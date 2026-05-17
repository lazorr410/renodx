#include "../shared.h"

// IS-FAST noise: 128x128x32 RG8_UNORM source, decoded into float2 elements.
// Bound as a ByteAddressBuffer (D3D12 root SRV) instead of a typed texture
// to avoid forcing ReShade's descriptor-heap swap. See
// project-docs/011_buffer-srv-injection-no-heap-swap/.
ByteAddressBuffer FASTNoiseTexture : register(t0, space50);

// Flat-index helper: emulate Texture2DArray.Load(int4(x, y, slice, 0))
// over a ByteAddressBuffer with shape [SLICES][HEIGHT][WIDTH] in row-major.
// Each element is a float2 (8 bytes). asfloat() reinterprets the raw uint2
// load as the original normalized [0,1] floats from the C++ upload.
static const uint FAST_NOISE_W = 128u;
static const uint FAST_NOISE_H = 128u;
static const uint FAST_NOISE_SLICE_TEXELS = FAST_NOISE_W * FAST_NOISE_H;
static const uint FAST_NOISE_ELEMENT_BYTES = 8u;  // sizeof(float2)
static float2 FastNoiseLoad(uint x, uint y, uint slice) {
  uint flat_index = slice * FAST_NOISE_SLICE_TEXELS + y * FAST_NOISE_W + x;
  uint byte_offset = flat_index * FAST_NOISE_ELEMENT_BYTES;
  return asfloat(FASTNoiseTexture.Load2(byte_offset));
}

// --- Fog History Filter Implementations ---

float3 BSplineTricubicSample3(Texture3D<float4> tex, SamplerState samp, float3 uvw, float3 texSize, float3 uvMax) {
  float3 coord = uvw * texSize - 0.5;
  float3 f = frac(coord);
  float3 f2 = f * f;
  float3 f3 = f2 * f;
  float3 w0 = (1.0 / 6.0) * (-f3 + 3.0 * f2 - 3.0 * f + 1.0);
  float3 w1 = (1.0 / 6.0) * (3.0 * f3 - 6.0 * f2 + 4.0);
  float3 w2 = (1.0 / 6.0) * (-3.0 * f3 + 3.0 * f2 + 3.0 * f + 1.0);
  float3 w3 = (1.0 / 6.0) * f3;
  float3 g0 = w0 + w1;
  float3 g1 = w2 + w3;
  float3 h0 = (w1 / g0) - 0.5 + floor(coord);
  float3 h1 = (w3 / g1) + 1.5 + floor(coord);
  float3 tc0 = clamp(h0 / texSize, 0.0, uvMax);
  float3 tc1 = clamp(h1 / texSize, 0.0, uvMax);
  float4 s000 = tex.SampleLevel(samp, float3(tc0.x, tc0.y, tc0.z), 0);
  float4 s100 = tex.SampleLevel(samp, float3(tc1.x, tc0.y, tc0.z), 0);
  float4 s010 = tex.SampleLevel(samp, float3(tc0.x, tc1.y, tc0.z), 0);
  float4 s110 = tex.SampleLevel(samp, float3(tc1.x, tc1.y, tc0.z), 0);
  float4 s001 = tex.SampleLevel(samp, float3(tc0.x, tc0.y, tc1.z), 0);
  float4 s101 = tex.SampleLevel(samp, float3(tc1.x, tc0.y, tc1.z), 0);
  float4 s011 = tex.SampleLevel(samp, float3(tc0.x, tc1.y, tc1.z), 0);
  float4 s111 = tex.SampleLevel(samp, float3(tc1.x, tc1.y, tc1.z), 0);
  float gx = g1.x / (g0.x + g1.x);
  float gy = g1.y / (g0.y + g1.y);
  float gz = g1.z / (g0.z + g1.z);
  float4 xy0 = lerp(lerp(s000, s100, gx), lerp(s010, s110, gx), gy);
  float4 xy1 = lerp(lerp(s001, s101, gx), lerp(s011, s111, gx), gy);
  float4 bspline_result = lerp(xy0, xy1, gz);
  float4 bilinear_result = tex.SampleLevel(samp, uvw, 0);
  float3 diff = abs(bspline_result.rgb - bilinear_result.rgb);
  float max_val = max(max(bilinear_result.r, bilinear_result.g), max(bilinear_result.b, 0.001));
  float contrast = (diff.r + diff.g + diff.b) / (3.0 * max_val);
  float detail_preserve = saturate(contrast * 6.667);
  return lerp(bspline_result.rgb, bilinear_result.rgb, detail_preserve);
}

float3 CatmullRomTricubicSample3(Texture3D<float4> tex, SamplerState samp, float3 uvw, float3 texSize, float3 uvMax) {
  float3 coord = uvw * texSize - 0.5;
  float3 f = frac(coord);
  float3 f2 = f * f;
  float3 f3 = f2 * f;
  float3 bw0 = (1.0 / 6.0) * (-f3 + 3.0 * f2 - 3.0 * f + 1.0);
  float3 bw1 = (1.0 / 6.0) * (3.0 * f3 - 6.0 * f2 + 4.0);
  float3 bw2 = (1.0 / 6.0) * (-3.0 * f3 + 3.0 * f2 + 3.0 * f + 1.0);
  float3 bw3 = (1.0 / 6.0) * f3;
  float3 bg0 = bw0 + bw1;
  float3 bg1 = bw2 + bw3;
  float3 bh0 = (bw1 / bg0) - 0.5 + floor(coord);
  float3 bh1 = (bw3 / bg1) + 1.5 + floor(coord);
  float3 bt0 = clamp(bh0 / texSize, 0.0, uvMax);
  float3 bt1 = clamp(bh1 / texSize, 0.0, uvMax);
  float bgx = bg1.x / (bg0.x + bg1.x);
  float bgy = bg1.y / (bg0.y + bg1.y);
  float bgz = bg1.z / (bg0.z + bg1.z);
  float4 bs000 = tex.SampleLevel(samp, float3(bt0.x, bt0.y, bt0.z), 0);
  float4 bs100 = tex.SampleLevel(samp, float3(bt1.x, bt0.y, bt0.z), 0);
  float4 bs010 = tex.SampleLevel(samp, float3(bt0.x, bt1.y, bt0.z), 0);
  float4 bs110 = tex.SampleLevel(samp, float3(bt1.x, bt1.y, bt0.z), 0);
  float4 bs001 = tex.SampleLevel(samp, float3(bt0.x, bt0.y, bt1.z), 0);
  float4 bs101 = tex.SampleLevel(samp, float3(bt1.x, bt0.y, bt1.z), 0);
  float4 bs011 = tex.SampleLevel(samp, float3(bt0.x, bt1.y, bt1.z), 0);
  float4 bs111 = tex.SampleLevel(samp, float3(bt1.x, bt1.y, bt1.z), 0);
  float4 bxy0 = lerp(lerp(bs000, bs100, bgx), lerp(bs010, bs110, bgx), bgy);
  float4 bxy1 = lerp(lerp(bs001, bs101, bgx), lerp(bs011, bs111, bgx), bgy);
  float4 bspline = lerp(bxy0, bxy1, bgz);
  float4 bilinear = tex.SampleLevel(samp, uvw, 0);
  float4 sharp_result = max(bspline * 1.2 - bilinear * 0.2, 0.0);
  float3 diff = abs(sharp_result.rgb - bilinear.rgb);
  float max_val = max(max(bilinear.r, bilinear.g), max(bilinear.b, 0.001));
  float contrast = (diff.r + diff.g + diff.b) / (3.0 * max_val);
  float detail_preserve = saturate(contrast * 6.667);
  return lerp(sharp_result.rgb, bilinear.rgb, detail_preserve);
}

float3 TriquadraticSample3(Texture3D<float4> tex, SamplerState samp, float3 uvw, float3 texSize, float3 uvMax) {
  float3 coord = uvw * texSize - 0.5;
  float3 f = frac(coord);
  float3 w0 = 0.5 * (1.0 - f) * (1.0 - f);
  float3 w2 = 0.5 * f * f;
  float3 w1 = 1.0 - w0 - w2;
  float3 h0 = clamp((floor(coord) + 0.5 - (0.5 * (1.0 - f) / (w0 + w1))) / texSize, 0.0, uvMax);
  float3 h1 = clamp((floor(coord) + 0.5 + (0.5 * f / (w1 + w2)) + 1.0) / texSize, 0.0, uvMax);
  float3 g0 = w0 + w1;
  float3 g1 = w1 + w2;
  float4 s0 = tex.SampleLevel(samp, h0, 0);
  float4 s1 = tex.SampleLevel(samp, h1, 0);
  float3 blend = g1 / (g0 + g1);
  return lerp(s0.rgb, s1.rgb, blend.x * blend.y * blend.z);
}

float3 SampleFogHistory3(Texture3D<float4> tex, SamplerState samp, float3 uvw, float3 texSize, uint mode, float3 uvMax) {
  if (mode > 2u) {
    return TriquadraticSample3(tex, samp, uvw, texSize, uvMax);
  } else if (mode > 1u) {
    return CatmullRomTricubicSample3(tex, samp, uvw, texSize, uvMax);
  } else if (mode > 0u) {
    return BSplineTricubicSample3(tex, samp, uvw, texSize, uvMax);
  } else {
    return tex.SampleLevel(samp, uvw, 0).rgb;
  }
}

Texture2D<float4> t0 : register(t0);

StructuredBuffer<float4> t1 : register(t1);

Texture2D<float4> t2 : register(t2);

StructuredBuffer<float4> t3 : register(t3);

StructuredBuffer<uint> t4 : register(t4);

Buffer<uint> t5 : register(t5);

Texture3D<float4> t6 : register(t6);

Texture3D<float4> t7 : register(t7);

ByteAddressBuffer t8 : register(t8);

Texture2D<uint> t9 : register(t9);

Texture2DArray<uint> t10 : register(t10);

Texture2D<float> t11 : register(t11);

Texture2D<float3> t12 : register(t12);

Texture2D<float> t13 : register(t13);

Texture2D<float> t14 : register(t14);

Texture3D<float4> t15 : register(t15);

Texture3D<float4> t16 : register(t16);

Texture3D<float4> t17 : register(t17);

Texture3D<float4> t18 : register(t18);

Texture3D<float4> t19 : register(t19);

Texture3D<float4> t20 : register(t20);

Texture2D<float4> t21 : register(t21);

RWTexture3D<float3> u0 : register(u0);

RWTexture3D<float3> u1 : register(u1);

cbuffer cb0 : register(b0) {
  float cb0_005x : packoffset(c005.x);
  float cb0_005y : packoffset(c005.y);
  float cb0_005z : packoffset(c005.z);
  float cb0_005w : packoffset(c005.w);
  float cb0_006x : packoffset(c006.x);
  float cb0_006y : packoffset(c006.y);
  float cb0_006z : packoffset(c006.z);
  float cb0_006w : packoffset(c006.w);
  float cb0_007x : packoffset(c007.x);
  float cb0_007y : packoffset(c007.y);
  float cb0_007z : packoffset(c007.z);
  float cb0_007w : packoffset(c007.w);
  float cb0_008x : packoffset(c008.x);
  float cb0_008y : packoffset(c008.y);
  float cb0_008z : packoffset(c008.z);
  float cb0_008w : packoffset(c008.w);
  float cb0_009x : packoffset(c009.x);
  float cb0_009y : packoffset(c009.y);
  float cb0_009z : packoffset(c009.z);
  float cb0_009w : packoffset(c009.w);
  float cb0_010x : packoffset(c010.x);
  float cb0_010y : packoffset(c010.y);
  float cb0_010z : packoffset(c010.z);
  float cb0_010w : packoffset(c010.w);
  float cb0_011x : packoffset(c011.x);
  float cb0_011y : packoffset(c011.y);
  float cb0_011z : packoffset(c011.z);
  float cb0_011w : packoffset(c011.w);
  float cb0_012x : packoffset(c012.x);
  float cb0_012y : packoffset(c012.y);
  float cb0_012z : packoffset(c012.z);
  float cb0_012w : packoffset(c012.w);
  float cb0_013x : packoffset(c013.x);
  float cb0_013y : packoffset(c013.y);
  float cb0_013z : packoffset(c013.z);
  float cb0_029x : packoffset(c029.x);
  float cb0_078x : packoffset(c078.x);
  float cb0_078y : packoffset(c078.y);
  float cb0_079x : packoffset(c079.x);
  float cb0_079y : packoffset(c079.y);
  float cb0_080x : packoffset(c080.x);
  float cb0_080y : packoffset(c080.y);
  float cb0_081x : packoffset(c081.x);
  float cb0_081y : packoffset(c081.y);
  float cb0_082x : packoffset(c082.x);
  float cb0_082y : packoffset(c082.y);
  float cb0_082z : packoffset(c082.z);
  float cb0_082w : packoffset(c082.w);
  float cb0_083x : packoffset(c083.x);
  float cb0_083y : packoffset(c083.y);
  float cb0_083z : packoffset(c083.z);
  float cb0_083w : packoffset(c083.w);
  float cb0_084x : packoffset(c084.x);
  float cb0_084y : packoffset(c084.y);
  float cb0_084z : packoffset(c084.z);
  float cb0_084w : packoffset(c084.w);
  float cb0_085x : packoffset(c085.x);
  float cb0_085y : packoffset(c085.y);
  float cb0_085z : packoffset(c085.z);
  float cb0_085w : packoffset(c085.w);
  float cb0_088z : packoffset(c088.z);
  float cb0_089y : packoffset(c089.y);
  float cb0_090x : packoffset(c090.x);
  float cb0_090y : packoffset(c090.y);
  float cb0_090z : packoffset(c090.z);
  float cb0_090w : packoffset(c090.w);
  float cb0_091x : packoffset(c091.x);
  float cb0_091y : packoffset(c091.y);
  float cb0_091z : packoffset(c091.z);
  float cb0_091w : packoffset(c091.w);
  float cb0_092x : packoffset(c092.x);
  int cb0_092y : packoffset(c092.y);
  int cb0_092z : packoffset(c092.z);
  int cb0_093x : packoffset(c093.x);
  int cb0_093y : packoffset(c093.y);
};

cbuffer cb1 : register(b1) {
  uint4 cb1_raw[630];
};

cbuffer cb2 : register(b2) {
  int LightFunctionAtlas_000 : packoffset(c000.x);
  int LightFunctionAtlas_004 : packoffset(c000.y);
  int LightFunctionAtlas_008 : packoffset(c000.z);
  int LightFunctionAtlas_012 : packoffset(c000.w);
  int LightFunctionAtlas_016 : packoffset(c001.x);
  int LightFunctionAtlas_020 : packoffset(c001.y);
  float LightFunctionAtlas_024 : packoffset(c001.z);
};

cbuffer cb3 : register(b3) {
  uint4 cb3_raw[45];
};

cbuffer cb4 : register(b4) {
  float LumenGIVolumeStruct_000 : packoffset(c000.x);
  float LumenGIVolumeStruct_004 : packoffset(c000.y);
  float LumenGIVolumeStruct_008 : packoffset(c000.z);
  float LumenGIVolumeStruct_012 : packoffset(c000.w);
  float LumenGIVolumeStruct_016 : packoffset(c001.x);
  float LumenGIVolumeStruct_020 : packoffset(c001.y);
  int2 LumenGIVolumeStruct_024 : packoffset(c001.z);
  int LumenGIVolumeStruct_032 : packoffset(c002.x);
  int LumenGIVolumeStruct_036 : packoffset(c002.y);
  int LumenGIVolumeStruct_040 : packoffset(c002.z);
  int LumenGIVolumeStruct_044 : packoffset(c002.w);
  int LumenGIVolumeStruct_048 : packoffset(c003.x);
  int LumenGIVolumeStruct_052 : packoffset(c003.y);
  int LumenGIVolumeStruct_056 : packoffset(c003.z);
  int LumenGIVolumeStruct_060 : packoffset(c003.w);
  int LumenGIVolumeStruct_064 : packoffset(c004.x);
  int LumenGIVolumeStruct_068 : packoffset(c004.y);
  int LumenGIVolumeStruct_072 : packoffset(c004.z);
  float LumenGIVolumeStruct_076 : packoffset(c004.w);
  int LumenGIVolumeStruct_080 : packoffset(c005.x);
  int LumenGIVolumeStruct_084 : packoffset(c005.y);
  int LumenGIVolumeStruct_088 : packoffset(c005.z);
  int LumenGIVolumeStruct_092 : packoffset(c005.w);
  int LumenGIVolumeStruct_096 : packoffset(c006.x);
  int LumenGIVolumeStruct_100 : packoffset(c006.y);
  int LumenGIVolumeStruct_104 : packoffset(c006.z);
  int LumenGIVolumeStruct_108 : packoffset(c006.w);
  int LumenGIVolumeStruct_112 : packoffset(c007.x);
  int LumenGIVolumeStruct_116 : packoffset(c007.y);
  int LumenGIVolumeStruct_120 : packoffset(c007.z);
  int LumenGIVolumeStruct_124 : packoffset(c007.w);
  int LumenGIVolumeStruct_128 : packoffset(c008.x);
  int LumenGIVolumeStruct_132 : packoffset(c008.y);
  int LumenGIVolumeStruct_136 : packoffset(c008.z);
  int LumenGIVolumeStruct_140 : packoffset(c008.w);
  float4 LumenGIVolumeStruct_144[6] : packoffset(c009.x);
  float4 LumenGIVolumeStruct_240[6] : packoffset(c015.x);
  float2 LumenGIVolumeStruct_336 : packoffset(c021.x);
  float2 LumenGIVolumeStruct_344 : packoffset(c021.z);
  float2 LumenGIVolumeStruct_352 : packoffset(c022.x);
  float LumenGIVolumeStruct_360 : packoffset(c022.z);
  int LumenGIVolumeStruct_364 : packoffset(c022.w);
  int LumenGIVolumeStruct_368 : packoffset(c023.x);
  int LumenGIVolumeStruct_372 : packoffset(c023.y);
  int LumenGIVolumeStruct_376 : packoffset(c023.z);
  float LumenGIVolumeStruct_380 : packoffset(c023.w);
  int LumenGIVolumeStruct_384 : packoffset(c024.x);
  int LumenGIVolumeStruct_388 : packoffset(c024.y);
  int LumenGIVolumeStruct_392 : packoffset(c024.z);
  int LumenGIVolumeStruct_396 : packoffset(c024.w);
  int LumenGIVolumeStruct_400 : packoffset(c025.x);
  int LumenGIVolumeStruct_404 : packoffset(c025.y);
  int LumenGIVolumeStruct_408 : packoffset(c025.z);
  float LumenGIVolumeStruct_412 : packoffset(c025.w);
  float LumenGIVolumeStruct_416 : packoffset(c026.x);
  float LumenGIVolumeStruct_420 : packoffset(c026.y);
  float LumenGIVolumeStruct_424 : packoffset(c026.z);
  float LumenGIVolumeStruct_428 : packoffset(c026.w);
  int LumenGIVolumeStruct_432 : packoffset(c027.x);
  int LumenGIVolumeStruct_436 : packoffset(c027.y);
  int LumenGIVolumeStruct_440 : packoffset(c027.z);
  int LumenGIVolumeStruct_444 : packoffset(c027.w);
  int LumenGIVolumeStruct_448 : packoffset(c028.x);
  int LumenGIVolumeStruct_452 : packoffset(c028.y);
  int LumenGIVolumeStruct_456 : packoffset(c028.z);
  int LumenGIVolumeStruct_460 : packoffset(c028.w);
  int LumenGIVolumeStruct_464 : packoffset(c029.x);
  int LumenGIVolumeStruct_468 : packoffset(c029.y);
  int LumenGIVolumeStruct_472 : packoffset(c029.z);
  int LumenGIVolumeStruct_476 : packoffset(c029.w);
  float3 LumenGIVolumeStruct_480 : packoffset(c030.x);
  int LumenGIVolumeStruct_492 : packoffset(c030.w);
  int3 LumenGIVolumeStruct_496 : packoffset(c031.x);
};

cbuffer cb5 : register(b5) {
  int VirtualShadowMap_000 : packoffset(c000.x);
  int VirtualShadowMap_004 : packoffset(c000.y);
  int VirtualShadowMap_008 : packoffset(c000.z);
  int VirtualShadowMap_012 : packoffset(c000.w);
  int VirtualShadowMap_016 : packoffset(c001.x);
  int VirtualShadowMap_020 : packoffset(c001.y);
  int VirtualShadowMap_024 : packoffset(c001.z);
  int VirtualShadowMap_028 : packoffset(c001.w);
  int VirtualShadowMap_032 : packoffset(c002.x);
  int VirtualShadowMap_036 : packoffset(c002.y);
  int VirtualShadowMap_040 : packoffset(c002.z);
  int VirtualShadowMap_044 : packoffset(c002.w);
  float4 VirtualShadowMap_048 : packoffset(c003.x);
  int2 VirtualShadowMap_064 : packoffset(c004.x);
  int2 VirtualShadowMap_072 : packoffset(c004.z);
  int VirtualShadowMap_080 : packoffset(c005.x);
  int VirtualShadowMap_084 : packoffset(c005.y);
  int VirtualShadowMap_088 : packoffset(c005.z);
  int VirtualShadowMap_092 : packoffset(c005.w);
  float4 VirtualShadowMap_096 : packoffset(c006.x);
  int VirtualShadowMap_112 : packoffset(c007.x);
  float VirtualShadowMap_116 : packoffset(c007.y);
  float VirtualShadowMap_120 : packoffset(c007.z);
  float VirtualShadowMap_124 : packoffset(c007.w);
  int VirtualShadowMap_128 : packoffset(c008.x);
  float VirtualShadowMap_132 : packoffset(c008.y);
  int VirtualShadowMap_136 : packoffset(c008.z);
  int VirtualShadowMap_140 : packoffset(c008.w);
  float VirtualShadowMap_144 : packoffset(c009.x);
  float VirtualShadowMap_148 : packoffset(c009.y);
  int VirtualShadowMap_152 : packoffset(c009.z);
  int VirtualShadowMap_156 : packoffset(c009.w);
  int VirtualShadowMap_160 : packoffset(c010.x);
  float VirtualShadowMap_164 : packoffset(c010.y);
  float VirtualShadowMap_168 : packoffset(c010.z);
  float VirtualShadowMap_172 : packoffset(c010.w);
  float VirtualShadowMap_176 : packoffset(c011.x);
  int VirtualShadowMap_180 : packoffset(c011.y);
  int VirtualShadowMap_184 : packoffset(c011.z);
  float VirtualShadowMap_188 : packoffset(c011.w);
  float VirtualShadowMap_192 : packoffset(c012.x);
  float VirtualShadowMap_196 : packoffset(c012.y);
  int VirtualShadowMap_200 : packoffset(c012.z);
  int VirtualShadowMap_204 : packoffset(c012.w);
  int VirtualShadowMap_208 : packoffset(c013.x);
  int VirtualShadowMap_212 : packoffset(c013.y);
  int VirtualShadowMap_216 : packoffset(c013.z);
  int VirtualShadowMap_220 : packoffset(c013.w);
  int VirtualShadowMap_224 : packoffset(c014.x);
  int VirtualShadowMap_228 : packoffset(c014.y);
  int VirtualShadowMap_232 : packoffset(c014.z);
  int VirtualShadowMap_236 : packoffset(c014.w);
  int VirtualShadowMap_240 : packoffset(c015.x);
  int VirtualShadowMap_244 : packoffset(c015.y);
  int VirtualShadowMap_248 : packoffset(c015.z);
  int VirtualShadowMap_252 : packoffset(c015.w);
  int VirtualShadowMap_256 : packoffset(c016.x);
  int VirtualShadowMap_260 : packoffset(c016.y);
  int VirtualShadowMap_264 : packoffset(c016.z);
  int VirtualShadowMap_268 : packoffset(c016.w);
  int VirtualShadowMap_272 : packoffset(c017.x);
  float VirtualShadowMap_276 : packoffset(c017.y);
  float VirtualShadowMap_280 : packoffset(c017.z);
  float VirtualShadowMap_284 : packoffset(c017.w);
  int VirtualShadowMap_288 : packoffset(c018.x);
  int VirtualShadowMap_292 : packoffset(c018.y);
  int VirtualShadowMap_296 : packoffset(c018.z);
  int VirtualShadowMap_300 : packoffset(c018.w);
  int VirtualShadowMap_304 : packoffset(c019.x);
};

