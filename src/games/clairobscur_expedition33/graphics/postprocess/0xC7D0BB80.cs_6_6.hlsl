#include "../shared.h"

Texture2D<float4> GatherInput_SceneColor : register(t0);

Texture2D<float4> TileClassification_Foreground : register(t1);

Texture2D<float4> TileClassification_Background : register(t2);

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
  float CocSqueeze : packoffset(c005.z);
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
  float _19;
  float _20;
  float4 _24;
  float4 _27;
  bool _30;
  bool _31;
  float _40;
  int _83;
  float _84;
  float _85;
  float _86;
  float _87;
  float _88;
  float _89;
  int _90;
  float _120;
  float _121;
  float _122;
  float _123;
  float _124;
  float _125;
  float _126;
  float _127;
  float _128;
  float _129;
  int _130;
  float _156;
  int _157;
  float _160;
  float _161;
  float _162;
  float _163;
  float _164;
  float _165;
  int _166;
  float _281;
  float _282;
  float _283;
  float _284;
  float _285;
  float _286;
  float _294;
  float _295;
  float _296;
  float _297;
  float _298;
  float _299;
  float _304;
  float _305;
  float _306;
  float _307;
  float _308;
  float _309;
  float _36;
  float _42;
  int _54;
  float _75;
  float _76;
  float _77;
  float _78;
  uint _92;
  float _93;
  float _94;
  uint _97;
  float _98;
  float _100;
  float _101;
  float _102;
  float _103;
  float _104;
  float _108;
  float _109;
  float _110;
  float _113;
  float _114;
  float _115;
  float _116;
  float _139;
  float _140;
  float _141;
  float _142;
  float _158;
  bool _167;
  float _169;
  float _170;
  float _171;
  float _172;
  float _183;
  float _187;
  float _191;
  float _192;
  float _193;
  float _194;
  float _197;
  float _198;
  float _199;
  float _200;
  float4 _209;
  float _214;
  float _219;
  float _220;
  float _223;
  float _224;
  float4 _231;
  float _236;
  bool _255;
  float _256;
  float _258;
  float _259;
  float _267;
  int _287;
  int _290;
  float _312;
  float _313;
  float4 _324;
  float _332;
  float _333;
  float _334;
  float _337;
  uint _343;
  uint _344;
  int __loop_jump_target = -1;
  _19 = DispatchThreadIdToInputBufferUV.x * (float((uint)SV_DispatchThreadID.x) + 0.5f);
  _20 = DispatchThreadIdToInputBufferUV.y * (float((uint)SV_DispatchThreadID.y) + 0.5f);
  _24 = TileClassification_Foreground.Load(int3((int)(SV_GroupID.x), (int)(SV_GroupID.y), 0));
  _27 = TileClassification_Background.Load(int3((int)(SV_GroupID.x), (int)(SV_GroupID.y), 0));
  _30 = (_24.x == 0.0f);
  _31 = (_27.x == 0.0f);
  if (!_30) {
    _36 = -0.0f - _24.y;
    if (!_31) {
      _40 = min(_36, _27.y);
    } else {
      _40 = _36;
    }
  } else {
    _40 = select((_30 && _31), 16384.0f, _27.y);
  }
  _42 = max((-0.0f - _24.x), _27.x);
  _54 = WaveReadLaneFirst((int)(uint(round(min(_42, SlightOutOfFocusRadiusBoundary)))));
  [branch]
  if (_40 > SlightOutOfFocusRadiusBoundary) {
    if (!((int)((uint)(int)(SV_DispatchThreadID.x) >= (uint)ViewportRect.z) || (int)((uint)(int)(SV_DispatchThreadID.y) >= (uint)ViewportRect.w))) {
      ConvolutionOutput_SceneColor[int2((int)(SV_DispatchThreadID.x), (int)(SV_DispatchThreadID.y))] = float4(0.0f, 0.0f, 0.0f, 0.0f);
    }
  } else {
    _75 = WaveReadLaneFirst(1.0f);
    _76 = WaveReadLaneFirst((GatherInputViewportSize.x + -0.5f) * GatherInputSize.z);
    _77 = WaveReadLaneFirst((GatherInputViewportSize.y + -0.5f) * GatherInputSize.w);
    _78 = WaveReadLaneFirst(0.0f);
    if (!(_54 == 0)) {
      _83 = 4;
      _84 = 0.0f;
      _85 = 0.0f;
      _86 = 0.0f;
      _87 = 0.0f;
      _88 = 0.0f;
      _89 = 0.0f;
      _90 = 0;
      while(true) {
        _92 = _90 + 1u;
        _93 = float((uint)_92);
        _94 = _93 * _75;
        _97 = (_90 << 2) + 4u;
        _98 = WaveReadLaneFirst(_94);
        _100 = float((uint)_97);
        _101 = 3.1415927410125732f / _100;
        _102 = cos(_101);
        _103 = sin(_101);
        _104 = -0.0f - _103;
        _108 = (float((uint)((uint)(_90 & 1))) * 1.5707963705062866f) / _100;
        _109 = cos(_108);
        _110 = sin(_108);
        _113 = WaveReadLaneFirst(_109);
        _114 = WaveReadLaneFirst(_110);
        _115 = WaveReadLaneFirst(_109 * _98);
        _116 = WaveReadLaneFirst(_110 * _98);
        if (!(_97 == 0)) {
          _120 = _84;
          _121 = _85;
          _122 = _86;
          _123 = _87;
          _124 = _88;
          _125 = _89;
          _126 = _113;
          _127 = _114;
          _128 = _115;
          _129 = _116;
          _130 = 0;
          while(true) {
            _139 = WaveReadLaneFirst(mad(_127, _104, (_126 * _102)));
            _140 = WaveReadLaneFirst(mad(_127, _102, (_126 * _103)));
            _141 = WaveReadLaneFirst(mad(_129, _104, (_128 * _102)));
            _142 = WaveReadLaneFirst(mad(_129, _102, (_128 * _103)));
            if (!((uint)_130 < (uint)_92)) {
              if ((uint)_130 < (uint)((int)(_92 * 3))) {
                _156 = (_93 - float((uint)(_130 - _92)));
                _157 = _92;
              } else {
                _156 = (-0.0f - _93);
                _157 = ((int)((_92 << 2) - _130));
              }
            } else {
              _156 = _93;
              _157 = _130;
            }
            _158 = float((uint)_157);
            _160 = _120;
            _161 = _121;
            _162 = _122;
            _163 = _123;
            _164 = _124;
            _165 = _125;
            _166 = 0;
            while(true) {
              _167 = (_166 == 1);
              _169 = select(_167, (-0.0f - _158), _156);
              _170 = select(_167, _156, _158);
              _171 = _169 * _75;
              _172 = _170 * _75;
              if (!(sqrt((_169 * _169) + (_170 * _170)) > (float((uint)_54) + 0.5f))) {
                _183 = CocSqueeze * _171;
                _187 = sqrt((_183 * _183) + (_172 * _172));
                _191 = GatherInputSize.z * _171;
                _192 = GatherInputSize.w * _172;
                _193 = _191 + _19;
                _194 = _192 + _20;
                _197 = max(_193, (-0.0f - _193));
                _198 = max(_194, (-0.0f - _194));
                _199 = _76 * 2.0f;
                _200 = _77 * 2.0f;
                _209 = GatherInput_SceneColor.SampleLevel(D3DStaticPointClampedSampler, float2(min(min(_197, (_199 - _197)), _76), min(min(_198, (_200 - _198)), _77)), _78);
                _214 = abs(_209.w);
                _219 = _19 - _191;
                _220 = _20 - _192;
                _223 = max(_219, (-0.0f - _219));
                _224 = max(_220, (-0.0f - _220));
                _231 = GatherInput_SceneColor.SampleLevel(D3DStaticPointClampedSampler, float2(min(min(_223, (_199 - _223)), _76), min(min(_224, (_200 - _224)), _77)), _78);
                _236 = abs(_231.w);
                _255 = (_231.w > _209.w);
                _256 = select(_255, saturate(((_214 - _187) * 4.0f) + 0.5f), saturate(((_236 - _187) * 4.0f) + 0.5f));
                _258 = select(_255, min((0.31830987334251404f / (_209.w * _209.w)), 5.092957973480225f), min((0.31830987334251404f / (_231.w * _231.w)), 5.092957973480225f)) * _256;
                _259 = _258 * saturate(MaxRecombineAbsCocRadius - _214);
                _267 = saturate(MaxRecombineAbsCocRadius - _236) * _258;
                _281 = (((_259 * _209.x) + _160) + (_267 * _231.x));
                _282 = (((_259 * _209.y) + _161) + (_267 * _231.y));
                _283 = (((_259 * _209.z) + _162) + (_267 * _231.z));
                _284 = ((_259 + _163) + _267);
                _285 = (((saturate(MaxRecombineAbsCocRadius - _231.w) + saturate(MaxRecombineAbsCocRadius - _209.w)) * _256) + _164);
                _286 = ((_256 * 2.0f) + _165);
              } else {
                _281 = _160;
                _282 = _161;
                _283 = _162;
                _284 = _163;
                _285 = _164;
                _286 = _165;
              }
              _287 = _166 + 1;
              if (!(_287 == 2)) {
                _160 = _281;
                _161 = _282;
                _162 = _283;
                _163 = _284;
                _164 = _285;
                _165 = _286;
                _166 = _287;
                continue;
              }
              _290 = _130 + 1;
              if (!(_290 == ((uint)(_83) >> 1))) {
                _120 = _281;
                _121 = _282;
                _122 = _283;
                _123 = _284;
                _124 = _285;
                _125 = _286;
                _126 = _139;
                _127 = _140;
                _128 = _141;
                _129 = _142;
                _130 = _290;
                __loop_jump_target = 119;
                break;
              }
              _294 = _281;
              _295 = _282;
              _296 = _283;
              _297 = _284;
              _298 = _285;
              _299 = _286;
              break;
            }
            if (__loop_jump_target == 119) {
              __loop_jump_target = -1;
              continue;
            }
            if (__loop_jump_target != -1) {
              break;
            }
            break;
          }
        } else {
          _294 = _84;
          _295 = _85;
          _296 = _86;
          _297 = _87;
          _298 = _88;
          _299 = _89;
        }
        if (!(_92 == _54)) {
          _83 = ((int)(_83 + 4u));
          _84 = _294;
          _85 = _295;
          _86 = _296;
          _87 = _297;
          _88 = _298;
          _89 = _299;
          _90 = _92;
          continue;
        }
        _304 = _294;
        _305 = _295;
        _306 = _296;
        _307 = _297;
        _308 = _298;
        _309 = _299;
        break;
      }
    } else {
      _304 = 0.0f;
      _305 = 0.0f;
      _306 = 0.0f;
      _307 = 0.0f;
      _308 = 0.0f;
      _309 = 0.0f;
    }
    _312 = max(_19, (-0.0f - _19));
    _313 = max(_20, (-0.0f - _20));
    _324 = GatherInput_SceneColor.SampleLevel(D3DStaticPointClampedSampler, float2(min(min(_312, ((_76 * 2.0f) - _312)), _76), min(min(_313, ((_77 * 2.0f) - _313)), _77)), _78);
    _332 = saturate(MaxRecombineAbsCocRadius - abs(_324.w)) * min((0.31830987334251404f / (_324.w * _324.w)), 5.092957973480225f);
    _333 = _332 + _307;
    _334 = _309 + 1.0f;
    _337 = select((_333 > 0.0f), (1.0f / _333), 0.0f);
    _343 = uint(InputBufferUVToOutputPixel.x * _19);
    _344 = uint(InputBufferUVToOutputPixel.y * _20);
    if (!((int)((uint)_343 >= (uint)ViewportRect.z) || (int)((uint)_344 >= (uint)ViewportRect.w))) {
      ConvolutionOutput_SceneColor[int2(_343, _344)] = float4((_337 * ((_332 * _324.x) + _304)), (_337 * ((_332 * _324.y) + _305)), (_337 * ((_332 * _324.z) + _306)), (select((_334 > 0.0f), (1.0f / _334), 0.0f) * (saturate(MaxRecombineAbsCocRadius - _324.w) + _308)));
    }
  }
}