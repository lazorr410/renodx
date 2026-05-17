#include "../shared.h"

// IS-FAST noise texture for reflection bilateral filter (injected via ViewBinding)

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

// IS-FAST noise buffer (ByteAddressBuffer root SRV — avoids ReShade heap-swap corruption)
ByteAddressBuffer ISFASTNoise : register(t0, space50);
static const uint ISFAST_W = 128u;
static const uint ISFAST_H = 128u;
static const uint ISFAST_SLICE_TEXELS = ISFAST_W * ISFAST_H;
static const uint ISFAST_ELEMENT_BYTES = 8u;
static float2 ISFASTNoiseLoad(uint x, uint y, uint slice) {
  return asfloat(ISFASTNoise.Load2((slice * ISFAST_SLICE_TEXELS + y * ISFAST_W + x) * ISFAST_ELEMENT_BYTES));
}

Texture2D<float4> SceneTexturesStruct_GBufferATexture : register(t1);

Texture2D<float4> SceneTexturesStruct_GBufferBTexture : register(t2);

Texture2D<float4> SceneTexturesStruct_GBufferDTexture : register(t3);

Buffer<uint> ReflectionResolveTileData : register(t4);

Texture2DArray<float> ResolveVariance : register(t5);

Texture2DArray<float3> SpecularIndirect : register(t6);

RWTexture2DArray<float3> RWSpecularIndirect : register(u0);