cbuffer cb6 : register(b6) {
  int3 VolumetricFog_000 : packoffset(c000.x);
  int VolumetricFog_012 : packoffset(c000.w);
  float3 VolumetricFog_016 : packoffset(c001.x);
  float VolumetricFog_028 : packoffset(c001.w);
  int3 VolumetricFog_032 : packoffset(c002.x);
  int VolumetricFog_044 : packoffset(c002.w);
  float3 VolumetricFog_048 : packoffset(c003.x);
  float VolumetricFog_060 : packoffset(c003.w);
  float3 VolumetricFog_064 : packoffset(c004.x);
  float VolumetricFog_076 : packoffset(c004.w);
  float2 VolumetricFog_080 : packoffset(c005.x);
  float VolumetricFog_088 : packoffset(c005.z);
  float VolumetricFog_092 : packoffset(c005.w);
  float3 VolumetricFog_096 : packoffset(c006.x);
  float VolumetricFog_108 : packoffset(c006.w);
  float3 VolumetricFog_112 : packoffset(c007.x);
  float VolumetricFog_124 : packoffset(c007.w);
  int2 VolumetricFog_128 : packoffset(c008.x);
};

SamplerState s0 : register(s0);

SamplerState s1 : register(s1);

SamplerState s2 : register(s2);

SamplerState s3 : register(s3);

SamplerState s4 : register(s4);

SamplerState s5 : register(s5);

// DXIL FirstbitHi: returns bit position counting from MSB (leading zeros count)
uint firstbithigh_msb(int value) { return (value == 0) ? 0xFFFFFFFF : (31u - firstbithigh(value)); }
uint firstbithigh_msb(uint value) { return (value == 0) ? 0xFFFFFFFF : (31u - firstbithigh(value)); }

