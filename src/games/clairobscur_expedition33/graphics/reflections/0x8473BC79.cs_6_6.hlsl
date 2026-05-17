#include "../shared.h"

// IS-FAST noise buffer (ByteAddressBuffer root SRV â€” avoids ReShade heap-swap corruption)
ByteAddressBuffer ISFASTNoise : register(t0, space50);
static const uint ISFAST_W = 128u;
static const uint ISFAST_H = 128u;
static const uint ISFAST_SLICE_TEXELS = ISFAST_W * ISFAST_H;
static const uint ISFAST_ELEMENT_BYTES = 8u;
static float2 ISFASTNoiseLoad(uint x, uint y, uint slice) {
  return asfloat(ISFASTNoise.Load2((slice * ISFAST_SLICE_TEXELS + y * ISFAST_W + x) * ISFAST_ELEMENT_BYTES));
}

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


Texture2D<float4> SceneTexturesStruct_SceneDepthTexture : register(t0);

Texture2D<float4> SceneTexturesStruct_GBufferATexture : register(t1);

Texture2D<float4> SceneTexturesStruct_GBufferBTexture : register(t2);

Texture2D<float4> SceneTexturesStruct_GBufferDTexture : register(t3);

Buffer<uint> ReflectionResolveTileData : register(t4);

Texture2DArray<float4> HistoryNumFramesAccumulated : register(t5);

Texture2DArray<float4> ResolvedReflections : register(t6);

Texture2DArray<float4> ResolvedReflectionsDepth : register(t7);

Texture2DArray<float4> SpecularIndirectHistory : register(t8);

Texture2D<float4> DepthHistory : register(t9);

Texture2DArray<float> ResolveVariance : register(t10);

Texture2DArray<float4> ResolveVarianceHistory : register(t11);

Texture2D<float4> VelocityTexture : register(t12);

RWTexture2DArray<float4> RWSpecularIndirectAccumulated : register(u0);

RWTexture2DArray<float> RWResolveVariance : register(u1);

RWTexture2DArray<float> RWNumHistoryFramesAccumulated : register(u2);

cbuffer _RootShaderParameters : register(b0) {
  float HistoryDistanceThreshold : packoffset(c007.z);
  float PrevInvPreExposure : packoffset(c007.w);
  float MaxFramesAccumulated : packoffset(c008.x);
  float NeighborhoodClampExpandWithResolveVariance : packoffset(c008.y);
  float4 HistoryScreenPositionScaleBias : packoffset(c009.x);
  float4 HistoryUVMinMax : packoffset(c010.x);
  uint ReflectionDownsampleFactor : packoffset(c015.x);
  uint ReflectionsStateFrameIndexMod8 : packoffset(c018.z);
  float MaxRoughnessToTrace : packoffset(c020.x);
};

cbuffer View : register(b1) {
  FViewConstants View : packoffset(c000.x);
};

SamplerState D3DStaticPointClampedSampler : register(s1, space1000);

SamplerState D3DStaticBilinearClampedSampler : register(s3, space1000);

// DXIL FirstbitHi: returns bit position counting from MSB (leading zeros count)
uint firstbithigh_msb(int value) { return (value == 0) ? 0xFFFFFFFF : (31u - firstbithigh(value)); }
uint firstbithigh_msb(uint value) { return (value == 0) ? 0xFFFFFFFF : (31u - firstbithigh(value)); }

// --- Shared memory for percentile-based firefly clamping ---
// 64 threads per group dispatch → 64 luma samples sorted per tile via odd-even sort.
// Reference: Alber 2025, "Percentile-based Adaptive SVGF" (HPG Student Competition).
// Rephrased for licensing compliance.
groupshared float s_firefly_luma[64];

