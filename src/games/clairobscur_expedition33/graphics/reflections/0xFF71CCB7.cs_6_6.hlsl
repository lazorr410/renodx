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

Texture2D<float4> SceneTexturesStruct_GBufferFTexture : register(t4);

Texture2DArray<float4> DownsampledDepth : register(t5);

Texture2DArray<float4> RayBuffer : register(t6);

Texture2DArray<float3> TraceRadiance : register(t7);

Texture2DArray<float> TraceHit : register(t8);

Buffer<uint> ReflectionResolveTileData : register(t9);

Texture2DArray<uint> ResolveTileUsed : register(t10);

RWTexture2DArray<float3> RWSpecularIndirect : register(u0);

RWTexture2DArray<float> RWSpecularIndirectDepth : register(u1);

RWTexture2DArray<float> RWResolveVariance : register(u2);

cbuffer _RootShaderParameters : register(b0) {
  uint NumSpatialReconstructionSamples : packoffset(c001.z);
  float SpatialReconstructionKernelRadius : packoffset(c001.w);
  float SpatialReconstructionRoughnessScale : packoffset(c002.x);
  float SpatialResolveTonemapStrength : packoffset(c002.y);
  uint ReflectionDownsampleFactor : packoffset(c004.x);
  uint2 ReflectionTracingViewSize : packoffset(c004.z);
  float ReflectionSmoothBias : packoffset(c005.w);
  uint ReflectionPass : packoffset(c006.x);
  uint ReflectionsStateFrameIndexMod8 : packoffset(c007.z);
  float MaxRoughnessToTrace : packoffset(c009.x);
  float MaxRoughnessToTraceForFoliage : packoffset(c009.y);
  float InvRoughnessFadeLength : packoffset(c009.z);
};

