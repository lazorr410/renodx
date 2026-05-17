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

struct FBlueNoiseConstants {
  int3 Dimensions;
  int Padding12;
  int3 ModuloMasks;
  int Padding28;
  uint BindlessSRV_ScalarTexture;
  uint Padding36;
  uint BindlessSRV_Vec2Texture;
};


Texture2D<float4> SceneTexturesStruct_SceneDepthTexture : register(t0);

Texture2D<float4> SceneTexturesStruct_GBufferATexture : register(t1);

Texture2D<float4> SceneTexturesStruct_GBufferBTexture : register(t2);

Texture2D<float4> SceneTexturesStruct_GBufferDTexture : register(t3);

Texture2D<float4> SceneTexturesStruct_GBufferFTexture : register(t4);

Texture2D<float4> BlueNoise_Vec2Texture : register(t5);

Buffer<uint> ReflectionTracingTileData : register(t6);

Texture3D<uint> RadianceProbeIndirectionTexture : register(t7);

RWTexture2DArray<float> RWDownsampledDepth : register(u0);

RWTexture2DArray<uint> RWRayTraceDistance : register(u1);

RWTexture2DArray<float4> RWRayBuffer : register(u2);

cbuffer _RootShaderParameters : register(b0) {
  uint4 _RootShaderParameters_raw[45];
};

cbuffer View : register(b1) {
  FViewConstants View : packoffset(c000.x);
};

