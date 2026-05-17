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

// --- Fog History Filter Implementations ---
// Mode 0: Bilinear (hardware default, no helper needed)
// Mode 1: Tricubic B-Spline (Sigg & Hadwiger 2005) — C2 smooth, approximating
// Mode 2: Tricubic Catmull-Rom — C1 smooth, interpolating (sharper, preserves detail)
// Mode 3: Triquadratic B-Spline (Csebfalvi 2023) — C1 smooth, only 2 trilinear taps

// Mode 1: B-Spline Tricubic (8 bilinear taps, C2 continuous)
// Adaptive detail preservation: where local contrast is high (light shafts, thin
// bright features spanning 1-2 voxels), the B-spline's low-pass character erases
// detail. We blend toward bilinear in high-contrast regions to preserve peaks,
// and use full B-spline in smooth regions (ground fog) to eliminate voxel banding.
float4 BSplineTricubicSample(Texture3D<float4> tex, SamplerState samp, float3 uvw, float3 texSize) {
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

  // Clamp sample positions to the valid texture range so the outer B-spline
  // support doesn't bleed in zero-valued border texels at fog volume edges.
  float3 t0 = clamp(h0 / texSize, 0.0, 1.0);
  float3 t1 = clamp(h1 / texSize, 0.0, 1.0);

  float4 s000 = tex.SampleLevel(samp, float3(t0.x, t0.y, t0.z), 0);
  float4 s100 = tex.SampleLevel(samp, float3(t1.x, t0.y, t0.z), 0);
  float4 s010 = tex.SampleLevel(samp, float3(t0.x, t1.y, t0.z), 0);
  float4 s110 = tex.SampleLevel(samp, float3(t1.x, t1.y, t0.z), 0);
  float4 s001 = tex.SampleLevel(samp, float3(t0.x, t0.y, t1.z), 0);
  float4 s101 = tex.SampleLevel(samp, float3(t1.x, t0.y, t1.z), 0);
  float4 s011 = tex.SampleLevel(samp, float3(t0.x, t1.y, t1.z), 0);
  float4 s111 = tex.SampleLevel(samp, float3(t1.x, t1.y, t1.z), 0);

  float gx = g1.x / (g0.x + g1.x);
  float gy = g1.y / (g0.y + g1.y);
  float gz = g1.z / (g0.z + g1.z);
  float4 xy0 = lerp(lerp(s000, s100, gx), lerp(s010, s110, gx), gy);
  float4 xy1 = lerp(lerp(s001, s101, gx), lerp(s011, s111, gx), gy);
  float4 bspline_result = lerp(xy0, xy1, gz);

  // Bilinear reference at the same position.
  float4 bilinear_result = tex.SampleLevel(samp, uvw, 0);

  // Adaptive blend: measure local contrast as the relative difference between
  // B-spline (smoothed) and bilinear (peak-preserving). High contrast means
  // the B-spline is erasing detail (light shafts, thin features). Blend toward
  // bilinear to preserve those peaks.
  float3 diff = abs(bspline_result.rgb - bilinear_result.rgb);
  float max_val = max(max(bilinear_result.r, bilinear_result.g), max(bilinear_result.b, 0.001));
  float contrast = (diff.r + diff.g + diff.b) / (3.0 * max_val);
  // Ramp: 0 contrast → full B-spline, >15% relative contrast → full bilinear
  float detail_preserve = saturate(contrast * 6.667);  // 1/0.15 ≈ 6.667

  return lerp(bspline_result, bilinear_result, detail_preserve);
}

// Mode 2: Catmull-Rom Tricubic via sharpened B-spline (9 taps total, C1 continuous)
// result = (4/3)*bspline - (1/3)*bilinear  ≈  Mitchell-Netravali (B=1/3, C=1/3)
//
// Grid artifact fix: the sharpening subtraction can produce negative values at
// sharp fog edges (Catmull-Rom's negative lobes). For fog density (always ≥ 0)
// these get hard-clamped to zero by the renderer, producing grid-aligned zero
// bands. Fix: clamp the final result to max(0, ...) per channel, and use a
// slightly softer sharpening factor (1.2 instead of 4/3) to reduce overshoot
// while keeping the interpolating character.
float4 CatmullRomTricubicSample(Texture3D<float4> tex, SamplerState samp, float3 uvw, float3 texSize) {
  // B-spline sub-computation — coord system: uvw * texSize - 0.5 so that
  // floor(coord) gives the lower-left texel index, matching BSplineTricubicSample.
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

  // Clamp to valid range (same fix as B-spline mode).
  float3 bt0 = clamp(bh0 / texSize, 0.0, 1.0);
  float3 bt1 = clamp(bh1 / texSize, 0.0, 1.0);

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

  // Bilinear reference tap at the same UV.
  float4 bilinear = tex.SampleLevel(samp, uvw, 0);

  // Sharpened B-spline ≈ Catmull-Rom. Factor 1.2 instead of 4/3 (≈1.333) to
  // reduce negative-lobe overshoot that causes grid-aligned zero-clamp bands.
  // Clamp to max(0) per channel: fog density and scattering are non-negative,
  // so any negative result from the sharpening is physically invalid.
  float4 sharp_result = max(bspline * 1.2 - bilinear * 0.2, 0.0);

  // Adaptive detail preservation (same logic as B-spline mode): where local
  // contrast is high (light shafts), blend toward bilinear to preserve peaks.
  float3 diff = abs(sharp_result.rgb - bilinear.rgb);
  float max_val = max(max(bilinear.r, bilinear.g), max(bilinear.b, 0.001));
  float contrast = (diff.r + diff.g + diff.b) / (3.0 * max_val);
  float detail_preserve = saturate(contrast * 6.667);

  return lerp(sharp_result, bilinear, detail_preserve);
}

// Mode 3: Triquadratic B-Spline (2 trilinear taps, C1 continuous)
// Based on: Csebfalvi 2023 "One Step Further Beyond Trilinear"
// Much cheaper than tricubic (2 taps vs 8) while still C1 smooth.
float4 TriquadraticSample(Texture3D<float4> tex, SamplerState samp, float3 uvw, float3 texSize) {
  float3 coord = uvw * texSize - 0.5;
  float3 f = frac(coord);

  // Quadratic B-spline weights: w0 = 0.5*(1-f)^2, w1 = 0.5+f-f^2, w2 = 0.5*f^2
  float3 w0 = 0.5 * (1.0 - f) * (1.0 - f);
  float3 w2 = 0.5 * f * f;
  float3 w1 = 1.0 - w0 - w2;

  // Two trilinear taps with shifted coordinates
  float3 h0 = (floor(coord) + 0.5 - (0.5 * (1.0 - f) / (w0 + w1))) / texSize;
  float3 h1 = (floor(coord) + 0.5 + (0.5 * f / (w1 + w2)) + 1.0) / texSize;

  float3 g0 = w0 + w1;
  float3 g1 = w1 + w2;

  float4 s0 = tex.SampleLevel(samp, h0, 0);
  float4 s1 = tex.SampleLevel(samp, h1, 0);

  // Blend along each axis — for a true 3D triquadratic we need 8 taps,
  // but the 2-tap approximation blends the two trilinear samples
  float3 blend = g1 / (g0 + g1);
  return lerp(s0, s1, blend.x * blend.y * blend.z);
}

// Dispatcher: selects filter based on fog_filter_mode
float4 SampleFogHistory(Texture3D<float4> tex, SamplerState samp, float3 uvw, float3 texSize, float mode) {
  if (mode > 2.5f) {
    return TriquadraticSample(tex, samp, uvw, texSize);
  } else if (mode > 1.5f) {
    return CatmullRomTricubicSample(tex, samp, uvw, texSize);
  } else if (mode > 0.5f) {
    return BSplineTricubicSample(tex, samp, uvw, texSize);
  } else {
    return tex.SampleLevel(samp, uvw, 0);
  }
}

struct FForwardLightDataConstants {
  uint NumLocalLights;
  uint NumReflectionCaptures;
  uint HasDirectionalLight;
  uint NumGridCells;
  int3 CulledGridSize;
  uint MaxCulledLightsPerCell;
  uint LightGridPixelSizeShift;
  uint Padding36;
  uint Padding40;
  uint Padding44;
  float3 LightGridZParams;
  float Padding60;
  float3 DirectionalLightDirection;
  float DirectionalLightSourceRadius;
  float DirectionalLightSoftSourceRadius;
  float Padding84;
  float Padding88;
  float Padding92;
  float3 DirectionalLightColor;
  float DirectionalLightVolumetricScatteringIntensity;
  float DirectionalLightSpecularScale;
  uint DirectionalLightShadowMapChannelMask;
  float2 DirectionalLightDistanceFadeMAD;
  uint NumDirectionalLightCascades;
  int DirectionalLightVSM;
  int Padding136;
  int Padding140;
  float4 CascadeEndDepths;
  float4 DirectionalLightTranslatedWorldToShadowMatrix[4][4];
  float4 DirectionalLightShadowmapMinMax[4];
  float4 DirectionalLightShadowmapAtlasBufferSize;
  float DirectionalLightDepthBias;
  uint DirectionalLightUseStaticShadowing;
  uint SimpleLightsEndIndex;
  uint ClusteredDeferredSupportedEndIndex;
  uint ManyLightsSupportedStartIndex;
  uint Padding516;
  uint Padding520;
  uint Padding524;
  float4 DirectionalLightStaticShadowBufferSize;
  float4 DirectionalLightTranslatedWorldToStaticShadow[4];
  uint DirectLightingShowFlag;
  uint LightFunctionAtlasLightIndex;
  float Padding616;
  float Padding620;
  float DirectionalLightSMRTSettings_ScreenRayLength;
  int DirectionalLightSMRTSettings_SMRTRayCount;
  int DirectionalLightSMRTSettings_SMRTSamplesPerRay;
  float DirectionalLightSMRTSettings_SMRTRayLengthScale;
  float DirectionalLightSMRTSettings_SMRTCotMaxRayAngleFromLight;
  float DirectionalLightSMRTSettings_SMRTTexelDitherScale;
  float DirectionalLightSMRTSettings_SMRTExtrapolateSlope;
  float DirectionalLightSMRTSettings_SMRTMaxSlopeBias;
  uint DirectionalLightSMRTSettings_SMRTAdaptiveRayCount;
  uint Padding660;
  uint Padding664;
  uint Padding668;
  uint BindlessSRV_DirectionalLightShadowmapAtlas;
  uint Padding676;
  uint BindlessSampler_ShadowmapSampler;
  uint Padding684;
  uint BindlessSRV_DirectionalLightStaticShadowmap;
  uint Padding692;
  uint BindlessSampler_StaticShadowmapSampler;
  uint Padding700;
  uint BindlessSRV_ForwardLocalLightBuffer;
  uint Padding708;
  uint BindlessSRV_NumCulledLightsGrid;
  uint Padding716;
  uint BindlessSRV_CulledLightDataGrid32Bit;
  uint Padding724;
  uint BindlessSRV_CulledLightDataGrid16Bit;
};

struct FViewConstants {
  float4 TranslatedWorldToClip[4];
  float4 RelativeWorldToClip[4];
  float4 ClipToRelativeWorld[4];
  float4 TranslatedWorldToView[4];
  float4 ViewToTranslatedWorld[4];
  float4 TranslatedWorldToCameraView[4];
  float4 CameraViewToTranslatedWorld[4];
  float4 ViewToClip[4];
  float4 ViewToClipNoAA[4];
  float4 ClipToView[4];
  float4 ClipToTranslatedWorld[4];
  float4 SVPositionToTranslatedWorld[4];
  float4 ScreenToRelativeWorld[4];
  float4 ScreenToTranslatedWorld[4];
  float4 MobileMultiviewShadowTransform[4];
  float3 ViewOriginHigh;
  float Padding972;
  float3 ViewForward;
  float Padding988;
  float3 ViewUp;
  float Padding1004;
  float3 ViewRight;
  float Padding1020;
  float3 HMDViewNoRollUp;
  float Padding1036;
  float3 HMDViewNoRollRight;
  float Padding1052;
  float4 InvDeviceZToWorldZTransform;
  float4 ScreenPositionScaleBias;
  float3 ViewOriginLow;
  float Padding1100;
  float3 TranslatedWorldCameraOrigin;
  float Padding1116;
  float3 WorldViewOriginHigh;
  float Padding1132;
  float3 WorldViewOriginLow;
  float Padding1148;
  float3 PreViewTranslationHigh;
  float Padding1164;
  float3 PreViewTranslationLow;
  float Padding1180;
  float4 PrevViewToClip[4];
  float4 PrevClipToView[4];
  float4 PrevTranslatedWorldToClip[4];
  float4 PrevTranslatedWorldToView[4];
  float4 PrevViewToTranslatedWorld[4];
  float4 PrevTranslatedWorldToCameraView[4];
  float4 PrevCameraViewToTranslatedWorld[4];
  float3 PrevTranslatedWorldCameraOrigin;
  float Padding1644;
  float3 PrevWorldCameraOriginHigh;
  float Padding1660;
  float3 PrevWorldCameraOriginLow;
  float Padding1676;
  float3 PrevWorldViewOriginHigh;
  float Padding1692;
  float3 PrevWorldViewOriginLow;
  float Padding1708;
  float3 PrevPreViewTranslationHigh;
  float Padding1724;
  float3 PrevPreViewTranslationLow;
  float Padding1740;
  float3 ViewTilePosition;
  float Padding1756;
  float3 RelativeWorldCameraOriginTO;
  float Padding1772;
  float3 RelativeWorldViewOriginTO;
  float Padding1788;
  float3 RelativePreViewTranslationTO;
  float Padding1804;
  float3 PrevRelativeWorldCameraOriginTO;
  float Padding1820;
  float3 PrevRelativeWorldViewOriginTO;
  float Padding1836;
  float3 RelativePrevPreViewTranslationTO;
  float Padding1852;
  float4 PrevClipToRelativeWorld[4];
  float4 PrevScreenToTranslatedWorld[4];
  float4 ClipToPrevClip[4];
  float4 ClipToPrevClipWithAA[4];
  float4 TemporalAAJitter;
  float4 GlobalClippingPlane;
  float2 FieldOfViewWideAngles;
  float2 PrevFieldOfViewWideAngles;
  float4 ViewRectMin;
  float4 ViewSizeAndInvSize;
  uint4 ViewRectMinAndSize;
  float4 LightProbeSizeRatioAndInvSizeRatio;
  float4 BufferSizeAndInvSize;
  float4 BufferBilinearUVMinMax;
  float4 ScreenToViewSpace;
  float2 BufferToSceneTextureScale;
  float2 ResolutionFractionAndInv;
  int NumSceneColorMSAASamples;
  float ProjectionDepthThicknessScale;
  float PreExposure;
  float OneOverPreExposure;
  float4 DiffuseOverrideParameter;
  float4 SpecularOverrideParameter;
  float4 NormalOverrideParameter;
  float2 RoughnessOverrideParameter;
  float PrevFrameGameTime;
  float PrevFrameRealTime;
  float OutOfBoundsMask;
  float Padding2372;
  float Padding2376;
  float Padding2380;
  float3 WorldCameraMovementSinceLastFrame;
  float CullingSign;
  float NearPlane;
  float GameTime;
  float RealTime;
  float DeltaTime;
  float MaterialTextureMipBias;
  float MaterialTextureDerivativeMultiply;
  uint Random;
  uint FrameNumber;
  uint FrameCounter;
  uint StateFrameIndexMod8;
  uint StateFrameIndex;
  uint DebugViewModeMask;
  uint WorldIsPaused;
  float CameraCut;
  float UnlitViewmodeMask;
  float Padding2460;
  float4 DirectionalLightColor;
  float3 DirectionalLightDirection;
  float Padding2492;
  float4 TranslucencyLightingVolumeMin[2];
  float4 TranslucencyLightingVolumeInvSize[2];
  float4 TemporalAAParams;
  float4 CircleDOFParams;
  float DepthOfFieldSensorWidth;
  float DepthOfFieldFocalDistance;
  float DepthOfFieldScale;
  float DepthOfFieldFocalLength;
  float DepthOfFieldFocalRegion;
  float DepthOfFieldNearTransitionRegion;
  float DepthOfFieldFarTransitionRegion;
  float MotionBlurNormalizedToPixel;
  float GeneralPurposeTweak;
  float GeneralPurposeTweak2;
  float DemosaicVposOffset;
  float DecalDepthBias;
  float3 IndirectLightingColorScale;
  float Padding2652;
  float3 PrecomputedIndirectLightingColorScale;
  float Padding2668;
  float3 PrecomputedIndirectSpecularColorScale;
  float Padding2684;
  float4 AtmosphereLightDirection[2];
  float4 AtmosphereLightIlluminanceOnGroundPostTransmittance[2];
  float4 AtmosphereLightIlluminanceOuterSpace[2];
  float4 AtmosphereLightDiscLuminance[2];
  float4 AtmosphereLightDiscCosHalfApexAngle_PPTrans[2];
  float4 SkyViewLutSizeAndInvSize;
  float3 SkyCameraTranslatedWorldOrigin;
  float Padding2876;
  float4 SkyPlanetTranslatedWorldCenterAndViewHeight;
  float4 SkyViewLutReferential[4];
  float4 SkyAtmosphereSkyLuminanceFactor;
  float SkyAtmospherePresentInScene;
  float SkyAtmosphereHeightFogContribution;
  float SkyAtmosphereBottomRadiusKm;
  float SkyAtmosphereTopRadiusKm;
  float4 SkyAtmosphereCameraAerialPerspectiveVolumeSizeAndInvSize;
  float SkyAtmosphereAerialPerspectiveStartDepthKm;
  float SkyAtmosphereCameraAerialPerspectiveVolumeDepthResolution;
  float SkyAtmosphereCameraAerialPerspectiveVolumeDepthResolutionInv;
  float SkyAtmosphereCameraAerialPerspectiveVolumeDepthSliceLengthKm;
  float SkyAtmosphereCameraAerialPerspectiveVolumeDepthSliceLengthKmInv;
  float SkyAtmosphereApplyCameraAerialPerspectiveVolume;
  float Padding3032;
  float Padding3036;
  float3 NormalCurvatureToRoughnessScaleBias;
  float RenderingReflectionCaptureMask;
  float RealTimeReflectionCapture;
  float RealTimeReflectionCapturePreExposure;
  float Padding3064;
  float Padding3068;
  float4 AmbientCubemapTint;
  float AmbientCubemapIntensity;
  float SkyLightApplyPrecomputedBentNormalShadowingFlag;
  float SkyLightAffectReflectionFlag;
  float SkyLightAffectGlobalIlluminationFlag;
  float4 SkyLightColor;
  float SkyLightVolumetricScatteringIntensity;
  float Padding3124;
  float Padding3128;
  float Padding3132;
  float4 MobileSkyIrradianceEnvironmentMap[8];
  float MobilePreviewMode;
  float HMDEyePaddingOffset;
  float ReflectionCubemapMaxMip;
  float ShowDecalsMask;
  uint DistanceFieldAOSpecularOcclusionMode;
  float IndirectCapsuleSelfShadowingIntensity;
  float Padding3288;
  float Padding3292;
  float3 ReflectionEnvironmentRoughnessMixingScaleBiasAndLargestWeight;
  int StereoPassIndex;
  float4 GlobalVolumeTranslatedCenterAndExtent[6];
  float4 GlobalVolumeTranslatedWorldToUVAddAndMul[6];
  float4 GlobalDistanceFieldMipTranslatedWorldToUVScale[6];
  float4 GlobalDistanceFieldMipTranslatedWorldToUVBias[6];
  float GlobalDistanceFieldMipFactor;
  float GlobalDistanceFieldMipTransition;
  int GlobalDistanceFieldClipmapSizeInPages;
  int Padding3708;
  float3 GlobalDistanceFieldInvPageAtlasSize;
  float Padding3724;
  float3 GlobalDistanceFieldInvCoverageAtlasSize;
  float GlobalVolumeDimension;
  float GlobalVolumeTexelSize;
  float MaxGlobalDFAOConeDistance;
  uint NumGlobalSDFClipmaps;
  float CoveredExpandSurfaceScale;
  float NotCoveredExpandSurfaceScale;
  float NotCoveredMinStepScale;
  float DitheredTransparencyStepThreshold;
  float DitheredTransparencyTraceThreshold;
  int2 CursorPosition;
  float bCheckerboardSubsurfaceProfileRendering;
  float Padding3788;
  float3 VolumetricFogInvGridSize;
  float Padding3804;
  float3 VolumetricFogGridZParams;
  float Padding3820;
  float2 VolumetricFogSVPosToVolumeUV;
  float2 VolumetricFogViewGridUVToPrevViewRectUV;
  float2 VolumetricFogPrevViewGridRectUVToResourceUV;
  float2 VolumetricFogPrevUVMax;
  float2 VolumetricFogPrevUVMaxForTemporalBlend;
  float2 VolumetricFogScreenToResourceUV;
  float2 VolumetricFogUVMax;
  float VolumetricFogMaxDistance;
  float Padding3884;
  float3 VolumetricLightmapWorldToUVScale;
  float Padding3900;
  float3 VolumetricLightmapWorldToUVAdd;
  float Padding3916;
  float3 VolumetricLightmapIndirectionTextureSize;
  float VolumetricLightmapBrickSize;
  float3 VolumetricLightmapBrickTexelSize;
  float IndirectLightingCacheShowFlag;
  float EyeToPixelSpreadAngle;
  float Padding3956;
  float Padding3960;
  float Padding3964;
  float4 XRPassthroughCameraUVs[2];
  float GlobalVirtualTextureMipBias;
  uint VirtualTextureFeedbackShift;
  uint VirtualTextureFeedbackMask;
  uint VirtualTextureFeedbackStride;
  uint VirtualTextureFeedbackJitterOffset;
  uint VirtualTextureFeedbackSampleOffset;
  uint Padding4024;
  uint Padding4028;
  float4 RuntimeVirtualTextureMipLevel;
  float2 RuntimeVirtualTexturePackHeight;
  float Padding4056;
  float Padding4060;
  float4 RuntimeVirtualTextureDebugParams;
  int FarShadowStaticMeshLODBias;
  float MinRoughness;
  float Padding4088;
  float Padding4092;
  float4 HairRenderInfo;
  uint EnableSkyLight;
  uint HairRenderInfoBits;
  uint HairComponents;
  float bSubsurfacePostprocessEnabled;
  float4 SSProfilesTextureSizeAndInvSize;
  float4 SSProfilesPreIntegratedTextureSizeAndInvSize;
  float4 SpecularProfileTextureSizeAndInvSize;
  float3 PhysicsFieldClipmapCenter;
  float PhysicsFieldClipmapDistance;
  int PhysicsFieldClipmapResolution;
  int PhysicsFieldClipmapExponent;
  int PhysicsFieldClipmapCount;
  int PhysicsFieldTargetCount;
  int4 PhysicsFieldTargets[32];
  uint GPUSceneViewId;
  float ViewResolutionFraction;
  float SubSurfaceColorAsTransmittanceAtDistanceInMeters;
  float Padding4732;
  float4 TanAndInvTanHalfFOV;
  float4 PrevTanAndInvTanHalfFOV;
  float2 WorldDepthToPixelWorldRadius;
  float Padding4776;
  float Padding4780;
  float4 ScreenRayLengthMultiplier;
  float4 GlintLUTParameters0;
  float4 GlintLUTParameters1;
  int4 EnvironmentComponentsFlags;
  uint BindlessSampler_MaterialTextureBilinearWrapedSampler;
  uint Padding4852;
  uint BindlessSampler_MaterialTextureBilinearClampedSampler;
  uint Padding4860;
  uint BindlessSRV_VolumetricLightmapIndirectionTexture;
  uint Padding4868;
  uint BindlessSRV_VolumetricLightmapBrickAmbientVector;
  uint Padding4876;
  uint BindlessSRV_VolumetricLightmapBrickSHCoefficients0;
  uint Padding4884;
  uint BindlessSRV_VolumetricLightmapBrickSHCoefficients1;
  uint Padding4892;
  uint BindlessSRV_VolumetricLightmapBrickSHCoefficients2;
  uint Padding4900;
  uint BindlessSRV_VolumetricLightmapBrickSHCoefficients3;
  uint Padding4908;
  uint BindlessSRV_VolumetricLightmapBrickSHCoefficients4;
  uint Padding4916;
  uint BindlessSRV_VolumetricLightmapBrickSHCoefficients5;
  uint Padding4924;
  uint BindlessSRV_SkyBentNormalBrickTexture;
  uint Padding4932;
  uint BindlessSRV_DirectionalLightShadowingBrickTexture;
  uint Padding4940;
  uint BindlessSampler_VolumetricLightmapBrickAmbientVectorSampler;
  uint Padding4948;
  uint BindlessSampler_VolumetricLightmapTextureSampler0;
  uint Padding4956;
  uint BindlessSampler_VolumetricLightmapTextureSampler1;
  uint Padding4964;
  uint BindlessSampler_VolumetricLightmapTextureSampler2;
  uint Padding4972;
  uint BindlessSampler_VolumetricLightmapTextureSampler3;
  uint Padding4980;
  uint BindlessSampler_VolumetricLightmapTextureSampler4;
  uint Padding4988;
  uint BindlessSampler_VolumetricLightmapTextureSampler5;
  uint Padding4996;
  uint BindlessSampler_SkyBentNormalTextureSampler;
  uint Padding5004;
  uint BindlessSampler_DirectionalLightShadowingTextureSampler;
  uint Padding5012;
  uint BindlessSRV_GlobalDistanceFieldPageAtlasTexture;
  uint Padding5020;
  uint BindlessSRV_GlobalDistanceFieldCoverageAtlasTexture;
  uint Padding5028;
  uint BindlessSRV_GlobalDistanceFieldPageTableTexture;
  uint Padding5036;
  uint BindlessSRV_GlobalDistanceFieldMipTexture;
  uint Padding5044;
  uint BindlessSampler_GlobalDistanceFieldPageAtlasTextureSampler;
  uint Padding5052;
  uint BindlessSampler_GlobalDistanceFieldCoverageAtlasTextureSampler;
  uint Padding5060;
  uint BindlessSampler_GlobalDistanceFieldMipTextureSampler;
  uint Padding5068;
  uint BindlessSRV_AtmosphereTransmittanceTexture;
  uint Padding5076;
  uint BindlessSampler_AtmosphereTransmittanceTextureSampler;
  uint Padding5084;
  uint BindlessSRV_AtmosphereIrradianceTexture;
  uint Padding5092;
  uint BindlessSampler_AtmosphereIrradianceTextureSampler;
  uint Padding5100;
  uint BindlessSRV_AtmosphereInscatterTexture;
  uint Padding5108;
  uint BindlessSampler_AtmosphereInscatterTextureSampler;
  uint Padding5116;
  uint BindlessSRV_PerlinNoiseGradientTexture;
  uint Padding5124;
  uint BindlessSampler_PerlinNoiseGradientTextureSampler;
  uint Padding5132;
  uint BindlessSRV_PerlinNoise3DTexture;
  uint Padding5140;
  uint BindlessSampler_PerlinNoise3DTextureSampler;
  uint Padding5148;
  uint BindlessSRV_SobolSamplingTexture;
  uint Padding5156;
  uint BindlessSampler_SharedPointWrappedSampler;
  uint Padding5164;
  uint BindlessSampler_SharedPointClampedSampler;
  uint Padding5172;
  uint BindlessSampler_SharedBilinearWrappedSampler;
  uint Padding5180;
  uint BindlessSampler_SharedBilinearClampedSampler;
  uint Padding5188;
  uint BindlessSampler_SharedBilinearAnisoClampedSampler;
  uint Padding5196;
  uint BindlessSampler_SharedTrilinearWrappedSampler;
  uint Padding5204;
  uint BindlessSampler_SharedTrilinearClampedSampler;
  uint Padding5212;
  uint BindlessSRV_PreIntegratedBRDF;
  uint Padding5220;
  uint BindlessSampler_PreIntegratedBRDFSampler;
  uint Padding5228;
  uint BindlessSRV_SkyIrradianceEnvironmentMap;
  uint Padding5236;
  uint BindlessSRV_TransmittanceLutTexture;
  uint Padding5244;
  uint BindlessSampler_TransmittanceLutTextureSampler;
  uint Padding5252;
  uint BindlessSRV_SkyViewLutTexture;
  uint Padding5260;
  uint BindlessSampler_SkyViewLutTextureSampler;
  uint Padding5268;
  uint BindlessSRV_DistantSkyLightLutTexture;
  uint Padding5276;
  uint BindlessSampler_DistantSkyLightLutTextureSampler;
  uint Padding5284;
  uint BindlessSRV_CameraAerialPerspectiveVolume;
  uint Padding5292;
  uint BindlessSampler_CameraAerialPerspectiveVolumeSampler;
  uint Padding5300;
  uint BindlessSRV_CameraAerialPerspectiveVolumeMieOnly;
  uint Padding5308;
  uint BindlessSampler_CameraAerialPerspectiveVolumeMieOnlySampler;
  uint Padding5316;
  uint BindlessSRV_CameraAerialPerspectiveVolumeRayOnly;
  uint Padding5324;
  uint BindlessSampler_CameraAerialPerspectiveVolumeRayOnlySampler;
  uint Padding5332;
  uint BindlessSRV_HairScatteringLUTTexture;
  uint Padding5340;
  uint BindlessSampler_HairScatteringLUTSampler;
  uint Padding5348;
  uint BindlessSRV_GGXLTCMatTexture;
  uint Padding5356;
  uint BindlessSampler_GGXLTCMatSampler;
  uint Padding5364;
  uint BindlessSRV_GGXLTCAmpTexture;
  uint Padding5372;
  uint BindlessSampler_GGXLTCAmpSampler;
  uint Padding5380;
  uint BindlessSRV_SheenLTCTexture;
  uint Padding5388;
  uint BindlessSampler_SheenLTCSampler;
  uint Padding5396;
  uint bShadingEnergyConservation;
  uint bShadingEnergyPreservation;
  uint BindlessSRV_ShadingEnergyGGXSpecTexture;
  uint Padding5412;
  uint BindlessSRV_ShadingEnergyGGXGlassTexture;
  uint Padding5420;
  uint BindlessSRV_ShadingEnergyClothSpecTexture;
  uint Padding5428;
  uint BindlessSRV_ShadingEnergyDiffuseTexture;
  uint Padding5436;
  uint BindlessSampler_ShadingEnergySampler;
  uint Padding5444;
  uint BindlessSRV_GlintTexture;
  uint Padding5452;
  uint BindlessSampler_GlintSampler;
  uint Padding5460;
  uint BindlessSRV_SimpleVolumeTexture;
  uint Padding5468;
  uint BindlessSampler_SimpleVolumeTextureSampler;
  uint Padding5476;
  uint BindlessSRV_SimpleVolumeEnvTexture;
  uint Padding5484;
  uint BindlessSampler_SimpleVolumeEnvTextureSampler;
  uint Padding5492;
  uint BindlessSRV_SSProfilesTexture;
  uint Padding5500;
  uint BindlessSampler_SSProfilesSampler;
  uint Padding5508;
  uint BindlessSampler_SSProfilesTransmissionSampler;
  uint Padding5516;
  uint BindlessSRV_SSProfilesPreIntegratedTexture;
  uint Padding5524;
  uint BindlessSampler_SSProfilesPreIntegratedSampler;
  uint Padding5532;
  uint BindlessSRV_SpecularProfileTexture;
  uint Padding5540;
  uint BindlessSampler_SpecularProfileSampler;
  uint Padding5548;
  uint BindlessSRV_WaterIndirection;
  uint Padding5556;
  uint BindlessSRV_WaterData;
  uint Padding5564;
  float4 RectLightAtlasSizeAndInvSize;
  float RectLightAtlasMaxMipLevel;
  float Padding5588;
  uint BindlessSRV_RectLightAtlasTexture;
  uint Padding5596;
  uint BindlessSampler_RectLightAtlasSampler;
  uint Padding5604;
  uint Padding5608;
  uint Padding5612;
  float4 IESAtlasSizeAndInvSize;
  uint BindlessSRV_IESAtlasTexture;
  uint Padding5636;
  uint BindlessSampler_IESAtlasSampler;
  uint Padding5644;
  uint BindlessSampler_LandscapeWeightmapSampler;
  uint Padding5652;
  uint BindlessSRV_LandscapeIndirection;
  uint Padding5660;
  uint BindlessSRV_LandscapePerComponentData;
  uint Padding5668;
  uint BindlessUAV_VTFeedbackBuffer;
  uint Padding5676;
  uint BindlessSRV_PhysicsFieldClipmapBuffer;
  uint Padding5684;
  uint Padding5688;
  uint Padding5692;
  float3 TLASPreViewTranslationHigh;
  float Padding5708;
  float3 TLASPreViewTranslationLow;
};

