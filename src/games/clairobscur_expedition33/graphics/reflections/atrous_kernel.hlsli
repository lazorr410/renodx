// atrous_kernel.hlsli
//
// Shared edge-stop math for Lumen reflection A-trous passes. Both the
// inline pass-1 (`0x88E6E1DB.cs_6_6.hlsl`, replaces UE5 ReflectionBilateralFilterCS)
// and the injected pass-2 / pass-3 (`0xFF71ABCD.cs_6_6.hlsl`, host-launched
// by `OnAfterBilateral` in `host.hpp`) include this file so the three
// passes share identical weight functions. Without this, the previous
// implementations drifted: the inline pass used log-luma color sigma with
// depth-relative tolerance, the injected passes used linear-luma color
// sigma with flat depth tolerance — which produced "severe blur" because
// linear sigma at HDR luma 5–50 is wildly permissive while normal-power 128
// over-rejected silhouettes. See `project-docs/005_bilateral-atrous-rework`.
//
// Design choices (rationale in `project-docs/005_bilateral-atrous-rework/questions_and_answers.md`):
//
// - **Color edge-stop in log-luminance space**. HDR Lumen reflections span
//   ~0.01..1000 nits. Log space is scale-invariant — the same sigma behaves
//   identically across that range. Linear sigma either over-blurs highlights
//   or under-blurs shadows.
// - **Depth tolerance is depth-relative**. UE5 InvDeviceZToWorldZTransform
//   gives world units; tolerance scales as 0.5% of |center_depth| with a
//   hard floor at 0.005 world units near the camera.
// - **Normal weight power = 64**. 32 (previous pass-1 value) under-rejects
//   silhouettes; 128 (previous pass-2/3 value) over-rejects causing grid
//   artifacts when the kernel coincidentally crosses an edge. 64 strikes
//   the balance used by SVGF (Schied et al. 2017) and ReLAX/RELAX (NRD).
// - **Variance contraction across passes**. Pass-1 sees raw 1spp variance.
//   The B3-spline kernel has N_eff ~ 9 effective taps, so each pass
//   reduces variance by ~1/9. Pass-2 sees `var/9`, pass-3 sees `var/81`.
//   The filter-strength gate AND the color sigma both consume this
//   contracted variance — so passes 2/3 progressively run on fewer
//   pixels (mostly converged after pass-1) and at narrower color
//   tolerance (small residual variance), preserving detail.
// - **Filter strength gate is variance-only, not max(variance, roughness)**.
//   Roughness drives sigma (color tolerance), not the gate. A converged
//   glossy pixel (low variance, mid roughness) should NOT be filtered
//   just because the surface is rough; that crushes specular detail.
//   Mirror passthrough (rough < 0.02) is a hard early-out — bilateral
//   filtering on mirror reflections destroys pixel-perfect detail.
// - **IS-FAST per-pixel lattice shift**. Each pixel samples a different
//   integer-aligned 5×5 sub-grid (offset in `[-step/2, +step/2]` per
//   axis). At step=1 there's nothing to shift (taps are dense); at
//   step=3 there are 9 distinct sub-grids; at step=7 there are 49.
//   The deterministic 5×5 grid period is replaced with per-pixel
//   decorrelated noise that TAA resolves. NOTE: the previous sub-tap
//   `±step/2` float jitter was buggy at step=1 — `round(dx + 0.5)`
//   collapsed `dx=-1` onto center, producing the bright-edge unsharp-mask
//   artifact in single-pass mode.

#ifndef SRC_CLAIROBSCUR_EXPEDITION33_GRAPHICS_REFLECTIONS_ATROUS_KERNEL_HLSLI_
#define SRC_CLAIROBSCUR_EXPEDITION33_GRAPHICS_REFLECTIONS_ATROUS_KERNEL_HLSLI_

// =============================================================================
// Constants
// =============================================================================

// Rec.709 luma weights. Used for both color-stop luma and IS-FAST clamp.
static const float3 kAtrousLumaWeights = float3(0.21259999f, 0.71520001f, 0.07220000f);

// 5-tap B3-spline ({1,4,6,4,1} / 16). 2D kernel = outer product.
static const float kAtrousKernelWeights[5] = {
    1.0f / 16.0f,
    4.0f / 16.0f,
    6.0f / 16.0f,
    4.0f / 16.0f,
    1.0f / 16.0f,
};

