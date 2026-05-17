#include "../shared.h"

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


Texture2D<float4> SceneColorInput : register(t0);

Texture2D<float> LowResDepthTexture : register(t1);

Texture2D<float> FullResDepthTexture : register(t2);

Texture2D<float4> SceneSeparateTranslucency : register(t3);

Texture2D<float4> SceneSeparateTranslucencyModulateColor : register(t4);

Texture2D<float4> ForegroundConvolution_SceneColor : register(t5);

Texture2D<float4> ForegroundHoleFillingConvolution_SceneColor : register(t6);

Texture2D<float4> SlightOutOfFocusConvolution_SceneColor : register(t7);

Texture2D<float4> BackgroundConvolution_SceneColor : register(t8);

// IS-FAST noise buffer (ByteAddressBuffer root SRV â€” avoids ReShade heap-swap corruption)
ByteAddressBuffer ISFASTNoise : register(t0, space50);
static const uint ISFAST_W = 128u;
static const uint ISFAST_H = 128u;
static const uint ISFAST_SLICE_TEXELS = ISFAST_W * ISFAST_H;
static const uint ISFAST_ELEMENT_BYTES = 8u;
static float2 ISFASTNoiseLoad(uint x, uint y, uint slice) {
  return asfloat(ISFASTNoise.Load2((slice * ISFAST_SLICE_TEXELS + y * ISFAST_W + x) * ISFAST_ELEMENT_BYTES));
}

RWTexture2D<float4> SceneColorOutput : register(u0);

cbuffer _RootShaderParameters : register(b0) {
  float CocInvSqueeze : packoffset(c003.z);
  uint4 ViewportRect : packoffset(c005.x);
  float4 ViewportSize : packoffset(c006.x);
  float4 DispatchThreadIdToDOFBufferUV : packoffset(c007.x);
  float2 DOFBufferUVMax : packoffset(c008.x);
  float4 SeparateTranslucencyBilinearUVMinMax : packoffset(c009.x);
  uint SeparateTranslucencyUpscaling : packoffset(c010.x);
  float EncodedCocRadiusToRecombineCocRadius : packoffset(c010.y);
  float4 ConvolutionInputSize : packoffset(c015.x);
  float2 SeparateTranslucencyTextureLowResExtentInverse : packoffset(c020.x);
};

cbuffer View : register(b1) {
  FViewConstants View : packoffset(c000.x);
};

SamplerState D3DStaticPointClampedSampler : register(s1, space1000);

SamplerState D3DStaticBilinearClampedSampler : register(s3, space1000);

// DXIL FirstbitHi: returns bit position counting from MSB (leading zeros count)
uint firstbithigh_msb(int value) { return (value == 0) ? 0xFFFFFFFF : (31u - firstbithigh(value)); }
uint firstbithigh_msb(uint value) { return (value == 0) ? 0xFFFFFFFF : (31u - firstbithigh(value)); }

groupshared uint _global_0;
static const int _global_1[8] = { -1, -1, 1, -1, -1, 1, 1, 1 };