[numthreads(64, 1, 1)]
void main(
  uint3 SV_DispatchThreadID : SV_DispatchThreadID,
  uint3 SV_GroupID : SV_GroupID,
  uint3 SV_GroupThreadID : SV_GroupThreadID,
  uint SV_GroupIndex : SV_GroupIndex
) {
  uint _26;
  int _34;
  int _35;
  uint _39;
  uint _40;
  float _57;
  float _58;
  float4 _60;
  float4 _65;
  float4 _68;
  float _80;
  float4 _82;
  float _106;
  float _110;
  float _118;
  float _120;
  float _121;
  float _122;
  bool _127;
  float _154;
  float _155;
  float _156;
  float _188;
  float _189;
  bool _214;
  int _600;
  float _601;
  float _602;
  float _603;
  float _604;
  float _605;
  float _606;
  int _641;
  float _642;
  float _643;
  float _644;
  float _645;
  float _646;
  float _647;
  int _682;
  float _683;
  float _684;
  float _685;
  float _686;
  float _687;
  float _688;
  int _720;
  float _721;
  float _722;
  float _723;
  float _724;
  float _725;
  float _726;
  int _760;
  float _761;
  float _762;
  float _763;
  float _764;
  float _765;
  float _766;
  int _800;
  float _801;
  float _802;
  float _803;
  float _804;
  float _805;
  float _806;
  int _838;
  float _839;
  float _840;
  float _841;
  float _842;
  float _843;
  float _844;
  int _876;
  float _877;
  float _878;
  float _879;
  float _880;
  float _881;
  float _882;
  bool _899;
  float _906;
  bool _915;
  float _922;
  float _933;
  float _948;
  float _995;
  float _159;
  float _165;
  float _166;
  float _167;
  float _204;
  float _205;
  float _217;
  float _218;
  float _223;
  float _224;
  float _225;
  float _226;
  float _227;
  float _228;
  float _231;
  float _232;
  float _235;
  float _236;
  float _239;
  float _240;
  float _243;
  float _244;
  float4 _246;
  float4 _251;
  uint _259;
  float _264;
  float _265;
  float _266;
  int _267;
  float _276;
  float _284;
  float _304;
  float4 _307;
  bool _348;
  float _349;
  float _350;
  float _363;
  float _364;
  float _365;
  float _367;
  float _376;
  float _389;
  float _398;
  float _403;
  float _404;
  float _405;
  float _406;
  float _407;
  float _408;
  float _419;
  float _420;
  float _421;
  float _422;
  float4 _424;
  float4 _429;
  float4 _434;
  float4 _439;
  float _446;
  float _449;
  float _452;
  float _455;
  float _478;
  float _485;
  float _486;
  float _487;
  float _488;
  float _489;
  float _490;
  float _497;
  float _498;
  float _499;
  float _500;
  float4 _501;
  float4 _506;
  float4 _511;
  float4 _516;
  float _523;
  float _526;
  float _529;
  float _532;
  float _555;
  float _559;
  float _560;
  float _561;
  uint _565;
  uint _567;
  int _572;
  int _573;
  float4 _574;
  float _584;
  float _585;
  float _586;
  float _590;
  float _591;
  float _592;
  int _609;
  float4 _610;
  int _620;
  float _621;
  float _622;
  float _623;
  float _624;
  float _628;
  float _629;
  float _630;
  int _650;
  float4 _651;
  int _661;
  float _662;
  float _663;
  float _664;
  float _665;
  float _669;
  float _670;
  float _671;
  float4 _689;
  int _699;
  float _700;
  float _701;
  float _702;
  float _703;
  float _707;
  float _708;
  float _709;
  int _728;
  float4 _729;
  int _739;
  float _740;
  float _741;
  float _742;
  float _743;
  float _747;
  float _748;
  float _749;
  int _768;
  float4 _769;
  int _779;
  float _780;
  float _781;
  float _782;
  float _783;
  float _787;
  float _788;
  float _789;
  float4 _807;
  int _817;
  float _818;
  float _819;
  float _820;
  float _821;
  float _825;
  float _826;
  float _827;
  float4 _845;
  int _855;
  float _856;
  float _857;
  float _858;
  float _859;
  float _863;
  float _864;
  float _865;
  float _884;
  bool _893;
  bool _923;
  bool _938;
  float _939;
  float _940;
  float _952;
  float _957;
  float _958;
  float _959;
  float _960;
  float _970;
  float _971;
  float _972;
  float4 _975;
  float _1006;
  float _1008;
  float _1015;
  float _1016;
  float _1017;
  _26 = ReflectionResolveTileData.Load((int)(SV_GroupID.x));
  _34 = (((int)(_26.x << 3)) & 32760) | ((int)(SV_GroupThreadID.x) & 7);
  _35 = (((uint)((uint)(_26.x)) >> 9) & 32760) + ((uint)(SV_GroupThreadID.x) >> 3);
  _39 = _34 + (uint)(View.ViewRectMinAndSize.x);
  _40 = _35 + (uint)(View.ViewRectMinAndSize.y);
  _57 = (((float((uint)_39) + 0.5f) * View.BufferSizeAndInvSize.z) - View.ScreenPositionScaleBias.w) / View.ScreenPositionScaleBias.x;
  _58 = (((float((uint)_40) + 0.5f) * View.BufferSizeAndInvSize.w) - View.ScreenPositionScaleBias.z) / View.ScreenPositionScaleBias.y;
  _60 = ResolvedReflections.Load(int4(_39, _40, 0, 0));

  // === Percentile-based firefly clamp ===
  // Sort luma across the 64-thread tile, clamp values above 95th percentile + IPR.
  // This removes fireflies at the input before they pollute temporal history.
  // Only runs when temporal mode is active so we keep backwards compat.
  if (InjectionToggle(TOGGLE_USE_SUPERIOR_REFLECTION_TEMPORAL)) {
    // Compute current-pixel luma (guard against sentinel values used in the shader)
    float _ff_luma = 0.0f;
    if ((_60.z != 64512.0f) && (_60.x != 65024.0f) && (_60.y != 65024.0f)) {
      _ff_luma = dot(float3(_60.x, _60.y, _60.z), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
    }
    s_firefly_luma[SV_GroupIndex] = _ff_luma;
    GroupMemoryBarrierWithGroupSync();

    // Odd-even sort: 32 passes of 64-element sort. Each pass does compare-exchange
    // on alternating even/odd pairs.
    [unroll]
    for (int _ff_pass = 0; _ff_pass < 32; _ff_pass++) {
      // Even phase
      if (SV_GroupIndex < 63u && (SV_GroupIndex & 1u) == 0u) {
        float _ff_a = s_firefly_luma[SV_GroupIndex];
        float _ff_b = s_firefly_luma[SV_GroupIndex + 1];
        if (_ff_a > _ff_b) {
          s_firefly_luma[SV_GroupIndex] = _ff_b;
          s_firefly_luma[SV_GroupIndex + 1] = _ff_a;
        }
      }
      GroupMemoryBarrierWithGroupSync();
      // Odd phase
      if (SV_GroupIndex < 63u && (SV_GroupIndex & 1u) == 1u) {
        float _ff_a = s_firefly_luma[SV_GroupIndex];
        float _ff_b = s_firefly_luma[SV_GroupIndex + 1];
        if (_ff_a > _ff_b) {
          s_firefly_luma[SV_GroupIndex] = _ff_b;
          s_firefly_luma[SV_GroupIndex + 1] = _ff_a;
        }
      }
      GroupMemoryBarrierWithGroupSync();
    }

    // 64 elements sorted ascending. 5th percentile ≈ index 3, 95th percentile ≈ index 60.
    float _ff_p5 = s_firefly_luma[3];
    float _ff_p95 = s_firefly_luma[60];
    float _ff_ipr = max(_ff_p95 - _ff_p5, 0.0f);
    // Clamp threshold: upper + IPR * 1.0 + small bias
    float _ff_max_luma = _ff_p95 + _ff_ipr + 0.05f;

    // If the current pixel luma exceeds the clamp threshold, scale colors uniformly
    // so the resulting luma equals the threshold (preserves hue).
    if (_ff_luma > _ff_max_luma && _ff_luma > 0.0f) {
      float _ff_scale = _ff_max_luma / _ff_luma;
      _60.x *= _ff_scale;
      _60.y *= _ff_scale;
      _60.z *= _ff_scale;
    }
  }
  _65 = ResolvedReflectionsDepth.Load(int4(_39, _40, 0, 0));
  _68 = SceneTexturesStruct_SceneDepthTexture.Load(int3(_39, _40, 0));
  _80 = ((View.InvDeviceZToWorldZTransform.x * _68.x) + View.InvDeviceZToWorldZTransform.y) + (1.0f / ((View.InvDeviceZToWorldZTransform.z * _68.x) - View.InvDeviceZToWorldZTransform.w));
  _82 = VelocityTexture.Load(int3(_39, _40, 0));
  _106 = mad(_58, (View.ClipToPrevClipWithAA[1].x), ((View.ClipToPrevClipWithAA[0].x) * _57));
  _110 = mad(_58, (View.ClipToPrevClipWithAA[1].y), ((View.ClipToPrevClipWithAA[0].y) * _57));
  _118 = mad(_58, (View.ClipToPrevClipWithAA[1].w), ((View.ClipToPrevClipWithAA[0].w) * _57));
  _120 = mad(_68.x, (View.ClipToPrevClipWithAA[2].w), _118) + (View.ClipToPrevClipWithAA[3].w);
  _121 = (mad(_68.x, (View.ClipToPrevClipWithAA[2].x), _106) + (View.ClipToPrevClipWithAA[3].x)) / _120;
  _122 = (mad(_68.x, (View.ClipToPrevClipWithAA[2].y), _110) + (View.ClipToPrevClipWithAA[3].y)) / _120;
  _127 = (_82.x > 0.0f);
  if (_127) {
    _154 = (((_82.x * 2.0040080547332764f) + -1.0019887685775757f) * abs((_82.x * 4.008016109466553f) + -2.0039775371551514f));
    _155 = (((_82.y * 2.0040080547332764f) + -1.0019887685775757f) * abs((_82.y * 4.008016109466553f) + -2.0039775371551514f));
    _156 = asfloat((((int)(uint(round(_82.w * 65535.0f))) & 65534) | ((int)((int)(uint(round(_82.z * 65535.0f))) << 16))));
  } else {
    _154 = (_57 - _121);
    _155 = (_58 - _122);
    _156 = (_68.x - ((mad(_68.x, (View.ClipToPrevClipWithAA[2].z), mad(_58, (View.ClipToPrevClipWithAA[1].z), ((View.ClipToPrevClipWithAA[0].z) * _57))) + (View.ClipToPrevClipWithAA[3].z)) / _120));
  }
  _159 = _68.x - _156;
  _165 = mad(_65.x, (View.ClipToPrevClipWithAA[2].w), _118) + (View.ClipToPrevClipWithAA[3].w);
  _166 = (mad(_65.x, (View.ClipToPrevClipWithAA[2].x), _106) + (View.ClipToPrevClipWithAA[3].x)) / _165;
  _167 = (mad(_65.x, (View.ClipToPrevClipWithAA[2].y), _110) + (View.ClipToPrevClipWithAA[3].y)) / _165;
  if (_127) {
    _188 = ((_121 - _166) + (((_82.x * 2.0040080547332764f) + -1.0019887685775757f) * abs((_82.x * 4.008016109466553f) + -2.0039775371551514f)));
    _189 = ((_122 - _167) + (((_82.y * 2.0040080547332764f) + -1.0019887685775757f) * abs((_82.y * 4.008016109466553f) + -2.0039775371551514f)));
  } else {
    _188 = (_57 - _166);
    _189 = (_58 - _167);
  }
  _204 = (HistoryScreenPositionScaleBias.x * (_57 - _154)) + HistoryScreenPositionScaleBias.w;
  _205 = (HistoryScreenPositionScaleBias.y * (_58 - _155)) + HistoryScreenPositionScaleBias.z;
  if ((_204 < HistoryUVMinMax.z) && (_205 < HistoryUVMinMax.w)) {
    _214 = ((_204 > HistoryUVMinMax.x) && (_205 > HistoryUVMinMax.y));
  } else {
    _214 = false;
  }
  _217 = min(max(_204, HistoryUVMinMax.x), HistoryUVMinMax.z);
  _218 = min(max(_205, HistoryUVMinMax.y), HistoryUVMinMax.w);
  _223 = (View.BufferSizeAndInvSize.x * _217) + -0.5f;
  _224 = (View.BufferSizeAndInvSize.y * _218) + -0.5f;
  _225 = floor(_223);
  _226 = floor(_224);
  _227 = frac(_223);
  _228 = frac(_224);
  _231 = (HistoryScreenPositionScaleBias.x * (_57 - _188)) + HistoryScreenPositionScaleBias.w;
  _232 = (HistoryScreenPositionScaleBias.y * (_58 - _189)) + HistoryScreenPositionScaleBias.z;
  _235 = (_231 * View.BufferSizeAndInvSize.x) + -0.5f;
  _236 = (_232 * View.BufferSizeAndInvSize.y) + -0.5f;
  _239 = frac(_235);
  _240 = frac(_236);
  _243 = View.BufferSizeAndInvSize.z * (_225 + 1.0f);
  _244 = View.BufferSizeAndInvSize.w * (_226 + 1.0f);
  _246 = SceneTexturesStruct_GBufferATexture.Load(int3(_39, _40, 0));
  _251 = SceneTexturesStruct_GBufferBTexture.Load(int3(_39, _40, 0));
  _259 = uint((_251.w * 255.0f) + 0.5f);
  _264 = (_246.x * 2.0f) + -1.0f;
  _265 = (_246.y * 2.0f) + -1.0f;
  _266 = (_246.z * 2.0f) + -1.0f;
  _267 = _259 & 14;
  _276 = rsqrt(dot(float3(_264, _265, _266), float3(_264, _265, _266)));
  _284 = float((uint)(uint)(ReflectionsStateFrameIndexMod8));
  _304 = ((View.InvDeviceZToWorldZTransform.x * _159) + View.InvDeviceZToWorldZTransform.y) + (1.0f / ((View.InvDeviceZToWorldZTransform.z * _159) - View.InvDeviceZToWorldZTransform.w));
  _307 = DepthHistory.GatherRed(D3DStaticPointClampedSampler, float2(_243, _244));
  _348 = ((View.ViewToClip[3].w) >= 1.0f);
  _349 = select(_348, _57, (_80 * _57));
  _350 = select(_348, _58, (_80 * _58));
  _363 = -0.0f - ((View.ScreenToTranslatedWorld[3].x) + mad(_80, (View.ScreenToTranslatedWorld[2].x), mad(_350, (View.ScreenToTranslatedWorld[1].x), (_349 * (View.ScreenToTranslatedWorld[0].x)))));
  _364 = -0.0f - ((View.ScreenToTranslatedWorld[3].y) + mad(_80, (View.ScreenToTranslatedWorld[2].y), mad(_350, (View.ScreenToTranslatedWorld[1].y), (_349 * (View.ScreenToTranslatedWorld[0].y)))));
  _365 = -0.0f - ((View.ScreenToTranslatedWorld[3].z) + mad(_80, (View.ScreenToTranslatedWorld[2].z), mad(_350, (View.ScreenToTranslatedWorld[1].z), (_349 * (View.ScreenToTranslatedWorld[0].z)))));
  _367 = rsqrt(dot(float3(_363, _364, _365), float3(_363, _364, _365)));
  _376 = View.InvDeviceZToWorldZTransform.y - _304;
  float _depth_dither;
  if (InjectionToggle(TOGGLE_USE_SUPERIOR_REFLECTION_TEMPORAL)) {
    _depth_dither = ISFASTNoiseLoad(uint(_34) % 128u, uint(_35) % 128u, uint(float(InjectionFrameIndex())) % 32u).x;
  } else {
    _depth_dither = frac(frac(dot(float2(((_284 * 32.665000915527344f) + float((uint)_34)), ((_284 * 11.8149995803833f) + float((uint)_35))), float2(0.0671105608344078f, 0.005837149918079376f))) * 52.98291778564453f);
  }
  _389 = ((HistoryDistanceThreshold * (_depth_dither + 0.5f)) / min(max(saturate(dot(float3((_367 * _363), (_367 * _364), (_367 * _365)), float3((_276 * _264), (_276 * _265), (_276 * _266)))), 0.10000000149011612f), 1.0f)) * _304;
  _398 = select(_214, 1.0f, 0.0f);
  _403 = saturate(_398 - select((abs((_376 + (View.InvDeviceZToWorldZTransform.x * _307.w)) + (1.0f / ((View.InvDeviceZToWorldZTransform.z * _307.w) - View.InvDeviceZToWorldZTransform.w))) >= _389), 1.0f, 0.0f));
  _404 = saturate(_398 - select((abs((_376 + (View.InvDeviceZToWorldZTransform.x * _307.z)) + (1.0f / ((View.InvDeviceZToWorldZTransform.z * _307.z) - View.InvDeviceZToWorldZTransform.w))) >= _389), 1.0f, 0.0f));
  _405 = saturate(_398 - select((abs((_376 + (View.InvDeviceZToWorldZTransform.x * _307.x)) + (1.0f / ((View.InvDeviceZToWorldZTransform.z * _307.x) - View.InvDeviceZToWorldZTransform.w))) >= _389), 1.0f, 0.0f));
  _406 = saturate(_398 - select((abs((_376 + (View.InvDeviceZToWorldZTransform.x * _307.y)) + (1.0f / ((View.InvDeviceZToWorldZTransform.z * _307.y) - View.InvDeviceZToWorldZTransform.w))) >= _389), 1.0f, 0.0f));
  _407 = 1.0f - _227;
  _408 = 1.0f - _228;
  _419 = View.BufferSizeAndInvSize.z * (_225 + 0.5f);
  _420 = View.BufferSizeAndInvSize.w * (_226 + 0.5f);
  _421 = _419 + View.BufferSizeAndInvSize.z;
  _422 = _420 + View.BufferSizeAndInvSize.w;
  _424 = SpecularIndirectHistory.SampleLevel(D3DStaticPointClampedSampler, float3(_419, _420, 0.0f), 0.0f);
  _429 = SpecularIndirectHistory.SampleLevel(D3DStaticPointClampedSampler, float3(_421, _420, 0.0f), 0.0f);
  _434 = SpecularIndirectHistory.SampleLevel(D3DStaticPointClampedSampler, float3(_419, _422, 0.0f), 0.0f);
  _439 = SpecularIndirectHistory.SampleLevel(D3DStaticPointClampedSampler, float3(_421, _422, 0.0f), 0.0f);
  _446 = ((_408 * _407) * _403) * select((_424.w > 0.0f), 1.0f, 0.0f);
  _449 = ((_408 * _227) * _404) * select((_429.w > 0.0f), 1.0f, 0.0f);
  _452 = ((_407 * _228) * _405) * select((_434.w > 0.0f), 1.0f, 0.0f);
  _455 = ((_228 * _227) * _406) * select((_439.w > 0.0f), 1.0f, 0.0f);
  _478 = max(dot(float4(_446, _449, _452, _455), float4(1.0f, 1.0f, 1.0f, 1.0f)), 9.999999747378752e-06f);
  _485 = View.PreExposure * PrevInvPreExposure;
  _486 = _485 * (((((_449 * _429.x) + (_446 * _424.x)) + (_452 * _434.x)) + (_455 * _439.x)) / _478);
  _487 = _485 * (((((_449 * _429.y) + (_446 * _424.y)) + (_452 * _434.y)) + (_455 * _439.y)) / _478);
  _488 = _485 * (((((_449 * _429.z) + (_446 * _424.z)) + (_452 * _434.z)) + (_455 * _439.z)) / _478);

  // === Catmull-Rom 5-tap history reprojection (Jimenez 2014) ===
  // Bilinear history resampling causes progressive blur across accumulation frames
  // because bilinear is a low-pass filter with cos^2 response. Catmull-Rom has
  // near-unity response at mid-frequencies, preserving detail across many frames.
  // The 5-tap form uses hardware bilinear with strategic offsets to approximate
  // a 16-tap separable Catmull-Rom at 1/3 the cost.
  // Rephrased from Jimenez 2014 (SIGGRAPH course) for licensing compliance.
  if (InjectionToggle(TOGGLE_USE_SUPERIOR_REFLECTION_TEMPORAL)) {
    // Reprojected sample position in buffer-pixel coords.
    // _223/_224 are pixel-offset by -0.5 (texel center convention); add 0.5 to
    // recover the actual sample position, then floor to get the 4x4 corner.
    float2 _cr_sample_pos = float2(_223, _224) + 0.5f;
    float2 _cr_texel_size = float2(View.BufferSizeAndInvSize.z, View.BufferSizeAndInvSize.w);
    float2 _cr_center = floor(_cr_sample_pos - 0.5f) + 0.5f;
    float2 _cr_f = _cr_sample_pos - _cr_center;
    float2 _cr_f2 = _cr_f * _cr_f;
    float2 _cr_f3 = _cr_f * _cr_f2;

    // Catmull-Rom weights for 4 neighboring samples in 1D.
    // (tension = 0.5, the standard spline)
    float2 _cr_w0 = -0.5f * _cr_f3 + _cr_f2 - 0.5f * _cr_f;
    float2 _cr_w1 = 1.5f * _cr_f3 - 2.5f * _cr_f2 + 1.0f;
    float2 _cr_w2 = -1.5f * _cr_f3 + 2.0f * _cr_f2 + 0.5f * _cr_f;
    float2 _cr_w3 = 0.5f * _cr_f3 - 0.5f * _cr_f2;

    // Fold adjacent pairs together so each fetch uses bilinear to sample
    // two source texels simultaneously.
    float2 _cr_w12 = _cr_w1 + _cr_w2;
    float2 _cr_offset12 = _cr_w2 / _cr_w12;

    // 5 sample positions in texture coordinates
    float2 _cr_tc0 = (_cr_center - 1.0f) * _cr_texel_size;
    float2 _cr_tc3 = (_cr_center + 2.0f) * _cr_texel_size;
    float2 _cr_tc12 = (_cr_center + _cr_offset12) * _cr_texel_size;

    // 5 bilinear fetches (Jimenez layout: corner-drop + separable cross)
    float4 _cr_s0 = SpecularIndirectHistory.SampleLevel(D3DStaticBilinearClampedSampler, float3(_cr_tc12.x, _cr_tc0.y, 0.0f), 0.0f);
    float4 _cr_s1 = SpecularIndirectHistory.SampleLevel(D3DStaticBilinearClampedSampler, float3(_cr_tc0.x, _cr_tc12.y, 0.0f), 0.0f);
    float4 _cr_s2 = SpecularIndirectHistory.SampleLevel(D3DStaticBilinearClampedSampler, float3(_cr_tc12.x, _cr_tc12.y, 0.0f), 0.0f);
    float4 _cr_s3 = SpecularIndirectHistory.SampleLevel(D3DStaticBilinearClampedSampler, float3(_cr_tc3.x, _cr_tc12.y, 0.0f), 0.0f);
    float4 _cr_s4 = SpecularIndirectHistory.SampleLevel(D3DStaticBilinearClampedSampler, float3(_cr_tc12.x, _cr_tc3.y, 0.0f), 0.0f);

    // Combine with Catmull-Rom row/col weights
    float _cr_wsum = _cr_w12.x * _cr_w0.y           // s0: top
                   + _cr_w0.x * _cr_w12.y           // s1: left
                   + _cr_w12.x * _cr_w12.y          // s2: center (dominant)
                   + _cr_w3.x * _cr_w12.y           // s3: right
                   + _cr_w12.x * _cr_w3.y;          // s4: bottom

    float3 _cr_color = _cr_s0.xyz * (_cr_w12.x * _cr_w0.y)
                     + _cr_s1.xyz * (_cr_w0.x * _cr_w12.y)
                     + _cr_s2.xyz * (_cr_w12.x * _cr_w12.y)
                     + _cr_s3.xyz * (_cr_w3.x * _cr_w12.y)
                     + _cr_s4.xyz * (_cr_w12.x * _cr_w3.y);

    _cr_color /= max(_cr_wsum, 1e-6f);
    // Clamp negative weights (Catmull-Rom has them) to prevent ringing below 0
    _cr_color = max(_cr_color, 0.0f);

    // Anti-ringing: clamp to min/max of the contributing samples.
    // Catmull-Rom's negative outer weights cause overshoot (positive ringing) on
    // sharp luminance edges, producing firefly-like artifacts on bright reflections.
    // Constraining the result to the bilinear-sample bounds eliminates this.
    float3 _cr_min = min(min(min(min(_cr_s0.xyz, _cr_s1.xyz), _cr_s2.xyz), _cr_s3.xyz), _cr_s4.xyz);
    float3 _cr_max = max(max(max(max(_cr_s0.xyz, _cr_s1.xyz), _cr_s2.xyz), _cr_s3.xyz), _cr_s4.xyz);
    _cr_color = clamp(_cr_color, _cr_min, _cr_max);

    // Apply the Catmull-Rom result
    _486 = _485 * _cr_color.x;
    _487 = _485 * _cr_color.y;
    _488 = _485 * _cr_color.z;
  }
  _489 = 1.0f - _239;
  _490 = 1.0f - _240;
  _497 = View.BufferSizeAndInvSize.z * (floor(_235) + 0.5f);
  _498 = View.BufferSizeAndInvSize.w * (floor(_236) + 0.5f);
  _499 = _497 + View.BufferSizeAndInvSize.z;
  _500 = _498 + View.BufferSizeAndInvSize.w;
  _501 = SpecularIndirectHistory.SampleLevel(D3DStaticPointClampedSampler, float3(_497, _498, 0.0f), 0.0f);
  _506 = SpecularIndirectHistory.SampleLevel(D3DStaticPointClampedSampler, float3(_499, _498, 0.0f), 0.0f);
  _511 = SpecularIndirectHistory.SampleLevel(D3DStaticPointClampedSampler, float3(_497, _500, 0.0f), 0.0f);
  _516 = SpecularIndirectHistory.SampleLevel(D3DStaticPointClampedSampler, float3(_499, _500, 0.0f), 0.0f);
  _523 = (_490 * _489) * select((_501.w > 0.0f), 1.0f, 0.0f);
  _526 = (_490 * _239) * select((_506.w > 0.0f), 1.0f, 0.0f);
  _529 = (_489 * _240) * select((_511.w > 0.0f), 1.0f, 0.0f);
  _532 = (_240 * _239) * select((_516.w > 0.0f), 1.0f, 0.0f);
  _555 = max(dot(float4(_523, _526, _529, _532), float4(1.0f, 1.0f, 1.0f, 1.0f)), 9.999999747378752e-06f);
  _559 = _485 * (((((_526 * _506.x) + (_523 * _501.x)) + (_529 * _511.x)) + (_532 * _516.x)) / _555);
  _560 = _485 * (((((_526 * _506.y) + (_523 * _501.y)) + (_529 * _511.y)) + (_532 * _516.y)) / _555);
  _561 = _485 * (((((_526 * _506.z) + (_523 * _501.z)) + (_529 * _511.z)) + (_532 * _516.z)) / _555);

  // === Catmull-Rom for the secondary (prev-view) reprojection ===
  // The temporal pass keeps two candidate reprojected history samples (_486/_559)
  // and chooses between them via _923. If we only Catmull-Rom the primary _486,
  // the secondary path still uses bilinear and the blur re-enters. Apply the
  // same 5-tap Catmull-Rom at _235/_236 (the prev-view UV).
  if (InjectionToggle(TOGGLE_USE_SUPERIOR_REFLECTION_TEMPORAL)) {
    float2 _cr2_sample_pos = float2(_235, _236) + 0.5f;
    float2 _cr2_texel_size = float2(View.BufferSizeAndInvSize.z, View.BufferSizeAndInvSize.w);
    float2 _cr2_center = floor(_cr2_sample_pos - 0.5f) + 0.5f;
    float2 _cr2_f = _cr2_sample_pos - _cr2_center;
    float2 _cr2_f2 = _cr2_f * _cr2_f;
    float2 _cr2_f3 = _cr2_f * _cr2_f2;
    float2 _cr2_w0 = -0.5f * _cr2_f3 + _cr2_f2 - 0.5f * _cr2_f;
    float2 _cr2_w1 = 1.5f * _cr2_f3 - 2.5f * _cr2_f2 + 1.0f;
    float2 _cr2_w2 = -1.5f * _cr2_f3 + 2.0f * _cr2_f2 + 0.5f * _cr2_f;
    float2 _cr2_w3 = 0.5f * _cr2_f3 - 0.5f * _cr2_f2;
    float2 _cr2_w12 = _cr2_w1 + _cr2_w2;
    float2 _cr2_offset12 = _cr2_w2 / _cr2_w12;
    float2 _cr2_tc0 = (_cr2_center - 1.0f) * _cr2_texel_size;
    float2 _cr2_tc3 = (_cr2_center + 2.0f) * _cr2_texel_size;
    float2 _cr2_tc12 = (_cr2_center + _cr2_offset12) * _cr2_texel_size;
    float4 _cr2_s0 = SpecularIndirectHistory.SampleLevel(D3DStaticBilinearClampedSampler, float3(_cr2_tc12.x, _cr2_tc0.y, 0.0f), 0.0f);
    float4 _cr2_s1 = SpecularIndirectHistory.SampleLevel(D3DStaticBilinearClampedSampler, float3(_cr2_tc0.x, _cr2_tc12.y, 0.0f), 0.0f);
    float4 _cr2_s2 = SpecularIndirectHistory.SampleLevel(D3DStaticBilinearClampedSampler, float3(_cr2_tc12.x, _cr2_tc12.y, 0.0f), 0.0f);
    float4 _cr2_s3 = SpecularIndirectHistory.SampleLevel(D3DStaticBilinearClampedSampler, float3(_cr2_tc3.x, _cr2_tc12.y, 0.0f), 0.0f);
    float4 _cr2_s4 = SpecularIndirectHistory.SampleLevel(D3DStaticBilinearClampedSampler, float3(_cr2_tc12.x, _cr2_tc3.y, 0.0f), 0.0f);
    float _cr2_wsum = _cr2_w12.x * _cr2_w0.y
                    + _cr2_w0.x * _cr2_w12.y
                    + _cr2_w12.x * _cr2_w12.y
                    + _cr2_w3.x * _cr2_w12.y
                    + _cr2_w12.x * _cr2_w3.y;
    float3 _cr2_color = _cr2_s0.xyz * (_cr2_w12.x * _cr2_w0.y)
                      + _cr2_s1.xyz * (_cr2_w0.x * _cr2_w12.y)
                      + _cr2_s2.xyz * (_cr2_w12.x * _cr2_w12.y)
                      + _cr2_s3.xyz * (_cr2_w3.x * _cr2_w12.y)
                      + _cr2_s4.xyz * (_cr2_w12.x * _cr2_w3.y);
    _cr2_color /= max(_cr2_wsum, 1e-6f);
    _cr2_color = max(_cr2_color, 0.0f);
    // Anti-ringing: clamp to sample bounds
    float3 _cr2_min = min(min(min(min(_cr2_s0.xyz, _cr2_s1.xyz), _cr2_s2.xyz), _cr2_s3.xyz), _cr2_s4.xyz);
    float3 _cr2_max = max(max(max(max(_cr2_s0.xyz, _cr2_s1.xyz), _cr2_s2.xyz), _cr2_s3.xyz), _cr2_s4.xyz);
    _cr2_color = clamp(_cr2_color, _cr2_min, _cr2_max);
    _559 = _485 * _cr2_color.x;
    _560 = _485 * _cr2_color.y;
    _561 = _485 * _cr2_color.z;
  }
  _565 = ((uint)(View.ViewRectMinAndSize.x) + (uint)(-1)) + (uint)(View.ViewRectMinAndSize.z);
  _567 = ((uint)(View.ViewRectMinAndSize.y) + (uint)(-1)) + (uint)(View.ViewRectMinAndSize.w);
  _572 = (int)min((uint)(((int)max((uint)(((int)(_39 + (uint)(-1)))), (uint)(View.ViewRectMinAndSize.x)))), (uint)(_565));
  _573 = (int)min((uint)(((int)max((uint)(((int)(_40 + (uint)(-1)))), (uint)(View.ViewRectMinAndSize.y)))), (uint)(_567));
  _574 = ResolvedReflections.Load(int4(_572, _573, 0, 0));
  if ((_574.z != 64512.0f) && ((_574.x != 65024.0f) && (_574.y != 65024.0f))) {
    _584 = _574.x - _60.x;
    _585 = _574.y - _60.y;
    _586 = _574.z - _60.z;
    _590 = (_584 * 0.5f) + _60.x;
    _591 = (_585 * 0.5f) + _60.y;
    _592 = (_586 * 0.5f) + _60.z;
    _600 = 2;
    _601 = _590;
    _602 = _591;
    _603 = _592;
    _604 = ((_574.x - _590) * _584);
    _605 = ((_574.y - _591) * _585);
    _606 = ((_574.z - _592) * _586);
  } else {
    _600 = 1;
    _601 = _60.x;
    _602 = _60.y;
    _603 = _60.z;
    _604 = 0.0f;
    _605 = 0.0f;
    _606 = 0.0f;
  }
  _609 = (int)min((uint)(((int)max((uint)(((int)(_39 + 1u))), (uint)(View.ViewRectMinAndSize.x)))), (uint)(_565));
  _610 = ResolvedReflections.Load(int4(_609, _573, 0, 0));
  if ((_610.z != 64512.0f) && ((_610.x != 65024.0f) && (_610.y != 65024.0f))) {
    _620 = _600 + 1;
    _621 = _610.x - _601;
    _622 = _610.y - _602;
    _623 = _610.z - _603;
    _624 = float((int)(_620));
    _628 = (_621 / _624) + _601;
    _629 = (_622 / _624) + _602;
    _630 = (_623 / _624) + _603;
    _641 = _620;
    _642 = _628;
    _643 = _629;
    _644 = _630;
    _645 = (((_610.x - _628) * _621) + _604);
    _646 = (((_610.y - _629) * _622) + _605);
    _647 = (((_610.z - _630) * _623) + _606);
  } else {
    _641 = _600;
    _642 = _601;
    _643 = _602;
    _644 = _603;
    _645 = _604;
    _646 = _605;
    _647 = _606;
  }
  _650 = (int)min((uint)(((int)max((uint)(((int)(_40 + 1u))), (uint)(View.ViewRectMinAndSize.y)))), (uint)(_567));
  _651 = ResolvedReflections.Load(int4(_572, _650, 0, 0));
  if ((_651.z != 64512.0f) && ((_651.x != 65024.0f) && (_651.y != 65024.0f))) {
    _661 = _641 + 1;
    _662 = _651.x - _642;
    _663 = _651.y - _643;
    _664 = _651.z - _644;
    _665 = float((int)(_661));
    _669 = (_662 / _665) + _642;
    _670 = (_663 / _665) + _643;
    _671 = (_664 / _665) + _644;
    _682 = _661;
    _683 = _669;
    _684 = _670;
    _685 = _671;
    _686 = (((_651.x - _669) * _662) + _645);
    _687 = (((_651.y - _670) * _663) + _646);
    _688 = (((_651.z - _671) * _664) + _647);
  } else {
    _682 = _641;
    _683 = _642;
    _684 = _643;
    _685 = _644;
    _686 = _645;
    _687 = _646;
    _688 = _647;
  }
  _689 = ResolvedReflections.Load(int4(_609, _650, 0, 0));
  if ((_689.z != 64512.0f) && ((_689.x != 65024.0f) && (_689.y != 65024.0f))) {
    _699 = _682 + 1;
    _700 = _689.x - _683;
    _701 = _689.y - _684;
    _702 = _689.z - _685;
    _703 = float((int)(_699));
    _707 = (_700 / _703) + _683;
    _708 = (_701 / _703) + _684;
    _709 = (_702 / _703) + _685;
    _720 = _699;
    _721 = _707;
    _722 = _708;
    _723 = _709;
    _724 = (((_689.x - _707) * _700) + _686);
    _725 = (((_689.y - _708) * _701) + _687);
    _726 = (((_689.z - _709) * _702) + _688);
  } else {
    _720 = _682;
    _721 = _683;
    _722 = _684;
    _723 = _685;
    _724 = _686;
    _725 = _687;
    _726 = _688;
  }
  _728 = (int)min((uint)(((int)max((uint)(_39), (uint)(View.ViewRectMinAndSize.x)))), (uint)(_565));
  _729 = ResolvedReflections.Load(int4(_728, _573, 0, 0));
  if ((_729.z != 64512.0f) && ((_729.x != 65024.0f) && (_729.y != 65024.0f))) {
    _739 = _720 + 1;
    _740 = _729.x - _721;
    _741 = _729.y - _722;
    _742 = _729.z - _723;
    _743 = float((int)(_739));
    _747 = (_740 / _743) + _721;
    _748 = (_741 / _743) + _722;
    _749 = (_742 / _743) + _723;
    _760 = _739;
    _761 = _747;
    _762 = _748;
    _763 = _749;
    _764 = (((_729.x - _747) * _740) + _724);
    _765 = (((_729.y - _748) * _741) + _725);
    _766 = (((_729.z - _749) * _742) + _726);
  } else {
    _760 = _720;
    _761 = _721;
    _762 = _722;
    _763 = _723;
    _764 = _724;
    _765 = _725;
    _766 = _726;
  }
  _768 = (int)min((uint)(((int)max((uint)(_40), (uint)(View.ViewRectMinAndSize.y)))), (uint)(_567));
  _769 = ResolvedReflections.Load(int4(_572, _768, 0, 0));
  if ((_769.z != 64512.0f) && ((_769.x != 65024.0f) && (_769.y != 65024.0f))) {
    _779 = _760 + 1;
    _780 = _769.x - _761;
    _781 = _769.y - _762;
    _782 = _769.z - _763;
    _783 = float((int)(_779));
    _787 = (_780 / _783) + _761;
    _788 = (_781 / _783) + _762;
    _789 = (_782 / _783) + _763;
    _800 = _779;
    _801 = _787;
    _802 = _788;
    _803 = _789;
    _804 = (((_769.x - _787) * _780) + _764);
    _805 = (((_769.y - _788) * _781) + _765);
    _806 = (((_769.z - _789) * _782) + _766);
  } else {
    _800 = _760;
    _801 = _761;
    _802 = _762;
    _803 = _763;
    _804 = _764;
    _805 = _765;
    _806 = _766;
  }
  _807 = ResolvedReflections.Load(int4(_609, _768, 0, 0));
  if ((_807.z != 64512.0f) && ((_807.x != 65024.0f) && (_807.y != 65024.0f))) {
    _817 = _800 + 1;
    _818 = _807.x - _801;
    _819 = _807.y - _802;
    _820 = _807.z - _803;
    _821 = float((int)(_817));
    _825 = (_818 / _821) + _801;
    _826 = (_819 / _821) + _802;
    _827 = (_820 / _821) + _803;
    _838 = _817;
    _839 = _825;
    _840 = _826;
    _841 = _827;
    _842 = (((_807.x - _825) * _818) + _804);
    _843 = (((_807.y - _826) * _819) + _805);
    _844 = (((_807.z - _827) * _820) + _806);
  } else {
    _838 = _800;
    _839 = _801;
    _840 = _802;
    _841 = _803;
    _842 = _804;
    _843 = _805;
    _844 = _806;
  }
  _845 = ResolvedReflections.Load(int4(_728, _650, 0, 0));
  if ((_845.z != 64512.0f) && ((_845.x != 65024.0f) && (_845.y != 65024.0f))) {
    _855 = _838 + 1;
    _856 = _845.x - _839;
    _857 = _845.y - _840;
    _858 = _845.z - _841;
    _859 = float((int)(_855));
    _863 = (_856 / _859) + _839;
    _864 = (_857 / _859) + _840;
    _865 = (_858 / _859) + _841;
    _876 = _855;
    _877 = _863;
    _878 = _864;
    _879 = _865;
    _880 = (((_845.x - _863) * _856) + _842);
    _881 = (((_845.y - _864) * _857) + _843);
    _882 = (((_845.z - _865) * _858) + _844);
  } else {
    _876 = _838;
    _877 = _839;
    _878 = _840;
    _879 = _841;
    _880 = _842;
    _881 = _843;
    _882 = _844;
  }
  _884 = float((int)(_876 + -1));
  _893 = (_231 > HistoryUVMinMax.z) || (_232 > HistoryUVMinMax.w);
  if (!_893) {
    _899 = ((!(_232 < HistoryUVMinMax.y)) && (!(_231 < HistoryUVMinMax.x)));
  } else {
    _899 = false;
  }
  if (_899) {
    _906 = abs(dot(float3(_559, _560, _561), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f)) - dot(float3(_877, _878, _879), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f)));
  } else {
    _906 = 1e+06f;
  }
  if (!((_217 > HistoryUVMinMax.z) || (_218 > HistoryUVMinMax.w))) {
    _915 = ((!(_218 < HistoryUVMinMax.y)) && (!(_217 < HistoryUVMinMax.x)));
  } else {
    _915 = false;
  }
  if (_915) {
    _922 = abs(dot(float3(_486, _487, _488), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f)) - dot(float3(_877, _878, _879), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f)));
  } else {
    _922 = 1e+06f;
  }
  // Hysteresis on the primary-vs-secondary reprojection pick.
  // UE5 uses `_906 < _922` which flips frame-to-frame on noisy edges because
  // both distances jitter around similar values → candidate UV swaps → shimmer.
  // Require secondary to be at least 2x closer to commit to it, giving stable
  // frame-to-frame selection on steady-state pixels.
  if (InjectionToggle(TOGGLE_USE_SUPERIOR_REFLECTION_TEMPORAL)) {
    _923 = (_906 * 2.0f) < _922;
  } else {
    _923 = (_906 < _922);
  }
  if (!_893) {
    _933 = select(((!(_232 < HistoryUVMinMax.y)) && (!(_231 < HistoryUVMinMax.x))), 0.8999999761581421f, 0.0f);
  } else {
    _933 = 0.0f;
  }
  _938 = (dot(float4(_403, _404, _405, _406), float4(1.0f, 1.0f, 1.0f, 1.0f)) < 1.0f);
  _939 = select(_938, 0.0f, _933);
  _940 = select(_938, 1.0f, ((ResolveVariance.Load(int4(_39, _40, 0, 0))).x));
  if (_939 > 0.0f) {
    _948 = (((float4)(ResolveVarianceHistory.SampleLevel(D3DStaticBilinearClampedSampler, float3(_231, _232, 0.0f), 0.0f))).x);
  } else {
    _948 = 0.0f;
  }
  _952 = max((lerp(_940, _948, _939)), 0.0f);
  RWResolveVariance[int3(_39, _40, 0)] = _952;
  float2 _temporal_jitter;
  if (InjectionToggle(TOGGLE_USE_SUPERIOR_REFLECTION_TEMPORAL)) {
    _temporal_jitter = ISFASTNoiseLoad((uint(_34) + 7u) % 128u, (uint(_35) + 13u) % 128u, uint(float(InjectionFrameIndex())) % 32u);
  } else {
    _temporal_jitter = float2(0.5f, 0.5f);  // neutral (no jitter)
  }
  // Stochastic clamp expansion: narrowed from [0.7, 1.3] to [0.95, 1.05] because
  // the wider range produced a visible moving pattern on camera-panning reflections
  // (TAA could not resolve the scrambled clamp widths on translating content).
  float _clamp_scale = 0.95f + 0.1f * _temporal_jitter.y;
  _957 = NeighborhoodClampExpandWithResolveVariance * sqrt(_952) * _clamp_scale;
  _958 = max(sqrt(_880 / _884), _957);
  _959 = max(sqrt(_881 / _884), _957);
  _960 = max(sqrt(_882 / _884), _957);
  _970 = min(max(select(_923, _559, _486), (_877 - _958)), (_958 + _877));
  _971 = min(max(select(_923, _560, _487), (_878 - _959)), (_959 + _878));
  _972 = min(max(select(_923, _561, _488), (_879 - _960)), (_960 + _879));
  _975 = HistoryNumFramesAccumulated.GatherRed(D3DStaticPointClampedSampler, float3(_243, _244, 0.0f));
  if (ReflectionDownsampleFactor == 1) {
    _995 = (((MaxFramesAccumulated + -2.0f) * saturate(select(((_259 & 15) == 4), select(((_267 == 8) || (((_259 & 12) == 4) || (_267 == 2))), (((float4)(SceneTexturesStruct_GBufferDTexture.Load(int3(_39, _40, 0)))).y), 0.0f), _251.z) * 20.0f)) + 2.0f);
  } else {
    _995 = MaxFramesAccumulated;
  }
  _1006 = select(_214, (dot(float4(min(((MaxFramesAccumulated * _975.w) + 1.0f), _995), min(((MaxFramesAccumulated * _975.z) + 1.0f), _995), min(((MaxFramesAccumulated * _975.x) + 1.0f), _995), min(((MaxFramesAccumulated * _975.y) + 1.0f), _995)), float4(_446, _449, _452, _455)) / _478), 0.0f);
  // Stochastic blend weight: jitter effective frame count by ±20%. Converts spatial
  // boiling into temporal noise that TAA resolves cleanly. Channel R is decorrelated
  // from clamp scale (channel G) above.
  float _n_effective;
  if (InjectionToggle(TOGGLE_USE_SUPERIOR_REFLECTION_TEMPORAL)) {
    // Narrowed from [0.8, 1.2] to [0.95, 1.05] to avoid visible moving patterns
    // on camera motion; the pattern wasn't averaging out through TAA.
    _n_effective = _1006 * (0.95f + 0.1f * _temporal_jitter.x);
  } else {
    _n_effective = _1006;
  }
  _1008 = 1.0f / (_n_effective + 1.0f);
  _1015 = (_1008 * (_60.x - _970)) + _970;
  _1016 = (_1008 * (_60.y - _971)) + _971;
  _1017 = (_1008 * (_60.z - _972)) + _972;
  RWSpecularIndirectAccumulated[int3(_39, _40, 0)] = float4(select(((asint(_1015) & 2139095040) != 2139095040), _1015, 0.0f), select(((asint(_1016) & 2139095040) != 2139095040), _1016, 0.0f), select(((asint(_1017) & 2139095040) != 2139095040), _1017, 0.0f), select(((_60.z != 64512.0f) || ((_60.x != 65024.0f) || (_60.y != 65024.0f))), 1.0f, 0.0f));
  RWNumHistoryFramesAccumulated[int3(_39, _40, 0)] = (_1006 / MaxFramesAccumulated);
}