// Normal-power. 64 is the SVGF/RELAX consensus — sharp enough to reject
// silhouettes, soft enough to avoid binary edge-grid artifacts.
static const float kAtrousNormalPower = 64.0f;

// Smoothstep range for the variance-driven filter strength. Below 0.001
// variance the pixel is converged via temporal — pass through unchanged.
// Above 0.015 variance we filter at full strength.
static const float kAtrousVarianceLow  = 0.001f;
static const float kAtrousVarianceHigh = 0.015f;

// Smoothstep range for the roughness-driven filter strength. Mirror-like
// surfaces (roughness < 0.02) pass through; rough surfaces (>= 0.08)
// always filter.
static const float kAtrousRoughnessLow  = 0.02f;
static const float kAtrousRoughnessHigh = 0.08f;

// =============================================================================
// Helpers
// =============================================================================

// Stable luma — clamps to non-negative so HDR negative pixels (rare but
// possible from filtering rounding) don't break log/sqrt math.
static float AtrousLuma(float3 color) {
  return dot(max(color, 0.0f), kAtrousLumaWeights);
}

// Decode + normalize a packed normal from UE5's GBufferA RGB. Out-of-range
// inputs (e.g. zeroed pixels in untouched tiles) yield a unit vector.
static float3 AtrousDecodeNormal(float3 ga_rgb) {
  float3 n = ga_rgb * 2.0f - 1.0f;
  return n * rsqrt(max(dot(n, n), 1e-6f));
}

// True log-luminance for the color edge-stop. The +0.01 floor keeps
// log2 finite at black without distorting non-black values
// (`log2(0.01)=-6.6`). Differences in this space are *stops* — a
// scale-invariant measure: doubling luma always corresponds to +1 stop
// regardless of HDR magnitude. This is what makes the σ tuning
// independent of overall scene brightness.
static const float kAtrousLogLumaFloor = 0.01f;
static float AtrousLogLuma(float luma) {
  return log2(max(luma, kAtrousLogLumaFloor));
}

// Karis-domain luma. Maps unbounded HDR luma onto [0, 1) via x/(1+x).
// Used for the firefly-robust reference (the Karis-domain mean of a
// noisy box averages toward the median of normal neighbors, not the
// firefly outlier).
static float AtrousKarisLuma(float luma) {
  return luma / (1.0f + max(luma, 0.0f));
}
static float AtrousKarisLumaInverse(float karis_luma) {
  // Inverse of l/(1+l): k/(1-k). Clamp denominator for stability.
  return karis_luma / max(1.0f - karis_luma, 1e-3f);
}

// =============================================================================
// Filter strength
// =============================================================================
//
// See the rationale below `AtrousColorSigma` for the design choices.

// Mirror passthrough: glossy/mirror surfaces (roughness < 0.02) skip
// filtering entirely regardless of variance. The bilateral filter on
// mirror reflections crushes pixel-perfect detail, so we passthrough
// even if the per-pixel variance is high (1spp on a mirror IS the
// correct signal — the variance reflects scene noise upstream, not
// integration noise we should smooth).
static bool AtrousIsMirror(float roughness) {
  return roughness < kAtrousRoughnessLow;
}

// =============================================================================
// Karis HDR-stable accumulation + log-stops color edge-stop
// =============================================================================
//
// Iterations 1–6 tried various color edge-stops alone (no Karis tonemap)
// and all failed:
//   - Tight σ from UE5 ResolveVariance: rejected ~24/25 taps.
//   - Wide σ via constant rough multiplier: leaked across silhouettes.
//   - SVGF spatial-variance σ: poisoned by single fireflies.
//
// Iteration 7 went the other way: Karis tonemap accumulation, NO color
// stop. That handles fireflies but leaks across genuine luma edges
// within a smooth surface (one rough material reflecting a bright sky
// and a dark wall with no normal/depth difference at the boundary).
//
// Iteration 8 combines both:
//
//   1. Karis tonemap accumulation handles fireflies via amplitude
//      attenuation. A 100× firefly contributes ~1× to the sum, same
//      as a normal neighbor.
//   2. A log-stops color edge-stop with σ from UE5's ResolveVariance
//      handles cross-edge rejection. ResolveVariance is multi-sample
//      (computed in the resolve pass from 4–8 spatial samples) so it's
//      bounded and won't explode like in-shader 3×3 stats. We use it
//      purely as a *floor* for σ — the σ widens with measured noise,
//      so on noisy surfaces neighbors are accepted, but at a
//      cross-edge the sample's log-luma delta exceeds even the wide
//      σ → still rejected.
//   3. The reference luma for the comparison is the **Karis-domain
//      box mean**, which is firefly-robust: the Karis tonemap caps
//      each contributor's influence so a single firefly can't drag
//      the reference toward itself the way a linear mean would.
//
// Why this works where iteration 6's SVGF approach didn't:
//   - σ is bounded (ResolveVariance is bounded by definition; it's a
//     pre-computed multi-sample variance, not raw 1spp data).
//   - The reference is firefly-robust (Karis-domain box mean).
//   - Karis tonemap accumulation already attenuates fireflies, so
//     the color stop only needs to do edge rejection — its job got
//     much easier.

