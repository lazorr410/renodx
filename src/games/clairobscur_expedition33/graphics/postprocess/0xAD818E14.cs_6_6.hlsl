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

SamplerState D3DStaticBilinearClampedSampler : register(s3, space1000);

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
  float _12;
  float _13;
  float _19;
  float _20;
  float4 _23;
  float _25;
  float _29;
  float _30;
  int _32;
  int _120;
  int _121;
  float _122;
  float _123;
  float _124;
  float _151;
  float _152;
  float _153;
  float _154;
  int _155;
  float _156;
  float _157;
  float _158;
  int _172;
  float _173;
  float _174;
  float _175;
  int _323;
  float _324;
  float _325;
  float _326;
  float _327;
  float _328;
  float _329;
  float _330;
  float _331;
  float _332;
  int _333;
  float _363;
  float _364;
  float _365;
  float _366;
  float _367;
  float _368;
  float _369;
  float _370;
  float _371;
  float _372;
  float _373;
  float _374;
  float _375;
  int _376;
  float _390;
  float _391;
  float _392;
  float _393;
  float _394;
  float _395;
  float _396;
  float _397;
  float _398;
  int _399;
  float _537;
  float _538;
  float _539;
  float _540;
  float _541;
  float _542;
  float _543;
  float _544;
  float _545;
  float _550;
  float _551;
  float _552;
  float _553;
  float _554;
  float _555;
  float _556;
  float _557;
  float _558;
  float _59;
  float _60;
  float _61;
  float _62;
  float _63;
  float _66;
  float _72;
  float _76;
  float _79;
  float _80;
  float _81;
  float _83;
  float _90;
  float _95;
  float _96;
  float _97;
  float _98;
  float _99;
  float _100;
  float _104;
  float _105;
  float _106;
  float _107;
  float4 _115;
  int _125;
  float _127;
  float _131;
  float _133;
  float _134;
  float _135;
  float _136;
  float _137;
  float _141;
  float _142;
  float _143;
  float _146;
  float _147;
  float _148;
  float _149;
  float _167;
  float _168;
  float _169;
  float _170;
  bool _176;
  float _186;
  float _187;
  float _188;
  float _189;
  float _192;
  float _193;
  float4 _202;
  float _209;
  float _210;
  float _213;
  float _214;
  float4 _221;
  float _225;
  float _226;
  float _227;
  int _228;
  int _231;
  float _238;
  uint _244;
  uint _245;
  float _267;
  float _268;
  float _269;
  float _270;
  float _271;
  float _272;
  float _273;
  float _276;
  float _277;
  float _278;
  float _279;
  float4 _287;
  float _293;
  bool _297;
  float _303;
  float _307;
  float _309;
  float _310;
  float _311;
  float _312;
  float _313;
  float _314;
  float _315;
  float _316;
  float _317;
  float _319;
  int _335;
  float _337;
  uint _340;
  float _341;
  float _343;
  float _344;
  float _345;
  float _346;
  float _347;
  float _351;
  float _352;
  float _353;
  float _356;
  float _357;
  float _358;
  float _359;
  float _385;
  float _386;
  float _387;
  float _388;
  bool _400;
  float _410;
  float _411;
  float _412;
  float _413;
  float _416;
  float _417;
  float4 _426;
  float _436;
  float _437;
  float _440;
  float _441;
  float4 _448;
  bool _470;
  float _471;
  float _473;
  bool _474;
  float _475;
  float _477;
  float _478;
  float _482;
  float _486;
  float _487;
  float _489;
  float _497;
  float _505;
  float _510;
  float _511;
  float _512;
  float _517;
  float _521;
  float _522;
  float _523;
  float _528;
  float _529;
  int _530;
  int _533;
  float _570;
  float _574;
  float _577;
  float _580;
  float _581;
  float _582;
  float _583;
  float _587;
  uint _593;
  uint _594;
  int __loop_jump_target = -1;
  _12 = float((uint)SV_DispatchThreadID.x);
  _13 = float((uint)SV_DispatchThreadID.y);
  _19 = DispatchThreadIdToInputBufferUV.x * (_12 + 0.5f);
  _20 = DispatchThreadIdToInputBufferUV.y * (_13 + 0.5f);
  _23 = TileClassification_Foreground.Load(int3((int)(SV_GroupID.x), (int)(SV_GroupID.y), 0));
  _25 = -0.0f - _23.x;
  _29 = WaveReadLaneFirst(_23.x);
  _30 = WaveReadLaneFirst(_25);
  _32 = WaveReadLaneFirst(5);
  [branch]
  if (MinGatherRadius < _25) {
    // IS-FAST noise replacement for bokeh sampling jitter
    float _fast_radius_noise;
    float _fast_angle_noise;
    if (InjectionToggle(TOGGLE_USE_ISFAST_DOF)) {
      uint _fast_slice = (((uint)_12 ^ ((uint)_13 * 7u)) + (uint)float(InjectionFrameIndex())) % 32u;
      float2 _fast_n = FastNoiseLoad((uint)_12 % 128u, (uint)_13 % 128u, _fast_slice);
      // UniformCircle disk texture: RG stores point on unit disk in [0,1] (encoded from [-1,1])
      float2 _disk_point = _fast_n * 2.0f - 1.0f;
      _fast_radius_noise = length(_disk_point) * 0.47999998927116394f;
      _fast_angle_noise = atan2(_disk_point.y, _disk_point.x);
    } else {
      _fast_radius_noise = sqrt(frac(frac(dot(float2(_12, _13), float2(0.0671105608344078f, 0.005837149918079376f))) * 52.98291778564453f)) * 0.47999998927116394f;
      _fast_angle_noise = frac(frac(dot(float2((_12 + 32.665000915527344f), (_13 + 11.8149995803833f)), float2(0.0671105608344078f, 0.005837149918079376f))) * 52.98291778564453f) * 6.2831854820251465f;
    }
    _59 = _fast_radius_noise;
    _60 = _fast_angle_noise;
    _61 = cos(_60);
    _62 = sin(_60);
    _63 = _30 * 0.1818181872367859f;
    _66 = floor(log2(_63) + 0.5f);
    _72 = exp2(float((uint)uint(_66)));
    _76 = _72 * 0.5f;
    _79 = (GatherInputViewportSize.x - _76) * GatherInputSize.z;
    _80 = (GatherInputViewportSize.y - _76) * GatherInputSize.w;
    _81 = 1.0f / _72;
    _83 = 1.0f - MaxRecombineAbsCocRadius;
    if ((_23.y - _23.x) < (_23.x * -0.05000000074505806f)) {
      _90 = max(((_30 + -5.0f) - _72), 0.0f) * 0.1818181872367859f;
      _95 = (((_59 * _61) * _90) * GatherInputSize.z) + _19;
      _96 = (((_62 * _59) * _90) * GatherInputSize.w) + _20;
      _97 = WaveReadLaneFirst(_63);
      _98 = WaveReadLaneFirst(_79);
      _99 = WaveReadLaneFirst(_80);
      _100 = WaveReadLaneFirst(_66);
      _104 = max(_95, (-0.0f - _95));
      _105 = max(_96, (-0.0f - _96));
      _106 = _98 * 2.0f;
      _107 = _99 * 2.0f;
      _115 = GatherInput_SceneColor.SampleLevel(D3DStaticBilinearClampedSampler, float2(min(min(_104, (_106 - _104)), _98), min(min(_105, (_107 - _105)), _99)), _100);
      _120 = 2;
      _121 = 0;
      _122 = _115.x;
      _123 = _115.y;
      _124 = _115.z;
      while(true) {
        _125 = _121 + 1;
        _127 = float((uint)_125) * _97;
        _131 = WaveReadLaneFirst(_127);
        _133 = float((uint)((uint)(((int)(_121 << 2)) + 4)));
        _134 = 3.1415927410125732f / _133;
        _135 = cos(_134);
        _136 = sin(_134);
        _137 = -0.0f - _136;
        _141 = (float((uint)((uint)(_121 & 1))) * 1.5707963705062866f) / _133;
        _142 = cos(_141);
        _143 = sin(_141);
        _146 = WaveReadLaneFirst(_142);
        _147 = WaveReadLaneFirst(_143);
        _148 = WaveReadLaneFirst(_142 * _131);
        _149 = WaveReadLaneFirst(_143 * _131);
        _151 = _146;
        _152 = _147;
        _153 = _148;
        _154 = _149;
        _155 = 0;
        _156 = _122;
        _157 = _123;
        _158 = _124;
        while(true) {
          _167 = WaveReadLaneFirst(mad(_152, _137, (_151 * _135)));
          _168 = WaveReadLaneFirst(mad(_152, _135, (_151 * _136)));
          _169 = WaveReadLaneFirst(mad(_154, _137, (_153 * _135)));
          _170 = WaveReadLaneFirst(mad(_154, _135, (_153 * _136)));
          _172 = 0;
          _173 = _156;
          _174 = _157;
          _175 = _158;
          while(true) {
            _176 = (_172 == 1);
            _186 = (CocInvSqueeze * select(_176, (-0.0f - _170), _169)) * GatherInputSize.z;
            _187 = GatherInputSize.w * select(_176, _169, _170);
            _188 = _186 + _95;
            _189 = _187 + _96;
            _192 = max(_188, (-0.0f - _188));
            _193 = max(_189, (-0.0f - _189));
            _202 = GatherInput_SceneColor.SampleLevel(D3DStaticBilinearClampedSampler, float2(min(min(_192, (_106 - _192)), _98), min(min(_193, (_107 - _193)), _99)), _100);
            _209 = _95 - _186;
            _210 = _96 - _187;
            _213 = max(_209, (-0.0f - _209));
            _214 = max(_210, (-0.0f - _210));
            _221 = GatherInput_SceneColor.SampleLevel(D3DStaticBilinearClampedSampler, float2(min(min(_213, (_106 - _213)), _98), min(min(_214, (_107 - _214)), _99)), _100);
            _225 = (_202.x + _173) + _221.x;
            _226 = (_202.y + _174) + _221.y;
            _227 = (_202.z + _175) + _221.z;
            _228 = _172 + 1;
            if (!(_228 == 2)) {
              _172 = _228;
              _173 = _225;
              _174 = _226;
              _175 = _227;
              continue;
            }
            _231 = _155 + 1;
            if (!(_231 == _120)) {
              _151 = _167;
              _152 = _168;
              _153 = _169;
              _154 = _170;
              _155 = _231;
              _156 = _225;
              _157 = _226;
              _158 = _227;
              __loop_jump_target = 150;
              break;
            }
            if (!(_125 == 5)) {
              _120 = (_120 + 2);
              _121 = _125;
              _122 = _225;
              _123 = _226;
              _124 = _227;
              __loop_jump_target = 119;
              break;
            }
            _238 = saturate(_83 + _30);
            _244 = uint(InputBufferUVToOutputPixel.x * _19);
            _245 = uint(InputBufferUVToOutputPixel.y * _20);
            if (!(((uint)_244 >= (uint)ViewportRect.z) || ((uint)_245 >= (uint)ViewportRect.w))) {
              ConvolutionOutput_SceneColor[int2(_244, _245)] = float4(((_225 * 0.00826446246355772f) * _238), ((_226 * 0.00826446246355772f) * _238), ((_227 * 0.00826446246355772f) * _238), _238);
            }
            break;
          }
          if (__loop_jump_target == 150) {
            __loop_jump_target = -1;
            continue;
          }
          if (__loop_jump_target != -1) {
            break;
          }
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
      _267 = (((_61 * _63) * _59) * GatherInputSize.z) + _19;
      _268 = (((_59 * _63) * _62) * GatherInputSize.w) + _20;
      _269 = WaveReadLaneFirst(_63);
      _270 = WaveReadLaneFirst(_79);
      _271 = WaveReadLaneFirst(_80);
      _272 = WaveReadLaneFirst(_66);
      _273 = WaveReadLaneFirst(_81);
      _276 = max(_267, (-0.0f - _267));
      _277 = max(_268, (-0.0f - _268));
      _278 = _270 * 2.0f;
      _279 = _271 * 2.0f;
      _287 = GatherInput_SceneColor.SampleLevel(D3DStaticPointClampedSampler, float2(min(min(_276, (_278 - _276)), _270), min(min(_277, (_279 - _277)), _271)), _272);
      _293 = saturate(_83 - _287.w);
      _297 = (_287.w < 0.0f);
      _303 = saturate(saturate((_287.w - _29) * 0.5f));
      _307 = (_303 * _303) * (3.0f - (_303 * 2.0f));
      _309 = (_293 * select(_297, _293, 0.0f)) * min((0.31830987334251404f / (_287.w * _287.w)), 5.092957973480225f);
      _310 = _309 * _307;
      _311 = _310 * _287.x;
      _312 = _310 * _287.y;
      _313 = _310 * _287.z;
      _314 = _309 * (1.0f - _307);
      _315 = _314 * _287.x;
      _316 = _314 * _287.y;
      _317 = _314 * _287.z;
      _319 = _293 * select(_297, 1.0f, 0.0f);
      if ((int)_32 > (int)0) {
        _323 = 4;
        _324 = _310;
        _325 = _314;
        _326 = _319;
        _327 = _317;
        _328 = _313;
        _329 = _316;
        _330 = _312;
        _331 = _315;
        _332 = _311;
        _333 = 0;
        while(true) {
          _537 = _324;
          _538 = _325;
          _539 = _326;
          _540 = _327;
          _541 = _328;
          _542 = _329;
          _543 = _330;
          _544 = _331;
          _545 = _332;
          _335 = _333 + 1;
          _337 = float((uint)_335) * _269;
          _340 = (_333 << 2) + 4u;
          _341 = WaveReadLaneFirst(_337);
          _343 = float((uint)_340);
          _344 = 3.1415927410125732f / _343;
          _345 = cos(_344);
          _346 = sin(_344);
          _347 = -0.0f - _346;
          _351 = (float((uint)((uint)(_333 & 1))) * 1.5707963705062866f) / _343;
          _352 = cos(_351);
          _353 = sin(_351);
          _356 = WaveReadLaneFirst(_352);
          _357 = WaveReadLaneFirst(_353);
          _358 = WaveReadLaneFirst(_352 * _341);
          _359 = WaveReadLaneFirst(_353 * _341);
          if (!(_340 == 0)) {
            _363 = _324;
            _364 = _325;
            _365 = _326;
            _366 = _327;
            _367 = _328;
            _368 = _329;
            _369 = _330;
            _370 = _331;
            _371 = _332;
            _372 = _356;
            _373 = _357;
            _374 = _358;
            _375 = _359;
            _376 = 0;
            while(true) {
              _385 = WaveReadLaneFirst(mad(_373, _347, (_372 * _345)));
              _386 = WaveReadLaneFirst(mad(_373, _345, (_372 * _346)));
              _387 = WaveReadLaneFirst(mad(_375, _347, (_374 * _345)));
              _388 = WaveReadLaneFirst(mad(_375, _345, (_374 * _346)));
              _390 = _363;
              _391 = _364;
              _392 = _365;
              _393 = _366;
              _394 = _367;
              _395 = _368;
              _396 = _369;
              _397 = _370;
              _398 = _371;
              _399 = 0;
              while(true) {
                _400 = (_399 == 1);
                _410 = (CocInvSqueeze * select(_400, (-0.0f - _388), _387)) * GatherInputSize.z;
                _411 = GatherInputSize.w * select(_400, _387, _388);
                _412 = _410 + _267;
                _413 = _411 + _268;
                _416 = max(_412, (-0.0f - _412));
                _417 = max(_413, (-0.0f - _413));
                _426 = GatherInput_SceneColor.SampleLevel(D3DStaticPointClampedSampler, float2(min(min(_416, (_278 - _416)), _270), min(min(_417, (_279 - _417)), _271)), _272);
                _436 = _267 - _410;
                _437 = _268 - _411;
                _440 = max(_436, (-0.0f - _436));
                _441 = max(_437, (-0.0f - _437));
                _448 = GatherInput_SceneColor.SampleLevel(D3DStaticPointClampedSampler, float2(min(min(_440, (_278 - _440)), _270), min(min(_441, (_279 - _441)), _271)), _272);
                _470 = (_448.w > _426.w);
                _471 = select(_470, min((0.31830987334251404f / (_426.w * _426.w)), 5.092957973480225f), min((0.31830987334251404f / (_448.w * _448.w)), 5.092957973480225f));
                _473 = select(_470, _426.w, _448.w);
                _474 = (_473 < 0.0f);
                _475 = select(_474, select(_470, (saturate(_83 - _426.w) * saturate(((abs(_426.w) - _341) * _273) + 0.5f)), (saturate(_83 - _448.w) * saturate(((abs(_448.w) - _341) * _273) + 0.5f))), 0.0f);
                _477 = saturate(_83 - _473);
                _478 = _475 * _477;
                _482 = saturate(saturate((_473 - _29) * 0.5f));
                _486 = (_482 * _482) * (3.0f - (_482 * 2.0f));
                _487 = 1.0f - _486;
                _489 = (_486 * _478) * _471;
                _497 = (_487 * _478) * _471;
                _505 = _477 * select(_474, 1.0f, 0.0f);
                _510 = ((_489 * _426.x) + _398) + (_489 * _448.x);
                _511 = ((_489 * _426.y) + _396) + (_489 * _448.y);
                _512 = ((_489 * _426.z) + _394) + (_489 * _448.z);
                _517 = ((_486 * (_475 * (_477 + _477))) * _471) + _390;
                _521 = ((_497 * _426.x) + _397) + (_497 * _448.x);
                _522 = ((_497 * _426.y) + _395) + (_497 * _448.y);
                _523 = ((_497 * _426.z) + _393) + (_497 * _448.z);
                _528 = ((_487 * (_475 * (_477 + _477))) * _471) + _391;
                _529 = (_505 + _392) + _505;
                _530 = _399 + 1;
                if (!(_530 == 2)) {
                  _390 = _517;
                  _391 = _528;
                  _392 = _529;
                  _393 = _523;
                  _394 = _512;
                  _395 = _522;
                  _396 = _511;
                  _397 = _521;
                  _398 = _510;
                  _399 = _530;
                  continue;
                }
                _533 = _376 + 1;
                if (!(_533 == ((uint)(_323) >> 1))) {
                  _363 = _517;
                  _364 = _528;
                  _365 = _529;
                  _366 = _523;
                  _367 = _512;
                  _368 = _522;
                  _369 = _511;
                  _370 = _521;
                  _371 = _510;
                  _372 = _385;
                  _373 = _386;
                  _374 = _387;
                  _375 = _388;
                  _376 = _533;
                  __loop_jump_target = 362;
                  break;
                }
                _537 = _517;
                _538 = _528;
                _539 = _529;
                _540 = _523;
                _541 = _512;
                _542 = _522;
                _543 = _511;
                _544 = _521;
                _545 = _510;
                break;
              }
              if (__loop_jump_target == 362) {
                __loop_jump_target = -1;
                continue;
              }
              if (__loop_jump_target != -1) {
                break;
              }
              break;
            }
          } else {
            _537 = _324;
            _538 = _325;
            _539 = _326;
            _540 = _327;
            _541 = _328;
            _542 = _329;
            _543 = _330;
            _544 = _331;
            _545 = _332;
          }
          if (!(_335 == _32)) {
            _323 = ((int)(_323 + 4u));
            _324 = _537;
            _325 = _538;
            _326 = _539;
            _327 = _540;
            _328 = _541;
            _329 = _542;
            _330 = _543;
            _331 = _544;
            _332 = _545;
            _333 = _335;
            continue;
          }
          _550 = _537;
          _551 = _538;
          _552 = _539;
          _553 = _540;
          _554 = _541;
          _555 = _542;
          _556 = _543;
          _557 = _544;
          _558 = _545;
          break;
        }
      } else {
        _550 = _310;
        _551 = _314;
        _552 = _319;
        _553 = _317;
        _554 = _313;
        _555 = _316;
        _556 = _312;
        _557 = _315;
        _558 = _311;
      }
      _570 = 1.0f / float((uint)((uint)(((int)(((int)(_32 << 2)) * ((int)(_32 + 1u)))) | 1)));
      _574 = saturate((((1.0f / min((0.26306599378585815f / (_30 * _30)), 5.092957973480225f)) * _551) * _570) + select((_550 == 0.0f), 1.0f, 0.0f));
      _577 = select((_551 > 0.0f), (1.0f / _551), 0.0f);
      _580 = select((_550 > 0.0f), (1.0f / _550), 0.0f);
      _581 = _580 * _558;
      _582 = _580 * _556;
      _583 = _580 * _554;
      _587 = select(((_551 + _550) > 0.0f), (_570 * _552), 0.0f);
      _593 = uint(InputBufferUVToOutputPixel.x * _19);
      _594 = uint(InputBufferUVToOutputPixel.y * _20);
      if (!(((uint)_593 >= (uint)ViewportRect.z) || ((uint)_594 >= (uint)ViewportRect.w))) {
        ConvolutionOutput_SceneColor[int2(_593, _594)] = float4((((((_577 * _557) - _581) * _574) + _581) * _587), (((((_577 * _555) - _582) * _574) + _582) * _587), (((((_577 * _553) - _583) * _574) + _583) * _587), _587);
      }
    }
  } else {
    if (!(((uint)(int)(SV_DispatchThreadID.x) >= (uint)ViewportRect.z) || ((uint)(int)(SV_DispatchThreadID.y) >= (uint)ViewportRect.w))) {
      ConvolutionOutput_SceneColor[int2((int)(SV_DispatchThreadID.x), (int)(SV_DispatchThreadID.y))] = float4(0.0f, 0.0f, 0.0f, 0.0f);
    }
  }
}