cbuffer _RootShaderParameters : register(b0) {
  float BilateralFilterSpatialKernelRadius : packoffset(c001.z);
  uint BilateralFilterNumSamples : packoffset(c001.w);
  float BilateralFilterDepthWeightScale : packoffset(c002.x);
  float BilateralFilterNormalAngleThresholdScale : packoffset(c002.y);
  float BilateralFilterStrongBlurVarianceThreshold : packoffset(c002.z);
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

SamplerState SceneTexturesStruct_PointClampSampler : register(s0);

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
  uint _17;
  uint _29;
  uint _31;
  float _32;
  float _33;
  float _39;
  float _40;
  float4 _43;
  float _55;
  float4 _57;
  float4 _62;
  uint _70;
  int _71;
  float _75;
  float _76;
  float _77;
  int _78;
  float _87;
  float _88;
  float _89;
  float _90;
  bool _91;
  float _92;
  float _107;
  bool _129;
  int _137;
  float _260;
  float _261;
  float _262;
  float _263;
  int _264;
  float _375;
  bool _448;
  int _456;
  float _508;
  float _509;
  float _510;
  float _511;
  float _516;
  float _517;
  float _518;
  float _519;
  float _524;
  float _525;
  float _526;
  float _533;
  float _534;
  float _535;
  float _100;
  float _113;
  float3 _141;
  float _146;
  float _147;
  float _148;
  float _149;
  float _151;
  float _163;
  float _167;
  uint _186;
  uint _187;
  uint _189;
  uint _191;
  uint _193;
  uint _195;
  float _206;
  float _207;
  bool _235;
  float _236;
  float _237;
  uint _256;
  float _280;
  float _281;
  int _284;
  int _285;
  float4 _311;
  float _323;
  float4 _325;
  float4 _330;
  uint _338;
  int _339;
  float _343;
  float _344;
  float _345;
  int _346;
  float _355;
  bool _359;
  float _360;
  float _368;
  float _389;
  float _390;
  bool _418;
  float _419;
  float _420;
  float _461;
  float _473;
  float _474;
  float _479;
  float _484;
  float _489;
  float3 _491;
  float _496;
  uint _512;
  float _528;
  _17 = ReflectionResolveTileData.Load((int)(SV_GroupID.x));
  _29 = ((uint)((((int)(_17.x << 3)) & 32760) | ((int)(SV_GroupThreadID.x) & 7))) + (uint)(View.ViewRectMinAndSize.x);
  _31 = ((uint)(View.ViewRectMinAndSize.y) + ((uint)((uint)(SV_GroupThreadID.x) >> 3))) + ((uint)(((uint)((uint)(_17.x)) >> 9) & 32760));
  _32 = float((uint)_29);
  _33 = float((uint)_31);
  _39 = (_32 + 0.5f) * View.BufferSizeAndInvSize.z;
  _40 = (_33 + 0.5f) * View.BufferSizeAndInvSize.w;
  _43 = SceneTexturesStruct_SceneDepthTexture.SampleLevel(SceneTexturesStruct_PointClampSampler, float2(_39, _40), 0.0f);
  _55 = ((View.InvDeviceZToWorldZTransform.x * _43.x) + View.InvDeviceZToWorldZTransform.y) + (1.0f / ((View.InvDeviceZToWorldZTransform.z * _43.x) - View.InvDeviceZToWorldZTransform.w));
  _57 = SceneTexturesStruct_GBufferATexture.Load(int3(_29, _31, 0));
  _62 = SceneTexturesStruct_GBufferBTexture.Load(int3(_29, _31, 0));
  _70 = uint((_62.w * 255.0f) + 0.5f);
  _71 = _70 & 15;
  _75 = (_57.x * 2.0f) + -1.0f;
  _76 = (_57.y * 2.0f) + -1.0f;
  _77 = (_57.z * 2.0f) + -1.0f;
  _78 = _70 & 14;
  _87 = rsqrt(dot(float3(_75, _76, _77), float3(_75, _76, _77)));
  _88 = _87 * _75;
  _89 = _87 * _76;
  _90 = _87 * _77;
  _91 = (_71 == 4);
  _92 = select(_91, select(((_78 == 8) || (((_70 & 12) == 4) || (_78 == 2))), (((float4)(SceneTexturesStruct_GBufferDTexture.Load(int3(_29, _31, 0)))).y), 0.0f), _62.z);
  if (ReflectionSmoothBias > 0.0f) {
    _100 = saturate(_92 / ReflectionSmoothBias);
    _107 = (((_100 * _100) * _92) * (3.0f - (_100 * 2.0f)));
  } else {
    _107 = _92;
  }
  _113 = select(((ReflectionPass & -3) == 0), _107, 0.0f);
  if (ReflectionPass == 0) {
    if (!(_71 == 0)) {
      _129 = (_91 || (saturate(InvRoughnessFadeLength * (select(((_70 & 11) == 2), MaxRoughnessToTraceForFoliage, MaxRoughnessToTrace) - _113)) > 0.0f));
    } else {
      _129 = false;
    }
    _137 = ((int)(uint)(_129));
  } else {
    if (ReflectionPass == 1) {
      _137 = ((int)(uint)((int)(_71 == 10)));
    } else {
      _137 = 0;
    }
  }
  if (!(_137 == 0)) {
    _141 = SpecularIndirect.Load(int4(_29, _31, 0, 0));
    float _center_luma = dot(float3(_141.x, _141.y, _141.z), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
    _151 = ResolveVariance.Load(int4(_29, _31, 0, 0));

    if (InjectionToggle(TOGGLE_USE_SUPERIOR_REFLECTION_FILTER)) {
      // Linear accumulation — no Karis tonemap
      _146 = 1.0f;
      _147 = _141.x;
      _148 = _141.y;
      _149 = _141.z;
    } else {
      _146 = _center_luma + 1.0f;
      _147 = _141.x / _146;
      _148 = _141.y / _146;
      _149 = _141.z / _146;
    }
    _163 = select((_151.x > BilateralFilterStrongBlurVarianceThreshold), 2.0f, 1.0f);
    _167 = ((View.ViewSizeAndInvSize.x * BilateralFilterSpatialKernelRadius) * saturate(_113 * 8.0f)) * _163;
    if ((_151.x > 0.03999999910593033f) && (_167 >= 0.5f)) {
      
        _186 = (_31 * 1664525) + 1013904223u;
        _187 = (ReflectionsStateFrameIndexMod8 * 1664525) + 1013904223u;
        _189 = ((_29 * 1664525) + 1013904223u) + (_187 * _186);
        _191 = (_189 * _187) + _186;
        _193 = (_191 * _189) + _187;
        _195 = (_193 * _191) + _189;
      _206 = (_39 - View.ScreenPositionScaleBias.w) / View.ScreenPositionScaleBias.x;
      _207 = (_40 - View.ScreenPositionScaleBias.z) / View.ScreenPositionScaleBias.y;
      _235 = ((View.ViewToClip[3].w) >= 1.0f);
      _236 = select(_235, _206, (_206 * _55));
      _237 = select(_235, _207, (_207 * _55));
      _256 = uint(min((float((uint)(uint)(BilateralFilterNumSamples)) * _163), 16.0f));
      if (!(_256 == 0)) {
        _260 = _147;
        _261 = _148;
        _262 = _149;
        _263 = 1.0f;
        _264 = 0;
        while(true) {
          _508 = _260;
          _509 = _261;
          _510 = _262;
          _511 = _263;
          _280 = (_167 * 2.0f) * (frac((float((uint)_264) / float((uint)_256)) + (float((uint)((uint)((uint)(_195) >> 16))) * 1.52587890625e-05f)) + -0.5f);
          _281 = ((float((uint)((uint)((uint)((uint)(reversebits(_264) ^ ((int)((_195 * _193) + _191)))) >> 16))) * 3.0517578125e-05f) + -1.0f) * _167;
          // IS-FAST replacement for per-pixel LCG seeds (_195/_193/_191) in
          // bilateral kernel spatial jitter. Preserves the per-sample stratified
          // sequence (frac(_264/_256) and reversebits(_264)) used to fill the
          // disc; only swaps the per-pixel/per-frame decorrelation with blue noise.
          //
          // Two improvements over the naive IS-FAST swap:
          //
          // 1. Kernel-radius-aware coordinate scaling: IS-FAST's blue-noise
          //    property (σ=1.0 Gaussian) only decorrelates within ~3px. When
          //    the bilateral kernel is 20-40px wide, pixels at the kernel's
          //    outer radius see uncorrelated (white-noise) IS-FAST values.
          //    Scaling the lookup coordinates by (128 / kernel_diameter) maps
          //    the full 128px blue-noise tile onto the kernel footprint, so
          //    adjacent pixels within the same kernel sample adjacent IS-FAST
          //    texels — preserving decorrelation at the scale that matters.
          //
          // 2. Two independent IS-FAST samples for radial vs angular: the
          //    original code used .x for radial and .y for angular from a
          //    single jointly-optimized 2D sample. For polar disc coverage,
          //    independent streams are better. A second lookup at a coprime
          //    spatial offset provides a decorrelated angular seed.
          if (InjectionToggle(TOGGLE_USE_ISFAST_REFLECTIONS)) {
            // Scale coordinates so the 128px tile spans the kernel diameter.
            // When kernel < 128px, scale >= 1.0 and we get standard 1:1 behavior.
            float _kernel_diameter = max(_167 * 2.0f, 1.0f);
            float _coord_scale = max(128.0f / _kernel_diameter, 1.0f);
            float2 _scaled_coord = float2(float(_29), float(_31)) * _coord_scale;

            uint _isfast_frame = uint(float(InjectionFrameIndex())) % 32u;

            // Radial seed: kernel-scaled coordinates
            float2 _isfast_radial = ISFASTNoiseLoad(uint(_scaled_coord.x) % 128u, uint(_scaled_coord.y) % 128u, _isfast_frame);

            // Angular seed: coprime spatial offset for decorrelation from radial
            float2 _isfast_angular = ISFASTNoiseLoad((uint(_scaled_coord.x) + 67u) % 128u, (uint(_scaled_coord.y) + 43u) % 128u, _isfast_frame);

            float _strat1 = float((uint)_264) / float((uint)_256);
            float _strat2 = float((uint)reversebits((uint)_264)) * 2.3283064365386963e-10f;
            _280 = (_167 * 2.0f) * (frac(_strat1 + _isfast_radial.x) + -0.5f);
            _281 = ((frac(_strat2 + _isfast_angular.x) * 2.0f) + -1.0f) * _167;
          }
          _284 = int(_280 + _32);
          _285 = int(_281 + _33);
          if ((((int)_284 >= (int)View.ViewRectMinAndSize.x) && ((int)_284 < (int)((int)((uint)(View.ViewRectMinAndSize.z) + (uint)(View.ViewRectMinAndSize.x))))) && (((int)_285 >= (int)View.ViewRectMinAndSize.y) && ((int)_285 < (int)((int)((uint)(View.ViewRectMinAndSize.w) + (uint)(View.ViewRectMinAndSize.y)))))) {
            _311 = SceneTexturesStruct_SceneDepthTexture.Load(int3(_284, _285, 0));
            _323 = ((View.InvDeviceZToWorldZTransform.x * _311.x) + View.InvDeviceZToWorldZTransform.y) + (1.0f / ((View.InvDeviceZToWorldZTransform.z * _311.x) - View.InvDeviceZToWorldZTransform.w));
            _325 = SceneTexturesStruct_GBufferATexture.Load(int3(_284, _285, 0));
            _330 = SceneTexturesStruct_GBufferBTexture.Load(int3(_284, _285, 0));
            _338 = uint((_330.w * 255.0f) + 0.5f);
            _339 = _338 & 15;
            _343 = (_325.x * 2.0f) + -1.0f;
            _344 = (_325.y * 2.0f) + -1.0f;
            _345 = (_325.z * 2.0f) + -1.0f;
            _346 = _338 & 14;
            _355 = rsqrt(dot(float3(_343, _344, _345), float3(_343, _344, _345)));
            _359 = (_339 == 4);
            _360 = select(_359, select(((_346 == 8) || (((_338 & 12) == 4) || (_346 == 2))), (((float4)(SceneTexturesStruct_GBufferDTexture.Load(int3(_284, _285, 0)))).y), 0.0f), _330.z);
            if (ReflectionSmoothBias > 0.0f) {
              _368 = saturate(_360 / ReflectionSmoothBias);
              _375 = (((_368 * _368) * _360) * (3.0f - (_368 * 2.0f)));
            } else {
              _375 = _360;
            }
            _389 = ((View.BufferSizeAndInvSize.z * (float((uint)_284) + 0.5f)) - View.ScreenPositionScaleBias.w) / View.ScreenPositionScaleBias.x;
            _390 = ((View.BufferSizeAndInvSize.w * (float((uint)_285) + 0.5f)) - View.ScreenPositionScaleBias.z) / View.ScreenPositionScaleBias.y;
            _418 = ((View.ViewToClip[3].w) >= 1.0f);
            _419 = select(_418, _389, (_389 * _323));
            _420 = select(_418, _390, (_390 * _323));
            if (ReflectionPass == 0) {
              if (!(_339 == 0)) {
                _448 = (_359 || (saturate(InvRoughnessFadeLength * (select(((_338 & 11) == 2), MaxRoughnessToTraceForFoliage, MaxRoughnessToTrace) - select(((ReflectionPass & -3) == 0), _375, 0.0f))) > 0.0f));
              } else {
                _448 = false;
              }
              _456 = ((int)(uint)(_448));
            } else {
              if (ReflectionPass == 1) {
                _456 = ((int)(uint)((int)(_339 == 10)));
              } else {
                _456 = 0;
              }
            }
            if (!(_456 == 0)) {
              _461 = abs(dot(float4(((View.ViewOriginHigh.x + (View.ScreenToRelativeWorld[3].x)) + mad(_323, (View.ScreenToRelativeWorld[2].x), mad(_420, (View.ScreenToRelativeWorld[1].x), (_419 * (View.ScreenToRelativeWorld[0].x))))), ((View.ViewOriginHigh.y + (View.ScreenToRelativeWorld[3].y)) + mad(_323, (View.ScreenToRelativeWorld[2].y), mad(_420, (View.ScreenToRelativeWorld[1].y), (_419 * (View.ScreenToRelativeWorld[0].y))))), ((View.ViewOriginHigh.z + (View.ScreenToRelativeWorld[3].z)) + mad(_323, (View.ScreenToRelativeWorld[2].z), mad(_420, (View.ScreenToRelativeWorld[1].z), (_419 * (View.ScreenToRelativeWorld[0].z))))), -1.0f), float4(_88, _89, _90, dot(float3(((View.ViewOriginHigh.x + (View.ScreenToRelativeWorld[3].x)) + mad(_55, (View.ScreenToRelativeWorld[2].x), mad(_237, (View.ScreenToRelativeWorld[1].x), (_236 * (View.ScreenToRelativeWorld[0].x))))), ((View.ViewOriginHigh.y + (View.ScreenToRelativeWorld[3].y)) + mad(_55, (View.ScreenToRelativeWorld[2].y), mad(_237, (View.ScreenToRelativeWorld[1].y), (_236 * (View.ScreenToRelativeWorld[0].y))))), ((View.ViewOriginHigh.z + (View.ScreenToRelativeWorld[3].z)) + mad(_55, (View.ScreenToRelativeWorld[2].z), mad(_237, (View.ScreenToRelativeWorld[1].z), (_236 * (View.ScreenToRelativeWorld[0].z)))))), float3(_88, _89, _90))))) / _55;
              _473 = saturate(dot(float3(_88, _89, _90), float3((_355 * _343), (_355 * _344), (_355 * _345))));
              _474 = abs(_473);
              _479 = (1.5707963705062866f - (_474 * 0.1565829962491989f)) * sqrt(1.0f - _474);
              _484 = saturate(select((_473 >= 0.0f), _479, (3.1415927410125732f - _479)) * (1.0f / (BilateralFilterNormalAngleThresholdScale * (((_62.z * _62.z) * 3.1412785053253174f) + 0.00031415926059708f))));
              _489 = (exp2(-0.0f - ((2.0f / (_167 * _167)) * dot(float2(_280, _281), float2(_280, _281)))) * exp2(-0.0f - ((_461 * _461) * BilateralFilterDepthWeightScale))) * ((1.0f - _484) + (_484 * select((_151.x > 0.8999999761581421f), 1.0f, 0.0f)));
              _491 = SpecularIndirect.Load(int4(_284, _285, 0, 0));
              if (InjectionToggle(TOGGLE_USE_SUPERIOR_REFLECTION_FILTER)) {
                // Soft firefly clamp — bound samples that are absurdly brighter than center.
                // Not the Karis crush: just caps single-pixel outliers at 8x center luma.
                float _sample_luma_raw = dot(float3(_491.x, _491.y, _491.z), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
                const float _firefly_cap = 8.0f;
                float _luma_ref = max(_center_luma, 0.01f);
                if (_sample_luma_raw > _luma_ref * _firefly_cap) {
                  float _clamp_scale = (_luma_ref * _firefly_cap) / _sample_luma_raw;
                  _491.x *= _clamp_scale;
                  _491.y *= _clamp_scale;
                  _491.z *= _clamp_scale;
                }
                // Color-range weight in log-luminance space (true bilateral).
                // Variance-adaptive sigma: tight on clean regions, wide in noisy regions so the
                // filter can still denoise where neighbors are genuinely different noisy samples
                // of the same underlying signal.
                float _sample_luma = dot(float3(_491.x, _491.y, _491.z), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
                float _log_delta = log2(_sample_luma + 0.001f) - log2(_center_luma + 0.001f);
                float _color_sigma_sq = 0.25f + 4.0f * saturate(_151.x);  // 0.25 .. 4.25
                float _color_weight = exp2(-(_log_delta * _log_delta) / _color_sigma_sq);
                _489 = _489 * _color_weight;
                _496 = 1.0f;  // Linear accumulation — no per-sample tonemap
              } else {
                _496 = dot(float3(_491.x, _491.y, _491.z), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f)) + 1.0f;
              }
              _508 = (((_491.x / _496) * _489) + _260);
              _509 = (((_491.y / _496) * _489) + _261);
              _510 = (((_491.z / _496) * _489) + _262);
              _511 = (_489 + _263);
            } else {
              _508 = _260;
              _509 = _261;
              _510 = _262;
              _511 = _263;
            }
          } else {
            _508 = _260;
            _509 = _261;
            _510 = _262;
            _511 = _263;
          }
          _512 = _264 + 1u;
          if (!(_512 == _256)) {
            _260 = _508;
            _261 = _509;
            _262 = _510;
            _263 = _511;
            _264 = _512;
            continue;
          }
          _516 = _508;
          _517 = _509;
          _518 = _510;
          _519 = _511;
          break;
        }
      } else {
        _516 = _147;
        _517 = _148;
        _518 = _149;
        _519 = 1.0f;
      }
      _524 = (_516 / _519);
      _525 = (_517 / _519);
      _526 = (_518 / _519);
    } else {
      _524 = _147;
      _525 = _148;
      _526 = _149;
    }
    _528 = 1.0f - dot(float3(_524, _525, _526), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
    if (InjectionToggle(TOGGLE_USE_SUPERIOR_REFLECTION_FILTER)) {
      // Already in linear space — skip inverse tonemap
      _533 = _524;
      _534 = _525;
      _535 = _526;
    } else {
      _533 = (_524 / _528);
      _534 = (_525 / _528);
      _535 = (_526 / _528);
    }
  } else {
    _533 = 0.0f;
    _534 = 0.0f;
    _535 = 0.0f;
  }
  // Debug visualization for bilateral filter
  //
  // Modes (driven by DebugReflections dropdown). Each mode uses a color
  // pair picked so no two modes can look the same — yellow means "IS-FAST
  // mode, but off", NOT any other mode's "off" state:
  //   0 = off, write normal filtered color
  //   1 = IS-FAST noise:          green=active, red=binding fail, yellow=off
  //   2 = (reserved, was A-trous toggle): always gray
  //   3 = Superior Filter toggle: white=on, black=off
  //   4 = Superior Temporal:      blue=on,  pink=off
  //   5 = (reserved, was multipass A-trous): always gray
  //   6 = All toggles at once:    G=superior_filter only (R/B reserved).
  //                               Alpha channel (brightness) = use_isfast_reflections.
  //   7 = Frame-index heartbeat:  R oscillates with frame_index. If frozen,
  //                               OnPresent isn't firing and the cbuffer is
  //                               stale.
  //   8 = Cbuffer field strip:    paint the reflection buffer with a pattern
  //                               where each column (x mod 24) reads one
  //                               shader_injection field. White = value > 0.5,
  //                               black = value <= 0.5. A whole-frame pattern
  //                               shows exactly which fields are live and
  //                               which are stuck / truncated by the root
  //                               signature DWORD budget.
  if ((InjectionEnum(ENUM_DEBUG_REFLECTIONS_SHIFT) > 0u)) {
    uint _dbg_mode = InjectionEnum(ENUM_DEBUG_REFLECTIONS_SHIFT);
    float3 _dbg_col = float3(0.5f, 0.5f, 0.5f);
    if (_dbg_mode == 1u) {
      _dbg_col = float3(0.8f, 0.8f, 0.0f);  // yellow = IS-FAST off
    } else if (_dbg_mode == 2u) {
      // Reserved (was A-trous toggle, now removed).
      _dbg_col = float3(0.5f, 0.5f, 0.5f);
    } else if (_dbg_mode == 3u) {
      _dbg_col = (InjectionToggle(TOGGLE_USE_SUPERIOR_REFLECTION_FILTER))
          ? float3(1.0f, 1.0f, 1.0f)   // white
          : float3(0.0f, 0.0f, 0.0f);  // black
    } else if (_dbg_mode == 4u) {
      _dbg_col = (InjectionToggle(TOGGLE_USE_SUPERIOR_REFLECTION_TEMPORAL))
          ? float3(0.0f, 0.0f, 1.0f)   // blue
          : float3(1.0f, 0.5f, 0.7f);  // pink
    } else if (_dbg_mode == 5u) {
      // Reserved (was multipass A-trous toggle, now removed).
      _dbg_col = float3(0.5f, 0.5f, 0.5f);
    } else if (_dbg_mode == 6u) {
      // Combined view: each primary channel shows one toggle, brightness
      // shows IS-FAST.
      float _r = 0.0f;  // (was A-trous, now removed)
      float _g = (InjectionToggle(TOGGLE_USE_SUPERIOR_REFLECTION_FILTER)) ? 1.0f : 0.0f;
      float _b = 0.0f;  // (was multipass A-trous, now removed)
      float _bright = (InjectionToggle(TOGGLE_USE_ISFAST_REFLECTIONS)) ? 1.0f : 0.25f;
      _dbg_col = float3(_r, _g, _b) * _bright + float3(0.05f, 0.05f, 0.05f);
    } else if (_dbg_mode == 7u) {
      // Heartbeat: frame_index cycles 0..31. Oscillate R so a static image
      // means OnPresent isn't ticking.
      float _t = (sin(float(InjectionFrameIndex()) * 0.3926991f) * 0.5f + 0.5f);
      _dbg_col = float3(_t, 0.1f, 1.0f - _t);
    } else if (_dbg_mode == 8u) {
      // Cbuffer field strip. Each column (x modulo 24) decodes one
      // shader_injection float. White = >0.5, black = otherwise. This
      // visualizes the entire injected cbuffer contents at a glance so
      // we can see exactly which fields are live vs stuck / truncated.
      uint _field = uint(_29) % 24u;
      float _v = 0.0f;
      if      (_field ==  0u) _v = (InjectionToggle(TOGGLE_USE_ISFAST_NOISE) ? 1.0f : 0.0f);
      else if (_field ==  1u) _v = float(InjectionEnum(ENUM_DEBUG_NOISE_SHIFT));
      else if (_field ==  2u) _v = (InjectionToggle(TOGGLE_USE_ISFAST_DOF) ? 1.0f : 0.0f);
      else if (_field ==  3u) _v = float(InjectionEnum(ENUM_DEBUG_DOF_SHIFT));
      else if (_field ==  4u) _v = (InjectionToggle(TOGGLE_USE_ISFAST_SHADOWS) ? 1.0f : 0.0f);
      else if (_field ==  5u) _v = float(InjectionEnum(ENUM_DEBUG_SHADOWS_SHIFT));
      else if (_field ==  6u) _v = (InjectionToggle(TOGGLE_USE_ISFAST_FOG) ? 1.0f : 0.0f);
      else if (_field ==  7u) _v = float(InjectionFogFilterMode()) / 3.0f;
      else if (_field ==  8u) _v = 0.0f  > 0.0f ? 1.0f : 0.0f;
      else if (_field ==  9u) _v = 0.0f > 0.0f ? 1.0f : 0.0f;
      else if (_field == 10u) _v = 0.0f  > 0.0f ? 1.0f : 0.0f;
      else if (_field == 11u) _v = float(InjectionEnum(ENUM_DEBUG_FOG_SHIFT));
      else if (_field == 12u) _v = (InjectionToggle(TOGGLE_USE_SINGLEPASS_DOF) ? 1.0f : 0.0f);
      else if (_field == 13u) _v = (InjectionToggle(TOGGLE_USE_SMOOTH_DOF) ? 1.0f : 0.0f);
      else if (_field == 14u) _v = float(InjectionFrameIndex()) / 32.0f;
      else if (_field == 15u) _v = (InjectionToggle(TOGGLE_USE_ISFAST_REFLECTIONS) ? 1.0f : 0.0f);
      else if (_field == 16u) _v = float(InjectionEnum(ENUM_DEBUG_REFLECTIONS_SHIFT)) / 8.0f;
      else if (_field == 17u) _v = (InjectionToggle(TOGGLE_USE_SUPERIOR_REFLECTION_FILTER) ? 1.0f : 0.0f);
      else if (_field == 18u) _v = (InjectionToggle(TOGGLE_USE_SUPERIOR_REFLECTION_TEMPORAL) ? 1.0f : 0.0f);
      else if (_field == 19u) _v = 0.0f;  // (was A-trous, now removed)
      else if (_field == 20u) _v = 0.0f;  // (was multipass A-trous, now removed)
      // 21..23 are padding; paint them with fixed known values so we can
      // tell a "stuck zero" from "end of strip".
      else if (_field == 21u) _v = 0.25f;
      else if (_field == 22u) _v = 0.50f;
      else                    _v = 0.75f;
      // Color each field position uniquely so a wall of "same color"
      // proves the cbuffer is stuck, not just accidentally same-valued.
      float3 _hue = float3(float(_field % 3u) * 0.5f,
                           float((_field / 3u) % 3u) * 0.5f,
                           float((_field / 9u) % 3u) * 0.5f);
      _dbg_col = _hue * _v + float3(0.05f, 0.05f, 0.05f);
    } else {
      _dbg_col = float3(0.5f, 0.5f, 0.5f);  // unknown debug mode: gray
    }
    RWSpecularIndirect[int3(_29, _31, 0)] = _dbg_col;
  } else {
    RWSpecularIndirect[int3(_29, _31, 0)] = float3(_533, _534, _535);
  }
}