struct FLightFunctionAtlasConstants {
  uint BindlessSRV_LightFunctionAtlasTexture;
  uint Padding4;
  uint BindlessSRV_LightInfoDataBuffer;
  uint Padding12;
  uint BindlessSampler_LightFunctionAtlasSampler;
  uint Padding20;
  float Slot_UVSize;
};

struct FLumenGIVolumeStructConstants {
  float ReprojectionRadiusScale;
  float ClipmapWorldExtent;
  float ClipmapDistributionBase;
  float InvClipmapFadeSize;
  int2 ProbeAtlasResolutionInProbes;
  uint RadianceProbeClipmapResolution;
  uint NumRadianceProbeClipmaps;
  uint RadianceProbeResolution;
  uint FinalProbeResolution;
  uint FinalRadianceAtlasMaxMip;
  uint CalculateIrradiance;
  uint IrradianceProbeResolution;
  uint OcclusionProbeResolution;
  uint NumProbesToTraceBudget;
  uint RadianceCacheStats;
  uint BindlessSRV_RadianceProbeIndirectionTexture;
  uint Padding68;
  uint BindlessSRV_RadianceCacheFinalRadianceAtlas;
  uint Padding76;
  uint BindlessSRV_RadianceCacheFinalIrradianceAtlas;
  uint Padding84;
  uint BindlessSRV_RadianceCacheProbeOcclusionAtlas;
  uint Padding92;
  uint BindlessSRV_RadianceCacheDepthAtlas;
  uint Padding100;
  uint BindlessSRV_ProbeWorldOffset;
  uint Padding108;
  float4 RadianceProbeSettings[6];
  float4 PaddedWorldPositionToRadianceProbeCoordBias[6];
  float4 PaddedRadianceProbeCoordToWorldPositionBias[6];
  float2 InvProbeFinalRadianceAtlasResolution;
  float2 InvProbeFinalIrradianceAtlasResolution;
  float2 InvProbeDepthAtlasResolution;
  uint OverrideCacheOcclusionLighting;
  uint ShowBlackRadianceCacheLighting;
  uint ProbeAtlasResolutionModuloMask;
  uint ProbeAtlasResolutionDivideShift;
  float Padding440;
  float Padding444;
  uint BindlessSRV_Radiance;
  uint Padding452;
  uint BindlessSRV_Normal;
  uint Padding460;
  uint BindlessSRV_SceneDepth;
  uint Padding468;
  uint Enabled;
  float RelativeDepthThreshold;
  float SpecularScale;
  float Contrast;
  float Padding488;
  float Padding492;
  uint BindlessSRV_TranslucencyGIVolume0;
  uint Padding500;
  uint BindlessSRV_TranslucencyGIVolume1;
  uint Padding508;
  uint BindlessSRV_TranslucencyGIVolumeHistory0;
  uint Padding516;
  uint BindlessSRV_TranslucencyGIVolumeHistory1;
  uint Padding524;
  uint BindlessSampler_TranslucencyGIVolumeSampler;
  uint Padding532;
  uint Padding536;
  uint Padding540;
  float3 TranslucencyGIGridZParams;
  uint TranslucencyGIGridPixelSizeShift;
  int3 TranslucencyGIGridSize;
};

struct FVirtualShadowMapConstants {
  uint NumFullShadowMaps;
  uint NumSinglePageShadowMaps;
  uint MaxPhysicalPages;
  uint NumShadowMapSlots;
  uint StaticCachedArrayIndex;
  uint PhysicalPageRowMask;
  uint PhysicalPageRowShift;
  uint PackedShadowMaskMaxLightCount;
  float4 RecPhysicalPoolSize;
  int2 PhysicalPoolSize;
  int2 PhysicalPoolSizePages;
  uint bExcludeNonNaniteFromCoarsePages;
  float CoarsePagePixelThresholdDynamic;
  float CoarsePagePixelThresholdStatic;
  float CoarsePagePixelThresholdDynamicNanite;
  uint SceneFrameNumber;
  uint bClipmapGreedyLevelSelection;
  float GlobalResolutionLodBias;
  float Padding92;
  uint BindlessSRV_ProjectionData;
  uint Padding100;
  uint BindlessSRV_PageTable;
  uint Padding108;
  uint BindlessSRV_PageFlags;
  uint Padding116;
  uint BindlessSRV_PageRectBounds;
  uint Padding124;
  uint BindlessSRV_PhysicalPagePool;
  uint Padding132;
  uint BindlessSRV_CachePrimitiveAsDynamic;
  uint Padding140;
  uint BindlessSRV_LightGridData;
  uint Padding148;
  uint BindlessSRV_NumCulledLightsGrid;
};

struct FVolumetricFogConstants {
  int3 ViewGridSizeInt;
  int Padding12;
  float3 ViewGridSize;
  float Padding28;
  int3 ResourceGridSizeInt;
  int Padding44;
  float3 ResourceGridSize;
  float Padding60;
  float3 GridZParams;
  float Padding76;
  float2 SVPosToVolumeUV;
  float MaxDistance;
  float Padding92;
  float3 HeightFogInscatteringColor;
  float Padding108;
  float3 HeightFogDirectionalLightInscatteringColor;
  float Padding124;
  int2 FogGridToPixelXY;
};


Texture2D<float4> LightFunctionAtlas_LightFunctionAtlasTexture : register(t0);

StructuredBuffer<float4> LightFunctionAtlas_LightInfoDataBuffer : register(t1);

Texture2D<float4> ForwardLightData_DirectionalLightShadowmapAtlas : register(t2);

StructuredBuffer<float4> ForwardLightData_ForwardLocalLightBuffer : register(t3);

StructuredBuffer<uint> ForwardLightData_NumCulledLightsGrid : register(t4);

Buffer<uint> ForwardLightData_CulledLightDataGrid16Bit : register(t5);

Texture3D<float4> LumenGIVolumeStruct_TranslucencyGIVolume0 : register(t6);

Texture3D<float4> LumenGIVolumeStruct_TranslucencyGIVolume1 : register(t7);

ByteAddressBuffer VirtualShadowMap_ProjectionData : register(t8);

StructuredBuffer<uint> VirtualShadowMap_PageTable : register(t9);

Texture2DArray<uint> VirtualShadowMap_PhysicalPagePool : register(t10);

Texture2D<float> ConservativeDepthTexture : register(t11);

Texture2D<float> PrevConservativeDepthTexture : register(t12);

Texture3D<float4> VBufferA : register(t13);

Texture3D<float4> VBufferB : register(t14);

Texture3D<float4> LightScatteringHistory : register(t15);

Texture3D<float4> LocalShadowedLightScattering : register(t16);

Texture2D<float4> DirectionalLightLightFunctionTexture : register(t17);

RWTexture3D<float4> RWLightScattering : register(u0);

cbuffer _RootShaderParameters : register(b0) {
  uint4 _RootShaderParameters_raw[89];
};

cbuffer View : register(b1) {
  FViewConstants View : packoffset(c000.x);
};

cbuffer LightFunctionAtlas : register(b2) {
  FLightFunctionAtlasConstants LightFunctionAtlas : packoffset(c000.x);
};

cbuffer ForwardLightData : register(b3) {
  uint4 ForwardLightData_raw[46];
};

cbuffer LumenGIVolumeStruct : register(b4) {
  FLumenGIVolumeStructConstants LumenGIVolumeStruct : packoffset(c000.x);
};

cbuffer VirtualShadowMap : register(b5) {
  FVirtualShadowMapConstants VirtualShadowMap : packoffset(c000.x);
};

cbuffer VolumetricFog : register(b6) {
  FVolumetricFogConstants VolumetricFog : packoffset(c000.x);
};

SamplerState LightFunctionAtlas_LightFunctionAtlasSampler : register(s0);

SamplerState ForwardLightData_ShadowmapSampler : register(s1);

SamplerState LumenGIVolumeStruct_TranslucencyGIVolumeSampler : register(s2);

SamplerState LightScatteringHistorySampler : register(s3);

