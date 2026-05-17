// ReflectionGenerateRaysCS — Subnautica 2 (0xC55C32A6)
// Modifications:
//   - IS-FAST noise replaces BlueNoise Vec2 (GGX VNDF sampling)
//   - IS-FAST noise replaces BlueNoise Scalar (roughness-to-distance jitter)
//   - LEAN sub-pixel lobe widening (Olano-Baker 2010)
//   - IGN clipmap threshold left untouched (unsafe to replace)

#include "../shared.h"

// IS-FAST noise: 128x128x32 RG8_UNORM source, decoded into float2 elements.
// Bound as a ByteAddressBuffer (D3D12 root SRV) instead of a typed texture
// to avoid forcing ReShade's descriptor-heap swap. See
// project-docs/011_buffer-srv-injection-no-heap-swap/.
ByteAddressBuffer ISFASTNoise : register(t0, space50);

// Flat-index helper: emulate Texture2DArray.Load(int4(x, y, slice, 0))
// over a ByteAddressBuffer with shape [SLICES][HEIGHT][WIDTH] in row-major.
// Each element is a float2 (8 bytes). asfloat() reinterprets the raw uint2
// load as the original normalized [0,1] floats from the C++ upload.
static const uint FAST_NOISE_W = 128u;
static const uint FAST_NOISE_H = 128u;
static const uint FAST_NOISE_SLICE_TEXELS = FAST_NOISE_W * FAST_NOISE_H;
static const uint FAST_NOISE_ELEMENT_BYTES = 8u;  // sizeof(float2)
static float2 ISFASTNoiseLoad(uint x, uint y, uint slice) {
  uint flat_index = slice * FAST_NOISE_SLICE_TEXELS + y * FAST_NOISE_W + x;
  uint byte_offset = flat_index * FAST_NOISE_ELEMENT_BYTES;
  return asfloat(ISFASTNoise.Load2(byte_offset));
}

Texture2D<float4> t0 : register(t0);

Texture2D<float4> t1 : register(t1);

Texture2D<float4> t2 : register(t2);

Texture2D<float4> t3 : register(t3);

Texture2D<float4> t4 : register(t4);

Texture2D<float4> t5 : register(t5);

Texture2D<float4> t6 : register(t6);

Buffer<uint> t7 : register(t7);

Texture3D<uint> t8 : register(t8);

RWTexture2DArray<float> u0 : register(u0);

RWTexture2DArray<uint> u1 : register(u1);

RWTexture2DArray<float4> u2 : register(u2);

cbuffer cb0 : register(b0) {
  uint4 cb0_raw[51];
};

