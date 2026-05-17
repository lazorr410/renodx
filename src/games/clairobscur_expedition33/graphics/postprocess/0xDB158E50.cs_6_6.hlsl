#include "../shared.h"

// IS-FAST noise buffer (ByteAddressBuffer root SRV â€” avoids ReShade heap-swap corruption)
ByteAddressBuffer FASTNoiseTexture : register(t0, space50);
static const uint FAST_NOISE_W = 128u;
static const uint FAST_NOISE_H = 128u;
static const uint FAST_NOISE_SLICE_TEXELS = FAST_NOISE_W * FAST_NOISE_H;
static const uint FAST_NOISE_ELEMENT_BYTES = 8u;
static float2 FastNoiseLoad(uint x, uint y, uint slice) {
  return asfloat(FASTNoiseTexture.Load2((slice * FAST_NOISE_SLICE_TEXELS + y * FAST_NOISE_W + x) * FAST_NOISE_ELEMENT_BYTES));
}

Texture2D<float4> GatherInput_SceneColor : register(t0);

Texture2D<float4> TileClassification_Foreground : register(t1);

RWTexture2D<float4> ConvolutionOutput_SceneColor : register(u0);

cbuffer _RootShaderParameters : register(b0) {
  float4 ViewportSize : packoffset(c000.x);
  uint4 ViewportRect : packoffset(c001.x);
  float2 DispatchThreadIdToInputBufferUV : packoffset(c002.z);
  float2 ConsiderCocRadiusAffineTransformation0 : packoffset(c003.x);
  float2 ConsiderCocRadiusAffineTransformation1 : packoffset(c003.z);
  float2 ConsiderAbsCocRadiusAffineTransformation : packoffset(c004.x);
  float2 InputBufferUVToOutputPixel : packoffset(c004.z);
  float MaxRecombineAbsCocRadius : packoffset(c005.y);
  float CocInvSqueeze : packoffset(c005.w);
  float MinGatherRadius : packoffset(c006.x);
  float SlightOutOfFocusRadiusBoundary : packoffset(c006.y);
  float4 GatherInputSize : packoffset(c008.x);
  float2 GatherInputViewportSize : packoffset(c009.x);
};

SamplerState D3DStaticPointClampedSampler : register(s1, space1000);

// DXIL FirstbitHi: returns bit position counting from MSB (leading zeros count)
uint firstbithigh_msb(int value) { return (value == 0) ? 0xFFFFFFFF : (31u - firstbithigh(value)); }
uint firstbithigh_msb(uint value) { return (value == 0) ? 0xFFFFFFFF : (31u - firstbithigh(value)); }

