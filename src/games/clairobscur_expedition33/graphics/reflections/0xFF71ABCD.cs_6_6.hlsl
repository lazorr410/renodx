// A-trous wavelet compute pass for Lumen reflections multi-pass filter (v3).
//
// This shader runs under the GAME'S compute root signature (UE5
// ReflectionBilateralFilterCS at 0x88E6E1DB), extended with our extra
// params in space 100 so we can append our ping texture, IS-FAST noise,
// and push constants without rewriting any of UE5's bindings.
//
// Two-pass schedule (driven by host `OnAfterBilateral`):
//   Pass 2 (step=3, variance_attenuation=9):  SpecularIndirect (t6, space0) → Ping (u0, space100)
//   Pass 3 (step=7, variance_attenuation=81): Ping (t0, space100)           → RWSpecularIndirect (u0, space0)
//
// Step sizes 1, 3, 7 are pairwise coprime — no shared spatial period
// across passes, so the 5-pixel grid period that any single 5×5 A-trous
// pass introduces does not reinforce into a visible lattice when the
// three passes compose.
//
// All edge-stop math lives in `atrous_kernel.hlsli`, shared 1:1 with the
// inline pass-1 in `0x88E6E1DB.cs_6_6.hlsl`.
//
// Variance contracts ~1/N_eff per pass (B3-spline N_eff ~ 9). The host
// pushes `variance_attenuation` ∈ {1, 9, 81} for the inline / pass-2 /
// pass-3, and we divide ResolveVariance by it before driving both the
// filter-strength gate and the color sigma. So passes 2/3:
//   - run on **fewer** pixels (gate sees `var/9`, `var/81` — most are
//     below the smoothstep threshold and pass through);
//   - filter at **narrower** sigma where they do run (sqrt of attenuated
//     variance) — preserves detail.
//
// IS-FAST per-pixel lattice shift breaks the deterministic 5×5 grid
// period without changing the wavelet basis. Each pixel samples a
// shifted integer-aligned subgrid; the residual lattice is per-pixel
// noise that TAA resolves.
//
// Tile-gate context (see 0x88E6E1DB): UE5's bilateral runs only over
// tiles listed in ReflectionResolveTileData. Pixels outside those tiles
// contain zero (or stale) data in SpecularIndirect. We pass those
// through unchanged and reject near-zero neighbors so tile boundaries
// don't bleed garbage into valid reflections.

#include "atrous_kernel.hlsli"

// --- UE5's bindings (space 0) — cloned from 0x88E6E1DB's root signature ---
Texture2D<float4>        SceneTexturesStruct_SceneDepthTexture : register(t0);
Texture2D<float4>        SceneTexturesStruct_GBufferATexture   : register(t1);
Texture2D<float4>        SceneTexturesStruct_GBufferBTexture   : register(t2);
Texture2D<float4>        SceneTexturesStruct_GBufferDTexture   : register(t3);
Buffer<uint>             ReflectionResolveTileData             : register(t4);
Texture2DArray<float>    ResolveVariance                       : register(t5);
Texture2DArray<float3>   SpecularIndirect                      : register(t6);
RWTexture2DArray<float3> RWSpecularIndirect                    : register(u0);

// --- Our extensions (space 100) ---
Texture2DArray<float3>   PingInput    : register(t0, space100);
ByteAddressBuffer        ISFASTNoise  : register(t1, space100);
static const uint ISFAST_W = 128u;
static const uint ISFAST_H = 128u;
static const uint ISFAST_SLICE_TEXELS = ISFAST_W * ISFAST_H;
static const uint ISFAST_ELEMENT_BYTES = 8u;
static float2 ISFASTNoiseLoad(uint x, uint y, uint slice) {
  return asfloat(ISFASTNoise.Load2((slice * ISFAST_SLICE_TEXELS + y * ISFAST_W + x) * ISFAST_ELEMENT_BYTES));
}
RWTexture2DArray<float3> PingOutput   : register(u0, space100);

cbuffer AtrousParams : register(b0, space100) {
  uint   step_size;             // 3 for pass 2, 7 for pass 3
  uint   input_source;          // 0 = SpecularIndirect, 1 = PingInput
  uint   output_target;         // 0 = PingOutput, 1 = RWSpecularIndirect
  uint   pass_index;            // 1 for step=3, 2 for step=7. 0 reserved for inline.
  uint4  view_rect;             // .xy = min, .zw = size
  uint   frame_index;           // 0..31, IS-FAST temporal slice
  float  variance_attenuation;  // 1.0 (pass 1), 9.0 (pass 2), 81.0 (pass 3)
  uint   _ac_pad_0;
  uint   _ac_pad_1;
};

// UE5's bilateral cbuffer at b0,space0 — inherited via the cloned root
// signature. We declare only the fields we actually use here. The
// cbuffer slot is shared with UE5's bilateral so the engine populates
// these from the same r.Lumen.Reflections.BilateralFilter.* cvars
// every frame.
cbuffer LumenReflectionBilateralFilter : register(b0) {
  float BilateralFilterSpatialKernelRadius : packoffset(c001.z);
  uint  BilateralFilterNumSamples          : packoffset(c001.w);
  float BilateralFilterDepthWeightScale    : packoffset(c002.x);
  float BilateralFilterNormalAngleThresholdScale : packoffset(c002.y);
  float BilateralFilterStrongBlurVarianceThreshold : packoffset(c002.z);
};

static bool IsValidReflection(float3 color) {
  return AtrousLuma(color) > 1e-6f;
}

static float3 SampleInput(int2 spx) {
  return (input_source == 0u)
      ? SpecularIndirect.Load(int4(spx, 0, 0))
      : PingInput.Load(int4(spx, 0, 0));
}