cbuffer cb1 : register(b1) {
  float4 View_000[4] : packoffset(c000.x);
  float4 View_064[4] : packoffset(c004.x);
  float4 View_128[4] : packoffset(c008.x);
  float4 View_192[4] : packoffset(c012.x);
  float4 View_256[4] : packoffset(c016.x);
  float4 View_320[4] : packoffset(c020.x);
  float4 View_384[4] : packoffset(c024.x);
  float4 View_448[4] : packoffset(c028.x);
  float4 View_512[4] : packoffset(c032.x);
  float4 View_576[4] : packoffset(c036.x);
  float4 View_640[4] : packoffset(c040.x);
  float4 View_704[4] : packoffset(c044.x);
  float4 View_768[4] : packoffset(c048.x);
  float4 View_832[4] : packoffset(c052.x);
  float4 View_896[4] : packoffset(c056.x);
  float4 View_960[4] : packoffset(c060.x);
  float4 View_1024[4] : packoffset(c064.x);
  float4 View_1088[4] : packoffset(c068.x);
  float3 View_1152 : packoffset(c072.x);
  float View_1164 : packoffset(c072.w);
  float3 View_1168 : packoffset(c073.x);
  float View_1180 : packoffset(c073.w);
  float3 View_1184 : packoffset(c074.x);
  float View_1196 : packoffset(c074.w);
  float3 View_1200 : packoffset(c075.x);
  float View_1212 : packoffset(c075.w);
  float3 View_1216 : packoffset(c076.x);
  float View_1228 : packoffset(c076.w);
  float3 View_1232 : packoffset(c077.x);
  float View_1244 : packoffset(c077.w);
  float4 View_1248 : packoffset(c078.x);
  float4 View_1264 : packoffset(c079.x);
  float3 View_1280 : packoffset(c080.x);
  float View_1292 : packoffset(c080.w);
  float3 View_1296 : packoffset(c081.x);
  float View_1308 : packoffset(c081.w);
  float3 View_1312 : packoffset(c082.x);
  float View_1324 : packoffset(c082.w);
  float3 View_1328 : packoffset(c083.x);
  float View_1340 : packoffset(c083.w);
  float3 View_1344 : packoffset(c084.x);
  float View_1356 : packoffset(c084.w);
  float3 View_1360 : packoffset(c085.x);
  float View_1372 : packoffset(c085.w);
  float4 View_1376[4] : packoffset(c086.x);
  float4 View_1440[4] : packoffset(c090.x);
  float4 View_1504[4] : packoffset(c094.x);
  float4 View_1568[4] : packoffset(c098.x);
  float4 View_1632[4] : packoffset(c102.x);
  float4 View_1696[4] : packoffset(c106.x);
  float4 View_1760[4] : packoffset(c110.x);
  float3 View_1824 : packoffset(c114.x);
  float View_1836 : packoffset(c114.w);
  float3 View_1840 : packoffset(c115.x);
  float View_1852 : packoffset(c115.w);
  float3 View_1856 : packoffset(c116.x);
  float View_1868 : packoffset(c116.w);
  float3 View_1872 : packoffset(c117.x);
  float View_1884 : packoffset(c117.w);
  float3 View_1888 : packoffset(c118.x);
  float View_1900 : packoffset(c118.w);
  float3 View_1904 : packoffset(c119.x);
  float View_1916 : packoffset(c119.w);
  float3 View_1920 : packoffset(c120.x);
  float View_1932 : packoffset(c120.w);
  float3 View_1936 : packoffset(c121.x);
  float View_1948 : packoffset(c121.w);
  float3 View_1952 : packoffset(c122.x);
  float View_1964 : packoffset(c122.w);
  float3 View_1968 : packoffset(c123.x);
  float View_1980 : packoffset(c123.w);
  float3 View_1984 : packoffset(c124.x);
  float View_1996 : packoffset(c124.w);
  float3 View_2000 : packoffset(c125.x);
  float View_2012 : packoffset(c125.w);
  float3 View_2016 : packoffset(c126.x);
  float View_2028 : packoffset(c126.w);
  float3 View_2032 : packoffset(c127.x);
  float View_2044 : packoffset(c127.w);
  float4 View_2048[4] : packoffset(c128.x);
  float4 View_2112[4] : packoffset(c132.x);
  float4 View_2176[4] : packoffset(c136.x);
  float4 View_2240[4] : packoffset(c140.x);
  float4 View_2304 : packoffset(c144.x);
  float4 View_2320 : packoffset(c145.x);
  float2 View_2336 : packoffset(c146.x);
  float2 View_2344 : packoffset(c146.z);
  float2 View_2352 : packoffset(c147.x);
  float2 View_2360 : packoffset(c147.z);
  float4 View_2368 : packoffset(c148.x);
  float4 View_2384 : packoffset(c149.x);
  int4 View_2400 : packoffset(c150.x);
  float4 View_2416 : packoffset(c151.x);
  float4 View_2432 : packoffset(c152.x);
  float4 View_2448 : packoffset(c153.x);
  float4 View_2464 : packoffset(c154.x);
  float2 View_2480 : packoffset(c155.x);
  float2 View_2488 : packoffset(c155.z);
  int View_2496 : packoffset(c156.x);
  float View_2500 : packoffset(c156.y);
  float View_2504 : packoffset(c156.z);
  float View_2508 : packoffset(c156.w);
  float4 View_2512 : packoffset(c157.x);
  float4 View_2528 : packoffset(c158.x);
  float4 View_2544 : packoffset(c159.x);
  float2 View_2560 : packoffset(c160.x);
  float2 View_2568 : packoffset(c160.z);
  float View_2576 : packoffset(c161.x);
  float View_2580 : packoffset(c161.y);
  float View_2584 : packoffset(c161.z);
  float View_2588 : packoffset(c161.w);
  float3 View_2592 : packoffset(c162.x);
  float View_2604 : packoffset(c162.w);
  float View_2608 : packoffset(c163.x);
  float View_2612 : packoffset(c163.y);
  float View_2616 : packoffset(c163.z);
  float View_2620 : packoffset(c163.w);
  float View_2624 : packoffset(c164.x);
  float View_2628 : packoffset(c164.y);
  float View_2632 : packoffset(c164.z);
  int View_2636 : packoffset(c164.w);
  int View_2640 : packoffset(c165.x);
  int View_2644 : packoffset(c165.y);
  int View_2648 : packoffset(c165.z);
  int View_2652 : packoffset(c165.w);
  int View_2656 : packoffset(c166.x);
  int View_2660 : packoffset(c166.y);
  int View_2664 : packoffset(c166.z);
  float View_2668 : packoffset(c166.w);
  float View_2672 : packoffset(c167.x);
  float View_2676 : packoffset(c167.y);
  float View_2680 : packoffset(c167.z);
  float View_2684 : packoffset(c167.w);
  float4 View_2688 : packoffset(c168.x);
  float3 View_2704 : packoffset(c169.x);
  float View_2716 : packoffset(c169.w);
  float4 View_2720[2] : packoffset(c170.x);
  float4 View_2752[2] : packoffset(c172.x);
  float4 View_2784 : packoffset(c174.x);
  float4 View_2800 : packoffset(c175.x);
  float View_2816 : packoffset(c176.x);
  float View_2820 : packoffset(c176.y);
  float View_2824 : packoffset(c176.z);
  float View_2828 : packoffset(c176.w);
  float View_2832 : packoffset(c177.x);
  float View_2836 : packoffset(c177.y);
  float View_2840 : packoffset(c177.z);
  float View_2844 : packoffset(c177.w);
  float View_2848 : packoffset(c178.x);
  float View_2852 : packoffset(c178.y);
  float View_2856 : packoffset(c178.z);
  float View_2860 : packoffset(c178.w);
  float3 View_2864 : packoffset(c179.x);
  float View_2876 : packoffset(c179.w);
  float3 View_2880 : packoffset(c180.x);
  float View_2892 : packoffset(c180.w);
  float3 View_2896 : packoffset(c181.x);
  float View_2908 : packoffset(c181.w);
  float4 View_2912[2] : packoffset(c182.x);
  float4 View_2944[2] : packoffset(c184.x);
  float4 View_2976[2] : packoffset(c186.x);
  float4 View_3008[2] : packoffset(c188.x);
  float4 View_3040[2] : packoffset(c190.x);
  float4 View_3072 : packoffset(c192.x);
  float3 View_3088 : packoffset(c193.x);
  float View_3100 : packoffset(c193.w);
  float4 View_3104 : packoffset(c194.x);
  float4 View_3120[4] : packoffset(c195.x);
  float4 View_3184 : packoffset(c199.x);
  float View_3200 : packoffset(c200.x);
  float View_3204 : packoffset(c200.y);
  float View_3208 : packoffset(c200.z);
  float View_3212 : packoffset(c200.w);
  float4 View_3216 : packoffset(c201.x);
  float View_3232 : packoffset(c202.x);
  float View_3236 : packoffset(c202.y);
  float View_3240 : packoffset(c202.z);
  float View_3244 : packoffset(c202.w);
  float View_3248 : packoffset(c203.x);
  float View_3252 : packoffset(c203.y);
  float View_3256 : packoffset(c203.z);
  float View_3260 : packoffset(c203.w);
  float3 View_3264 : packoffset(c204.x);
  float View_3276 : packoffset(c204.w);
  float View_3280 : packoffset(c205.x);
  float View_3284 : packoffset(c205.y);
  float View_3288 : packoffset(c205.z);
  float View_3292 : packoffset(c205.w);
  float4 View_3296 : packoffset(c206.x);
  float View_3312 : packoffset(c207.x);
  float View_3316 : packoffset(c207.y);
  float View_3320 : packoffset(c207.z);
  float View_3324 : packoffset(c207.w);
  float4 View_3328 : packoffset(c208.x);
  float View_3344 : packoffset(c209.x);
  float View_3348 : packoffset(c209.y);
  float View_3352 : packoffset(c209.z);
  float View_3356 : packoffset(c209.w);
  float4 View_3360[8] : packoffset(c210.x);
  float View_3488 : packoffset(c218.x);
  float View_3492 : packoffset(c218.y);
  float View_3496 : packoffset(c218.z);
  float View_3500 : packoffset(c218.w);
  int View_3504 : packoffset(c219.x);
  float View_3508 : packoffset(c219.y);
  float View_3512 : packoffset(c219.z);
  float View_3516 : packoffset(c219.w);
  float3 View_3520 : packoffset(c220.x);
  int View_3532 : packoffset(c220.w);
  float4 View_3536[6] : packoffset(c221.x);
  float4 View_3632[6] : packoffset(c227.x);
  float4 View_3728[6] : packoffset(c233.x);
  float4 View_3824[6] : packoffset(c239.x);
  float View_3920 : packoffset(c245.x);
  float View_3924 : packoffset(c245.y);
  int View_3928 : packoffset(c245.z);
  int View_3932 : packoffset(c245.w);
  float3 View_3936 : packoffset(c246.x);
  float View_3948 : packoffset(c246.w);
  float3 View_3952 : packoffset(c247.x);
  float View_3964 : packoffset(c247.w);
  float View_3968 : packoffset(c248.x);
  float View_3972 : packoffset(c248.y);
  int View_3976 : packoffset(c248.z);
  float View_3980 : packoffset(c248.w);
  float View_3984 : packoffset(c249.x);
  float View_3988 : packoffset(c249.y);
  float View_3992 : packoffset(c249.z);
  float View_3996 : packoffset(c249.w);
  float View_4000 : packoffset(c250.x);
  float View_4004 : packoffset(c250.y);
  int2 View_4008 : packoffset(c250.z);
  float View_4016 : packoffset(c251.x);
  float View_4020 : packoffset(c251.y);
  float View_4024 : packoffset(c251.z);
  float View_4028 : packoffset(c251.w);
  float3 View_4032 : packoffset(c252.x);
  float View_4044 : packoffset(c252.w);
  float3 View_4048 : packoffset(c253.x);
  float View_4060 : packoffset(c253.w);
  float2 View_4064 : packoffset(c254.x);
  float2 View_4072 : packoffset(c254.z);
  float2 View_4080 : packoffset(c255.x);
  float2 View_4088 : packoffset(c255.z);
  float2 View_4096 : packoffset(c256.x);
  float View_4104 : packoffset(c256.z);
  float View_4108 : packoffset(c256.w);
  float3 View_4112 : packoffset(c257.x);
  float View_4124 : packoffset(c257.w);
  float2 View_4128 : packoffset(c258.x);
  float2 View_4136 : packoffset(c258.z);
  float View_4144 : packoffset(c259.x);
  float View_4148 : packoffset(c259.y);
  float View_4152 : packoffset(c259.z);
  float View_4156 : packoffset(c259.w);
  float3 View_4160 : packoffset(c260.x);
  float View_4172 : packoffset(c260.w);
  float3 View_4176 : packoffset(c261.x);
  float View_4188 : packoffset(c261.w);
  float3 View_4192 : packoffset(c262.x);
  float View_4204 : packoffset(c262.w);
  float3 View_4208 : packoffset(c263.x);
  float View_4220 : packoffset(c263.w);
  float View_4224 : packoffset(c264.x);
  float View_4228 : packoffset(c264.y);
  float View_4232 : packoffset(c264.z);
  float View_4236 : packoffset(c264.w);
  float4 View_4240[2] : packoffset(c265.x);
  float4 View_4272 : packoffset(c267.x);
  int View_4288 : packoffset(c268.x);
  int View_4292 : packoffset(c268.y);
  int View_4296 : packoffset(c268.z);
  int View_4300 : packoffset(c268.w);
  int View_4304 : packoffset(c269.x);
  int View_4308 : packoffset(c269.y);
  int View_4312 : packoffset(c269.z);
  float View_4316 : packoffset(c269.w);
  float4 View_4320 : packoffset(c270.x);
  int View_4336 : packoffset(c271.x);
  int View_4340 : packoffset(c271.y);
  int View_4344 : packoffset(c271.z);
  int View_4348 : packoffset(c271.w);
  int4 View_4352 : packoffset(c272.x);
  float2 View_4368 : packoffset(c273.x);
  float View_4376 : packoffset(c273.z);
  float View_4380 : packoffset(c273.w);
  float4 View_4384 : packoffset(c274.x);
  float4 View_4400 : packoffset(c275.x);
  float4 View_4416 : packoffset(c276.x);
  float3 View_4432 : packoffset(c277.x);
  float View_4444 : packoffset(c277.w);
  int View_4448 : packoffset(c278.x);
  int View_4452 : packoffset(c278.y);
  int View_4456 : packoffset(c278.z);
  int View_4460 : packoffset(c278.w);
  int4 View_4464[32] : packoffset(c279.x);
  int View_4976 : packoffset(c311.x);
  float View_4980 : packoffset(c311.y);
  float View_4984 : packoffset(c311.z);
  float View_4988 : packoffset(c311.w);
  float4 View_4992 : packoffset(c312.x);
  float4 View_5008 : packoffset(c313.x);
  float4 View_5024 : packoffset(c314.x);
  float4 View_5040 : packoffset(c315.x);
  float2 View_5056 : packoffset(c316.x);
  float View_5064 : packoffset(c316.z);
  float View_5068 : packoffset(c316.w);
  float4 View_5072 : packoffset(c317.x);
  float4 View_5088 : packoffset(c318.x);
  float4 View_5104 : packoffset(c319.x);
  float View_5120 : packoffset(c320.x);
  float View_5124 : packoffset(c320.y);
  float View_5128 : packoffset(c320.z);
  int View_5132 : packoffset(c320.w);
  int4 View_5136 : packoffset(c321.x);
  int View_5152 : packoffset(c322.x);
  int View_5156 : packoffset(c322.y);
  int View_5160 : packoffset(c322.z);
  int View_5164 : packoffset(c322.w);
  float4 View_5168[4] : packoffset(c323.x);
  int3 View_5232 : packoffset(c327.x);
  int View_5244 : packoffset(c327.w);
  float3 View_5248 : packoffset(c328.x);
  float View_5260 : packoffset(c328.w);
  float3 View_5264 : packoffset(c329.x);
  float View_5276 : packoffset(c329.w);
  int3 View_5280 : packoffset(c330.x);
  int View_5292 : packoffset(c330.w);
  float4 View_5296[16] : packoffset(c331.x);
  float View_5552 : packoffset(c347.x);
  float View_5556 : packoffset(c347.y);
  float View_5560 : packoffset(c347.z);
  float View_5564 : packoffset(c347.w);
  float View_5568 : packoffset(c348.x);
  float View_5572 : packoffset(c348.y);
  float View_5576 : packoffset(c348.z);
  float View_5580 : packoffset(c348.w);
  float4 View_5584[4][4] : packoffset(c349.x);
  float4 View_5840[4] : packoffset(c365.x);
  float4 View_5904[4] : packoffset(c369.x);
  float4 View_5968[4][16] : packoffset(c373.x);
  float4 View_6992[16] : packoffset(c437.x);
  float4 View_7248[16] : packoffset(c453.x);
  float4 View_7504[4][8] : packoffset(c469.x);
  float4 View_8016[8] : packoffset(c501.x);
  float4 View_8144[8] : packoffset(c509.x);
  float4 View_8272[8] : packoffset(c517.x);
  float4 View_8400[8] : packoffset(c525.x);
  float4 View_8528[2] : packoffset(c533.x);
  float4 View_8560[2] : packoffset(c535.x);
  float4 View_8592[2] : packoffset(c537.x);
  float4 View_8624[2] : packoffset(c539.x);
  float4 View_8656[2] : packoffset(c541.x);
  float4 View_8688[2] : packoffset(c543.x);
  float4 View_8720[2] : packoffset(c545.x);
  float4 View_8752[2] : packoffset(c547.x);
  float4 View_8784[2] : packoffset(c549.x);
  float4 View_8816[2] : packoffset(c551.x);
  float4 View_8848 : packoffset(c553.x);
  float4 View_8864 : packoffset(c554.x);
  float View_8880 : packoffset(c555.x);
  int View_8884 : packoffset(c555.y);
  int View_8888 : packoffset(c555.z);
  float View_8892 : packoffset(c555.w);
  int View_8896 : packoffset(c556.x);
  int View_8900 : packoffset(c556.y);
  int View_8904 : packoffset(c556.z);
  int View_8908 : packoffset(c556.w);
  int View_8912 : packoffset(c557.x);
  int View_8916 : packoffset(c557.y);
  int View_8920 : packoffset(c557.z);
  int View_8924 : packoffset(c557.w);
  int View_8928 : packoffset(c558.x);
  int View_8932 : packoffset(c558.y);
  int View_8936 : packoffset(c558.z);
  int View_8940 : packoffset(c558.w);
  int View_8944 : packoffset(c559.x);
  int View_8948 : packoffset(c559.y);
  int View_8952 : packoffset(c559.z);
  int View_8956 : packoffset(c559.w);
  float3 View_8960 : packoffset(c560.x);
  int View_8972 : packoffset(c560.w);
  float4 View_8976 : packoffset(c561.x);
  float4 View_8992 : packoffset(c562.x);
  float4 View_9008 : packoffset(c563.x);
  float3 View_9024 : packoffset(c564.x);
  int View_9036 : packoffset(c564.w);
  int3 View_9040 : packoffset(c565.x);
  int View_9052 : packoffset(c565.w);
  int3 View_9056 : packoffset(c566.x);
  int View_9068 : packoffset(c566.w);
  int3 View_9072 : packoffset(c567.x);
  int View_9084 : packoffset(c567.w);
  float3 View_9088 : packoffset(c568.x);
  float View_9100 : packoffset(c568.w);
  float3 View_9104 : packoffset(c569.x);
  float View_9116 : packoffset(c569.w);
  float3 View_9120 : packoffset(c570.x);
  float View_9132 : packoffset(c570.w);
  float3 View_9136 : packoffset(c571.x);
  float View_9148 : packoffset(c571.w);
  int View_9152 : packoffset(c572.x);
  int View_9156 : packoffset(c572.y);
  int View_9160 : packoffset(c572.z);
  int View_9164 : packoffset(c572.w);
  int View_9168 : packoffset(c573.x);
  int View_9172 : packoffset(c573.y);
  int View_9176 : packoffset(c573.z);
  int View_9180 : packoffset(c573.w);
  int View_9184 : packoffset(c574.x);
  int View_9188 : packoffset(c574.y);
  int View_9192 : packoffset(c574.z);
  int View_9196 : packoffset(c574.w);
  int View_9200 : packoffset(c575.x);
  int View_9204 : packoffset(c575.y);
  int View_9208 : packoffset(c575.z);
  int View_9212 : packoffset(c575.w);
  int View_9216 : packoffset(c576.x);
  int View_9220 : packoffset(c576.y);
  int View_9224 : packoffset(c576.z);
  int View_9228 : packoffset(c576.w);
  int View_9232 : packoffset(c577.x);
  int View_9236 : packoffset(c577.y);
  int View_9240 : packoffset(c577.z);
  int View_9244 : packoffset(c577.w);
  int View_9248 : packoffset(c578.x);
  int View_9252 : packoffset(c578.y);
  int View_9256 : packoffset(c578.z);
  int View_9260 : packoffset(c578.w);
  int View_9264 : packoffset(c579.x);
  int View_9268 : packoffset(c579.y);
  int View_9272 : packoffset(c579.z);
  int View_9276 : packoffset(c579.w);
  int View_9280 : packoffset(c580.x);
  int View_9284 : packoffset(c580.y);
  int View_9288 : packoffset(c580.z);
  int View_9292 : packoffset(c580.w);
  int View_9296 : packoffset(c581.x);
  int View_9300 : packoffset(c581.y);
  int View_9304 : packoffset(c581.z);
  int View_9308 : packoffset(c581.w);
  int View_9312 : packoffset(c582.x);
  int View_9316 : packoffset(c582.y);
  int View_9320 : packoffset(c582.z);
  int View_9324 : packoffset(c582.w);
  int View_9328 : packoffset(c583.x);
  int View_9332 : packoffset(c583.y);
  int View_9336 : packoffset(c583.z);
  int View_9340 : packoffset(c583.w);
  int View_9344 : packoffset(c584.x);
  int View_9348 : packoffset(c584.y);
  int View_9352 : packoffset(c584.z);
  int View_9356 : packoffset(c584.w);
  int View_9360 : packoffset(c585.x);
  int View_9364 : packoffset(c585.y);
  int View_9368 : packoffset(c585.z);
  int View_9372 : packoffset(c585.w);
  int View_9376 : packoffset(c586.x);
  int View_9380 : packoffset(c586.y);
  int View_9384 : packoffset(c586.z);
  int View_9388 : packoffset(c586.w);
  int View_9392 : packoffset(c587.x);
  int View_9396 : packoffset(c587.y);
  int View_9400 : packoffset(c587.z);
  int View_9404 : packoffset(c587.w);
  int View_9408 : packoffset(c588.x);
  int View_9412 : packoffset(c588.y);
  int View_9416 : packoffset(c588.z);
  int View_9420 : packoffset(c588.w);
  int View_9424 : packoffset(c589.x);
  int View_9428 : packoffset(c589.y);
  int View_9432 : packoffset(c589.z);
  int View_9436 : packoffset(c589.w);
  int View_9440 : packoffset(c590.x);
  int View_9444 : packoffset(c590.y);
  int View_9448 : packoffset(c590.z);
  int View_9452 : packoffset(c590.w);
  int View_9456 : packoffset(c591.x);
  int View_9460 : packoffset(c591.y);
  int View_9464 : packoffset(c591.z);
  int View_9468 : packoffset(c591.w);
  int View_9472 : packoffset(c592.x);
  int View_9476 : packoffset(c592.y);
  int View_9480 : packoffset(c592.z);
  int View_9484 : packoffset(c592.w);
  int View_9488 : packoffset(c593.x);
  int View_9492 : packoffset(c593.y);
  int View_9496 : packoffset(c593.z);
  int View_9500 : packoffset(c593.w);
  int View_9504 : packoffset(c594.x);
  int View_9508 : packoffset(c594.y);
  int View_9512 : packoffset(c594.z);
  int View_9516 : packoffset(c594.w);
  int View_9520 : packoffset(c595.x);
  int View_9524 : packoffset(c595.y);
  int View_9528 : packoffset(c595.z);
  int View_9532 : packoffset(c595.w);
  int View_9536 : packoffset(c596.x);
  int View_9540 : packoffset(c596.y);
  int View_9544 : packoffset(c596.z);
  int View_9548 : packoffset(c596.w);
  int View_9552 : packoffset(c597.x);
  int View_9556 : packoffset(c597.y);
  int View_9560 : packoffset(c597.z);
  int View_9564 : packoffset(c597.w);
  int View_9568 : packoffset(c598.x);
  int View_9572 : packoffset(c598.y);
  int View_9576 : packoffset(c598.z);
  int View_9580 : packoffset(c598.w);
  int View_9584 : packoffset(c599.x);
  int View_9588 : packoffset(c599.y);
  int View_9592 : packoffset(c599.z);
  int View_9596 : packoffset(c599.w);
  int View_9600 : packoffset(c600.x);
  int View_9604 : packoffset(c600.y);
  int View_9608 : packoffset(c600.z);
  int View_9612 : packoffset(c600.w);
  int View_9616 : packoffset(c601.x);
  int View_9620 : packoffset(c601.y);
  int View_9624 : packoffset(c601.z);
  int View_9628 : packoffset(c601.w);
  int View_9632 : packoffset(c602.x);
  int View_9636 : packoffset(c602.y);
  int View_9640 : packoffset(c602.z);
  int View_9644 : packoffset(c602.w);
  int View_9648 : packoffset(c603.x);
  int View_9652 : packoffset(c603.y);
  int View_9656 : packoffset(c603.z);
  int View_9660 : packoffset(c603.w);
  int View_9664 : packoffset(c604.x);
  int View_9668 : packoffset(c604.y);
  int View_9672 : packoffset(c604.z);
  int View_9676 : packoffset(c604.w);
  int View_9680 : packoffset(c605.x);
  int View_9684 : packoffset(c605.y);
  int View_9688 : packoffset(c605.z);
  int View_9692 : packoffset(c605.w);
  int View_9696 : packoffset(c606.x);
  int View_9700 : packoffset(c606.y);
  int View_9704 : packoffset(c606.z);
  int View_9708 : packoffset(c606.w);
  int View_9712 : packoffset(c607.x);
  int View_9716 : packoffset(c607.y);
  int View_9720 : packoffset(c607.z);
  int View_9724 : packoffset(c607.w);
  int View_9728 : packoffset(c608.x);
  int View_9732 : packoffset(c608.y);
  int View_9736 : packoffset(c608.z);
  int View_9740 : packoffset(c608.w);
  int View_9744 : packoffset(c609.x);
  int View_9748 : packoffset(c609.y);
  int View_9752 : packoffset(c609.z);
  int View_9756 : packoffset(c609.w);
  int View_9760 : packoffset(c610.x);
  int View_9764 : packoffset(c610.y);
  int View_9768 : packoffset(c610.z);
  int View_9772 : packoffset(c610.w);
  int View_9776 : packoffset(c611.x);
  int View_9780 : packoffset(c611.y);
  int View_9784 : packoffset(c611.z);
  int View_9788 : packoffset(c611.w);
  int View_9792 : packoffset(c612.x);
  int View_9796 : packoffset(c612.y);
  int View_9800 : packoffset(c612.z);
  int View_9804 : packoffset(c612.w);
  int View_9808 : packoffset(c613.x);
  int View_9812 : packoffset(c613.y);
  int View_9816 : packoffset(c613.z);
  int View_9820 : packoffset(c613.w);
  int View_9824 : packoffset(c614.x);
  int View_9828 : packoffset(c614.y);
  int View_9832 : packoffset(c614.z);
  int View_9836 : packoffset(c614.w);
  int View_9840 : packoffset(c615.x);
  int View_9844 : packoffset(c615.y);
  int View_9848 : packoffset(c615.z);
  int View_9852 : packoffset(c615.w);
  int View_9856 : packoffset(c616.x);
  int View_9860 : packoffset(c616.y);
  int View_9864 : packoffset(c616.z);
  int View_9868 : packoffset(c616.w);
  int View_9872 : packoffset(c617.x);
  int View_9876 : packoffset(c617.y);
  int View_9880 : packoffset(c617.z);
  int View_9884 : packoffset(c617.w);
  float4 View_9888 : packoffset(c618.x);
  float View_9904 : packoffset(c619.x);
  float View_9908 : packoffset(c619.y);
  int View_9912 : packoffset(c619.z);
  int View_9916 : packoffset(c619.w);
  int View_9920 : packoffset(c620.x);
  int View_9924 : packoffset(c620.y);
  int View_9928 : packoffset(c620.z);
  int View_9932 : packoffset(c620.w);
  float4 View_9936 : packoffset(c621.x);
  int View_9952 : packoffset(c622.x);
  int View_9956 : packoffset(c622.y);
  int View_9960 : packoffset(c622.z);
  int View_9964 : packoffset(c622.w);
  int View_9968 : packoffset(c623.x);
  int View_9972 : packoffset(c623.y);
  int View_9976 : packoffset(c623.z);
  int View_9980 : packoffset(c623.w);
  int View_9984 : packoffset(c624.x);
  int View_9988 : packoffset(c624.y);
  int View_9992 : packoffset(c624.z);
  int View_9996 : packoffset(c624.w);
  int View_10000 : packoffset(c625.x);
  int View_10004 : packoffset(c625.y);
  int View_10008 : packoffset(c625.z);
  int View_10012 : packoffset(c625.w);
  int3 View_10016 : packoffset(c626.x);
  int View_10028 : packoffset(c626.w);
  int3 View_10032 : packoffset(c627.x);
  int View_10044 : packoffset(c627.w);
  float3 View_10048 : packoffset(c628.x);
  float View_10060 : packoffset(c628.w);
  float3 View_10064 : packoffset(c629.x);
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

// DXIL FirstbitHi: returns bit position counting from MSB (leading zeros count)
uint firstbithigh_msb(int value) { return (value == 0) ? 0xFFFFFFFF : (31u - firstbithigh(value)); }
uint firstbithigh_msb(uint value) { return (value == 0) ? 0xFFFFFFFF : (31u - firstbithigh(value)); }

[numthreads(64, 1, 1)]
void main(
  uint3 SV_DispatchThreadID : SV_DispatchThreadID,
  uint3 SV_GroupID : SV_GroupID,
  uint3 SV_GroupThreadID : SV_GroupThreadID,
  uint SV_GroupIndex : SV_GroupIndex
) {
  uint _22;
  uint _34;
  uint _36;
  float _68;
  float _69;
  float _164;
  float _165;
  float _166;
  float _167;
  float _186;
  bool _208;
  int _216;
  float _354;
  float _355;
  float _356;
  float _357;
  float _358;
  float _359;
  float _378;
  float _379;
  float _462;
  float _463;
  float _464;
  float _465;
  int _529;
  int _598;
  bool _684;
  float _685;
  float _701;
  int _702;
  float _712;
  uint _56;
  int _87;
  int _88;
  float4 _91;
  float _103;
  float4 _105;
  float4 _107;
  float4 _112;
  uint _120;
  int _121;
  float _125;
  float _126;
  float _127;
  int _128;
  float _141;
  float _142;
  float _143;
  float _144;
  float _153;
  float _154;
  float _155;
  float _159;
  bool _168;
  float _169;
  float _179;
  float _192;
  float _235;
  float _236;
  bool _257;
  float _258;
  float _259;
  float _263;
  float _267;
  float _271;
  float _280;
  float _281;
  float _282;
  float _284;
  float _288;
  float _289;
  float _290;
  float _291;
  float _292;
  float _293;
  float _297;
  float4 _316;
  bool _323;
  float _336;
  float _339;
  float _341;
  float _362;
  float _365;
  float _368;
  float _369;
  float _380;
  float _381;
  float _383;
  float _386;
  float _387;
  float _389;
  float _394;
  float _395;
  float _396;
  float _399;
  float _402;
  float _406;
  float _410;
  float _418;
  float _419;
  float _420;
  float _422;
  float _423;
  float _424;
  float _425;
  float _427;
  float _428;
  float _429;
  float _430;
  float _432;
  float _447;
  float _450;
  float _453;
  float _455;
  float _469;
  float _494;
  float _507;
  float _509;
  float _511;
  float _513;
  float4 _539;
  float _553;
  float _554;
  float _555;
  float _569;
  uint _589;
  float4 _612;
  int _635;
  int _636;
  int _637;
  uint _639;
  uint _640;
  uint _646;
  uint _650;
  uint _659;
  float4 _676;
  int _686;
  _22 = t7.Load((int)(SV_GroupID.x));
  _34 = ((uint)((((int)(_22.x << 3)) & 32760) | ((int)(SV_GroupThreadID.x) & 7))) + (uint)(asint(cb0_raw[9u].z));
  _36 = ((uint)(asint(cb0_raw[9u].w)) + ((uint)((uint)(SV_GroupThreadID.x) >> 3))) + ((uint)(((uint)((uint)(_22.x)) >> 9) & 32760));
  if ((uint)asint(cb0_raw[9u].x) > (uint)1) {
    if ((uint)asint(cb0_raw[9u].y) > (uint)1) {
      _56 = (uint)(asint(cb0_raw[13u].y)) + ((uint)((_34 & 1) | ((int)(_36 << 1))));
      _68 = float((uint)((uint)(((uint)(_56) >> 1) & 1)));
      _69 = float((uint)((uint)((_56 & 1) ^ 1)));
    } else {
      _68 = float((uint)((uint)(((int)((uint)(asint(cb0_raw[13u].y)) + _36)) & 1)));
      _69 = 0.0f;
    }
  } else {
    _68 = 0.0f;
    _69 = 0.0f;
  }
  _87 = (int)min((uint)(((int)((asint(cb0_raw[9u].x) * _34) + uint(_68 + 0.5f)))), (uint)(((int)(((uint)(View_2400.x) + (uint)(-1)) + (uint)(View_2400.z)))));
  _88 = (int)min((uint)(((int)((asint(cb0_raw[9u].y) * _36) + uint(_69 + 0.5f)))), (uint)(((int)(((uint)(View_2400.y) + (uint)(-1)) + (uint)(View_2400.w)))));
  if (((uint)_34 < (uint)((int)((uint)(asint(cb0_raw[10u].x)) + (uint)(asint(cb0_raw[9u].z))))) && ((uint)_36 < (uint)((int)((uint)(asint(cb0_raw[10u].y)) + (uint)(asint(cb0_raw[9u].w)))))) {
    _91 = t0.Load(int3(_87, _88, 0));
    _103 = ((View_1248.x * _91.x) + View_1248.y) + (1.0f / ((View_1248.z * _91.x) - View_1248.w));
    _105 = t4.Load(int3(_87, _88, 0));
    _107 = t1.Load(int3(_87, _88, 0));
    _112 = t2.Load(int3(_87, _88, 0));
    _120 = uint((_112.w * 255.0f) + 0.5f);
    _121 = _120 & 15;
    _125 = (_107.x * 2.0f) + -1.0f;
    _126 = (_107.y * 2.0f) + -1.0f;
    _127 = (_107.z * 2.0f) + -1.0f;
    _128 = _120 & 14;
    _141 = rsqrt(dot(float3(_125, _126, _127), float3(_125, _126, _127)));
    _142 = _141 * _125;
    _143 = _141 * _126;
    _144 = _141 * _127;
    if (!((_120 & 16) == 0)) {
      _153 = (_105.x * 2.0f) + -1.0f;
      _154 = (_105.y * 2.0f) + -1.0f;
      _155 = (_105.z * 2.0f) + -1.0f;
      _159 = rsqrt(dot(float3(_153, _154, _155), float3(_153, _154, _155)));
      _164 = ((_105.w * 2.0f) + -1.0f);
      _165 = (_159 * _153);
      _166 = (_159 * _154);
      _167 = (_159 * _155);
    } else {
      _164 = 0.0f;
      _165 = 0.0f;
      _166 = 0.0f;
      _167 = 0.0f;
    }
    _168 = (_121 == 4);
    _169 = select(_168, select(((_121 == 13) || ((_128 == 8) || (((_120 & 12) == 4) || (_128 == 2)))), (((float4)(t3.Load(int3(_87, _88, 0)))).y), 0.0f), _112.z);
    if (asfloat(cb0_raw[11u].w) > 0.0f) {
      _179 = saturate(_169 / asfloat(cb0_raw[11u].w));
      _186 = (((_179 * _179) * _169) * (3.0f - (_179 * 2.0f)));
    } else {
      _186 = _169;
    }
    _192 = select(((asint(cb0_raw[12u].x) & -3) == 0), _186, 0.0f);
    if (asint(cb0_raw[12u].x) == 0) {
      if (!(_121 == 0)) {
        _208 = (_168 || (saturate(asfloat(cb0_raw[15u].z) * (select(((_120 & 11) == 2), asfloat(cb0_raw[15u].y), asfloat(cb0_raw[15u].x)) - _192)) > 0.0f));
      } else {
        _208 = false;
      }
      _216 = ((int)(uint)(_208));
    } else {
      if (asint(cb0_raw[12u].x) == 1) {
        _216 = ((int)(uint)((int)(_121 == 10)));
      } else {
        _216 = 0;
      }
    }
    if (_216 == 0) {
      _712 = (-0.0f - _103);
    } else {
      _235 = ((View_2432.z * (float((uint)_87) + 0.5f)) - View_1264.w) / View_1264.x;
      _236 = ((View_2432.w * (float((uint)_88) + 0.5f)) - View_1264.z) / View_1264.y;
      _257 = ((View_448[3].w) >= 1.0f);
      _258 = select(_257, _235, (_235 * _103));
      _259 = select(_257, _236, (_236 * _103));
      _263 = mad(_103, (View_832[2].x), mad(_259, (View_832[1].x), (_258 * (View_832[0].x)))) + (View_832[3].x);
      _267 = mad(_103, (View_832[2].y), mad(_259, (View_832[1].y), (_258 * (View_832[0].y)))) + (View_832[3].y);
      _271 = mad(_103, (View_832[2].z), mad(_259, (View_832[1].z), (_258 * (View_832[0].z)))) + (View_832[3].z);
      _280 = _263 - View_1296.x;
      _281 = _267 - View_1296.y;
      _282 = _271 - View_1296.z;
      _284 = rsqrt(dot(float3(_280, _281, _282), float3(_280, _281, _282)));
      _288 = select(_257, View_1168.x, (_284 * _280));
      _289 = select(_257, View_1168.y, (_284 * _281));
      _290 = select(_257, View_1168.z, (_284 * _282));
      _291 = -0.0f - _288;
      _292 = -0.0f - _289;
      _293 = -0.0f - _290;
      if (_192 < 0.0010000000474974513f) {
        _297 = dot(float3(_288, _289, _290), float3(_142, _143, _144)) * 2.0f;
        _462 = (_297 * _142);
        _463 = (_297 * _143);
        _464 = (_297 * _144);
        _465 = 0.0f;
      } else {
        // IS-FAST: Replace BlueNoise Vec2 for GGX VNDF importance sampling.
        // IS-FAST's spatial blue-noise property anti-correlates adjacent pixels'
        // samples, which the bilateral filter benefits from on every frame.
        if (InjectionToggle(TOGGLE_USE_ISFAST_REFLECTIONS)) {
          float2 _isfast_sample = ISFASTNoiseLoad(
              uint(_34) % 128u,
              uint(_36) % 128u,
              uint(InjectionFrameIndex()) % 32u);
          _316 = float4(_isfast_sample.x, _isfast_sample.y, 0, 0);
        } else {
          _316 = t6.Load(int3((BlueNoise_016.x & _34), ((int)(((BlueNoise_016.z & asint(cb0_raw[13u].w)) * BlueNoise_000.y) + ((uint)(BlueNoise_016.y & _36)))), 0));
        }
        _323 = (_164 != 0.0f);
        if (_323) {
          _354 = _165;
          _355 = _166;
          _356 = _167;
          _357 = ((_167 * _143) - (_166 * _144));
          _358 = ((_165 * _144) - (_167 * _142));
          _359 = ((_166 * _142) - (_165 * _143));
        } else {
          _336 = select((_144 >= 0.0f), 1.0f, -1.0f);
          _339 = -0.0f - (1.0f / (_336 + _144));
          _341 = (_142 * _143) * _339;
          _354 = ((((_142 * _142) * _336) * _339) + 1.0f);
          _355 = (_341 * _336);
          _356 = (-0.0f - (_142 * _336));
          _357 = _341;
          _358 = (((_143 * _143) * _339) + _336);
          _359 = (-0.0f - _143);
        }
        _362 = mad(_356, _293, mad(_355, _292, (_354 * _291)));
        _365 = mad(_359, _293, mad(_358, _292, (_357 * _291)));
        _368 = mad(_144, _293, mad(_143, _292, (_142 * _291)));
        _369 = _192 * _192;

        // ---------------------------------------------------------------
        // LEAN sub-pixel lobe widening (Olano-Baker 2010).
        // Toggle: TOGGLE_USE_REFLECTION_LEAN
        //
        // Widens GGX α² by sub-pixel normal variance to absorb geometric
        // aliasing. Reduces temporal boil and edge crawling on thin geometry.
        // Cost: 4 extra GBuffer normal loads + ~10 ALU per pixel.
        if (InjectionToggle(TOGGLE_USE_REFLECTION_LEAN)) {
          int4 _lean_off_x = int4(_87 - 1, _87 + 1, _87,     _87    );
          int4 _lean_off_y = int4(_88,     _88,     _88 - 1, _88 + 1);
          float3 _lean_n_avg = float3(_142, _143, _144);  // include center
          float  _lean_count = 1.0f;

          [unroll]
          for (int _li = 0; _li < 4; _li++) {
            float4 _lga = t1.Load(int3(_lean_off_x[_li], _lean_off_y[_li], 0));
            float3 _ln = float3(_lga.x * 2.0f - 1.0f, _lga.y * 2.0f - 1.0f, _lga.z * 2.0f - 1.0f);
            // Skip empty/sky pixels (encoded normal length ~ 0).
            if (dot(_ln, _ln) < 0.25f) continue;
            _ln = _ln * rsqrt(max(dot(_ln, _ln), 1e-6f));
            // Reject silhouette neighbors (>30° disagreement).
            if (dot(_ln, float3(_142, _143, _144)) < 0.866f) continue;
            _lean_n_avg += _ln;
            _lean_count += 1.0f;
          }

          _lean_n_avg /= _lean_count;
          float _lean_mean_len_sq = saturate(dot(_lean_n_avg, _lean_n_avg));
          float _lean_sigma_sq = max(1.0f - _lean_mean_len_sq, 0.0f);
          // LEAN: α²_extra ≈ 3σ². Cap at 0.4 (more aggressive for no-temporal pipeline).
          float _lean_alpha_extra = min(3.0f * _lean_sigma_sq, 0.4f);
          // Compose in quadrature: only ever broaden.
          _369 = _369 + _lean_alpha_extra;
        }

        if (_323) {
          _378 = max((_369 * (_164 + 1.0f)), 0.0010000000474974513f);
          _379 = max((_369 * (1.0f - _164)), 0.0010000000474974513f);
        } else {
          _378 = _369;
          _379 = _369;
        }
        _380 = _378 * _362;
        _381 = _379 * _365;
        _383 = rsqrt(dot(float3(_380, _381, _368), float3(_380, _381, _368)));
        _386 = _383 * _368;
        _387 = _316.x * 6.2831854820251465f;
        _389 = saturate(min(_378, _379));
        _394 = sqrt((_365 * _365) + (_362 * _362)) + 1.0f;
        _395 = _389 * _389;
        _396 = _394 * _394;
        _399 = _368 * _368;
        _402 = (_396 - (_396 * _395)) / (_396 + (_399 * _395));
        _406 = (((1.0f - asfloat(cb0_raw[4u].z)) * _316.y) * (-1.0f - (_402 * _386))) + 1.0f;
        _410 = sqrt(saturate(1.0f - (_406 * _406)));
        _418 = ((cos(_387) * _410) + (_383 * _380)) * _378;
        _419 = ((sin(_387) * _410) + (_383 * _381)) * _379;
        _420 = max(0.0f, (_406 + _386));
        _422 = rsqrt(dot(float3(_418, _419, _420), float3(_418, _419, _420)));
        _423 = _422 * _418;
        _424 = _419 * _422;
        _425 = _422 * _420;
        _427 = _379 * _378;
        _428 = _423 * _379;
        _429 = _424 * _378;
        _430 = _425 * _427;
        _432 = _427 / dot(float3(_428, _429, _430), float3(_428, _429, _430));
        _447 = mad(_425, _142, mad(_424, _357, (_423 * _354)));
        _450 = mad(_425, _143, mad(_424, _358, (_423 * _355)));
        _453 = mad(_425, _144, mad(_424, _359, (_423 * _356)));
        _455 = dot(float3(_288, _289, _290), float3(_447, _450, _453)) * 2.0f;
        _462 = (_455 * _447);
        _463 = (_455 * _450);
        _464 = (_455 * _453);
        _465 = (1.0f / max((((_432 * _432) * ((_427 * 0.6366197466850281f) * dot(float3(_362, _365, _368), float3(_423, _424, _425)))) / ((_402 * _368) + sqrt(((_380 * _380) + _399) + (_381 * _381)))), 9.999999747378752e-05f));
      }
      _469 = max(_465, 9.999999747378752e-06f);
      u2[int3(_34, _36, 0)] = float4((_288 - _462), (_289 - _463), (_290 - _464), select(((_120 & 64) != 0), (-0.0f - _469), _469));
      // IS-FAST: Replace BlueNoise Scalar for roughness-to-max-distance jitter.
      // Use a decorrelated sample (offset pixel coords) from the same IS-FAST texture.
      float _isfast_scalar;
      if (InjectionToggle(TOGGLE_USE_ISFAST_REFLECTIONS)) {
        _isfast_scalar = ISFASTNoiseLoad(
            (uint(_34) + 5u) % 128u,
            (uint(_36) + 35u) % 128u,
            uint(InjectionFrameIndex()) % 32u).x;
      } else {
        _isfast_scalar = (((float4)(t5.Load(int3((BlueNoise_016.x & _34), ((int)(((BlueNoise_016.z & asint(cb0_raw[13u].y)) * BlueNoise_000.y) + ((uint)(BlueNoise_016.y & _36)))), 0)))).x);
      }
      _494 = (asfloat(cb0_raw[4u].y) * _isfast_scalar) + _192;
      if (_494 > asfloat(cb0_raw[3u].z)) {
        _507 = (_263 - View_1344.x) - View_1360.x;
        _509 = (_267 - View_1344.y) - View_1360.y;
        _511 = (_271 - View_1344.z) - View_1360.z;
        _513 = float((uint)(uint)(asint(cb0_raw[13u].z)));
        if (asint(cb0_raw[32u].y) == 0) {
          _598 = asint(cb0_raw[32u].y);
        } else {
          _529 = 0;
          while(true) {
            _539 = asfloat(cb0_raw[((uint)(_529 + 45u))]);
            _553 = (((View_1344.x + _507) + View_1360.x) - _539.x) / _539.w;
            _554 = (((View_1344.y + _509) + View_1360.y) - _539.y) / _539.w;
            _555 = (((View_1344.z + _511) + View_1360.z) - _539.z) / _539.w;
            _569 = float((uint)(uint)(asint(cb0_raw[32u].x)));
            if (min(min(saturate(asfloat(cb0_raw[30u].w) * (_553 + -0.5f)), min(saturate(asfloat(cb0_raw[30u].w) * (_554 + -0.5f)), saturate(asfloat(cb0_raw[30u].w) * (_555 + -0.5f)))), min(saturate(((-0.5f - _553) + _569) * asfloat(cb0_raw[30u].w)), min(saturate(((-0.5f - _554) + _569) * asfloat(cb0_raw[30u].w)), saturate(((-0.5f - _555) + _569) * asfloat(cb0_raw[30u].w))))) > frac(frac(dot(float2(((_513 * 32.665000915527344f) + float((uint)_34)), ((_513 * 11.8149995803833f) + float((uint)_36))), float2(0.0671105608344078f, 0.005837149918079376f))) * 52.98291778564453f)) {
              _598 = _529;
            } else {
              _589 = _529 + 1u;
              if ((uint)_589 < (uint)asint(cb0_raw[32u].y)) {
                _529 = _589;
                continue;
              } else {
                _598 = asint(cb0_raw[32u].y);
              }
            }
            break;
          }
        }
        if ((uint)_598 < (uint)asint(cb0_raw[32u].y)) {
          _612 = asfloat(cb0_raw[((uint)(_598 + 45u))]);
          _635 = int(floor(((((View_1344.x + _507) + View_1360.x) - _612.x) / _612.w) + -0.5f));
          _636 = int(floor(((((View_1344.y + _509) + View_1360.y) - _612.y) / _612.w) + -0.5f));
          _637 = int(floor(((((View_1344.z + _511) + View_1360.z) - _612.z) / _612.w) + -0.5f));
          _639 = asint(cb0_raw[32u].x) * _598;
          _640 = _639 + _635;
          _646 = (_635 + 1u) + _639;
          _650 = _636 + 1u;
          _659 = _637 + 1u;
          _676 = asfloat(cb0_raw[((uint)(_598 + 39u))]);
          _684 = ((((((uint)(t8.Load(int4(_640, _636, _637, 0)))).x) != -1) && (!(((((((((uint)(t8.Load(int4(_646, _636, _637, 0)))).x) == -1) || ((((uint)(t8.Load(int4(_640, _650, _637, 0)))).x) == -1)) || ((((uint)(t8.Load(int4(_646, _650, _637, 0)))).x) == -1)) || ((((uint)(t8.Load(int4(_640, _636, _659, 0)))).x) == -1)) || ((((uint)(t8.Load(int4(_646, _636, _659, 0)))).x) == -1)) || ((((uint)(t8.Load(int4(_640, _650, _659, 0)))).x) == -1)))) && ((((uint)(t8.Load(int4(_646, _650, _659, 0)))).x) != -1));
          _685 = (_676.x + (_612.w * 1.7320507764816284f));
        } else {
          _684 = false;
          _685 = 1e+07f;
        }
        _686 = (int)(uint)(_684);
        if (_684) {
          _701 = min(max((((asfloat(cb0_raw[4u].x) - asfloat(cb0_raw[3u].w)) * saturate((_494 - asfloat(cb0_raw[3u].z)) / (asfloat(cb0_raw[3u].y) - asfloat(cb0_raw[3u].z)))) + asfloat(cb0_raw[3u].w)), _685), asfloat(cb0_raw[3u].x));
          _702 = _686;
        } else {
          _701 = asfloat(cb0_raw[3u].x);
          _702 = _686;
        }
      } else {
        _701 = asfloat(cb0_raw[3u].x);
        _702 = 0;
      }
      u1[int3(_34, _36, 0)] = (((int)(f32tof16(min(_701, 65504.0f))) & 32767) | (_702 << 15));
      _712 = _103;
    }
    u0[int3(_34, _36, 0)] = _712;
  }
}