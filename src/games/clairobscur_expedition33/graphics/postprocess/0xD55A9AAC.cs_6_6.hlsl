#include "../shared.h"

Texture2D<float4> ConvolutionInput_SceneColor : register(t0);

RWTexture2D<float4> ConvolutionOutput_SceneColor : register(u0);

cbuffer _RootShaderParameters : register(b0) {
  uint4 ViewportRect : packoffset(c000.x);
  float2 MaxInputBufferUV : packoffset(c001.x);
  float4 ConvolutionInputSize : packoffset(c004.x);
};

SamplerState D3DStaticPointClampedSampler : register(s1, space1000);

uint firstbithigh_msb(int value) { return (value == 0) ? 0xFFFFFFFF : (31u - firstbithigh(value)); }
uint firstbithigh_msb(uint value) { return (value == 0) ? 0xFFFFFFFF : (31u - firstbithigh(value)); }

static const int _global_0[18] = { -1, -1, 0, -1, 1, -1, -1, 0, 0, 0, 1, 0, -1, 1, 0, 1, 1, 1 };

static const float3 singlepassdof_axes[11] = {
  float3(1, 0, 0), float3(0, 1, 0), float3(0, 0, 1),
  float3(0.000000f, 0.664104f, -0.747640f),
  float3(-0.656496f, -0.656139f, 0.372149f),
  float3(-0.664251f, 0.000000f, -0.747509f),
  float3(-0.664672f, 0.000000f, 0.747135f),
  float3(0.000000f, 0.664287f, 0.747478f),
  float3(0.657415f, -0.657637f, -0.367857f),
  float3(-0.656571f, -0.657954f, -0.368796f),
  float3(0.656800f, -0.655635f, 0.372501f)
};

float3 singlepassdof_variance_clip(float3 cur_color, float3 prev_color, float3 colors[9]) {
  float3 dir = prev_color - cur_color;
  float near_t = -1e9f, far_t = 1e9f;
  [unroll] for (int a = 0; a < 11; ++a) {
    float3 axis = singlepassdof_axes[a];
    float2 moments = float2(0, 0);
    [unroll] for (int n = 0; n < 9; ++n) {
      float t = dot(colors[n], axis);
      moments += float2(t, t * t);
    }
    float proj_pos = dot(cur_color, axis);
    moments /= 9.0f;
    float mu = moments.x;
    float sigma = sqrt(max(moments.y - mu * mu, 0.0f));
    float2 extent = float2(min(mu - 1.25f * sigma, proj_pos), max(mu + 1.25f * sigma, proj_pos));
    float inv_dir = 1.0f / dot(dir, axis);
    float t0 = (extent.x - proj_pos) * inv_dir;
    float t1 = (extent.y - proj_pos) * inv_dir;
    near_t = max(near_t, min(t0, t1));
    far_t = min(far_t, max(t0, t1));
  }
  if (near_t <= far_t && (near_t > 0.0f || far_t > 0.0f)) {
    float t = clamp(near_t > 0.0f ? near_t : far_t, 0.0f, 1.0f);
    return cur_color + t * dir;
  }
  return cur_color;
}

