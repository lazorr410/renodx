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

Buffer<float4> t0 : register(t0);

Buffer<float4> t1 : register(t1);

Texture3D<float4> t2 : register(t2);

Texture3D<float4> t3 : register(t3);

Texture3D<float4> t4 : register(t4);

Texture2D<float4> t5 : register(t5);

RWTexture2D<float3> u0 : register(u0);

RWTexture2D<float3> u1 : register(u1);

cbuffer cb0 : register(b0) {
  float cb0_013x : packoffset(c013.x);
};

cbuffer cb1 : register(b1) {
  uint4 cb1_raw[630];
};

cbuffer cb2 : register(b2) {
  int3 BlueNoise_000 : packoffset(c000.x);
  int BlueNoise_012 : packoffset(c000.w);
  int3 BlueNoise_016 : packoffset(c001.x);
  int BlueNoise_028 : packoffset(c001.w);
  int BlueNoise_032 : packoffset(c002.x);
  int BlueNoise_036 : packoffset(c002.y);
  int BlueNoise_040 : packoffset(c002.z);
  int BlueNoise_044 : packoffset(c002.w);
  int BlueNoise_048 : packoffset(c003.x);
};

cbuffer cb3 : register(b3) {
  float4 FogStruct_000 : packoffset(c000.x);
  float4 FogStruct_016 : packoffset(c001.x);
  float4 FogStruct_032 : packoffset(c002.x);
  float4 FogStruct_048 : packoffset(c003.x);
  float4 FogStruct_064 : packoffset(c004.x);
  float4 FogStruct_080 : packoffset(c005.x);
  float4 FogStruct_096 : packoffset(c006.x);
  float2 FogStruct_112 : packoffset(c007.x);
  float FogStruct_120 : packoffset(c007.z);
  float FogStruct_124 : packoffset(c007.w);
  float3 FogStruct_128 : packoffset(c008.x);
  float FogStruct_140 : packoffset(c008.w);
  float FogStruct_144 : packoffset(c009.x);
  float FogStruct_148 : packoffset(c009.y);
  float FogStruct_152 : packoffset(c009.z);
  float FogStruct_156 : packoffset(c009.w);
  float3 FogStruct_160 : packoffset(c010.x);
  float FogStruct_172 : packoffset(c010.w);
  float4 FogStruct_176 : packoffset(c011.x);
  float4 FogStruct_192 : packoffset(c012.x);
  float4 FogStruct_208 : packoffset(c013.x);
  float4 FogStruct_224 : packoffset(c014.x);
  float4 FogStruct_240 : packoffset(c015.x);
  float4 FogStruct_256 : packoffset(c016.x);
  int FogStruct_272 : packoffset(c017.x);
  int FogStruct_276 : packoffset(c017.y);
  int FogStruct_280 : packoffset(c017.z);
  int FogStruct_284 : packoffset(c017.w);
  int FogStruct_288 : packoffset(c018.x);
  int FogStruct_292 : packoffset(c018.y);
  int FogStruct_296 : packoffset(c018.z);
  int FogStruct_300 : packoffset(c018.w);
  int FogStruct_304 : packoffset(c019.x);
  int FogStruct_308 : packoffset(c019.y);
  int FogStruct_312 : packoffset(c019.z);
};