[numthreads(8, 8, 1)]
void main(
  uint3 SV_DispatchThreadID : SV_DispatchThreadID,
  uint3 SV_GroupID : SV_GroupID,
  uint3 SV_GroupThreadID : SV_GroupThreadID,
  uint SV_GroupIndex : SV_GroupIndex
) {
  float _22;
  float _23;
  float _24;
  float _25;
  float _53;
  float _54;
  float _67;
  float _68;
  uint _75;
  uint _76;
  uint _78;
  uint _80;
  uint _82;
  uint _84;
  float4 _90;
  float _95;
  float4 _98;
  float _105;
  float _106;
  float _110;
  int _111;
  int _194;
  float _195;
  float _196;
  float _197;
  float _198;
  float _199;
  float _200;
  float _339;
  float _340;
  float _341;
  float _342;
  float _371;
  float _372;
  float _373;
  float _374;
  float _375;
  float _376;
  float _497;
  float _498;
  float _499;
  float _500;
  float _540;
  float _541;
  float _542;
  float _543;
  float _544;
  float _672;
  float _673;
  bool _674;
  float _708;
  float _709;
  float _710;
  float _711;
  float _712;
  float _713;
  float _714;
  float _147;
  float _150;
  int _151;
  uint _155;
  float _157;
  float _158;
  float _160;
  int _164;
  float _183;
  float _185;
  float _187;
  float _188;
  float _189;
  float _190;
  float _213;
  float _214;
  float _215;
  float _216;
  float _221;
  bool _222;
  float _223;
  float _230;
  float _231;
  float _250;
  float _251;
  float _256;
  float _261;
  float _264;
  float4 _278;
  float _285;
  float _286;
  float _292;
  float _296;
  float4 _303;
  float _308;
  float _309;
  float _315;
  float _319;
  float _322;
  float _329;
  float _344;
  float _350;
  float _355;
  float _357;
  float _359;
  float _361;
  float _364;
  float _366;
  uint _367;
  float _377;
  float _378;
  float _384;
  float _385;
  float4 _388;
  float _394;
  float4 _395;
  float _409;
  float4 _410;
  float4 _423;
  float _428;
  float _429;
  float _430;
  float _431;
  float _439;
  float _440;
  float _441;
  float _442;
  float _443;
  float _467;
  bool _489;
  float _492;
  float4 _503;
  float _510;
  float4 _515;
  float _532;
  float _535;
  float _551;
  float4 _580;
  float _621;
  float _629;
  float _632;
  float _633;
  float _635;
  float _637;
  float _638;
  float _640;
  bool _641;
  float _642;
  float _646;
  bool _647;
  float _651;
  bool _652;
  float _656;
  bool _667;
  float _682;
  float _683;
  float4 _688;
  float4 _693;
  float4 _698;
  float4 _703;
  _22 = float((uint)SV_DispatchThreadID.x);
  _23 = float((uint)SV_DispatchThreadID.y);
  _24 = _22 + 0.5f;
  _25 = _23 + 0.5f;
  _53 = min(max(((((ViewportSize.z * _24) * View.ViewSizeAndInvSize.x) + View.ViewRectMin.x) * View.BufferSizeAndInvSize.z), View.BufferBilinearUVMinMax.x), View.BufferBilinearUVMinMax.z);
  _54 = min(max(((((ViewportSize.w * _25) * View.ViewSizeAndInvSize.y) + View.ViewRectMin.y) * View.BufferSizeAndInvSize.w), View.BufferBilinearUVMinMax.y), View.BufferBilinearUVMinMax.w);
  _67 = min(((DispatchThreadIdToDOFBufferUV.x * _22) + DispatchThreadIdToDOFBufferUV.z), DOFBufferUVMax.x);
  _68 = min(((DispatchThreadIdToDOFBufferUV.y * _23) + DispatchThreadIdToDOFBufferUV.w), DOFBufferUVMax.y);
  _75 = ((int)(SV_DispatchThreadID.y) * 1664525) + 1013904223u;
  _76 = (View.StateFrameIndexMod8 * 1664525) + 1013904223u;
  _78 = (((int)(SV_DispatchThreadID.x) * 1664525) + 1013904223u) + (_76 * _75);
  _80 = (_78 * _76) + _75;
  _82 = (_80 * _78) + _76;
  _84 = (_82 * _80) + _78;
  _90 = ForegroundConvolution_SceneColor.SampleLevel(D3DStaticBilinearClampedSampler, float2(_67, _68), 0.0f);
  _95 = 1.0f - _90.w;
  _98 = SceneColorInput.SampleLevel(D3DStaticPointClampedSampler, float2(_53, _54), 0.0f);
  _105 = EncodedCocRadiusToRecombineCocRadius * _98.w;
  _global_0 = 0;
  GroupMemoryBarrierWithGroupSync();
  _106 = abs(_105);
  // Smooth the hard CoC < 3.0 threshold to reduce stairstep artifacts at tile boundaries
  if (InjectionToggle(TOGGLE_USE_SMOOTH_DOF)) {
    float _smooth_weight = 1.0f - smoothstep(2.0f, 4.0f, _106);
    _110 = _106 * _smooth_weight;
  } else {
    _110 = select((_106 < 3.0f), _106, 0.0f);
  }
  _111 = 0;
  while(true) {
    _147 = abs(EncodedCocRadiusToRecombineCocRadius * (((float4)(SceneColorInput.SampleLevel(D3DStaticPointClampedSampler, float2(min(max((((float((int)(_global_1[min((uint)(((int)(0u + (_111 * 2)))), 7u)])) * 6.0f) * View.BufferSizeAndInvSize.z) + _53), View.BufferBilinearUVMinMax.x), View.BufferBilinearUVMinMax.z), min(max((((float((int)(_global_1[min((uint)(((int)(1u + (_111 * 2)))), 7u)])) * 6.0f) * View.BufferSizeAndInvSize.w) + _54), View.BufferBilinearUVMinMax.y), View.BufferBilinearUVMinMax.w)), 0.0f))).w));
    if (InjectionToggle(TOGGLE_USE_SMOOTH_DOF)) {
      float _neighbor_smooth = _147 * (1.0f - smoothstep(2.0f, 4.0f, _147));
      _150 = max(_110, _neighbor_smooth);
    } else {
      _150 = max(_110, select((_147 < 3.0f), _147, _110));
    }
    _151 = _111 + 1;
    if (!(_151 == 4)) {
      _110 = _150;
      _111 = _151;
      continue;
    }
    InterlockedMax(_global_0, asint(_150), _155);
    GroupMemoryBarrierWithGroupSync();
    _157 = asfloat(_global_0);
    _158 = _157 * 2.0f;
    _160 = ceil(_158) + 0.5f;
    _164 = (int)min((uint)(12), (uint)((int)(uint((_157 * 3.1415927410125732f) * _158))));
    if (!(((uint)((int)((uint)(ViewportRect.x) + SV_DispatchThreadID.x)) >= (uint)ViewportRect.z) || ((uint)((int)((uint)(ViewportRect.y) + SV_DispatchThreadID.y)) >= (uint)ViewportRect.w))) {
      [branch]
      if ((!(_95 < 0.009999999776482582f)) && (_157 > 0.125f)) {
        _183 = _105 * _105;
        _185 = min((0.07957746833562851f / _183), 1.2732394933700562f);
        _187 = saturate(3.0f - _105);
        _188 = _185 * _98.x;
        _189 = _185 * _98.y;
        _190 = _185 * _98.z;
        if (!(_164 == 0)) {
          _194 = 0;
          _195 = 1.0f;
          _196 = _187;
          _197 = _185;
          _198 = _188;
          _199 = _189;
          _200 = _190;
          while(true) {
            // IS-FAST replacement for per-pixel LCG seeds (_84/_82/_80) used
            // in the bokeh disc sampling. Preserves the per-sample Halton(_194/12)
            // and reversebits(_194) low-discrepancy stratification, only swaps
            // the per-pixel decorrelation seed with screen-space blue noise.
            if (InjectionToggle(TOGGLE_USE_ISFAST_DOF)) {
              float2 _isfast_dof = ISFASTNoiseLoad(uint(SV_DispatchThreadID.x) % 128u, uint(SV_DispatchThreadID.y) % 128u, uint(float(InjectionFrameIndex())) % 32u);
              float _halton1 = float((uint)_194) * 0.0833333358168602f;
              float _halton2 = float((uint)reversebits((uint)_194)) * 2.3283064365386963e-10f;
              _213 = (frac(_halton1 + _isfast_dof.x) * 1.4142135381698608f) + -0.7071067690849304f;
              _214 = (frac(_halton2 + _isfast_dof.y) * 1.4142135381698608f) + -0.7071067690849304f;
            } else {
              _213 = (frac((float((uint)_194) * 0.0833333358168602f) + (float((uint)((uint)((uint)(_84) >> 16))) * 1.52587890625e-05f)) * 1.4142135381698608f) + -0.7071067690849304f;
              _214 = (float((uint)((uint)((uint)((uint)(reversebits(_194) ^ ((int)((_84 * _82) + _80)))) >> 16))) * 2.15791860682657e-05f) + -0.7071067690849304f;
            }
            _215 = _213 * _213;
            _216 = _214 * _214;
            _221 = sqrt((max(_215, _216) * 2.0f) - min(_215, _216));
            _222 = (_215 > _216);
            _223 = -0.0f - _221;
            _230 = select(_222, select((_213 > 0.0f), _221, _223), _213) * _160;
            _231 = select(_222, _214, select((_214 > 0.0f), _221, _223)) * _160;
            _250 = float((int)(((int)(uint)((int)(_230 > 0.0f))) - ((int)(uint)((int)(_230 < 0.0f))))) * floor(abs(_230) + 0.5f);
            _251 = float((int)(((int)(uint)((int)(_231 > 0.0f))) - ((int)(uint)((int)(_231 < 0.0f))))) * floor(abs(_231) + 0.5f);
            _256 = sqrt((_251 * _251) + (_250 * _250)) * 0.5f;
            _261 = View.BufferSizeAndInvSize.w * _251;
            _264 = (View.BufferSizeAndInvSize.z * _250) * CocInvSqueeze;
            _278 = SceneColorInput.SampleLevel(D3DStaticPointClampedSampler, float2(min(max((_264 + _53), View.BufferBilinearUVMinMax.x), View.BufferBilinearUVMinMax.z), min(max((_261 + _54), View.BufferBilinearUVMinMax.y), View.BufferBilinearUVMinMax.w)), 0.0f);
            _285 = EncodedCocRadiusToRecombineCocRadius * _278.w;
            _286 = abs(_285);
            _292 = saturate(saturate(((max(_286, 0.25f) - _256) * 4.0f) + 0.5f));
            _296 = (_292 * _292) * (3.0f - (_292 * 2.0f));
            _303 = SceneColorInput.SampleLevel(D3DStaticPointClampedSampler, float2(min(max((_53 - _264), View.BufferBilinearUVMinMax.x), View.BufferBilinearUVMinMax.z), min(max((_54 - _261), View.BufferBilinearUVMinMax.y), View.BufferBilinearUVMinMax.w)), 0.0f);
            _308 = EncodedCocRadiusToRecombineCocRadius * _303.w;
            _309 = abs(_308);
            _315 = saturate(saturate(((max(_309, 0.25f) - _256) * 4.0f) + 0.5f));
            _319 = (_315 * _315) * (3.0f - (_315 * 2.0f));
            _322 = min((0.07957746833562851f / (_285 * _285)), 1.2732394933700562f);
            _329 = min((0.07957746833562851f / (_308 * _308)), 1.2732394933700562f);
            if (!(_308 > _285)) {
              if (_285 > _308) {
                _339 = _329;
                _340 = _329;
                _341 = _319;
                _342 = _319;
              } else {
                _339 = _329;
                _340 = _322;
                _341 = _319;
                _342 = _296;
              }
            } else {
              _339 = _322;
              _340 = _322;
              _341 = _296;
              _342 = _296;
            }
            _344 = (_340 * saturate(3.0f - _286)) * _342;
            _350 = (_339 * saturate(3.0f - _309)) * _341;
            _355 = ((_350 * _303.x) + _198) + (_344 * _278.x);
            _357 = ((_350 * _303.y) + _199) + (_344 * _278.y);
            _359 = ((_350 * _303.z) + _200) + (_344 * _278.z);
            _361 = (_350 + _197) + _344;
            _364 = ((_341 * saturate(3.0f - _308)) + _196) + (_342 * saturate(3.0f - _285));
            _366 = (_341 + _195) + _342;
            _367 = _194 + 1u;
            if (!(_367 == _164)) {
              _194 = _367;
              _195 = _366;
              _196 = _364;
              _197 = _361;
              _198 = _355;
              _199 = _357;
              _200 = _359;
              continue;
            }
            _371 = _366;
            _372 = _364;
            _373 = _361;
            _374 = _355;
            _375 = _357;
            _376 = _359;
            break;
          }
        } else {
          _371 = 1.0f;
          _372 = _187;
          _373 = _185;
          _374 = _188;
          _375 = _189;
          _376 = _190;
        }
        _377 = ConvolutionInputSize.z * 0.5f;
        _378 = ConvolutionInputSize.w * 0.5f;
        _384 = min((_67 - _377), DOFBufferUVMax.x);
        _385 = min((_68 - _378), DOFBufferUVMax.y);
        _388 = SlightOutOfFocusConvolution_SceneColor.SampleLevel(D3DStaticPointClampedSampler, float2(_384, _385), 0.0f);
        _394 = min((_67 + _377), DOFBufferUVMax.x);
        _395 = SlightOutOfFocusConvolution_SceneColor.SampleLevel(D3DStaticPointClampedSampler, float2(_394, _385), 0.0f);
        _409 = min((_68 + _378), DOFBufferUVMax.y);
        _410 = SlightOutOfFocusConvolution_SceneColor.SampleLevel(D3DStaticPointClampedSampler, float2(_384, _409), 0.0f);
        _423 = SlightOutOfFocusConvolution_SceneColor.SampleLevel(D3DStaticPointClampedSampler, float2(_394, _409), 0.0f);
        _428 = min(min(min(_388.x, _395.x), _410.x), _423.x);
        _429 = min(min(min(_388.y, _395.y), _410.y), _423.y);
        _430 = min(min(min(_388.z, _395.z), _410.z), _423.z);
        _431 = min(min(min(_388.w, _395.w), _410.w), _423.w);
        _439 = (1.0f - saturate(_183 * 0.015625f)) * 0.125f;
        _440 = _439 * _428;
        _441 = _439 * _429;
        _442 = _439 * _430;
        _443 = _439 * _431;
        _467 = saturate(_183 * 4.0f);
        _489 = (_373 > 0.0f);
        _492 = select(_489, (1.0f / _373), 0.0f);
        _497 = select(_489, saturate(((_467 * (min(max(_372, (saturate(_431 - _443) * _371)), (saturate(_443 + max(max(max(_388.w, _395.w), _410.w), _423.w)) * _371)) - _372)) + _372) * select((_371 > 0.0f), (1.0f / _371), 0.0f)), 0.0f);
        _498 = (_492 * ((_467 * (min(max(_374, ((_428 - _440) * _373)), ((_440 + max(max(max(_388.x, _395.x), _410.x), _423.x)) * _373)) - _374)) + _374));
        _499 = (_492 * ((_467 * (min(max(_375, ((_429 - _441) * _373)), ((_441 + max(max(max(_388.y, _395.y), _410.y), _423.y)) * _373)) - _375)) + _375));
        _500 = (_492 * ((_467 * (min(max(_376, ((_430 - _442) * _373)), ((_442 + max(max(max(_388.z, _395.z), _410.z), _423.z)) * _373)) - _376)) + _376));
      } else {
        if (InjectionToggle(TOGGLE_USE_SMOOTH_DOF)) {
          _497 = 1.0f - smoothstep(0.0f, 0.75f, _106);
        } else {
          _497 = saturate(2.0f - (_106 * 4.0f));
        }
        _498 = _98.x;
        _499 = _98.y;
        _500 = _98.z;
      }
      // Read background convolution.
      //
      // Confidence-blended BG bokeh (008_dof-character-preservation):
      //
      // UE5's tile-based BG gather produces three failure modes that all
      // show up at hair silhouettes (and to a lesser extent on other
      // partial-coverage geometry):
      //
      //   1. Pure black holes (`_503.w == 0`) — tile classifier said skip.
      //   2. Hard 8x8 stairsteps where bilinear samples cross hole/non-hole
      //      boundaries (small-but-positive `_503.w`).
      //   3. Wrong-data tiles where the gather sampled through hair and
      //      wrote garbage RGB with healthy `_503.w`.
      //
      // The original soft-Karis single-pass DoF replacement that lived
      // here historically fixed all three perfectly because it bypassed
      // the BG buffer entirely — but it changed bulk-BG character too
      // aggressively, costing UE5's "cinematic feel" everywhere.
      //
      // Solution: keep the soft-Karis character on the per-pixel side
      // (because it was perfect at hair), then confidence-blend POST-
      // DIVIDE means with UE5's bokeh:
      //
      //   - Bulk-BG pixels (UE5 weight ≥ 2.0): UE5 dominates, character preserved.
      //   - Hole interior (UE5 weight = 0):    soft single-pass dominates, hair fixed.
      //   - Boundaries / through-hair garbage: smooth blend, no hard edges.
      //
      // Lerp is on post-divide colors so the blend is a true weighted
      // average — UE5's typically-larger pre-divide W doesn't skew the
      // mix the way it would for a pre-divide lerp.
      _503 = BackgroundConvolution_SceneColor.SampleLevel(D3DStaticBilinearClampedSampler, float2(_67, _68), 0.0f);
      if (InjectionToggle(TOGGLE_USE_SINGLEPASS_DOF) && (_106 > 0.5f)) {
        // ---- Per-pixel disc gather over SceneColorInput ----
        // SOFT character (matches the original SinglePassDiscDoF that
        // fixed hair perfectly): Karis luma weight per sample, soft
        // `max(sample_coc, center_coc)` falloff, adaptive sample count.
        // This is the "patch" character — only dominates where UE5 is
        // broken, so the soft look doesn't hurt bulk-BG.
        //
        // Scale CoC from gather-resolution pixels to full-res pixels.
        // At divisor=2 (default half-res gather), this is 2.0×.
        // At divisor=1 (full-res gather), this is 1.0× (no-op).
        // Without this, the disc radius and FG rejection threshold are
        // wrong at non-default gather resolutions.
        float _singlepassdof_gather_scale = View.BufferSizeAndInvSize.x * ConvolutionInputSize.z;
        float _singlepassdof_coc_fullres = _106 * _singlepassdof_gather_scale;
        float _singlepassdof_max_r_px = 0.025f * (1.0f / View.BufferSizeAndInvSize.w);  // 0.025 * screen_height
        float _singlepassdof_radius = clamp(_singlepassdof_coc_fullres, 0.5f, _singlepassdof_max_r_px);

        uint _singlepassdof_slice = uint(float(InjectionFrameIndex())) % 32u;
        float2 _singlepassdof_n = ISFASTNoiseLoad(uint(SV_DispatchThreadID.x) % 128u, uint(SV_DispatchThreadID.y) % 128u, _singlepassdof_slice);
        float _singlepassdof_rot = _singlepassdof_n.x * 6.2831853f;

        const float _singlepassdof_golden_angle = 2.39996323f;
        const uint _singlepassdof_min_samples = 16u;
        const uint _singlepassdof_max_samples = 48u;
        uint _singlepassdof_num_samples = uint(lerp(float(_singlepassdof_min_samples), float(_singlepassdof_max_samples),
            saturate(_singlepassdof_radius / _singlepassdof_max_r_px)));

        // Center sample privileged with Karis weight — same shape as the
        // original SinglePassDiscDoF.
        float _singlepassdof_center_luma = dot(_98.rgb, float3(0.2126f, 0.7152f, 0.0722f));
        float _singlepassdof_center_w = 1.0f / (1.0f + _singlepassdof_center_luma);
        float3 _singlepassdof_acc_rgb = _98.rgb * _singlepassdof_center_w;
        float _singlepassdof_acc_w = _singlepassdof_center_w;

        [loop]
        for (uint _singlepassdof_i = 0u; _singlepassdof_i < _singlepassdof_num_samples; ++_singlepassdof_i) {
          float _singlepassdof_t = (float(_singlepassdof_i) + 1.0f) / float(_singlepassdof_num_samples);
          float _singlepassdof_r_px = sqrt(_singlepassdof_t) * _singlepassdof_radius;
          float _singlepassdof_theta = float(_singlepassdof_i) * _singlepassdof_golden_angle + _singlepassdof_rot;
          float _singlepassdof_dx = cos(_singlepassdof_theta) * _singlepassdof_r_px * View.BufferSizeAndInvSize.z * CocInvSqueeze;
          float _singlepassdof_dy = sin(_singlepassdof_theta) * _singlepassdof_r_px * View.BufferSizeAndInvSize.w;
          float2 _singlepassdof_uv = clamp(
              float2(_53 + _singlepassdof_dx, _54 + _singlepassdof_dy),
              View.BufferBilinearUVMinMax.xy, View.BufferBilinearUVMinMax.zw);

          float4 _singlepassdof_s = SceneColorInput.SampleLevel(D3DStaticPointClampedSampler, _singlepassdof_uv, 0.0f);
          if (any(isnan(_singlepassdof_s.rgb)) || any(isinf(_singlepassdof_s.rgb))) continue;

          float _singlepassdof_sample_coc_abs = abs(EncodedCocRadiusToRecombineCocRadius * _singlepassdof_s.w) * _singlepassdof_gather_scale;

          // Foreground rejection — drop samples much sharper than center
          // (hair pixels, in-focus geometry). 25% threshold in full-res
          // pixels so it's resolution-independent.
          if (_singlepassdof_sample_coc_abs < _singlepassdof_coc_fullres * 0.25f) continue;

          // Soft falloff with center-CoC backstop: each sample's bokeh
          // extends as far as max(its own CoC, center's CoC), so even
          // small-CoC background samples spread across the full disc.
          // This is the smoothing characteristic that made the original
          // single-pass perfect at hiding hair tile holes.
          float _singlepassdof_gather_coc = max(_singlepassdof_sample_coc_abs, _singlepassdof_coc_fullres);
          float _singlepassdof_falloff = saturate((_singlepassdof_gather_coc - _singlepassdof_r_px + 0.5f) * 2.0f);

          // Karis luma weight per sample — dampens bright fireflies and
          // produces the soft, evenly-blurred output that hides hair
          // boundaries.
          float _singlepassdof_luma = dot(_singlepassdof_s.rgb, float3(0.2126f, 0.7152f, 0.0722f));
          float _singlepassdof_luma_w = 1.0f / (1.0f + _singlepassdof_luma);

          float _singlepassdof_w = _singlepassdof_falloff * _singlepassdof_luma_w;
          _singlepassdof_acc_rgb += _singlepassdof_s.rgb * _singlepassdof_w;
          _singlepassdof_acc_w   += _singlepassdof_w;
        }

        // Post-divide per-pixel mean. Karis weights cancel out in the
        // divide, leaving a clean weighted-average color.
        float3 _singlepassdof_pp_mean = _singlepassdof_acc_rgb / max(_singlepassdof_acc_w, 0.001f);
        if (any(isnan(_singlepassdof_pp_mean)) || any(isinf(_singlepassdof_pp_mean))) _singlepassdof_pp_mean = _98.rgb;

        // ---- Confidence blend in POST-DIVIDE color space ----
        // UE5 gather format is (R*W, G*W, B*W, W). Recover its mean.
        float _ue5_w = _503.w;
        float3 _ue5_mean = (_ue5_w > 0.001f) ? (_503.rgb / _ue5_w) : float3(0, 0, 0);

        // Confidence is calibrated so bulk-BG tiles (UE5 W typically 8+
        // for a fully-gathered tile) lock in at 1.0, while holes,
        // bilinear-mixed boundaries (W in 0-4 from mixing zero-tiles with
        // valid neighbors), and through-hair garbage tiles (W in 1-6 from
        // few legit samples) stay in the per-pixel-favoring zone.
        //
        // smoothstep(1.0, 8.0, W) gives:
        //   W = 0   → 0.0  (pure hole: single-pass dominates)
        //   W = 1   → 0.0  (bilinear boundary: single-pass dominates)
        //   W = 4   → 0.37 (partial: mostly single-pass)
        //   W = 8   → 1.0  (healthy bulk BG: UE5 dominates)
        //   W > 8   → 1.0  (clamped)
        //
        // This is much steeper than the previous `saturate(W * 0.5)` which
        // saturated at W=2 and let contaminated boundary data through.
        float _singlepassdof_conf = saturate(_ue5_w * 0.5f);
        float3 _blended_mean = lerp(_singlepassdof_pp_mean, _ue5_mean, _singlepassdof_conf);

        // Re-pack in UE5's gather format with a synthesized W when UE5's
        // is unhealthy. The downstream `_510 = 1/_503.w; _510 * _503.rgb`
        // recovers `_blended_mean` regardless of which W we pick.
        // Synthesized W = UE5's bokeh-density formula on the center CoC,
        // gives recombine's confidence math (`_544 = min(_544, ...)`)
        // sensible numbers in hole regions.
        float _singlepassdof_w_synth = min(0.0795775f / max(_106 * _106, 1e-4f), 1.27324f);
        float _blended_w = max(_ue5_w, _singlepassdof_w_synth);
        _503 = float4(_blended_mean * _blended_w, _blended_w);
      }
      _510 = select((_503.w > 0.0f), (1.0f / _503.w), 0.0f);
      _515 = ForegroundHoleFillingConvolution_SceneColor.SampleLevel(D3DStaticBilinearClampedSampler, float2(_67, _68), 0.0f);
      if (!(_503.w > 0.0010000000474974513f)) {
        if (_515.w < 1.0f) {
          _532 = min(_515.w, min((1.0f - (saturate(_105 + 3.0f) * saturate(-1.0f - (_105 * 8.0f)))), _503.w));
          _535 = (1.0f - _532) / (1.0f - _515.w);
          _540 = _497;
          _541 = (_535 * _515.x);
          _542 = (_535 * _515.y);
          _543 = (_535 * _515.z);
          _544 = _532;
        } else {
          _540 = 1.0f;
          _541 = _515.x;
          _542 = _515.y;
          _543 = _515.z;
          _544 = _515.w;
        }
      } else {
        _540 = _497;
        _541 = _515.x;
        _542 = _515.y;
        _543 = _515.z;
        _544 = _515.w;
      }
      _551 = 1.0f - _540;
      if (!(SeparateTranslucencyUpscaling == 0)) {
        _580 = LowResDepthTexture.GatherRed(D3DStaticBilinearClampedSampler, float2(_53, _54));
        _621 = FullResDepthTexture.Load(int3((int)(uint(_24 + View.ViewRectMin.x)), (int)(uint(_25 + View.ViewRectMin.y)), 0));
        _629 = min((((View.InvDeviceZToWorldZTransform.x * _621.x) + View.InvDeviceZToWorldZTransform.y) + (1.0f / ((View.InvDeviceZToWorldZTransform.z * _621.x) - View.InvDeviceZToWorldZTransform.w))), 2e+06f);
        _632 = _53 - (SeparateTranslucencyTextureLowResExtentInverse.x * 0.5f);
        _633 = _54 - (SeparateTranslucencyTextureLowResExtentInverse.y * 0.5f);
        _635 = abs(min((((View.InvDeviceZToWorldZTransform.x * _580.w) + View.InvDeviceZToWorldZTransform.y) + (1.0f / ((View.InvDeviceZToWorldZTransform.z * _580.w) - View.InvDeviceZToWorldZTransform.w))), 2e+06f) - _629);
        _637 = select((_635 < 1e+08f), _635, 1e+08f);
        _638 = _632 + SeparateTranslucencyTextureLowResExtentInverse.x;
        _640 = abs(min((((View.InvDeviceZToWorldZTransform.x * _580.z) + View.InvDeviceZToWorldZTransform.y) + (1.0f / ((View.InvDeviceZToWorldZTransform.z * _580.z) - View.InvDeviceZToWorldZTransform.w))), 2e+06f) - _629);
        _641 = (_640 < _637);
        _642 = select(_641, _640, _637);
        _646 = abs(min((((View.InvDeviceZToWorldZTransform.x * _580.x) + View.InvDeviceZToWorldZTransform.y) + (1.0f / ((View.InvDeviceZToWorldZTransform.z * _580.x) - View.InvDeviceZToWorldZTransform.w))), 2e+06f) - _629);
        _647 = (_646 < _642);
        _651 = abs(min((((View.InvDeviceZToWorldZTransform.x * _580.y) + View.InvDeviceZToWorldZTransform.y) + (1.0f / ((View.InvDeviceZToWorldZTransform.z * _580.y) - View.InvDeviceZToWorldZTransform.w))), 2e+06f) - _629);
        _652 = (_651 < select(_647, _646, _642));
        _656 = 1.0f / _629;
        _667 = ((((_635 * _656) < 0.10000000149011612f) && ((_640 * _656) < 0.10000000149011612f)) && ((_646 * _656) < 0.10000000149011612f)) && ((_651 * _656) < 0.10000000149011612f);
        _672 = select(_667, _53, select(_652, _638, select(_647, _632, select(_641, _638, _632))));
        _673 = select(_667, _54, select((_652 || _647), (_633 + SeparateTranslucencyTextureLowResExtentInverse.y), _633));
        _674 = (!_667);
      } else {
        _672 = _53;
        _673 = _54;
        _674 = true;
      }
      _682 = min(max(_672, SeparateTranslucencyBilinearUVMinMax.x), SeparateTranslucencyBilinearUVMinMax.z);
      _683 = min(max(_673, SeparateTranslucencyBilinearUVMinMax.y), SeparateTranslucencyBilinearUVMinMax.w);
      if (_674) {
        _688 = SceneSeparateTranslucency.SampleLevel(D3DStaticPointClampedSampler, float2(_682, _683), 0.0f);
        _693 = SceneSeparateTranslucencyModulateColor.SampleLevel(D3DStaticPointClampedSampler, float2(_682, _683), 0.0f);
        _708 = _688.x;
        _709 = _688.y;
        _710 = _688.z;
        _711 = _688.w;
        _712 = _693.x;
        _713 = _693.y;
        _714 = _693.z;
      } else {
        _698 = SceneSeparateTranslucency.SampleLevel(D3DStaticBilinearClampedSampler, float2(_682, _683), 0.0f);
        _703 = SceneSeparateTranslucencyModulateColor.SampleLevel(D3DStaticBilinearClampedSampler, float2(_682, _683), 0.0f);
        _708 = _698.x;
        _709 = _698.y;
        _710 = _698.z;
        _711 = _698.w;
        _712 = _703.x;
        _713 = _703.y;
        _714 = _703.z;
      }

      // Debug + hair gap fix + final output
      if ((InjectionEnum(ENUM_DEBUG_DOF_SHIFT) > 0u)) {
        int2 _dbg_out_pos = int2((int)(uint(View.BufferSizeAndInvSize.x * _53)), (int)(uint(View.BufferSizeAndInvSize.y * _54)));
        if (float(InjectionEnum(ENUM_DEBUG_DOF_SHIFT)) < 1.5f) {
          float _dbg_transition = smoothstep(2.0f, 4.0f, _106);
          float _dbg_slight_oof = smoothstep(0.0f, 0.75f, _106);
          float3 _dbg_color = lerp(float3(0, 1, 1), float3(1, 1, 0), _dbg_transition);
          _dbg_color *= (1.0f - _dbg_slight_oof);
          SceneColorOutput[_dbg_out_pos] = float4(_dbg_color, 0.0f);
        } else if (float(InjectionEnum(ENUM_DEBUG_DOF_SHIFT)) < 2.5f) {
          // Mode 2: Hair coverage — shows where hair fix activates
          float _dbg_coverage = min(min(_712, _713), _714);
          float _dbg_bg_avail = saturate(_503.w * 4.0f);
          float _dbg_blend = (1.0f - _dbg_coverage) * _dbg_bg_avail;
          // Green = blend strength, Red = no BG data available, Blue = hair detected but opaque
          SceneColorOutput[_dbg_out_pos] = float4(
            (1.0f - _dbg_coverage) * (1.0f - _dbg_bg_avail),  // Red: hair gap but no BG
            _dbg_blend,                                         // Green: active blend
            (1.0f - _dbg_coverage) * 0.3f,                     // Blue: raw hair detection
            0.0f);
        } else if (float(InjectionEnum(ENUM_DEBUG_DOF_SHIFT)) < 3.5f) {
          float3 _bg_only = (_503.w > 0.001f) ? float3(_510 * _503.x, _510 * _503.y, _510 * _503.z) : float3(0, 0, 0);
          SceneColorOutput[_dbg_out_pos] = float4(_bg_only, 0.0f);
        } else if (float(InjectionEnum(ENUM_DEBUG_DOF_SHIFT)) < 4.5f) {
          SceneColorOutput[_dbg_out_pos] = float4(_711, _711, _711, 0.0f);
        } else if (float(InjectionEnum(ENUM_DEBUG_DOF_SHIFT)) < 5.5f) {
          float3 _scatter = float3(_498, _499, _500) * _540;
          float3 _bg_gather = (_503.w > 0.001f) ? float3(_510 * _503.x, _510 * _503.y, _510 * _503.z) : float3(0, 0, 0);
          float3 _raw_dof = lerp(_scatter, _bg_gather, saturate(_106 - 1.0f));
          SceneColorOutput[_dbg_out_pos] = float4(_raw_dof, 0.0f);
        } else if (float(InjectionEnum(ENUM_DEBUG_DOF_SHIFT)) < 6.5f) {
          // Mode 6: IS-FAST noise visualization for DOF
          // Shows the raw noise texture values at this pixel. If the disk texture is bound:
          //   R = disk_point.x remapped to [0,1], G = disk_point.y remapped to [0,1]
          //   B = length(disk_point) — should be <=1 for all pixels if disk texture is working
          // If square texture is bound instead (fallback):
          //   R/G will show uniform square distribution, B will exceed 1.0 in corners
          int2 _dbg_nc = int2(uint(SV_DispatchThreadID.x) % 128u, uint(SV_DispatchThreadID.y) % 128u);
          uint _dbg_ns = uint(float(InjectionFrameIndex())) % 32u;
          float2 _dbg_raw = ISFASTNoiseLoad(uint(_dbg_nc.x), uint(_dbg_nc.y), _dbg_ns);
          float2 _dbg_disk = _dbg_raw * 2.0f - 1.0f;
          float _dbg_len = length(_dbg_disk);
          // Encode: RG = signed disk point remapped to [0,1] for display, B = radius
          // If disk texture: B should be uniformly distributed in [0,1]
          // If square texture: B will have values > 1.0 in corners (clamped to white)
          SceneColorOutput[_dbg_out_pos] = float4(
            _dbg_disk.x * 0.5f + 0.5f,  // R: x position on disk
            _dbg_disk.y * 0.5f + 0.5f,  // G: y position on disk
            _dbg_len,                     // B: radius (should be <=1 for disk, >1 in corners for square)
            0.0f);
        } else {
          // Mode 7+: raw composite (no post-processing)
          float3 _scatter = float3(_498, _499, _500) * _540;
          float3 _bg_gather = (_503.w > 0.001f) ? float3(_510 * _503.x, _510 * _503.y, _510 * _503.z) : float3(0, 0, 0);
          float3 _raw_dof = lerp(_scatter, _bg_gather, saturate(_106 - 1.0f));
          SceneColorOutput[_dbg_out_pos] = float4(_raw_dof, 0.0f);
        }
      } else {
        float3 _dof_composite = float3(
          ((((((_510 * _503.x) * _544) + _541) * _551) + (_540 * _498)) * _95) + _90.x,
          ((((((_510 * _503.y) * _544) + _542) * _551) + (_540 * _499)) * _95) + _90.y,
          ((((((_510 * _503.z) * _544) + _543) * _551) + (_540 * _500)) * _95) + _90.z
        );

        // Depth-discontinuity stability: at silhouette edges, reduce BG bokeh contribution
        // to prevent flickering from unstable gather data at depth boundaries
        if (InjectionToggle(TOGGLE_USE_SMOOTH_DOF)) {
          // Hair/translucency fix: where modulate color indicates partial coverage,
          // force the DoF composite to use the background bokeh result.
          // This ensures consistent blur behind hair strands regardless of tile classification.
          float _hair_coverage = min(min(_712, _713), _714);  // 1 = opaque, <1 = hair/translucent
          float _bg_available = saturate(_503.w * 4.0f);  // 1 if BG gather has valid data

          if (_hair_coverage < 0.95f && _bg_available > 0.1f) {
            // Behind hair: blend toward background bokeh to hide tile artifacts
            float _hair_blend_strength = (1.0f - _hair_coverage) * _bg_available;
            float3 _bg_color = float3(_510 * _503.x, _510 * _503.y, _510 * _503.z);
            _dof_composite = lerp(_dof_composite, _bg_color, _hair_blend_strength);
          }
        }

        float3 _final = ((_711 * _dof_composite) * float3(_712, _713, _714)) + float3(_708, _709, _710);
        SceneColorOutput[int2((int)(uint(View.BufferSizeAndInvSize.x * _53)), (int)(uint(View.BufferSizeAndInvSize.y * _54)))] = float4(_final, 0.0f);
      }
    }
    break;
  }
}