[numthreads(8, 8, 1)]
void main(uint3 SV_DispatchThreadID : SV_DispatchThreadID, uint3 SV_GroupID : SV_GroupID, uint3 SV_GroupThreadID : SV_GroupThreadID, uint SV_GroupIndex : SV_GroupIndex) {
  float _26 = float((uint)SV_DispatchThreadID.x) + 0.5f;
  float _27 = float((uint)SV_DispatchThreadID.y) + 0.5f;
  [branch]
  if (!((uint)(int)(SV_DispatchThreadID.x) >= (uint)ViewportRect.z || (uint)(int)(SV_DispatchThreadID.y) >= (uint)ViewportRect.w)) {
    float4 samples[9];
    [unroll] for (int i = 0; i < 9; i++) {
      samples[i] = ConvolutionInput_SceneColor.SampleLevel(D3DStaticPointClampedSampler, float2(
        min(ConvolutionInputSize.z * (float(_global_0[i*2]) + _26), MaxInputBufferUV.x),
        min(ConvolutionInputSize.w * (float(_global_0[i*2+1]) + _27), MaxInputBufferUV.y)), 0.0f);
    }
    float4 center = samples[4];
    int2 outPos = int2((int)(uint(ConvolutionInputSize.x * (ConvolutionInputSize.z * _26))), (int)(uint(ConvolutionInputSize.y * (ConvolutionInputSize.w * _27))));

    if (InjectionToggle(TOGGLE_USE_SINGLEPASS_DOF)) {
      float3 colors[9];
      [unroll] for (int n = 0; n < 9; n++) colors[n] = samples[n].xyz;
      float3 mean_color = float3(0,0,0);
      [unroll] for (int m = 0; m < 9; m++) mean_color += colors[m];
      mean_color /= 9.0f;
      float3 clipped = singlepassdof_variance_clip(mean_color, center.xyz, colors);
      float blur_amount = saturate(center.w * 2.0f);
      float3 final_rgb = lerp(clipped, mean_color, blur_amount * 0.5f);
      float min_a = samples[0].w, max_a = samples[0].w;
      [unroll] for (int k = 1; k < 9; k++) { min_a = min(min_a, samples[k].w); max_a = max(max_a, samples[k].w); }
      ConvolutionOutput_SceneColor[outPos] = float4(final_rgb, clamp(center.w, min_a, max_a));
    } else {
      // Original median filter
      float _20[9], _21[9], _22[9], _23[9];
      [unroll] for (int j = 0; j < 9; j++) { _20[j]=samples[j].x; _21[j]=samples[j].y; _22[j]=samples[j].z; _23[j]=samples[j].w; }
      float _8[3],_9[3],_10[3],_11[3],_12[3],_13[3],_14[3],_15[3],_16[3],_17[3],_18[3],_19[3];
      [unroll] for (int row = 0; row < 3; row++) {
        int b = row*3;
        float ax=_20[b],ay=_21[b],az=_22[b],aw=_23[b];
        float bx=_20[b+1],by=_21[b+1],bz=_22[b+1],bw=_23[b+1];
        float cx=_20[b+2],cy=_21[b+2],cz=_22[b+2],cw=_23[b+2];
        _16[row]=min(ax,min(bx,cx)); _17[row]=min(ay,min(by,cy)); _18[row]=min(az,min(bz,cz)); _19[row]=min(aw,min(bw,cw));
        float midx=min(max(ax,min(bx,cx)),max(bx,cx)); float midy=min(max(ay,min(by,cy)),max(by,cy));
        float midz=min(max(az,min(bz,cz)),max(bz,cz)); float midw=min(max(aw,min(bw,cw)),max(bw,cw));
        _12[row]=midx; _13[row]=midy; _14[row]=midz; _15[row]=midw;
        _8[row]=max(ax,max(bx,cx)); _9[row]=max(ay,max(by,cy)); _10[row]=max(az,max(bz,cz)); _11[row]=max(aw,max(bw,cw));
      }
      float rx=min(max(max(_16[0],max(_16[1],_16[2])),min(min(max(_12[0],min(_12[1],_12[2])),max(min(_12[0],_12[1]),_12[2])),min(_8[0],min(_8[1],_8[2])))),max(min(max(_12[0],min(_12[1],_12[2])),max(min(_12[0],_12[1]),_12[2])),min(_8[0],min(_8[1],_8[2]))));
      float ry=min(max(max(_17[0],max(_17[1],_17[2])),min(min(max(_13[0],min(_13[1],_13[2])),max(min(_13[0],_13[1]),_13[2])),min(_9[0],min(_9[1],_9[2])))),max(min(max(_13[0],min(_13[1],_13[2])),max(min(_13[0],_13[1]),_13[2])),min(_9[0],min(_9[1],_9[2]))));
      float rz=min(max(max(_18[0],max(_18[1],_18[2])),min(min(max(_14[0],min(_14[1],_14[2])),max(min(_14[0],_14[1]),_14[2])),min(_10[0],min(_10[1],_10[2])))),max(min(max(_14[0],min(_14[1],_14[2])),max(min(_14[0],_14[1]),_14[2])),min(_10[0],min(_10[1],_10[2]))));
      float rw=min(max(max(_19[0],max(_19[1],_19[2])),min(min(max(_15[0],min(_15[1],_15[2])),max(min(_15[0],_15[1]),_15[2])),min(_11[0],min(_11[1],_11[2])))),max(min(max(_15[0],min(_15[1],_15[2])),max(min(_15[0],_15[1]),_15[2])),min(_11[0],min(_11[1],_11[2]))));
      ConvolutionOutput_SceneColor[outPos] = float4(rx, ry, rz, rw);
    }
  }
}