// Forward Karis tonemap. Maps HDR luma onto [0, 1) so arithmetic
// averages of tonemapped values are dominated by the median rather
// than the brightest outlier.
static float3 AtrousKarisToneMap(float3 color) {
  return color * (1.0f / (1.0f + AtrousLuma(color)));
}

// Inverse Karis tonemap. After the weighted average, recover linear
// luma. Algebra: if y = x/(1+l_x), then x = y/(1-l_y).
static float3 AtrousKarisInverseToneMap(float3 toned) {
  float toned_luma = AtrousLuma(toned);
  // Clamp denominator: toned_luma should be in [0, 1) by construction
  // but rounding can push it over. Cap at 1-ε for numerical stability.
  float denom = max(1.0f - toned_luma, 1e-3f);
  return toned / denom;
}

// Compute σ in log-stops from UE5's ResolveVariance. ResolveVariance
// is a per-pixel scalar in [0, 1] representing temporal disagreement
// of the 1spp signal AS RESOLVED — it's already multi-sample (4–8
// taps) so it's bounded and won't explode on a single firefly.
//
// We translate it into log-stops:
//   noise_stops = log2(1 + scale × ResolveVariance)
//
// At ResolveVariance=0 (converged) → 0 stops → σ tight, edges sharp.
// At ResolveVariance=1 (max noise) → log2(1 + scale) stops.
//
// `strong_blur_threshold` honors UE5's
// `BilateralFilter.StrongBlurVarianceThreshold` cvar (default 0.5):
// pixels whose variance exceeds the threshold get a smoothly-ramped
// up-to-+1-stop sigma boost for stronger denoising on noisy regions.
// This is our analog of UE5's "kernel-radius-doubles-above-threshold"
// behavior — we can't change the kernel radius mid-pass but a wider σ
// has the equivalent effect of letting more samples through.
//
// The 8× scale + 0.5 floor was chosen so that:
//   - ResolveVariance=0.0  → σ ≈ 0.5 stops    (tight: cross-edge rejection still works)
//   - ResolveVariance=0.05 → σ ≈ 1.0 stops    (1 stop tolerance for moderate noise)
//   - ResolveVariance=0.20 → σ ≈ 1.8 stops    (3.5× luma tolerance for noisy regions)
//   - ResolveVariance=1.00 → σ ≈ 3.6 stops    (12× luma tolerance for max noise)
//
// At a cross-edge (e.g., bright sky reflection at 100 luma next to
// dark wall reflection at 1 luma), the log-luma delta is ~6.6 stops.
// Even at max σ=3.6, the cross-edge sample weight is exp2(-6.6/3.6)
// = 2^-1.83 ≈ 0.28 — significant down-weight while still allowing
// some bleed-through (which the kernel weight further reduces).
static float AtrousColorSigmaStops(float resolve_variance, float strong_blur_threshold) {
  float base = 0.5f + log2(1.0f + 8.0f * saturate(resolve_variance));
  // Smooth ramp around the threshold so the transition is not binary.
  float strong_boost = smoothstep(
      strong_blur_threshold * 0.8f,
      strong_blur_threshold,
      resolve_variance);
  return base + strong_boost;
}

// Backward-compat overload — neutral threshold (0.5 → matches engine
// default). Prefer the explicit form for cvar-driven tuning.
static float AtrousColorSigmaStops(float resolve_variance) {
  return AtrousColorSigmaStops(resolve_variance, 0.5f);
}

// Per-tap color edge-stop weight. Compares sample log-luma to the
// reference log-luma in stops, σ in stops.
static float AtrousColorWeight(
    float sample_log_luma,
    float reference_log_luma,
    float sigma_stops) {
  float diff_stops = abs(sample_log_luma - reference_log_luma);
  return exp2(-diff_stops / max(sigma_stops, 1e-4f));
}