SamplerState DirectionalLightLightFunctionSampler : register(s4);

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
  float _45;
  float _46;
  float _47;
  float _48;
  float _49;
  float _87;
  int _202;
  float _255;
  float _357;
  int _371;
  float _373;
  float _374;
  float _375;
  int _376;
  float _474;
  float _656;
  int _830;
  int _910;
  int _917;
  int _918;
  float _919;
  float _920;
  int _921;
  int _922;
  float _940;
  bool _941;
  int _1008;
  int _1036;
  int _1037;
  int _1038;
  int _1039;
  int _1040;
  int _1041;
  int _1042;
  int _1043;
  int _1044;
  int _1045;
  int _1046;
  int _1047;
  int _1048;
  int _1049;
  int _1050;
  int _1051;
  int _1052;
  int _1100;
  float _1128;
  bool _1129;
  float _1134;
  float _1137;
  float _1242;
  float _1243;
  float _1305;
  float _1319;
  float _1320;
  float _1321;
  float _1348;
  float _1349;
  float _1350;
  float _1351;
  float _1547;
  float _1604;
  float _1605;
  float _1606;
  int _1607;
  float _1708;
  float _1717;
  float _1723;
  float _1831;
  float _1832;
  float _1833;
  float _1834;
  float _1835;
  float _1984;
  float _1987;
  float _2087;
  float _2088;
  float _2125;
  float _2155;
  float _2156;
  float _2157;
  float _2162;
  float _2163;
  float _2164;
  float _2203;
  float _2204;
  float _2205;
  float _2250;
  float _2251;
  float _2252;
  float _2253;
  float _58;
  float _60;
  float _69;
  float _123;
  float _124;
  float _125;
  float _126;
  float _147;
  float _182;
  float _226;
  float _228;
  float _237;
  float _291;
  float _292;
  float _293;
  float _294;
  float _306;
  float _337;
  float _338;
  float _339;
  uint _386;
  uint _387;
  uint _388;
  uint _390;
  uint _392;
  uint _394;
  uint _396;
  int _402;
  int _403;
  uint _406;
  uint _408;
  float4 _424;
  float _433;
  float _434;
  float _435;
  float _445;
  float _447;
  float _456;
  float _510;
  float _511;
  float _512;
  float _513;
  float _525;
  float _526;
  float _527;
  float _532;
  float _533;
  float _534;
  float _540;
  float _541;
  float _542;
  float _543;
  float _552;
  float _553;
  float _554;
  int _585;
  int _588;
  float4 _590;
  float4 _595;
  float4 _600;
  float4 _605;
  float _620;
  float _621;
  float _622;
  float4 _624;
  uint _658;
  int _670;
  uint _672;
  uint _673;
  int _676;
  int _677;
  int _678;
  int _683;
  int _684;
  int _685;
  int _691;
  int _695;
  int _696;
  int _697;
  int _703;
  int _706;
  float _719;
  float _720;
  float _721;
  int _737;
  int _740;
  uint _741;
  int _744;
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
  int _833;
  int _834;
  int _835;
  bool _838;
  uint _840;
  int _848;
  int _849;
  uint _850;
  int _853;
  int _857;
  int _858;
  int _865;
  int _870;
  uint _872;
  uint _873;
  float _882;
  int _912;
  int _946;
  int _947;
  int _948;
  int _949;
  int _950;
  int _951;
  int _952;
  int _953;
  int _954;
  int _955;
  int _956;
  int _957;
  int _958;
  int _959;
  int _960;
  int _961;
  int _963;
  int _964;
  int _965;
  int _970;
  int _971;
  int _972;
  float _985;
  float _986;
  float _987;
  float _990;
  float _991;
  float _993;
  uint _1009;
  uint _1010;
  int _1013;
  int _1014;
  int _1015;
  int _1016;
  int _1019;
  int _1020;
  int _1021;
  int _1022;
  int _1025;
  int _1026;
  int _1027;
  int _1028;
  int _1031;
  int _1032;
  int _1033;
  int _1034;
  float _1084;
  float _1085;
  float _1086;
  bool _1088;
  int _1103;
  float _1109;
  uint _1145;
  float _1148;
  float _1149;
  float _1150;
  int _1151;
  int _1152;
  float _1156;
  float _1165;
  float _1166;
  float _1167;
  float _1168;
  float _1171;
  float _1172;
  float _1173;
  float _1174;
  float _1177;
  float _1178;
  float _1179;
  float _1180;
  float _1183;
  float _1184;
  float _1185;
  float _1186;
  float _1202;
  float _1203;
  float _1204;
  float _1205;
  float _1207;
  float _1208;
  float _1217;
  float _1218;
  float _1219;
  float _1222;
  bool _1225;
  bool _1226;
  bool _1227;
  bool _1228;
  float _1259;
  float _1260;
  float _1261;
  float _1314;
  float _1332;
  float _1336;
  float _1337;
  float _1352;
  float _1353;
  float _1354;
  float _1378;
  float _1379;
  float _1380;
  float _1381;
  float _1382;
  float _1383;
  float _1396;
  float _1397;
  float _1398;
  float _1410;
  float _1424;
  float _1427;
  float _1428;
  float4 _1431;
  float4 _1436;
  float _1441;
  float _1442;
  float _1443;
  float _1444;
  float _1460;
  float _1461;
  float _1462;
  int _1484;
  uint _1495;
  int _1498;
  int _1499;
  int _1502;
  float _1517;
  float _1519;
  float _1529;
  float _1583;
  float _1587;
  float _1588;
  float _1589;
  float _1599;
  float _1600;
  uint _1612;
  float _1616;
  float _1617;
  float _1618;
  float _1621;
  float _1622;
  float _1623;
  float _1626;
  float _1627;
  float _1628;
  float _1631;
  float _1632;
  float _1634;
  int _1635;
  float _1637;
  float _1640;
  float _1641;
  float _1642;
  float _1643;
  float _1644;
  float _1645;
  float _1648;
  int _1649;
  int _1651;
  int _1652;
  float _1666;
  float _1667;
  float _1668;
  float _1669;
  bool _1670;
  bool _1672;
  int _1673;
  float _1675;
  float _1679;
  int _1681;
  float _1682;
  float _1683;
  float _1684;
  float _1685;
  float _1686;
  float _1687;
  float _1688;
  float _1689;
  float _1692;
  float _1695;
  float _1698;
  float _1699;
  float _1700;
  float _1713;
  float _1727;
  float _1730;
  float _1733;
  float _1738;
  float _1741;
  float _1744;
  float _1748;
  float _1749;
  float _1753;
  float _1764;
  float _1765;
  float _1779;
  float _1786;
  float _1787;
  float _1798;
  float _1799;
  float _1808;
  float _1809;
  float _1812;
  float _1813;
  float _1840;
  float _1841;
  float _1842;
  float _1843;
  float _1844;
  float _1845;
  float _1846;
  float _1847;
  float _1850;
  float _1851;
  float _1852;
  float _1853;
  float _1856;
  float _1857;
  float _1858;
  float _1859;
  float _1862;
  float _1863;
  float _1864;
  float _1865;
  float _1868;
  float _1869;
  float _1870;
  float _1871;
  float _1872;
  float _1873;
  float _1874;
  float _1875;
  float _1884;
  float _1893;
  float _1895;
  float _1902;
  float _1903;
  float _1904;
  float _1918;
  float _1922;
  float _1923;
  float _1924;
  float _1934;
  float _1935;
  float _1936;
  float _1949;
  float _1950;
  float _1951;
  float _1952;
  float _1957;
  float _1958;
  float _1959;
  float _1960;
  float _1961;
  float _1962;
  float _1963;
  float _1964;
  float _1965;
  float _1966;
  float _1968;
  float _1973;
  int _1990;
  float _1993;
  float _1994;
  float _1995;
  int _1996;
  int _1997;
  float _2001;
  float _2010;
  float _2011;
  float _2012;
  float _2013;
  float _2016;
  float _2017;
  float _2018;
  float _2019;
  float _2022;
  float _2023;
  float _2024;
  float _2025;
  float _2028;
  float _2029;
  float _2030;
  float _2031;
  float _2047;
  float _2048;
  float _2049;
  float _2050;
  float _2052;
  float _2053;
  float _2062;
  float _2063;
  float _2064;
  float _2067;
  bool _2070;
  bool _2071;
  bool _2072;
  bool _2073;
  float _2108;
  float _2109;
  float _2110;
  float _2140;
  float _2147;
  uint _2158;
  int _2165;
  float _2168;
  float4 _2175;
  float4 _2186;
  float _2192;
  float4 _2198;
  float _2213;
  float _2214;
  float _2215;
  float4 _2226;
  float _2233;
  _45 = float((uint)SV_DispatchThreadID.x);
  _46 = float((uint)SV_DispatchThreadID.y);
  _47 = _45 + 0.5f;
  _48 = _46 + 0.5f;
  _49 = float((uint)SV_DispatchThreadID.z);
  if (asint(_RootShaderParameters_raw[87u].z) == 0) {
    _202 = 0;
    _226 = ((_47 / VolumetricFog.ViewGridSize.x) * 2.0f) + -1.0f;
    _228 = -0.0f - (((_48 / VolumetricFog.ViewGridSize.y) * 2.0f) + -1.0f);
    _237 = (exp2((_49 + 0.5f) / VolumetricFog.GridZParams.z) - VolumetricFog.GridZParams.y) / VolumetricFog.GridZParams.x;
    [branch]
    if (!((View.ViewToClip[3].w) >= 1.0f)) {
      _255 = (1.0f / ((_237 + View.InvDeviceZToWorldZTransform.w) * View.InvDeviceZToWorldZTransform.z));
    } else {
      _255 = ((_237 * (View.ViewToClip[2].z)) + (View.ViewToClip[3].z));
    }
    _291 = mad(1.0f, asfloat(_RootShaderParameters_raw[8u].w), mad(_255, asfloat(_RootShaderParameters_raw[7u].w), mad(_228, asfloat(_RootShaderParameters_raw[6u].w), (_226 * asfloat(_RootShaderParameters_raw[5u].w)))));
    _292 = mad(1.0f, asfloat(_RootShaderParameters_raw[8u].x), mad(_255, asfloat(_RootShaderParameters_raw[7u].x), mad(_228, asfloat(_RootShaderParameters_raw[6u].x), (_226 * asfloat(_RootShaderParameters_raw[5u].x))))) / _291;
    _293 = mad(1.0f, asfloat(_RootShaderParameters_raw[8u].y), mad(_255, asfloat(_RootShaderParameters_raw[7u].y), mad(_228, asfloat(_RootShaderParameters_raw[6u].y), (_226 * asfloat(_RootShaderParameters_raw[5u].y))))) / _291;
    _294 = mad(1.0f, asfloat(_RootShaderParameters_raw[8u].z), mad(_255, asfloat(_RootShaderParameters_raw[7u].z), mad(_228, asfloat(_RootShaderParameters_raw[6u].z), (_226 * asfloat(_RootShaderParameters_raw[5u].z))))) / _291;
    _306 = mad(1.0f, asfloat(_RootShaderParameters_raw[12u].w), mad(_294, asfloat(_RootShaderParameters_raw[11u].w), mad(_293, asfloat(_RootShaderParameters_raw[10u].w), (asfloat(_RootShaderParameters_raw[9u].w) * _292))));
    _337 = min(((((mad(1.0f, asfloat(_RootShaderParameters_raw[12u].x), mad(_294, asfloat(_RootShaderParameters_raw[11u].x), mad(_293, asfloat(_RootShaderParameters_raw[10u].x), (asfloat(_RootShaderParameters_raw[9u].x) * _292)))) / _306) * 0.5f) + 0.5f) * (View.VolumetricFogViewGridUVToPrevViewRectUV.x * View.VolumetricFogPrevViewGridRectUVToResourceUV.x)), View.VolumetricFogPrevUVMaxForTemporalBlend.x);
    _338 = min(((0.5f - ((mad(1.0f, asfloat(_RootShaderParameters_raw[12u].y), mad(_294, asfloat(_RootShaderParameters_raw[11u].y), mad(_293, asfloat(_RootShaderParameters_raw[10u].y), (asfloat(_RootShaderParameters_raw[9u].y) * _292)))) / _306) * 0.5f)) * (View.VolumetricFogViewGridUVToPrevViewRectUV.y * View.VolumetricFogPrevViewGridRectUVToResourceUV.y)), View.VolumetricFogPrevUVMaxForTemporalBlend.y);
    _339 = min(((log2((_306 * View.VolumetricFogGridZParams.x) + View.VolumetricFogGridZParams.y) * View.VolumetricFogGridZParams.z) * View.VolumetricFogInvGridSize.z), 1.0f);
    if ((((int)((int)(_337 < 0.0f) || (int)(_338 < 0.0f))) || (int)(_339 < 0.0f)) | ((int)(_202 != 0) || ((int)((int)(_339 >= 1.0f) || ((int)((int)(_337 >= View.VolumetricFogPrevUVMaxForTemporalBlend.x) || (int)(_338 >= View.VolumetricFogPrevUVMaxForTemporalBlend.y))))))) {
      _357 = 0.0f;
    } else {
      _357 = asfloat(_RootShaderParameters_raw[29u].x);
    }
    if (_357 < 0.0010000000474974513f) {
      _371 = select(((int)((int)(int)(SV_DispatchThreadID.z) < (int)VolumetricFog.ViewGridSizeInt.z) && ((int)((int)((int)(int)(SV_DispatchThreadID.x) < (int)VolumetricFog.ViewGridSizeInt.x) && (int)((int)(int)(SV_DispatchThreadID.y) < (int)VolumetricFog.ViewGridSizeInt.y)))), 8, 1);
    } else {
      _371 = 1;
    }
    _373 = 0.0f;
    _374 = 0.0f;
    _375 = 0.0f;
    _376 = 0;
    while(true) {
      _386 = ((int)(SV_DispatchThreadID.y) * 1664525) + 1013904223u;
      _387 = ((int)(SV_DispatchThreadID.z) * 1664525) + 1013904223u;
      _388 = (((int)((uint)(View.StateFrameIndexMod8) + (_376 << 3))) * 1664525) + 1013904223u;
      _390 = (((int)(SV_DispatchThreadID.x) * 1664525) + 1013904223u) + (_388 * _386);
      _392 = (_390 * _387) + _386;
      _394 = (_392 * _390) + _387;
      _396 = (_394 * _392) + _388;
      _402 = ((uint)(_392) >> 16) ^ _392;
      _403 = ((uint)(_394) >> 16) ^ _394;
      _406 = ((((uint)(_396) >> 16) ^ _396) * _402) + ((uint)(((uint)(_390) >> 16) ^ _390));
      _408 = (_406 * _403) + _402;
      _424 = asfloat(_RootShaderParameters_raw[((int)(_376 + 13))]);
      if (InjectionToggle(TOGGLE_USE_ISFAST_FOG)) {
        uint _fast_slice = (View.FrameCounter + (uint)_376) % 32u;
        float2 _fast_n = FastNoiseLoad(
            SV_DispatchThreadID.x % 128u, SV_DispatchThreadID.y % 128u, _fast_slice);
        float _fast_z_n = FastNoiseLoad(
            SV_DispatchThreadID.z % 128u, (SV_DispatchThreadID.x ^ SV_DispatchThreadID.y) % 128u, (_fast_slice + 16u) % 32u).x;
        _433 = _424.x + (asfloat(_RootShaderParameters_raw[86u].z) * ((_fast_n.x * 2.0f) - 1.0f));
        _434 = _424.y + (asfloat(_RootShaderParameters_raw[86u].z) * ((_fast_n.y * 2.0f) - 1.0f));
        _435 = _424.z + (asfloat(_RootShaderParameters_raw[86u].z) * ((_fast_z_n * 2.0f) - 1.0f));
      } else {
        _433 = _424.x + (asfloat(_RootShaderParameters_raw[86u].z) * (((float((uint)_406) * 2.3283064365386963e-10f) * 2.0f) + -1.0f));
        _434 = _424.y + (asfloat(_RootShaderParameters_raw[86u].z) * (((float((uint)_408) * 2.3283064365386963e-10f) * 2.0f) + -1.0f));
        _435 = _424.z + (asfloat(_RootShaderParameters_raw[86u].z) * (((float((uint)((_408 * _406) + _403)) * 2.3283064365386963e-10f) * 2.0f) + -1.0f));
      }
      _445 = (((_45 + _433) / VolumetricFog.ViewGridSize.x) * 2.0f) + -1.0f;
      _447 = -0.0f - ((((_46 + _434) / VolumetricFog.ViewGridSize.y) * 2.0f) + -1.0f);
      _456 = (exp2((_49 + _435) / VolumetricFog.GridZParams.z) - VolumetricFog.GridZParams.y) / VolumetricFog.GridZParams.x;
      [branch]
      if (!((View.ViewToClip[3].w) >= 1.0f)) {
        _474 = (1.0f / ((_456 + View.InvDeviceZToWorldZTransform.w) * View.InvDeviceZToWorldZTransform.z));
      } else {
        _474 = ((_456 * (View.ViewToClip[2].z)) + (View.ViewToClip[3].z));
      }
      _510 = mad(1.0f, asfloat(_RootShaderParameters_raw[8u].w), mad(_474, asfloat(_RootShaderParameters_raw[7u].w), mad(_447, asfloat(_RootShaderParameters_raw[6u].w), (_445 * asfloat(_RootShaderParameters_raw[5u].w)))));
      _511 = mad(1.0f, asfloat(_RootShaderParameters_raw[8u].x), mad(_474, asfloat(_RootShaderParameters_raw[7u].x), mad(_447, asfloat(_RootShaderParameters_raw[6u].x), (_445 * asfloat(_RootShaderParameters_raw[5u].x))))) / _510;
      _512 = mad(1.0f, asfloat(_RootShaderParameters_raw[8u].y), mad(_474, asfloat(_RootShaderParameters_raw[7u].y), mad(_447, asfloat(_RootShaderParameters_raw[6u].y), (_445 * asfloat(_RootShaderParameters_raw[5u].y))))) / _510;
      _513 = mad(1.0f, asfloat(_RootShaderParameters_raw[8u].z), mad(_474, asfloat(_RootShaderParameters_raw[7u].z), mad(_447, asfloat(_RootShaderParameters_raw[6u].z), (_445 * asfloat(_RootShaderParameters_raw[5u].z))))) / _510;
      _525 = _511 - (View.PreViewTranslationHigh.x + View.PreViewTranslationLow.x);
      _526 = _512 - (View.PreViewTranslationHigh.y + View.PreViewTranslationLow.y);
      _527 = _513 - (View.PreViewTranslationHigh.z + View.PreViewTranslationLow.z);
      _532 = _511 - View.TranslatedWorldCameraOrigin.x;
      _533 = _512 - View.TranslatedWorldCameraOrigin.y;
      _534 = _513 - View.TranslatedWorldCameraOrigin.z;
      _540 = sqrt(((_532 * _532) + (_533 * _533)) + (_534 * _534));
      _541 = _532 / _540;
      _542 = _533 / _540;
      _543 = _534 / _540;
      _552 = asfloat(ForwardLightData_raw[6u].w) * asfloat(ForwardLightData_raw[6u].x);
      _553 = asfloat(ForwardLightData_raw[6u].w) * asfloat(ForwardLightData_raw[6u].y);
      _554 = asfloat(ForwardLightData_raw[6u].w) * asfloat(ForwardLightData_raw[6u].z);
      [branch]
      if (asint(ForwardLightData_raw[0u].z) == 0) {
        _1348 = asfloat(_RootShaderParameters_raw[86u].x);
        _1349 = _373;
        _1350 = _374;
        _1351 = _375;
      } else {
        if (asfloat(_RootShaderParameters_raw[87u].y) > 0.0f) {
          if (!(asint(ForwardLightData_raw[8u].x) == 0)) {
            _585 = ((((int)(uint)((int)(_456 >= asfloat(ForwardLightData_raw[9u].x)))) + ((int)(uint)((int)(_456 >= asfloat(ForwardLightData_raw[9u].y))))) + ((int)(uint)((int)(_456 >= asfloat(ForwardLightData_raw[9u].z))))) + ((int)(uint)((int)(_456 >= asfloat(ForwardLightData_raw[9u].w))));
            if ((uint)_585 < (uint)asint(ForwardLightData_raw[8u].x)) {
              _588 = _585 << 2;
              _590 = asfloat(ForwardLightData_raw[((int)(_588 + 10))]);
              _595 = asfloat(ForwardLightData_raw[((int)(_588 + 11))]);
              _600 = asfloat(ForwardLightData_raw[((int)(_588 + 12))]);
              _605 = asfloat(ForwardLightData_raw[((int)(_588 + 13))]);
              _620 = mad(_513, _600.w, mad(_512, _595.w, (_590.w * _511))) + _605.w;
              _621 = (mad(_513, _600.x, mad(_512, _595.x, (_590.x * _511))) + _605.x) / _620;
              _622 = (mad(_513, _600.y, mad(_512, _595.y, (_590.y * _511))) + _605.y) / _620;
              _624 = asfloat(ForwardLightData_raw[((int)(_585 + 26))]);
              if (((int)((int)(_621 >= _624.x) && (int)(_621 <= _624.z))) && ((int)((int)(_622 >= _624.y) && (int)(_622 <= _624.w)))) {
                _656 = float((bool)(uint)(((1.0f - _605.z) - mad(_513, _600.z, mad(_512, _595.z, (_590.z * _511)))) < ((((float4)(ForwardLightData_DirectionalLightShadowmapAtlas.SampleLevel(ForwardLightData_ShadowmapSampler, float2(_621, _622), 0.0f))).x) - asfloat(ForwardLightData_raw[31u].x))));
              } else {
                _656 = 1.0f;
              }
            } else {
              _656 = 1.0f;
            }
          } else {
            _656 = 1.0f;
          }
          _658 = asint(ForwardLightData_raw[8u].y) * 288;
          _670 = asint(VirtualShadowMap_ProjectionData.Load(((int)(_658 + 204u))));
          _672 = _658 + 208u;
          _673 = _658 + 224u;
          if (_670 == 0) {
            _676 = asint(VirtualShadowMap_ProjectionData.Load3(_672)).x;
            _677 = asint(VirtualShadowMap_ProjectionData.Load3(_672)).y;
            _678 = asint(VirtualShadowMap_ProjectionData.Load3(_672)).z;
            _683 = asint(VirtualShadowMap_ProjectionData.Load3(_673)).x;
            _684 = asint(VirtualShadowMap_ProjectionData.Load3(_673)).y;
            _685 = asint(VirtualShadowMap_ProjectionData.Load3(_673)).z;
            _691 = asint(VirtualShadowMap_ProjectionData.Load(((int)(_658 + 236u))));
            _695 = asint(VirtualShadowMap_ProjectionData.Load3(((int)(_658 + 240u)))).x;
            _696 = asint(VirtualShadowMap_ProjectionData.Load3(((int)(_658 + 240u)))).y;
            _697 = asint(VirtualShadowMap_ProjectionData.Load3(((int)(_658 + 240u)))).z;
            _703 = asint(VirtualShadowMap_ProjectionData.Load(((int)(_658 + 264u))));
            _706 = asint(VirtualShadowMap_ProjectionData.Load(((int)(_658 + 268u))));
            _719 = _511 + (asfloat(_695) + ((asfloat(_676) - View.PreViewTranslationHigh.x) + (asfloat(_683) - View.PreViewTranslationLow.x)));
            _720 = _512 + (asfloat(_696) + ((asfloat(_677) - View.PreViewTranslationHigh.y) + (asfloat(_684) - View.PreViewTranslationLow.y)));
            _721 = _513 + (asfloat(_697) + ((asfloat(_678) - View.PreViewTranslationHigh.z) + (asfloat(_685) - View.PreViewTranslationLow.z)));
            _737 = max((int)(0), (int)((int(floor(log2(sqrt((_721 * _721) + ((_719 * _719) + (_720 * _720)))) + select((VirtualShadowMap.bClipmapGreedyLevelSelection != 0), 0.0f, asfloat(_691)))) - _703)));
            if ((int)_737 < (int)_706) {
              _740 = _737 + asint(ForwardLightData_raw[8u].y);
              _741 = _740 * 288;
              _744 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_741 + 48u)))).z;
              _748 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_741 + 64u)))).x;
              _749 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_741 + 64u)))).y;
              _750 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_741 + 64u)))).z;
              _756 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_741 + 80u)))).x;
              _757 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_741 + 80u)))).y;
              _758 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_741 + 80u)))).z;
              _764 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_741 + 96u)))).x;
              _765 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_741 + 96u)))).y;
              _766 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_741 + 96u)))).z;
              _772 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_741 + 112u)))).x;
              _773 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_741 + 112u)))).y;
              _774 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_741 + 112u)))).z;
              _780 = asint(VirtualShadowMap_ProjectionData.Load3(((int)(_741 + 208u)))).x;
              _781 = asint(VirtualShadowMap_ProjectionData.Load3(((int)(_741 + 208u)))).y;
              _782 = asint(VirtualShadowMap_ProjectionData.Load3(((int)(_741 + 208u)))).z;
              _788 = asint(VirtualShadowMap_ProjectionData.Load3(((int)(_741 + 224u)))).x;
              _789 = asint(VirtualShadowMap_ProjectionData.Load3(((int)(_741 + 224u)))).y;
              _790 = asint(VirtualShadowMap_ProjectionData.Load3(((int)(_741 + 224u)))).z;
              _803 = ((asfloat(_780) - View.PreViewTranslationHigh.x) + (asfloat(_788) - View.PreViewTranslationLow.x)) + _511;
              _804 = ((asfloat(_781) - View.PreViewTranslationHigh.y) + (asfloat(_789) - View.PreViewTranslationLow.y)) + _512;
              _805 = ((asfloat(_782) - View.PreViewTranslationHigh.z) + (asfloat(_790) - View.PreViewTranslationLow.z)) + _513;
              _809 = mad(_805, asfloat(_764), mad(_804, asfloat(_756), (_803 * asfloat(_748)))) + asfloat(_772);
              _813 = mad(_805, asfloat(_765), mad(_804, asfloat(_757), (_803 * asfloat(_749)))) + asfloat(_773);
              _820 = uint(_809 * 128.0f);
              _821 = uint(_813 * 128.0f);
              if (!((uint)_740 < (uint)8192)) {
                _830 = ((int)((((_740 * 21845) + (uint)(-178946048)) + _820) + (_821 << 7)));
              } else {
                _830 = _740;
              }
              _833 = VirtualShadowMap_PageTable[_830];
              _834 = (uint)(_833) >> 20;
              _835 = _834 & 63;
              if ((int)_833 < (int)0) {
                _838 = (_835 == 0);
                _840 = _835 + _740;
                if (!_838) {
                  _848 = asint(VirtualShadowMap_ProjectionData.Load2(((int)(_741 + 256u)))).x;
                  _849 = asint(VirtualShadowMap_ProjectionData.Load2(((int)(_741 + 256u)))).y;
                  _850 = _840 * 288;
                  _853 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_850 + 48u)))).z;
                  _857 = asint(VirtualShadowMap_ProjectionData.Load2(((int)(_850 + 256u)))).x;
                  _858 = asint(VirtualShadowMap_ProjectionData.Load2(((int)(_850 + 256u)))).y;
                  _865 = _834 & 31;
                  _870 = (uint)((_820 - (_848 << 5)) + (((int)(_857 << 5)) << _865)) >> _865;
                  _872 = _870 << 7;
                  _873 = ((uint)((_821 - (_849 << 5)) + (((int)(_858 << 5)) << _865)) >> _865) << 7;
                  _882 = 1.0f / float((uint)(1 << _865));
                  if (!((uint)_840 < (uint)8192)) {
                    _910 = ((int)((((_840 * 21845) + (uint)(-178946048)) + _870) + _873));
                  } else {
                    _910 = _840;
                  }
                  _912 = VirtualShadowMap_PageTable[_910];
                  _917 = ((int)min((uint)(((int)max((uint)((int)(uint((((float((int)(_857)) - (_882 * float((int)(_848)))) * 0.25f) + (_882 * _809)) * 16384.0f))), (uint)(_872)))), (uint)((_872 | 127))));
                  _918 = ((int)min((uint)(((int)max((uint)((int)(uint((((float((int)(_858)) - (_882 * float((int)(_849)))) * 0.25f) + (_882 * _813)) * 16384.0f))), (uint)(_873)))), (uint)((_873 | 127))));
                  _919 = _882;
                  _920 = (asfloat(_853) - (_882 * asfloat(_744)));
                  _921 = ((int)(uint)((int)((_912 & -2081423360) == -2147483648)));
                  _922 = _912;
                } else {
                  _917 = (int)(uint(_809 * 16384.0f));
                  _918 = (int)(uint(_813 * 16384.0f));
                  _919 = 1.0f;
                  _920 = 0.0f;
                  _921 = ((int)(uint)(_838));
                  _922 = _833;
                }
                if (!(_921 == 0)) {
                  _940 = ((asfloat((((uint)(VirtualShadowMap_PhysicalPagePool.Load(int4(((((int)(_922 << 7)) & 130944) | (_917 & 127)), ((((uint)(_922) >> 3) & 130944) | (_918 & 127)), 0, 0)))).x)) - _920) / _919);
                  _941 = true;
                } else {
                  _940 = 0.0f;
                  _941 = false;
                }
              } else {
                _940 = 0.0f;
                _941 = false;
              }
              _1134 = select((_941 && (int)(_940 > (mad(_805, asfloat(_766), mad(_804, asfloat(_758), (_803 * asfloat(_750)))) + asfloat(_774)))), 0.0f, 1.0f);
            } else {
              _1134 = 1.0f;
            }
          } else {
            _946 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_658 + 112u)))).w;
            _947 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_658 + 112u)))).z;
            _948 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_658 + 112u)))).y;
            _949 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_658 + 112u)))).x;
            _950 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_658 + 96u)))).w;
            _951 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_658 + 96u)))).z;
            _952 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_658 + 96u)))).y;
            _953 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_658 + 96u)))).x;
            _954 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_658 + 80u)))).w;
            _955 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_658 + 80u)))).z;
            _956 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_658 + 80u)))).y;
            _957 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_658 + 80u)))).x;
            _958 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_658 + 64u)))).w;
            _959 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_658 + 64u)))).z;
            _960 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_658 + 64u)))).y;
            _961 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_658 + 64u)))).x;
            _963 = asint(VirtualShadowMap_ProjectionData.Load3(_672)).x;
            _964 = asint(VirtualShadowMap_ProjectionData.Load3(_672)).y;
            _965 = asint(VirtualShadowMap_ProjectionData.Load3(_672)).z;
            _970 = asint(VirtualShadowMap_ProjectionData.Load3(_673)).x;
            _971 = asint(VirtualShadowMap_ProjectionData.Load3(_673)).y;
            _972 = asint(VirtualShadowMap_ProjectionData.Load3(_673)).z;
            _985 = ((asfloat(_963) - View.PreViewTranslationHigh.x) + (asfloat(_970) - View.PreViewTranslationLow.x)) + _511;
            _986 = ((asfloat(_964) - View.PreViewTranslationHigh.y) + (asfloat(_971) - View.PreViewTranslationLow.y)) + _512;
            _987 = ((asfloat(_965) - View.PreViewTranslationHigh.z) + (asfloat(_972) - View.PreViewTranslationLow.z)) + _513;
            if (!(_670 == 2)) {
              _990 = abs(_985);
              _991 = abs(_986);
              _993 = abs(_987);
              if ((int)(_990 < _991) || (int)(_990 < _993)) {
                if (_991 > _993) {
                  _1008 = select((_986 > 0.0f), 2, 3);
                } else {
                  _1008 = select((_987 > 0.0f), 4, 5);
                }
              } else {
                _1008 = ((int)(uint)((int)(!(_985 > 0.0f))));
              }
              _1009 = _1008 + (uint)(asint(ForwardLightData_raw[8u].y));
              _1010 = _1009 * 288;
              _1013 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_1010 + 64u)))).x;
              _1014 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_1010 + 64u)))).y;
              _1015 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_1010 + 64u)))).z;
              _1016 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_1010 + 64u)))).w;
              _1019 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_1010 + 80u)))).x;
              _1020 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_1010 + 80u)))).y;
              _1021 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_1010 + 80u)))).z;
              _1022 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_1010 + 80u)))).w;
              _1025 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_1010 + 96u)))).x;
              _1026 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_1010 + 96u)))).y;
              _1027 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_1010 + 96u)))).z;
              _1028 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_1010 + 96u)))).w;
              _1031 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_1010 + 112u)))).x;
              _1032 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_1010 + 112u)))).y;
              _1033 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_1010 + 112u)))).z;
              _1034 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_1010 + 112u)))).w;
              _1036 = _1013;
              _1037 = _1014;
              _1038 = _1015;
              _1039 = _1016;
              _1040 = _1019;
              _1041 = _1020;
              _1042 = _1021;
              _1043 = _1022;
              _1044 = _1025;
              _1045 = _1026;
              _1046 = _1027;
              _1047 = _1028;
              _1048 = _1031;
              _1049 = _1032;
              _1050 = _1033;
              _1051 = _1034;
              _1052 = _1009;
            } else {
              _1036 = _961;
              _1037 = _960;
              _1038 = _959;
              _1039 = _958;
              _1040 = _957;
              _1041 = _956;
              _1042 = _955;
              _1043 = _954;
              _1044 = _953;
              _1045 = _952;
              _1046 = _951;
              _1047 = _950;
              _1048 = _949;
              _1049 = _948;
              _1050 = _947;
              _1051 = _946;
              _1052 = asint(ForwardLightData_raw[8u].y);
            }
            _1084 = mad(_987, asfloat(_1047), mad(_986, asfloat(_1043), (asfloat(_1039) * _985))) + asfloat(_1051);
            _1085 = (mad(_987, asfloat(_1044), mad(_986, asfloat(_1040), (asfloat(_1036) * _985))) + asfloat(_1048)) / _1084;
            _1086 = (mad(_987, asfloat(_1045), mad(_986, asfloat(_1041), (asfloat(_1037) * _985))) + asfloat(_1049)) / _1084;
            _1088 = ((uint)_1052 < (uint)8192);
            if (!_1088) {
              _1100 = ((int)((((_1052 * 21845) + (uint)(-178946048)) + uint(_1085 * 128.0f)) + ((int)(uint(_1086 * 128.0f)) << 7)));
            } else {
              _1100 = _1052;
            }
            _1103 = VirtualShadowMap_PageTable[_1100];
            _1109 = select(_1088, 128.0f, float((uint)((uint)((uint)(16384u) >> (((uint)(_1103) >> 20) & 31)))));
            if ((int)_1103 < (int)0) {
              _1128 = asfloat((((uint)(VirtualShadowMap_PhysicalPagePool.Load(int4((((int)(uint(_1109 * _1085)) & 127) | (((int)(_1103 << 7)) & 130944)), (((int)(uint(_1109 * _1086)) & 127) | (((uint)(_1103) >> 3) & 130944)), 0, 0)))).x));
              _1129 = true;
            } else {
              _1128 = 0.0f;
              _1129 = false;
            }
            _1134 = select((_1129 && (int)(_1128 > ((mad(_987, asfloat(_1046), mad(_986, asfloat(_1042), (asfloat(_1038) * _985))) + asfloat(_1050)) / _1084))), 0.0f, 1.0f);
          }
          _1137 = (_1134 * _656);
        } else {
          _1137 = 1.0f;
        }
        if (asint(_RootShaderParameters_raw[88u].y) == 0) {
          _1305 = (((float4)(DirectionalLightLightFunctionTexture.SampleLevel(DirectionalLightLightFunctionSampler, float2((((mad(_513, asfloat(_RootShaderParameters_raw[76u].x), mad(_512, asfloat(_RootShaderParameters_raw[75u].x), (asfloat(_RootShaderParameters_raw[74u].x) * _511))) + asfloat(_RootShaderParameters_raw[77u].x)) * 0.5f) + 0.5f), (0.5f - ((mad(_513, asfloat(_RootShaderParameters_raw[76u].y), mad(_512, asfloat(_RootShaderParameters_raw[75u].y), (asfloat(_RootShaderParameters_raw[74u].y) * _511))) + asfloat(_RootShaderParameters_raw[77u].y)) * 0.5f))), 0.0f))).x);
        } else {
          if (!(asint(_RootShaderParameters_raw[88u].z) == 0)) {
            _1145 = asint(_RootShaderParameters_raw[88u].z) * 5;
            _1148 = LightFunctionAtlas_LightInfoDataBuffer[_1145].x;
            _1149 = LightFunctionAtlas_LightInfoDataBuffer[_1145].y;
            _1150 = LightFunctionAtlas_LightInfoDataBuffer[_1145].z;
            _1151 = asint(_1149);
            _1152 = asint(_1150);
            _1156 = f16tof32(((uint)(((uint)(_1151) >> 8) & 65535)));
            _1165 = LightFunctionAtlas_LightInfoDataBuffer[((int)(_1145 + 1u))].x;
            _1166 = LightFunctionAtlas_LightInfoDataBuffer[((int)(_1145 + 1u))].y;
            _1167 = LightFunctionAtlas_LightInfoDataBuffer[((int)(_1145 + 1u))].z;
            _1168 = LightFunctionAtlas_LightInfoDataBuffer[((int)(_1145 + 1u))].w;
            _1171 = LightFunctionAtlas_LightInfoDataBuffer[((int)(_1145 + 2u))].x;
            _1172 = LightFunctionAtlas_LightInfoDataBuffer[((int)(_1145 + 2u))].y;
            _1173 = LightFunctionAtlas_LightInfoDataBuffer[((int)(_1145 + 2u))].z;
            _1174 = LightFunctionAtlas_LightInfoDataBuffer[((int)(_1145 + 2u))].w;
            _1177 = LightFunctionAtlas_LightInfoDataBuffer[((int)(_1145 + 3u))].x;
            _1178 = LightFunctionAtlas_LightInfoDataBuffer[((int)(_1145 + 3u))].y;
            _1179 = LightFunctionAtlas_LightInfoDataBuffer[((int)(_1145 + 3u))].z;
            _1180 = LightFunctionAtlas_LightInfoDataBuffer[((int)(_1145 + 3u))].w;
            _1183 = LightFunctionAtlas_LightInfoDataBuffer[((int)(_1145 + 4u))].x;
            _1184 = LightFunctionAtlas_LightInfoDataBuffer[((int)(_1145 + 4u))].y;
            _1185 = LightFunctionAtlas_LightInfoDataBuffer[((int)(_1145 + 4u))].z;
            _1186 = LightFunctionAtlas_LightInfoDataBuffer[((int)(_1145 + 4u))].w;
            _1202 = mad(_513, _1180, mad(_512, _1174, (_1168 * _511))) + _1186;
            _1203 = (mad(_513, _1179, mad(_512, _1173, (_1167 * _511))) + _1185) / _1202;
            _1204 = (mad(_513, _1178, mad(_512, _1172, (_1166 * _511))) + _1184) / _1202;
            _1205 = (mad(_513, _1177, mad(_512, _1171, (_1165 * _511))) + _1183) / _1202;
            switch (((int)(_1151 & 255))) {
              case 2: {
                _1207 = LightFunctionAtlas_LightInfoDataBuffer[_1145].w;
                _1208 = _1205 * _1207;
                _1242 = (((_1203 / _1208) * 0.5f) + 0.5f);
                _1243 = (((_1204 / _1208) * 0.5f) + 0.5f);
                break;
              }
              case 1: {
                _1217 = rsqrt(dot(float3(_1203, _1204, _1205), float3(_1203, _1204, _1205)));
                _1218 = _1217 * _1203;
                _1219 = _1217 * _1204;
                _1222 = atan(_1219 / _1218);
                _1225 = (_1218 < 0.0f);
                _1226 = (_1218 == 0.0f);
                _1227 = (_1219 >= 0.0f);
                _1228 = (_1219 < 0.0f);
                _1242 = select((_1226 && _1227), 0.75f, select((_1226 && _1228), 0.25f, ((select((_1225 && _1228), (_1222 + -3.1415927410125732f), select((_1225 && _1227), (_1222 + 3.1415927410125732f), _1222)) + 3.1415927410125732f) * 0.15915493667125702f)));
                _1243 = (acos(_1217 * _1205) * 0.31830987334251404f);
                break;
              }
              default: {
                _1242 = _1203;
                _1243 = _1204;
                break;
              }
            }
            _1259 = View.TranslatedWorldCameraOrigin.x - _511;
            _1260 = View.TranslatedWorldCameraOrigin.y - _512;
            _1261 = View.TranslatedWorldCameraOrigin.z - _513;
            _1305 = ((saturate((_1148 - sqrt(((_1259 * _1259) + (_1260 * _1260)) + (_1261 * _1261))) / (_1148 * 0.20000000298023224f)) * (((((float4)(LightFunctionAtlas_LightFunctionAtlasTexture.SampleLevel(LightFunctionAtlas_LightFunctionAtlasSampler, float2(((LightFunctionAtlas.Slot_UVSize * saturate(frac(_1242))) + (float((uint)((uint)(_1152 & 65535))) * 1.52587890625e-05f)), ((LightFunctionAtlas.Slot_UVSize * saturate(frac(_1243))) + (float((uint)((uint)((uint)(_1152) >> 16))) * 1.52587890625e-05f))), 0.0f))).x) * (((float4)(LightFunctionAtlas_LightFunctionAtlasTexture.SampleLevel(LightFunctionAtlas_LightFunctionAtlasSampler, float2(((LightFunctionAtlas.Slot_UVSize * saturate(frac(_1242))) + (float((uint)((uint)(_1152 & 65535))) * 1.52587890625e-05f)), ((LightFunctionAtlas.Slot_UVSize * saturate(frac(_1243))) + (float((uint)((uint)((uint)(_1152) >> 16))) * 1.52587890625e-05f))), 0.0f))).x)) - _1156)) + _1156);
          } else {
            _1305 = 1.0f;
          }
        }
        if (asfloat(_RootShaderParameters_raw[84u].z) > 0.0f) {
          _1314 = dot(float3(_552, _553, _554), float3(0.30000001192092896f, 0.5899999737739563f, 0.10999999940395355f));
          _1319 = (VolumetricFog.HeightFogDirectionalLightInscatteringColor.x * _1314);
          _1320 = (VolumetricFog.HeightFogDirectionalLightInscatteringColor.y * _1314);
          _1321 = (VolumetricFog.HeightFogDirectionalLightInscatteringColor.z * _1314);
        } else {
          _1319 = _552;
          _1320 = _553;
          _1321 = _554;
        }
        _1332 = (((dot(float3(asfloat(ForwardLightData_raw[4u].x), asfloat(ForwardLightData_raw[4u].y), asfloat(ForwardLightData_raw[4u].z)), float3((-0.0f - _541), (-0.0f - _542), (-0.0f - _543))) * 2.0f) + asfloat(_RootShaderParameters_raw[86u].x)) * asfloat(_RootShaderParameters_raw[86u].x)) + 1.0f;
        _1336 = (1.0f - (asfloat(_RootShaderParameters_raw[86u].x) * asfloat(_RootShaderParameters_raw[86u].x))) / ((sqrt(_1332) * 12.566370964050293f) * _1332);
        _1337 = _1305 * _1137;
        _1348 = asfloat(_RootShaderParameters_raw[86u].x);
        _1349 = (((_1337 * _1319) * _1336) + _373);
        _1350 = (((_1337 * _1320) * _1336) + _374);
        _1351 = (((_1337 * _1321) * _1336) + _375);
      }
      _1352 = _1348 * _542;
      _1353 = _1348 * _543;
      _1354 = _1348 * _541;
      _1378 = _525 - View.ViewOriginHigh.x;
      _1379 = _526 - View.ViewOriginHigh.y;
      _1380 = _527 - View.ViewOriginHigh.z;
      _1381 = _1378 - _525;
      _1382 = _1379 - _526;
      _1383 = _1380 - _527;
      _1396 = (((-0.0f - View.ViewOriginHigh.x) - _1381) + (_525 - (_1378 - _1381))) + _1378;
      _1397 = (((-0.0f - View.ViewOriginHigh.y) - _1382) + (_526 - (_1379 - _1382))) + _1379;
      _1398 = (((-0.0f - View.ViewOriginHigh.z) - _1383) + (_527 - (_1380 - _1383))) + _1380;
      _1410 = (View.RelativeWorldToClip[3].w) + mad(_1398, (View.RelativeWorldToClip[2].w), mad(_1397, (View.RelativeWorldToClip[1].w), (_1396 * (View.RelativeWorldToClip[0].w))));
      _1424 = (LumenGIVolumeStruct.TranslucencyGIGridZParams.z * log2((LumenGIVolumeStruct.TranslucencyGIGridZParams.x * _1410) + LumenGIVolumeStruct.TranslucencyGIGridZParams.y)) / float((int)(LumenGIVolumeStruct.TranslucencyGIGridSize.z));
      _1427 = ((((View.RelativeWorldToClip[3].x) + mad(_1398, (View.RelativeWorldToClip[2].x), mad(_1397, (View.RelativeWorldToClip[1].x), (_1396 * (View.RelativeWorldToClip[0].x))))) / _1410) * 0.5f) + 0.5f;
      _1428 = 0.5f - ((((View.RelativeWorldToClip[3].y) + mad(_1398, (View.RelativeWorldToClip[2].y), mad(_1397, (View.RelativeWorldToClip[1].y), (_1396 * (View.RelativeWorldToClip[0].y))))) / _1410) * 0.5f);
      _1431 = LumenGIVolumeStruct_TranslucencyGIVolume0.SampleLevel(LumenGIVolumeStruct_TranslucencyGIVolumeSampler, float3(_1427, _1428, _1424), 0.0f);
      _1436 = LumenGIVolumeStruct_TranslucencyGIVolume1.SampleLevel(LumenGIVolumeStruct_TranslucencyGIVolumeSampler, float3(_1427, _1428, _1424), 0.0f);
      _1441 = dot(float3(_1431.x, _1431.y, _1431.z), float3(0.30000001192092896f, 0.5899999737739563f, 0.10999999940395355f)) + 9.999999747378752e-06f;
      _1442 = _1431.x / _1441;
      _1443 = _1431.y / _1441;
      _1444 = _1431.z / _1441;
      _1460 = max(dot(float4(_1431.x, (_1442 * _1436.x), (_1442 * _1436.y), (_1442 * _1436.z)), float4(1.0f, _1352, _1353, _1354)), 0.0f) + _1349;
      _1461 = max(dot(float4(_1431.y, (_1443 * _1436.x), (_1443 * _1436.y), (_1443 * _1436.z)), float4(1.0f, _1352, _1353, _1354)), 0.0f) + _1350;
      _1462 = max(dot(float4(_1431.z, (_1444 * _1436.x), (_1444 * _1436.y), (_1444 * _1436.z)), float4(1.0f, _1352, _1353, _1354)), 0.0f) + _1351;
      _1484 = asint(ForwardLightData_raw[2u].x) & 31;
      _1495 = ((int)((((int)((asint(ForwardLightData_raw[1u].y) * ((int)min((uint)((int)(uint(max(0.0f, (log2((asfloat(ForwardLightData_raw[3u].x) * _456) + asfloat(ForwardLightData_raw[3u].y)) * asfloat(ForwardLightData_raw[3u].z)))))), (uint)((asint(ForwardLightData_raw[1u].z) + -1))))) + ((uint)((uint)(VolumetricFog.FogGridToPixelXY.y * (int)(SV_DispatchThreadID.y)) >> _1484)))) * asint(ForwardLightData_raw[1u].x)) + ((uint)((uint)(VolumetricFog.FogGridToPixelXY.x * (int)(SV_DispatchThreadID.x)) >> _1484)))) << 1;
      _1498 = ForwardLightData_NumCulledLightsGrid[_1495];
      _1499 = (int)min((uint)(_1498), (uint)(asint(ForwardLightData_raw[0u].x)));
      _1502 = ForwardLightData_NumCulledLightsGrid[(_1495 | 1)];
      _1517 = (((_433 + float((uint)(SV_DispatchThreadID.x + 1u))) / VolumetricFog.ViewGridSize.x) * 2.0f) + -1.0f;
      _1519 = -0.0f - ((((_434 + float((uint)(SV_DispatchThreadID.y + 1u))) / VolumetricFog.ViewGridSize.y) * 2.0f) + -1.0f);
      _1529 = (exp2((_435 + float((uint)(SV_DispatchThreadID.z + 1u))) / VolumetricFog.GridZParams.z) - VolumetricFog.GridZParams.y) / VolumetricFog.GridZParams.x;
      [branch]
      if ((View.ViewToClip[3].w) < 1.0f) {
        _1547 = (1.0f / ((View.InvDeviceZToWorldZTransform.w + _1529) * View.InvDeviceZToWorldZTransform.z));
      } else {
        _1547 = (((View.ViewToClip[2].z) * _1529) + (View.ViewToClip[3].z));
      }
      _1583 = mad(_1547, asfloat(_RootShaderParameters_raw[7u].w), mad(_1519, asfloat(_RootShaderParameters_raw[6u].w), (asfloat(_RootShaderParameters_raw[5u].w) * _1517))) + asfloat(_RootShaderParameters_raw[8u].w);
      _1587 = _511 - ((mad(_1547, asfloat(_RootShaderParameters_raw[7u].x), mad(_1519, asfloat(_RootShaderParameters_raw[6u].x), (asfloat(_RootShaderParameters_raw[5u].x) * _1517))) + asfloat(_RootShaderParameters_raw[8u].x)) / _1583);
      _1588 = _512 - ((mad(_1547, asfloat(_RootShaderParameters_raw[7u].y), mad(_1519, asfloat(_RootShaderParameters_raw[6u].y), (asfloat(_RootShaderParameters_raw[5u].y) * _1517))) + asfloat(_RootShaderParameters_raw[8u].y)) / _1583);
      _1589 = _513 - ((mad(_1547, asfloat(_RootShaderParameters_raw[7u].z), mad(_1519, asfloat(_RootShaderParameters_raw[6u].z), (asfloat(_RootShaderParameters_raw[5u].z) * _1517))) + asfloat(_RootShaderParameters_raw[8u].z)) / _1583);
      _1599 = max((asfloat(_RootShaderParameters_raw[86u].y) * sqrt(((_1588 * _1588) + (_1587 * _1587)) + (_1589 * _1589))), 1.0f);
      _1600 = _1599 * _1599;
      if (!(_1499 == 0)) {
        _1604 = _1460;
        _1605 = _1461;
        _1606 = _1462;
        _1607 = 0;
        while(true) {
          _1612 = (((uint)(ForwardLightData_CulledLightDataGrid16Bit.Load((int)(_1607 + _1502)))).x) * 6;
          _1616 = ForwardLightData_ForwardLocalLightBuffer[((int)(_1612 + 4u))].x;
          _1617 = ForwardLightData_ForwardLocalLightBuffer[((int)(_1612 + 4u))].y;
          _1618 = ForwardLightData_ForwardLocalLightBuffer[((int)(_1612 + 4u))].z;
          _1621 = ForwardLightData_ForwardLocalLightBuffer[((int)(_1612 + 3u))].x;
          _1622 = ForwardLightData_ForwardLocalLightBuffer[((int)(_1612 + 3u))].y;
          _1623 = ForwardLightData_ForwardLocalLightBuffer[((int)(_1612 + 3u))].w;
          _1626 = ForwardLightData_ForwardLocalLightBuffer[((int)(_1612 + 2u))].x;
          _1627 = ForwardLightData_ForwardLocalLightBuffer[((int)(_1612 + 2u))].y;
          _1628 = ForwardLightData_ForwardLocalLightBuffer[((int)(_1612 + 2u))].z;
          _1631 = ForwardLightData_ForwardLocalLightBuffer[(_1612 | 1)].x;
          _1632 = ForwardLightData_ForwardLocalLightBuffer[(_1612 | 1)].w;
          _1634 = ForwardLightData_ForwardLocalLightBuffer[_1612].w;
          _1635 = asint(_1623);
          _1637 = f16tof32(((uint)((uint)(_1635) >> 16)));
          if (_1637 > 0.0f) {
            _1640 = ForwardLightData_ForwardLocalLightBuffer[(_1612 | 1)].y;
            _1641 = ForwardLightData_ForwardLocalLightBuffer[((int)(_1612 + 2u))].w;
            _1642 = ForwardLightData_ForwardLocalLightBuffer[_1612].z;
            _1643 = ForwardLightData_ForwardLocalLightBuffer[_1612].y;
            _1644 = ForwardLightData_ForwardLocalLightBuffer[_1612].x;
            _1645 = ForwardLightData_ForwardLocalLightBuffer[((int)(_1612 + 3u))].z;
            _1648 = ForwardLightData_ForwardLocalLightBuffer[((int)(_1612 + 5u))].z;
            _1649 = asint(_1641);
            _1651 = ((uint)(_1649) >> 16) & 3;
            _1652 = asint(_1640);
            _1666 = f16tof32(((uint)(asint(_1645) & 65535)));
            _1667 = -0.0f - _1666;
            _1668 = f16tof32(_1635);
            _1669 = -0.0f - _1668;
            _1670 = (_1632 == 0.0f);
            _1672 = (_1651 == 3);
            _1673 = asint(_1648);
            _1675 = f16tof32(((uint)(_1673 & 65535)));
            _1679 = float((uint)((uint)(((uint)(_1673) >> 16) & 1023))) * 0.0009775171056389809f;
            _1681 = ((uint)(_1649) >> 20) & 255;
            _1682 = _1644 - _511;
            _1683 = _1643 - _512;
            _1684 = _1642 - _513;
            _1685 = dot(float3(_1682, _1683, _1684), float3(_1682, _1683, _1684));
            _1686 = rsqrt(_1685);
            _1687 = _1686 * _1682;
            _1688 = _1686 * _1683;
            _1689 = _1686 * _1684;
            if (_1670) {
              _1692 = (_1634 * _1634) * _1685;
              _1695 = saturate(1.0f - (_1692 * _1692));
              _1708 = (_1695 * _1695);
            } else {
              _1698 = _1682 * _1634;
              _1699 = _1683 * _1634;
              _1700 = _1684 * _1634;
              _1708 = exp2(log2(1.0f - saturate(dot(float3(_1698, _1699, _1700), float3(_1698, _1699, _1700)))) * _1632);
            }
            if (_1651 == 2) {
              _1713 = saturate((dot(float3(_1687, _1688, _1689), float3(_1626, _1627, _1628)) - _1621) * _1622);
              _1717 = ((_1713 * _1713) * _1708);
            } else {
              _1717 = _1708;
            }
            if (_1672) {
              _1723 = select((dot(float3(_1626, _1627, _1628), float3(_1687, _1688, _1689)) < 0.0f), 0.0f, _1717);
            } else {
              _1723 = _1717;
            }
            if (_1672) {
              _1727 = (_1628 * _1617) - (_1627 * _1618);
              _1730 = (_1626 * _1618) - (_1628 * _1616);
              _1733 = (_1627 * _1616) - (_1626 * _1617);
              if (_1679 > 0.03500000014901161f) {
                _1738 = mad(_1733, _1684, mad(_1730, _1683, (_1682 * _1727)));
                _1741 = mad(_1618, _1684, mad(_1617, _1683, (_1682 * _1616)));
                _1744 = mad(_1628, _1684, mad(_1627, _1683, (_1682 * _1626)));
                _1748 = _1679 * _1675;
                _1749 = min(_1744, _1748);
                _1753 = (sqrt(1.0f - (_1679 * _1679)) * _1675) * (_1749 / max(9.999999747378752e-05f, _1748));
                _1764 = float((int)(((int)(uint)((int)(_1738 > 0.0f))) - ((int)(uint)((int)(_1738 < 0.0f)))));
                _1765 = float((int)(((int)(uint)((int)(_1741 > 0.0f))) - ((int)(uint)((int)(_1741 < 0.0f)))));
                _1779 = max((_1744 - _1749), 0.0010000000474974513f);
                _1786 = ((abs(((_1667 - _1753) + max(abs(_1738), (_1753 + _1666))) * _1764) / _1779) * _1749) - _1753;
                _1787 = ((abs(((_1669 - _1753) + max(abs(_1741), (_1753 + _1668))) * _1765) / _1779) * _1749) - _1753;
                _1798 = min(max(((_1786 * max(0.0f, (-0.0f - _1764))) - _1666), _1667), _1666);
                _1799 = min(max(((_1787 * max(0.0f, (-0.0f - _1765))) - _1668), _1669), _1668);
                _1808 = min(max((_1666 - (max(0.0f, _1764) * _1786)), _1667), _1666);
                _1809 = min(max((_1668 - (max(0.0f, _1765) * _1787)), _1669), _1668);
                _1812 = (_1808 + _1798) * 0.5f;
                _1813 = (_1809 + _1799) * 0.5f;
                _1831 = ((_1682 - (_1812 * _1727)) - (_1813 * _1616));
                _1832 = ((_1683 - (_1812 * _1730)) - (_1813 * _1617));
                _1833 = ((_1684 - (_1812 * _1733)) - (_1813 * _1618));
                _1834 = ((_1808 - _1798) * 0.5f);
                _1835 = ((_1809 - _1799) * 0.5f);
              } else {
                _1831 = _1682;
                _1832 = _1683;
                _1833 = _1684;
                _1834 = _1666;
                _1835 = _1668;
              }
              if (!((int)(_1834 == 0.0f) || (int)(_1835 == 0.0f))) {
                _1840 = dot(float3(_1727, _1730, _1733), float3(_1831, _1832, _1833));
                _1841 = dot(float3(_1616, _1617, _1618), float3(_1831, _1832, _1833));
                _1842 = dot(float3(_1626, _1627, _1628), float3(_1831, _1832, _1833));
                _1843 = _1840 - _1834;
                _1844 = _1840 + _1834;
                _1845 = _1841 - _1835;
                _1846 = _1841 + _1835;
                _1847 = _1842 * _1842;
                _1850 = rsqrt(dot(float2(_1843, _1845), float2(_1843, _1845)) + _1847);
                _1851 = _1850 * _1843;
                _1852 = _1850 * _1845;
                _1853 = _1850 * _1842;
                _1856 = rsqrt(dot(float2(_1844, _1845), float2(_1844, _1845)) + _1847);
                _1857 = _1856 * _1844;
                _1858 = _1856 * _1845;
                _1859 = _1856 * _1842;
                _1862 = rsqrt(dot(float2(_1844, _1846), float2(_1844, _1846)) + _1847);
                _1863 = _1862 * _1844;
                _1864 = _1862 * _1846;
                _1865 = _1862 * _1842;
                _1868 = rsqrt(dot(float2(_1843, _1846), float2(_1843, _1846)) + _1847);
                _1869 = _1868 * _1843;
                _1870 = _1868 * _1846;
                _1871 = _1868 * _1842;
                _1872 = dot(float3(_1851, _1852, _1853), float3(_1857, _1858, _1859));
                _1873 = dot(float3(_1857, _1858, _1859), float3(_1863, _1864, _1865));
                _1874 = dot(float3(_1863, _1864, _1865), float3(_1869, _1870, _1871));
                _1875 = dot(float3(_1869, _1870, _1871), float3(_1851, _1852, _1853));
                _1884 = rsqrt(_1873 + 1.0f) * (1.5707999467849731f - (_1873 * 0.17499999701976776f));
                _1893 = rsqrt(_1875 + 1.0f) * (1.5707999467849731f - (_1875 * 0.17499999701976776f));
                _1895 = -0.0f - ((1.5707999467849731f - (_1872 * 0.17499999701976776f)) * rsqrt(_1872 + 1.0f));
                _1902 = (_1884 * _1863) + (_1851 * _1895);
                _1903 = (_1884 * _1864) + (_1852 * _1895);
                _1904 = (_1884 * _1865) + (_1853 * _1895);
                _1918 = -0.0f - ((1.5707999467849731f - (_1874 * 0.17499999701976776f)) * rsqrt(_1874 + 1.0f));
                _1922 = (_1893 * _1851) + (_1863 * _1918);
                _1923 = (_1893 * _1852) + (_1864 * _1918);
                _1924 = (_1893 * _1853) + (_1865 * _1918);
                _1934 = ((_1924 * _1870) - (_1923 * _1871)) + ((_1904 * _1858) - (_1903 * _1859));
                _1935 = ((_1922 * _1871) - (_1924 * _1869)) + ((_1902 * _1859) - (_1904 * _1857));
                _1936 = ((_1923 * _1869) - (_1922 * _1870)) + ((_1903 * _1857) - (_1902 * _1858));
                _1949 = ((_1934 * _1727) + (_1935 * _1616)) + (_1936 * _1626);
                _1950 = ((_1934 * _1730) + (_1935 * _1617)) + (_1936 * _1627);
                _1951 = ((_1934 * _1733) + (_1935 * _1618)) + (_1936 * _1628);
                _1952 = dot(float3(_1949, _1950, _1951), float3(_1949, _1950, _1951));
                _1987 = ((_1952 * 0.5f) * rsqrt(_1952));
              } else {
                _1987 = 0.0f;
              }
            } else {
              _1957 = _1668 * 0.5f;
              _1958 = _1957 * _1616;
              _1959 = _1957 * _1617;
              _1960 = _1957 * _1618;
              _1961 = _1682 - _1958;
              _1962 = _1683 - _1959;
              _1963 = _1684 - _1960;
              _1964 = _1958 + _1682;
              _1965 = _1959 + _1683;
              _1966 = _1960 + _1684;
              _1968 = dot(float3(_1961, _1962, _1963), float3(_1961, _1962, _1963));
              [branch]
              if (_1668 > 0.0f) {
                _1973 = rsqrt(dot(float3(_1964, _1965, _1966), float3(_1964, _1965, _1966))) * rsqrt(_1968);
                _1984 = (_1973 / ((((dot(float3(_1961, _1962, _1963), float3(_1964, _1965, _1966)) * 0.5f) + _1600) * _1973) + 0.5f));
              } else {
                _1984 = (1.0f / (_1968 + _1600));
              }
              _1987 = select(_1670, _1984, 1.0f);
            }
            if (!(_1681 == 0)) {
              _1990 = _1681 * 5;
              _1993 = LightFunctionAtlas_LightInfoDataBuffer[_1990].x;
              _1994 = LightFunctionAtlas_LightInfoDataBuffer[_1990].y;
              _1995 = LightFunctionAtlas_LightInfoDataBuffer[_1990].z;
              _1996 = asint(_1994);
              _1997 = asint(_1995);
              _2001 = f16tof32(((uint)(((uint)(_1996) >> 8) & 65535)));
              _2010 = LightFunctionAtlas_LightInfoDataBuffer[(_1990 + 1)].x;
              _2011 = LightFunctionAtlas_LightInfoDataBuffer[(_1990 + 1)].y;
              _2012 = LightFunctionAtlas_LightInfoDataBuffer[(_1990 + 1)].z;
              _2013 = LightFunctionAtlas_LightInfoDataBuffer[(_1990 + 1)].w;
              _2016 = LightFunctionAtlas_LightInfoDataBuffer[(_1990 + 2)].x;
              _2017 = LightFunctionAtlas_LightInfoDataBuffer[(_1990 + 2)].y;
              _2018 = LightFunctionAtlas_LightInfoDataBuffer[(_1990 + 2)].z;
              _2019 = LightFunctionAtlas_LightInfoDataBuffer[(_1990 + 2)].w;
              _2022 = LightFunctionAtlas_LightInfoDataBuffer[(_1990 + 3)].x;
              _2023 = LightFunctionAtlas_LightInfoDataBuffer[(_1990 + 3)].y;
              _2024 = LightFunctionAtlas_LightInfoDataBuffer[(_1990 + 3)].z;
              _2025 = LightFunctionAtlas_LightInfoDataBuffer[(_1990 + 3)].w;
              _2028 = LightFunctionAtlas_LightInfoDataBuffer[(_1990 + 4)].x;
              _2029 = LightFunctionAtlas_LightInfoDataBuffer[(_1990 + 4)].y;
              _2030 = LightFunctionAtlas_LightInfoDataBuffer[(_1990 + 4)].z;
              _2031 = LightFunctionAtlas_LightInfoDataBuffer[(_1990 + 4)].w;
              _2047 = mad(_513, _2025, mad(_512, _2019, (_2013 * _511))) + _2031;
              _2048 = (mad(_513, _2024, mad(_512, _2018, (_2012 * _511))) + _2030) / _2047;
              _2049 = (mad(_513, _2023, mad(_512, _2017, (_2011 * _511))) + _2029) / _2047;
              _2050 = (mad(_513, _2022, mad(_512, _2016, (_2010 * _511))) + _2028) / _2047;
              switch (((int)(_1996 & 255))) {
                case 2: {
                  _2052 = LightFunctionAtlas_LightInfoDataBuffer[_1990].w;
                  _2053 = _2050 * _2052;
                  _2087 = (((_2048 / _2053) * 0.5f) + 0.5f);
                  _2088 = (((_2049 / _2053) * 0.5f) + 0.5f);
                  break;
                }
                case 1: {
                  _2062 = rsqrt(dot(float3(_2048, _2049, _2050), float3(_2048, _2049, _2050)));
                  _2063 = _2062 * _2048;
                  _2064 = _2062 * _2049;
                  _2067 = atan(_2064 / _2063);
                  _2070 = (_2063 < 0.0f);
                  _2071 = (_2063 == 0.0f);
                  _2072 = (_2064 >= 0.0f);
                  _2073 = (_2064 < 0.0f);
                  _2087 = select((_2071 && _2072), 0.75f, select((_2071 && _2073), 0.25f, ((select((_2070 && _2073), (_2067 + -3.1415927410125732f), select((_2070 && _2072), (_2067 + 3.1415927410125732f), _2067)) + 3.1415927410125732f) * 0.15915493667125702f)));
                  _2088 = (acos(_2062 * _2050) * 0.31830987334251404f);
                  break;
                }
                default: {
                  _2087 = _2048;
                  _2088 = _2049;
                  break;
                }
              }
              _2108 = View.TranslatedWorldCameraOrigin.x - _511;
              _2109 = View.TranslatedWorldCameraOrigin.y - _512;
              _2110 = View.TranslatedWorldCameraOrigin.z - _513;
              _2125 = ((saturate((_1993 - sqrt(((_2108 * _2108) + (_2109 * _2109)) + (_2110 * _2110))) / (_1993 * 0.20000000298023224f)) * (((((float4)(LightFunctionAtlas_LightFunctionAtlasTexture.SampleLevel(LightFunctionAtlas_LightFunctionAtlasSampler, float2(((LightFunctionAtlas.Slot_UVSize * saturate(frac(_2087))) + (float((uint)((uint)(_1997 & 65535))) * 1.52587890625e-05f)), ((LightFunctionAtlas.Slot_UVSize * saturate(frac(_2088))) + (float((uint)((uint)((uint)(_1997) >> 16))) * 1.52587890625e-05f))), 0.0f))).x) * (((float4)(LightFunctionAtlas_LightFunctionAtlasTexture.SampleLevel(LightFunctionAtlas_LightFunctionAtlasSampler, float2(((LightFunctionAtlas.Slot_UVSize * saturate(frac(_2087))) + (float((uint)((uint)(_1997 & 65535))) * 1.52587890625e-05f)), ((LightFunctionAtlas.Slot_UVSize * saturate(frac(_2088))) + (float((uint)((uint)((uint)(_1997) >> 16))) * 1.52587890625e-05f))), 0.0f))).x)) - _2001)) + _2001);
            } else {
              _2125 = 1.0f;
            }
            _2140 = (((dot(float3(_1687, _1688, _1689), float3((-0.0f - _541), (-0.0f - _542), (-0.0f - _543))) * 2.0f) + asfloat(_RootShaderParameters_raw[86u].x)) * asfloat(_RootShaderParameters_raw[86u].x)) + 1.0f;
            _2147 = ((_1723 * _1637) * _1987) * ((1.0f - (asfloat(_RootShaderParameters_raw[86u].x) * asfloat(_RootShaderParameters_raw[86u].x))) / ((sqrt(_2140) * 12.566370964050293f) * _2140));
            _2155 = ((((float((uint)((uint)(_1652 & 1023))) * _1631) * _2125) * _2147) + _1604);
            _2156 = ((((float((uint)((uint)(((uint)(_1652) >> 10) & 1023))) * _1631) * _2125) * _2147) + _1605);
            _2157 = ((((float((uint)((uint)(((uint)(_1652) >> 20) & 1023))) * _1631) * _2125) * _2147) + _1606);
          } else {
            _2155 = _1604;
            _2156 = _1605;
            _2157 = _1606;
          }
          _2158 = _1607 + 1u;
          if (!(_2158 == _1499)) {
            _1604 = _2155;
            _1605 = _2156;
            _1606 = _2157;
            _1607 = _2158;
            continue;
          }
          _2162 = _2155;
          _2163 = _2156;
          _2164 = _2157;
          break;
        }
      } else {
        _2162 = _1460;
        _2163 = _1461;
        _2164 = _1462;
      }
      _2165 = _376 + 1;
      if ((uint)_2165 < (uint)_371) {
        _373 = _2162;
        _374 = _2163;
        _375 = _2164;
        _376 = _2165;
        continue;
      }
      _2168 = float((uint)_371);
      _2175 = LocalShadowedLightScattering.Load(int4((int)(SV_DispatchThreadID.x), (int)(SV_DispatchThreadID.y), (int)(SV_DispatchThreadID.z), 0));
      _2186 = VBufferA.Load(int4((int)(SV_DispatchThreadID.x), (int)(SV_DispatchThreadID.y), (int)(SV_DispatchThreadID.z), 0));
      _2192 = _2186.w + dot(float3(_2186.x, _2186.y, _2186.z), float3(0.30000001192092896f, 0.5899999737739563f, 0.10999999940395355f));
      [branch]
      if (!(asint(_RootShaderParameters_raw[87u].w) == 0)) {
        _2198 = VBufferB.Load(int4((int)(SV_DispatchThreadID.x), (int)(SV_DispatchThreadID.y), (int)(SV_DispatchThreadID.z), 0));
        _2203 = _2198.x;
        _2204 = _2198.y;
        _2205 = _2198.z;
      } else {
        _2203 = 0.0f;
        _2204 = 0.0f;
        _2205 = 0.0f;
      }
      _2213 = View.PreExposure * (_2203 + (_2186.x * ((_2175.x * View.OneOverPreExposure) + (_2162 / _2168))));
      _2214 = View.PreExposure * (_2204 + (_2186.y * ((_2175.y * View.OneOverPreExposure) + (_2163 / _2168))));
      _2215 = View.PreExposure * (_2205 + (_2186.z * ((_2175.z * View.OneOverPreExposure) + (_2164 / _2168))));
      [branch]
      if (_357 > 0.0f) {
        float3 _fog_tex_size = float3(
            VolumetricFog.ResourceGridSize.x,
            VolumetricFog.ResourceGridSize.y,
            VolumetricFog.ResourceGridSize.z);
        float3 _hist_uvw = float3(min(_337, View.VolumetricFogPrevUVMax.x), min(_338, View.VolumetricFogPrevUVMax.y), min(_339, 1.0f));
        _2226 = SampleFogHistory(LightScatteringHistory, LightScatteringHistorySampler,
            _hist_uvw, _fog_tex_size, float(InjectionFogFilterMode()));
        _2233 = View.PreExposure * asfloat(_RootShaderParameters_raw[85u].y);

        // Neighborhood clamping: sample the 6 face-neighbors of the current voxel
        // in the history volume using simple bilinear (point) reads. Compute min/max
        // and clamp the tricubic result to that range. This prevents the wider filter
        // footprint from pulling in values that don't exist near this voxel — preserving
        // light shaft edges that would otherwise be eroded by temporal accumulation.
        float3 _voxel_step = 1.0 / _fog_tex_size;
        float4 _n_xp = LightScatteringHistory.SampleLevel(LightScatteringHistorySampler, _hist_uvw + float3(_voxel_step.x, 0, 0), 0);
        float4 _n_xn = LightScatteringHistory.SampleLevel(LightScatteringHistorySampler, _hist_uvw - float3(_voxel_step.x, 0, 0), 0);
        float4 _n_yp = LightScatteringHistory.SampleLevel(LightScatteringHistorySampler, _hist_uvw + float3(0, _voxel_step.y, 0), 0);
        float4 _n_yn = LightScatteringHistory.SampleLevel(LightScatteringHistorySampler, _hist_uvw - float3(0, _voxel_step.y, 0), 0);
        float4 _n_zp = LightScatteringHistory.SampleLevel(LightScatteringHistorySampler, _hist_uvw + float3(0, 0, _voxel_step.z), 0);
        float4 _n_zn = LightScatteringHistory.SampleLevel(LightScatteringHistorySampler, _hist_uvw - float3(0, 0, _voxel_step.z), 0);
        float4 _bilinear_center = LightScatteringHistory.SampleLevel(LightScatteringHistorySampler, _hist_uvw, 0);
        float4 _nhood_min = min(min(min(_n_xp, _n_xn), min(_n_yp, _n_yn)), min(min(_n_zp, _n_zn), _bilinear_center));
        float4 _nhood_max = max(max(max(_n_xp, _n_xn), max(_n_yp, _n_yn)), max(max(_n_zp, _n_zn), _bilinear_center));
        _2226 = clamp(_2226, _nhood_min, _nhood_max);

        _2250 = ((((_2233 * _2226.x) - _2213) * _357) + _2213);
        _2251 = ((((_2233 * _2226.y) - _2214) * _357) + _2214);
        _2252 = ((((_2233 * _2226.z) - _2215) * _357) + _2215);
        _2253 = (lerp(_2192, _2226.w, _357));
      } else {
        _2250 = _2213;
        _2251 = _2214;
        _2252 = _2215;
        _2253 = _2192;
      }
      if ((int)((int)(int)(SV_DispatchThreadID.z) < (int)VolumetricFog.ResourceGridSizeInt.z) && ((int)((int)((int)(int)(SV_DispatchThreadID.x) < (int)VolumetricFog.ResourceGridSizeInt.x) && (int)((int)(int)(SV_DispatchThreadID.y) < (int)VolumetricFog.ResourceGridSizeInt.y)))) {
        // Debug: Mode 1 = noise source, Mode 2 = filter diff
        if ((InjectionEnum(ENUM_DEBUG_FOG_SHIFT) > 0u) && float(InjectionEnum(ENUM_DEBUG_FOG_SHIFT)) < 1.5f) {
          uint _dbg_s = View.FrameCounter % 32u;
          float2 _dbg_n = FastNoiseLoad(SV_DispatchThreadID.x % 128u, SV_DispatchThreadID.y % 128u, _dbg_s);
          float _dbg_v = (_dbg_n.x + _dbg_n.y) * 0.5f;
          if (InjectionToggle(TOGGLE_USE_ISFAST_FOG)) {
            float4 _dbg_col = (_dbg_v == 0.0f)
                ? float4(10.0f * View.PreExposure, 0.0f, 0.0f, _2253)
                : float4(0.0f, _dbg_v * 5.0f * View.PreExposure, 0.0f, _2253);
            RWLightScattering[int3((int)(SV_DispatchThreadID.x), (int)(SV_DispatchThreadID.y), (int)(SV_DispatchThreadID.z))] = _dbg_col;
          } else {
            RWLightScattering[int3((int)(SV_DispatchThreadID.x), (int)(SV_DispatchThreadID.y), (int)(SV_DispatchThreadID.z))] = float4(3.0f * View.PreExposure, 3.0f * View.PreExposure, 0.0f, _2253);
          }
        } else if (float(InjectionEnum(ENUM_DEBUG_FOG_SHIFT)) > 1.5f) {
          float4 _bilinear_ref = LightScatteringHistory.SampleLevel(LightScatteringHistorySampler,
              float3(min(_337, View.VolumetricFogPrevUVMax.x), min(_338, View.VolumetricFogPrevUVMax.y), min(_339, 1.0f)), 0.0f);
          float _diff = length(_2226.xyz - _bilinear_ref.xyz);
          // Color by filter mode: blue=B-spline, cyan=Catmull-Rom, green=triquadratic, magenta=bilinear
          float4 _mode_col = (float(InjectionFogFilterMode()) > 2.5f) ? float4(0, _diff * 50.0f, 0, 1)   // green = triquadratic
                           : (float(InjectionFogFilterMode()) > 1.5f) ? float4(0, _diff * 50.0f, _diff * 50.0f, 1) // cyan = Catmull-Rom
                           : (float(InjectionFogFilterMode()) > 0.5f) ? float4(0, 0, _diff * 50.0f, 1)   // blue = B-spline
                           : float4(_diff * 50.0f, 0, _diff * 50.0f, 1); // magenta = bilinear (no diff)
          RWLightScattering[int3((int)(SV_DispatchThreadID.x), (int)(SV_DispatchThreadID.y), (int)(SV_DispatchThreadID.z))] = float4(_mode_col.xyz * View.PreExposure, _2253);
        } else {
          RWLightScattering[int3((int)(SV_DispatchThreadID.x), (int)(SV_DispatchThreadID.y), (int)(SV_DispatchThreadID.z))] = float4(select(((uint)asint(_2250) < (uint)2139095040), _2250, 0.0f), select(((uint)asint(_2251) < (uint)2139095040), _2251, 0.0f), select(((uint)asint(_2252) < (uint)2139095040), _2252, 0.0f), select(((uint)asint(_2253) < (uint)2139095040), _2253, 0.0f));
        }
      }
      break;
    }
  } else {
    _58 = ((_47 / VolumetricFog.ViewGridSize.x) * 2.0f) + -1.0f;
    _60 = -0.0f - (((_48 / VolumetricFog.ViewGridSize.y) * 2.0f) + -1.0f);
    _69 = (exp2((_49 + -1.0f) / VolumetricFog.GridZParams.z) - VolumetricFog.GridZParams.y) / VolumetricFog.GridZParams.x;
    [branch]
    if (!((View.ViewToClip[3].w) >= 1.0f)) {
      _87 = (1.0f / ((_69 + View.InvDeviceZToWorldZTransform.w) * View.InvDeviceZToWorldZTransform.z));
    } else {
      _87 = ((_69 * (View.ViewToClip[2].z)) + (View.ViewToClip[3].z));
    }
    _123 = mad(1.0f, asfloat(_RootShaderParameters_raw[8u].w), mad(_87, asfloat(_RootShaderParameters_raw[7u].w), mad(_60, asfloat(_RootShaderParameters_raw[6u].w), (_58 * asfloat(_RootShaderParameters_raw[5u].w)))));
    _124 = mad(1.0f, asfloat(_RootShaderParameters_raw[8u].x), mad(_87, asfloat(_RootShaderParameters_raw[7u].x), mad(_60, asfloat(_RootShaderParameters_raw[6u].x), (_58 * asfloat(_RootShaderParameters_raw[5u].x))))) / _123;
    _125 = mad(1.0f, asfloat(_RootShaderParameters_raw[8u].y), mad(_87, asfloat(_RootShaderParameters_raw[7u].y), mad(_60, asfloat(_RootShaderParameters_raw[6u].y), (_58 * asfloat(_RootShaderParameters_raw[5u].y))))) / _123;
    _126 = mad(1.0f, asfloat(_RootShaderParameters_raw[8u].z), mad(_87, asfloat(_RootShaderParameters_raw[7u].z), mad(_60, asfloat(_RootShaderParameters_raw[6u].z), (_58 * asfloat(_RootShaderParameters_raw[5u].z))))) / _123;
    _147 = mad(1.0f, (View.TranslatedWorldToClip[3].z), mad(_126, (View.TranslatedWorldToClip[2].z), mad(_125, (View.TranslatedWorldToClip[1].z), (_124 * (View.TranslatedWorldToClip[0].z))))) / mad(1.0f, (View.TranslatedWorldToClip[3].w), mad(_126, (View.TranslatedWorldToClip[2].w), mad(_125, (View.TranslatedWorldToClip[1].w), (_124 * (View.TranslatedWorldToClip[0].w)))));
    if (((ConservativeDepthTexture.Load(int3((int)(SV_DispatchThreadID.x), (int)(SV_DispatchThreadID.y), 0))).x) > _147) {
      RWLightScattering[int3((int)(SV_DispatchThreadID.x), (int)(SV_DispatchThreadID.y), (int)(SV_DispatchThreadID.z))] = float4(0.0f, 0.0f, 0.0f, 0.0f);
    } else {
      _182 = mad(1.0f, asfloat(_RootShaderParameters_raw[12u].w), mad(_126, asfloat(_RootShaderParameters_raw[11u].w), mad(_125, asfloat(_RootShaderParameters_raw[10u].w), (_124 * asfloat(_RootShaderParameters_raw[9u].w)))));
      if (((PrevConservativeDepthTexture.Load(int3((int)(uint((((mad(1.0f, asfloat(_RootShaderParameters_raw[12u].x), mad(_126, asfloat(_RootShaderParameters_raw[11u].x), mad(_125, asfloat(_RootShaderParameters_raw[10u].x), (_124 * asfloat(_RootShaderParameters_raw[9u].x))))) / _182) * 0.5f) + 0.5f) * asfloat(_RootShaderParameters_raw[84u].x))), (int)(uint(asfloat(_RootShaderParameters_raw[84u].y) * (0.5f - ((mad(1.0f, asfloat(_RootShaderParameters_raw[12u].y), mad(_126, asfloat(_RootShaderParameters_raw[11u].y), mad(_125, asfloat(_RootShaderParameters_raw[10u].y), (_124 * asfloat(_RootShaderParameters_raw[9u].y))))) / _182) * 0.5f)))), 0))).x) > _147) {
        _202 = 1;
      } else {
        _202 = 0;
      }
      _226 = ((_47 / VolumetricFog.ViewGridSize.x) * 2.0f) + -1.0f;
      _228 = -0.0f - (((_48 / VolumetricFog.ViewGridSize.y) * 2.0f) + -1.0f);
      _237 = (exp2((_49 + 0.5f) / VolumetricFog.GridZParams.z) - VolumetricFog.GridZParams.y) / VolumetricFog.GridZParams.x;
      [branch]
      if (!((View.ViewToClip[3].w) >= 1.0f)) {
        _255 = (1.0f / ((_237 + View.InvDeviceZToWorldZTransform.w) * View.InvDeviceZToWorldZTransform.z));
      } else {
        _255 = ((_237 * (View.ViewToClip[2].z)) + (View.ViewToClip[3].z));
      }
      _291 = mad(1.0f, asfloat(_RootShaderParameters_raw[8u].w), mad(_255, asfloat(_RootShaderParameters_raw[7u].w), mad(_228, asfloat(_RootShaderParameters_raw[6u].w), (_226 * asfloat(_RootShaderParameters_raw[5u].w)))));
      _292 = mad(1.0f, asfloat(_RootShaderParameters_raw[8u].x), mad(_255, asfloat(_RootShaderParameters_raw[7u].x), mad(_228, asfloat(_RootShaderParameters_raw[6u].x), (_226 * asfloat(_RootShaderParameters_raw[5u].x))))) / _291;
      _293 = mad(1.0f, asfloat(_RootShaderParameters_raw[8u].y), mad(_255, asfloat(_RootShaderParameters_raw[7u].y), mad(_228, asfloat(_RootShaderParameters_raw[6u].y), (_226 * asfloat(_RootShaderParameters_raw[5u].y))))) / _291;
      _294 = mad(1.0f, asfloat(_RootShaderParameters_raw[8u].z), mad(_255, asfloat(_RootShaderParameters_raw[7u].z), mad(_228, asfloat(_RootShaderParameters_raw[6u].z), (_226 * asfloat(_RootShaderParameters_raw[5u].z))))) / _291;
      _306 = mad(1.0f, asfloat(_RootShaderParameters_raw[12u].w), mad(_294, asfloat(_RootShaderParameters_raw[11u].w), mad(_293, asfloat(_RootShaderParameters_raw[10u].w), (asfloat(_RootShaderParameters_raw[9u].w) * _292))));
      _337 = min(((((mad(1.0f, asfloat(_RootShaderParameters_raw[12u].x), mad(_294, asfloat(_RootShaderParameters_raw[11u].x), mad(_293, asfloat(_RootShaderParameters_raw[10u].x), (asfloat(_RootShaderParameters_raw[9u].x) * _292)))) / _306) * 0.5f) + 0.5f) * (View.VolumetricFogViewGridUVToPrevViewRectUV.x * View.VolumetricFogPrevViewGridRectUVToResourceUV.x)), View.VolumetricFogPrevUVMaxForTemporalBlend.x);
      _338 = min(((0.5f - ((mad(1.0f, asfloat(_RootShaderParameters_raw[12u].y), mad(_294, asfloat(_RootShaderParameters_raw[11u].y), mad(_293, asfloat(_RootShaderParameters_raw[10u].y), (asfloat(_RootShaderParameters_raw[9u].y) * _292)))) / _306) * 0.5f)) * (View.VolumetricFogViewGridUVToPrevViewRectUV.y * View.VolumetricFogPrevViewGridRectUVToResourceUV.y)), View.VolumetricFogPrevUVMaxForTemporalBlend.y);
      _339 = min(((log2((_306 * View.VolumetricFogGridZParams.x) + View.VolumetricFogGridZParams.y) * View.VolumetricFogGridZParams.z) * View.VolumetricFogInvGridSize.z), 1.0f);
      if ((((int)((int)(_337 < 0.0f) || (int)(_338 < 0.0f))) || (int)(_339 < 0.0f)) | ((int)(_202 != 0) || ((int)((int)(_339 >= 1.0f) || ((int)((int)(_337 >= View.VolumetricFogPrevUVMaxForTemporalBlend.x) || (int)(_338 >= View.VolumetricFogPrevUVMaxForTemporalBlend.y))))))) {
        _357 = 0.0f;
      } else {
        _357 = asfloat(_RootShaderParameters_raw[29u].x);
      }
      if (_357 < 0.0010000000474974513f) {
        _371 = select(((int)((int)(int)(SV_DispatchThreadID.z) < (int)VolumetricFog.ViewGridSizeInt.z) && ((int)((int)((int)(int)(SV_DispatchThreadID.x) < (int)VolumetricFog.ViewGridSizeInt.x) && (int)((int)(int)(SV_DispatchThreadID.y) < (int)VolumetricFog.ViewGridSizeInt.y)))), 8, 1);
      } else {
        _371 = 1;
      }
      _373 = 0.0f;
      _374 = 0.0f;
      _375 = 0.0f;
      _376 = 0;
      while(true) {
        _386 = ((int)(SV_DispatchThreadID.y) * 1664525) + 1013904223u;
        _387 = ((int)(SV_DispatchThreadID.z) * 1664525) + 1013904223u;
        _388 = (((int)((uint)(View.StateFrameIndexMod8) + (_376 << 3))) * 1664525) + 1013904223u;
        _390 = (((int)(SV_DispatchThreadID.x) * 1664525) + 1013904223u) + (_388 * _386);
        _392 = (_390 * _387) + _386;
        _394 = (_392 * _390) + _387;
        _396 = (_394 * _392) + _388;
        _402 = ((uint)(_392) >> 16) ^ _392;
        _403 = ((uint)(_394) >> 16) ^ _394;
        _406 = ((((uint)(_396) >> 16) ^ _396) * _402) + ((uint)(((uint)(_390) >> 16) ^ _390));
        _408 = (_406 * _403) + _402;
        _424 = asfloat(_RootShaderParameters_raw[((int)(_376 + 13))]);
        if (InjectionToggle(TOGGLE_USE_ISFAST_FOG)) {
          uint _fast_slice = (View.FrameCounter + (uint)_376) % 32u;
          float2 _fast_n = FastNoiseLoad(
              SV_DispatchThreadID.x % 128u, SV_DispatchThreadID.y % 128u, _fast_slice);
          float _fast_z_n = FastNoiseLoad(
              SV_DispatchThreadID.z % 128u, (SV_DispatchThreadID.x ^ SV_DispatchThreadID.y) % 128u, (_fast_slice + 16u) % 32u).x;
          _433 = _424.x + (asfloat(_RootShaderParameters_raw[86u].z) * ((_fast_n.x * 2.0f) - 1.0f));
          _434 = _424.y + (asfloat(_RootShaderParameters_raw[86u].z) * ((_fast_n.y * 2.0f) - 1.0f));
          _435 = _424.z + (asfloat(_RootShaderParameters_raw[86u].z) * ((_fast_z_n * 2.0f) - 1.0f));
        } else {
          _433 = _424.x + (asfloat(_RootShaderParameters_raw[86u].z) * (((float((uint)_406) * 2.3283064365386963e-10f) * 2.0f) + -1.0f));
          _434 = _424.y + (asfloat(_RootShaderParameters_raw[86u].z) * (((float((uint)_408) * 2.3283064365386963e-10f) * 2.0f) + -1.0f));
          _435 = _424.z + (asfloat(_RootShaderParameters_raw[86u].z) * (((float((uint)((_408 * _406) + _403)) * 2.3283064365386963e-10f) * 2.0f) + -1.0f));
        }
        _445 = (((_45 + _433) / VolumetricFog.ViewGridSize.x) * 2.0f) + -1.0f;
        _447 = -0.0f - ((((_46 + _434) / VolumetricFog.ViewGridSize.y) * 2.0f) + -1.0f);
        _456 = (exp2((_49 + _435) / VolumetricFog.GridZParams.z) - VolumetricFog.GridZParams.y) / VolumetricFog.GridZParams.x;
        [branch]
        if (!((View.ViewToClip[3].w) >= 1.0f)) {
          _474 = (1.0f / ((_456 + View.InvDeviceZToWorldZTransform.w) * View.InvDeviceZToWorldZTransform.z));
        } else {
          _474 = ((_456 * (View.ViewToClip[2].z)) + (View.ViewToClip[3].z));
        }
        _510 = mad(1.0f, asfloat(_RootShaderParameters_raw[8u].w), mad(_474, asfloat(_RootShaderParameters_raw[7u].w), mad(_447, asfloat(_RootShaderParameters_raw[6u].w), (_445 * asfloat(_RootShaderParameters_raw[5u].w)))));
        _511 = mad(1.0f, asfloat(_RootShaderParameters_raw[8u].x), mad(_474, asfloat(_RootShaderParameters_raw[7u].x), mad(_447, asfloat(_RootShaderParameters_raw[6u].x), (_445 * asfloat(_RootShaderParameters_raw[5u].x))))) / _510;
        _512 = mad(1.0f, asfloat(_RootShaderParameters_raw[8u].y), mad(_474, asfloat(_RootShaderParameters_raw[7u].y), mad(_447, asfloat(_RootShaderParameters_raw[6u].y), (_445 * asfloat(_RootShaderParameters_raw[5u].y))))) / _510;
        _513 = mad(1.0f, asfloat(_RootShaderParameters_raw[8u].z), mad(_474, asfloat(_RootShaderParameters_raw[7u].z), mad(_447, asfloat(_RootShaderParameters_raw[6u].z), (_445 * asfloat(_RootShaderParameters_raw[5u].z))))) / _510;
        _525 = _511 - (View.PreViewTranslationHigh.x + View.PreViewTranslationLow.x);
        _526 = _512 - (View.PreViewTranslationHigh.y + View.PreViewTranslationLow.y);
        _527 = _513 - (View.PreViewTranslationHigh.z + View.PreViewTranslationLow.z);
        _532 = _511 - View.TranslatedWorldCameraOrigin.x;
        _533 = _512 - View.TranslatedWorldCameraOrigin.y;
        _534 = _513 - View.TranslatedWorldCameraOrigin.z;
        _540 = sqrt(((_532 * _532) + (_533 * _533)) + (_534 * _534));
        _541 = _532 / _540;
        _542 = _533 / _540;
        _543 = _534 / _540;
        _552 = asfloat(ForwardLightData_raw[6u].w) * asfloat(ForwardLightData_raw[6u].x);
        _553 = asfloat(ForwardLightData_raw[6u].w) * asfloat(ForwardLightData_raw[6u].y);
        _554 = asfloat(ForwardLightData_raw[6u].w) * asfloat(ForwardLightData_raw[6u].z);
        [branch]
        if (asint(ForwardLightData_raw[0u].z) == 0) {
          _1348 = asfloat(_RootShaderParameters_raw[86u].x);
          _1349 = _373;
          _1350 = _374;
          _1351 = _375;
        } else {
          if (asfloat(_RootShaderParameters_raw[87u].y) > 0.0f) {
            if (!(asint(ForwardLightData_raw[8u].x) == 0)) {
              _585 = ((((int)(uint)((int)(_456 >= asfloat(ForwardLightData_raw[9u].x)))) + ((int)(uint)((int)(_456 >= asfloat(ForwardLightData_raw[9u].y))))) + ((int)(uint)((int)(_456 >= asfloat(ForwardLightData_raw[9u].z))))) + ((int)(uint)((int)(_456 >= asfloat(ForwardLightData_raw[9u].w))));
              if ((uint)_585 < (uint)asint(ForwardLightData_raw[8u].x)) {
                _588 = _585 << 2;
                _590 = asfloat(ForwardLightData_raw[((int)(_588 + 10))]);
                _595 = asfloat(ForwardLightData_raw[((int)(_588 + 11))]);
                _600 = asfloat(ForwardLightData_raw[((int)(_588 + 12))]);
                _605 = asfloat(ForwardLightData_raw[((int)(_588 + 13))]);
                _620 = mad(_513, _600.w, mad(_512, _595.w, (_590.w * _511))) + _605.w;
                _621 = (mad(_513, _600.x, mad(_512, _595.x, (_590.x * _511))) + _605.x) / _620;
                _622 = (mad(_513, _600.y, mad(_512, _595.y, (_590.y * _511))) + _605.y) / _620;
                _624 = asfloat(ForwardLightData_raw[((int)(_585 + 26))]);
                if (((int)((int)(_621 >= _624.x) && (int)(_621 <= _624.z))) && ((int)((int)(_622 >= _624.y) && (int)(_622 <= _624.w)))) {
                  _656 = float((bool)(uint)(((1.0f - _605.z) - mad(_513, _600.z, mad(_512, _595.z, (_590.z * _511)))) < ((((float4)(ForwardLightData_DirectionalLightShadowmapAtlas.SampleLevel(ForwardLightData_ShadowmapSampler, float2(_621, _622), 0.0f))).x) - asfloat(ForwardLightData_raw[31u].x))));
                } else {
                  _656 = 1.0f;
                }
              } else {
                _656 = 1.0f;
              }
            } else {
              _656 = 1.0f;
            }
            _658 = asint(ForwardLightData_raw[8u].y) * 288;
            _670 = asint(VirtualShadowMap_ProjectionData.Load(((int)(_658 + 204u))));
            _672 = _658 + 208u;
            _673 = _658 + 224u;
            if (_670 == 0) {
              _676 = asint(VirtualShadowMap_ProjectionData.Load3(_672)).x;
              _677 = asint(VirtualShadowMap_ProjectionData.Load3(_672)).y;
              _678 = asint(VirtualShadowMap_ProjectionData.Load3(_672)).z;
              _683 = asint(VirtualShadowMap_ProjectionData.Load3(_673)).x;
              _684 = asint(VirtualShadowMap_ProjectionData.Load3(_673)).y;
              _685 = asint(VirtualShadowMap_ProjectionData.Load3(_673)).z;
              _691 = asint(VirtualShadowMap_ProjectionData.Load(((int)(_658 + 236u))));
              _695 = asint(VirtualShadowMap_ProjectionData.Load3(((int)(_658 + 240u)))).x;
              _696 = asint(VirtualShadowMap_ProjectionData.Load3(((int)(_658 + 240u)))).y;
              _697 = asint(VirtualShadowMap_ProjectionData.Load3(((int)(_658 + 240u)))).z;
              _703 = asint(VirtualShadowMap_ProjectionData.Load(((int)(_658 + 264u))));
              _706 = asint(VirtualShadowMap_ProjectionData.Load(((int)(_658 + 268u))));
              _719 = _511 + (asfloat(_695) + ((asfloat(_676) - View.PreViewTranslationHigh.x) + (asfloat(_683) - View.PreViewTranslationLow.x)));
              _720 = _512 + (asfloat(_696) + ((asfloat(_677) - View.PreViewTranslationHigh.y) + (asfloat(_684) - View.PreViewTranslationLow.y)));
              _721 = _513 + (asfloat(_697) + ((asfloat(_678) - View.PreViewTranslationHigh.z) + (asfloat(_685) - View.PreViewTranslationLow.z)));
              _737 = max((int)(0), (int)((int(floor(log2(sqrt((_721 * _721) + ((_719 * _719) + (_720 * _720)))) + select((VirtualShadowMap.bClipmapGreedyLevelSelection != 0), 0.0f, asfloat(_691)))) - _703)));
              if ((int)_737 < (int)_706) {
                _740 = _737 + asint(ForwardLightData_raw[8u].y);
                _741 = _740 * 288;
                _744 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_741 + 48u)))).z;
                _748 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_741 + 64u)))).x;
                _749 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_741 + 64u)))).y;
                _750 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_741 + 64u)))).z;
                _756 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_741 + 80u)))).x;
                _757 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_741 + 80u)))).y;
                _758 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_741 + 80u)))).z;
                _764 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_741 + 96u)))).x;
                _765 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_741 + 96u)))).y;
                _766 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_741 + 96u)))).z;
                _772 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_741 + 112u)))).x;
                _773 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_741 + 112u)))).y;
                _774 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_741 + 112u)))).z;
                _780 = asint(VirtualShadowMap_ProjectionData.Load3(((int)(_741 + 208u)))).x;
                _781 = asint(VirtualShadowMap_ProjectionData.Load3(((int)(_741 + 208u)))).y;
                _782 = asint(VirtualShadowMap_ProjectionData.Load3(((int)(_741 + 208u)))).z;
                _788 = asint(VirtualShadowMap_ProjectionData.Load3(((int)(_741 + 224u)))).x;
                _789 = asint(VirtualShadowMap_ProjectionData.Load3(((int)(_741 + 224u)))).y;
                _790 = asint(VirtualShadowMap_ProjectionData.Load3(((int)(_741 + 224u)))).z;
                _803 = ((asfloat(_780) - View.PreViewTranslationHigh.x) + (asfloat(_788) - View.PreViewTranslationLow.x)) + _511;
                _804 = ((asfloat(_781) - View.PreViewTranslationHigh.y) + (asfloat(_789) - View.PreViewTranslationLow.y)) + _512;
                _805 = ((asfloat(_782) - View.PreViewTranslationHigh.z) + (asfloat(_790) - View.PreViewTranslationLow.z)) + _513;
                _809 = mad(_805, asfloat(_764), mad(_804, asfloat(_756), (_803 * asfloat(_748)))) + asfloat(_772);
                _813 = mad(_805, asfloat(_765), mad(_804, asfloat(_757), (_803 * asfloat(_749)))) + asfloat(_773);
                _820 = uint(_809 * 128.0f);
                _821 = uint(_813 * 128.0f);
                if (!((uint)_740 < (uint)8192)) {
                  _830 = ((int)((((_740 * 21845) + (uint)(-178946048)) + _820) + (_821 << 7)));
                } else {
                  _830 = _740;
                }
                _833 = VirtualShadowMap_PageTable[_830];
                _834 = (uint)(_833) >> 20;
                _835 = _834 & 63;
                if ((int)_833 < (int)0) {
                  _838 = (_835 == 0);
                  _840 = _835 + _740;
                  if (!_838) {
                    _848 = asint(VirtualShadowMap_ProjectionData.Load2(((int)(_741 + 256u)))).x;
                    _849 = asint(VirtualShadowMap_ProjectionData.Load2(((int)(_741 + 256u)))).y;
                    _850 = _840 * 288;
                    _853 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_850 + 48u)))).z;
                    _857 = asint(VirtualShadowMap_ProjectionData.Load2(((int)(_850 + 256u)))).x;
                    _858 = asint(VirtualShadowMap_ProjectionData.Load2(((int)(_850 + 256u)))).y;
                    _865 = _834 & 31;
                    _870 = (uint)((_820 - (_848 << 5)) + (((int)(_857 << 5)) << _865)) >> _865;
                    _872 = _870 << 7;
                    _873 = ((uint)((_821 - (_849 << 5)) + (((int)(_858 << 5)) << _865)) >> _865) << 7;
                    _882 = 1.0f / float((uint)(1 << _865));
                    if (!((uint)_840 < (uint)8192)) {
                      _910 = ((int)((((_840 * 21845) + (uint)(-178946048)) + _870) + _873));
                    } else {
                      _910 = _840;
                    }
                    _912 = VirtualShadowMap_PageTable[_910];
                    _917 = ((int)min((uint)(((int)max((uint)((int)(uint((((float((int)(_857)) - (_882 * float((int)(_848)))) * 0.25f) + (_882 * _809)) * 16384.0f))), (uint)(_872)))), (uint)((_872 | 127))));
                    _918 = ((int)min((uint)(((int)max((uint)((int)(uint((((float((int)(_858)) - (_882 * float((int)(_849)))) * 0.25f) + (_882 * _813)) * 16384.0f))), (uint)(_873)))), (uint)((_873 | 127))));
                    _919 = _882;
                    _920 = (asfloat(_853) - (_882 * asfloat(_744)));
                    _921 = ((int)(uint)((int)((_912 & -2081423360) == -2147483648)));
                    _922 = _912;
                  } else {
                    _917 = (int)(uint(_809 * 16384.0f));
                    _918 = (int)(uint(_813 * 16384.0f));
                    _919 = 1.0f;
                    _920 = 0.0f;
                    _921 = ((int)(uint)(_838));
                    _922 = _833;
                  }
                  if (!(_921 == 0)) {
                    _940 = ((asfloat((((uint)(VirtualShadowMap_PhysicalPagePool.Load(int4(((((int)(_922 << 7)) & 130944) | (_917 & 127)), ((((uint)(_922) >> 3) & 130944) | (_918 & 127)), 0, 0)))).x)) - _920) / _919);
                    _941 = true;
                  } else {
                    _940 = 0.0f;
                    _941 = false;
                  }
                } else {
                  _940 = 0.0f;
                  _941 = false;
                }
                _1134 = select((_941 && (int)(_940 > (mad(_805, asfloat(_766), mad(_804, asfloat(_758), (_803 * asfloat(_750)))) + asfloat(_774)))), 0.0f, 1.0f);
              } else {
                _1134 = 1.0f;
              }
            } else {
              _946 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_658 + 112u)))).w;
              _947 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_658 + 112u)))).z;
              _948 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_658 + 112u)))).y;
              _949 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_658 + 112u)))).x;
              _950 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_658 + 96u)))).w;
              _951 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_658 + 96u)))).z;
              _952 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_658 + 96u)))).y;
              _953 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_658 + 96u)))).x;
              _954 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_658 + 80u)))).w;
              _955 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_658 + 80u)))).z;
              _956 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_658 + 80u)))).y;
              _957 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_658 + 80u)))).x;
              _958 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_658 + 64u)))).w;
              _959 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_658 + 64u)))).z;
              _960 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_658 + 64u)))).y;
              _961 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_658 + 64u)))).x;
              _963 = asint(VirtualShadowMap_ProjectionData.Load3(_672)).x;
              _964 = asint(VirtualShadowMap_ProjectionData.Load3(_672)).y;
              _965 = asint(VirtualShadowMap_ProjectionData.Load3(_672)).z;
              _970 = asint(VirtualShadowMap_ProjectionData.Load3(_673)).x;
              _971 = asint(VirtualShadowMap_ProjectionData.Load3(_673)).y;
              _972 = asint(VirtualShadowMap_ProjectionData.Load3(_673)).z;
              _985 = ((asfloat(_963) - View.PreViewTranslationHigh.x) + (asfloat(_970) - View.PreViewTranslationLow.x)) + _511;
              _986 = ((asfloat(_964) - View.PreViewTranslationHigh.y) + (asfloat(_971) - View.PreViewTranslationLow.y)) + _512;
              _987 = ((asfloat(_965) - View.PreViewTranslationHigh.z) + (asfloat(_972) - View.PreViewTranslationLow.z)) + _513;
              if (!(_670 == 2)) {
                _990 = abs(_985);
                _991 = abs(_986);
                _993 = abs(_987);
                if ((int)(_990 < _991) || (int)(_990 < _993)) {
                  if (_991 > _993) {
                    _1008 = select((_986 > 0.0f), 2, 3);
                  } else {
                    _1008 = select((_987 > 0.0f), 4, 5);
                  }
                } else {
                  _1008 = ((int)(uint)((int)(!(_985 > 0.0f))));
                }
                _1009 = _1008 + (uint)(asint(ForwardLightData_raw[8u].y));
                _1010 = _1009 * 288;
                _1013 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_1010 + 64u)))).x;
                _1014 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_1010 + 64u)))).y;
                _1015 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_1010 + 64u)))).z;
                _1016 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_1010 + 64u)))).w;
                _1019 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_1010 + 80u)))).x;
                _1020 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_1010 + 80u)))).y;
                _1021 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_1010 + 80u)))).z;
                _1022 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_1010 + 80u)))).w;
                _1025 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_1010 + 96u)))).x;
                _1026 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_1010 + 96u)))).y;
                _1027 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_1010 + 96u)))).z;
                _1028 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_1010 + 96u)))).w;
                _1031 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_1010 + 112u)))).x;
                _1032 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_1010 + 112u)))).y;
                _1033 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_1010 + 112u)))).z;
                _1034 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_1010 + 112u)))).w;
                _1036 = _1013;
                _1037 = _1014;
                _1038 = _1015;
                _1039 = _1016;
                _1040 = _1019;
                _1041 = _1020;
                _1042 = _1021;
                _1043 = _1022;
                _1044 = _1025;
                _1045 = _1026;
                _1046 = _1027;
                _1047 = _1028;
                _1048 = _1031;
                _1049 = _1032;
                _1050 = _1033;
                _1051 = _1034;
                _1052 = _1009;
              } else {
                _1036 = _961;
                _1037 = _960;
                _1038 = _959;
                _1039 = _958;
                _1040 = _957;
                _1041 = _956;
                _1042 = _955;
                _1043 = _954;
                _1044 = _953;
                _1045 = _952;
                _1046 = _951;
                _1047 = _950;
                _1048 = _949;
                _1049 = _948;
                _1050 = _947;
                _1051 = _946;
                _1052 = asint(ForwardLightData_raw[8u].y);
              }
              _1084 = mad(_987, asfloat(_1047), mad(_986, asfloat(_1043), (asfloat(_1039) * _985))) + asfloat(_1051);
              _1085 = (mad(_987, asfloat(_1044), mad(_986, asfloat(_1040), (asfloat(_1036) * _985))) + asfloat(_1048)) / _1084;
              _1086 = (mad(_987, asfloat(_1045), mad(_986, asfloat(_1041), (asfloat(_1037) * _985))) + asfloat(_1049)) / _1084;
              _1088 = ((uint)_1052 < (uint)8192);
              if (!_1088) {
                _1100 = ((int)((((_1052 * 21845) + (uint)(-178946048)) + uint(_1085 * 128.0f)) + ((int)(uint(_1086 * 128.0f)) << 7)));
              } else {
                _1100 = _1052;
              }
              _1103 = VirtualShadowMap_PageTable[_1100];
              _1109 = select(_1088, 128.0f, float((uint)((uint)((uint)(16384u) >> (((uint)(_1103) >> 20) & 31)))));
              if ((int)_1103 < (int)0) {
                _1128 = asfloat((((uint)(VirtualShadowMap_PhysicalPagePool.Load(int4((((int)(uint(_1109 * _1085)) & 127) | (((int)(_1103 << 7)) & 130944)), (((int)(uint(_1109 * _1086)) & 127) | (((uint)(_1103) >> 3) & 130944)), 0, 0)))).x));
                _1129 = true;
              } else {
                _1128 = 0.0f;
                _1129 = false;
              }
              _1134 = select((_1129 && (int)(_1128 > ((mad(_987, asfloat(_1046), mad(_986, asfloat(_1042), (asfloat(_1038) * _985))) + asfloat(_1050)) / _1084))), 0.0f, 1.0f);
            }
            _1137 = (_1134 * _656);
          } else {
            _1137 = 1.0f;
          }
          if (asint(_RootShaderParameters_raw[88u].y) == 0) {
            _1305 = (((float4)(DirectionalLightLightFunctionTexture.SampleLevel(DirectionalLightLightFunctionSampler, float2((((mad(_513, asfloat(_RootShaderParameters_raw[76u].x), mad(_512, asfloat(_RootShaderParameters_raw[75u].x), (asfloat(_RootShaderParameters_raw[74u].x) * _511))) + asfloat(_RootShaderParameters_raw[77u].x)) * 0.5f) + 0.5f), (0.5f - ((mad(_513, asfloat(_RootShaderParameters_raw[76u].y), mad(_512, asfloat(_RootShaderParameters_raw[75u].y), (asfloat(_RootShaderParameters_raw[74u].y) * _511))) + asfloat(_RootShaderParameters_raw[77u].y)) * 0.5f))), 0.0f))).x);
          } else {
            if (!(asint(_RootShaderParameters_raw[88u].z) == 0)) {
              _1145 = asint(_RootShaderParameters_raw[88u].z) * 5;
              _1148 = LightFunctionAtlas_LightInfoDataBuffer[_1145].x;
              _1149 = LightFunctionAtlas_LightInfoDataBuffer[_1145].y;
              _1150 = LightFunctionAtlas_LightInfoDataBuffer[_1145].z;
              _1151 = asint(_1149);
              _1152 = asint(_1150);
              _1156 = f16tof32(((uint)(((uint)(_1151) >> 8) & 65535)));
              _1165 = LightFunctionAtlas_LightInfoDataBuffer[((int)(_1145 + 1u))].x;
              _1166 = LightFunctionAtlas_LightInfoDataBuffer[((int)(_1145 + 1u))].y;
              _1167 = LightFunctionAtlas_LightInfoDataBuffer[((int)(_1145 + 1u))].z;
              _1168 = LightFunctionAtlas_LightInfoDataBuffer[((int)(_1145 + 1u))].w;
              _1171 = LightFunctionAtlas_LightInfoDataBuffer[((int)(_1145 + 2u))].x;
              _1172 = LightFunctionAtlas_LightInfoDataBuffer[((int)(_1145 + 2u))].y;
              _1173 = LightFunctionAtlas_LightInfoDataBuffer[((int)(_1145 + 2u))].z;
              _1174 = LightFunctionAtlas_LightInfoDataBuffer[((int)(_1145 + 2u))].w;
              _1177 = LightFunctionAtlas_LightInfoDataBuffer[((int)(_1145 + 3u))].x;
              _1178 = LightFunctionAtlas_LightInfoDataBuffer[((int)(_1145 + 3u))].y;
              _1179 = LightFunctionAtlas_LightInfoDataBuffer[((int)(_1145 + 3u))].z;
              _1180 = LightFunctionAtlas_LightInfoDataBuffer[((int)(_1145 + 3u))].w;
              _1183 = LightFunctionAtlas_LightInfoDataBuffer[((int)(_1145 + 4u))].x;
              _1184 = LightFunctionAtlas_LightInfoDataBuffer[((int)(_1145 + 4u))].y;
              _1185 = LightFunctionAtlas_LightInfoDataBuffer[((int)(_1145 + 4u))].z;
              _1186 = LightFunctionAtlas_LightInfoDataBuffer[((int)(_1145 + 4u))].w;
              _1202 = mad(_513, _1180, mad(_512, _1174, (_1168 * _511))) + _1186;
              _1203 = (mad(_513, _1179, mad(_512, _1173, (_1167 * _511))) + _1185) / _1202;
              _1204 = (mad(_513, _1178, mad(_512, _1172, (_1166 * _511))) + _1184) / _1202;
              _1205 = (mad(_513, _1177, mad(_512, _1171, (_1165 * _511))) + _1183) / _1202;
              switch (((int)(_1151 & 255))) {
                case 2: {
                  _1207 = LightFunctionAtlas_LightInfoDataBuffer[_1145].w;
                  _1208 = _1205 * _1207;
                  _1242 = (((_1203 / _1208) * 0.5f) + 0.5f);
                  _1243 = (((_1204 / _1208) * 0.5f) + 0.5f);
                  break;
                }
                case 1: {
                  _1217 = rsqrt(dot(float3(_1203, _1204, _1205), float3(_1203, _1204, _1205)));
                  _1218 = _1217 * _1203;
                  _1219 = _1217 * _1204;
                  _1222 = atan(_1219 / _1218);
                  _1225 = (_1218 < 0.0f);
                  _1226 = (_1218 == 0.0f);
                  _1227 = (_1219 >= 0.0f);
                  _1228 = (_1219 < 0.0f);
                  _1242 = select((_1226 && _1227), 0.75f, select((_1226 && _1228), 0.25f, ((select((_1225 && _1228), (_1222 + -3.1415927410125732f), select((_1225 && _1227), (_1222 + 3.1415927410125732f), _1222)) + 3.1415927410125732f) * 0.15915493667125702f)));
                  _1243 = (acos(_1217 * _1205) * 0.31830987334251404f);
                  break;
                }
                default: {
                  _1242 = _1203;
                  _1243 = _1204;
                  break;
                }
              }
              _1259 = View.TranslatedWorldCameraOrigin.x - _511;
              _1260 = View.TranslatedWorldCameraOrigin.y - _512;
              _1261 = View.TranslatedWorldCameraOrigin.z - _513;
              _1305 = ((saturate((_1148 - sqrt(((_1259 * _1259) + (_1260 * _1260)) + (_1261 * _1261))) / (_1148 * 0.20000000298023224f)) * (((((float4)(LightFunctionAtlas_LightFunctionAtlasTexture.SampleLevel(LightFunctionAtlas_LightFunctionAtlasSampler, float2(((LightFunctionAtlas.Slot_UVSize * saturate(frac(_1242))) + (float((uint)((uint)(_1152 & 65535))) * 1.52587890625e-05f)), ((LightFunctionAtlas.Slot_UVSize * saturate(frac(_1243))) + (float((uint)((uint)((uint)(_1152) >> 16))) * 1.52587890625e-05f))), 0.0f))).x) * (((float4)(LightFunctionAtlas_LightFunctionAtlasTexture.SampleLevel(LightFunctionAtlas_LightFunctionAtlasSampler, float2(((LightFunctionAtlas.Slot_UVSize * saturate(frac(_1242))) + (float((uint)((uint)(_1152 & 65535))) * 1.52587890625e-05f)), ((LightFunctionAtlas.Slot_UVSize * saturate(frac(_1243))) + (float((uint)((uint)((uint)(_1152) >> 16))) * 1.52587890625e-05f))), 0.0f))).x)) - _1156)) + _1156);
            } else {
              _1305 = 1.0f;
            }
          }
          if (asfloat(_RootShaderParameters_raw[84u].z) > 0.0f) {
            _1314 = dot(float3(_552, _553, _554), float3(0.30000001192092896f, 0.5899999737739563f, 0.10999999940395355f));
            _1319 = (VolumetricFog.HeightFogDirectionalLightInscatteringColor.x * _1314);
            _1320 = (VolumetricFog.HeightFogDirectionalLightInscatteringColor.y * _1314);
            _1321 = (VolumetricFog.HeightFogDirectionalLightInscatteringColor.z * _1314);
          } else {
            _1319 = _552;
            _1320 = _553;
            _1321 = _554;
          }
          _1332 = (((dot(float3(asfloat(ForwardLightData_raw[4u].x), asfloat(ForwardLightData_raw[4u].y), asfloat(ForwardLightData_raw[4u].z)), float3((-0.0f - _541), (-0.0f - _542), (-0.0f - _543))) * 2.0f) + asfloat(_RootShaderParameters_raw[86u].x)) * asfloat(_RootShaderParameters_raw[86u].x)) + 1.0f;
          _1336 = (1.0f - (asfloat(_RootShaderParameters_raw[86u].x) * asfloat(_RootShaderParameters_raw[86u].x))) / ((sqrt(_1332) * 12.566370964050293f) * _1332);
          _1337 = _1305 * _1137;
          _1348 = asfloat(_RootShaderParameters_raw[86u].x);
          _1349 = (((_1337 * _1319) * _1336) + _373);
          _1350 = (((_1337 * _1320) * _1336) + _374);
          _1351 = (((_1337 * _1321) * _1336) + _375);
        }
        _1352 = _1348 * _542;
        _1353 = _1348 * _543;
        _1354 = _1348 * _541;
        _1378 = _525 - View.ViewOriginHigh.x;
        _1379 = _526 - View.ViewOriginHigh.y;
        _1380 = _527 - View.ViewOriginHigh.z;
        _1381 = _1378 - _525;
        _1382 = _1379 - _526;
        _1383 = _1380 - _527;
        _1396 = (((-0.0f - View.ViewOriginHigh.x) - _1381) + (_525 - (_1378 - _1381))) + _1378;
        _1397 = (((-0.0f - View.ViewOriginHigh.y) - _1382) + (_526 - (_1379 - _1382))) + _1379;
        _1398 = (((-0.0f - View.ViewOriginHigh.z) - _1383) + (_527 - (_1380 - _1383))) + _1380;
        _1410 = (View.RelativeWorldToClip[3].w) + mad(_1398, (View.RelativeWorldToClip[2].w), mad(_1397, (View.RelativeWorldToClip[1].w), (_1396 * (View.RelativeWorldToClip[0].w))));
        _1424 = (LumenGIVolumeStruct.TranslucencyGIGridZParams.z * log2((LumenGIVolumeStruct.TranslucencyGIGridZParams.x * _1410) + LumenGIVolumeStruct.TranslucencyGIGridZParams.y)) / float((int)(LumenGIVolumeStruct.TranslucencyGIGridSize.z));
        _1427 = ((((View.RelativeWorldToClip[3].x) + mad(_1398, (View.RelativeWorldToClip[2].x), mad(_1397, (View.RelativeWorldToClip[1].x), (_1396 * (View.RelativeWorldToClip[0].x))))) / _1410) * 0.5f) + 0.5f;
        _1428 = 0.5f - ((((View.RelativeWorldToClip[3].y) + mad(_1398, (View.RelativeWorldToClip[2].y), mad(_1397, (View.RelativeWorldToClip[1].y), (_1396 * (View.RelativeWorldToClip[0].y))))) / _1410) * 0.5f);
        _1431 = LumenGIVolumeStruct_TranslucencyGIVolume0.SampleLevel(LumenGIVolumeStruct_TranslucencyGIVolumeSampler, float3(_1427, _1428, _1424), 0.0f);
        _1436 = LumenGIVolumeStruct_TranslucencyGIVolume1.SampleLevel(LumenGIVolumeStruct_TranslucencyGIVolumeSampler, float3(_1427, _1428, _1424), 0.0f);
        _1441 = dot(float3(_1431.x, _1431.y, _1431.z), float3(0.30000001192092896f, 0.5899999737739563f, 0.10999999940395355f)) + 9.999999747378752e-06f;
        _1442 = _1431.x / _1441;
        _1443 = _1431.y / _1441;
        _1444 = _1431.z / _1441;
        _1460 = max(dot(float4(_1431.x, (_1442 * _1436.x), (_1442 * _1436.y), (_1442 * _1436.z)), float4(1.0f, _1352, _1353, _1354)), 0.0f) + _1349;
        _1461 = max(dot(float4(_1431.y, (_1443 * _1436.x), (_1443 * _1436.y), (_1443 * _1436.z)), float4(1.0f, _1352, _1353, _1354)), 0.0f) + _1350;
        _1462 = max(dot(float4(_1431.z, (_1444 * _1436.x), (_1444 * _1436.y), (_1444 * _1436.z)), float4(1.0f, _1352, _1353, _1354)), 0.0f) + _1351;
        _1484 = asint(ForwardLightData_raw[2u].x) & 31;
        _1495 = ((int)((((int)((asint(ForwardLightData_raw[1u].y) * ((int)min((uint)((int)(uint(max(0.0f, (log2((asfloat(ForwardLightData_raw[3u].x) * _456) + asfloat(ForwardLightData_raw[3u].y)) * asfloat(ForwardLightData_raw[3u].z)))))), (uint)((asint(ForwardLightData_raw[1u].z) + -1))))) + ((uint)((uint)(VolumetricFog.FogGridToPixelXY.y * (int)(SV_DispatchThreadID.y)) >> _1484)))) * asint(ForwardLightData_raw[1u].x)) + ((uint)((uint)(VolumetricFog.FogGridToPixelXY.x * (int)(SV_DispatchThreadID.x)) >> _1484)))) << 1;
        _1498 = ForwardLightData_NumCulledLightsGrid[_1495];
        _1499 = (int)min((uint)(_1498), (uint)(asint(ForwardLightData_raw[0u].x)));
        _1502 = ForwardLightData_NumCulledLightsGrid[(_1495 | 1)];
        _1517 = (((_433 + float((uint)(SV_DispatchThreadID.x + 1u))) / VolumetricFog.ViewGridSize.x) * 2.0f) + -1.0f;
        _1519 = -0.0f - ((((_434 + float((uint)(SV_DispatchThreadID.y + 1u))) / VolumetricFog.ViewGridSize.y) * 2.0f) + -1.0f);
        _1529 = (exp2((_435 + float((uint)(SV_DispatchThreadID.z + 1u))) / VolumetricFog.GridZParams.z) - VolumetricFog.GridZParams.y) / VolumetricFog.GridZParams.x;
        [branch]
        if ((View.ViewToClip[3].w) < 1.0f) {
          _1547 = (1.0f / ((View.InvDeviceZToWorldZTransform.w + _1529) * View.InvDeviceZToWorldZTransform.z));
        } else {
          _1547 = (((View.ViewToClip[2].z) * _1529) + (View.ViewToClip[3].z));
        }
        _1583 = mad(_1547, asfloat(_RootShaderParameters_raw[7u].w), mad(_1519, asfloat(_RootShaderParameters_raw[6u].w), (asfloat(_RootShaderParameters_raw[5u].w) * _1517))) + asfloat(_RootShaderParameters_raw[8u].w);
        _1587 = _511 - ((mad(_1547, asfloat(_RootShaderParameters_raw[7u].x), mad(_1519, asfloat(_RootShaderParameters_raw[6u].x), (asfloat(_RootShaderParameters_raw[5u].x) * _1517))) + asfloat(_RootShaderParameters_raw[8u].x)) / _1583);
        _1588 = _512 - ((mad(_1547, asfloat(_RootShaderParameters_raw[7u].y), mad(_1519, asfloat(_RootShaderParameters_raw[6u].y), (asfloat(_RootShaderParameters_raw[5u].y) * _1517))) + asfloat(_RootShaderParameters_raw[8u].y)) / _1583);
        _1589 = _513 - ((mad(_1547, asfloat(_RootShaderParameters_raw[7u].z), mad(_1519, asfloat(_RootShaderParameters_raw[6u].z), (asfloat(_RootShaderParameters_raw[5u].z) * _1517))) + asfloat(_RootShaderParameters_raw[8u].z)) / _1583);
        _1599 = max((asfloat(_RootShaderParameters_raw[86u].y) * sqrt(((_1588 * _1588) + (_1587 * _1587)) + (_1589 * _1589))), 1.0f);
        _1600 = _1599 * _1599;
        if (!(_1499 == 0)) {
          _1604 = _1460;
          _1605 = _1461;
          _1606 = _1462;
          _1607 = 0;
          while(true) {
            _1612 = (((uint)(ForwardLightData_CulledLightDataGrid16Bit.Load((int)(_1607 + _1502)))).x) * 6;
            _1616 = ForwardLightData_ForwardLocalLightBuffer[((int)(_1612 + 4u))].x;
            _1617 = ForwardLightData_ForwardLocalLightBuffer[((int)(_1612 + 4u))].y;
            _1618 = ForwardLightData_ForwardLocalLightBuffer[((int)(_1612 + 4u))].z;
            _1621 = ForwardLightData_ForwardLocalLightBuffer[((int)(_1612 + 3u))].x;
            _1622 = ForwardLightData_ForwardLocalLightBuffer[((int)(_1612 + 3u))].y;
            _1623 = ForwardLightData_ForwardLocalLightBuffer[((int)(_1612 + 3u))].w;
            _1626 = ForwardLightData_ForwardLocalLightBuffer[((int)(_1612 + 2u))].x;
            _1627 = ForwardLightData_ForwardLocalLightBuffer[((int)(_1612 + 2u))].y;
            _1628 = ForwardLightData_ForwardLocalLightBuffer[((int)(_1612 + 2u))].z;
            _1631 = ForwardLightData_ForwardLocalLightBuffer[(_1612 | 1)].x;
            _1632 = ForwardLightData_ForwardLocalLightBuffer[(_1612 | 1)].w;
            _1634 = ForwardLightData_ForwardLocalLightBuffer[_1612].w;
            _1635 = asint(_1623);
            _1637 = f16tof32(((uint)((uint)(_1635) >> 16)));
            if (_1637 > 0.0f) {
              _1640 = ForwardLightData_ForwardLocalLightBuffer[(_1612 | 1)].y;
              _1641 = ForwardLightData_ForwardLocalLightBuffer[((int)(_1612 + 2u))].w;
              _1642 = ForwardLightData_ForwardLocalLightBuffer[_1612].z;
              _1643 = ForwardLightData_ForwardLocalLightBuffer[_1612].y;
              _1644 = ForwardLightData_ForwardLocalLightBuffer[_1612].x;
              _1645 = ForwardLightData_ForwardLocalLightBuffer[((int)(_1612 + 3u))].z;
              _1648 = ForwardLightData_ForwardLocalLightBuffer[((int)(_1612 + 5u))].z;
              _1649 = asint(_1641);
              _1651 = ((uint)(_1649) >> 16) & 3;
              _1652 = asint(_1640);
              _1666 = f16tof32(((uint)(asint(_1645) & 65535)));
              _1667 = -0.0f - _1666;
              _1668 = f16tof32(_1635);
              _1669 = -0.0f - _1668;
              _1670 = (_1632 == 0.0f);
              _1672 = (_1651 == 3);
              _1673 = asint(_1648);
              _1675 = f16tof32(((uint)(_1673 & 65535)));
              _1679 = float((uint)((uint)(((uint)(_1673) >> 16) & 1023))) * 0.0009775171056389809f;
              _1681 = ((uint)(_1649) >> 20) & 255;
              _1682 = _1644 - _511;
              _1683 = _1643 - _512;
              _1684 = _1642 - _513;
              _1685 = dot(float3(_1682, _1683, _1684), float3(_1682, _1683, _1684));
              _1686 = rsqrt(_1685);
              _1687 = _1686 * _1682;
              _1688 = _1686 * _1683;
              _1689 = _1686 * _1684;
              if (_1670) {
                _1692 = (_1634 * _1634) * _1685;
                _1695 = saturate(1.0f - (_1692 * _1692));
                _1708 = (_1695 * _1695);
              } else {
                _1698 = _1682 * _1634;
                _1699 = _1683 * _1634;
                _1700 = _1684 * _1634;
                _1708 = exp2(log2(1.0f - saturate(dot(float3(_1698, _1699, _1700), float3(_1698, _1699, _1700)))) * _1632);
              }
              if (_1651 == 2) {
                _1713 = saturate((dot(float3(_1687, _1688, _1689), float3(_1626, _1627, _1628)) - _1621) * _1622);
                _1717 = ((_1713 * _1713) * _1708);
              } else {
                _1717 = _1708;
              }
              if (_1672) {
                _1723 = select((dot(float3(_1626, _1627, _1628), float3(_1687, _1688, _1689)) < 0.0f), 0.0f, _1717);
              } else {
                _1723 = _1717;
              }
              if (_1672) {
                _1727 = (_1628 * _1617) - (_1627 * _1618);
                _1730 = (_1626 * _1618) - (_1628 * _1616);
                _1733 = (_1627 * _1616) - (_1626 * _1617);
                if (_1679 > 0.03500000014901161f) {
                  _1738 = mad(_1733, _1684, mad(_1730, _1683, (_1682 * _1727)));
                  _1741 = mad(_1618, _1684, mad(_1617, _1683, (_1682 * _1616)));
                  _1744 = mad(_1628, _1684, mad(_1627, _1683, (_1682 * _1626)));
                  _1748 = _1679 * _1675;
                  _1749 = min(_1744, _1748);
                  _1753 = (sqrt(1.0f - (_1679 * _1679)) * _1675) * (_1749 / max(9.999999747378752e-05f, _1748));
                  _1764 = float((int)(((int)(uint)((int)(_1738 > 0.0f))) - ((int)(uint)((int)(_1738 < 0.0f)))));
                  _1765 = float((int)(((int)(uint)((int)(_1741 > 0.0f))) - ((int)(uint)((int)(_1741 < 0.0f)))));
                  _1779 = max((_1744 - _1749), 0.0010000000474974513f);
                  _1786 = ((abs(((_1667 - _1753) + max(abs(_1738), (_1753 + _1666))) * _1764) / _1779) * _1749) - _1753;
                  _1787 = ((abs(((_1669 - _1753) + max(abs(_1741), (_1753 + _1668))) * _1765) / _1779) * _1749) - _1753;
                  _1798 = min(max(((_1786 * max(0.0f, (-0.0f - _1764))) - _1666), _1667), _1666);
                  _1799 = min(max(((_1787 * max(0.0f, (-0.0f - _1765))) - _1668), _1669), _1668);
                  _1808 = min(max((_1666 - (max(0.0f, _1764) * _1786)), _1667), _1666);
                  _1809 = min(max((_1668 - (max(0.0f, _1765) * _1787)), _1669), _1668);
                  _1812 = (_1808 + _1798) * 0.5f;
                  _1813 = (_1809 + _1799) * 0.5f;
                  _1831 = ((_1682 - (_1812 * _1727)) - (_1813 * _1616));
                  _1832 = ((_1683 - (_1812 * _1730)) - (_1813 * _1617));
                  _1833 = ((_1684 - (_1812 * _1733)) - (_1813 * _1618));
                  _1834 = ((_1808 - _1798) * 0.5f);
                  _1835 = ((_1809 - _1799) * 0.5f);
                } else {
                  _1831 = _1682;
                  _1832 = _1683;
                  _1833 = _1684;
                  _1834 = _1666;
                  _1835 = _1668;
                }
                if (!((int)(_1834 == 0.0f) || (int)(_1835 == 0.0f))) {
                  _1840 = dot(float3(_1727, _1730, _1733), float3(_1831, _1832, _1833));
                  _1841 = dot(float3(_1616, _1617, _1618), float3(_1831, _1832, _1833));
                  _1842 = dot(float3(_1626, _1627, _1628), float3(_1831, _1832, _1833));
                  _1843 = _1840 - _1834;
                  _1844 = _1840 + _1834;
                  _1845 = _1841 - _1835;
                  _1846 = _1841 + _1835;
                  _1847 = _1842 * _1842;
                  _1850 = rsqrt(dot(float2(_1843, _1845), float2(_1843, _1845)) + _1847);
                  _1851 = _1850 * _1843;
                  _1852 = _1850 * _1845;
                  _1853 = _1850 * _1842;
                  _1856 = rsqrt(dot(float2(_1844, _1845), float2(_1844, _1845)) + _1847);
                  _1857 = _1856 * _1844;
                  _1858 = _1856 * _1845;
                  _1859 = _1856 * _1842;
                  _1862 = rsqrt(dot(float2(_1844, _1846), float2(_1844, _1846)) + _1847);
                  _1863 = _1862 * _1844;
                  _1864 = _1862 * _1846;
                  _1865 = _1862 * _1842;
                  _1868 = rsqrt(dot(float2(_1843, _1846), float2(_1843, _1846)) + _1847);
                  _1869 = _1868 * _1843;
                  _1870 = _1868 * _1846;
                  _1871 = _1868 * _1842;
                  _1872 = dot(float3(_1851, _1852, _1853), float3(_1857, _1858, _1859));
                  _1873 = dot(float3(_1857, _1858, _1859), float3(_1863, _1864, _1865));
                  _1874 = dot(float3(_1863, _1864, _1865), float3(_1869, _1870, _1871));
                  _1875 = dot(float3(_1869, _1870, _1871), float3(_1851, _1852, _1853));
                  _1884 = rsqrt(_1873 + 1.0f) * (1.5707999467849731f - (_1873 * 0.17499999701976776f));
                  _1893 = rsqrt(_1875 + 1.0f) * (1.5707999467849731f - (_1875 * 0.17499999701976776f));
                  _1895 = -0.0f - ((1.5707999467849731f - (_1872 * 0.17499999701976776f)) * rsqrt(_1872 + 1.0f));
                  _1902 = (_1884 * _1863) + (_1851 * _1895);
                  _1903 = (_1884 * _1864) + (_1852 * _1895);
                  _1904 = (_1884 * _1865) + (_1853 * _1895);
                  _1918 = -0.0f - ((1.5707999467849731f - (_1874 * 0.17499999701976776f)) * rsqrt(_1874 + 1.0f));
                  _1922 = (_1893 * _1851) + (_1863 * _1918);
                  _1923 = (_1893 * _1852) + (_1864 * _1918);
                  _1924 = (_1893 * _1853) + (_1865 * _1918);
                  _1934 = ((_1924 * _1870) - (_1923 * _1871)) + ((_1904 * _1858) - (_1903 * _1859));
                  _1935 = ((_1922 * _1871) - (_1924 * _1869)) + ((_1902 * _1859) - (_1904 * _1857));
                  _1936 = ((_1923 * _1869) - (_1922 * _1870)) + ((_1903 * _1857) - (_1902 * _1858));
                  _1949 = ((_1934 * _1727) + (_1935 * _1616)) + (_1936 * _1626);
                  _1950 = ((_1934 * _1730) + (_1935 * _1617)) + (_1936 * _1627);
                  _1951 = ((_1934 * _1733) + (_1935 * _1618)) + (_1936 * _1628);
                  _1952 = dot(float3(_1949, _1950, _1951), float3(_1949, _1950, _1951));
                  _1987 = ((_1952 * 0.5f) * rsqrt(_1952));
                } else {
                  _1987 = 0.0f;
                }
              } else {
                _1957 = _1668 * 0.5f;
                _1958 = _1957 * _1616;
                _1959 = _1957 * _1617;
                _1960 = _1957 * _1618;
                _1961 = _1682 - _1958;
                _1962 = _1683 - _1959;
                _1963 = _1684 - _1960;
                _1964 = _1958 + _1682;
                _1965 = _1959 + _1683;
                _1966 = _1960 + _1684;
                _1968 = dot(float3(_1961, _1962, _1963), float3(_1961, _1962, _1963));
                [branch]
                if (_1668 > 0.0f) {
                  _1973 = rsqrt(dot(float3(_1964, _1965, _1966), float3(_1964, _1965, _1966))) * rsqrt(_1968);
                  _1984 = (_1973 / ((((dot(float3(_1961, _1962, _1963), float3(_1964, _1965, _1966)) * 0.5f) + _1600) * _1973) + 0.5f));
                } else {
                  _1984 = (1.0f / (_1968 + _1600));
                }
                _1987 = select(_1670, _1984, 1.0f);
              }
              if (!(_1681 == 0)) {
                _1990 = _1681 * 5;
                _1993 = LightFunctionAtlas_LightInfoDataBuffer[_1990].x;
                _1994 = LightFunctionAtlas_LightInfoDataBuffer[_1990].y;
                _1995 = LightFunctionAtlas_LightInfoDataBuffer[_1990].z;
                _1996 = asint(_1994);
                _1997 = asint(_1995);
                _2001 = f16tof32(((uint)(((uint)(_1996) >> 8) & 65535)));
                _2010 = LightFunctionAtlas_LightInfoDataBuffer[(_1990 + 1)].x;
                _2011 = LightFunctionAtlas_LightInfoDataBuffer[(_1990 + 1)].y;
                _2012 = LightFunctionAtlas_LightInfoDataBuffer[(_1990 + 1)].z;
                _2013 = LightFunctionAtlas_LightInfoDataBuffer[(_1990 + 1)].w;
                _2016 = LightFunctionAtlas_LightInfoDataBuffer[(_1990 + 2)].x;
                _2017 = LightFunctionAtlas_LightInfoDataBuffer[(_1990 + 2)].y;
                _2018 = LightFunctionAtlas_LightInfoDataBuffer[(_1990 + 2)].z;
                _2019 = LightFunctionAtlas_LightInfoDataBuffer[(_1990 + 2)].w;
                _2022 = LightFunctionAtlas_LightInfoDataBuffer[(_1990 + 3)].x;
                _2023 = LightFunctionAtlas_LightInfoDataBuffer[(_1990 + 3)].y;
                _2024 = LightFunctionAtlas_LightInfoDataBuffer[(_1990 + 3)].z;
                _2025 = LightFunctionAtlas_LightInfoDataBuffer[(_1990 + 3)].w;
                _2028 = LightFunctionAtlas_LightInfoDataBuffer[(_1990 + 4)].x;
                _2029 = LightFunctionAtlas_LightInfoDataBuffer[(_1990 + 4)].y;
                _2030 = LightFunctionAtlas_LightInfoDataBuffer[(_1990 + 4)].z;
                _2031 = LightFunctionAtlas_LightInfoDataBuffer[(_1990 + 4)].w;
                _2047 = mad(_513, _2025, mad(_512, _2019, (_2013 * _511))) + _2031;
                _2048 = (mad(_513, _2024, mad(_512, _2018, (_2012 * _511))) + _2030) / _2047;
                _2049 = (mad(_513, _2023, mad(_512, _2017, (_2011 * _511))) + _2029) / _2047;
                _2050 = (mad(_513, _2022, mad(_512, _2016, (_2010 * _511))) + _2028) / _2047;
                switch (((int)(_1996 & 255))) {
                  case 2: {
                    _2052 = LightFunctionAtlas_LightInfoDataBuffer[_1990].w;
                    _2053 = _2050 * _2052;
                    _2087 = (((_2048 / _2053) * 0.5f) + 0.5f);
                    _2088 = (((_2049 / _2053) * 0.5f) + 0.5f);
                    break;
                  }
                  case 1: {
                    _2062 = rsqrt(dot(float3(_2048, _2049, _2050), float3(_2048, _2049, _2050)));
                    _2063 = _2062 * _2048;
                    _2064 = _2062 * _2049;
                    _2067 = atan(_2064 / _2063);
                    _2070 = (_2063 < 0.0f);
                    _2071 = (_2063 == 0.0f);
                    _2072 = (_2064 >= 0.0f);
                    _2073 = (_2064 < 0.0f);
                    _2087 = select((_2071 && _2072), 0.75f, select((_2071 && _2073), 0.25f, ((select((_2070 && _2073), (_2067 + -3.1415927410125732f), select((_2070 && _2072), (_2067 + 3.1415927410125732f), _2067)) + 3.1415927410125732f) * 0.15915493667125702f)));
                    _2088 = (acos(_2062 * _2050) * 0.31830987334251404f);
                    break;
                  }
                  default: {
                    _2087 = _2048;
                    _2088 = _2049;
                    break;
                  }
                }
                _2108 = View.TranslatedWorldCameraOrigin.x - _511;
                _2109 = View.TranslatedWorldCameraOrigin.y - _512;
                _2110 = View.TranslatedWorldCameraOrigin.z - _513;
                _2125 = ((saturate((_1993 - sqrt(((_2108 * _2108) + (_2109 * _2109)) + (_2110 * _2110))) / (_1993 * 0.20000000298023224f)) * (((((float4)(LightFunctionAtlas_LightFunctionAtlasTexture.SampleLevel(LightFunctionAtlas_LightFunctionAtlasSampler, float2(((LightFunctionAtlas.Slot_UVSize * saturate(frac(_2087))) + (float((uint)((uint)(_1997 & 65535))) * 1.52587890625e-05f)), ((LightFunctionAtlas.Slot_UVSize * saturate(frac(_2088))) + (float((uint)((uint)((uint)(_1997) >> 16))) * 1.52587890625e-05f))), 0.0f))).x) * (((float4)(LightFunctionAtlas_LightFunctionAtlasTexture.SampleLevel(LightFunctionAtlas_LightFunctionAtlasSampler, float2(((LightFunctionAtlas.Slot_UVSize * saturate(frac(_2087))) + (float((uint)((uint)(_1997 & 65535))) * 1.52587890625e-05f)), ((LightFunctionAtlas.Slot_UVSize * saturate(frac(_2088))) + (float((uint)((uint)((uint)(_1997) >> 16))) * 1.52587890625e-05f))), 0.0f))).x)) - _2001)) + _2001);
              } else {
                _2125 = 1.0f;
              }
              _2140 = (((dot(float3(_1687, _1688, _1689), float3((-0.0f - _541), (-0.0f - _542), (-0.0f - _543))) * 2.0f) + asfloat(_RootShaderParameters_raw[86u].x)) * asfloat(_RootShaderParameters_raw[86u].x)) + 1.0f;
              _2147 = ((_1723 * _1637) * _1987) * ((1.0f - (asfloat(_RootShaderParameters_raw[86u].x) * asfloat(_RootShaderParameters_raw[86u].x))) / ((sqrt(_2140) * 12.566370964050293f) * _2140));
              _2155 = ((((float((uint)((uint)(_1652 & 1023))) * _1631) * _2125) * _2147) + _1604);
              _2156 = ((((float((uint)((uint)(((uint)(_1652) >> 10) & 1023))) * _1631) * _2125) * _2147) + _1605);
              _2157 = ((((float((uint)((uint)(((uint)(_1652) >> 20) & 1023))) * _1631) * _2125) * _2147) + _1606);
            } else {
              _2155 = _1604;
              _2156 = _1605;
              _2157 = _1606;
            }
            _2158 = _1607 + 1u;
            if (!(_2158 == _1499)) {
              _1604 = _2155;
              _1605 = _2156;
              _1606 = _2157;
              _1607 = _2158;
              continue;
            }
            _2162 = _2155;
            _2163 = _2156;
            _2164 = _2157;
            break;
          }
        } else {
          _2162 = _1460;
          _2163 = _1461;
          _2164 = _1462;
        }
        _2165 = _376 + 1;
        if ((uint)_2165 < (uint)_371) {
          _373 = _2162;
          _374 = _2163;
          _375 = _2164;
          _376 = _2165;
          continue;
        }
        _2168 = float((uint)_371);
        _2175 = LocalShadowedLightScattering.Load(int4((int)(SV_DispatchThreadID.x), (int)(SV_DispatchThreadID.y), (int)(SV_DispatchThreadID.z), 0));
        _2186 = VBufferA.Load(int4((int)(SV_DispatchThreadID.x), (int)(SV_DispatchThreadID.y), (int)(SV_DispatchThreadID.z), 0));
        _2192 = _2186.w + dot(float3(_2186.x, _2186.y, _2186.z), float3(0.30000001192092896f, 0.5899999737739563f, 0.10999999940395355f));
        [branch]
        if (!(asint(_RootShaderParameters_raw[87u].w) == 0)) {
          _2198 = VBufferB.Load(int4((int)(SV_DispatchThreadID.x), (int)(SV_DispatchThreadID.y), (int)(SV_DispatchThreadID.z), 0));
          _2203 = _2198.x;
          _2204 = _2198.y;
          _2205 = _2198.z;
        } else {
          _2203 = 0.0f;
          _2204 = 0.0f;
          _2205 = 0.0f;
        }
        _2213 = View.PreExposure * (_2203 + (_2186.x * ((_2175.x * View.OneOverPreExposure) + (_2162 / _2168))));
        _2214 = View.PreExposure * (_2204 + (_2186.y * ((_2175.y * View.OneOverPreExposure) + (_2163 / _2168))));
        _2215 = View.PreExposure * (_2205 + (_2186.z * ((_2175.z * View.OneOverPreExposure) + (_2164 / _2168))));
        [branch]
        if (_357 > 0.0f) {
          float3 _fog_tex_size = float3(
              VolumetricFog.ResourceGridSize.x,
              VolumetricFog.ResourceGridSize.y,
              VolumetricFog.ResourceGridSize.z);
          float3 _hist_uvw = float3(min(_337, View.VolumetricFogPrevUVMax.x), min(_338, View.VolumetricFogPrevUVMax.y), min(_339, 1.0f));
          _2226 = SampleFogHistory(LightScatteringHistory, LightScatteringHistorySampler,
              _hist_uvw, _fog_tex_size, float(InjectionFogFilterMode()));
          _2233 = View.PreExposure * asfloat(_RootShaderParameters_raw[85u].y);

          // Neighborhood clamping (second path, same logic as first).
          float3 _voxel_step = 1.0 / _fog_tex_size;
          float4 _n_xp = LightScatteringHistory.SampleLevel(LightScatteringHistorySampler, _hist_uvw + float3(_voxel_step.x, 0, 0), 0);
          float4 _n_xn = LightScatteringHistory.SampleLevel(LightScatteringHistorySampler, _hist_uvw - float3(_voxel_step.x, 0, 0), 0);
          float4 _n_yp = LightScatteringHistory.SampleLevel(LightScatteringHistorySampler, _hist_uvw + float3(0, _voxel_step.y, 0), 0);
          float4 _n_yn = LightScatteringHistory.SampleLevel(LightScatteringHistorySampler, _hist_uvw - float3(0, _voxel_step.y, 0), 0);
          float4 _n_zp = LightScatteringHistory.SampleLevel(LightScatteringHistorySampler, _hist_uvw + float3(0, 0, _voxel_step.z), 0);
          float4 _n_zn = LightScatteringHistory.SampleLevel(LightScatteringHistorySampler, _hist_uvw - float3(0, 0, _voxel_step.z), 0);
          float4 _bilinear_center = LightScatteringHistory.SampleLevel(LightScatteringHistorySampler, _hist_uvw, 0);
          float4 _nhood_min = min(min(min(_n_xp, _n_xn), min(_n_yp, _n_yn)), min(min(_n_zp, _n_zn), _bilinear_center));
          float4 _nhood_max = max(max(max(_n_xp, _n_xn), max(_n_yp, _n_yn)), max(max(_n_zp, _n_zn), _bilinear_center));
          _2226 = clamp(_2226, _nhood_min, _nhood_max);

          _2250 = ((((_2233 * _2226.x) - _2213) * _357) + _2213);
          _2251 = ((((_2233 * _2226.y) - _2214) * _357) + _2214);
          _2252 = ((((_2233 * _2226.z) - _2215) * _357) + _2215);
          _2253 = (lerp(_2192, _2226.w, _357));
        } else {
          _2250 = _2213;
          _2251 = _2214;
          _2252 = _2215;
          _2253 = _2192;
        }
        if ((int)((int)(int)(SV_DispatchThreadID.z) < (int)VolumetricFog.ResourceGridSizeInt.z) && ((int)((int)((int)(int)(SV_DispatchThreadID.x) < (int)VolumetricFog.ResourceGridSizeInt.x) && (int)((int)(int)(SV_DispatchThreadID.y) < (int)VolumetricFog.ResourceGridSizeInt.y)))) {
          if ((InjectionEnum(ENUM_DEBUG_FOG_SHIFT) > 0u) && float(InjectionEnum(ENUM_DEBUG_FOG_SHIFT)) < 1.5f) {
            uint _dbg_s2 = View.FrameCounter % 32u;
            float2 _dbg_n2 = FastNoiseLoad(SV_DispatchThreadID.x % 128u, SV_DispatchThreadID.y % 128u, _dbg_s2);
            float _dbg_v2 = (_dbg_n2.x + _dbg_n2.y) * 0.5f;
            if (InjectionToggle(TOGGLE_USE_ISFAST_FOG)) {
              float4 _dbg_col2 = (_dbg_v2 == 0.0f)
                  ? float4(10.0f * View.PreExposure, 0.0f, 0.0f, _2253)
                  : float4(0.0f, _dbg_v2 * 5.0f * View.PreExposure, 0.0f, _2253);
              RWLightScattering[int3((int)(SV_DispatchThreadID.x), (int)(SV_DispatchThreadID.y), (int)(SV_DispatchThreadID.z))] = _dbg_col2;
            } else {
              RWLightScattering[int3((int)(SV_DispatchThreadID.x), (int)(SV_DispatchThreadID.y), (int)(SV_DispatchThreadID.z))] = float4(3.0f * View.PreExposure, 3.0f * View.PreExposure, 0.0f, _2253);
            }
          } else if (float(InjectionEnum(ENUM_DEBUG_FOG_SHIFT)) > 1.5f) {
            float4 _bilinear_ref2 = LightScatteringHistory.SampleLevel(LightScatteringHistorySampler,
                float3(min(_337, View.VolumetricFogPrevUVMax.x), min(_338, View.VolumetricFogPrevUVMax.y), min(_339, 1.0f)), 0.0f);
            float _diff2 = length(_2226.xyz - _bilinear_ref2.xyz);
            float4 _mode_col2 = (float(InjectionFogFilterMode()) > 2.5f) ? float4(0, _diff2 * 50.0f, 0, 1)
                              : (float(InjectionFogFilterMode()) > 1.5f) ? float4(0, _diff2 * 50.0f, _diff2 * 50.0f, 1)
                              : (float(InjectionFogFilterMode()) > 0.5f) ? float4(0, 0, _diff2 * 50.0f, 1)
                              : float4(_diff2 * 50.0f, 0, _diff2 * 50.0f, 1);
            RWLightScattering[int3((int)(SV_DispatchThreadID.x), (int)(SV_DispatchThreadID.y), (int)(SV_DispatchThreadID.z))] = float4(_mode_col2.xyz * View.PreExposure, _2253);
          } else {
            RWLightScattering[int3((int)(SV_DispatchThreadID.x), (int)(SV_DispatchThreadID.y), (int)(SV_DispatchThreadID.z))] = float4(select(((uint)asint(_2250) < (uint)2139095040), _2250, 0.0f), select(((uint)asint(_2251) < (uint)2139095040), _2251, 0.0f), select(((uint)asint(_2252) < (uint)2139095040), _2252, 0.0f), select(((uint)asint(_2253) < (uint)2139095040), _2253, 0.0f));
          }
        }
        break;
      }
    }
  }
}