cbuffer View : register(b1) {
  FViewConstants View : packoffset(c000.x);
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
  int _28;
  int _29;
  int _30;
  int _31;
  uint _35;
  uint _36;
  float _37;
  float _38;
  float4 _47;
  float _59;
  float4 _61;
  float4 _63;
  float4 _68;
  uint _76;
  int _77;
  float _81;
  float _82;
  float _83;
  int _84;
  float _95;
  float _96;
  float _97;
  float _98;
  float _118;
  float _119;
  float _120;
  float _121;
  float _138;
  bool _160;
  int _168;
  float _265;
  float _266;
  float _267;
  float _268;
  float _269;
  float _270;
  float _294;
  float _295;
  float _336;
  float _337;
  float _338;
  float _339;
  float _340;
  float _442;
  float _443;
  float _444;
  float _445;
  float _451;
  float _452;
  float _453;
  float _454;
  float _455;
  float _456;
  float _457;
  int _458;
  float _605;
  float _606;
  float _607;
  float _684;
  float _721;
  float _722;
  float _723;
  float _724;
  float _725;
  float _726;
  float _727;
  float _732;
  float _733;
  float _734;
  float _735;
  float _736;
  float _737;
  float _755;
  float _756;
  float _757;
  float _758;
  float _761;
  float _762;
  float _763;
  float _764;
  float _765;
  float _784;
  int _803;
  int _804;
  float _107;
  float _108;
  float _109;
  float _113;
  bool _122;
  float _123;
  float _131;
  float _144;
  uint _173;
  uint _174;
  float _182;
  float _183;
  bool _204;
  float _205;
  float _206;
  float _210;
  float _214;
  float _218;
  float _223;
  float _224;
  float _225;
  float _227;
  float _228;
  float _229;
  float _230;
  float _231;
  float _232;
  float _233;
  bool _234;
  float _247;
  float _250;
  float _252;
  float _273;
  float _276;
  float _279;
  float _284;
  float _285;
  float _296;
  uint _303;
  uint _304;
  uint _306;
  uint _308;
  uint _310;
  uint _312;
  float _319;
  float3 _323;
  float _328;
  float _331;
  float _341;
  float _352;
  float _376;
  float _377;
  float _378;
  float _390;
  float _391;
  float _392;
  float _393;
  float _405;
  float _423;
  float _424;
  float _425;
  float _426;
  float _429;
  float _434;
  float _435;
  float _438;
  float _473;
  float _474;
  int _485;
  int _486;
  float4 _503;
  float _536;
  float _537;
  bool _558;
  float _559;
  float _560;
  float4 _571;
  float _580;
  float _586;
  float _589;
  float _592;
  float _598;
  float _608;
  float _609;
  float _610;
  float _612;
  float _613;
  float _614;
  float _615;
  float _618;
  float _621;
  float _624;
  float _625;
  float _626;
  float _631;
  float _632;
  float _633;
  float _635;
  float _636;
  float _638;
  float _639;
  float _640;
  float _647;
  float _648;
  float _664;
  float _686;
  float _687;
  float3 _689;
  float _695;
  float _698;
  float _705;
  float _706;
  float _707;
  float _708;
  float _710;
  float _712;
  float _716;
  uint _728;
  float _740;
  float _741;
  float _742;
  float _743;
  float _749;
  uint _790;
  int _791;
  bool _799;
  uint _807;
  uint _808;
  _22 = ReflectionResolveTileData.Load((int)(SV_GroupID.x));
  _28 = (int)(SV_GroupThreadID.x) & 7;
  _29 = (uint)(SV_GroupThreadID.x) >> 3;
  _30 = (((int)(_22.x << 3)) & 32760) | _28;
  _31 = (((uint)((uint)(_22.x)) >> 9) & 32760) + _29;
  _35 = _30 + (uint)(View.ViewRectMinAndSize.x);
  _36 = _31 + (uint)(View.ViewRectMinAndSize.y);
  _37 = float((uint)_35);
  _38 = float((uint)_36);
  _47 = SceneTexturesStruct_SceneDepthTexture.Load(int3(_35, _36, 0));
  _59 = ((View.InvDeviceZToWorldZTransform.x * _47.x) + View.InvDeviceZToWorldZTransform.y) + (1.0f / ((View.InvDeviceZToWorldZTransform.z * _47.x) - View.InvDeviceZToWorldZTransform.w));
  _61 = SceneTexturesStruct_GBufferFTexture.Load(int3(_35, _36, 0));
  _63 = SceneTexturesStruct_GBufferATexture.Load(int3(_35, _36, 0));
  _68 = SceneTexturesStruct_GBufferBTexture.Load(int3(_35, _36, 0));
  _76 = uint((_68.w * 255.0f) + 0.5f);
  _77 = _76 & 15;
  _81 = (_63.x * 2.0f) + -1.0f;
  _82 = (_63.y * 2.0f) + -1.0f;
  _83 = (_63.z * 2.0f) + -1.0f;
  _84 = _76 & 14;
  _95 = rsqrt(dot(float3(_81, _82, _83), float3(_81, _82, _83)));
  _96 = _95 * _81;
  _97 = _95 * _82;
  _98 = _95 * _83;
  if (!((_76 & 16) == 0)) {
    _107 = (_61.x * 2.0f) + -1.0f;
    _108 = (_61.y * 2.0f) + -1.0f;
    _109 = (_61.z * 2.0f) + -1.0f;
    _113 = rsqrt(dot(float3(_107, _108, _109), float3(_107, _108, _109)));
    _118 = ((_61.w * 2.0f) + -1.0f);
    _119 = (_113 * _107);
    _120 = (_113 * _108);
    _121 = (_113 * _109);
  } else {
    _118 = 0.0f;
    _119 = 0.0f;
    _120 = 0.0f;
    _121 = 0.0f;
  }
  _122 = (_77 == 4);
  _123 = select(_122, select(((_84 == 8) || (((_76 & 12) == 4) || (_84 == 2))), (((float4)(SceneTexturesStruct_GBufferDTexture.Load(int3(_35, _36, 0)))).y), 0.0f), _68.z);
  if (ReflectionSmoothBias > 0.0f) {
    _131 = saturate(_123 / ReflectionSmoothBias);
    _138 = (((_131 * _131) * _123) * (3.0f - (_131 * 2.0f)));
  } else {
    _138 = _123;
  }
  _144 = select(((ReflectionPass & -3) == 0), _138, 0.0f);
  if (ReflectionPass == 0) {
    if (!(_77 == 0)) {
      _160 = (_122 || (saturate(InvRoughnessFadeLength * (select(((_76 & 11) == 2), MaxRoughnessToTraceForFoliage, MaxRoughnessToTrace) - _144)) > 0.0f));
    } else {
      _160 = false;
    }
    _168 = ((int)(uint)(_160));
  } else {
    if (ReflectionPass == 1) {
      _168 = ((int)(uint)((int)(_77 == 10)));
    } else {
      _168 = 0;
    }
  }
  if (!(_168 == 0)) {
    _173 = _30 / (uint)(ReflectionDownsampleFactor);
    _174 = _31 / (uint)(ReflectionDownsampleFactor);
    _182 = (((_37 + 0.5f) * View.BufferSizeAndInvSize.z) - View.ScreenPositionScaleBias.w) / View.ScreenPositionScaleBias.x;
    _183 = (((_38 + 0.5f) * View.BufferSizeAndInvSize.w) - View.ScreenPositionScaleBias.z) / View.ScreenPositionScaleBias.y;
    _204 = ((View.ViewToClip[3].w) >= 1.0f);
    _205 = select(_204, _182, (_182 * _59));
    _206 = select(_204, _183, (_183 * _59));
    _210 = mad(_59, (View.ScreenToTranslatedWorld[2].x), mad(_206, (View.ScreenToTranslatedWorld[1].x), (_205 * (View.ScreenToTranslatedWorld[0].x)))) + (View.ScreenToTranslatedWorld[3].x);
    _214 = mad(_59, (View.ScreenToTranslatedWorld[2].y), mad(_206, (View.ScreenToTranslatedWorld[1].y), (_205 * (View.ScreenToTranslatedWorld[0].y)))) + (View.ScreenToTranslatedWorld[3].y);
    _218 = mad(_59, (View.ScreenToTranslatedWorld[2].z), mad(_206, (View.ScreenToTranslatedWorld[1].z), (_205 * (View.ScreenToTranslatedWorld[0].z)))) + (View.ScreenToTranslatedWorld[3].z);
    _223 = _210 - View.TranslatedWorldCameraOrigin.x;
    _224 = _214 - View.TranslatedWorldCameraOrigin.y;
    _225 = _218 - View.TranslatedWorldCameraOrigin.z;
    _227 = rsqrt(dot(float3(_223, _224, _225), float3(_223, _224, _225)));
    _228 = _223 * _227;
    _229 = _224 * _227;
    _230 = _225 * _227;
    _231 = -0.0f - _228;
    _232 = -0.0f - _229;
    _233 = -0.0f - _230;
    _234 = (_118 != 0.0f);
    if (_234) {
      _265 = _119;
      _266 = _120;
      _267 = _121;
      _268 = ((_121 * _97) - (_120 * _98));
      _269 = ((_119 * _98) - (_121 * _96));
      _270 = ((_120 * _96) - (_119 * _97));
    } else {
      _247 = select((_98 >= 0.0f), 1.0f, -1.0f);
      _250 = -0.0f - (1.0f / (_247 + _98));
      _252 = (_96 * _97) * _250;
      _265 = ((((_96 * _96) * _247) * _250) + 1.0f);
      _266 = (_252 * _247);
      _267 = (-0.0f - (_96 * _247));
      _268 = _252;
      _269 = (((_97 * _97) * _250) + _247);
      _270 = (-0.0f - _97);
    }
    _273 = mad(_267, _233, mad(_266, _232, (_265 * _231)));
    _276 = mad(_270, _233, mad(_269, _232, (_268 * _231)));
    _279 = mad(_98, _233, mad(_97, _232, (_96 * _231)));
    _284 = min(max((SpatialReconstructionRoughnessScale * _144), 0.0f), 1.0f);
    _285 = _284 * _284;
    if (_234) {
      _294 = max((_285 * (_118 + 1.0f)), 0.0010000000474974513f);
      _295 = max((_285 * (1.0f - _118)), 0.0010000000474974513f);
    } else {
      _294 = _285;
      _295 = _285;
    }
    _296 = _295 * _294;
    if (InjectionToggle(TOGGLE_USE_ISFAST_REFLECTIONS)) {
      float2 _isfast_resolve = ISFASTNoiseLoad(uint(_30) % 128u, uint(_31) % 128u, uint(float(InjectionFrameIndex())) % 32u);
      _312 = uint(_isfast_resolve.x * 65535.0f) | (uint(_isfast_resolve.y * 65535.0f) << 16u);
      _310 = _312 ^ 0xA5A5A5A5u;
      _308 = _312 ^ 0x5A5A5A5Au;
    } else {
      _303 = (_31 * 1664525) + 1013904223u;
      _304 = (ReflectionsStateFrameIndexMod8 * 1664525) + 1013904223u;
      _306 = ((_30 * 1664525) + 1013904223u) + (_304 * _303);
      _308 = (_306 * _304) + _303;
      _310 = (_308 * _306) + _304;
      _312 = (_310 * _308) + _306;
    }
    _319 = abs((TraceHit.Load(int4(_173, _174, 0, 0))).x);
    if (ReflectionDownsampleFactor == 1) {
      _323 = TraceRadiance.Load(int4(_173, _174, 0, 0));
      _328 = dot(float3(_323.x, _323.y, _323.z), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
      _331 = 1.0f / ((SpatialResolveTonemapStrength * _328) + 1.0f);
      _336 = (_331 * _323.x);
      _337 = (_331 * _323.y);
      _338 = (_331 * _323.z);
      _339 = 1.0f;
      _340 = _328;
    } else {
      _336 = 0.0f;
      _337 = 0.0f;
      _338 = 0.0f;
      _339 = 0.0f;
      _340 = 0.0f;
    }
    _341 = float((uint)(uint)(ReflectionDownsampleFactor));
    _352 = ((saturate(_144 * 8.0f) * (SpatialReconstructionKernelRadius - _341)) + _341) * (2.0f - (log2(_341) * 0.5f));
    if (_234) {
      _376 = _265 + _210;
      _377 = _266 + _214;
      _378 = _267 + _218;
      _390 = mad(_378, (View.TranslatedWorldToClip[2].w), mad(_377, (View.TranslatedWorldToClip[1].w), ((View.TranslatedWorldToClip[0].w) * _376))) + (View.TranslatedWorldToClip[3].w);
      _391 = _268 + _210;
      _392 = _269 + _214;
      _393 = _270 + _218;
      _405 = mad(_393, (View.TranslatedWorldToClip[2].w), mad(_392, (View.TranslatedWorldToClip[1].w), ((View.TranslatedWorldToClip[0].w) * _391))) + (View.TranslatedWorldToClip[3].w);
      _423 = -0.5f - _37;
      _424 = _423 + (View.ViewSizeAndInvSize.x * ((((mad(_378, (View.TranslatedWorldToClip[2].x), mad(_377, (View.TranslatedWorldToClip[1].x), ((View.TranslatedWorldToClip[0].x) * _376))) + (View.TranslatedWorldToClip[3].x)) / _390) * 0.5f) + 0.5f));
      _425 = -0.5f - _38;
      _426 = _425 + (View.ViewSizeAndInvSize.y * (0.5f - (((mad(_378, (View.TranslatedWorldToClip[2].y), mad(_377, (View.TranslatedWorldToClip[1].y), ((View.TranslatedWorldToClip[0].y) * _376))) + (View.TranslatedWorldToClip[3].y)) / _390) * 0.5f)));
      _429 = rsqrt(dot(float2(_424, _426), float2(_424, _426))) * max((_352 * (_118 + 1.0f)), _341);
      _434 = _423 + (View.ViewSizeAndInvSize.x * ((((mad(_393, (View.TranslatedWorldToClip[2].x), mad(_392, (View.TranslatedWorldToClip[1].x), ((View.TranslatedWorldToClip[0].x) * _391))) + (View.TranslatedWorldToClip[3].x)) / _405) * 0.5f) + 0.5f));
      _435 = _425 + (View.ViewSizeAndInvSize.y * (0.5f - (((mad(_393, (View.TranslatedWorldToClip[2].y), mad(_392, (View.TranslatedWorldToClip[1].y), ((View.TranslatedWorldToClip[0].y) * _391))) + (View.TranslatedWorldToClip[3].y)) / _405) * 0.5f)));
      _438 = rsqrt(dot(float2(_434, _435), float2(_434, _435))) * max((_352 * (1.0f - _118)), _341);
      _442 = (_429 * _424);
      _443 = (_429 * _426);
      _444 = (_438 * _434);
      _445 = (_438 * _435);
    } else {
      _442 = _352;
      _443 = 0.0f;
      _444 = 0.0f;
      _445 = _352;
    }
    if (!(NumSpatialReconstructionSamples == 0)) {
      _451 = _336;
      _452 = _337;
      _453 = _338;
      _454 = _319;
      _455 = _339;
      _456 = _340;
      _457 = 0.0f;
      _458 = 0;
      while(true) {
        _721 = _451;
        _722 = _452;
        _723 = _453;
        _724 = _454;
        _725 = _455;
        _726 = _456;
        _727 = _457;
        _473 = frac((float((uint)_458) / float((uint)(uint)(NumSpatialReconstructionSamples))) + (float((uint)((uint)((uint)(_312) >> 16))) * 1.52587890625e-05f)) + -0.5f;
        _474 = (float((uint)((uint)((uint)((uint)(reversebits(_458) ^ ((int)((_312 * _310) + _308)))) >> 16))) * 1.52587890625e-05f) + -0.5f;
        _485 = int(((_473 * _442) + float((uint)_173)) + (_474 * _444));
        _486 = int(((_473 * _443) + float((uint)_174)) + (_474 * _445));
        if ((((int)_485 > (int)-1) && ((int)_485 < (int)ReflectionTracingViewSize.x)) && (((int)_486 > (int)-1) && ((int)_486 < (int)ReflectionTracingViewSize.y))) {
          _503 = DownsampledDepth.Load(int4(_485, _486, 0, 0));
          if (_503.x > 0.0f) {
            _536 = ((min(((View.ViewRectMin.x + 0.5f) + float((uint)(ReflectionDownsampleFactor * _485))), ((View.ViewRectMin.x + -1.0f) + View.ViewSizeAndInvSize.x)) * View.BufferSizeAndInvSize.z) - View.ScreenPositionScaleBias.w) / View.ScreenPositionScaleBias.x;
            _537 = ((min(((View.ViewRectMin.y + 0.5f) + float((uint)(ReflectionDownsampleFactor * _486))), ((View.ViewRectMin.y + -1.0f) + View.ViewSizeAndInvSize.y)) * View.BufferSizeAndInvSize.w) - View.ScreenPositionScaleBias.z) / View.ScreenPositionScaleBias.y;
            _558 = ((View.ViewToClip[3].w) >= 1.0f);
            _559 = select(_558, _536, (_536 * _503.x));
            _560 = select(_558, _537, (_537 * _503.x));
            _571 = RayBuffer.Load(int4(_485, _486, 0, 0));
            _580 = min(abs((TraceHit.Load(int4(_485, _486, 0, 0))).x), _319);
            _586 = (((View.ScreenToTranslatedWorld[3].x) - _210) + mad(_503.x, (View.ScreenToTranslatedWorld[2].x), mad(_560, (View.ScreenToTranslatedWorld[1].x), (_559 * (View.ScreenToTranslatedWorld[0].x))))) + (_580 * _571.x);
            _589 = (((View.ScreenToTranslatedWorld[3].y) - _214) + mad(_503.x, (View.ScreenToTranslatedWorld[2].y), mad(_560, (View.ScreenToTranslatedWorld[1].y), (_559 * (View.ScreenToTranslatedWorld[0].y))))) + (_580 * _571.y);
            _592 = (((View.ScreenToTranslatedWorld[3].z) - _218) + mad(_503.x, (View.ScreenToTranslatedWorld[2].z), mad(_560, (View.ScreenToTranslatedWorld[1].z), (_559 * (View.ScreenToTranslatedWorld[0].z))))) + (_580 * _571.z);
            _598 = sqrt(((_586 * _586) + (_589 * _589)) + (_592 * _592));
            if (_598 > 0.0f) {
              _605 = (_586 / _598);
              _606 = (_589 / _598);
              _607 = (_592 / _598);
            } else {
              _605 = _571.x;
              _606 = _571.y;
              _607 = _571.z;
            }
            _608 = _605 - _228;
            _609 = _606 - _229;
            _610 = _607 - _230;
            _612 = rsqrt(dot(float3(_608, _609, _610), float3(_608, _609, _610)));
            _613 = _612 * _608;
            _614 = _612 * _609;
            _615 = _612 * _610;
            _618 = mad(_267, _615, mad(_266, _614, (_613 * _265)));
            _621 = mad(_270, _615, mad(_269, _614, (_613 * _268)));
            _624 = mad(_98, _615, mad(_97, _614, (_613 * _96)));
            _625 = dot(float3(_273, _276, _279), float3(_618, _621, _624));
            _626 = _624 * _296;
            _631 = sqrt((_276 * _276) + (_273 * _273)) + 1.0f;
            _632 = _631 * _631;
            _633 = _279 * _279;
            if (_234) {
              _635 = _618 * _295;
              _636 = _621 * _294;
              _638 = _296 / dot(float3(_635, _636, _626), float3(_635, _636, _626));
              _639 = _294 * _273;
              _640 = _295 * _276;
              _647 = saturate(min(_294, _295));
              _648 = _647 * _647;
              _684 = (((_638 * _638) * ((_296 * 0.6366197466850281f) * _625)) / ((((_632 - (_632 * _648)) / (_632 + (_633 * _648))) * _279) + sqrt(((_639 * _639) + _633) + (_640 * _640))));
            } else {
              _664 = ((_626 - _624) * _624) + 1.0f;
              _684 = (((_625 * 2.0f) * (_296 / ((_664 * _664) * 3.1415927410125732f))) / ((((_632 - (_632 * _296)) / (_632 + (_633 * _296))) * _279) + sqrt(((_279 - (_296 * _279)) * _279) + _296)));
            }
            _686 = min(_684, 1e+05f) * _571.w;
            _687 = max(9.999999974752427e-07f, _686);
            _689 = TraceRadiance.Load(int4(_485, _486, 0, 0));
            _695 = dot(float3(_689.x, _689.y, _689.z), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
            _698 = 1.0f / ((SpatialResolveTonemapStrength * _695) + 1.0f);
            _705 = ((_689.x * _687) * _698) + _451;
            _706 = ((_689.y * _687) * _698) + _452;
            _707 = ((_689.z * _687) * _698) + _453;
            _708 = _687 + _455;
            _710 = _695 - _456;
            _712 = ((_687 / _708) * _710) + _456;
            _716 = ((_710 * _687) * (_695 - _712)) + _457;
            if (_686 > 0.0010000000474974513f) {
              _721 = _705;
              _722 = _706;
              _723 = _707;
              _724 = min(_454, _580);
              _725 = _708;
              _726 = _712;
              _727 = _716;
            } else {
              _721 = _705;
              _722 = _706;
              _723 = _707;
              _724 = _454;
              _725 = _708;
              _726 = _712;
              _727 = _716;
            }
          } else {
            _721 = _451;
            _722 = _452;
            _723 = _453;
            _724 = _454;
            _725 = _455;
            _726 = _456;
            _727 = _457;
          }
        } else {
          _721 = _451;
          _722 = _452;
          _723 = _453;
          _724 = _454;
          _725 = _455;
          _726 = _456;
          _727 = _457;
        }
        _728 = _458 + 1u;
        if ((uint)_728 < (uint)NumSpatialReconstructionSamples) {
          _451 = _721;
          _452 = _722;
          _453 = _723;
          _454 = _724;
          _455 = _725;
          _456 = _726;
          _457 = _727;
          _458 = _728;
          continue;
        }
        _732 = _721;
        _733 = _722;
        _734 = _723;
        _735 = _724;
        _736 = _725;
        _737 = _727;
        break;
      }
    } else {
      _732 = _336;
      _733 = _337;
      _734 = _338;
      _735 = _319;
      _736 = _339;
      _737 = 0.0f;
    }
    if (_736 > 0.0f) {
      _740 = 1.0f / _736;
      _741 = _740 * _732;
      _742 = _740 * _733;
      _743 = _740 * _734;
      _749 = 1.0f / (1.0f - (SpatialResolveTonemapStrength * dot(float3(_741, _742, _743), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f))));
      _755 = (_749 * _741);
      _756 = (_749 * _742);
      _757 = (_749 * _743);
      _758 = (_737 / _736);
    } else {
      _755 = _732;
      _756 = _733;
      _757 = _734;
      _758 = 0.0f;
    }
    _761 = _755;
    _762 = _756;
    _763 = _757;
    _764 = _758;
    _765 = (_735 + _59);
  } else {
    _761 = 65024.0f;
    _762 = 65024.0f;
    _763 = 64512.0f;
    _764 = 0.0f;
    _765 = _59;
  }
  // Debug visualization for temporal resolve
  if ((InjectionEnum(ENUM_DEBUG_REFLECTIONS_SHIFT) > 0u)) {
    if (InjectionToggle(TOGGLE_USE_ISFAST_REFLECTIONS)) {
      float2 _dbg_res = ISFASTNoiseLoad(uint(_30) % 128u, uint(_31) % 128u, uint(float(InjectionFrameIndex())) % 32u);
      if (_dbg_res.x == 0.0f && _dbg_res.y == 0.0f) {
        RWSpecularIndirect[int3(_35, _36, 0)] = float3(1.0f, 0.0f, 0.0f);  // Red = binding fail
      } else {
        RWSpecularIndirect[int3(_35, _36, 0)] = float3(0.0f, _dbg_res.x, 0.0f);  // Green = IS-FAST active
      }
    } else {
      RWSpecularIndirect[int3(_35, _36, 0)] = float3(0.8f, 0.8f, 0.0f);  // Yellow = original path
    }
  } else {
    RWSpecularIndirect[int3(_35, _36, 0)] = float3(_761, _762, _763);
  }
  [branch]
  if ((View.ViewToClip[3].w) < 1.0f) {
    _784 = (1.0f / ((View.InvDeviceZToWorldZTransform.w + _765) * View.InvDeviceZToWorldZTransform.z));
  } else {
    _784 = (((View.ViewToClip[2].z) * _765) + (View.ViewToClip[3].z));
  }
  RWSpecularIndirectDepth[int3(_35, _36, 0)] = _784;
  RWResolveVariance[int3(_35, _36, 0)] = min(_764, 0.8999999761581421f);
  if ((uint)(int)(SV_GroupThreadID.x) < (uint)36) {
    _790 = (int)(SV_GroupThreadID.x) % 9;
    _791 = _790 + -1;
    if (!((uint)((int)(SV_GroupThreadID.x + (uint)(-9))) < (uint)9)) {
      if (!((uint)((int)(SV_GroupThreadID.x + (uint)(-18))) < (uint)9)) {
        _799 = ((uint)((int)(SV_GroupThreadID.x + (uint)(-27))) < (uint)9);
        _803 = select(_799, -1, _791);
        _804 = select(_799, _790, -1);
      } else {
        _803 = _790;
        _804 = 8;
      }
    } else {
      _803 = 8;
      _804 = _791;
    }
    _807 = _803 + (_35 - _28);
    _808 = _804 + (_36 - _29);
    if ((int)(_808 | _807) > (int)-1) {
      if (((uint)_807 < (uint)((int)((uint)(View.ViewRectMinAndSize.z) + (uint)(View.ViewRectMinAndSize.x)))) && ((uint)_808 < (uint)((int)((uint)(View.ViewRectMinAndSize.w) + (uint)(View.ViewRectMinAndSize.y))))) {
        if ((((uint)(ResolveTileUsed.Load(int4(((uint)(_807 - (uint)(View.ViewRectMinAndSize.x)) >> 3), ((uint)(_808 - (uint)(View.ViewRectMinAndSize.y)) >> 3), 0, 0)))).x) == 0) {
          RWSpecularIndirect[int3(_807, _808, 0)] = float3(65024.0f, 65024.0f, 64512.0f);
          RWSpecularIndirectDepth[int3(_807, _808, 0)] = 0.0f;
        }
      }
    }
  }
}