[numthreads(4, 4, 4)]
void main(
  uint3 SV_DispatchThreadID : SV_DispatchThreadID,
  uint3 SV_GroupID : SV_GroupID,
  uint3 SV_GroupThreadID : SV_GroupThreadID,
  uint SV_GroupIndex : SV_GroupIndex
) {
  float _48;
  float _49;
  float _59;
  float _61;
  float _62;
  float _72;
  bool _75;
  float _90;
  float _216;
  float _357;
  float _358;
  int _359;
  float _421;
  float _507;
  float _665;
  int _712;
  int _713;
  int _837;
  int _838;
  int _935;
  int _936;
  int _947;
  int _948;
  int _949;
  int _950;
  float _951;
  float _952;
  float _970;
  bool _971;
  int _1049;
  int _1081;
  int _1082;
  int _1083;
  int _1084;
  int _1085;
  int _1086;
  int _1087;
  int _1088;
  int _1089;
  int _1090;
  int _1091;
  int _1092;
  int _1093;
  int _1094;
  int _1095;
  int _1096;
  int _1097;
  int _1098;
  int _1162;
  int _1163;
  int _1167;
  int _1168;
  float _1201;
  bool _1202;
  float _1207;
  float _1278;
  float _1393;
  float _1394;
  float _1428;
  float _1474;
  float _1475;
  float _1476;
  bool _1546;
  bool _1591;
  int _1592;
  bool _1637;
  int _1638;
  int _1684;
  float _1774;
  float _1775;
  float _1776;
  float _1805;
  float _1806;
  float _1807;
  float _1808;
  float _1996;
  float _2032;
  float _2033;
  float _2034;
  int _2035;
  float _2136;
  float _2145;
  float _2151;
  float _2259;
  float _2260;
  float _2261;
  float _2262;
  float _2263;
  float _2416;
  float _2419;
  float _2529;
  float _2530;
  float _2575;
  float _2590;
  float _2591;
  float _2592;
  float _2622;
  float _2623;
  float _2624;
  float _2629;
  float _2630;
  float _2631;
  float _2664;
  float _2665;
  float _2666;
  float _2765;
  float _2766;
  float _2767;
  float _2768;
  float _2769;
  float _2770;
  float _112;
  float _116;
  float _120;
  float _124;
  float _126;
  float _127;
  float _128;
  float _129;
  float _157;
  float _185;
  float _186;
  float _189;
  float _190;
  float _191;
  float _201;
  float _224;
  float _225;
  float _226;
  float _227;
  float _269;
  float _273;
  float _274;
  float _281;
  float _282;
  float _287;
  float _288;
  float4 _293;
  bool _298;
  bool _299;
  bool _300;
  bool _301;
  bool _302;
  float _371;
  float _372;
  float _373;
  uint _429;
  uint _430;
  uint _431;
  uint _433;
  uint _435;
  uint _437;
  uint _439;
  int _445;
  int _446;
  uint _449;
  uint _451;
  float _475;
  float _476;
  float _477;
  float _484;
  float _486;
  float _492;
  float _523;
  float _524;
  float _525;
  float _526;
  float _530;
  float _531;
  float _532;
  float _541;
  float _542;
  float _543;
  float _545;
  bool _549;
  float _550;
  float _551;
  float _552;
  float _561;
  float _562;
  float _563;
  int _594;
  int _597;
  float4 _599;
  float4 _604;
  float4 _609;
  float4 _614;
  float _629;
  float _630;
  float _631;
  float4 _633;
  int _668;
  int _672;
  uint _674;
  uint _675;
  int _678;
  int _679;
  int _680;
  int _685;
  int _686;
  int _687;
  int _693;
  int _697;
  int _698;
  int _699;
  int _705;
  float _726;
  float _727;
  float _728;
  int _740;
  int _743;
  int _745;
  int _748;
  int _749;
  int _750;
  int _756;
  int _757;
  int _758;
  int _764;
  int _765;
  int _766;
  int _772;
  int _773;
  int _774;
  int _780;
  int _781;
  int _782;
  int _788;
  int _789;
  int _790;
  float _803;
  float _804;
  float _805;
  float _809;
  float _813;
  uint _820;
  uint _821;
  bool _822;
  uint _827;
  uint _844;
  int _846;
  int _847;
  bool _850;
  uint _852;
  int _860;
  int _861;
  int _863;
  int _866;
  int _867;
  int _874;
  int _879;
  int _880;
  uint _881;
  uint _882;
  int _887;
  int _891;
  float _899;
  bool _920;
  uint _925;
  uint _941;
  int _978;
  int _979;
  int _980;
  int _981;
  int _984;
  int _985;
  int _986;
  int _987;
  int _990;
  int _991;
  int _992;
  int _993;
  int _996;
  int _997;
  int _998;
  int _999;
  int _1001;
  int _1002;
  int _1003;
  int _1008;
  int _1009;
  int _1010;
  int _1016;
  float _1026;
  float _1027;
  float _1028;
  float _1031;
  float _1032;
  float _1034;
  uint _1050;
  int _1052;
  int _1055;
  int _1056;
  int _1057;
  int _1058;
  int _1061;
  int _1062;
  int _1063;
  int _1064;
  int _1067;
  int _1068;
  int _1069;
  int _1070;
  int _1073;
  int _1074;
  int _1075;
  int _1076;
  int _1079;
  float _1130;
  float _1131;
  float _1132;
  int _1138;
  bool _1141;
  uint _1146;
  uint _1174;
  float _1182;
  float _1208;
  float _1248;
  float3 _1258;
  uint _1286;
  float _1289;
  float _1290;
  float _1291;
  float _1292;
  int _1293;
  int _1294;
  float _1298;
  float _1307;
  float _1308;
  float _1309;
  float _1310;
  float _1313;
  float _1314;
  float _1315;
  float _1316;
  float _1319;
  float _1320;
  float _1321;
  float _1322;
  float _1325;
  float _1326;
  float _1327;
  float _1328;
  float _1344;
  float _1345;
  float _1346;
  float _1347;
  float _1349;
  float _1358;
  float _1359;
  float _1360;
  float _1363;
  bool _1366;
  bool _1367;
  bool _1368;
  bool _1369;
  float _1385;
  float4 _1407;
  float _1414;
  float _1415;
  float _1416;
  float _1422;
  float _1432;
  float4 _1469;
  float _1477;
  float _1478;
  float _1479;
  float _1480;
  float _1481;
  float _1482;
  float _1495;
  float _1496;
  float _1497;
  float _1498;
  float _1499;
  float _1500;
  float _1507;
  float _1508;
  float _1509;
  float _1510;
  float _1511;
  float _1512;
  float _1519;
  float _1520;
  float _1521;
  float _1533;
  float _1575;
  float _1621;
  float _1667;
  int _1686;
  float4 _1690;
  bool _1692;
  float4 _1697;
  float4 _1703;
  float4 _1707;
  float4 _1712;
  float _1720;
  float _1726;
  float _1738;
  float _1739;
  float _1740;
  float _1751;
  float _1769;
  float _1787;
  float _1791;
  float _1809;
  float _1810;
  float _1811;
  float _1835;
  float _1836;
  float _1837;
  float _1838;
  float _1839;
  float _1840;
  float _1853;
  float _1854;
  float _1855;
  float _1867;
  float _1881;
  float _1884;
  float _1885;
  float4 _1888;
  float4 _1893;
  float _1898;
  float _1899;
  float _1900;
  float _1901;
  float _1917;
  float _1918;
  float _1919;
  int _1941;
  uint _1950;
  int _1953;
  int _1956;
  int _1959;
  float _1972;
  float _1974;
  float _1981;
  float _2012;
  float _2016;
  float _2017;
  float _2018;
  float _2027;
  float _2028;
  uint _2040;
  float _2044;
  float _2045;
  float _2046;
  float _2049;
  float _2050;
  float _2051;
  float _2054;
  float _2055;
  float _2056;
  float _2059;
  float _2060;
  float _2062;
  int _2063;
  float _2065;
  float _2068;
  float _2069;
  float _2070;
  float _2071;
  float _2072;
  float _2073;
  float _2076;
  int _2077;
  int _2079;
  int _2080;
  float _2094;
  float _2095;
  float _2096;
  float _2097;
  bool _2099;
  int _2100;
  float _2102;
  float _2106;
  int _2108;
  bool _2109;
  float _2110;
  float _2111;
  float _2112;
  float _2113;
  float _2114;
  float _2115;
  float _2116;
  float _2117;
  float _2120;
  float _2123;
  float _2126;
  float _2127;
  float _2128;
  float _2141;
  float _2155;
  float _2158;
  float _2161;
  float _2166;
  float _2169;
  float _2172;
  float _2176;
  float _2177;
  float _2181;
  float _2192;
  float _2193;
  float _2207;
  float _2214;
  float _2215;
  float _2226;
  float _2227;
  float _2236;
  float _2237;
  float _2240;
  float _2241;
  float _2268;
  float _2269;
  float _2270;
  float _2271;
  float _2272;
  float _2273;
  float _2274;
  float _2275;
  float _2278;
  float _2279;
  float _2280;
  float _2281;
  float _2284;
  float _2285;
  float _2286;
  float _2287;
  float _2290;
  float _2291;
  float _2292;
  float _2293;
  float _2296;
  float _2297;
  float _2298;
  float _2299;
  float _2300;
  float _2301;
  float _2302;
  float _2303;
  float _2314;
  float _2325;
  float _2327;
  float _2334;
  float _2335;
  float _2336;
  float _2350;
  float _2354;
  float _2355;
  float _2356;
  float _2366;
  float _2367;
  float _2368;
  float _2381;
  float _2382;
  float _2383;
  float _2384;
  float _2389;
  float _2390;
  float _2391;
  float _2392;
  float _2393;
  float _2394;
  float _2395;
  float _2396;
  float _2397;
  float _2398;
  float _2400;
  float _2405;
  int _2422;
  float _2425;
  float _2426;
  float _2427;
  float _2428;
  int _2429;
  int _2430;
  float _2434;
  float _2443;
  float _2444;
  float _2445;
  float _2446;
  float _2449;
  float _2450;
  float _2451;
  float _2452;
  float _2455;
  float _2456;
  float _2457;
  float _2458;
  float _2461;
  float _2462;
  float _2463;
  float _2464;
  float _2480;
  float _2481;
  float _2482;
  float _2483;
  float _2485;
  float _2494;
  float _2495;
  float _2496;
  float _2499;
  bool _2502;
  bool _2503;
  bool _2504;
  bool _2505;
  float _2521;
  float4 _2543;
  float _2554;
  float _2555;
  float _2556;
  float _2562;
  float _2579;
  float _2607;
  float _2614;
  uint _2625;
  float4 _2635;
  float4 _2646;
  float4 _2651;
  float4 _2659;
  float _2674;
  float _2675;
  float _2676;
  float _2695;
  float _2696;
  float _2697;
  float4 _2700;
  float _2706;
  float _2707;
  float _2708;
  float _2709;
  float _2723;
  float _2725;
  float _2727;
  float _2739;
  float4 _2742;
  _48 = float((uint)SV_DispatchThreadID.x);
  _49 = float((uint)SV_DispatchThreadID.y);
  _59 = (((_48 + 0.5f) / VolumetricFog_016.x) * 2.0f) + -1.0f;
  _61 = -0.0f - ((((_49 + 0.5f) / VolumetricFog_016.y) * 2.0f) + -1.0f);
  _62 = float((uint)SV_DispatchThreadID.z);
  _72 = (exp2(max((_62 + 0.5f), 0.0f) / VolumetricFog_064.z) - VolumetricFog_064.y) / VolumetricFog_064.x;
  _75 = !(asfloat(cb1_raw[31u].w) >= 1.0f);
  [branch]
  if (_75) {
    _90 = (1.0f / ((_72 + asfloat(cb1_raw[78u].w)) * asfloat(cb1_raw[78u].z)));
  } else {
    _90 = ((_72 * asfloat(cb1_raw[30u].z)) + asfloat(cb1_raw[31u].z));
  }
  _112 = mad(_61, cb0_006x, (_59 * cb0_005x));
  _116 = mad(_61, cb0_006y, (_59 * cb0_005y));
  _120 = mad(_61, cb0_006z, (_59 * cb0_005z));
  _124 = mad(_61, cb0_006w, (_59 * cb0_005w));
  _126 = mad(1.0f, cb0_008w, mad(_90, cb0_007w, _124));
  _127 = mad(1.0f, cb0_008x, mad(_90, cb0_007x, _112)) / _126;
  _128 = mad(1.0f, cb0_008y, mad(_90, cb0_007y, _116)) / _126;
  _129 = mad(1.0f, cb0_008z, mad(_90, cb0_007z, _120)) / _126;
  _157 = mad(1.0f, cb0_012w, mad(_129, cb0_011w, mad(_128, cb0_010w, (_127 * cb0_009w))));
  _185 = asfloat(cb1_raw[254u].z) * asfloat(cb1_raw[255u].x);
  _186 = asfloat(cb1_raw[254u].w) * asfloat(cb1_raw[255u].y);
  _189 = min(((((mad(1.0f, cb0_012x, mad(_129, cb0_011x, mad(_128, cb0_010x, (_127 * cb0_009x)))) / _157) * 0.5f) + 0.5f) * _185), asfloat(cb1_raw[256u].x));
  _190 = min(((0.5f - ((mad(1.0f, cb0_012y, mad(_129, cb0_011y, mad(_128, cb0_010y, (_127 * cb0_009y)))) / _157) * 0.5f)) * _186), asfloat(cb1_raw[256u].y));
  _191 = min(max((asfloat(cb1_raw[252u].z) * (log2(asfloat(cb1_raw[253u].y) + (_157 * asfloat(cb1_raw[253u].x))) * asfloat(cb1_raw[253u].z))), 0.0f), 1.0f);
  if (cb0_092y == 0) {
    _357 = _189;
    _358 = _190;
    _359 = 1;
    _371 = asfloat(cb1_raw[85u].x) + 0.0f;
    _372 = asfloat(cb1_raw[85u].y) + 0.0f;
    _373 = asfloat(cb1_raw[85u].z) + 0.0f;
    if (((_191 < 0.0f) || ((_357 < 0.0f) || (_358 < 0.0f))) | !((_359 != 0) && (!((_191 >= 1.0f) || ((_357 >= asfloat(cb1_raw[256u].x)) || (_358 >= asfloat(cb1_raw[256u].y))))))) {
      _421 = 0.0f;
    } else {
      _421 = cb0_029x;
    }
    _429 = ((int)(SV_DispatchThreadID.y) * 1664525) + 1013904223u;
    _430 = ((int)(SV_DispatchThreadID.z) * 1664525) + 1013904223u;
    _431 = (asint(cb1_raw[165u].z) * 1664525) + 1013904223u;
    _433 = (((int)(SV_DispatchThreadID.x) * 1664525) + 1013904223u) + (_431 * _429);
    _435 = (_433 * _430) + _429;
    _437 = (_435 * _433) + _430;
    _439 = (_437 * _435) + _431;
    _445 = ((uint)(_435) >> 16) ^ _435;
    _446 = ((uint)(_437) >> 16) ^ _437;
    _449 = ((((uint)(_439) >> 16) ^ _439) * _445) + ((uint)(((uint)(_433) >> 16) ^ _433));
    _451 = (_449 * _446) + _445;
    if (InjectionToggle(TOGGLE_USE_ISFAST_FOG)) {
      uint _fast_slice = InjectionFrameIndex();
      float2 _fast_n = FastNoiseLoad(
          SV_DispatchThreadID.x % 128u,
          SV_DispatchThreadID.y % 128u,
          _fast_slice);
      float _fast_z_n = FastNoiseLoad(
          SV_DispatchThreadID.z % 128u,
          (SV_DispatchThreadID.x ^ SV_DispatchThreadID.y) % 128u,
          (_fast_slice + 16u) % 32u).x;
      _475 = cb0_013x + (cb0_090z * ((_fast_n.x * 2.0f) - 1.0f));
      _476 = cb0_013y + (cb0_090z * ((_fast_n.y * 2.0f) - 1.0f));
      _477 = cb0_013z + (cb0_090z * ((_fast_z_n * 2.0f) - 1.0f));
    } else {
      _475 = cb0_013x + (cb0_090z * (((float((uint)_449) * 2.3283064365386963e-10f) * 2.0f) + -1.0f));
      _476 = cb0_013y + (cb0_090z * (((float((uint)_451) * 2.3283064365386963e-10f) * 2.0f) + -1.0f));
      _477 = cb0_013z + (cb0_090z * (((float((uint)((_451 * _449) + _446)) * 2.3283064365386963e-10f) * 2.0f) + -1.0f));
    }
    _484 = (((_48 + _475) / VolumetricFog_016.x) * 2.0f) + -1.0f;
    _486 = -0.0f - ((((_49 + _476) / VolumetricFog_016.y) * 2.0f) + -1.0f);
    _492 = (exp2(max((_62 + _477), 0.0f) / VolumetricFog_064.z) - VolumetricFog_064.y) / VolumetricFog_064.x;
    [branch]
    if (_75) {
      _507 = (1.0f / ((_492 + asfloat(cb1_raw[78u].w)) * asfloat(cb1_raw[78u].z)));
    } else {
      _507 = ((_492 * asfloat(cb1_raw[30u].z)) + asfloat(cb1_raw[31u].z));
    }
    _523 = mad(1.0f, cb0_008w, mad(_507, cb0_007w, mad(_486, cb0_006w, (_484 * cb0_005w))));
    _524 = mad(1.0f, cb0_008x, mad(_507, cb0_007x, mad(_486, cb0_006x, (_484 * cb0_005x)))) / _523;
    _525 = mad(1.0f, cb0_008y, mad(_507, cb0_007y, mad(_486, cb0_006y, (_484 * cb0_005y)))) / _523;
    _526 = mad(1.0f, cb0_008z, mad(_507, cb0_007z, mad(_486, cb0_006z, (_484 * cb0_005z)))) / _523;
    _530 = _524 - (asfloat(cb1_raw[84u].x) + asfloat(cb1_raw[85u].x));
    _531 = _525 - (asfloat(cb1_raw[84u].y) + asfloat(cb1_raw[85u].y));
    _532 = _526 - (asfloat(cb1_raw[84u].z) + asfloat(cb1_raw[85u].z));
    _541 = _524 - asfloat(cb1_raw[81u].x);
    _542 = _525 - asfloat(cb1_raw[81u].y);
    _543 = _526 - asfloat(cb1_raw[81u].z);
    _545 = rsqrt(dot(float3(_541, _542, _543), float3(_541, _542, _543)));
    _549 = (asfloat(cb1_raw[31u].w) >= 1.0f);
    _550 = select(_549, asfloat(cb1_raw[73u].x), (_545 * _541));
    _551 = select(_549, asfloat(cb1_raw[73u].y), (_545 * _542));
    _552 = select(_549, asfloat(cb1_raw[73u].z), (_545 * _543));
    _561 = asfloat(cb3_raw[7u].w) * asfloat(cb3_raw[7u].x);
    _562 = asfloat(cb3_raw[7u].w) * asfloat(cb3_raw[7u].y);
    _563 = asfloat(cb3_raw[7u].w) * asfloat(cb3_raw[7u].z);
    [branch]
    if (asint(cb3_raw[0u].w) == 0) {
      _1805 = cb0_090x;
      _1806 = 0.0f;
      _1807 = 0.0f;
      _1808 = 0.0f;
    } else {
      if (cb0_091y > 0.0f) {
        if (!(asint(cb3_raw[9u].z) == 0)) {
          _594 = ((((int)(uint)((int)(_492 >= asfloat(cb3_raw[10u].x)))) + ((int)(uint)((int)(_492 >= asfloat(cb3_raw[10u].y))))) + ((int)(uint)((int)(_492 >= asfloat(cb3_raw[10u].z))))) + ((int)(uint)((int)(_492 >= asfloat(cb3_raw[10u].w))));
          if ((uint)_594 < (uint)asint(cb3_raw[9u].z)) {
            _597 = _594 << 2;
            _599 = asfloat(cb3_raw[((int)(_597 + 11))]);
            _604 = asfloat(cb3_raw[((int)(_597 + 12))]);
            _609 = asfloat(cb3_raw[((int)(_597 + 13))]);
            _614 = asfloat(cb3_raw[((int)(_597 + 14))]);
            _629 = mad(_526, _609.w, mad(_525, _604.w, (_599.w * _524))) + _614.w;
            _630 = (mad(_526, _609.x, mad(_525, _604.x, (_599.x * _524))) + _614.x) / _629;
            _631 = (mad(_526, _609.y, mad(_525, _604.y, (_599.y * _524))) + _614.y) / _629;
            _633 = asfloat(cb3_raw[((int)(_594 + 27))]);
            if (((_630 >= _633.x) && (_630 <= _633.z)) && ((_631 >= _633.y) && (_631 <= _633.w))) {
              _665 = float((bool)(uint)(((1.0f - _614.z) - mad(_526, _609.z, mad(_525, _604.z, (_599.z * _524)))) < ((((float4)(t2.SampleLevel(s1, float2(_630, _631), 0.0f))).x) - asfloat(cb3_raw[32u].x))));
            } else {
              _665 = 1.0f;
            }
          } else {
            _665 = 1.0f;
          }
        } else {
          _665 = 1.0f;
        }
        _668 = ((int)(asint(cb3_raw[9u].w) * 288)) | 16;
        _672 = asint(t8.Load(((int)(_668 + 188u))));
        _674 = _668 + 192u;
        _675 = _668 + 208u;
        if (_672 == 0) {
          _678 = asint(t8.Load3(_674)).x;
          _679 = asint(t8.Load3(_674)).y;
          _680 = asint(t8.Load3(_674)).z;
          _685 = asint(t8.Load3(_675)).x;
          _686 = asint(t8.Load3(_675)).y;
          _687 = asint(t8.Load3(_675)).z;
          _693 = asint(t8.Load(((int)(_668 + 220u))));
          _697 = asint(t8.Load3(((int)(_668 + 224u)))).x;
          _698 = asint(t8.Load3(((int)(_668 + 224u)))).y;
          _699 = asint(t8.Load3(((int)(_668 + 224u)))).z;
          _705 = asint(t8.Load(((int)(_668 + 248u))));
          if (!(_705 == -1)) {
            _712 = (((uint)(_705) >> 16) + -1024);
            _713 = (_705 & 65535);
          } else {
            _712 = 1024;
            _713 = -1;
          }
          _726 = _524 + (asfloat(_697) + ((asfloat(_678) - asfloat(cb1_raw[84u].x)) + (asfloat(_685) - asfloat(cb1_raw[85u].x))));
          _727 = _525 + (asfloat(_698) + ((asfloat(_679) - asfloat(cb1_raw[84u].y)) + (asfloat(_686) - asfloat(cb1_raw[85u].y))));
          _728 = _526 + (asfloat(_699) + ((asfloat(_680) - asfloat(cb1_raw[84u].z)) + (asfloat(_687) - asfloat(cb1_raw[85u].z))));
          _740 = max((int)(0), (int)((int(floor(asfloat(_693) + log2(sqrt((_728 * _728) + ((_726 * _726) + (_727 * _727)))))) - _712)));
          if ((int)_740 < (int)_713) {
            _743 = _740 + asint(cb3_raw[9u].w);
            _745 = ((int)(_743 * 288)) | 16;
            _748 = asint(t8.Load4(((int)(_745 + 48u)))).x;
            _749 = asint(t8.Load4(((int)(_745 + 48u)))).y;
            _750 = asint(t8.Load4(((int)(_745 + 48u)))).z;
            _756 = asint(t8.Load4(((int)(_745 + 64u)))).x;
            _757 = asint(t8.Load4(((int)(_745 + 64u)))).y;
            _758 = asint(t8.Load4(((int)(_745 + 64u)))).z;
            _764 = asint(t8.Load4(((int)(_745 + 80u)))).x;
            _765 = asint(t8.Load4(((int)(_745 + 80u)))).y;
            _766 = asint(t8.Load4(((int)(_745 + 80u)))).z;
            _772 = asint(t8.Load4(((int)(_745 + 96u)))).x;
            _773 = asint(t8.Load4(((int)(_745 + 96u)))).y;
            _774 = asint(t8.Load4(((int)(_745 + 96u)))).z;
            _780 = asint(t8.Load3(((int)(_745 + 192u)))).x;
            _781 = asint(t8.Load3(((int)(_745 + 192u)))).y;
            _782 = asint(t8.Load3(((int)(_745 + 192u)))).z;
            _788 = asint(t8.Load3(((int)(_745 + 208u)))).x;
            _789 = asint(t8.Load3(((int)(_745 + 208u)))).y;
            _790 = asint(t8.Load3(((int)(_745 + 208u)))).z;
            _803 = ((asfloat(_780) - asfloat(cb1_raw[84u].x)) + (asfloat(_788) - asfloat(cb1_raw[85u].x))) + _524;
            _804 = ((asfloat(_781) - asfloat(cb1_raw[84u].y)) + (asfloat(_789) - asfloat(cb1_raw[85u].y))) + _525;
            _805 = ((asfloat(_782) - asfloat(cb1_raw[84u].z)) + (asfloat(_790) - asfloat(cb1_raw[85u].z))) + _526;
            _809 = mad(_805, asfloat(_764), mad(_804, asfloat(_756), (_803 * asfloat(_748)))) + asfloat(_772);
            _813 = mad(_805, asfloat(_765), mad(_804, asfloat(_757), (_803 * asfloat(_749)))) + asfloat(_773);
            _820 = uint(_809 * 128.0f);
            _821 = uint(_813 * 128.0f);
            _822 = ((int)_743 < (int)8192);
            if (_822) {
              _837 = (_743 & 127);
              _838 = ((uint)(_743) >> 7);
            } else {
              _827 = _743 + (uint)(-8191);
              _837 = ((int)((VirtualShadowMap_084 & _827) << 7));
              _838 = ((int)(((uint)(_827) >> (VirtualShadowMap_080 & 31)) * 192));
            }
            _844 = t9.Load(int3(((int)(_837 + (uint)(select(_822, 0, _820)))), ((int)(_838 + (uint)(select(_822, 0, _821)))), 0));
            _846 = (uint)((uint)(_844.x)) >> 20;
            _847 = _846 & 63;
            if ((int)_844.x < (int)0) {
              _850 = (_847 == 0);
              _852 = _847 + _743;
              if (!_850) {
                _860 = asint(t8.Load2(((int)(_745 + 240u)))).x;
                _861 = asint(t8.Load2(((int)(_745 + 240u)))).y;
                _863 = ((int)(_852 * 288)) | 16;
                _866 = asint(t8.Load2(((int)(_863 + 240u)))).x;
                _867 = asint(t8.Load2(((int)(_863 + 240u)))).y;
                _874 = _846 & 31;
                _879 = (uint)((_820 - (_860 << 5)) + (((int)(_866 << 5)) << _874)) >> _874;
                _880 = (uint)((_821 - (_861 << 5)) + (((int)(_867 << 5)) << _874)) >> _874;
                _881 = _879 << 7;
                _882 = _880 << 7;
                _887 = asint(t8.Load4(((int)(_745 + 32u)))).z;
                _891 = asint(t8.Load4(((int)(_863 + 32u)))).z;
                _899 = 1.0f / float((uint)(1 << _874));
                _920 = ((int)_852 < (int)8192);
                if (_920) {
                  _935 = (_852 & 127);
                  _936 = ((uint)(_852) >> 7);
                } else {
                  _925 = _852 + (uint)(-8191);
                  _935 = ((int)((VirtualShadowMap_084 & _925) << 7));
                  _936 = ((int)(((uint)(_925) >> (VirtualShadowMap_080 & 31)) * 192));
                }
                _941 = t9.Load(int3(((int)(_935 + (uint)(select(_920, 0, _879)))), ((int)(_936 + (uint)(select(_920, 0, _880)))), 0));
                _947 = _941.x;
                _948 = ((int)(uint)((int)((_941.x & -2081423360) == -2147483648)));
                _949 = ((int)min((uint)(((int)max((uint)((int)(uint((((float((int)(_866)) - (_899 * float((int)(_860)))) * 0.25f) + (_899 * _809)) * 16384.0f))), (uint)(_881)))), (uint)((_881 | 127))));
                _950 = ((int)min((uint)(((int)max((uint)((int)(uint((((float((int)(_867)) - (_899 * float((int)(_861)))) * 0.25f) + (_899 * _813)) * 16384.0f))), (uint)(_882)))), (uint)((_882 | 127))));
                _951 = _899;
                _952 = (asfloat(_891) - (_899 * asfloat(_887)));
              } else {
                _947 = _844.x;
                _948 = ((int)(uint)(_850));
                _949 = (int)(uint(_809 * 16384.0f));
                _950 = (int)(uint(_813 * 16384.0f));
                _951 = 1.0f;
                _952 = 0.0f;
              }
              if (!(_948 == 0)) {
                _970 = ((asfloat((((uint)(t10.Load(int4(((_949 & 127) | (((int)(_947 << 7)) & 130944)), ((_950 & 127) | (((uint)(_947) >> 3) & 130944)), 0, 0)))).x)) - _952) / _951);
                _971 = true;
              } else {
                _970 = 0.0f;
                _971 = false;
              }
            } else {
              _970 = 0.0f;
              _971 = false;
            }
            _1207 = select((_971 && (_970 > (mad(_805, asfloat(_766), mad(_804, asfloat(_758), (_803 * asfloat(_750)))) + asfloat(_774)))), 0.0f, 1.0f);
          } else {
            _1207 = 1.0f;
          }
        } else {
          _978 = asint(t8.Load4(((int)(_668 + 48u)))).x;
          _979 = asint(t8.Load4(((int)(_668 + 48u)))).y;
          _980 = asint(t8.Load4(((int)(_668 + 48u)))).z;
          _981 = asint(t8.Load4(((int)(_668 + 48u)))).w;
          _984 = asint(t8.Load4(((int)(_668 + 64u)))).x;
          _985 = asint(t8.Load4(((int)(_668 + 64u)))).y;
          _986 = asint(t8.Load4(((int)(_668 + 64u)))).z;
          _987 = asint(t8.Load4(((int)(_668 + 64u)))).w;
          _990 = asint(t8.Load4(((int)(_668 + 80u)))).x;
          _991 = asint(t8.Load4(((int)(_668 + 80u)))).y;
          _992 = asint(t8.Load4(((int)(_668 + 80u)))).z;
          _993 = asint(t8.Load4(((int)(_668 + 80u)))).w;
          _996 = asint(t8.Load4(((int)(_668 + 96u)))).x;
          _997 = asint(t8.Load4(((int)(_668 + 96u)))).y;
          _998 = asint(t8.Load4(((int)(_668 + 96u)))).z;
          _999 = asint(t8.Load4(((int)(_668 + 96u)))).w;
          _1001 = asint(t8.Load3(_674)).x;
          _1002 = asint(t8.Load3(_674)).y;
          _1003 = asint(t8.Load3(_674)).z;
          _1008 = asint(t8.Load3(_675)).x;
          _1009 = asint(t8.Load3(_675)).y;
          _1010 = asint(t8.Load3(_675)).z;
          _1016 = asint(t8.Load(((int)(_668 + 268u))));
          _1026 = ((asfloat(_1001) - asfloat(cb1_raw[84u].x)) + (asfloat(_1008) - asfloat(cb1_raw[85u].x))) + _524;
          _1027 = ((asfloat(_1002) - asfloat(cb1_raw[84u].y)) + (asfloat(_1009) - asfloat(cb1_raw[85u].y))) + _525;
          _1028 = ((asfloat(_1003) - asfloat(cb1_raw[84u].z)) + (asfloat(_1010) - asfloat(cb1_raw[85u].z))) + _526;
          if (!(_672 == 2)) {
            _1031 = abs(_1026);
            _1032 = abs(_1027);
            _1034 = abs(_1028);
            if ((_1031 < _1032) || (_1031 < _1034)) {
              if (_1032 > _1034) {
                _1049 = select((_1027 > 0.0f), 2, 3);
              } else {
                _1049 = select((_1028 > 0.0f), 4, 5);
              }
            } else {
              _1049 = ((int)(uint)((int)(!(_1026 > 0.0f))));
            }
            _1050 = _1049 + (uint)(asint(cb3_raw[9u].w));
            _1052 = ((int)(_1050 * 288)) | 16;
            _1055 = asint(t8.Load4(((int)(_1052 + 48u)))).x;
            _1056 = asint(t8.Load4(((int)(_1052 + 48u)))).y;
            _1057 = asint(t8.Load4(((int)(_1052 + 48u)))).z;
            _1058 = asint(t8.Load4(((int)(_1052 + 48u)))).w;
            _1061 = asint(t8.Load4(((int)(_1052 + 64u)))).x;
            _1062 = asint(t8.Load4(((int)(_1052 + 64u)))).y;
            _1063 = asint(t8.Load4(((int)(_1052 + 64u)))).z;
            _1064 = asint(t8.Load4(((int)(_1052 + 64u)))).w;
            _1067 = asint(t8.Load4(((int)(_1052 + 80u)))).x;
            _1068 = asint(t8.Load4(((int)(_1052 + 80u)))).y;
            _1069 = asint(t8.Load4(((int)(_1052 + 80u)))).z;
            _1070 = asint(t8.Load4(((int)(_1052 + 80u)))).w;
            _1073 = asint(t8.Load4(((int)(_1052 + 96u)))).x;
            _1074 = asint(t8.Load4(((int)(_1052 + 96u)))).y;
            _1075 = asint(t8.Load4(((int)(_1052 + 96u)))).z;
            _1076 = asint(t8.Load4(((int)(_1052 + 96u)))).w;
            _1079 = asint(t8.Load(((int)(_1052 + 268u))));
            _1081 = _1055;
            _1082 = _1056;
            _1083 = _1057;
            _1084 = _1058;
            _1085 = _1061;
            _1086 = _1062;
            _1087 = _1063;
            _1088 = _1064;
            _1089 = _1067;
            _1090 = _1068;
            _1091 = _1069;
            _1092 = _1070;
            _1093 = _1073;
            _1094 = _1074;
            _1095 = _1075;
            _1096 = _1076;
            _1097 = _1079;
            _1098 = _1050;
          } else {
            _1081 = _978;
            _1082 = _979;
            _1083 = _980;
            _1084 = _981;
            _1085 = _984;
            _1086 = _985;
            _1087 = _986;
            _1088 = _987;
            _1089 = _990;
            _1090 = _991;
            _1091 = _992;
            _1092 = _993;
            _1093 = _996;
            _1094 = _997;
            _1095 = _998;
            _1096 = _999;
            _1097 = _1016;
            _1098 = asint(cb3_raw[9u].w);
          }
          _1130 = mad(_1028, asfloat(_1092), mad(_1027, asfloat(_1088), (asfloat(_1084) * _1026))) + asfloat(_1096);
          _1131 = (mad(_1028, asfloat(_1089), mad(_1027, asfloat(_1085), (asfloat(_1081) * _1026))) + asfloat(_1093)) / _1130;
          _1132 = (mad(_1028, asfloat(_1090), mad(_1027, asfloat(_1086), (asfloat(_1082) * _1026))) + asfloat(_1094)) / _1130;
          _1138 = _1097 & 31;
          _1141 = ((int)_1098 < (int)8192);
          if (_1141) {
            _1167 = (_1098 & 127);
            _1168 = ((uint)(_1098) >> 7);
          } else {
            _1146 = _1098 + (uint)(-8191);
            if (!(_1097 == 0)) {
              _1162 = (((int)(127 << (((int)(8u - _1097)) & 31))) & 127);
              _1163 = 128;
            } else {
              _1162 = 0;
              _1163 = 0;
            }
            _1167 = (_1162 | ((int)((VirtualShadowMap_084 & _1146) << 7)));
            _1168 = ((int)(_1163 + (((uint)(_1146) >> (VirtualShadowMap_080 & 31)) * 192)));
          }
          _1174 = t9.Load(int3(((int)(_1167 + (uint)(select(_1141, 0, ((uint)(uint(_1131 * 128.0f)) >> _1138))))), ((int)(_1168 + (uint)(select(_1141, 0, ((uint)(uint(_1132 * 128.0f)) >> _1138))))), 0));
          _1182 = select(_1141, 128.0f, float((uint)((uint)((uint)(16384u) >> (((int)(((uint)((uint)((uint)(_1174.x)) >> 20)) + _1097)) & 31)))));
          if ((int)_1174.x < (int)0) {
            _1201 = asfloat((((uint)(t10.Load(int4((((int)(uint(_1182 * _1131)) & 127) | (((int)(_1174.x << 7)) & 130944)), (((int)(uint(_1182 * _1132)) & 127) | (((uint)((uint)(_1174.x)) >> 3) & 130944)), 0, 0)))).x));
            _1202 = true;
          } else {
            _1201 = 0.0f;
            _1202 = false;
          }
          _1207 = select((_1202 && (_1201 > ((mad(_1028, asfloat(_1091), mad(_1027, asfloat(_1087), (asfloat(_1083) * _1026))) + asfloat(_1095)) / _1130))), 0.0f, 1.0f);
        }
        _1208 = _1207 * _665;
        if (cb0_091x > 0.0f) {
          _1248 = mad(_526, cb0_084w, mad(_525, cb0_083w, (cb0_082w * _524))) + cb0_085w;
          _1258 = t12.SampleLevel(s2, float2(((((mad(_526, cb0_084x, mad(_525, cb0_083x, (cb0_082x * _524))) + cb0_085x) / _1248) * 0.5f) + 0.5f), (0.5f - (((mad(_526, cb0_084y, mad(_525, cb0_083y, (cb0_082y * _524))) + cb0_085y) / _1248) * 0.5f))), 0.0f);
          _1278 = ((((saturate(exp2(min(_1258.z, ((_1258.y * 1000.0f) * max(0.0f, ((saturate(1.0f - ((mad(_526, cb0_084z, mad(_525, cb0_083z, (cb0_082z * _524))) + cb0_085z) / _1248)) * cb0_090w) - _1258.x)))) * -1.4426950216293335f)) + -1.0f) * cb0_091x) + 1.0f) * _1208);
        } else {
          _1278 = _1208;
        }
      } else {
        _1278 = 1.0f;
      }
      if (cb0_093x == 0) {
        _1469 = t21.SampleLevel(s5, float2((((mad(_526, cb0_080x, mad(_525, cb0_079x, (cb0_078x * _524))) + cb0_081x) * 0.5f) + 0.5f), (0.5f - ((mad(_526, cb0_080y, mad(_525, cb0_079y, (cb0_078y * _524))) + cb0_081y) * 0.5f))), 0.0f);
        _1474 = _1469.x;
        _1475 = _1469.y;
        _1476 = _1469.z;
      } else {
        if (!(cb0_093y == 0)) {
          _1286 = cb0_093y * 5;
          _1289 = t1[_1286].x;
          _1290 = t1[_1286].y;
          _1291 = t1[_1286].z;
          _1292 = t1[_1286].w;
          _1293 = asint(_1290);
          _1294 = asint(_1291);
          _1298 = f16tof32(((uint)(((uint)(_1293) >> 8) & 65535)));
          _1307 = t1[((int)(_1286 + 1u))].x;
          _1308 = t1[((int)(_1286 + 1u))].y;
          _1309 = t1[((int)(_1286 + 1u))].z;
          _1310 = t1[((int)(_1286 + 1u))].w;
          _1313 = t1[((int)(_1286 + 2u))].x;
          _1314 = t1[((int)(_1286 + 2u))].y;
          _1315 = t1[((int)(_1286 + 2u))].z;
          _1316 = t1[((int)(_1286 + 2u))].w;
          _1319 = t1[((int)(_1286 + 3u))].x;
          _1320 = t1[((int)(_1286 + 3u))].y;
          _1321 = t1[((int)(_1286 + 3u))].z;
          _1322 = t1[((int)(_1286 + 3u))].w;
          _1325 = t1[((int)(_1286 + 4u))].x;
          _1326 = t1[((int)(_1286 + 4u))].y;
          _1327 = t1[((int)(_1286 + 4u))].z;
          _1328 = t1[((int)(_1286 + 4u))].w;
          _1344 = mad(_526, _1322, mad(_525, _1316, (_1310 * _524))) + _1328;
          _1345 = (mad(_526, _1321, mad(_525, _1315, (_1309 * _524))) + _1327) / _1344;
          _1346 = (mad(_526, _1320, mad(_525, _1314, (_1308 * _524))) + _1326) / _1344;
          _1347 = (mad(_526, _1319, mad(_525, _1313, (_1307 * _524))) + _1325) / _1344;
          switch (((int)(_1293 & 255))) {
            case 2: {
              _1349 = _1347 * _1292;
              _1393 = (((_1345 / _1349) * 0.5f) + 0.5f);
              _1394 = (((_1346 / _1349) * 0.5f) + 0.5f);
              break;
            }
            case 1: {
              _1358 = rsqrt(dot(float3(_1345, _1346, _1347), float3(_1345, _1346, _1347)));
              _1359 = _1358 * _1345;
              _1360 = _1358 * _1346;
              _1363 = atan(_1360 / _1359);
              _1366 = (_1359 < 0.0f);
              _1367 = (_1359 == 0.0f);
              _1368 = (_1360 >= 0.0f);
              _1369 = (_1360 < 0.0f);
              _1393 = select((_1367 && _1368), 0.75f, select((_1367 && _1369), 0.25f, ((select((_1366 && _1369), (_1363 + -3.1415927410125732f), select((_1366 && _1368), (_1363 + 3.1415927410125732f), _1363)) + 3.1415927410125732f) * 0.15915493667125702f)));
              _1394 = (acos(_1358 * _1347) * 0.31830987334251404f);
              break;
            }
            case 3: {
              if (_1292 > 0.0f) {
                _1385 = _1347 * _1292;
                _1393 = (((_1345 / _1385) * 0.5f) + 0.5f);
                _1394 = (((_1346 / _1385) * 0.5f) + 0.5f);
              } else {
                _1393 = _1345;
                _1394 = _1346;
              }
              break;
            }
            default: {
              _1393 = _1345;
              _1394 = _1346;
              break;
            }
          }
          _1407 = t0.SampleLevel(s0, float2(((LightFunctionAtlas_024 * saturate(frac(_1393))) + (float((uint)((uint)(_1294 & 65535))) * 1.52587890625e-05f)), ((LightFunctionAtlas_024 * saturate(frac(_1394))) + (float((uint)((uint)((uint)(_1294) >> 16))) * 1.52587890625e-05f))), 0.0f);
          _1414 = asfloat(cb1_raw[81u].x) - _524;
          _1415 = asfloat(cb1_raw[81u].y) - _525;
          _1416 = asfloat(cb1_raw[81u].z) - _526;
          _1422 = sqrt(((_1414 * _1414) + (_1415 * _1415)) + (_1416 * _1416));
          if (!_75) {
            _1428 = ((_1422 / dot(float3(_1414, _1415, _1416), float3(asfloat(cb1_raw[73u].x), asfloat(cb1_raw[73u].y), asfloat(cb1_raw[73u].z)))) * _1422);
          } else {
            _1428 = _1422;
          }
          _1432 = saturate((_1289 - _1428) / (_1289 * 0.20000000298023224f));
          _1474 = ((_1432 * ((_1407.x * _1407.x) - _1298)) + _1298);
          _1475 = ((_1432 * ((_1407.y * _1407.y) - _1298)) + _1298);
          _1476 = ((_1432 * ((_1407.z * _1407.z) - _1298)) + _1298);
        } else {
          _1474 = 1.0f;
          _1475 = 1.0f;
          _1476 = 1.0f;
        }
      }
      _1477 = _524 + asfloat(cb1_raw[84u].x);
      _1478 = _525 + asfloat(cb1_raw[84u].y);
      _1479 = _526 + asfloat(cb1_raw[84u].z);
      _1480 = _1477 - _524;
      _1481 = _1478 - _525;
      _1482 = _1479 - _526;
      _1495 = _371 + ((asfloat(cb1_raw[84u].x) - _1480) + (_524 - (_1477 - _1480)));
      _1496 = _372 + ((asfloat(cb1_raw[84u].y) - _1481) + (_525 - (_1478 - _1481)));
      _1497 = _373 + ((asfloat(cb1_raw[84u].z) - _1482) + (_526 - (_1479 - _1482)));
      _1498 = _1477 + _1495;
      _1499 = _1478 + _1496;
      _1500 = _1479 + _1497;
      _1507 = ((asfloat(cb1_raw[85u].x) - _371) + (0.0f - (_371 - _371))) + (_1495 - (_1498 - _1477));
      _1508 = ((asfloat(cb1_raw[85u].y) - _372) + (0.0f - (_372 - _372))) + (_1496 - (_1499 - _1478));
      _1509 = ((asfloat(cb1_raw[85u].z) - _373) + (0.0f - (_373 - _373))) + (_1497 - (_1500 - _1479));
      _1510 = _1498 + _1507;
      _1511 = _1499 + _1508;
      _1512 = _1500 + _1509;
      _1519 = (_1507 - (_1510 - _1498)) + _1510;
      _1520 = (_1508 - (_1511 - _1499)) + _1511;
      _1521 = (_1509 - (_1512 - _1500)) + _1512;
      _1533 = mad(_1521, asfloat(cb1_raw[351u].w), mad(_1520, asfloat(cb1_raw[350u].w), (_1519 * asfloat(cb1_raw[349u].w)))) + asfloat(cb1_raw[352u].w);
      if ((abs((mad(_1521, asfloat(cb1_raw[351u].x), mad(_1520, asfloat(cb1_raw[350u].x), (_1519 * asfloat(cb1_raw[349u].x)))) + asfloat(cb1_raw[352u].x)) / _1533) <= asfloat(cb1_raw[365u].x)) && (abs((mad(_1521, asfloat(cb1_raw[351u].y), mad(_1520, asfloat(cb1_raw[350u].y), (_1519 * asfloat(cb1_raw[349u].y)))) + asfloat(cb1_raw[352u].y)) / _1533) <= asfloat(cb1_raw[365u].y))) {
        _1546 = (asfloat(cb1_raw[369u].x) > -3.4028234663852886e+38f);
      } else {
        _1546 = false;
      }
      if (!_1546) {
        _1575 = mad(_1521, asfloat(cb1_raw[355u].w), mad(_1520, asfloat(cb1_raw[354u].w), (asfloat(cb1_raw[353u].w) * _1519))) + asfloat(cb1_raw[356u].w);
        if ((abs((mad(_1521, asfloat(cb1_raw[355u].x), mad(_1520, asfloat(cb1_raw[354u].x), (asfloat(cb1_raw[353u].x) * _1519))) + asfloat(cb1_raw[356u].x)) / _1575) <= asfloat(cb1_raw[366u].x)) && (abs((mad(_1521, asfloat(cb1_raw[355u].y), mad(_1520, asfloat(cb1_raw[354u].y), (asfloat(cb1_raw[353u].y) * _1519))) + asfloat(cb1_raw[356u].y)) / _1575) <= asfloat(cb1_raw[366u].y))) {
          _1591 = (asfloat(cb1_raw[370u].x) > -3.4028234663852886e+38f);
          _1592 = 1;
        } else {
          _1591 = false;
          _1592 = 0;
        }
        if (!_1591) {
          _1621 = mad(_1521, asfloat(cb1_raw[359u].w), mad(_1520, asfloat(cb1_raw[358u].w), (asfloat(cb1_raw[357u].w) * _1519))) + asfloat(cb1_raw[360u].w);
          if ((abs((mad(_1521, asfloat(cb1_raw[359u].x), mad(_1520, asfloat(cb1_raw[358u].x), (asfloat(cb1_raw[357u].x) * _1519))) + asfloat(cb1_raw[360u].x)) / _1621) <= asfloat(cb1_raw[367u].x)) && (abs((mad(_1521, asfloat(cb1_raw[359u].y), mad(_1520, asfloat(cb1_raw[358u].y), (asfloat(cb1_raw[357u].y) * _1519))) + asfloat(cb1_raw[360u].y)) / _1621) <= asfloat(cb1_raw[367u].y))) {
            _1637 = (asfloat(cb1_raw[371u].x) > -3.4028234663852886e+38f);
            _1638 = 2;
          } else {
            _1637 = false;
            _1638 = 0;
          }
          if (!_1637) {
            _1667 = mad(_1521, asfloat(cb1_raw[363u].w), mad(_1520, asfloat(cb1_raw[362u].w), (asfloat(cb1_raw[361u].w) * _1519))) + asfloat(cb1_raw[364u].w);
            if ((abs((mad(_1521, asfloat(cb1_raw[363u].x), mad(_1520, asfloat(cb1_raw[362u].x), (asfloat(cb1_raw[361u].x) * _1519))) + asfloat(cb1_raw[364u].x)) / _1667) <= asfloat(cb1_raw[368u].x)) && (abs((mad(_1521, asfloat(cb1_raw[363u].y), mad(_1520, asfloat(cb1_raw[362u].y), (asfloat(cb1_raw[361u].y) * _1519))) + asfloat(cb1_raw[364u].y)) / _1667) <= asfloat(cb1_raw[368u].y))) {
              _1684 = select((asfloat(cb1_raw[372u].x) > -3.4028234663852886e+38f), 3, -1);
            } else {
              _1684 = -1;
            }
          } else {
            _1684 = _1638;
          }
        } else {
          _1684 = _1592;
        }
      } else {
        _1684 = 0;
      }
      _1686 = select((_1684 == -1), 0, _1684);
      _1690 = asfloat(cb1_raw[((int)(_1686 + 533))]);
      _1692 = (_1690.w < ((_526 - asfloat(cb1_raw[84u].z)) - asfloat(cb1_raw[85u].z)));
      _1697 = asfloat(cb1_raw[((int)(_1686 + 541))]);
      _1703 = asfloat(cb1_raw[((int)(_1686 + 543))]);
      _1707 = asfloat(cb1_raw[((int)(_1686 + 535))]);
      _1712 = asfloat(cb1_raw[((int)(_1686 + 539))]);
      _1720 = max(asfloat(cb3_raw[5u].z), 9.99999993922529e-09f);
      _1726 = max(((((((-0.0f - _526) - _1703.y) + asfloat(cb1_raw[84u].z)) + asfloat(cb1_raw[85u].z)) + _1690.w) / (lerp(_1720, 1.0f, _1712.w))), 0.0f) * -0.009999999776482582f;
      _1738 = exp2(((_1707.x * 1.4426950216293335f) * _1726) * asfloat(cb1_raw[347u].x));
      _1739 = exp2(((_1707.y * 1.4426950216293335f) * _1726) * asfloat(cb1_raw[347u].x));
      _1740 = exp2(((_1707.z * 1.4426950216293335f) * _1726) * asfloat(cb1_raw[347u].x));
      _1751 = (saturate(sqrt(((_525 * _525) + (_524 * _524)) + (_526 * _526)) * _1703.x) * (_1703.w - _1697.w)) + _1697.w;
      if (cb0_088z > 0.0f) {
        _1769 = dot(float3(_561, _562, _563), float3(0.2126390039920807f, 0.7151686549186707f, 0.07219231873750687f));
        _1774 = (VolumetricFog_112.x * _1769);
        _1775 = (VolumetricFog_112.y * _1769);
        _1776 = (VolumetricFog_112.z * _1769);
      } else {
        _1774 = _561;
        _1775 = _562;
        _1776 = _563;
      }
      _1787 = (((dot(float3(asfloat(cb3_raw[5u].x), asfloat(cb3_raw[5u].y), asfloat(cb3_raw[5u].z)), float3((-0.0f - _550), (-0.0f - _551), (-0.0f - _552))) * 2.0f) + cb0_090x) * cb0_090x) + 1.0f;
      _1791 = (1.0f - (cb0_090x * cb0_090x)) / ((sqrt(_1787) * 12.566370964050293f) * _1787);
      _1805 = cb0_090x;
      _1806 = ((((select(_1692, 1.0f, _1474) * _1278) * ((_1751 * (_1697.x - _1738)) + _1738)) * _1774) * _1791);
      _1807 = ((((select(_1692, 1.0f, _1475) * _1278) * ((_1751 * (_1697.y - _1739)) + _1739)) * _1775) * _1791);
      _1808 = ((((select(_1692, 1.0f, _1476) * _1278) * ((_1751 * (_1697.z - _1740)) + _1740)) * _1776) * _1791);
    }
    _1809 = _1805 * _551;
    _1810 = _1805 * _552;
    _1811 = _1805 * _550;
    _1835 = _530 - asfloat(cb1_raw[72u].x);
    _1836 = _531 - asfloat(cb1_raw[72u].y);
    _1837 = _532 - asfloat(cb1_raw[72u].z);
    _1838 = _1835 - _530;
    _1839 = _1836 - _531;
    _1840 = _1837 - _532;
    _1853 = (((-0.0f - asfloat(cb1_raw[72u].x)) - _1838) + (_530 - (_1835 - _1838))) + _1835;
    _1854 = (((-0.0f - asfloat(cb1_raw[72u].y)) - _1839) + (_531 - (_1836 - _1839))) + _1836;
    _1855 = (((-0.0f - asfloat(cb1_raw[72u].z)) - _1840) + (_532 - (_1837 - _1840))) + _1837;
    _1867 = asfloat(cb1_raw[7u].w) + mad(_1855, asfloat(cb1_raw[6u].w), mad(_1854, asfloat(cb1_raw[5u].w), (_1853 * asfloat(cb1_raw[4u].w))));
    _1881 = (LumenGIVolumeStruct_480.z * log2((LumenGIVolumeStruct_480.x * _1867) + LumenGIVolumeStruct_480.y)) / float((int)(LumenGIVolumeStruct_496.z));
    _1884 = (((asfloat(cb1_raw[7u].x) + mad(_1855, asfloat(cb1_raw[6u].x), mad(_1854, asfloat(cb1_raw[5u].x), (_1853 * asfloat(cb1_raw[4u].x))))) / _1867) * 0.5f) + 0.5f;
    _1885 = 0.5f - (((asfloat(cb1_raw[7u].y) + mad(_1855, asfloat(cb1_raw[6u].y), mad(_1854, asfloat(cb1_raw[5u].y), (_1853 * asfloat(cb1_raw[4u].y))))) / _1867) * 0.5f);
    _1888 = t6.SampleLevel(s0, float3(_1884, _1885, _1881), 0.0f);
    _1893 = t7.SampleLevel(s0, float3(_1884, _1885, _1881), 0.0f);
    _1898 = dot(float3(_1888.x, _1888.y, _1888.z), float3(0.2126390039920807f, 0.7151686549186707f, 0.07219231873750687f)) + 9.999999747378752e-06f;
    _1899 = _1888.x / _1898;
    _1900 = _1888.y / _1898;
    _1901 = _1888.z / _1898;
    _1917 = max(dot(float4(_1888.x, (_1899 * _1893.x), (_1899 * _1893.y), (_1899 * _1893.z)), float4(1.0f, _1809, _1810, _1811)), 0.0f) + _1806;
    _1918 = max(dot(float4(_1888.y, (_1900 * _1893.x), (_1900 * _1893.y), (_1900 * _1893.z)), float4(1.0f, _1809, _1810, _1811)), 0.0f) + _1807;
    _1919 = max(dot(float4(_1888.z, (_1901 * _1893.x), (_1901 * _1893.y), (_1901 * _1893.z)), float4(1.0f, _1809, _1810, _1811)), 0.0f) + _1808;
    _1941 = asint(cb3_raw[3u].x) & 31;
    _1950 = ((int)((((int)((asint(cb3_raw[2u].y) * ((int)min((uint)((int)(uint(max(0.0f, (log2((asfloat(cb3_raw[4u].x) * _492) + asfloat(cb3_raw[4u].y)) * asfloat(cb3_raw[4u].z)))))), (uint)((asint(cb3_raw[2u].z) + -1))))) + ((uint)((uint)(VolumetricFog_128.y * (int)(SV_DispatchThreadID.y)) >> _1941)))) * asint(cb3_raw[2u].x)) + ((uint)((uint)(VolumetricFog_128.x * (int)(SV_DispatchThreadID.x)) >> _1941)))) << 1;
    _1953 = t4[_1950];
    _1956 = (int)min((uint)((_1953 & 65535)), (uint)(asint(cb3_raw[0u].x)));
    _1959 = t4[(_1950 | 1)];
    _1972 = (((_475 + float((uint)(SV_DispatchThreadID.x + 1u))) / VolumetricFog_016.x) * 2.0f) + -1.0f;
    _1974 = -0.0f - ((((_476 + float((uint)(SV_DispatchThreadID.y + 1u))) / VolumetricFog_016.y) * 2.0f) + -1.0f);
    _1981 = (exp2(max((_477 + float((uint)(SV_DispatchThreadID.z + 1u))), 0.0f) / VolumetricFog_064.z) - VolumetricFog_064.y) / VolumetricFog_064.x;
    [branch]
    if (_75) {
      _1996 = (1.0f / ((asfloat(cb1_raw[78u].w) + _1981) * asfloat(cb1_raw[78u].z)));
    } else {
      _1996 = ((asfloat(cb1_raw[30u].z) * _1981) + asfloat(cb1_raw[31u].z));
    }
    _2012 = mad(_1996, cb0_007w, mad(_1974, cb0_006w, (cb0_005w * _1972))) + cb0_008w;
    _2016 = _524 - ((mad(_1996, cb0_007x, mad(_1974, cb0_006x, (cb0_005x * _1972))) + cb0_008x) / _2012);
    _2017 = _525 - ((mad(_1996, cb0_007y, mad(_1974, cb0_006y, (cb0_005y * _1972))) + cb0_008y) / _2012);
    _2018 = _526 - ((mad(_1996, cb0_007z, mad(_1974, cb0_006z, (cb0_005z * _1972))) + cb0_008z) / _2012);
    _2027 = max((cb0_090y * sqrt(((_2017 * _2017) + (_2016 * _2016)) + (_2018 * _2018))), 1.0f);
    _2028 = _2027 * _2027;
    if (!(_1956 == 0)) {
      _2032 = _1917;
      _2033 = _1918;
      _2034 = _1919;
      _2035 = 0;
      while(true) {
        _2622 = _2032;
        _2623 = _2033;
        _2624 = _2034;
        _2040 = (((uint)(t5.Load((int)(_2035 + ((uint)(_1959 & 1073741823)))))).x) * 6;
        _2044 = t3[((int)(_2040 + 4u))].x;
        _2045 = t3[((int)(_2040 + 4u))].y;
        _2046 = t3[((int)(_2040 + 4u))].z;
        _2049 = t3[((int)(_2040 + 3u))].x;
        _2050 = t3[((int)(_2040 + 3u))].y;
        _2051 = t3[((int)(_2040 + 3u))].w;
        _2054 = t3[((int)(_2040 + 2u))].x;
        _2055 = t3[((int)(_2040 + 2u))].y;
        _2056 = t3[((int)(_2040 + 2u))].z;
        _2059 = t3[(_2040 | 1)].x;
        _2060 = t3[(_2040 | 1)].w;
        _2062 = t3[_2040].w;
        _2063 = asint(_2051);
        _2065 = f16tof32(((uint)((uint)(_2063) >> 16)));
        if (_2065 > 0.0f) {
          _2068 = t3[(_2040 | 1)].y;
          _2069 = t3[((int)(_2040 + 2u))].w;
          _2070 = t3[_2040].z;
          _2071 = t3[_2040].y;
          _2072 = t3[_2040].x;
          _2073 = t3[((int)(_2040 + 3u))].z;
          _2076 = t3[((int)(_2040 + 5u))].z;
          _2077 = asint(_2069);
          _2079 = ((uint)(_2077) >> 16) & 3;
          _2080 = asint(_2068);
          _2094 = f16tof32(((uint)(asint(_2073) & 65535)));
          _2095 = -0.0f - _2094;
          _2096 = f16tof32(_2063);
          _2097 = -0.0f - _2096;
          _2099 = (_2079 == 3);
          _2100 = asint(_2076);
          _2102 = f16tof32(((uint)(_2100 & 65535)));
          _2106 = float((uint)((uint)(((uint)(_2100) >> 16) & 1023))) * 0.0009775171056389809f;
          _2108 = ((uint)(_2077) >> 20) & 255;
          _2109 = (_2060 == 0.0f);
          _2110 = _2072 - _524;
          _2111 = _2071 - _525;
          _2112 = _2070 - _526;
          _2113 = dot(float3(_2110, _2111, _2112), float3(_2110, _2111, _2112));
          _2114 = rsqrt(_2113);
          _2115 = _2114 * _2110;
          _2116 = _2114 * _2111;
          _2117 = _2114 * _2112;
          if (_2109) {
            _2120 = (_2062 * _2062) * _2113;
            _2123 = saturate(1.0f - (_2120 * _2120));
            _2136 = (_2123 * _2123);
          } else {
            _2126 = _2110 * _2062;
            _2127 = _2111 * _2062;
            _2128 = _2112 * _2062;
            _2136 = exp2(log2(1.0f - saturate(dot(float3(_2126, _2127, _2128), float3(_2126, _2127, _2128)))) * _2060);
          }
          if (_2079 == 2) {
            _2141 = saturate((dot(float3(_2115, _2116, _2117), float3(_2054, _2055, _2056)) - _2049) * _2050);
            _2145 = ((_2141 * _2141) * _2136);
          } else {
            _2145 = _2136;
          }
          if (_2099) {
            _2151 = select((dot(float3(_2054, _2055, _2056), float3(_2115, _2116, _2117)) < 0.0f), 0.0f, _2145);
          } else {
            _2151 = _2145;
          }
          if (_2099) {
            _2155 = (_2056 * _2045) - (_2055 * _2046);
            _2158 = (_2054 * _2046) - (_2056 * _2044);
            _2161 = (_2055 * _2044) - (_2054 * _2045);
            if (_2106 > 0.03500000014901161f) {
              _2166 = mad(_2161, _2112, mad(_2158, _2111, (_2110 * _2155)));
              _2169 = mad(_2046, _2112, mad(_2045, _2111, (_2110 * _2044)));
              _2172 = mad(_2056, _2112, mad(_2055, _2111, (_2110 * _2054)));
              _2176 = _2106 * _2102;
              _2177 = min(_2172, _2176);
              _2181 = (sqrt(1.0f - (_2106 * _2106)) * _2102) * (_2177 / max(9.999999747378752e-05f, _2176));
              _2192 = float((int)(((int)(uint)((int)(_2166 > 0.0f))) - ((int)(uint)((int)(_2166 < 0.0f)))));
              _2193 = float((int)(((int)(uint)((int)(_2169 > 0.0f))) - ((int)(uint)((int)(_2169 < 0.0f)))));
              _2207 = max((_2172 - _2177), 0.0010000000474974513f);
              _2214 = ((abs(((_2095 - _2181) + max(abs(_2166), (_2181 + _2094))) * _2192) / _2207) * _2177) - _2181;
              _2215 = ((abs(((_2097 - _2181) + max(abs(_2169), (_2181 + _2096))) * _2193) / _2207) * _2177) - _2181;
              _2226 = min(max(((_2214 * max(0.0f, (-0.0f - _2192))) - _2094), _2095), _2094);
              _2227 = min(max(((_2215 * max(0.0f, (-0.0f - _2193))) - _2096), _2097), _2096);
              _2236 = min(max((_2094 - (max(0.0f, _2192) * _2214)), _2095), _2094);
              _2237 = min(max((_2096 - (max(0.0f, _2193) * _2215)), _2097), _2096);
              _2240 = (_2236 + _2226) * 0.5f;
              _2241 = (_2237 + _2227) * 0.5f;
              _2259 = ((_2110 - (_2240 * _2155)) - (_2241 * _2044));
              _2260 = ((_2111 - (_2240 * _2158)) - (_2241 * _2045));
              _2261 = ((_2112 - (_2240 * _2161)) - (_2241 * _2046));
              _2262 = ((_2236 - _2226) * 0.5f);
              _2263 = ((_2237 - _2227) * 0.5f);
            } else {
              _2259 = _2110;
              _2260 = _2111;
              _2261 = _2112;
              _2262 = _2094;
              _2263 = _2096;
            }
            if (!((_2262 == 0.0f) || (_2263 == 0.0f))) {
              _2268 = dot(float3(_2155, _2158, _2161), float3(_2259, _2260, _2261));
              _2269 = dot(float3(_2044, _2045, _2046), float3(_2259, _2260, _2261));
              _2270 = dot(float3(_2054, _2055, _2056), float3(_2259, _2260, _2261));
              _2271 = _2268 - _2262;
              _2272 = _2268 + _2262;
              _2273 = _2269 - _2263;
              _2274 = _2269 + _2263;
              _2275 = _2270 * _2270;
              _2278 = rsqrt(dot(float2(_2271, _2273), float2(_2271, _2273)) + _2275);
              _2279 = _2278 * _2271;
              _2280 = _2278 * _2273;
              _2281 = _2278 * _2270;
              _2284 = rsqrt(dot(float2(_2272, _2273), float2(_2272, _2273)) + _2275);
              _2285 = _2284 * _2272;
              _2286 = _2284 * _2273;
              _2287 = _2284 * _2270;
              _2290 = rsqrt(dot(float2(_2272, _2274), float2(_2272, _2274)) + _2275);
              _2291 = _2290 * _2272;
              _2292 = _2290 * _2274;
              _2293 = _2290 * _2270;
              _2296 = rsqrt(dot(float2(_2271, _2274), float2(_2271, _2274)) + _2275);
              _2297 = _2296 * _2271;
              _2298 = _2296 * _2274;
              _2299 = _2296 * _2270;
              _2300 = dot(float3(_2279, _2280, _2281), float3(_2285, _2286, _2287));
              _2301 = dot(float3(_2285, _2286, _2287), float3(_2291, _2292, _2293));
              _2302 = dot(float3(_2291, _2292, _2293), float3(_2297, _2298, _2299));
              _2303 = dot(float3(_2297, _2298, _2299), float3(_2279, _2280, _2281));
              _2314 = rsqrt(max((_2301 + 1.0f), 9.999999747378752e-05f)) * (1.5707999467849731f - (_2301 * 0.17499999701976776f));
              _2325 = rsqrt(max((_2303 + 1.0f), 9.999999747378752e-05f)) * (1.5707999467849731f - (_2303 * 0.17499999701976776f));
              _2327 = -0.0f - ((1.5707999467849731f - (_2300 * 0.17499999701976776f)) * rsqrt(max((_2300 + 1.0f), 9.999999747378752e-05f)));
              _2334 = (_2314 * _2291) + (_2279 * _2327);
              _2335 = (_2314 * _2292) + (_2280 * _2327);
              _2336 = (_2314 * _2293) + (_2281 * _2327);
              _2350 = -0.0f - ((1.5707999467849731f - (_2302 * 0.17499999701976776f)) * rsqrt(max((_2302 + 1.0f), 9.999999747378752e-05f)));
              _2354 = (_2325 * _2279) + (_2291 * _2350);
              _2355 = (_2325 * _2280) + (_2292 * _2350);
              _2356 = (_2325 * _2281) + (_2293 * _2350);
              _2366 = ((_2356 * _2298) - (_2355 * _2299)) + ((_2336 * _2286) - (_2335 * _2287));
              _2367 = ((_2354 * _2299) - (_2356 * _2297)) + ((_2334 * _2287) - (_2336 * _2285));
              _2368 = ((_2355 * _2297) - (_2354 * _2298)) + ((_2335 * _2285) - (_2334 * _2286));
              _2381 = ((_2366 * _2155) + (_2367 * _2044)) + (_2368 * _2054);
              _2382 = ((_2366 * _2158) + (_2367 * _2045)) + (_2368 * _2055);
              _2383 = ((_2366 * _2161) + (_2367 * _2046)) + (_2368 * _2056);
              _2384 = dot(float3(_2381, _2382, _2383), float3(_2381, _2382, _2383));
              _2419 = ((_2384 * 0.5f) * rsqrt(_2384));
            } else {
              _2419 = 0.0f;
            }
          } else {
            _2389 = _2096 * 0.5f;
            _2390 = _2389 * _2044;
            _2391 = _2389 * _2045;
            _2392 = _2389 * _2046;
            _2393 = _2110 - _2390;
            _2394 = _2111 - _2391;
            _2395 = _2112 - _2392;
            _2396 = _2390 + _2110;
            _2397 = _2391 + _2111;
            _2398 = _2392 + _2112;
            _2400 = dot(float3(_2393, _2394, _2395), float3(_2393, _2394, _2395));
            [branch]
            if (_2096 > 0.0f) {
              _2405 = rsqrt(dot(float3(_2396, _2397, _2398), float3(_2396, _2397, _2398))) * rsqrt(_2400);
              _2416 = (_2405 / ((((dot(float3(_2393, _2394, _2395), float3(_2396, _2397, _2398)) * 0.5f) + _2028) * _2405) + 0.5f));
            } else {
              _2416 = (1.0f / (_2400 + _2028));
            }
            _2419 = select(_2109, _2416, 1.0f);
          }
          if (!(_2108 == 0)) {
            _2422 = _2108 * 5;
            _2425 = t1[_2422].x;
            _2426 = t1[_2422].y;
            _2427 = t1[_2422].z;
            _2428 = t1[_2422].w;
            _2429 = asint(_2426);
            _2430 = asint(_2427);
            _2434 = f16tof32(((uint)(((uint)(_2429) >> 8) & 65535)));
            _2443 = t1[(_2422 + 1)].x;
            _2444 = t1[(_2422 + 1)].y;
            _2445 = t1[(_2422 + 1)].z;
            _2446 = t1[(_2422 + 1)].w;
            _2449 = t1[(_2422 + 2)].x;
            _2450 = t1[(_2422 + 2)].y;
            _2451 = t1[(_2422 + 2)].z;
            _2452 = t1[(_2422 + 2)].w;
            _2455 = t1[(_2422 + 3)].x;
            _2456 = t1[(_2422 + 3)].y;
            _2457 = t1[(_2422 + 3)].z;
            _2458 = t1[(_2422 + 3)].w;
            _2461 = t1[(_2422 + 4)].x;
            _2462 = t1[(_2422 + 4)].y;
            _2463 = t1[(_2422 + 4)].z;
            _2464 = t1[(_2422 + 4)].w;
            _2480 = mad(_526, _2458, mad(_525, _2452, (_2446 * _524))) + _2464;
            _2481 = (mad(_526, _2457, mad(_525, _2451, (_2445 * _524))) + _2463) / _2480;
            _2482 = (mad(_526, _2456, mad(_525, _2450, (_2444 * _524))) + _2462) / _2480;
            _2483 = (mad(_526, _2455, mad(_525, _2449, (_2443 * _524))) + _2461) / _2480;
            switch (((int)(_2429 & 255))) {
              case 2: {
                _2485 = _2483 * _2428;
                _2529 = (((_2481 / _2485) * 0.5f) + 0.5f);
                _2530 = (((_2482 / _2485) * 0.5f) + 0.5f);
                break;
              }
              case 1: {
                _2494 = rsqrt(dot(float3(_2481, _2482, _2483), float3(_2481, _2482, _2483)));
                _2495 = _2494 * _2481;
                _2496 = _2494 * _2482;
                _2499 = atan(_2496 / _2495);
                _2502 = (_2495 < 0.0f);
                _2503 = (_2495 == 0.0f);
                _2504 = (_2496 >= 0.0f);
                _2505 = (_2496 < 0.0f);
                _2529 = select((_2503 && _2504), 0.75f, select((_2503 && _2505), 0.25f, ((select((_2502 && _2505), (_2499 + -3.1415927410125732f), select((_2502 && _2504), (_2499 + 3.1415927410125732f), _2499)) + 3.1415927410125732f) * 0.15915493667125702f)));
                _2530 = (acos(_2494 * _2483) * 0.31830987334251404f);
                break;
              }
              case 3: {
                if (_2428 > 0.0f) {
                  _2521 = _2483 * _2428;
                  _2529 = (((_2481 / _2521) * 0.5f) + 0.5f);
                  _2530 = (((_2482 / _2521) * 0.5f) + 0.5f);
                } else {
                  _2529 = _2481;
                  _2530 = _2482;
                }
                break;
              }
              default: {
                _2529 = _2481;
                _2530 = _2482;
                break;
              }
            }
            _2543 = t0.SampleLevel(s0, float2(((LightFunctionAtlas_024 * saturate(frac(_2529))) + (float((uint)((uint)(_2430 & 65535))) * 1.52587890625e-05f)), ((LightFunctionAtlas_024 * saturate(frac(_2530))) + (float((uint)((uint)((uint)(_2430) >> 16))) * 1.52587890625e-05f))), 0.0f);
            _2554 = asfloat(cb1_raw[81u].x) - _524;
            _2555 = asfloat(cb1_raw[81u].y) - _525;
            _2556 = asfloat(cb1_raw[81u].z) - _526;
            _2562 = sqrt(((_2554 * _2554) + (_2555 * _2555)) + (_2556 * _2556));
            if (!(asfloat(cb1_raw[31u].w) < 1.0f)) {
              _2575 = ((_2562 / dot(float3(_2554, _2555, _2556), float3(asfloat(cb1_raw[73u].x), asfloat(cb1_raw[73u].y), asfloat(cb1_raw[73u].z)))) * _2562);
            } else {
              _2575 = _2562;
            }
            _2579 = saturate((_2425 - _2575) / (_2425 * 0.20000000298023224f));
            _2590 = ((_2579 * ((_2543.x * _2543.x) - _2434)) + _2434);
            _2591 = ((_2579 * ((_2543.y * _2543.y) - _2434)) + _2434);
            _2592 = ((_2579 * ((_2543.z * _2543.z) - _2434)) + _2434);
          } else {
            _2590 = 1.0f;
            _2591 = 1.0f;
            _2592 = 1.0f;
          }
          _2607 = (((dot(float3(_2115, _2116, _2117), float3((-0.0f - _550), (-0.0f - _551), (-0.0f - _552))) * 2.0f) + cb0_090x) * cb0_090x) + 1.0f;
          _2614 = ((_2151 * _2065) * _2419) * ((1.0f - (cb0_090x * cb0_090x)) / ((sqrt(_2607) * 12.566370964050293f) * _2607));
          _2622 = ((((float((uint)((uint)(_2080 & 1023))) * _2059) * _2590) * _2614) + _2032);
          _2623 = ((((float((uint)((uint)(((uint)(_2080) >> 10) & 1023))) * _2059) * _2591) * _2614) + _2033);
          _2624 = ((((float((uint)((uint)(((uint)(_2080) >> 20) & 1023))) * _2059) * _2592) * _2614) + _2034);
        } else {
          _2622 = _2032;
          _2623 = _2033;
          _2624 = _2034;
        }
        _2625 = _2035 + 1u;
        if (!(_2625 == _1956)) {
          _2032 = _2622;
          _2033 = _2623;
          _2034 = _2624;
          _2035 = _2625;
          continue;
        }
        _2629 = _2622;
        _2630 = _2623;
        _2631 = _2624;
        break;
      }
    } else {
      _2629 = _1917;
      _2630 = _1918;
      _2631 = _1919;
    }
    _2635 = t20.Load(int4((int)(SV_DispatchThreadID.x), (int)(SV_DispatchThreadID.y), (int)(SV_DispatchThreadID.z), 0));
    _2646 = t15.Load(int4((int)(SV_DispatchThreadID.x), (int)(SV_DispatchThreadID.y), (int)(SV_DispatchThreadID.z), 0));
    _2651 = t16.Load(int4((int)(SV_DispatchThreadID.x), (int)(SV_DispatchThreadID.y), (int)(SV_DispatchThreadID.z), 0));
    [branch]
    if (!(cb0_092z == 0)) {
      _2659 = t17.Load(int4((int)(SV_DispatchThreadID.x), (int)(SV_DispatchThreadID.y), (int)(SV_DispatchThreadID.z), 0));
      _2664 = _2659.x;
      _2665 = _2659.y;
      _2666 = _2659.z;
    } else {
      _2664 = 0.0f;
      _2665 = 0.0f;
      _2666 = 0.0f;
    }
    _2674 = asfloat(cb1_raw[156u].z) * (_2664 + (_2646.x * ((_2635.x * asfloat(cb1_raw[156u].w)) + _2629)));
    _2675 = asfloat(cb1_raw[156u].z) * (_2665 + (_2646.y * ((_2635.y * asfloat(cb1_raw[156u].w)) + _2630)));
    _2676 = asfloat(cb1_raw[156u].z) * (_2666 + (_2646.z * ((_2635.z * asfloat(cb1_raw[156u].w)) + _2631)));
    [branch]
    if (_421 > 0.0f) {
      _2695 = min(_357, asfloat(cb1_raw[255u].z));
      _2696 = min(_358, asfloat(cb1_raw[255u].w));
      _2697 = min(_191, 1.0f);
      // Tricubic history filter + neighborhood clamping for inscatter
      {
        float3 _hist_uvw = float3(_2695, _2696, _2697);
        float3 _fog_tex_size = float3(VolumetricFog_000);
        float3 _fog_uv_max = float3(asfloat(cb1_raw[255u].z), asfloat(cb1_raw[255u].w), 1.0);
        float3 _hist_rgb = SampleFogHistory3(t18, s3, _hist_uvw, _fog_tex_size, InjectionFogFilterMode(), _fog_uv_max);
        // Neighborhood clamping: 6 face-neighbors + center
        float3 _voxel_step = 1.0 / _fog_tex_size;
        float3 _n_xp = t18.SampleLevel(s3, _hist_uvw + float3(_voxel_step.x, 0, 0), 0).rgb;
        float3 _n_xn = t18.SampleLevel(s3, _hist_uvw - float3(_voxel_step.x, 0, 0), 0).rgb;
        float3 _n_yp = t18.SampleLevel(s3, _hist_uvw + float3(0, _voxel_step.y, 0), 0).rgb;
        float3 _n_yn = t18.SampleLevel(s3, _hist_uvw - float3(0, _voxel_step.y, 0), 0).rgb;
        float3 _n_zp = t18.SampleLevel(s3, _hist_uvw + float3(0, 0, _voxel_step.z), 0).rgb;
        float3 _n_zn = t18.SampleLevel(s3, _hist_uvw - float3(0, 0, _voxel_step.z), 0).rgb;
        float3 _bilinear_c = t18.SampleLevel(s3, _hist_uvw, 0).rgb;
        float3 _nhood_min = min(min(min(_n_xp, _n_xn), min(_n_yp, _n_yn)), min(min(_n_zp, _n_zn), _bilinear_c));
        float3 _nhood_max = max(max(max(_n_xp, _n_xn), max(_n_yp, _n_yn)), max(max(_n_zp, _n_zn), _bilinear_c));
        _hist_rgb = clamp(_hist_rgb, _nhood_min, _nhood_max);
        _2700 = float4(_hist_rgb, t18.SampleLevel(s3, _hist_uvw, 0).w);
      }
      _2706 = asfloat(cb1_raw[156u].z) * cb0_089y;
      _2707 = _2706 * _2700.x;
      _2708 = _2706 * _2700.y;
      _2709 = _2706 * _2700.z;
      _2723 = (log2(_2707 + 9.99999993922529e-09f) - log2(_2674 + 9.99999993922529e-09f)) * 0.6931471824645996f;
      _2725 = (log2(_2708 + 9.99999993922529e-09f) - log2(_2675 + 9.99999993922529e-09f)) * 0.6931471824645996f;
      _2727 = (log2(_2709 + 9.99999993922529e-09f) - log2(_2676 + 9.99999993922529e-09f)) * 0.6931471824645996f;
      _2739 = (1.0f - saturate(cb0_092x * sqrt(((_2725 * _2725) + (_2723 * _2723)) + (_2727 * _2727)))) * (((_421 - cb0_091z) * (1.0f - saturate(1.0f / (cb0_091w * max(((t11.Load(int3((int)(SV_DispatchThreadID.x), (int)(SV_DispatchThreadID.y), 0))).x), 0.003921568859368563f))))) + cb0_091z);
      _2742 = t19.SampleLevel(s4, float3(_2695, _2696, _2697), 0.0f);
      _2765 = ((_2739 * (_2707 - _2674)) + _2674);
      _2766 = ((_2739 * (_2708 - _2675)) + _2675);
      _2767 = ((_2739 * (_2709 - _2676)) + _2676);
      _2768 = (lerp(_2651.x, _2742.x, _2739));
      _2769 = (lerp(_2651.y, _2742.y, _2739));
      _2770 = (lerp(_2651.z, _2742.z, _2739));
    } else {
      _2765 = _2674;
      _2766 = _2675;
      _2767 = _2676;
      _2768 = _2651.x;
      _2769 = _2651.y;
      _2770 = _2651.z;
    }
    if (((int)(int)(SV_DispatchThreadID.z) < (int)VolumetricFog_000.z) && (((int)(int)(SV_DispatchThreadID.x) < (int)VolumetricFog_000.x) && ((int)(int)(SV_DispatchThreadID.y) < (int)VolumetricFog_000.y))) {
      u0[int3((int)(SV_DispatchThreadID.x), (int)(SV_DispatchThreadID.y), (int)(SV_DispatchThreadID.z))] = float3(select(((uint)asint(_2765) < (uint)2139095040), _2765, 0.0f), select(((uint)asint(_2766) < (uint)2139095040), _2766, 0.0f), select(((uint)asint(_2767) < (uint)2139095040), _2767, 0.0f));
      u1[int3((int)(SV_DispatchThreadID.x), (int)(SV_DispatchThreadID.y), (int)(SV_DispatchThreadID.z))] = float3(select(((uint)asint(_2768) < (uint)2139095040), _2768, 0.0f), select(((uint)asint(_2769) < (uint)2139095040), _2769, 0.0f), select(((uint)asint(_2770) < (uint)2139095040), _2770, 0.0f));
    }
  } else {
    _201 = (exp2(max((_62 + -0.5f), 0.0f) / VolumetricFog_064.z) - VolumetricFog_064.y) / VolumetricFog_064.x;
    [branch]
    if (_75) {
      _216 = (1.0f / ((_201 + asfloat(cb1_raw[78u].w)) * asfloat(cb1_raw[78u].z)));
    } else {
      _216 = ((_201 * asfloat(cb1_raw[30u].z)) + asfloat(cb1_raw[31u].z));
    }
    _224 = mad(1.0f, cb0_008w, mad(_216, cb0_007w, _124));
    _225 = mad(1.0f, cb0_008x, mad(_216, cb0_007x, _112)) / _224;
    _226 = mad(1.0f, cb0_008y, mad(_216, cb0_007y, _116)) / _224;
    _227 = mad(1.0f, cb0_008z, mad(_216, cb0_007z, _120)) / _224;
    if (((t13.Load(int3((int)(SV_DispatchThreadID.x), (int)(SV_DispatchThreadID.y), 0))).x) > (mad(1.0f, asfloat(cb1_raw[3u].z), mad(_227, asfloat(cb1_raw[2u].z), mad(_226, asfloat(cb1_raw[1u].z), (_225 * asfloat(cb1_raw[0u].z))))) / mad(1.0f, asfloat(cb1_raw[3u].w), mad(_227, asfloat(cb1_raw[2u].w), mad(_226, asfloat(cb1_raw[1u].w), (_225 * asfloat(cb1_raw[0u].w))))))) {
      u0[int3((int)(SV_DispatchThreadID.x), (int)(SV_DispatchThreadID.y), (int)(SV_DispatchThreadID.z))] = float3(0.0f, 0.0f, 0.0f);
      u1[int3((int)(SV_DispatchThreadID.x), (int)(SV_DispatchThreadID.y), (int)(SV_DispatchThreadID.z))] = float3(0.0f, 0.0f, 0.0f);
    } else {
      _269 = mad(1.0f, cb0_012z, mad(_227, cb0_011z, mad(_226, cb0_010z, (_225 * cb0_009z)))) / mad(1.0f, cb0_012w, mad(_227, cb0_011w, mad(_226, cb0_010w, (_225 * cb0_009w))));
      _273 = _189 * asfloat(cb1_raw[257u].x);
      _274 = _190 * asfloat(cb1_raw[257u].y);
      _281 = float((uint)uint(floor(_273 + -0.5f)));
      _282 = float((uint)uint(floor(_274 + -0.5f)));
      _287 = _273 - _281;
      _288 = _274 - _282;
      _293 = t14.GatherRed(s3, float2((((_281 + 1.0f) / asfloat(cb1_raw[257u].x)) / _185), (((_282 + 1.0f) / asfloat(cb1_raw[257u].y)) / _186)));
      _298 = (_293.x < _269);
      _299 = (_293.y < _269);
      _300 = (_293.z < _269);
      _301 = (_293.w < _269);
      _302 = _298 && _299;
      if (!(_301 && (_300 && _302))) {
        if (_301 && _300) {
          _357 = ((_281 + _287) / asfloat(cb1_raw[257u].x));
          _358 = ((_282 + 0.5f) / asfloat(cb1_raw[257u].y));
          _359 = 1;
        } else {
          if (_302) {
            _357 = ((_281 + _287) / asfloat(cb1_raw[257u].x));
            _358 = ((_282 + 1.5f) / asfloat(cb1_raw[257u].y));
            _359 = 1;
          } else {
            if (_301 && _298) {
              _357 = ((_281 + 0.5f) / asfloat(cb1_raw[257u].x));
              _358 = ((_282 + _288) / asfloat(cb1_raw[257u].y));
              _359 = 1;
            } else {
              if (_300 && _299) {
                _357 = ((_281 + 1.5f) / asfloat(cb1_raw[257u].x));
                _358 = ((_282 + _288) / asfloat(cb1_raw[257u].y));
                _359 = 1;
              } else {
                if (_298) {
                  _357 = ((_281 + 0.5f) / asfloat(cb1_raw[257u].x));
                  _358 = ((_282 + 1.5f) / asfloat(cb1_raw[257u].y));
                  _359 = 1;
                } else {
                  if (_299) {
                    _357 = ((_281 + 1.5f) / asfloat(cb1_raw[257u].x));
                    _358 = ((_282 + 1.5f) / asfloat(cb1_raw[257u].y));
                    _359 = 1;
                  } else {
                    if (_301) {
                      _357 = ((_281 + 0.5f) / asfloat(cb1_raw[257u].x));
                      _358 = ((_282 + 0.5f) / asfloat(cb1_raw[257u].y));
                      _359 = 1;
                    } else {
                      if (_300) {
                        _357 = ((_281 + 1.5f) / asfloat(cb1_raw[257u].x));
                        _358 = ((_282 + 0.5f) / asfloat(cb1_raw[257u].y));
                        _359 = 1;
                      } else {
                        _357 = _189;
                        _358 = _190;
                        _359 = 0;
                      }
                    }
                  }
                }
              }
            }
          }
        }
      } else {
        _357 = _189;
        _358 = _190;
        _359 = 1;
      }
      _371 = asfloat(cb1_raw[85u].x) + 0.0f;
      _372 = asfloat(cb1_raw[85u].y) + 0.0f;
      _373 = asfloat(cb1_raw[85u].z) + 0.0f;
      if (((_191 < 0.0f) || ((_357 < 0.0f) || (_358 < 0.0f))) | !((_359 != 0) && (!((_191 >= 1.0f) || ((_357 >= asfloat(cb1_raw[256u].x)) || (_358 >= asfloat(cb1_raw[256u].y))))))) {
        _421 = 0.0f;
      } else {
        _421 = cb0_029x;
      }
      _429 = ((int)(SV_DispatchThreadID.y) * 1664525) + 1013904223u;
      _430 = ((int)(SV_DispatchThreadID.z) * 1664525) + 1013904223u;
      _431 = (asint(cb1_raw[165u].z) * 1664525) + 1013904223u;
      _433 = (((int)(SV_DispatchThreadID.x) * 1664525) + 1013904223u) + (_431 * _429);
      _435 = (_433 * _430) + _429;
      _437 = (_435 * _433) + _430;
      _439 = (_437 * _435) + _431;
      _445 = ((uint)(_435) >> 16) ^ _435;
      _446 = ((uint)(_437) >> 16) ^ _437;
      _449 = ((((uint)(_439) >> 16) ^ _439) * _445) + ((uint)(((uint)(_433) >> 16) ^ _433));
      _451 = (_449 * _446) + _445;
      if (InjectionToggle(TOGGLE_USE_ISFAST_FOG)) {
        uint _fast_slice2 = InjectionFrameIndex();
        float2 _fast_n2 = FastNoiseLoad(
            SV_DispatchThreadID.x % 128u,
            SV_DispatchThreadID.y % 128u,
            _fast_slice2);
        float _fast_z_n2 = FastNoiseLoad(
            SV_DispatchThreadID.z % 128u,
            (SV_DispatchThreadID.x ^ SV_DispatchThreadID.y) % 128u,
            (_fast_slice2 + 16u) % 32u).x;
        _475 = cb0_013x + (cb0_090z * ((_fast_n2.x * 2.0f) - 1.0f));
        _476 = cb0_013y + (cb0_090z * ((_fast_n2.y * 2.0f) - 1.0f));
        _477 = cb0_013z + (cb0_090z * ((_fast_z_n2 * 2.0f) - 1.0f));
      } else {
        _475 = cb0_013x + (cb0_090z * (((float((uint)_449) * 2.3283064365386963e-10f) * 2.0f) + -1.0f));
        _476 = cb0_013y + (cb0_090z * (((float((uint)_451) * 2.3283064365386963e-10f) * 2.0f) + -1.0f));
        _477 = cb0_013z + (cb0_090z * (((float((uint)((_451 * _449) + _446)) * 2.3283064365386963e-10f) * 2.0f) + -1.0f));
      }
      _484 = (((_48 + _475) / VolumetricFog_016.x) * 2.0f) + -1.0f;
      _486 = -0.0f - ((((_49 + _476) / VolumetricFog_016.y) * 2.0f) + -1.0f);
      _492 = (exp2(max((_62 + _477), 0.0f) / VolumetricFog_064.z) - VolumetricFog_064.y) / VolumetricFog_064.x;
      [branch]
      if (_75) {
        _507 = (1.0f / ((_492 + asfloat(cb1_raw[78u].w)) * asfloat(cb1_raw[78u].z)));
      } else {
        _507 = ((_492 * asfloat(cb1_raw[30u].z)) + asfloat(cb1_raw[31u].z));
      }
      _523 = mad(1.0f, cb0_008w, mad(_507, cb0_007w, mad(_486, cb0_006w, (_484 * cb0_005w))));
      _524 = mad(1.0f, cb0_008x, mad(_507, cb0_007x, mad(_486, cb0_006x, (_484 * cb0_005x)))) / _523;
      _525 = mad(1.0f, cb0_008y, mad(_507, cb0_007y, mad(_486, cb0_006y, (_484 * cb0_005y)))) / _523;
      _526 = mad(1.0f, cb0_008z, mad(_507, cb0_007z, mad(_486, cb0_006z, (_484 * cb0_005z)))) / _523;
      _530 = _524 - (asfloat(cb1_raw[84u].x) + asfloat(cb1_raw[85u].x));
      _531 = _525 - (asfloat(cb1_raw[84u].y) + asfloat(cb1_raw[85u].y));
      _532 = _526 - (asfloat(cb1_raw[84u].z) + asfloat(cb1_raw[85u].z));
      _541 = _524 - asfloat(cb1_raw[81u].x);
      _542 = _525 - asfloat(cb1_raw[81u].y);
      _543 = _526 - asfloat(cb1_raw[81u].z);
      _545 = rsqrt(dot(float3(_541, _542, _543), float3(_541, _542, _543)));
      _549 = (asfloat(cb1_raw[31u].w) >= 1.0f);
      _550 = select(_549, asfloat(cb1_raw[73u].x), (_545 * _541));
      _551 = select(_549, asfloat(cb1_raw[73u].y), (_545 * _542));
      _552 = select(_549, asfloat(cb1_raw[73u].z), (_545 * _543));
      _561 = asfloat(cb3_raw[7u].w) * asfloat(cb3_raw[7u].x);
      _562 = asfloat(cb3_raw[7u].w) * asfloat(cb3_raw[7u].y);
      _563 = asfloat(cb3_raw[7u].w) * asfloat(cb3_raw[7u].z);
      [branch]
      if (asint(cb3_raw[0u].w) == 0) {
        _1805 = cb0_090x;
        _1806 = 0.0f;
        _1807 = 0.0f;
        _1808 = 0.0f;
      } else {
        if (cb0_091y > 0.0f) {
          if (!(asint(cb3_raw[9u].z) == 0)) {
            _594 = ((((int)(uint)((int)(_492 >= asfloat(cb3_raw[10u].x)))) + ((int)(uint)((int)(_492 >= asfloat(cb3_raw[10u].y))))) + ((int)(uint)((int)(_492 >= asfloat(cb3_raw[10u].z))))) + ((int)(uint)((int)(_492 >= asfloat(cb3_raw[10u].w))));
            if ((uint)_594 < (uint)asint(cb3_raw[9u].z)) {
              _597 = _594 << 2;
              _599 = asfloat(cb3_raw[((int)(_597 + 11))]);
              _604 = asfloat(cb3_raw[((int)(_597 + 12))]);
              _609 = asfloat(cb3_raw[((int)(_597 + 13))]);
              _614 = asfloat(cb3_raw[((int)(_597 + 14))]);
              _629 = mad(_526, _609.w, mad(_525, _604.w, (_599.w * _524))) + _614.w;
              _630 = (mad(_526, _609.x, mad(_525, _604.x, (_599.x * _524))) + _614.x) / _629;
              _631 = (mad(_526, _609.y, mad(_525, _604.y, (_599.y * _524))) + _614.y) / _629;
              _633 = asfloat(cb3_raw[((int)(_594 + 27))]);
              if (((_630 >= _633.x) && (_630 <= _633.z)) && ((_631 >= _633.y) && (_631 <= _633.w))) {
                _665 = float((bool)(uint)(((1.0f - _614.z) - mad(_526, _609.z, mad(_525, _604.z, (_599.z * _524)))) < ((((float4)(t2.SampleLevel(s1, float2(_630, _631), 0.0f))).x) - asfloat(cb3_raw[32u].x))));
              } else {
                _665 = 1.0f;
              }
            } else {
              _665 = 1.0f;
            }
          } else {
            _665 = 1.0f;
          }
          _668 = ((int)(asint(cb3_raw[9u].w) * 288)) | 16;
          _672 = asint(t8.Load(((int)(_668 + 188u))));
          _674 = _668 + 192u;
          _675 = _668 + 208u;
          if (_672 == 0) {
            _678 = asint(t8.Load3(_674)).x;
            _679 = asint(t8.Load3(_674)).y;
            _680 = asint(t8.Load3(_674)).z;
            _685 = asint(t8.Load3(_675)).x;
            _686 = asint(t8.Load3(_675)).y;
            _687 = asint(t8.Load3(_675)).z;
            _693 = asint(t8.Load(((int)(_668 + 220u))));
            _697 = asint(t8.Load3(((int)(_668 + 224u)))).x;
            _698 = asint(t8.Load3(((int)(_668 + 224u)))).y;
            _699 = asint(t8.Load3(((int)(_668 + 224u)))).z;
            _705 = asint(t8.Load(((int)(_668 + 248u))));
            if (!(_705 == -1)) {
              _712 = (((uint)(_705) >> 16) + -1024);
              _713 = (_705 & 65535);
            } else {
              _712 = 1024;
              _713 = -1;
            }
            _726 = _524 + (asfloat(_697) + ((asfloat(_678) - asfloat(cb1_raw[84u].x)) + (asfloat(_685) - asfloat(cb1_raw[85u].x))));
            _727 = _525 + (asfloat(_698) + ((asfloat(_679) - asfloat(cb1_raw[84u].y)) + (asfloat(_686) - asfloat(cb1_raw[85u].y))));
            _728 = _526 + (asfloat(_699) + ((asfloat(_680) - asfloat(cb1_raw[84u].z)) + (asfloat(_687) - asfloat(cb1_raw[85u].z))));
            _740 = max((int)(0), (int)((int(floor(asfloat(_693) + log2(sqrt((_728 * _728) + ((_726 * _726) + (_727 * _727)))))) - _712)));
            if ((int)_740 < (int)_713) {
              _743 = _740 + asint(cb3_raw[9u].w);
              _745 = ((int)(_743 * 288)) | 16;
              _748 = asint(t8.Load4(((int)(_745 + 48u)))).x;
              _749 = asint(t8.Load4(((int)(_745 + 48u)))).y;
              _750 = asint(t8.Load4(((int)(_745 + 48u)))).z;
              _756 = asint(t8.Load4(((int)(_745 + 64u)))).x;
              _757 = asint(t8.Load4(((int)(_745 + 64u)))).y;
              _758 = asint(t8.Load4(((int)(_745 + 64u)))).z;
              _764 = asint(t8.Load4(((int)(_745 + 80u)))).x;
              _765 = asint(t8.Load4(((int)(_745 + 80u)))).y;
              _766 = asint(t8.Load4(((int)(_745 + 80u)))).z;
              _772 = asint(t8.Load4(((int)(_745 + 96u)))).x;
              _773 = asint(t8.Load4(((int)(_745 + 96u)))).y;
              _774 = asint(t8.Load4(((int)(_745 + 96u)))).z;
              _780 = asint(t8.Load3(((int)(_745 + 192u)))).x;
              _781 = asint(t8.Load3(((int)(_745 + 192u)))).y;
              _782 = asint(t8.Load3(((int)(_745 + 192u)))).z;
              _788 = asint(t8.Load3(((int)(_745 + 208u)))).x;
              _789 = asint(t8.Load3(((int)(_745 + 208u)))).y;
              _790 = asint(t8.Load3(((int)(_745 + 208u)))).z;
              _803 = ((asfloat(_780) - asfloat(cb1_raw[84u].x)) + (asfloat(_788) - asfloat(cb1_raw[85u].x))) + _524;
              _804 = ((asfloat(_781) - asfloat(cb1_raw[84u].y)) + (asfloat(_789) - asfloat(cb1_raw[85u].y))) + _525;
              _805 = ((asfloat(_782) - asfloat(cb1_raw[84u].z)) + (asfloat(_790) - asfloat(cb1_raw[85u].z))) + _526;
              _809 = mad(_805, asfloat(_764), mad(_804, asfloat(_756), (_803 * asfloat(_748)))) + asfloat(_772);
              _813 = mad(_805, asfloat(_765), mad(_804, asfloat(_757), (_803 * asfloat(_749)))) + asfloat(_773);
              _820 = uint(_809 * 128.0f);
              _821 = uint(_813 * 128.0f);
              _822 = ((int)_743 < (int)8192);
              if (_822) {
                _837 = (_743 & 127);
                _838 = ((uint)(_743) >> 7);
              } else {
                _827 = _743 + (uint)(-8191);
                _837 = ((int)((VirtualShadowMap_084 & _827) << 7));
                _838 = ((int)(((uint)(_827) >> (VirtualShadowMap_080 & 31)) * 192));
              }
              _844 = t9.Load(int3(((int)(_837 + (uint)(select(_822, 0, _820)))), ((int)(_838 + (uint)(select(_822, 0, _821)))), 0));
              _846 = (uint)((uint)(_844.x)) >> 20;
              _847 = _846 & 63;
              if ((int)_844.x < (int)0) {
                _850 = (_847 == 0);
                _852 = _847 + _743;
                if (!_850) {
                  _860 = asint(t8.Load2(((int)(_745 + 240u)))).x;
                  _861 = asint(t8.Load2(((int)(_745 + 240u)))).y;
                  _863 = ((int)(_852 * 288)) | 16;
                  _866 = asint(t8.Load2(((int)(_863 + 240u)))).x;
                  _867 = asint(t8.Load2(((int)(_863 + 240u)))).y;
                  _874 = _846 & 31;
                  _879 = (uint)((_820 - (_860 << 5)) + (((int)(_866 << 5)) << _874)) >> _874;
                  _880 = (uint)((_821 - (_861 << 5)) + (((int)(_867 << 5)) << _874)) >> _874;
                  _881 = _879 << 7;
                  _882 = _880 << 7;
                  _887 = asint(t8.Load4(((int)(_745 + 32u)))).z;
                  _891 = asint(t8.Load4(((int)(_863 + 32u)))).z;
                  _899 = 1.0f / float((uint)(1 << _874));
                  _920 = ((int)_852 < (int)8192);
                  if (_920) {
                    _935 = (_852 & 127);
                    _936 = ((uint)(_852) >> 7);
                  } else {
                    _925 = _852 + (uint)(-8191);
                    _935 = ((int)((VirtualShadowMap_084 & _925) << 7));
                    _936 = ((int)(((uint)(_925) >> (VirtualShadowMap_080 & 31)) * 192));
                  }
                  _941 = t9.Load(int3(((int)(_935 + (uint)(select(_920, 0, _879)))), ((int)(_936 + (uint)(select(_920, 0, _880)))), 0));
                  _947 = _941.x;
                  _948 = ((int)(uint)((int)((_941.x & -2081423360) == -2147483648)));
                  _949 = ((int)min((uint)(((int)max((uint)((int)(uint((((float((int)(_866)) - (_899 * float((int)(_860)))) * 0.25f) + (_899 * _809)) * 16384.0f))), (uint)(_881)))), (uint)((_881 | 127))));
                  _950 = ((int)min((uint)(((int)max((uint)((int)(uint((((float((int)(_867)) - (_899 * float((int)(_861)))) * 0.25f) + (_899 * _813)) * 16384.0f))), (uint)(_882)))), (uint)((_882 | 127))));
                  _951 = _899;
                  _952 = (asfloat(_891) - (_899 * asfloat(_887)));
                } else {
                  _947 = _844.x;
                  _948 = ((int)(uint)(_850));
                  _949 = (int)(uint(_809 * 16384.0f));
                  _950 = (int)(uint(_813 * 16384.0f));
                  _951 = 1.0f;
                  _952 = 0.0f;
                }
                if (!(_948 == 0)) {
                  _970 = ((asfloat((((uint)(t10.Load(int4(((_949 & 127) | (((int)(_947 << 7)) & 130944)), ((_950 & 127) | (((uint)(_947) >> 3) & 130944)), 0, 0)))).x)) - _952) / _951);
                  _971 = true;
                } else {
                  _970 = 0.0f;
                  _971 = false;
                }
              } else {
                _970 = 0.0f;
                _971 = false;
              }
              _1207 = select((_971 && (_970 > (mad(_805, asfloat(_766), mad(_804, asfloat(_758), (_803 * asfloat(_750)))) + asfloat(_774)))), 0.0f, 1.0f);
            } else {
              _1207 = 1.0f;
            }
          } else {
            _978 = asint(t8.Load4(((int)(_668 + 48u)))).x;
            _979 = asint(t8.Load4(((int)(_668 + 48u)))).y;
            _980 = asint(t8.Load4(((int)(_668 + 48u)))).z;
            _981 = asint(t8.Load4(((int)(_668 + 48u)))).w;
            _984 = asint(t8.Load4(((int)(_668 + 64u)))).x;
            _985 = asint(t8.Load4(((int)(_668 + 64u)))).y;
            _986 = asint(t8.Load4(((int)(_668 + 64u)))).z;
            _987 = asint(t8.Load4(((int)(_668 + 64u)))).w;
            _990 = asint(t8.Load4(((int)(_668 + 80u)))).x;
            _991 = asint(t8.Load4(((int)(_668 + 80u)))).y;
            _992 = asint(t8.Load4(((int)(_668 + 80u)))).z;
            _993 = asint(t8.Load4(((int)(_668 + 80u)))).w;
            _996 = asint(t8.Load4(((int)(_668 + 96u)))).x;
            _997 = asint(t8.Load4(((int)(_668 + 96u)))).y;
            _998 = asint(t8.Load4(((int)(_668 + 96u)))).z;
            _999 = asint(t8.Load4(((int)(_668 + 96u)))).w;
            _1001 = asint(t8.Load3(_674)).x;
            _1002 = asint(t8.Load3(_674)).y;
            _1003 = asint(t8.Load3(_674)).z;
            _1008 = asint(t8.Load3(_675)).x;
            _1009 = asint(t8.Load3(_675)).y;
            _1010 = asint(t8.Load3(_675)).z;
            _1016 = asint(t8.Load(((int)(_668 + 268u))));
            _1026 = ((asfloat(_1001) - asfloat(cb1_raw[84u].x)) + (asfloat(_1008) - asfloat(cb1_raw[85u].x))) + _524;
            _1027 = ((asfloat(_1002) - asfloat(cb1_raw[84u].y)) + (asfloat(_1009) - asfloat(cb1_raw[85u].y))) + _525;
            _1028 = ((asfloat(_1003) - asfloat(cb1_raw[84u].z)) + (asfloat(_1010) - asfloat(cb1_raw[85u].z))) + _526;
            if (!(_672 == 2)) {
              _1031 = abs(_1026);
              _1032 = abs(_1027);
              _1034 = abs(_1028);
              if ((_1031 < _1032) || (_1031 < _1034)) {
                if (_1032 > _1034) {
                  _1049 = select((_1027 > 0.0f), 2, 3);
                } else {
                  _1049 = select((_1028 > 0.0f), 4, 5);
                }
              } else {
                _1049 = ((int)(uint)((int)(!(_1026 > 0.0f))));
              }
              _1050 = _1049 + (uint)(asint(cb3_raw[9u].w));
              _1052 = ((int)(_1050 * 288)) | 16;
              _1055 = asint(t8.Load4(((int)(_1052 + 48u)))).x;
              _1056 = asint(t8.Load4(((int)(_1052 + 48u)))).y;
              _1057 = asint(t8.Load4(((int)(_1052 + 48u)))).z;
              _1058 = asint(t8.Load4(((int)(_1052 + 48u)))).w;
              _1061 = asint(t8.Load4(((int)(_1052 + 64u)))).x;
              _1062 = asint(t8.Load4(((int)(_1052 + 64u)))).y;
              _1063 = asint(t8.Load4(((int)(_1052 + 64u)))).z;
              _1064 = asint(t8.Load4(((int)(_1052 + 64u)))).w;
              _1067 = asint(t8.Load4(((int)(_1052 + 80u)))).x;
              _1068 = asint(t8.Load4(((int)(_1052 + 80u)))).y;
              _1069 = asint(t8.Load4(((int)(_1052 + 80u)))).z;
              _1070 = asint(t8.Load4(((int)(_1052 + 80u)))).w;
              _1073 = asint(t8.Load4(((int)(_1052 + 96u)))).x;
              _1074 = asint(t8.Load4(((int)(_1052 + 96u)))).y;
              _1075 = asint(t8.Load4(((int)(_1052 + 96u)))).z;
              _1076 = asint(t8.Load4(((int)(_1052 + 96u)))).w;
              _1079 = asint(t8.Load(((int)(_1052 + 268u))));
              _1081 = _1055;
              _1082 = _1056;
              _1083 = _1057;
              _1084 = _1058;
              _1085 = _1061;
              _1086 = _1062;
              _1087 = _1063;
              _1088 = _1064;
              _1089 = _1067;
              _1090 = _1068;
              _1091 = _1069;
              _1092 = _1070;
              _1093 = _1073;
              _1094 = _1074;
              _1095 = _1075;
              _1096 = _1076;
              _1097 = _1079;
              _1098 = _1050;
            } else {
              _1081 = _978;
              _1082 = _979;
              _1083 = _980;
              _1084 = _981;
              _1085 = _984;
              _1086 = _985;
              _1087 = _986;
              _1088 = _987;
              _1089 = _990;
              _1090 = _991;
              _1091 = _992;
              _1092 = _993;
              _1093 = _996;
              _1094 = _997;
              _1095 = _998;
              _1096 = _999;
              _1097 = _1016;
              _1098 = asint(cb3_raw[9u].w);
            }
            _1130 = mad(_1028, asfloat(_1092), mad(_1027, asfloat(_1088), (asfloat(_1084) * _1026))) + asfloat(_1096);
            _1131 = (mad(_1028, asfloat(_1089), mad(_1027, asfloat(_1085), (asfloat(_1081) * _1026))) + asfloat(_1093)) / _1130;
            _1132 = (mad(_1028, asfloat(_1090), mad(_1027, asfloat(_1086), (asfloat(_1082) * _1026))) + asfloat(_1094)) / _1130;
            _1138 = _1097 & 31;
            _1141 = ((int)_1098 < (int)8192);
            if (_1141) {
              _1167 = (_1098 & 127);
              _1168 = ((uint)(_1098) >> 7);
            } else {
              _1146 = _1098 + (uint)(-8191);
              if (!(_1097 == 0)) {
                _1162 = (((int)(127 << (((int)(8u - _1097)) & 31))) & 127);
                _1163 = 128;
              } else {
                _1162 = 0;
                _1163 = 0;
              }
              _1167 = (_1162 | ((int)((VirtualShadowMap_084 & _1146) << 7)));
              _1168 = ((int)(_1163 + (((uint)(_1146) >> (VirtualShadowMap_080 & 31)) * 192)));
            }
            _1174 = t9.Load(int3(((int)(_1167 + (uint)(select(_1141, 0, ((uint)(uint(_1131 * 128.0f)) >> _1138))))), ((int)(_1168 + (uint)(select(_1141, 0, ((uint)(uint(_1132 * 128.0f)) >> _1138))))), 0));
            _1182 = select(_1141, 128.0f, float((uint)((uint)((uint)(16384u) >> (((int)(((uint)((uint)((uint)(_1174.x)) >> 20)) + _1097)) & 31)))));
            if ((int)_1174.x < (int)0) {
              _1201 = asfloat((((uint)(t10.Load(int4((((int)(uint(_1182 * _1131)) & 127) | (((int)(_1174.x << 7)) & 130944)), (((int)(uint(_1182 * _1132)) & 127) | (((uint)((uint)(_1174.x)) >> 3) & 130944)), 0, 0)))).x));
              _1202 = true;
            } else {
              _1201 = 0.0f;
              _1202 = false;
            }
            _1207 = select((_1202 && (_1201 > ((mad(_1028, asfloat(_1091), mad(_1027, asfloat(_1087), (asfloat(_1083) * _1026))) + asfloat(_1095)) / _1130))), 0.0f, 1.0f);
          }
          _1208 = _1207 * _665;
          if (cb0_091x > 0.0f) {
            _1248 = mad(_526, cb0_084w, mad(_525, cb0_083w, (cb0_082w * _524))) + cb0_085w;
            _1258 = t12.SampleLevel(s2, float2(((((mad(_526, cb0_084x, mad(_525, cb0_083x, (cb0_082x * _524))) + cb0_085x) / _1248) * 0.5f) + 0.5f), (0.5f - (((mad(_526, cb0_084y, mad(_525, cb0_083y, (cb0_082y * _524))) + cb0_085y) / _1248) * 0.5f))), 0.0f);
            _1278 = ((((saturate(exp2(min(_1258.z, ((_1258.y * 1000.0f) * max(0.0f, ((saturate(1.0f - ((mad(_526, cb0_084z, mad(_525, cb0_083z, (cb0_082z * _524))) + cb0_085z) / _1248)) * cb0_090w) - _1258.x)))) * -1.4426950216293335f)) + -1.0f) * cb0_091x) + 1.0f) * _1208);
          } else {
            _1278 = _1208;
          }
        } else {
          _1278 = 1.0f;
        }
        if (cb0_093x == 0) {
          _1469 = t21.SampleLevel(s5, float2((((mad(_526, cb0_080x, mad(_525, cb0_079x, (cb0_078x * _524))) + cb0_081x) * 0.5f) + 0.5f), (0.5f - ((mad(_526, cb0_080y, mad(_525, cb0_079y, (cb0_078y * _524))) + cb0_081y) * 0.5f))), 0.0f);
          _1474 = _1469.x;
          _1475 = _1469.y;
          _1476 = _1469.z;
        } else {
          if (!(cb0_093y == 0)) {
            _1286 = cb0_093y * 5;
            _1289 = t1[_1286].x;
            _1290 = t1[_1286].y;
            _1291 = t1[_1286].z;
            _1292 = t1[_1286].w;
            _1293 = asint(_1290);
            _1294 = asint(_1291);
            _1298 = f16tof32(((uint)(((uint)(_1293) >> 8) & 65535)));
            _1307 = t1[((int)(_1286 + 1u))].x;
            _1308 = t1[((int)(_1286 + 1u))].y;
            _1309 = t1[((int)(_1286 + 1u))].z;
            _1310 = t1[((int)(_1286 + 1u))].w;
            _1313 = t1[((int)(_1286 + 2u))].x;
            _1314 = t1[((int)(_1286 + 2u))].y;
            _1315 = t1[((int)(_1286 + 2u))].z;
            _1316 = t1[((int)(_1286 + 2u))].w;
            _1319 = t1[((int)(_1286 + 3u))].x;
            _1320 = t1[((int)(_1286 + 3u))].y;
            _1321 = t1[((int)(_1286 + 3u))].z;
            _1322 = t1[((int)(_1286 + 3u))].w;
            _1325 = t1[((int)(_1286 + 4u))].x;
            _1326 = t1[((int)(_1286 + 4u))].y;
            _1327 = t1[((int)(_1286 + 4u))].z;
            _1328 = t1[((int)(_1286 + 4u))].w;
            _1344 = mad(_526, _1322, mad(_525, _1316, (_1310 * _524))) + _1328;
            _1345 = (mad(_526, _1321, mad(_525, _1315, (_1309 * _524))) + _1327) / _1344;
            _1346 = (mad(_526, _1320, mad(_525, _1314, (_1308 * _524))) + _1326) / _1344;
            _1347 = (mad(_526, _1319, mad(_525, _1313, (_1307 * _524))) + _1325) / _1344;
            switch (((int)(_1293 & 255))) {
              case 2: {
                _1349 = _1347 * _1292;
                _1393 = (((_1345 / _1349) * 0.5f) + 0.5f);
                _1394 = (((_1346 / _1349) * 0.5f) + 0.5f);
                break;
              }
              case 1: {
                _1358 = rsqrt(dot(float3(_1345, _1346, _1347), float3(_1345, _1346, _1347)));
                _1359 = _1358 * _1345;
                _1360 = _1358 * _1346;
                _1363 = atan(_1360 / _1359);
                _1366 = (_1359 < 0.0f);
                _1367 = (_1359 == 0.0f);
                _1368 = (_1360 >= 0.0f);
                _1369 = (_1360 < 0.0f);
                _1393 = select((_1367 && _1368), 0.75f, select((_1367 && _1369), 0.25f, ((select((_1366 && _1369), (_1363 + -3.1415927410125732f), select((_1366 && _1368), (_1363 + 3.1415927410125732f), _1363)) + 3.1415927410125732f) * 0.15915493667125702f)));
                _1394 = (acos(_1358 * _1347) * 0.31830987334251404f);
                break;
              }
              case 3: {
                if (_1292 > 0.0f) {
                  _1385 = _1347 * _1292;
                  _1393 = (((_1345 / _1385) * 0.5f) + 0.5f);
                  _1394 = (((_1346 / _1385) * 0.5f) + 0.5f);
                } else {
                  _1393 = _1345;
                  _1394 = _1346;
                }
                break;
              }
              default: {
                _1393 = _1345;
                _1394 = _1346;
                break;
              }
            }
            _1407 = t0.SampleLevel(s0, float2(((LightFunctionAtlas_024 * saturate(frac(_1393))) + (float((uint)((uint)(_1294 & 65535))) * 1.52587890625e-05f)), ((LightFunctionAtlas_024 * saturate(frac(_1394))) + (float((uint)((uint)((uint)(_1294) >> 16))) * 1.52587890625e-05f))), 0.0f);
            _1414 = asfloat(cb1_raw[81u].x) - _524;
            _1415 = asfloat(cb1_raw[81u].y) - _525;
            _1416 = asfloat(cb1_raw[81u].z) - _526;
            _1422 = sqrt(((_1414 * _1414) + (_1415 * _1415)) + (_1416 * _1416));
            if (!_75) {
              _1428 = ((_1422 / dot(float3(_1414, _1415, _1416), float3(asfloat(cb1_raw[73u].x), asfloat(cb1_raw[73u].y), asfloat(cb1_raw[73u].z)))) * _1422);
            } else {
              _1428 = _1422;
            }
            _1432 = saturate((_1289 - _1428) / (_1289 * 0.20000000298023224f));
            _1474 = ((_1432 * ((_1407.x * _1407.x) - _1298)) + _1298);
            _1475 = ((_1432 * ((_1407.y * _1407.y) - _1298)) + _1298);
            _1476 = ((_1432 * ((_1407.z * _1407.z) - _1298)) + _1298);
          } else {
            _1474 = 1.0f;
            _1475 = 1.0f;
            _1476 = 1.0f;
          }
        }
        _1477 = _524 + asfloat(cb1_raw[84u].x);
        _1478 = _525 + asfloat(cb1_raw[84u].y);
        _1479 = _526 + asfloat(cb1_raw[84u].z);
        _1480 = _1477 - _524;
        _1481 = _1478 - _525;
        _1482 = _1479 - _526;
        _1495 = _371 + ((asfloat(cb1_raw[84u].x) - _1480) + (_524 - (_1477 - _1480)));
        _1496 = _372 + ((asfloat(cb1_raw[84u].y) - _1481) + (_525 - (_1478 - _1481)));
        _1497 = _373 + ((asfloat(cb1_raw[84u].z) - _1482) + (_526 - (_1479 - _1482)));
        _1498 = _1477 + _1495;
        _1499 = _1478 + _1496;
        _1500 = _1479 + _1497;
        _1507 = ((asfloat(cb1_raw[85u].x) - _371) + (0.0f - (_371 - _371))) + (_1495 - (_1498 - _1477));
        _1508 = ((asfloat(cb1_raw[85u].y) - _372) + (0.0f - (_372 - _372))) + (_1496 - (_1499 - _1478));
        _1509 = ((asfloat(cb1_raw[85u].z) - _373) + (0.0f - (_373 - _373))) + (_1497 - (_1500 - _1479));
        _1510 = _1498 + _1507;
        _1511 = _1499 + _1508;
        _1512 = _1500 + _1509;
        _1519 = (_1507 - (_1510 - _1498)) + _1510;
        _1520 = (_1508 - (_1511 - _1499)) + _1511;
        _1521 = (_1509 - (_1512 - _1500)) + _1512;
        _1533 = mad(_1521, asfloat(cb1_raw[351u].w), mad(_1520, asfloat(cb1_raw[350u].w), (_1519 * asfloat(cb1_raw[349u].w)))) + asfloat(cb1_raw[352u].w);
        if ((abs((mad(_1521, asfloat(cb1_raw[351u].x), mad(_1520, asfloat(cb1_raw[350u].x), (_1519 * asfloat(cb1_raw[349u].x)))) + asfloat(cb1_raw[352u].x)) / _1533) <= asfloat(cb1_raw[365u].x)) && (abs((mad(_1521, asfloat(cb1_raw[351u].y), mad(_1520, asfloat(cb1_raw[350u].y), (_1519 * asfloat(cb1_raw[349u].y)))) + asfloat(cb1_raw[352u].y)) / _1533) <= asfloat(cb1_raw[365u].y))) {
          _1546 = (asfloat(cb1_raw[369u].x) > -3.4028234663852886e+38f);
        } else {
          _1546 = false;
        }
        if (!_1546) {
          _1575 = mad(_1521, asfloat(cb1_raw[355u].w), mad(_1520, asfloat(cb1_raw[354u].w), (asfloat(cb1_raw[353u].w) * _1519))) + asfloat(cb1_raw[356u].w);
          if ((abs((mad(_1521, asfloat(cb1_raw[355u].x), mad(_1520, asfloat(cb1_raw[354u].x), (asfloat(cb1_raw[353u].x) * _1519))) + asfloat(cb1_raw[356u].x)) / _1575) <= asfloat(cb1_raw[366u].x)) && (abs((mad(_1521, asfloat(cb1_raw[355u].y), mad(_1520, asfloat(cb1_raw[354u].y), (asfloat(cb1_raw[353u].y) * _1519))) + asfloat(cb1_raw[356u].y)) / _1575) <= asfloat(cb1_raw[366u].y))) {
            _1591 = (asfloat(cb1_raw[370u].x) > -3.4028234663852886e+38f);
            _1592 = 1;
          } else {
            _1591 = false;
            _1592 = 0;
          }
          if (!_1591) {
            _1621 = mad(_1521, asfloat(cb1_raw[359u].w), mad(_1520, asfloat(cb1_raw[358u].w), (asfloat(cb1_raw[357u].w) * _1519))) + asfloat(cb1_raw[360u].w);
            if ((abs((mad(_1521, asfloat(cb1_raw[359u].x), mad(_1520, asfloat(cb1_raw[358u].x), (asfloat(cb1_raw[357u].x) * _1519))) + asfloat(cb1_raw[360u].x)) / _1621) <= asfloat(cb1_raw[367u].x)) && (abs((mad(_1521, asfloat(cb1_raw[359u].y), mad(_1520, asfloat(cb1_raw[358u].y), (asfloat(cb1_raw[357u].y) * _1519))) + asfloat(cb1_raw[360u].y)) / _1621) <= asfloat(cb1_raw[367u].y))) {
              _1637 = (asfloat(cb1_raw[371u].x) > -3.4028234663852886e+38f);
              _1638 = 2;
            } else {
              _1637 = false;
              _1638 = 0;
            }
            if (!_1637) {
              _1667 = mad(_1521, asfloat(cb1_raw[363u].w), mad(_1520, asfloat(cb1_raw[362u].w), (asfloat(cb1_raw[361u].w) * _1519))) + asfloat(cb1_raw[364u].w);
              if ((abs((mad(_1521, asfloat(cb1_raw[363u].x), mad(_1520, asfloat(cb1_raw[362u].x), (asfloat(cb1_raw[361u].x) * _1519))) + asfloat(cb1_raw[364u].x)) / _1667) <= asfloat(cb1_raw[368u].x)) && (abs((mad(_1521, asfloat(cb1_raw[363u].y), mad(_1520, asfloat(cb1_raw[362u].y), (asfloat(cb1_raw[361u].y) * _1519))) + asfloat(cb1_raw[364u].y)) / _1667) <= asfloat(cb1_raw[368u].y))) {
                _1684 = select((asfloat(cb1_raw[372u].x) > -3.4028234663852886e+38f), 3, -1);
              } else {
                _1684 = -1;
              }
            } else {
              _1684 = _1638;
            }
          } else {
            _1684 = _1592;
          }
        } else {
          _1684 = 0;
        }
        _1686 = select((_1684 == -1), 0, _1684);
        _1690 = asfloat(cb1_raw[((int)(_1686 + 533))]);
        _1692 = (_1690.w < ((_526 - asfloat(cb1_raw[84u].z)) - asfloat(cb1_raw[85u].z)));
        _1697 = asfloat(cb1_raw[((int)(_1686 + 541))]);
        _1703 = asfloat(cb1_raw[((int)(_1686 + 543))]);
        _1707 = asfloat(cb1_raw[((int)(_1686 + 535))]);
        _1712 = asfloat(cb1_raw[((int)(_1686 + 539))]);
        _1720 = max(asfloat(cb3_raw[5u].z), 9.99999993922529e-09f);
        _1726 = max(((((((-0.0f - _526) - _1703.y) + asfloat(cb1_raw[84u].z)) + asfloat(cb1_raw[85u].z)) + _1690.w) / (lerp(_1720, 1.0f, _1712.w))), 0.0f) * -0.009999999776482582f;
        _1738 = exp2(((_1707.x * 1.4426950216293335f) * _1726) * asfloat(cb1_raw[347u].x));
        _1739 = exp2(((_1707.y * 1.4426950216293335f) * _1726) * asfloat(cb1_raw[347u].x));
        _1740 = exp2(((_1707.z * 1.4426950216293335f) * _1726) * asfloat(cb1_raw[347u].x));
        _1751 = (saturate(sqrt(((_525 * _525) + (_524 * _524)) + (_526 * _526)) * _1703.x) * (_1703.w - _1697.w)) + _1697.w;
        if (cb0_088z > 0.0f) {
          _1769 = dot(float3(_561, _562, _563), float3(0.2126390039920807f, 0.7151686549186707f, 0.07219231873750687f));
          _1774 = (VolumetricFog_112.x * _1769);
          _1775 = (VolumetricFog_112.y * _1769);
          _1776 = (VolumetricFog_112.z * _1769);
        } else {
          _1774 = _561;
          _1775 = _562;
          _1776 = _563;
        }
        _1787 = (((dot(float3(asfloat(cb3_raw[5u].x), asfloat(cb3_raw[5u].y), asfloat(cb3_raw[5u].z)), float3((-0.0f - _550), (-0.0f - _551), (-0.0f - _552))) * 2.0f) + cb0_090x) * cb0_090x) + 1.0f;
        _1791 = (1.0f - (cb0_090x * cb0_090x)) / ((sqrt(_1787) * 12.566370964050293f) * _1787);
        _1805 = cb0_090x;
        _1806 = ((((select(_1692, 1.0f, _1474) * _1278) * ((_1751 * (_1697.x - _1738)) + _1738)) * _1774) * _1791);
        _1807 = ((((select(_1692, 1.0f, _1475) * _1278) * ((_1751 * (_1697.y - _1739)) + _1739)) * _1775) * _1791);
        _1808 = ((((select(_1692, 1.0f, _1476) * _1278) * ((_1751 * (_1697.z - _1740)) + _1740)) * _1776) * _1791);
      }
      _1809 = _1805 * _551;
      _1810 = _1805 * _552;
      _1811 = _1805 * _550;
      _1835 = _530 - asfloat(cb1_raw[72u].x);
      _1836 = _531 - asfloat(cb1_raw[72u].y);
      _1837 = _532 - asfloat(cb1_raw[72u].z);
      _1838 = _1835 - _530;
      _1839 = _1836 - _531;
      _1840 = _1837 - _532;
      _1853 = (((-0.0f - asfloat(cb1_raw[72u].x)) - _1838) + (_530 - (_1835 - _1838))) + _1835;
      _1854 = (((-0.0f - asfloat(cb1_raw[72u].y)) - _1839) + (_531 - (_1836 - _1839))) + _1836;
      _1855 = (((-0.0f - asfloat(cb1_raw[72u].z)) - _1840) + (_532 - (_1837 - _1840))) + _1837;
      _1867 = asfloat(cb1_raw[7u].w) + mad(_1855, asfloat(cb1_raw[6u].w), mad(_1854, asfloat(cb1_raw[5u].w), (_1853 * asfloat(cb1_raw[4u].w))));
      _1881 = (LumenGIVolumeStruct_480.z * log2((LumenGIVolumeStruct_480.x * _1867) + LumenGIVolumeStruct_480.y)) / float((int)(LumenGIVolumeStruct_496.z));
      _1884 = (((asfloat(cb1_raw[7u].x) + mad(_1855, asfloat(cb1_raw[6u].x), mad(_1854, asfloat(cb1_raw[5u].x), (_1853 * asfloat(cb1_raw[4u].x))))) / _1867) * 0.5f) + 0.5f;
      _1885 = 0.5f - (((asfloat(cb1_raw[7u].y) + mad(_1855, asfloat(cb1_raw[6u].y), mad(_1854, asfloat(cb1_raw[5u].y), (_1853 * asfloat(cb1_raw[4u].y))))) / _1867) * 0.5f);
      _1888 = t6.SampleLevel(s0, float3(_1884, _1885, _1881), 0.0f);
      _1893 = t7.SampleLevel(s0, float3(_1884, _1885, _1881), 0.0f);
      _1898 = dot(float3(_1888.x, _1888.y, _1888.z), float3(0.2126390039920807f, 0.7151686549186707f, 0.07219231873750687f)) + 9.999999747378752e-06f;
      _1899 = _1888.x / _1898;
      _1900 = _1888.y / _1898;
      _1901 = _1888.z / _1898;
      _1917 = max(dot(float4(_1888.x, (_1899 * _1893.x), (_1899 * _1893.y), (_1899 * _1893.z)), float4(1.0f, _1809, _1810, _1811)), 0.0f) + _1806;
      _1918 = max(dot(float4(_1888.y, (_1900 * _1893.x), (_1900 * _1893.y), (_1900 * _1893.z)), float4(1.0f, _1809, _1810, _1811)), 0.0f) + _1807;
      _1919 = max(dot(float4(_1888.z, (_1901 * _1893.x), (_1901 * _1893.y), (_1901 * _1893.z)), float4(1.0f, _1809, _1810, _1811)), 0.0f) + _1808;
      _1941 = asint(cb3_raw[3u].x) & 31;
      _1950 = ((int)((((int)((asint(cb3_raw[2u].y) * ((int)min((uint)((int)(uint(max(0.0f, (log2((asfloat(cb3_raw[4u].x) * _492) + asfloat(cb3_raw[4u].y)) * asfloat(cb3_raw[4u].z)))))), (uint)((asint(cb3_raw[2u].z) + -1))))) + ((uint)((uint)(VolumetricFog_128.y * (int)(SV_DispatchThreadID.y)) >> _1941)))) * asint(cb3_raw[2u].x)) + ((uint)((uint)(VolumetricFog_128.x * (int)(SV_DispatchThreadID.x)) >> _1941)))) << 1;
      _1953 = t4[_1950];
      _1956 = (int)min((uint)((_1953 & 65535)), (uint)(asint(cb3_raw[0u].x)));
      _1959 = t4[(_1950 | 1)];
      _1972 = (((_475 + float((uint)(SV_DispatchThreadID.x + 1u))) / VolumetricFog_016.x) * 2.0f) + -1.0f;
      _1974 = -0.0f - ((((_476 + float((uint)(SV_DispatchThreadID.y + 1u))) / VolumetricFog_016.y) * 2.0f) + -1.0f);
      _1981 = (exp2(max((_477 + float((uint)(SV_DispatchThreadID.z + 1u))), 0.0f) / VolumetricFog_064.z) - VolumetricFog_064.y) / VolumetricFog_064.x;
      [branch]
      if (_75) {
        _1996 = (1.0f / ((asfloat(cb1_raw[78u].w) + _1981) * asfloat(cb1_raw[78u].z)));
      } else {
        _1996 = ((asfloat(cb1_raw[30u].z) * _1981) + asfloat(cb1_raw[31u].z));
      }
      _2012 = mad(_1996, cb0_007w, mad(_1974, cb0_006w, (cb0_005w * _1972))) + cb0_008w;
      _2016 = _524 - ((mad(_1996, cb0_007x, mad(_1974, cb0_006x, (cb0_005x * _1972))) + cb0_008x) / _2012);
      _2017 = _525 - ((mad(_1996, cb0_007y, mad(_1974, cb0_006y, (cb0_005y * _1972))) + cb0_008y) / _2012);
      _2018 = _526 - ((mad(_1996, cb0_007z, mad(_1974, cb0_006z, (cb0_005z * _1972))) + cb0_008z) / _2012);
      _2027 = max((cb0_090y * sqrt(((_2017 * _2017) + (_2016 * _2016)) + (_2018 * _2018))), 1.0f);
      _2028 = _2027 * _2027;
      if (!(_1956 == 0)) {
        _2032 = _1917;
        _2033 = _1918;
        _2034 = _1919;
        _2035 = 0;
        while(true) {
          _2622 = _2032;
          _2623 = _2033;
          _2624 = _2034;
          _2040 = (((uint)(t5.Load((int)(_2035 + ((uint)(_1959 & 1073741823)))))).x) * 6;
          _2044 = t3[((int)(_2040 + 4u))].x;
          _2045 = t3[((int)(_2040 + 4u))].y;
          _2046 = t3[((int)(_2040 + 4u))].z;
          _2049 = t3[((int)(_2040 + 3u))].x;
          _2050 = t3[((int)(_2040 + 3u))].y;
          _2051 = t3[((int)(_2040 + 3u))].w;
          _2054 = t3[((int)(_2040 + 2u))].x;
          _2055 = t3[((int)(_2040 + 2u))].y;
          _2056 = t3[((int)(_2040 + 2u))].z;
          _2059 = t3[(_2040 | 1)].x;
          _2060 = t3[(_2040 | 1)].w;
          _2062 = t3[_2040].w;
          _2063 = asint(_2051);
          _2065 = f16tof32(((uint)((uint)(_2063) >> 16)));
          if (_2065 > 0.0f) {
            _2068 = t3[(_2040 | 1)].y;
            _2069 = t3[((int)(_2040 + 2u))].w;
            _2070 = t3[_2040].z;
            _2071 = t3[_2040].y;
            _2072 = t3[_2040].x;
            _2073 = t3[((int)(_2040 + 3u))].z;
            _2076 = t3[((int)(_2040 + 5u))].z;
            _2077 = asint(_2069);
            _2079 = ((uint)(_2077) >> 16) & 3;
            _2080 = asint(_2068);
            _2094 = f16tof32(((uint)(asint(_2073) & 65535)));
            _2095 = -0.0f - _2094;
            _2096 = f16tof32(_2063);
            _2097 = -0.0f - _2096;
            _2099 = (_2079 == 3);
            _2100 = asint(_2076);
            _2102 = f16tof32(((uint)(_2100 & 65535)));
            _2106 = float((uint)((uint)(((uint)(_2100) >> 16) & 1023))) * 0.0009775171056389809f;
            _2108 = ((uint)(_2077) >> 20) & 255;
            _2109 = (_2060 == 0.0f);
            _2110 = _2072 - _524;
            _2111 = _2071 - _525;
            _2112 = _2070 - _526;
            _2113 = dot(float3(_2110, _2111, _2112), float3(_2110, _2111, _2112));
            _2114 = rsqrt(_2113);
            _2115 = _2114 * _2110;
            _2116 = _2114 * _2111;
            _2117 = _2114 * _2112;
            if (_2109) {
              _2120 = (_2062 * _2062) * _2113;
              _2123 = saturate(1.0f - (_2120 * _2120));
              _2136 = (_2123 * _2123);
            } else {
              _2126 = _2110 * _2062;
              _2127 = _2111 * _2062;
              _2128 = _2112 * _2062;
              _2136 = exp2(log2(1.0f - saturate(dot(float3(_2126, _2127, _2128), float3(_2126, _2127, _2128)))) * _2060);
            }
            if (_2079 == 2) {
              _2141 = saturate((dot(float3(_2115, _2116, _2117), float3(_2054, _2055, _2056)) - _2049) * _2050);
              _2145 = ((_2141 * _2141) * _2136);
            } else {
              _2145 = _2136;
            }
            if (_2099) {
              _2151 = select((dot(float3(_2054, _2055, _2056), float3(_2115, _2116, _2117)) < 0.0f), 0.0f, _2145);
            } else {
              _2151 = _2145;
            }
            if (_2099) {
              _2155 = (_2056 * _2045) - (_2055 * _2046);
              _2158 = (_2054 * _2046) - (_2056 * _2044);
              _2161 = (_2055 * _2044) - (_2054 * _2045);
              if (_2106 > 0.03500000014901161f) {
                _2166 = mad(_2161, _2112, mad(_2158, _2111, (_2110 * _2155)));
                _2169 = mad(_2046, _2112, mad(_2045, _2111, (_2110 * _2044)));
                _2172 = mad(_2056, _2112, mad(_2055, _2111, (_2110 * _2054)));
                _2176 = _2106 * _2102;
                _2177 = min(_2172, _2176);
                _2181 = (sqrt(1.0f - (_2106 * _2106)) * _2102) * (_2177 / max(9.999999747378752e-05f, _2176));
                _2192 = float((int)(((int)(uint)((int)(_2166 > 0.0f))) - ((int)(uint)((int)(_2166 < 0.0f)))));
                _2193 = float((int)(((int)(uint)((int)(_2169 > 0.0f))) - ((int)(uint)((int)(_2169 < 0.0f)))));
                _2207 = max((_2172 - _2177), 0.0010000000474974513f);
                _2214 = ((abs(((_2095 - _2181) + max(abs(_2166), (_2181 + _2094))) * _2192) / _2207) * _2177) - _2181;
                _2215 = ((abs(((_2097 - _2181) + max(abs(_2169), (_2181 + _2096))) * _2193) / _2207) * _2177) - _2181;
                _2226 = min(max(((_2214 * max(0.0f, (-0.0f - _2192))) - _2094), _2095), _2094);
                _2227 = min(max(((_2215 * max(0.0f, (-0.0f - _2193))) - _2096), _2097), _2096);
                _2236 = min(max((_2094 - (max(0.0f, _2192) * _2214)), _2095), _2094);
                _2237 = min(max((_2096 - (max(0.0f, _2193) * _2215)), _2097), _2096);
                _2240 = (_2236 + _2226) * 0.5f;
                _2241 = (_2237 + _2227) * 0.5f;
                _2259 = ((_2110 - (_2240 * _2155)) - (_2241 * _2044));
                _2260 = ((_2111 - (_2240 * _2158)) - (_2241 * _2045));
                _2261 = ((_2112 - (_2240 * _2161)) - (_2241 * _2046));
                _2262 = ((_2236 - _2226) * 0.5f);
                _2263 = ((_2237 - _2227) * 0.5f);
              } else {
                _2259 = _2110;
                _2260 = _2111;
                _2261 = _2112;
                _2262 = _2094;
                _2263 = _2096;
              }
              if (!((_2262 == 0.0f) || (_2263 == 0.0f))) {
                _2268 = dot(float3(_2155, _2158, _2161), float3(_2259, _2260, _2261));
                _2269 = dot(float3(_2044, _2045, _2046), float3(_2259, _2260, _2261));
                _2270 = dot(float3(_2054, _2055, _2056), float3(_2259, _2260, _2261));
                _2271 = _2268 - _2262;
                _2272 = _2268 + _2262;
                _2273 = _2269 - _2263;
                _2274 = _2269 + _2263;
                _2275 = _2270 * _2270;
                _2278 = rsqrt(dot(float2(_2271, _2273), float2(_2271, _2273)) + _2275);
                _2279 = _2278 * _2271;
                _2280 = _2278 * _2273;
                _2281 = _2278 * _2270;
                _2284 = rsqrt(dot(float2(_2272, _2273), float2(_2272, _2273)) + _2275);
                _2285 = _2284 * _2272;
                _2286 = _2284 * _2273;
                _2287 = _2284 * _2270;
                _2290 = rsqrt(dot(float2(_2272, _2274), float2(_2272, _2274)) + _2275);
                _2291 = _2290 * _2272;
                _2292 = _2290 * _2274;
                _2293 = _2290 * _2270;
                _2296 = rsqrt(dot(float2(_2271, _2274), float2(_2271, _2274)) + _2275);
                _2297 = _2296 * _2271;
                _2298 = _2296 * _2274;
                _2299 = _2296 * _2270;
                _2300 = dot(float3(_2279, _2280, _2281), float3(_2285, _2286, _2287));
                _2301 = dot(float3(_2285, _2286, _2287), float3(_2291, _2292, _2293));
                _2302 = dot(float3(_2291, _2292, _2293), float3(_2297, _2298, _2299));
                _2303 = dot(float3(_2297, _2298, _2299), float3(_2279, _2280, _2281));
                _2314 = rsqrt(max((_2301 + 1.0f), 9.999999747378752e-05f)) * (1.5707999467849731f - (_2301 * 0.17499999701976776f));
                _2325 = rsqrt(max((_2303 + 1.0f), 9.999999747378752e-05f)) * (1.5707999467849731f - (_2303 * 0.17499999701976776f));
                _2327 = -0.0f - ((1.5707999467849731f - (_2300 * 0.17499999701976776f)) * rsqrt(max((_2300 + 1.0f), 9.999999747378752e-05f)));
                _2334 = (_2314 * _2291) + (_2279 * _2327);
                _2335 = (_2314 * _2292) + (_2280 * _2327);
                _2336 = (_2314 * _2293) + (_2281 * _2327);
                _2350 = -0.0f - ((1.5707999467849731f - (_2302 * 0.17499999701976776f)) * rsqrt(max((_2302 + 1.0f), 9.999999747378752e-05f)));
                _2354 = (_2325 * _2279) + (_2291 * _2350);
                _2355 = (_2325 * _2280) + (_2292 * _2350);
                _2356 = (_2325 * _2281) + (_2293 * _2350);
                _2366 = ((_2356 * _2298) - (_2355 * _2299)) + ((_2336 * _2286) - (_2335 * _2287));
                _2367 = ((_2354 * _2299) - (_2356 * _2297)) + ((_2334 * _2287) - (_2336 * _2285));
                _2368 = ((_2355 * _2297) - (_2354 * _2298)) + ((_2335 * _2285) - (_2334 * _2286));
                _2381 = ((_2366 * _2155) + (_2367 * _2044)) + (_2368 * _2054);
                _2382 = ((_2366 * _2158) + (_2367 * _2045)) + (_2368 * _2055);
                _2383 = ((_2366 * _2161) + (_2367 * _2046)) + (_2368 * _2056);
                _2384 = dot(float3(_2381, _2382, _2383), float3(_2381, _2382, _2383));
                _2419 = ((_2384 * 0.5f) * rsqrt(_2384));
              } else {
                _2419 = 0.0f;
              }
            } else {
              _2389 = _2096 * 0.5f;
              _2390 = _2389 * _2044;
              _2391 = _2389 * _2045;
              _2392 = _2389 * _2046;
              _2393 = _2110 - _2390;
              _2394 = _2111 - _2391;
              _2395 = _2112 - _2392;
              _2396 = _2390 + _2110;
              _2397 = _2391 + _2111;
              _2398 = _2392 + _2112;
              _2400 = dot(float3(_2393, _2394, _2395), float3(_2393, _2394, _2395));
              [branch]
              if (_2096 > 0.0f) {
                _2405 = rsqrt(dot(float3(_2396, _2397, _2398), float3(_2396, _2397, _2398))) * rsqrt(_2400);
                _2416 = (_2405 / ((((dot(float3(_2393, _2394, _2395), float3(_2396, _2397, _2398)) * 0.5f) + _2028) * _2405) + 0.5f));
              } else {
                _2416 = (1.0f / (_2400 + _2028));
              }
              _2419 = select(_2109, _2416, 1.0f);
            }
            if (!(_2108 == 0)) {
              _2422 = _2108 * 5;
              _2425 = t1[_2422].x;
              _2426 = t1[_2422].y;
              _2427 = t1[_2422].z;
              _2428 = t1[_2422].w;
              _2429 = asint(_2426);
              _2430 = asint(_2427);
              _2434 = f16tof32(((uint)(((uint)(_2429) >> 8) & 65535)));
              _2443 = t1[(_2422 + 1)].x;
              _2444 = t1[(_2422 + 1)].y;
              _2445 = t1[(_2422 + 1)].z;
              _2446 = t1[(_2422 + 1)].w;
              _2449 = t1[(_2422 + 2)].x;
              _2450 = t1[(_2422 + 2)].y;
              _2451 = t1[(_2422 + 2)].z;
              _2452 = t1[(_2422 + 2)].w;
              _2455 = t1[(_2422 + 3)].x;
              _2456 = t1[(_2422 + 3)].y;
              _2457 = t1[(_2422 + 3)].z;
              _2458 = t1[(_2422 + 3)].w;
              _2461 = t1[(_2422 + 4)].x;
              _2462 = t1[(_2422 + 4)].y;
              _2463 = t1[(_2422 + 4)].z;
              _2464 = t1[(_2422 + 4)].w;
              _2480 = mad(_526, _2458, mad(_525, _2452, (_2446 * _524))) + _2464;
              _2481 = (mad(_526, _2457, mad(_525, _2451, (_2445 * _524))) + _2463) / _2480;
              _2482 = (mad(_526, _2456, mad(_525, _2450, (_2444 * _524))) + _2462) / _2480;
              _2483 = (mad(_526, _2455, mad(_525, _2449, (_2443 * _524))) + _2461) / _2480;
              switch (((int)(_2429 & 255))) {
                case 2: {
                  _2485 = _2483 * _2428;
                  _2529 = (((_2481 / _2485) * 0.5f) + 0.5f);
                  _2530 = (((_2482 / _2485) * 0.5f) + 0.5f);
                  break;
                }
                case 1: {
                  _2494 = rsqrt(dot(float3(_2481, _2482, _2483), float3(_2481, _2482, _2483)));
                  _2495 = _2494 * _2481;
                  _2496 = _2494 * _2482;
                  _2499 = atan(_2496 / _2495);
                  _2502 = (_2495 < 0.0f);
                  _2503 = (_2495 == 0.0f);
                  _2504 = (_2496 >= 0.0f);
                  _2505 = (_2496 < 0.0f);
                  _2529 = select((_2503 && _2504), 0.75f, select((_2503 && _2505), 0.25f, ((select((_2502 && _2505), (_2499 + -3.1415927410125732f), select((_2502 && _2504), (_2499 + 3.1415927410125732f), _2499)) + 3.1415927410125732f) * 0.15915493667125702f)));
                  _2530 = (acos(_2494 * _2483) * 0.31830987334251404f);
                  break;
                }
                case 3: {
                  if (_2428 > 0.0f) {
                    _2521 = _2483 * _2428;
                    _2529 = (((_2481 / _2521) * 0.5f) + 0.5f);
                    _2530 = (((_2482 / _2521) * 0.5f) + 0.5f);
                  } else {
                    _2529 = _2481;
                    _2530 = _2482;
                  }
                  break;
                }
                default: {
                  _2529 = _2481;
                  _2530 = _2482;
                  break;
                }
              }
              _2543 = t0.SampleLevel(s0, float2(((LightFunctionAtlas_024 * saturate(frac(_2529))) + (float((uint)((uint)(_2430 & 65535))) * 1.52587890625e-05f)), ((LightFunctionAtlas_024 * saturate(frac(_2530))) + (float((uint)((uint)((uint)(_2430) >> 16))) * 1.52587890625e-05f))), 0.0f);
              _2554 = asfloat(cb1_raw[81u].x) - _524;
              _2555 = asfloat(cb1_raw[81u].y) - _525;
              _2556 = asfloat(cb1_raw[81u].z) - _526;
              _2562 = sqrt(((_2554 * _2554) + (_2555 * _2555)) + (_2556 * _2556));
              if (!(asfloat(cb1_raw[31u].w) < 1.0f)) {
                _2575 = ((_2562 / dot(float3(_2554, _2555, _2556), float3(asfloat(cb1_raw[73u].x), asfloat(cb1_raw[73u].y), asfloat(cb1_raw[73u].z)))) * _2562);
              } else {
                _2575 = _2562;
              }
              _2579 = saturate((_2425 - _2575) / (_2425 * 0.20000000298023224f));
              _2590 = ((_2579 * ((_2543.x * _2543.x) - _2434)) + _2434);
              _2591 = ((_2579 * ((_2543.y * _2543.y) - _2434)) + _2434);
              _2592 = ((_2579 * ((_2543.z * _2543.z) - _2434)) + _2434);
            } else {
              _2590 = 1.0f;
              _2591 = 1.0f;
              _2592 = 1.0f;
            }
            _2607 = (((dot(float3(_2115, _2116, _2117), float3((-0.0f - _550), (-0.0f - _551), (-0.0f - _552))) * 2.0f) + cb0_090x) * cb0_090x) + 1.0f;
            _2614 = ((_2151 * _2065) * _2419) * ((1.0f - (cb0_090x * cb0_090x)) / ((sqrt(_2607) * 12.566370964050293f) * _2607));
            _2622 = ((((float((uint)((uint)(_2080 & 1023))) * _2059) * _2590) * _2614) + _2032);
            _2623 = ((((float((uint)((uint)(((uint)(_2080) >> 10) & 1023))) * _2059) * _2591) * _2614) + _2033);
            _2624 = ((((float((uint)((uint)(((uint)(_2080) >> 20) & 1023))) * _2059) * _2592) * _2614) + _2034);
          } else {
            _2622 = _2032;
            _2623 = _2033;
            _2624 = _2034;
          }
          _2625 = _2035 + 1u;
          if (!(_2625 == _1956)) {
            _2032 = _2622;
            _2033 = _2623;
            _2034 = _2624;
            _2035 = _2625;
            continue;
          }
          _2629 = _2622;
          _2630 = _2623;
          _2631 = _2624;
          break;
        }
      } else {
        _2629 = _1917;
        _2630 = _1918;
        _2631 = _1919;
      }
      _2635 = t20.Load(int4((int)(SV_DispatchThreadID.x), (int)(SV_DispatchThreadID.y), (int)(SV_DispatchThreadID.z), 0));
      _2646 = t15.Load(int4((int)(SV_DispatchThreadID.x), (int)(SV_DispatchThreadID.y), (int)(SV_DispatchThreadID.z), 0));
      _2651 = t16.Load(int4((int)(SV_DispatchThreadID.x), (int)(SV_DispatchThreadID.y), (int)(SV_DispatchThreadID.z), 0));
      [branch]
      if (!(cb0_092z == 0)) {
        _2659 = t17.Load(int4((int)(SV_DispatchThreadID.x), (int)(SV_DispatchThreadID.y), (int)(SV_DispatchThreadID.z), 0));
        _2664 = _2659.x;
        _2665 = _2659.y;
        _2666 = _2659.z;
      } else {
        _2664 = 0.0f;
        _2665 = 0.0f;
        _2666 = 0.0f;
      }
      _2674 = asfloat(cb1_raw[156u].z) * (_2664 + (_2646.x * ((_2635.x * asfloat(cb1_raw[156u].w)) + _2629)));
      _2675 = asfloat(cb1_raw[156u].z) * (_2665 + (_2646.y * ((_2635.y * asfloat(cb1_raw[156u].w)) + _2630)));
      _2676 = asfloat(cb1_raw[156u].z) * (_2666 + (_2646.z * ((_2635.z * asfloat(cb1_raw[156u].w)) + _2631)));
      [branch]
      if (_421 > 0.0f) {
        _2695 = min(_357, asfloat(cb1_raw[255u].z));
        _2696 = min(_358, asfloat(cb1_raw[255u].w));
        _2697 = min(_191, 1.0f);
        // Tricubic history filter + neighborhood clamping for inscatter (path 2)
        {
          float3 _hist_uvw2 = float3(_2695, _2696, _2697);
          float3 _fog_tex_size2 = float3(VolumetricFog_000);
          float3 _fog_uv_max2 = float3(asfloat(cb1_raw[255u].z), asfloat(cb1_raw[255u].w), 1.0);
          float3 _hist_rgb2 = SampleFogHistory3(t18, s3, _hist_uvw2, _fog_tex_size2, InjectionFogFilterMode(), _fog_uv_max2);
          float3 _voxel_step2 = 1.0 / _fog_tex_size2;
          float3 _n_xp2 = t18.SampleLevel(s3, _hist_uvw2 + float3(_voxel_step2.x, 0, 0), 0).rgb;
          float3 _n_xn2 = t18.SampleLevel(s3, _hist_uvw2 - float3(_voxel_step2.x, 0, 0), 0).rgb;
          float3 _n_yp2 = t18.SampleLevel(s3, _hist_uvw2 + float3(0, _voxel_step2.y, 0), 0).rgb;
          float3 _n_yn2 = t18.SampleLevel(s3, _hist_uvw2 - float3(0, _voxel_step2.y, 0), 0).rgb;
          float3 _n_zp2 = t18.SampleLevel(s3, _hist_uvw2 + float3(0, 0, _voxel_step2.z), 0).rgb;
          float3 _n_zn2 = t18.SampleLevel(s3, _hist_uvw2 - float3(0, 0, _voxel_step2.z), 0).rgb;
          float3 _bilinear_c2 = t18.SampleLevel(s3, _hist_uvw2, 0).rgb;
          float3 _nhood_min2 = min(min(min(_n_xp2, _n_xn2), min(_n_yp2, _n_yn2)), min(min(_n_zp2, _n_zn2), _bilinear_c2));
          float3 _nhood_max2 = max(max(max(_n_xp2, _n_xn2), max(_n_yp2, _n_yn2)), max(max(_n_zp2, _n_zn2), _bilinear_c2));
          _hist_rgb2 = clamp(_hist_rgb2, _nhood_min2, _nhood_max2);
          _2700 = float4(_hist_rgb2, t18.SampleLevel(s3, _hist_uvw2, 0).w);
        }
        _2706 = asfloat(cb1_raw[156u].z) * cb0_089y;
        _2707 = _2706 * _2700.x;
        _2708 = _2706 * _2700.y;
        _2709 = _2706 * _2700.z;
        _2723 = (log2(_2707 + 9.99999993922529e-09f) - log2(_2674 + 9.99999993922529e-09f)) * 0.6931471824645996f;
        _2725 = (log2(_2708 + 9.99999993922529e-09f) - log2(_2675 + 9.99999993922529e-09f)) * 0.6931471824645996f;
        _2727 = (log2(_2709 + 9.99999993922529e-09f) - log2(_2676 + 9.99999993922529e-09f)) * 0.6931471824645996f;
        _2739 = (1.0f - saturate(cb0_092x * sqrt(((_2725 * _2725) + (_2723 * _2723)) + (_2727 * _2727)))) * (((_421 - cb0_091z) * (1.0f - saturate(1.0f / (cb0_091w * max(((t11.Load(int3((int)(SV_DispatchThreadID.x), (int)(SV_DispatchThreadID.y), 0))).x), 0.003921568859368563f))))) + cb0_091z);
        _2742 = t19.SampleLevel(s4, float3(_2695, _2696, _2697), 0.0f);
        _2765 = ((_2739 * (_2707 - _2674)) + _2674);
        _2766 = ((_2739 * (_2708 - _2675)) + _2675);
        _2767 = ((_2739 * (_2709 - _2676)) + _2676);
        _2768 = (lerp(_2651.x, _2742.x, _2739));
        _2769 = (lerp(_2651.y, _2742.y, _2739));
        _2770 = (lerp(_2651.z, _2742.z, _2739));
      } else {
        _2765 = _2674;
        _2766 = _2675;
        _2767 = _2676;
        _2768 = _2651.x;
        _2769 = _2651.y;
        _2770 = _2651.z;
      }
      if (((int)(int)(SV_DispatchThreadID.z) < (int)VolumetricFog_000.z) && (((int)(int)(SV_DispatchThreadID.x) < (int)VolumetricFog_000.x) && ((int)(int)(SV_DispatchThreadID.y) < (int)VolumetricFog_000.y))) {
        u0[int3((int)(SV_DispatchThreadID.x), (int)(SV_DispatchThreadID.y), (int)(SV_DispatchThreadID.z))] = float3(select(((uint)asint(_2765) < (uint)2139095040), _2765, 0.0f), select(((uint)asint(_2766) < (uint)2139095040), _2766, 0.0f), select(((uint)asint(_2767) < (uint)2139095040), _2767, 0.0f));
        u1[int3((int)(SV_DispatchThreadID.x), (int)(SV_DispatchThreadID.y), (int)(SV_DispatchThreadID.z))] = float3(select(((uint)asint(_2768) < (uint)2139095040), _2768, 0.0f), select(((uint)asint(_2769) < (uint)2139095040), _2769, 0.0f), select(((uint)asint(_2770) < (uint)2139095040), _2770, 0.0f));
      }
    }
  }
}