cbuffer BlueNoise : register(b2) {
  FBlueNoiseConstants BlueNoise : packoffset(c000.x);
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
  uint _21;
  int _29;
  int _30;
  int _51;
  int _52;
  float _126;
  float _127;
  float _128;
  float _129;
  float _146;
  bool _168;
  int _176;
  float _324;
  float _325;
  float _326;
  float _327;
  float _328;
  float _329;
  float _348;
  float _349;
  float _432;
  float _433;
  float _434;
  float _435;
  int _480;
  int _537;
  bool _610;
  float _611;
  float _623;
  int _624;
  float _634;
  float4 _55;
  float _67;
  float4 _69;
  float4 _71;
  float4 _76;
  uint _84;
  int _85;
  float _89;
  float _90;
  float _91;
  int _92;
  float _103;
  float _104;
  float _105;
  float _106;
  float _115;
  float _116;
  float _117;
  float _121;
  bool _130;
  float _131;
  float _139;
  float _152;
  float _195;
  float _196;
  bool _224;
  float _225;
  float _226;
  float _230;
  float _234;
  float _238;
  float _244;
  float _246;
  float _248;
  float _250;
  float _258;
  float _259;
  float _260;
  float _261;
  float _262;
  float _263;
  float _267;
  float4 _286;
  bool _293;
  float _306;
  float _309;
  float _311;
  float _332;
  float _335;
  float _338;
  float _339;
  float _350;
  float _351;
  float _353;
  float _356;
  float _357;
  float _359;
  float _364;
  float _365;
  float _366;
  float _369;
  float _372;
  float _376;
  float _380;
  float _388;
  float _389;
  float _390;
  float _392;
  float _393;
  float _394;
  float _395;
  float _397;
  float _398;
  float _399;
  float _400;
  float _402;
  float _417;
  float _420;
  float _423;
  float _425;
  float _439;
  float _449;
  float _450;
  float _455;
  float _459;
  float _464;
  float4 _482;
  float4 _488;
  float _492;
  float _493;
  float _494;
  float _508;
  uint _528;
  float4 _543;
  float4 _549;
  int _562;
  int _563;
  int _564;
  uint _566;
  uint _567;
  uint _573;
  uint _577;
  uint _586;
  int _612;
  float _617;
  _21 = ReflectionTracingTileData.Load((int)(SV_GroupID.x));
  _29 = (((int)(_21.x << 3)) & 32760) | ((int)(SV_GroupThreadID.x) & 7);
  _30 = (((uint)((uint)(_21.x)) >> 9) & 32760) + ((uint)(SV_GroupThreadID.x) >> 3);
  _51 = (int)min((uint)(((int)((asint(_RootShaderParameters_raw[8u].x) * _29) + (uint)(View.ViewRectMinAndSize.x)))), (uint)(((int)(((uint)(View.ViewRectMinAndSize.x) + (uint)(-1)) + (uint)(View.ViewRectMinAndSize.z)))));
  _52 = (int)min((uint)(((int)((asint(_RootShaderParameters_raw[8u].x) * _30) + (uint)(View.ViewRectMinAndSize.y)))), (uint)(((int)(((uint)(View.ViewRectMinAndSize.y) + (uint)(-1)) + (uint)(View.ViewRectMinAndSize.w)))));
  if (((uint)_29 < (uint)asint(_RootShaderParameters_raw[8u].z)) && ((uint)_30 < (uint)asint(_RootShaderParameters_raw[8u].w))) {
    _55 = SceneTexturesStruct_SceneDepthTexture.Load(int3(_51, _52, 0));
    _67 = ((View.InvDeviceZToWorldZTransform.x * _55.x) + View.InvDeviceZToWorldZTransform.y) + (1.0f / ((View.InvDeviceZToWorldZTransform.z * _55.x) - View.InvDeviceZToWorldZTransform.w));
    _69 = SceneTexturesStruct_GBufferFTexture.Load(int3(_51, _52, 0));
    _71 = SceneTexturesStruct_GBufferATexture.Load(int3(_51, _52, 0));
    _76 = SceneTexturesStruct_GBufferBTexture.Load(int3(_51, _52, 0));
    _84 = uint((_76.w * 255.0f) + 0.5f);
    _85 = _84 & 15;
    _89 = (_71.x * 2.0f) + -1.0f;
    _90 = (_71.y * 2.0f) + -1.0f;
    _91 = (_71.z * 2.0f) + -1.0f;
    _92 = _84 & 14;
    _103 = rsqrt(dot(float3(_89, _90, _91), float3(_89, _90, _91)));
    _104 = _103 * _89;
    _105 = _103 * _90;
    _106 = _103 * _91;
    if (!((_84 & 16) == 0)) {
      _115 = (_69.x * 2.0f) + -1.0f;
      _116 = (_69.y * 2.0f) + -1.0f;
      _117 = (_69.z * 2.0f) + -1.0f;
      _121 = rsqrt(dot(float3(_115, _116, _117), float3(_115, _116, _117)));
      _126 = ((_69.w * 2.0f) + -1.0f);
      _127 = (_121 * _115);
      _128 = (_121 * _116);
      _129 = (_121 * _117);
    } else {
      _126 = 0.0f;
      _127 = 0.0f;
      _128 = 0.0f;
      _129 = 0.0f;
    }
    _130 = (_85 == 4);
    _131 = select(_130, select(((_92 == 8) || (((_84 & 12) == 4) || (_92 == 2))), (((float4)(SceneTexturesStruct_GBufferDTexture.Load(int3(_51, _52, 0)))).y), 0.0f), _76.z);
    if (asfloat(_RootShaderParameters_raw[9u].w) > 0.0f) {
      _139 = saturate(_131 / asfloat(_RootShaderParameters_raw[9u].w));
      _146 = (((_139 * _139) * _131) * (3.0f - (_139 * 2.0f)));
    } else {
      _146 = _131;
    }
    _152 = select(((asint(_RootShaderParameters_raw[10u].x) & -3) == 0), _146, 0.0f);
    if (asint(_RootShaderParameters_raw[10u].x) == 0) {
      if (!(_85 == 0)) {
        _168 = (_130 || (saturate(asfloat(_RootShaderParameters_raw[13u].z) * (select(((_84 & 11) == 2), asfloat(_RootShaderParameters_raw[13u].y), asfloat(_RootShaderParameters_raw[13u].x)) - _152)) > 0.0f));
      } else {
        _168 = false;
      }
      _176 = ((int)(uint)(_168));
    } else {
      if (asint(_RootShaderParameters_raw[10u].x) == 1) {
        _176 = ((int)(uint)((int)(_85 == 10)));
      } else {
        _176 = 0;
      }
    }
    if (_176 == 0) {
      _634 = (-0.0f - _67);
    } else {
      _195 = ((View.BufferSizeAndInvSize.z * (float((uint)_51) + 0.5f)) - View.ScreenPositionScaleBias.w) / View.ScreenPositionScaleBias.x;
      _196 = ((View.BufferSizeAndInvSize.w * (float((uint)_52) + 0.5f)) - View.ScreenPositionScaleBias.z) / View.ScreenPositionScaleBias.y;
      _224 = ((View.ViewToClip[3].w) >= 1.0f);
      _225 = select(_224, _195, (_195 * _67));
      _226 = select(_224, _196, (_196 * _67));
      _230 = (View.ViewOriginHigh.x + (View.ScreenToRelativeWorld[3].x)) + mad(_67, (View.ScreenToRelativeWorld[2].x), mad(_226, (View.ScreenToRelativeWorld[1].x), (_225 * (View.ScreenToRelativeWorld[0].x))));
      _234 = (View.ViewOriginHigh.y + (View.ScreenToRelativeWorld[3].y)) + mad(_67, (View.ScreenToRelativeWorld[2].y), mad(_226, (View.ScreenToRelativeWorld[1].y), (_225 * (View.ScreenToRelativeWorld[0].y))));
      _238 = (View.ViewOriginHigh.z + (View.ScreenToRelativeWorld[3].z)) + mad(_67, (View.ScreenToRelativeWorld[2].z), mad(_226, (View.ScreenToRelativeWorld[1].z), (_225 * (View.ScreenToRelativeWorld[0].z))));
      _244 = (_230 - View.ViewOriginHigh.x) - View.ViewOriginLow.x;
      _246 = (_234 - View.ViewOriginHigh.y) - View.ViewOriginLow.y;
      _248 = (_238 - View.ViewOriginHigh.z) - View.ViewOriginLow.z;
      _250 = rsqrt(dot(float3(_244, _246, _248), float3(_244, _246, _248)));
      _258 = select(_224, View.ViewForward.x, (_244 * _250));
      _259 = select(_224, View.ViewForward.y, (_246 * _250));
      _260 = select(_224, View.ViewForward.z, (_248 * _250));
      _261 = -0.0f - _258;
      _262 = -0.0f - _259;
      _263 = -0.0f - _260;
      if (_152 < 0.0010000000474974513f) {
        _267 = dot(float3(_258, _259, _260), float3(_104, _105, _106)) * 2.0f;
        _432 = (_267 * _104);
        _433 = (_267 * _105);
        _434 = (_267 * _106);
        _435 = 0.0f;
      } else {
        // Random 2D sample for GGX-VNDF importance sampling.
        // IS-FAST blue noise wins here — its spatial blue-noise property
        // anti-correlates adjacent pixels' samples, which the bilateral
        // filter benefits from on every frame. Three iterations of
        // R2-progressive-with-various-scrambles all underperformed
        // IS-FAST alone in this pipeline (see project-docs/006).
        if (InjectionToggle(TOGGLE_USE_ISFAST_REFLECTIONS)) {
          float2 _isfast_sample = ISFASTNoiseLoad(uint(_29) % 128u, uint(_30) % 128u, uint(float(InjectionFrameIndex())) % 32u);
          _286 = float4(_isfast_sample.x, _isfast_sample.y, 0, 0);
        } else {
          _286 = BlueNoise_Vec2Texture.Load(int3((BlueNoise.ModuloMasks.x & _29), ((int)(((BlueNoise.ModuloMasks.z & asint(_RootShaderParameters_raw[11u].w)) * BlueNoise.Dimensions.y) + ((uint)(BlueNoise.ModuloMasks.y & _30)))), 0));
        }
        _293 = (_126 != 0.0f);
        if (_293) {
          _324 = _127;
          _325 = _128;
          _326 = _129;
          _327 = ((_129 * _105) - (_128 * _106));
          _328 = ((_127 * _106) - (_129 * _104));
          _329 = ((_128 * _104) - (_127 * _105));
        } else {
          _306 = select((_106 >= 0.0f), 1.0f, -1.0f);
          _309 = -0.0f - (1.0f / (_306 + _106));
          _311 = (_104 * _105) * _309;
          _324 = ((((_104 * _104) * _306) * _309) + 1.0f);
          _325 = (_311 * _306);
          _326 = (-0.0f - (_104 * _306));
          _327 = _311;
          _328 = (((_105 * _105) * _309) + _306);
          _329 = (-0.0f - _105);
        }
        _332 = mad(_326, _263, mad(_325, _262, (_324 * _261)));
        _335 = mad(_329, _263, mad(_328, _262, (_327 * _261)));
        _338 = mad(_106, _263, mad(_105, _262, (_104 * _261)));
        _339 = _152 * _152;

        // ---------------------------------------------------------------
        // LEAN-style roughness widening from sub-pixel normal variance.
        // Toggle: TOGGLE_USE_REFLECTION_LEAN_WIDENING
        //
        // Sub-pixel geometry (normal-mapped detail, micro-bumps,
        // silhouette curvature) varies inside a single screen pixel.
        // Single-sample reflection lacks the integration to capture
        // that variance, producing temporal boil and edge crawling
        // (the symptoms reported as Q2.B/C/D).
        //
        // Olano-Baker LEAN mapping: an isotropic Gaussian distribution
        // of sub-pixel surface normals with variance σ² adds an extra
        // GGX α² of approximately 2σ². We estimate σ² locally by
        // sampling GBufferA's normal at 4 cardinal neighbors and
        // computing the angular spread.
        //
        // Cost: 4 extra texture loads per pixel + ~10 ALU. The widened
        // α² is composed in quadrature with the base α² so we never
        // narrow — only broaden.
        if (InjectionToggle(TOGGLE_USE_REFLECTION_LEAN_WIDENING)) {
          // Sample normal at 4 cardinals (screen-space, full-res
          // coordinates). Out-of-bounds is fine — Load clamps return
          // zeros which we treat as "no contribution" via the
          // length<0.5 check below.
          int4 _lean_off_x = int4(_51 - 1, _51 + 1, _51,     _51    );
          int4 _lean_off_y = int4(_52,     _52,     _52 - 1, _52 + 1);
          float3 _lean_n_avg = float3(_104, _105, _106);  // include center
          float  _lean_count = 1.0f;
          [unroll]
          for (int _li = 0; _li < 4; _li++) {
            float4 _lga = SceneTexturesStruct_GBufferATexture.Load(int3(_lean_off_x[_li], _lean_off_y[_li], 0));
            float3 _ln = float3(_lga.x * 2.0f - 1.0f, _lga.y * 2.0f - 1.0f, _lga.z * 2.0f - 1.0f);
            // Skip empty/sky pixels (encoded normal length ~ 0).
            if (dot(_ln, _ln) < 0.25f) continue;
            _ln = _ln * rsqrt(max(dot(_ln, _ln), 1e-6f));
            // Reject pixels with strongly different normals (different
            // surface). Threshold = 30 degrees: cos(30°) ≈ 0.866.
            // Otherwise the σ² estimate inflates at silhouette pixels
            // and we'd over-widen the lobe at every silhouette.
            if (dot(_ln, float3(_104, _105, _106)) < 0.866f) continue;
            _lean_n_avg += _ln;
            _lean_count += 1.0f;
          }
          // Mean normal direction. Length < 1 indicates spread:
          // |E[n]|² = 1 - σ² for a small-angle Gaussian on the sphere.
          _lean_n_avg /= _lean_count;
          float _lean_mean_len_sq = saturate(dot(_lean_n_avg, _lean_n_avg));
          float _lean_sigma_sq = max(1.0f - _lean_mean_len_sq, 0.0f);
          // LEAN: α²_extra ≈ 2σ². Cap at 0.25 (= roughness 0.5 extra)
          // so we never widen more than half a roughness unit.
          float _lean_alpha_extra = min(2.0f * _lean_sigma_sq, 0.25f);
          // Compose in quadrature: only ever broaden.
          _339 = _339 + _lean_alpha_extra;
        }

        if (_293) {
          _348 = max((_339 * (_126 + 1.0f)), 0.0010000000474974513f);
          _349 = max((_339 * (1.0f - _126)), 0.0010000000474974513f);
        } else {
          _348 = _339;
          _349 = _339;
        }
        _350 = _348 * _332;
        _351 = _349 * _335;
        _353 = rsqrt(dot(float3(_350, _351, _338), float3(_350, _351, _338)));
        _356 = _353 * _338;
        _357 = _286.x * 6.2831854820251465f;
        _359 = saturate(min(_348, _349));
        _364 = sqrt((_335 * _335) + (_332 * _332)) + 1.0f;
        _365 = _359 * _359;
        _366 = _364 * _364;
        _369 = _338 * _338;
        _372 = (_366 - (_366 * _365)) / (_366 + (_369 * _365));
        _376 = (((1.0f - asfloat(_RootShaderParameters_raw[3u].z)) * _286.y) * (-1.0f - (_372 * _356))) + 1.0f;
        _380 = sqrt(saturate(1.0f - (_376 * _376)));
        _388 = ((cos(_357) * _380) + (_353 * _350)) * _348;
        _389 = ((sin(_357) * _380) + (_353 * _351)) * _349;
        _390 = max(0.0f, (_376 + _356));
        _392 = rsqrt(dot(float3(_388, _389, _390), float3(_388, _389, _390)));
        _393 = _392 * _388;
        _394 = _389 * _392;
        _395 = _392 * _390;
        _397 = _349 * _348;
        _398 = _393 * _349;
        _399 = _394 * _348;
        _400 = _395 * _397;
        _402 = _397 / dot(float3(_398, _399, _400), float3(_398, _399, _400));
        _417 = mad(_395, _104, mad(_394, _327, (_393 * _324)));
        _420 = mad(_395, _105, mad(_394, _328, (_393 * _325)));
        _423 = mad(_395, _106, mad(_394, _329, (_393 * _326)));
        _425 = dot(float3(_258, _259, _260), float3(_417, _420, _423)) * 2.0f;
        _432 = (_425 * _417);
        _433 = (_425 * _420);
        _434 = (_425 * _423);
        _435 = (1.0f / max((((_402 * _402) * ((_397 * 0.6366197466850281f) * dot(float3(_332, _335, _338), float3(_393, _394, _395)))) / ((_372 * _338) + sqrt(((_350 * _350) + _369) + (_351 * _351)))), 9.999999747378752e-05f));
      }
      _439 = max(_435, 9.999999747378752e-06f);
      // Debug visualization: override ray buffer with noise source indicator
      if ((InjectionEnum(ENUM_DEBUG_REFLECTIONS_SHIFT) > 0u)) {
        if (InjectionToggle(TOGGLE_USE_ISFAST_REFLECTIONS)) {
          float2 _dbg_sample = ISFASTNoiseLoad(uint(_29) % 128u, uint(_30) % 128u, uint(float(InjectionFrameIndex())) % 32u);
          if (_dbg_sample.x == 0.0f && _dbg_sample.y == 0.0f) {
            RWRayBuffer[int3(_29, _30, 0)] = float4(1.0f, 0.0f, 0.0f, _439);  // Red = binding fail
          } else {
            RWRayBuffer[int3(_29, _30, 0)] = float4(0.0f, _dbg_sample.x, 0.0f, _439);  // Green = IS-FAST active
          }
        } else {
          RWRayBuffer[int3(_29, _30, 0)] = float4(0.8f, 0.8f, 0.0f, _439);  // Yellow = original path
        }
      } else {
        RWRayBuffer[int3(_29, _30, 0)] = float4((_258 - _432), (_259 - _433), (_260 - _434), _439);
      }
      _449 = 1.0f - (1.0f / float((uint)(asint(_RootShaderParameters_raw[28u].x) * asint(_RootShaderParameters_raw[28u].x))));
      _450 = abs(_449);
      _455 = (1.5707963705062866f - (_450 * 0.1565829962491989f)) * sqrt(1.0f - _450);
      _459 = select((_449 >= 0.0f), _455, (3.1415927410125732f - _455)) * asfloat(_RootShaderParameters_raw[3u].y);
      if (_439 > _459) {
        _464 = float((uint)(uint)(asint(_RootShaderParameters_raw[11u].z)));
        if (asint(_RootShaderParameters_raw[27u].w) == 0) {
          _537 = asint(_RootShaderParameters_raw[27u].w);
        } else {
          _480 = 0;
          while(true) {
            _482 = asfloat(_RootShaderParameters_raw[((uint)(_480 + 33u))]);
            _488 = asfloat(_RootShaderParameters_raw[((uint)(_480 + 39u))]);
            _492 = (_482.y * _230) + _488.x;
            _493 = (_482.y * _234) + _488.y;
            _494 = (_482.y * _238) + _488.z;
            _508 = float((uint)(uint)(asint(_RootShaderParameters_raw[27u].z)));
            float _ign_threshold;
            // Clipmap selection uses original IGN unconditionally — IS-FAST's
            // value distribution interacts badly with the `> threshold` test
            // when RadianceCache is enabled, producing black flicker from
            // invalid probe lookups. The noise quality here doesn't matter
            // (it's just dithering which clipmap level to pick), so keep IGN.
            _ign_threshold = frac(frac(dot(float2(((_464 * 32.665000915527344f) + float((uint)_29)), ((_464 * 11.8149995803833f) + float((uint)_30))), float2(0.0671105608344078f, 0.005837149918079376f))) * 52.98291778564453f);
            if (min(min(saturate((_492 + -0.5f) * asfloat(_RootShaderParameters_raw[26u].w)), min(saturate((_493 + -0.5f) * asfloat(_RootShaderParameters_raw[26u].w)), saturate((_494 + -0.5f) * asfloat(_RootShaderParameters_raw[26u].w)))), min(saturate(((-0.5f - _492) + _508) * asfloat(_RootShaderParameters_raw[26u].w)), min(saturate(((-0.5f - _493) + _508) * asfloat(_RootShaderParameters_raw[26u].w)), saturate(((-0.5f - _494) + _508) * asfloat(_RootShaderParameters_raw[26u].w))))) > _ign_threshold) {
              _537 = _480;
            } else {
              _528 = _480 + 1u;
              if ((uint)_528 < (uint)asint(_RootShaderParameters_raw[27u].w)) {
                _480 = _528;
                continue;
              } else {
                _537 = asint(_RootShaderParameters_raw[27u].w);
              }
            }
            break;
          }
        }
        if ((uint)_537 < (uint)asint(_RootShaderParameters_raw[27u].w)) {
          _543 = asfloat(_RootShaderParameters_raw[((uint)(_537 + 33u))]);
          _549 = asfloat(_RootShaderParameters_raw[((uint)(_537 + 39u))]);
          _562 = int(floor((_549.x + -0.5f) + (_543.y * _230)));
          _563 = int(floor((_549.y + -0.5f) + (_543.y * _234)));
          _564 = int(floor((_549.z + -0.5f) + (_543.y * _238)));
          _566 = asint(_RootShaderParameters_raw[27u].z) * _537;
          _567 = _566 + _562;
          _573 = (_562 + 1u) + _566;
          _577 = _563 + 1u;
          _586 = _564 + 1u;
          _610 = ((((((uint)(RadianceProbeIndirectionTexture.Load(int4(_567, _563, _564, 0)))).x) != -1) && (!(((((((((uint)(RadianceProbeIndirectionTexture.Load(int4(_573, _563, _564, 0)))).x) == -1) || ((((uint)(RadianceProbeIndirectionTexture.Load(int4(_567, _577, _564, 0)))).x) == -1)) || ((((uint)(RadianceProbeIndirectionTexture.Load(int4(_573, _577, _564, 0)))).x) == -1)) || ((((uint)(RadianceProbeIndirectionTexture.Load(int4(_567, _563, _586, 0)))).x) == -1)) || ((((uint)(RadianceProbeIndirectionTexture.Load(int4(_573, _563, _586, 0)))).x) == -1)) || ((((uint)(RadianceProbeIndirectionTexture.Load(int4(_567, _577, _586, 0)))).x) == -1)))) && ((((uint)(RadianceProbeIndirectionTexture.Load(int4(_573, _577, _586, 0)))).x) != -1));
          _611 = (_543.x + (_543.z * 1.7320507764816284f));
        } else {
          _610 = false;
          _611 = 1e+07f;
        }
        _612 = (int)(uint)(_610);
        if (_610) {
          _617 = asfloat(_RootShaderParameters_raw[3u].x) * 0.9900000095367432f;
          _623 = (((min(_611, _617) - _617) * saturate((_439 - _459) / _459)) + _617);
          _624 = _612;
        } else {
          _623 = asfloat(_RootShaderParameters_raw[3u].x);
          _624 = _612;
        }
      } else {
        _623 = asfloat(_RootShaderParameters_raw[3u].x);
        _624 = 0;
      }
      RWRayTraceDistance[int3(_29, _30, 0)] = (((int)(f32tof16(min(_623, 65504.0f))) & 32767) | (_624 << 15));
      _634 = _67;
    }
    RWDownsampledDepth[int3(_29, _30, 0)] = _634;
  }
}