SamplerState s0 : register(s0);

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
  float _69;
  bool _226;
  bool _271;
  int _272;
  bool _317;
  int _318;
  int _364;
  bool _493;
  int _494;
  bool _539;
  int _540;
  int _586;
  float _651;
  int _652;
  float _766;
  float _894;
  float _895;
  float _982;
  float _983;
  float _1070;
  float _1071;
  float _1143;
  float _1182;
  float _1183;
  float _1205;
  float _1206;
  float _1207;
  float _1208;
  float _1209;
  float _1210;
  float _35;
  float _36;
  float _40;
  float _54;
  float _105;
  float _106;
  float _107;
  float _108;
  float _112;
  float _123;
  float _124;
  float _125;
  float _126;
  float _127;
  float _128;
  float _141;
  float _142;
  float _143;
  float _156;
  float _157;
  float _158;
  float _159;
  float _160;
  float _161;
  float _168;
  float _169;
  float _170;
  float _171;
  float _172;
  float _173;
  float _180;
  float _181;
  float _182;
  float _210;
  bool _220;
  float _255;
  float _301;
  float _347;
  float4 _369;
  float _373;
  float _376;
  float4 _401;
  float _430;
  float _442;
  float _477;
  float _523;
  float _569;
  int _588;
  float _593;
  float _594;
  float _595;
  float _596;
  float _605;
  float _606;
  float _615;
  float _616;
  float _617;
  float _618;
  float _623;
  float _624;
  float _625;
  float _626;
  float _639;
  float _640;
  float4 _642;
  int _647;
  int _659;
  float4 _661;
  float4 _667;
  float _670;
  float _679;
  float _680;
  float _689;
  float _690;
  float _691;
  float _692;
  float _693;
  float _694;
  float _703;
  float _704;
  float _711;
  float _712;
  float _713;
  float _714;
  float _715;
  float _716;
  float _721;
  float _722;
  float _723;
  float _724;
  float _737;
  float _738;
  float _745;
  float _748;
  float _749;
  float _761;
  float _770;
  float _773;
  float _774;
  float _777;
  float _788;
  float _789;
  float _790;
  float _791;
  bool _802;
  float _803;
  float _804;
  float _805;
  float _806;
  float _808;
  float _809;
  bool _811;
  float _812;
  float _813;
  float _822;
  float _823;
  float _824;
  float _825;
  float _826;
  float _827;
  float _836;
  float _837;
  float _838;
  float _839;
  float _844;
  float _845;
  float _846;
  float _847;
  float _860;
  float _861;
  float _867;
  float _868;
  float _869;
  float _872;
  float _873;
  float _882;
  float _884;
  float _885;
  float _889;
  float _899;
  float _910;
  float _911;
  float _912;
  float _913;
  float _914;
  float _915;
  float _924;
  float _925;
  float _926;
  float _927;
  float _932;
  float _933;
  float _934;
  float _935;
  float _948;
  float _949;
  float _955;
  float _956;
  float _957;
  float _960;
  float _961;
  float _970;
  float _972;
  float _973;
  float _977;
  float _987;
  float _998;
  float _999;
  float _1000;
  float _1001;
  float _1002;
  float _1003;
  float _1012;
  float _1013;
  float _1014;
  float _1015;
  float _1020;
  float _1021;
  float _1022;
  float _1023;
  float _1036;
  float _1037;
  float _1043;
  float _1044;
  float _1045;
  float _1048;
  float _1049;
  float _1058;
  float _1060;
  float _1061;
  float _1065;
  float _1075;
  float _1078;
  float _1079;
  float _1080;
  float _1082;
  float _1083;
  float _1084;
  float _1085;
  float _1088;
  float _1089;
  float _1090;
  float _1093;
  float _1096;
  float _1100;
  float _1104;
  float _1105;
  float _1106;
  float _1111;
  float _1117;
  float _1118;
  float _1123;
  float _1124;
  float _1132;
  float _1138;
  int _1139;
  float4 _1145;
  bool _1153;
  float _1156;
  float _1161;
  float _1171;
  float _1176;
  float _1187;
  float _1188;
  float4 _1195;
  float4 _1200;
  if (!(((uint)(int)(SV_DispatchThreadID.x) >= (uint)((uint)(uint(asfloat(cb1_raw[149u].x))) >> 1)) || ((uint)(int)(SV_DispatchThreadID.y) >= (uint)((uint)(uint(asfloat(cb1_raw[149u].y))) >> 1)))) {
    _35 = (float((uint)SV_DispatchThreadID.x) * 2.0f) + 1.0f;
    _36 = (float((uint)SV_DispatchThreadID.y) * 2.0f) + 1.0f;
    _40 = max((((float4)(t5.Load(int3((int)(SV_DispatchThreadID.x), (int)(SV_DispatchThreadID.y), 0)))).x), 1.000000045813705e-18f);
    _54 = min((((_40 * asfloat(cb1_raw[78u].x)) + asfloat(cb1_raw[78u].y)) + (1.0f / ((_40 * asfloat(cb1_raw[78u].z)) - asfloat(cb1_raw[78u].w)))), asfloat(cb1_raw[259u].x));
    [branch]
    if (!(asfloat(cb1_raw[31u].w) >= 1.0f)) {
      _69 = (1.0f / ((_54 + asfloat(cb1_raw[78u].w)) * asfloat(cb1_raw[78u].z)));
    } else {
      _69 = ((_54 * asfloat(cb1_raw[30u].z)) + asfloat(cb1_raw[31u].z));
    }
    _105 = mad(1.0f, asfloat(cb1_raw[47u].w), mad(_69, asfloat(cb1_raw[46u].w), mad(_36, asfloat(cb1_raw[45u].w), (_35 * asfloat(cb1_raw[44u].w)))));
    _106 = mad(1.0f, asfloat(cb1_raw[47u].x), mad(_69, asfloat(cb1_raw[46u].x), mad(_36, asfloat(cb1_raw[45u].x), (_35 * asfloat(cb1_raw[44u].x))))) / _105;
    _107 = mad(1.0f, asfloat(cb1_raw[47u].y), mad(_69, asfloat(cb1_raw[46u].y), mad(_36, asfloat(cb1_raw[45u].y), (_35 * asfloat(cb1_raw[44u].y))))) / _105;
    _108 = mad(1.0f, asfloat(cb1_raw[47u].z), mad(_69, asfloat(cb1_raw[46u].z), mad(_36, asfloat(cb1_raw[45u].z), (_35 * asfloat(cb1_raw[44u].z))))) / _105;
    _112 = (saturate(_54 / asfloat(cb1_raw[259u].x)) * 9900.0f) + 100.0f;
    _123 = _106 + asfloat(cb1_raw[84u].x);
    _124 = _107 + asfloat(cb1_raw[84u].y);
    _125 = _108 + asfloat(cb1_raw[84u].z);
    _126 = _123 - _106;
    _127 = _124 - _107;
    _128 = _125 - _108;
    _141 = asfloat(cb1_raw[85u].x) + 0.0f;
    _142 = asfloat(cb1_raw[85u].y) + 0.0f;
    _143 = asfloat(cb1_raw[85u].z) + 0.0f;
    _156 = _141 + ((asfloat(cb1_raw[84u].x) - _126) + (_106 - (_123 - _126)));
    _157 = _142 + ((asfloat(cb1_raw[84u].y) - _127) + (_107 - (_124 - _127)));
    _158 = _143 + ((asfloat(cb1_raw[84u].z) - _128) + (_108 - (_125 - _128)));
    _159 = _123 + _156;
    _160 = _124 + _157;
    _161 = _125 + _158;
    _168 = ((asfloat(cb1_raw[85u].x) - _141) + (0.0f - (_141 - _141))) + (_156 - (_159 - _123));
    _169 = ((asfloat(cb1_raw[85u].y) - _142) + (0.0f - (_142 - _142))) + (_157 - (_160 - _124));
    _170 = ((asfloat(cb1_raw[85u].z) - _143) + (0.0f - (_143 - _143))) + (_158 - (_161 - _125));
    _171 = _159 + _168;
    _172 = _160 + _169;
    _173 = _161 + _170;
    _180 = _171 + (_168 - (_171 - _159));
    _181 = _172 + (_169 - (_172 - _160));
    _182 = _173 + (_170 - (_173 - _161));
    _210 = mad(1.0f, asfloat(cb1_raw[352u].w), mad(_182, asfloat(cb1_raw[351u].w), mad(_181, asfloat(cb1_raw[350u].w), (asfloat(cb1_raw[349u].w) * _180))));
    _220 = (abs(mad(1.0f, asfloat(cb1_raw[352u].x), mad(_182, asfloat(cb1_raw[351u].x), mad(_181, asfloat(cb1_raw[350u].x), (asfloat(cb1_raw[349u].x) * _180)))) / _210) <= asfloat(cb1_raw[365u].x)) && (abs(mad(1.0f, asfloat(cb1_raw[352u].y), mad(_182, asfloat(cb1_raw[351u].y), mad(_181, asfloat(cb1_raw[350u].y), (asfloat(cb1_raw[349u].y) * _180)))) / _210) <= asfloat(cb1_raw[365u].y));
    if (_220) {
      _226 = (asfloat(cb1_raw[369u].x) > -3.4028234663852886e+38f);
    } else {
      _226 = false;
    }
    if (!_226) {
      _255 = mad(1.0f, asfloat(cb1_raw[356u].w), mad(_182, asfloat(cb1_raw[355u].w), mad(_181, asfloat(cb1_raw[354u].w), (_180 * asfloat(cb1_raw[353u].w)))));
      if ((abs(mad(1.0f, asfloat(cb1_raw[356u].x), mad(_182, asfloat(cb1_raw[355u].x), mad(_181, asfloat(cb1_raw[354u].x), (_180 * asfloat(cb1_raw[353u].x))))) / _255) <= asfloat(cb1_raw[366u].x)) && (abs(mad(1.0f, asfloat(cb1_raw[356u].y), mad(_182, asfloat(cb1_raw[355u].y), mad(_181, asfloat(cb1_raw[354u].y), (_180 * asfloat(cb1_raw[353u].y))))) / _255) <= asfloat(cb1_raw[366u].y))) {
        _271 = (asfloat(cb1_raw[370u].x) > -3.4028234663852886e+38f);
        _272 = 1;
      } else {
        _271 = false;
        _272 = 0;
      }
      if (!_271) {
        _301 = mad(1.0f, asfloat(cb1_raw[360u].w), mad(_182, asfloat(cb1_raw[359u].w), mad(_181, asfloat(cb1_raw[358u].w), (_180 * asfloat(cb1_raw[357u].w)))));
        if ((abs(mad(1.0f, asfloat(cb1_raw[360u].x), mad(_182, asfloat(cb1_raw[359u].x), mad(_181, asfloat(cb1_raw[358u].x), (_180 * asfloat(cb1_raw[357u].x))))) / _301) <= asfloat(cb1_raw[367u].x)) && (abs(mad(1.0f, asfloat(cb1_raw[360u].y), mad(_182, asfloat(cb1_raw[359u].y), mad(_181, asfloat(cb1_raw[358u].y), (_180 * asfloat(cb1_raw[357u].y))))) / _301) <= asfloat(cb1_raw[367u].y))) {
          _317 = (asfloat(cb1_raw[371u].x) > -3.4028234663852886e+38f);
          _318 = 2;
        } else {
          _317 = false;
          _318 = 0;
        }
        if (!_317) {
          _347 = mad(1.0f, asfloat(cb1_raw[364u].w), mad(_182, asfloat(cb1_raw[363u].w), mad(_181, asfloat(cb1_raw[362u].w), (_180 * asfloat(cb1_raw[361u].w)))));
          if ((abs(mad(1.0f, asfloat(cb1_raw[364u].x), mad(_182, asfloat(cb1_raw[363u].x), mad(_181, asfloat(cb1_raw[362u].x), (_180 * asfloat(cb1_raw[361u].x))))) / _347) <= asfloat(cb1_raw[368u].x)) && (abs(mad(1.0f, asfloat(cb1_raw[364u].y), mad(_182, asfloat(cb1_raw[363u].y), mad(_181, asfloat(cb1_raw[362u].y), (_180 * asfloat(cb1_raw[361u].y))))) / _347) <= asfloat(cb1_raw[368u].y))) {
            _364 = select((asfloat(cb1_raw[372u].x) > -3.4028234663852886e+38f), 3, -1);
          } else {
            _364 = -1;
          }
        } else {
          _364 = _318;
        }
      } else {
        _364 = _272;
      }
    } else {
      _364 = 0;
    }
    _369 = asfloat(cb1_raw[(int)(select((_364 == -1), 369, ((int)(_364 + 369u))))]);
    _373 = abs((_108 - (asfloat(cb1_raw[84u].z) + asfloat(cb1_raw[85u].z))) - _369.x) - _112;
    _376 = saturate(abs(_373 / _112));
    if (InjectionToggle(TOGGLE_USE_ISFAST_FOG)) {
      // IS-FAST: 128x128x32 spatiotemporally optimized noise (32 temporal phases vs original 8)
      uint _fast_slice = InjectionFrameIndex();
      float2 _fast_xy = FastNoiseLoad(
          SV_DispatchThreadID.x % 128u,
          SV_DispatchThreadID.y % 128u,
          _fast_slice);
      float _fast_z = FastNoiseLoad(
          (SV_DispatchThreadID.x ^ SV_DispatchThreadID.y) % 128u,
          SV_DispatchThreadID.y % 128u,
          (_fast_slice + 16u) % 32u).x;
      _401 = float4(_fast_xy.x, _fast_xy.y, _fast_z, 0.0);
    } else {
      _401 = t2.Load(int4((BlueNoise_016.x & (int)(uint(_35))), (BlueNoise_016.y & (int)(uint(_36))), (BlueNoise_016.z & asint(cb1_raw[165u].z)), 0));
    }
    _430 = (asfloat(cb1_raw[253u].z) * log2(max(((asfloat(cb1_raw[253u].x) * min((_54 - ((_401.z * 8.0f) * cb0_013x)), asfloat(cb1_raw[259u].x))) + asfloat(cb1_raw[253u].y)), 9.99999993922529e-09f))) * asfloat(cb1_raw[252u].z);
    _442 = ((((cb0_013x * (1.0f - _376)) * ((_401.y * 2.0f) + -1.0f)) + _36) - asfloat(cb1_raw[148u].y)) * asfloat(cb1_raw[254u].y);
    if (_373 < 0.0f) {
      if (!(_220 && (asfloat(cb1_raw[369u].x) > -3.4028234663852886e+38f))) {
        _477 = mad(1.0f, asfloat(cb1_raw[356u].w), mad(_182, asfloat(cb1_raw[355u].w), mad(_181, asfloat(cb1_raw[354u].w), (_180 * asfloat(cb1_raw[353u].w)))));
        if ((abs(mad(1.0f, asfloat(cb1_raw[356u].x), mad(_182, asfloat(cb1_raw[355u].x), mad(_181, asfloat(cb1_raw[354u].x), (_180 * asfloat(cb1_raw[353u].x))))) / _477) <= asfloat(cb1_raw[366u].x)) && (abs(mad(1.0f, asfloat(cb1_raw[356u].y), mad(_182, asfloat(cb1_raw[355u].y), mad(_181, asfloat(cb1_raw[354u].y), (_180 * asfloat(cb1_raw[353u].y))))) / _477) <= asfloat(cb1_raw[366u].y))) {
          _493 = (asfloat(cb1_raw[370u].x) > -3.4028234663852886e+38f);
          _494 = 1;
        } else {
          _493 = false;
          _494 = 0;
        }
        if (!_493) {
          _523 = mad(1.0f, asfloat(cb1_raw[360u].w), mad(_182, asfloat(cb1_raw[359u].w), mad(_181, asfloat(cb1_raw[358u].w), (_180 * asfloat(cb1_raw[357u].w)))));
          if ((abs(mad(1.0f, asfloat(cb1_raw[360u].x), mad(_182, asfloat(cb1_raw[359u].x), mad(_181, asfloat(cb1_raw[358u].x), (_180 * asfloat(cb1_raw[357u].x))))) / _523) <= asfloat(cb1_raw[367u].x)) && (abs(mad(1.0f, asfloat(cb1_raw[360u].y), mad(_182, asfloat(cb1_raw[359u].y), mad(_181, asfloat(cb1_raw[358u].y), (_180 * asfloat(cb1_raw[357u].y))))) / _523) <= asfloat(cb1_raw[367u].y))) {
            _539 = (asfloat(cb1_raw[371u].x) > -3.4028234663852886e+38f);
            _540 = 2;
          } else {
            _539 = false;
            _540 = 0;
          }
          if (!_539) {
            _569 = mad(1.0f, asfloat(cb1_raw[364u].w), mad(_182, asfloat(cb1_raw[363u].w), mad(_181, asfloat(cb1_raw[362u].w), (_180 * asfloat(cb1_raw[361u].w)))));
            if ((abs(mad(1.0f, asfloat(cb1_raw[364u].x), mad(_182, asfloat(cb1_raw[363u].x), mad(_181, asfloat(cb1_raw[362u].x), (_180 * asfloat(cb1_raw[361u].x))))) / _569) <= asfloat(cb1_raw[368u].x)) && (abs(mad(1.0f, asfloat(cb1_raw[364u].y), mad(_182, asfloat(cb1_raw[363u].y), mad(_181, asfloat(cb1_raw[362u].y), (_180 * asfloat(cb1_raw[361u].y))))) / _569) <= asfloat(cb1_raw[368u].y))) {
              _586 = select((asfloat(cb1_raw[372u].x) > -3.4028234663852886e+38f), 3, -1);
            } else {
              _586 = -1;
            }
          } else {
            _586 = _540;
          }
        } else {
          _586 = _494;
        }
      } else {
        _586 = 0;
      }
      _588 = select((_586 == -1), 0, _586);
      _593 = _106 - asfloat(cb1_raw[84u].x);
      _594 = _107 - asfloat(cb1_raw[84u].y);
      _595 = _593 - _106;
      _596 = _594 - _107;
      _605 = 0.0f - asfloat(cb1_raw[85u].x);
      _606 = 0.0f - asfloat(cb1_raw[85u].y);
      _615 = _605 + (((-0.0f - asfloat(cb1_raw[84u].x)) - _595) + (_106 - (_593 - _595)));
      _616 = _606 + (((-0.0f - asfloat(cb1_raw[84u].y)) - _596) + (_107 - (_594 - _596)));
      _617 = _593 + _615;
      _618 = _594 + _616;
      _623 = (((-0.0f - asfloat(cb1_raw[85u].x)) - _605) + (0.0f - (_605 - _605))) + (_615 - (_617 - _593));
      _624 = (((-0.0f - asfloat(cb1_raw[85u].y)) - _606) + (0.0f - (_606 - _606))) + (_616 - (_618 - _594));
      _625 = _617 + _623;
      _626 = _618 + _624;
      _639 = mad(floor((_625 * 4.76837158203125e-07f) + 0.5f), -2097152.0f, _625) + (_623 - (_625 - _617));
      _640 = mad(floor((_626 * 4.76837158203125e-07f) + 0.5f), -2097152.0f, _626) + (_624 - (_626 - _618));
      _642 = t0.Load(_588 << 1);
      _647 = min((int)(int(_642.z)), (int)(64));
      if ((int)_647 > (int)0) {
        _651 = 0.0f;
        _652 = 0;
        while(true) {
          _659 = int(((float4)(t1.Load(0))).y) + ((_652 + int(_642.y)) << 2);
          _661 = t1.Load(_659 + 2);
          _667 = t1.Load(_659 + 3);
          _670 = asfloat(cb1_raw[163u].w) * _661.w;
          _679 = mad(floor((_639 * 4.76837158203125e-07f) + 0.5f), -2097152.0f, _639) + 0.0f;
          _680 = mad(floor((_640 * 4.76837158203125e-07f) + 0.5f), -2097152.0f, _640) + 0.0f;
          _689 = -0.0f - asfloat(cb1_raw[72u].x);
          _690 = -0.0f - asfloat(cb1_raw[72u].y);
          _691 = _639 - asfloat(cb1_raw[72u].x);
          _692 = _640 - asfloat(cb1_raw[72u].y);
          _693 = _691 - _639;
          _694 = _692 - _640;
          _703 = 0.0f - asfloat(cb1_raw[80u].x);
          _704 = 0.0f - asfloat(cb1_raw[80u].y);
          _711 = ((-0.0f - asfloat(cb1_raw[80u].x)) - _703) + (0.0f - (_703 - _703));
          _712 = ((-0.0f - asfloat(cb1_raw[80u].y)) - _704) + (0.0f - (_704 - _704));
          _713 = _703 + ((_689 - _693) + (_639 - (_691 - _693)));
          _714 = _704 + ((_690 - _694) + (_640 - (_692 - _694)));
          _715 = _691 + _713;
          _716 = _692 + _714;
          _721 = _711 + (_713 - (_715 - _691));
          _722 = _712 + (_714 - (_716 - _692));
          _723 = _715 + _721;
          _724 = _716 + _722;
          _737 = mad(floor((_723 * 4.76837158203125e-07f) + 0.5f), -2097152.0f, _723) + (_721 - (_723 - _715));
          _738 = mad(floor((_724 * 4.76837158203125e-07f) + 0.5f), -2097152.0f, _724) + (_722 - (_724 - _716));
          _745 = sin(dot(float2(_679, _680), float2(_667.x, _667.y)) - _670);
          _748 = 1048576.0f - abs(_679);
          _749 = 1048576.0f - abs(_680);
          if ((_748 < 400.0f) || (_749 < 400.0f)) {
            _761 = sin(dot(float2(_748, _749), float2(_667.x, _667.y)) - _670);
            _766 = (_761 + ((saturate(_748 / 400.0f) * saturate(_749 / 400.0f)) * (_745 - _761)));
          } else {
            _766 = _745;
          }
          _770 = saturate(sqrt((_737 * _737) + (_738 * _738)) * 0.0020000000949949026f);
          _773 = _639 - ((_661.x * _766) * _770);
          _774 = _640 - ((_661.y * _766) * _770);
          _777 = asfloat(cb1_raw[555u].w) * 0.015625f;
          _788 = _777 * floor(_773 / _777);
          _789 = _777 * floor(_774 / _777);
          _790 = _777 + _788;
          _791 = _777 + _789;
          _802 = ((((int)(uint(floor((_788 - (asfloat(cb1_raw[555u].w) * floor(_773 / asfloat(cb1_raw[555u].w)))) / _777))) ^ (int)(uint(floor((_789 - (asfloat(cb1_raw[555u].w) * floor(_774 / asfloat(cb1_raw[555u].w)))) / _777)))) & 1) == 0);
          _803 = select(_802, _788, _790);
          _804 = select(_802, _790, _788);
          _805 = _773 - _804;
          _806 = _774 - _789;
          _808 = _773 - _803;
          _809 = _774 - _791;
          _811 = (dot(float2(_805, _806), float2(_805, _806)) < dot(float2(_808, _809), float2(_808, _809)));
          _812 = select(_811, _804, _803);
          _813 = select(_811, _789, _791);
          _822 = mad(floor((_803 * 4.76837158203125e-07f) + 0.5f), -2097152.0f, _803) + 0.0f;
          _823 = mad(floor((_789 * 4.76837158203125e-07f) + 0.5f), -2097152.0f, _789) + 0.0f;
          _824 = _803 - asfloat(cb1_raw[72u].x);
          _825 = _789 - asfloat(cb1_raw[72u].y);
          _826 = _824 - _803;
          _827 = _825 - _789;
          _836 = _703 + ((_689 - _826) + (_803 - (_824 - _826)));
          _837 = _704 + ((_690 - _827) + (_789 - (_825 - _827)));
          _838 = _824 + _836;
          _839 = _825 + _837;
          _844 = _711 + (_836 - (_838 - _824));
          _845 = _712 + (_837 - (_839 - _825));
          _846 = _838 + _844;
          _847 = _839 + _845;
          _860 = mad(floor((_846 * 4.76837158203125e-07f) + 0.5f), -2097152.0f, _846) + (_844 - (_846 - _838));
          _861 = mad(floor((_847 * 4.76837158203125e-07f) + 0.5f), -2097152.0f, _847) + (_845 - (_847 - _839));
          _867 = dot(float2(_822, _823), float2(_667.x, _667.y)) - _670;
          _868 = sin(_867);
          _869 = cos(_867);
          _872 = 1048576.0f - abs(_822);
          _873 = 1048576.0f - abs(_823);
          if ((_872 < 400.0f) || (_873 < 400.0f)) {
            _882 = saturate(_873 * 0.0024999999441206455f) * saturate(_872 * 0.0024999999441206455f);
            _884 = dot(float2(_872, _873), float2(_667.x, _667.y)) - _670;
            _885 = sin(_884);
            _889 = cos(_884);
            _894 = (lerp(_885, _868, _882));
            _895 = (lerp(_889, _869, _882));
          } else {
            _894 = _868;
            _895 = _869;
          }
          _899 = saturate(sqrt((_860 * _860) + (_861 * _861)) * 0.0020000000949949026f);
          _910 = mad(floor((_804 * 4.76837158203125e-07f) + 0.5f), -2097152.0f, _804) + 0.0f;
          _911 = mad(floor((_791 * 4.76837158203125e-07f) + 0.5f), -2097152.0f, _791) + 0.0f;
          _912 = _804 - asfloat(cb1_raw[72u].x);
          _913 = _791 - asfloat(cb1_raw[72u].y);
          _914 = _912 - _804;
          _915 = _913 - _791;
          _924 = _703 + ((_689 - _914) + (_804 - (_912 - _914)));
          _925 = _704 + ((_690 - _915) + (_791 - (_913 - _915)));
          _926 = _912 + _924;
          _927 = _913 + _925;
          _932 = _711 + (_924 - (_926 - _912));
          _933 = _712 + (_925 - (_927 - _913));
          _934 = _926 + _932;
          _935 = _927 + _933;
          _948 = mad(floor((_934 * 4.76837158203125e-07f) + 0.5f), -2097152.0f, _934) + (_932 - (_934 - _926));
          _949 = mad(floor((_935 * 4.76837158203125e-07f) + 0.5f), -2097152.0f, _935) + (_933 - (_935 - _927));
          _955 = dot(float2(_910, _911), float2(_667.x, _667.y)) - _670;
          _956 = sin(_955);
          _957 = cos(_955);
          _960 = 1048576.0f - abs(_910);
          _961 = 1048576.0f - abs(_911);
          if ((_960 < 400.0f) || (_961 < 400.0f)) {
            _970 = saturate(_961 * 0.0024999999441206455f) * saturate(_960 * 0.0024999999441206455f);
            _972 = dot(float2(_960, _961), float2(_667.x, _667.y)) - _670;
            _973 = sin(_972);
            _977 = cos(_972);
            _982 = (lerp(_973, _956, _970));
            _983 = (lerp(_977, _957, _970));
          } else {
            _982 = _956;
            _983 = _957;
          }
          _987 = saturate(sqrt((_948 * _948) + (_949 * _949)) * 0.0020000000949949026f);
          _998 = mad(floor((_812 * 4.76837158203125e-07f) + 0.5f), -2097152.0f, _812) + 0.0f;
          _999 = mad(floor((_813 * 4.76837158203125e-07f) + 0.5f), -2097152.0f, _813) + 0.0f;
          _1000 = _812 - asfloat(cb1_raw[72u].x);
          _1001 = _813 - asfloat(cb1_raw[72u].y);
          _1002 = _1000 - _812;
          _1003 = _1001 - _813;
          _1012 = _703 + ((_689 - _1002) + (_812 - (_1000 - _1002)));
          _1013 = _704 + ((_690 - _1003) + (_813 - (_1001 - _1003)));
          _1014 = _1000 + _1012;
          _1015 = _1001 + _1013;
          _1020 = _711 + (_1012 - (_1014 - _1000));
          _1021 = _712 + (_1013 - (_1015 - _1001));
          _1022 = _1014 + _1020;
          _1023 = _1015 + _1021;
          _1036 = mad(floor((_1022 * 4.76837158203125e-07f) + 0.5f), -2097152.0f, _1022) + (_1020 - (_1022 - _1014));
          _1037 = mad(floor((_1023 * 4.76837158203125e-07f) + 0.5f), -2097152.0f, _1023) + (_1021 - (_1023 - _1015));
          _1043 = dot(float2(_998, _999), float2(_667.x, _667.y)) - _670;
          _1044 = sin(_1043);
          _1045 = cos(_1043);
          _1048 = 1048576.0f - abs(_998);
          _1049 = 1048576.0f - abs(_999);
          if ((_1048 < 400.0f) || (_1049 < 400.0f)) {
            _1058 = saturate(_1049 * 0.0024999999441206455f) * saturate(_1048 * 0.0024999999441206455f);
            _1060 = dot(float2(_1048, _1049), float2(_667.x, _667.y)) - _670;
            _1061 = sin(_1060);
            _1065 = cos(_1060);
            _1070 = (lerp(_1061, _1044, _1058));
            _1071 = (lerp(_1065, _1045, _1058));
          } else {
            _1070 = _1044;
            _1071 = _1045;
          }
          _1075 = saturate(sqrt((_1036 * _1036) + (_1037 * _1037)) * 0.0020000000949949026f);
          _1078 = ((_894 * _661.x) * _899) + _803;
          _1079 = ((_894 * _661.y) * _899) + _789;
          _1080 = ((_982 * _661.x) * _987) + _804;
          _1082 = ((_1070 * _661.x) * _1075) + _812;
          _1083 = ((_1070 * _661.y) * _1075) + _813;
          _1084 = _640 - _1083;
          _1085 = _1082 - _639;
          _1088 = (_1084 * _1082) + (_1085 * _1083);
          _1089 = (((_982 * _661.y) * _987) + _791) - _1079;
          _1090 = _1078 - _1080;
          _1093 = (_1089 * _1078) + (_1090 * _1079);
          _1096 = (_1084 * _1090) - (_1085 * _1089);
          _1100 = ((_1088 * _1090) - (_1085 * _1093)) / _1096;
          _1104 = ((_1084 * _1093) - (_1088 * _1089)) / _1096;
          _1105 = _1100 - _1078;
          _1106 = _1104 - _1079;
          _1111 = _1080 - _1078;
          _1117 = _639 - _1100;
          _1118 = _640 - _1104;
          _1123 = _1082 - _1100;
          _1124 = _1083 - _1104;
          _1132 = ((sqrt((_1106 * _1106) + (_1105 * _1105)) / sqrt((_1111 * _1111) + (_1089 * _1089))) * (_983 - _895)) + _895;
          _1138 = ((_1132 * _661.z) + _651) + ((_661.z * (_1071 - _1132)) * (sqrt((_1118 * _1118) + (_1117 * _1117)) / sqrt((_1123 * _1123) + (_1124 * _1124))));
          _1139 = _652 + 1;
          if (!(_1139 == _647)) {
            _651 = _1138;
            _652 = _1139;
            continue;
          }
          _1143 = _1138;
          break;
        }
      } else {
        _1143 = 0.0f;
      }
      _1145 = asfloat(cb1_raw[((int)(_588 + 369))]);
      _1153 = (_108 > -0.0f) && (((((_108 - asfloat(cb1_raw[84u].z)) - asfloat(cb1_raw[85u].z)) - _1143) - _1145.x) > 0.0f);
      _1156 = abs(asfloat(cb1_raw[73u].z));
      _1161 = (1.5707963705062866f - (_1156 * 0.1565829962491989f)) * sqrt(1.0f - _1156);
      _1171 = (8.742277657347586e-08f - (saturate(abs(select((asfloat(cb1_raw[73u].z) >= 0.0f), _1161, (3.1415927410125732f - _1161)) * 0.6366197466850281f)) * 8.742277657347586e-08f)) * asfloat(cb1_raw[252u].z);
      _1176 = (1.0f - saturate(abs((asfloat(cb1_raw[369u].x) - asfloat(cb1_raw[72u].z)) - asfloat(cb1_raw[80u].z)) * 0.0020000000949949026f)) * _376;
      _1182 = ((_1176 * select(_1153, (asfloat(cb1_raw[252u].y) * -2.0f), asfloat(cb1_raw[252u].y))) + _442);
      _1183 = ((_1176 * select(_1153, (_1171 * -2.0f), _1171)) + _430);
    } else {
      _1182 = _442;
      _1183 = _430;
    }
    _1187 = min(((((((_401.x * 2.0f) + -1.0f) * cb0_013x) + _35) - asfloat(cb1_raw[148u].x)) * asfloat(cb1_raw[254u].x)), asfloat(cb1_raw[258u].z));
    _1188 = min(_1182, asfloat(cb1_raw[258u].w));
    if (FogStruct_144 > 0.0f) {
      _1195 = t3.SampleLevel(s0, float3(_1187, _1188, _1183), 0.0f);
      _1200 = t4.SampleLevel(s0, float3(_1187, _1188, _1183), 0.0f);
      _1205 = _1195.x;
      _1206 = _1195.y;
      _1207 = _1195.z;
      _1208 = _1200.x;
      _1209 = _1200.y;
      _1210 = _1200.z;
    } else {
      _1205 = 0.0f;
      _1206 = 0.0f;
      _1207 = 0.0f;
      _1208 = 1.0f;
      _1209 = 1.0f;
      _1210 = 1.0f;
    }
    u0[int2((int)(SV_DispatchThreadID.x), (int)(SV_DispatchThreadID.y))] = float3(_1205, _1206, _1207);
    u1[int2((int)(SV_DispatchThreadID.x), (int)(SV_DispatchThreadID.y))] = float3(_1208, _1209, _1210);
  }
}