// Roughness-driven filter strength. The lerp from "noisy center" to
// "filtered result" is driven by *roughness*, not variance — because:
//   - Mirror (handled separately): output = center, no filter.
//   - Glossy (rough 0.02..0.1): partial commit. Glossy reflections
//     have fine detail; partial commit preserves it.
//   - Rough (rough > 0.1): full commit. The kernel result is
//     bilateral-correct — rejected samples were rejected for valid
//     edge-stop reasons. Blending back in the noisy center on a
//     rough surface only adds noise; it doesn't preserve any detail
//     because rough surfaces have no per-pixel detail to preserve.
//
// On surfaces where the bilateral aggressively rejects most
// neighbors (typical at 1spp specular noise on rough), the result
// will still carry residual noise — that's the limit of a 5×5
// single-pass A-trous. Multi-pass A-trous (steps 3, 7) and temporal
// reprojection downstream are responsible for the rest.
static float AtrousFilterStrength(float roughness) {
  return smoothstep(0.02f, 0.10f, roughness);
}

// Skip-kernel optimization: if the resolve variance is below this
// threshold, the pixel is essentially converged via temporal already.
// We still passthrough the center (no filter), saving the 25-tap cost.
// This is independent of the filter-strength lerp; it's a "no work
// needed" early-out, not a "blend back the noise" decision.
static bool AtrousVarianceConverged(float effective_variance) {
  return effective_variance < kAtrousVarianceLow;
}

// Depth tolerance — relative to view distance with a near-camera floor.
// `depth_weight_scale` honors UE5's
// `BilateralFilter.DepthWeightScale` cvar (default 1000): higher
// values produce stricter depth rejection. We map it onto a multiplier
// of the per-pixel tolerance.
static float AtrousDepthTolerance(float center_depth, float depth_weight_scale) {
  // Engine default of 1000 → multiplier 1.0 (current behavior).
  // Higher cvar → smaller tolerance → stricter rejection.
  float tol_scale = max(1.0f, 1000.0f / max(depth_weight_scale, 1.0f));
  return max(abs(center_depth) * 0.005f * tol_scale, 0.005f * tol_scale);
}

// Backward-compat overload — engine default of 1000.
static float AtrousDepthTolerance(float center_depth) {
  return AtrousDepthTolerance(center_depth, 1000.0f);
}

// Resolve the effective normal-power exponent from UE5's
// `BilateralFilter.NormalAngleThresholdScale` cvar (default 1.5):
// higher values produce a *looser* angle threshold (more permissive),
// so we *lower* the exponent. Engine default 1.5 → 64 (our base value).
static float AtrousNormalPower(float normal_angle_threshold_scale) {
  // Higher threshold scale → larger acceptable angle → softer power.
  // Linear interpolation around the engine default keeps tuning intuitive.
  return kAtrousNormalPower * (1.5f / max(normal_angle_threshold_scale, 0.1f));
}

// =============================================================================
// Per-tap weight (depth + normal — color is computed separately)
// =============================================================================

// Geometric edge-stop product (depth × normal). Color is computed by
// the caller via `AtrousColorWeight` because it needs the local
// variance which is built up in the same pre-pass that computes the
// luma reference.
//
// Cvar-driven version. Defaults:
//   depth_weight_scale  = 1000.0  (UE5 r.Lumen.Reflections.BilateralFilter.DepthWeightScale)
//   normal_angle_thresh = 1.5     (UE5 r.Lumen.Reflections.BilateralFilter.NormalAngleThresholdScale)
static float AtrousGeometricWeight(
    float  center_depth,
    float3 center_normal,
    float  sample_depth,
    float3 sample_normal,
    float  depth_weight_scale,
    float  normal_angle_threshold_scale) {
  float depth_tol  = AtrousDepthTolerance(center_depth, depth_weight_scale);
  float w_depth    = exp2(-abs(sample_depth - center_depth) / depth_tol);

  float ndot       = saturate(dot(sample_normal, center_normal));
  float w_normal   = pow(ndot, AtrousNormalPower(normal_angle_threshold_scale));

  return w_depth * w_normal;
}

// Backward-compat overload — engine defaults.
static float AtrousGeometricWeight(
    float  center_depth,
    float3 center_normal,
    float  sample_depth,
    float3 sample_normal) {
  return AtrousGeometricWeight(
      center_depth, center_normal,
      sample_depth, sample_normal,
      /*depth_weight_scale=*/1000.0f,
      /*normal_angle_threshold_scale=*/1.5f);
}