static void WriteOutput(int2 px, float3 value) {
  if (output_target == 0u) {
    PingOutput[int3(px, 0)] = value;
  } else {
    RWSpecularIndirect[int3(px, 0)] = value;
  }
}

[numthreads(8, 8, 1)]
void main(uint3 DTid : SV_DispatchThreadID) {
  const int2 rect_min  = int2(view_rect.xy);
  const int2 rect_size = int2(view_rect.zw);

  if (any(int2(DTid.xy) >= rect_size)) return;

  const int2 px = rect_min + int2(DTid.xy);

  float3 center_color = SampleInput(px);

  // Untouched / out-of-tile pixels: leave as-is so we don't propagate
  // zeros across the valid region through the kernel.
  if (!IsValidReflection(center_color)) {
    WriteOutput(px, center_color);
    return;
  }

  const float4 gb        = SceneTexturesStruct_GBufferBTexture.Load(int3(px, 0));
  const float  roughness = gb.z;

  // Mirror passthrough — preserve pixel-perfect specular detail.
  if (AtrousIsMirror(roughness)) {
    WriteOutput(px, center_color);
    return;
  }

  const uint shading_model = uint(gb.w * 255.0f + 0.5f) & 15u;
  if (shading_model == 0u) {
    WriteOutput(px, center_color);
    return;
  }

  // Variance contracts across passes. ResolveVariance reflects the input
  // to pass-1; we divide by attenuation to estimate the residual after
  // the previous passes' filtering.
  const float raw_variance       = ResolveVariance.Load(int4(px, 0, 0)).x;
  const float effective_variance = raw_variance / max(variance_attenuation, 1.0f);

  // Skip-kernel optimization for already-converged pixels.
  if (AtrousVarianceConverged(effective_variance)) {
    WriteOutput(px, center_color);
    return;
  }

  // Filter strength is roughness-driven (see atrous_kernel.hlsli).
  const float filter_weight = AtrousFilterStrength(roughness);

  const float  center_depth = SceneTexturesStruct_SceneDepthTexture.Load(int3(px, 0)).x;
  const float4 ga           = SceneTexturesStruct_GBufferATexture.Load(int3(px, 0));
  const float3 center_n     = AtrousDecodeNormal(ga.xyz);

  // Per-pixel integer lattice shift. Currently disabled; see
  // `atrous_kernel.hlsli`.
  const float2 isfast_xy = AtrousSampleISFast(ISFASTNoise, px, pass_index);
  const int2   shift     = AtrousLatticeShift(isfast_xy, step_size);

  // Cvar-driven step scaling. UE5's
  // `r.Lumen.Reflections.BilateralFilter.SpatialKernelRadius` (default
  // 0.01) maps directly onto our pass step size. Larger cvar → wider
  // taps for stronger denoising; smaller → tighter for more detail.
  const int effective_step = AtrousScaledStep(step_size, BilateralFilterSpatialKernelRadius);

  // KERNEL: 5×5 B3-spline with depth × normal edge stops only — no
  // color stop. Pass-1 (the inline `0x88E6E1DB` filter) already did the
  // heavy lifting of converting noisy 1spp data into a smoothed
  // signal; pass-2/3's job is to spread that smoothed signal further
  // for additional noise reduction. Adding a color stop here only
  // introduces failure modes:
  //   - Step-spaced reference: per-pixel variation produced low-freq
  //     boiling (iteration 8).
  //   - Unit-spaced reference: too tight at step=7, rejected most
  //     kernel samples → effective passthrough → high-freq shimmer
  //     (iteration 9).
  // Karis tonemapped accumulation handles fireflies via amplitude
  // attenuation. UE5's original bilateral uses the same depth+normal
  // structure with no color stop and produces a usable image.

  // Center contribution — guarantees wsum > 0.
  const float w_center = kAtrousKernelWeights[2] * kAtrousKernelWeights[2];
  float3 sum  = AtrousKarisToneMap(center_color) * w_center;
  float  wsum = w_center;

  [unroll]
  for (int dy = -2; dy <= 2; dy++) {
    [unroll]
    for (int dx = -2; dx <= 2; dx++) {
      if (dx == 0 && dy == 0) continue;

      int2 spx = px + int2(dx, dy) * effective_step + shift;
      spx = clamp(spx, rect_min, rect_min + rect_size - 1);

      float3 s_color = SampleInput(spx);
      const float s_luma = AtrousLuma(s_color);
      if (s_luma <= 1e-6f) continue;

      const float4 s_gb    = SceneTexturesStruct_GBufferBTexture.Load(int3(spx, 0));
      const uint   s_model = uint(s_gb.w * 255.0f + 0.5f) & 15u;
      if (s_model == 0u) continue;

      const float  s_depth = SceneTexturesStruct_SceneDepthTexture.Load(int3(spx, 0)).x;
      const float4 s_ga    = SceneTexturesStruct_GBufferATexture.Load(int3(spx, 0));
      const float3 s_n     = AtrousDecodeNormal(s_ga.xyz);

      const float w_spatial = kAtrousKernelWeights[dx + 2] * kAtrousKernelWeights[dy + 2];
      const float w_geo     = AtrousGeometricWeight(
          center_depth, center_n,
          s_depth,      s_n,
          BilateralFilterDepthWeightScale,
          BilateralFilterNormalAngleThresholdScale);

      const float w = w_spatial * w_geo;
      sum  += AtrousKarisToneMap(s_color) * w;
      wsum += w;
    }
  }

  const float3 toned    = sum / max(wsum, 1e-6f);
  const float3 filtered = AtrousKarisInverseToneMap(toned);
  const float3 blended  = lerp(center_color, filtered, filter_weight);
  WriteOutput(px, blended);
}