[numthreads(8, 8, 1)]
void main(
  uint3 SV_DispatchThreadID : SV_DispatchThreadID,
  uint3 SV_GroupID : SV_GroupID,
  uint3 SV_GroupThreadID : SV_GroupThreadID,
  uint SV_GroupIndex : SV_GroupIndex
) {
  float _11;
  float _12;
  float _18;
  float _19;
  float4 _36;
  float _39;
  bool _50;
  float _132;
  float _133;
  float _134;
  float _135;
  float _136;
  int _140;
  float _141;
  float _142;
  float _143;
  float _144;
  float _145;
  int _146;
  float _176;
  float _177;
  float _178;
  float _179;
  float _180;
  float _181;
  float _182;
  float _183;
  float _184;
  int _185;
  float _199;
  float _200;
  float _201;
  float _202;
  float _203;
  int _204;
  float _281;
  float _282;
  float _296;
  float _297;
  float _298;
  float _299;
  float _300;
  float _314;
  float _315;
  float _316;
  float _317;
  float _318;
  float _326;
  float _327;
  float _328;
  float _329;
  float _330;
  float _335;
  float _336;
  float _337;
  float _338;
  float _339;
  float _355;
  float _356;
  float _357;
  float _358;
  float _52;
  int _54;
  float _66;
  float _67;
  float _70;
  float _73;
  float _83;
  float _84;
  float _87;
  float _91;
  float _97;
  float _98;
  float _99;
  float _100;
  float _101;
  float _104;
  float _105;
  float _106;
  float _107;
  float4 _116;
  float _120;
  float _122;
  int _148;
  float _150;
  uint _153;
  float _154;
  float _156;
  float _157;
  float _158;
  float _159;
  float _160;
  float _164;
  float _165;
  float _166;
  float _169;
  float _170;
  float _171;
  float _172;
  float _194;
  float _195;
  float _196;
  float _197;
  bool _205;
  float _215;
  float _216;
  float _217;
  float _218;
  float _221;
  float _222;
  float4 _231;
  float _240;
  float _241;
  float _242;
  float _245;
  float _246;
  float4 _253;
  float _262;
  float _287;
  float _305;
  int _319;
  int _322;
  bool _340;
  float _342;
  float _349;
  float _350;
  uint _364;
  uint _365;
  int __loop_jump_target = -1;
  _11 = float((uint)SV_DispatchThreadID.x);
  _12 = float((uint)SV_DispatchThreadID.y);
  _18 = DispatchThreadIdToInputBufferUV.x * (_11 + 0.5f);
  _19 = DispatchThreadIdToInputBufferUV.y * (_12 + 0.5f);
  _36 = TileClassification_Foreground.Load(int3((int)(SV_GroupID.x), (int)(SV_GroupID.y), 0));
  _39 = -0.0f - _36.x;
  if (!((_36.y < -3.0f) || ((_36.y - _36.x) < (_36.x * -0.05000000074505806f)))) {
    _50 = (MinGatherRadius >= _39);
  } else {
    _50 = true;
  }
  _52 = WaveReadLaneFirst(_39);
  _54 = WaveReadLaneFirst(5);
  [branch]
  if (_50) {
    if (!(((uint)(int)(SV_DispatchThreadID.x) >= (uint)ViewportRect.z) || ((uint)(int)(SV_DispatchThreadID.y) >= (uint)ViewportRect.w))) {
      ConvolutionOutput_SceneColor[int2((int)(SV_DispatchThreadID.x), (int)(SV_DispatchThreadID.y))] = float4(0.0f, 0.0f, 0.0f, 1.0f);
    }
  } else {
    // IS-FAST noise replacement for bokeh sampling jitter
    float _fast_radius_noise;
    float _fast_angle_noise;
    if (InjectionToggle(TOGGLE_USE_ISFAST_DOF)) {
      uint _fast_slice = (((uint)_11 ^ ((uint)_12 * 7u)) + (uint)float(InjectionFrameIndex())) % 32u;
      float2 _fast_n = FastNoiseLoad((uint)_11 % 128u, (uint)_12 % 128u, _fast_slice);
      // UniformCircle disk texture: RG stores point on unit disk in [0,1] (encoded from [-1,1])
      float2 _disk_point = _fast_n * 2.0f - 1.0f;  // recover signed disk coordinate
      _fast_radius_noise = length(_disk_point) * 0.47999998927116394f;
      _fast_angle_noise = atan2(_disk_point.y, _disk_point.x);
    } else {
      _fast_radius_noise = sqrt(frac(frac(dot(float2(_11, _12), float2(0.0671105608344078f, 0.005837149918079376f))) * 52.98291778564453f)) * 0.47999998927116394f;
      _fast_angle_noise = frac(frac(dot(float2((_11 + 32.665000915527344f), (_12 + 11.8149995803833f)), float2(0.0671105608344078f, 0.005837149918079376f))) * 52.98291778564453f) * 6.2831854820251465f;
    }
    _66 = _fast_radius_noise;
    _67 = _fast_angle_noise;
    _70 = _52 * 0.1818181872367859f;
    _73 = floor(log2(_70) + 0.5f);
    _83 = (((cos(_67) * _70) * _66) * GatherInputSize.z) + _18;
    _84 = (((_66 * _70) * sin(_67)) * GatherInputSize.w) + _19;
    _87 = exp2(float((uint)uint(_73)));
    _91 = _87 * 0.5f;
    _97 = WaveReadLaneFirst(_70);
    _98 = WaveReadLaneFirst((GatherInputViewportSize.x - _91) * GatherInputSize.z);
    _99 = WaveReadLaneFirst((GatherInputViewportSize.y - _91) * GatherInputSize.w);
    _100 = WaveReadLaneFirst(_73);
    _101 = WaveReadLaneFirst(1.0f / _87);
    _104 = max(_83, (-0.0f - _83));
    _105 = max(_84, (-0.0f - _84));
    _106 = _98 * 2.0f;
    _107 = _99 * 2.0f;
    _116 = GatherInput_SceneColor.SampleLevel(D3DStaticPointClampedSampler, float2(min(min(_104, (_106 - _104)), _98), min(min(_105, (_107 - _105)), _99)), _100);
    _120 = saturate((_116.w * ConsiderAbsCocRadiusAffineTransformation.x) + ConsiderAbsCocRadiusAffineTransformation.y);
    _122 = -0.0f - (MaxRecombineAbsCocRadius + -1.0f);
    if (!(_116.w < _122)) {
      _132 = (_116.x * _120);
      _133 = (_116.y * _120);
      _134 = (_116.z * _120);
      _135 = _120;
      _136 = 16384.0f;
    } else {
      _132 = 0.0f;
      _133 = 0.0f;
      _134 = 0.0f;
      _135 = 0.0f;
      _136 = 0.0f;
    }
    if ((int)_54 > (int)0) {
      _140 = 4;
      _141 = _132;
      _142 = _133;
      _143 = _134;
      _144 = _135;
      _145 = _136;
      _146 = 0;
      while(true) {
        _326 = _141;
        _327 = _142;
        _328 = _143;
        _329 = _144;
        _330 = _145;
        _148 = _146 + 1;
        _150 = float((uint)_148) * _97;
        _153 = (_146 << 2) + 4u;
        _154 = WaveReadLaneFirst(_150);
        _156 = float((uint)_153);
        _157 = 3.1415927410125732f / _156;
        _158 = cos(_157);
        _159 = sin(_157);
        _160 = -0.0f - _159;
        _164 = (float((uint)((uint)(_146 & 1))) * 1.5707963705062866f) / _156;
        _165 = cos(_164);
        _166 = sin(_164);
        _169 = WaveReadLaneFirst(_165);
        _170 = WaveReadLaneFirst(_166);
        _171 = WaveReadLaneFirst(_165 * _154);
        _172 = WaveReadLaneFirst(_166 * _154);
        if (!(_153 == 0)) {
          _176 = _141;
          _177 = _142;
          _178 = _143;
          _179 = _144;
          _180 = _145;
          _181 = _169;
          _182 = _170;
          _183 = _171;
          _184 = _172;
          _185 = 0;
          while(true) {
            _194 = WaveReadLaneFirst(mad(_182, _160, (_181 * _158)));
            _195 = WaveReadLaneFirst(mad(_182, _158, (_181 * _159)));
            _196 = WaveReadLaneFirst(mad(_184, _160, (_183 * _158)));
            _197 = WaveReadLaneFirst(mad(_184, _158, (_183 * _159)));
            _199 = _176;
            _200 = _177;
            _201 = _178;
            _202 = _179;
            _203 = _180;
            _204 = 0;
            while(true) {
              _205 = (_204 == 1);
              _215 = (CocInvSqueeze * select(_205, (-0.0f - _197), _196)) * GatherInputSize.z;
              _216 = GatherInputSize.w * select(_205, _196, _197);
              _217 = _215 + _83;
              _218 = _216 + _84;
              _221 = max(_217, (-0.0f - _217));
              _222 = max(_218, (-0.0f - _218));
              _231 = GatherInput_SceneColor.SampleLevel(D3DStaticPointClampedSampler, float2(min(min(_221, (_106 - _221)), _98), min(min(_222, (_107 - _222)), _99)), _100);
              _240 = saturate(((abs(_231.w) - _154) * _101) + 0.5f);
              // Soft depth-separated rejection: gently fade out near-focus samples in BG gather
              if (InjectionToggle(TOGGLE_USE_SMOOTH_DOF)) {
                _240 *= smoothstep(0.0f, 4.0f, _231.w);  // smooth ramp over CoC 0-4
              }
              _241 = _83 - _215;
              _242 = _84 - _216;
              _245 = max(_241, (-0.0f - _241));
              _246 = max(_242, (-0.0f - _242));
              _253 = GatherInput_SceneColor.SampleLevel(D3DStaticPointClampedSampler, float2(min(min(_245, (_106 - _245)), _98), min(min(_246, (_107 - _246)), _99)), _100);
              _262 = saturate(((abs(_253.w) - _154) * _101) + 0.5f);
              // Soft depth-separated rejection for mirror sample
              if (InjectionToggle(TOGGLE_USE_SMOOTH_DOF)) {
                _262 *= smoothstep(0.0f, 4.0f, _253.w);
              }
              if ((_231.w < 0.0f) && (_253.w > _231.w)) {
                _281 = max(_262, _240);
                _282 = _240;
              } else {
                if ((_253.w < 0.0f) && (_231.w > _253.w)) {
                  _281 = _262;
                  _282 = max(_262, _240);
                } else {
                  _281 = _262;
                  _282 = _240;
                }
              }
              if (_231.w < _122) {
                _296 = _199;
                _297 = _200;
                _298 = _201;
                _299 = _202;
                _300 = min(_203, _154);
              } else {
                _287 = _282 * saturate((_231.w * ConsiderAbsCocRadiusAffineTransformation.x) + ConsiderAbsCocRadiusAffineTransformation.y);
                _296 = ((_287 * _231.x) + _199);
                _297 = ((_287 * _231.y) + _200);
                _298 = ((_287 * _231.z) + _201);
                _299 = (_287 + _202);
                _300 = _203;
              }
              if (_253.w < _122) {
                _314 = _296;
                _315 = _297;
                _316 = _298;
                _317 = _299;
                _318 = min(_300, _154);
              } else {
                _305 = _281 * saturate((_253.w * ConsiderAbsCocRadiusAffineTransformation.x) + ConsiderAbsCocRadiusAffineTransformation.y);
                _314 = (_296 + (_305 * _253.x));
                _315 = (_297 + (_305 * _253.y));
                _316 = (_298 + (_305 * _253.z));
                _317 = (_299 + _305);
                _318 = _300;
              }
              _319 = _204 + 1;
              if (!(_319 == 2)) {
                _199 = _314;
                _200 = _315;
                _201 = _316;
                _202 = _317;
                _203 = _318;
                _204 = _319;
                continue;
              }
              _322 = _185 + 1;
              if (!(_322 == ((uint)(_140) >> 1))) {
                _176 = _314;
                _177 = _315;
                _178 = _316;
                _179 = _317;
                _180 = _318;
                _181 = _194;
                _182 = _195;
                _183 = _196;
                _184 = _197;
                _185 = _322;
                __loop_jump_target = 175;
                break;
              }
              _326 = _314;
              _327 = _315;
              _328 = _316;
              _329 = _317;
              _330 = _318;
              break;
            }
            if (__loop_jump_target == 175) {
              __loop_jump_target = -1;
              continue;
            }
            if (__loop_jump_target != -1) {
              break;
            }
            break;
          }
        } else {
          _326 = _141;
          _327 = _142;
          _328 = _143;
          _329 = _144;
          _330 = _145;
        }
        if (!(_148 == _54)) {
          _140 = ((int)(_140 + 4u));
          _141 = _326;
          _142 = _327;
          _143 = _328;
          _144 = _329;
          _145 = _330;
          _146 = _148;
          continue;
        }
        _335 = _326;
        _336 = _327;
        _337 = _328;
        _338 = _329;
        _339 = _330;
        break;
      }
    } else {
      _335 = _132;
      _336 = _133;
      _337 = _134;
      _338 = _135;
      _339 = _136;
    }
    _340 = (_338 > 0.0f);
    _342 = select(_340, (1.0f / _338), 0.0f);
    if (_340 && (_339 != 16384.0f)) {
      _349 = _339 / _52;
      _350 = 1.0f - _349;
      _355 = ((_342 * _335) * _350);
      _356 = ((_342 * _336) * _350);
      _357 = ((_342 * _337) * _350);
      _358 = _349;
    } else {
      _355 = 0.0f;
      _356 = 0.0f;
      _357 = 0.0f;
      _358 = 1.0f;
    }
    _364 = uint(InputBufferUVToOutputPixel.x * _18);
    _365 = uint(InputBufferUVToOutputPixel.y * _19);
    if (!(((uint)_364 >= (uint)ViewportRect.z) || ((uint)_365 >= (uint)ViewportRect.w))) {
      ConvolutionOutput_SceneColor[int2(_364, _365)] = float4(_355, _356, _357, _358);
    }
  }
}