// =============================================================================
// Cvar-driven step scaling for multi-pass à-trous
// =============================================================================
//
// UE5's `BilateralFilter.SpatialKernelRadius` cvar (default 0.01 of
// viewport) drives the disc radius of UE5's original 16-tap bilateral.
// We map it onto a step multiplier for the injected pass-2 / pass-3
// dispatches: smaller cvar → tighter steps (more local detail), larger
// cvar → wider steps (more denoising at the cost of detail).
//
// Engine default 0.01 → multiplier 1.0 (steps 3 and 7 unchanged).
// Multiplier is clamped >= 1 so steps can't collapse to 0/1 (which
// would defeat the multi-pass pipeline).
static int AtrousScaledStep(uint base_step, float spatial_kernel_radius) {
  float multiplier = max(spatial_kernel_radius / 0.01f, 0.5f);
  return max(int(round(float(base_step) * multiplier)), 1);
}

// =============================================================================
// IS-FAST sub-step jitter
// =============================================================================// Returns the IS-FAST sample for a given pixel + pass at integer slice.
// Caller passes in the actual texture so this header doesn't need to
// pick a register slot (pass-1 binds at t0,space50; injected passes at
// t1,space100 in the cloned layout).
//
// IMPORTANT: NO temporal cycling. The slice is fixed per-pass and does
// not advance with frame index. The lattice shift is used to break the
// deterministic 5×5 grid period spatially — adjacent pixels see
// different shifts. Cycling the slice per frame would make each pixel's
// lattice shift change every frame, which means the *neighborhood the
// filter integrates over* changes per frame. For a stationary scene
// that produces frame-to-frame output variation that TAA cannot fully
// hide, especially on roughnesses where edge-stops reject most
// neighbors so only 1–3 contribute (the original "boiling on certain
// roughnesses" symptom). Holding the slice constant gives each pixel a
// fixed neighborhood — stationary input → stationary output.
//
// IS-FAST's exponential-temporal optimization is designed for Monte
// Carlo accumulation (integrating samples of a fixed integrand across
// frames). Here the noise picks which neighbors to consult, not what
// to integrate; we don't need temporal optimality, we need spatial
// decorrelation only.
static float2 AtrousSampleISFast(
    ByteAddressBuffer noise_texture,
    int2 pixel,
    uint pass_index) {
  // Per-pass slice offsets so pass-2 and pass-3 see independent (but
  // each individually time-invariant) noise patterns. 7 is coprime to
  // 32 → distinct slice values for the three passes.
  uint slice = (pass_index * 7u) % 32u;
  return asfloat(noise_texture.Load2((slice * (128u*128u) + uint(pixel.y % 128u) * 128u + uint(pixel.x % 128u)) * 8u));
}

// Per-pixel sample-position perturbation for the A-trous lattice.
// Currently disabled — returns int2(0,0) always.
//
// History: earlier iterations used IS-FAST blue noise to shift each
// pixel's 5×5 sub-grid by `[-step/2, +step/2]` integer pixels per
// axis. The intent was to break the deterministic 5×5 kernel period
// (5 px at step=1, 15 px at step=3, 35 px at step=7) so the grid
// dissolves into per-pixel noise.
//
// Real-world result: at large step sizes (step=3, step=7), adjacent
// pixels with different shifts saw substantially-disjoint
// neighborhoods (e.g., step=7 with ±3 shift → two adjacent pixels
// can sample 14-pixel-apart grids). Each pixel's filter integrated
// a different patch of the noisy input, producing low-frequency
// spatial disagreement between adjacent pixels. Frame-to-frame the
// disagreement pattern moved with the noise input → visible boiling
// waves on rough surfaces.
//
// The grid period at step=3 (15 px) and step=7 (35 px) is below
// perceptual frequency for textured rough surfaces — not worth the
// boiling cost. Pass-1 (step=1) has the strongest grid risk but the
// lattice is dense at unit spacing so there's no room to shift
// without collapsing taps.
//
// Kept the function so call sites stay intact; can be re-enabled
// per-pass if a specific scene shows visible grid artifacts.
static int2 AtrousLatticeShift(float2 isfast_xy, uint step_size) {
  return int2(0, 0);
}

#endif  // SRC_CLAIROBSCUR_EXPEDITION33_GRAPHICS_REFLECTIONS_ATROUS_KERNEL_HLSLI_
