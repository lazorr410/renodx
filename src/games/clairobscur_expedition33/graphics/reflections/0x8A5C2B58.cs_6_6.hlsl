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

struct FFogStructConstants {
  float4 ExponentialFogParameters;
  float4 ExponentialFogParameters2;
  float4 ExponentialFogColorParameter;
  float4 ExponentialFogParameters3;
  float4 SkyAtmosphereAmbientContributionColorScale;
  float4 InscatteringLightDirection;
  float4 DirectionalInscatteringColor;
  float2 SinCosInscatteringColorCubemapRotation;
  float Padding120;
  float Padding124;
  float3 FogInscatteringTextureParameters;
  float ApplyVolumetricFog;
  float VolumetricFogStartDistance;
  float VolumetricFogNearFadeInDistanceInv;
  uint BindlessSRV_FogInscatteringColorCubemap;
  uint Padding156;
  uint BindlessSampler_FogInscatteringColorSampler;
  uint Padding164;
  uint BindlessSRV_IntegratedLightScattering;
  uint Padding172;
  uint BindlessSampler_IntegratedLightScatteringSampler;
};

struct FLumenCardSceneConstants {
  uint NumCards;
  uint NumMeshCards;
  uint NumCardPages;
  uint NumHeightfields;
  uint NumPrimitiveGroups;
  uint Padding20;
  float2 PhysicalAtlasSize;
  float2 InvPhysicalAtlasSize;
  float IndirectLightingAtlasDownsampleFactor;
  float Padding44;
  uint BindlessSRV_CardData;
  uint Padding52;
  uint BindlessSRV_CardPageData;
  uint Padding60;
  uint BindlessSRV_MeshCardsData;
  uint Padding68;
  uint BindlessSRV_HeightfieldData;
  uint Padding76;
  uint BindlessSRV_PrimitiveGroupData;
  uint Padding84;
  uint BindlessSRV_PageTableBuffer;
  uint Padding92;
  uint BindlessSRV_SceneInstanceIndexToMeshCardsIndexBuffer;
  uint Padding100;
  uint BindlessSRV_AlbedoAtlas;
  uint Padding108;
  uint BindlessSRV_OpacityAtlas;
  uint Padding116;
  uint BindlessSRV_NormalAtlas;
  uint Padding124;
  uint BindlessSRV_EmissiveAtlas;
  uint Padding132;
  uint BindlessSRV_DepthAtlas;
};

struct FPackedVirtualVoxelNodeDesc {
  float3 TranslatedWorldMinAABB;
  uint PackedPageIndexResolution;
  float3 TranslatedWorldMaxAABB;
  uint PageIndexOffset_VoxelWorldSize;
};

struct FReflectionStructConstants {
  float4 SkyLightParameters;
  uint BindlessSRV_SkyLightCubemap;
  uint Padding20;
  uint BindlessSampler_SkyLightCubemapSampler;
  uint Padding28;
  uint BindlessSRV_SkyLightBlendDestinationCubemap;
  uint Padding36;
  uint BindlessSampler_SkyLightBlendDestinationCubemapSampler;
  uint Padding44;
  uint BindlessSRV_ReflectionCubemap;
  uint Padding52;
  uint BindlessSampler_ReflectionCubemapSampler;
  uint Padding60;
  uint BindlessSRV_PreIntegratedGF;
  uint Padding68;
  uint BindlessSampler_PreIntegratedGFSampler;
};

struct FVirtualVoxelConstants {
  int3 PageCountResolution;
  float CPUMinVoxelWorldSize;
  int3 PageTextureResolution;
  uint PageCount;
  uint PageResolution;
  uint PageResolutionLog2;
  uint PageIndexCount;
  uint IndirectDispatchGroupSize;
  uint NodeDescCount;
  uint JitterMode;
  float DensityScale;
  float DensityScale_AO;
  float DensityScale_Shadow;
  float DensityScale_Transmittance;
  float DensityScale_Environment;
  float DensityScale_Raytracing;
  float DepthBiasScale_Shadow;
  float DepthBiasScale_Transmittance;
  float DepthBiasScale_Environment;
  float SteppingScale_Shadow;
  float SteppingScale_Transmittance;
  float SteppingScale_Environment;
  float SteppingScale_Raytracing;
  float HairCoveragePixelRadiusAtDepth1;
  float Raytracing_ShadowOcclusionThreshold;
  float Raytracing_SkyOcclusionThreshold;
  float Padding120;
  float Padding124;
  float3 TranslatedWorldOffset;
  float Padding140;
  float3 TranslatedWorldOffsetStereoCorrection;
  uint AllocationFeedbackEnable;
  uint BindlessSRV_AllocatedPageCountBuffer;
  uint Padding164;
  uint BindlessSRV_PageIndexBuffer;
  uint Padding172;
  uint BindlessSRV_PageIndexCoordBuffer;
  uint Padding180;
  uint BindlessSRV_NodeDescBuffer;
  uint Padding188;
  uint BindlessSRV_CurrGPUMinVoxelSize;
  uint Padding196;
  uint BindlessSRV_NextGPUMinVoxelSize;
  float Padding204;
  uint BindlessSRV_PageTexture;
};


Texture2D<float4> View_DistantSkyLightLutTexture : register(t0);

StructuredBuffer<float4> LumenCardScene_CardData : register(t1);

StructuredBuffer<float4> LumenCardScene_MeshCardsData : register(t2);

ByteAddressBuffer LumenCardScene_PageTableBuffer : register(t3);

ByteAddressBuffer LumenCardScene_SceneInstanceIndexToMeshCardsIndexBuffer : register(t4);

TextureCube<float4> ReflectionStruct_SkyLightCubemap : register(t5);

TextureCube<float4> FogStruct_FogInscatteringColorCubemap : register(t6);

Buffer<uint> VirtualVoxel_PageIndexBuffer : register(t7);

StructuredBuffer<FPackedVirtualVoxelNodeDesc> VirtualVoxel_NodeDescBuffer : register(t8);

Texture3D<uint> VirtualVoxel_PageTexture : register(t9);

Texture2D<float4> FinalLightingAtlas : register(t10);

Texture2D<float4> DepthAtlas : register(t11);

ByteAddressBuffer DistanceFieldIndirectionTable : register(t12);

Texture3D<float4> DistanceFieldBrickTexture : register(t13);

StructuredBuffer<float4> SceneDistanceFieldAssetData : register(t14);

StructuredBuffer<float4> SceneObjectData : register(t15);

Buffer<uint> NumGridCulledMeshSDFObjects : register(t16);

Buffer<uint> GridCulledMeshSDFObjectStartOffsetArray : register(t17);

Buffer<uint> GridCulledMeshSDFObjectIndicesArray : register(t18);

Texture2DArray<float4> DownsampledDepth : register(t19);

Texture2DArray<float4> RayBuffer : register(t20);

Texture2DArray<uint> RayTraceDistance : register(t21);

Buffer<uint> CompactedTraceTexelAllocator : register(t22);

Buffer<uint> CompactedTraceTexelData : register(t23);

RWStructuredBuffer<uint> RWCardPageHighResLastUsedBuffer : register(u0);

RWStructuredBuffer<uint> RWSurfaceCacheFeedbackBufferAllocator : register(u1);

RWStructuredBuffer<uint2> RWSurfaceCacheFeedbackBuffer : register(u2);

RWTexture2DArray<float> RWTraceHit : register(u3);

RWTexture2DArray<float3> RWTraceRadiance : register(u4);

cbuffer _RootShaderParameters : register(b0) {
  float SkylightLeaking : packoffset(c004.y);
  float SkylightLeakingRoughness : packoffset(c004.z);
  float InvFullSkylightLeakingDistance : packoffset(c004.w);
  uint SampleHeightFog : packoffset(c005.x);
  uint SurfaceCacheFeedbackBufferSize : packoffset(c009.x);
  uint SurfaceCacheFeedbackBufferTileWrapMask : packoffset(c009.y);
  uint2 SurfaceCacheFeedbackBufferTileJitter : packoffset(c009.z);
  float SurfaceCacheFeedbackResLevelBias : packoffset(c010.x);
  uint SurfaceCacheUpdateFrameIndex : packoffset(c010.y);
  float3 DistanceFieldUniqueDataBrickSize : packoffset(c023.x);
  uint3 DistanceFieldBrickAtlasMask : packoffset(c025.x);
  uint3 DistanceFieldBrickAtlasSizeLog2 : packoffset(c026.x);
  float3 DistanceFieldBrickAtlasHalfTexelSize : packoffset(c028.x);
  float3 DistanceFieldBrickOffsetToAtlasUVScale : packoffset(c029.x);
  float3 DistanceFieldUniqueDataBrickSizeInAtlasTexels : packoffset(c030.x);
  float MeshSDFNotCoveredExpandSurfaceScale : packoffset(c031.x);
  float MeshSDFNotCoveredMinStepScale : packoffset(c031.y);
  float MeshSDFDitheredTransparencyStepThreshold : packoffset(c031.z);
  uint CardGridPixelSizeShift : packoffset(c033.z);
  float3 CardGridZParams : packoffset(c034.x);
  uint3 CullGridSize : packoffset(c035.x);
  uint ReflectionDownsampleFactor : packoffset(c040.x);
  float MaxRayIntensity : packoffset(c041.z);
  uint UseHighResSurface : packoffset(c042.z);
  float CardTraceEndDistanceFromCamera : packoffset(c054.y);
  float MaxTraceDistance : packoffset(c055.z);
  float MaxMeshSDFTraceDistance : packoffset(c055.w);
  float SurfaceBias : packoffset(c056.x);
};

cbuffer View : register(b1) {
  FViewConstants View : packoffset(c000.x);
};

cbuffer LumenCardScene : register(b2) {
  FLumenCardSceneConstants LumenCardScene : packoffset(c000.x);
};

cbuffer ReflectionStruct : register(b3) {
  FReflectionStructConstants ReflectionStruct : packoffset(c000.x);
};

cbuffer FogStruct : register(b4) {
  FFogStructConstants FogStruct : packoffset(c000.x);
};

cbuffer VirtualVoxel : register(b5) {
  FVirtualVoxelConstants VirtualVoxel : packoffset(c000.x);
};

SamplerState D3DStaticPointClampedSampler : register(s1, space1000);

SamplerState D3DStaticBilinearWrappedSampler : register(s2, space1000);

SamplerState View_DistantSkyLightLutTextureSampler : register(s0);

SamplerState ReflectionStruct_SkyLightCubemapSampler : register(s1);

SamplerState FogStruct_FogInscatteringColorSampler : register(s2);

// DXIL FirstbitHi: returns bit position counting from MSB (leading zeros count)
uint firstbithigh_msb(int value) { return (value == 0) ? 0xFFFFFFFF : (31u - firstbithigh(value)); }
uint firstbithigh_msb(uint value) { return (value == 0) ? 0xFFFFFFFF : (31u - firstbithigh(value)); }

[numthreads(32, 1, 1)]
void main(
  uint3 SV_DispatchThreadID : SV_DispatchThreadID,
  uint3 SV_GroupID : SV_GroupID,
  uint3 SV_GroupThreadID : SV_GroupThreadID,
  uint SV_GroupIndex : SV_GroupIndex
) {
  int _239;
  int _240;
  float _241;
  float _407;
  int _408;
  float _409;
  float _488;
  int _510;
  float _512;
  int _513;
  bool _514;
  int _533;
  float _534;
  int _539;
  float _540;
  float _733;
  float _797;
  float _866;
  float _931;
  float _997;
  float _1063;
  float _1079;
  float _1080;
  float _1081;
  float _1103;
  float _1104;
  float _1105;
  int _1204;
  int _1213;
  int _1222;
  int _1226;
  int _1227;
  int _1269;
  int _1274;
  int _1275;
  int _1276;
  float _1277;
  float _1278;
  float _1279;
  float _1280;
  float _1281;
  int _1282;
  int _1297;
  int _1298;
  int _1299;
  float _1300;
  float _1301;
  float _1302;
  float _1303;
  float _1304;
  float _1526;
  float _1552;
  int _1591;
  int _1592;
  int _1593;
  float _1594;
  float _1595;
  float _1596;
  float _1597;
  float _1630;
  float _1631;
  float _1632;
  float _1633;
  float _1634;
  float _1694;
  float _1695;
  float _1696;
  int _1718;
  int _1719;
  float _1720;
  float _1721;
  int _1822;
  int _1823;
  int _1824;
  int _1825;
  int _1826;
  int _1827;
  int _1828;
  float _1829;
  float _1830;
  float _1831;
  int _1905;
  int _1906;
  int _1907;
  int _1908;
  int _1909;
  int _1910;
  int _1911;
  float _1955;
  float _1963;
  float _1964;
  float _1972;
  float _1973;
  int _1974;
  int _1981;
  float _1982;
  float _1983;
  float _1994;
  float _1995;
  float _1996;
  float _1997;
  float _1998;
  float _2036;
  float _2114;
  float _2145;
  float _2146;
  float _2147;
  float _2148;
  float _2217;
  float _2218;
  float _2219;
  float _2304;
  float _2305;
  float _2306;
  float _2318;
  float _2319;
  float _2320;
  float _2352;
  float _2353;
  float _2354;
  float _2393;
  float _2394;
  float _2395;
  float _2413;
  float _2414;
  float _2415;
  float _2439;
  float _2451;
  float _2463;
  uint _55;
  int _57;
  int _59;
  uint _66;
  uint _67;
  float4 _92;
  float _101;
  float _102;
  bool _130;
  float _131;
  float _132;
  float _136;
  float _140;
  float _144;
  float4 _174;
  float _183;
  float _189;
  float _190;
  float _191;
  float _196;
  bool _200;
  int _219;
  uint _227;
  uint _229;
  uint _244;
  uint _246;
  float _249;
  float _250;
  float _251;
  float _254;
  float _255;
  float _256;
  float _257;
  float _260;
  float _261;
  float _262;
  float _263;
  float _266;
  float _267;
  float _268;
  float _269;
  float _272;
  float _273;
  float _274;
  float _275;
  float _276;
  float _279;
  float _280;
  float _281;
  float _282;
  float _283;
  float _284;
  float _298;
  float _302;
  float _303;
  float _304;
  float _307;
  float _308;
  float _311;
  float _312;
  float _315;
  float _316;
  float _326;
  float _327;
  float _328;
  float _334;
  float _337;
  float _338;
  float _339;
  float _343;
  float _344;
  float _345;
  float _349;
  float _350;
  float _351;
  float _355;
  float _356;
  float _357;
  float _371;
  float _372;
  float _375;
  uint _377;
  float _380;
  uint _385;
  float _387;
  float _388;
  int _389;
  float _393;
  float _394;
  float _395;
  float _396;
  float _399;
  float _400;
  float _401;
  float _402;
  float _419;
  float _420;
  float _421;
  int _422;
  int _423;
  int _424;
  int _433;
  float _489;
  float _490;
  float _494;
  float _503;
  int _507;
  float _519;
  float _521;
  float _523;
  float _529;
  uint _535;
  uint _543;
  float _546;
  float _547;
  float _548;
  float _551;
  float _552;
  float _553;
  float _554;
  float _557;
  float _558;
  float _559;
  float _560;
  float _563;
  float _564;
  float _565;
  float _566;
  float _569;
  float _570;
  float _571;
  float _574;
  float _578;
  float _580;
  float _581;
  float _582;
  float _598;
  float _599;
  float _600;
  float _619;
  float _620;
  float _621;
  uint _622;
  float _625;
  uint _630;
  float _632;
  float _633;
  int _634;
  int _635;
  float _638;
  float _639;
  float _640;
  float _641;
  float _644;
  float _645;
  float _646;
  int _647;
  int _649;
  float _657;
  float _658;
  float _659;
  float _664;
  float _665;
  float _666;
  int _667;
  int _668;
  int _669;
  uint _670;
  uint _672;
  int _678;
  float _736;
  int _737;
  int _742;
  float _801;
  float _802;
  int _803;
  int _804;
  uint _807;
  int _811;
  float _869;
  int _870;
  int _876;
  float _934;
  int _935;
  int _942;
  float _1000;
  int _1001;
  int _1008;
  float _1064;
  float _1065;
  float _1066;
  float _1072;
  float _1084;
  float _1087;
  float _1090;
  float _1096;
  int _1109;
  uint _1115;
  float _1118;
  float _1119;
  float _1120;
  float _1123;
  float _1124;
  float _1125;
  float _1126;
  float _1129;
  float _1130;
  float _1131;
  float _1132;
  float _1135;
  float _1136;
  float _1137;
  float _1138;
  float _1141;
  float _1142;
  float _1143;
  float _1144;
  int _1145;
  int _1146;
  float _1149;
  float _1150;
  float _1151;
  float _1152;
  bool _1154;
  float _1169;
  float _1171;
  float _1173;
  float _1175;
  float _1178;
  float _1181;
  float _1184;
  float _1187;
  float _1190;
  float _1193;
  float _1194;
  float _1195;
  float _1196;
  int _1228;
  uint _1230;
  uint _1233;
  float _1237;
  float _1240;
  float _1243;
  float _1246;
  float _1247;
  float _1248;
  float _1255;
  int _1265;
  int _1270;
  int _1283;
  uint _1285;
  uint _1287;
  uint _1288;
  float _1292;
  int _1293;
  float _1311;
  float _1312;
  float _1313;
  float _1322;
  float _1323;
  float _1324;
  int _1326;
  float _1327;
  float _1328;
  float _1329;
  float _1330;
  float _1331;
  float _1332;
  float _1333;
  float _1334;
  float _1335;
  float _1336;
  float _1337;
  float _1338;
  float _1339;
  float _1340;
  float _1341;
  float _1344;
  float _1347;
  float _1350;
  float _1354;
  float _1367;
  float _1368;
  float _1369;
  float _1370;
  float _1385;
  float _1386;
  int _1388;
  int _1389;
  int _1405;
  int _1406;
  int _1412;
  int _1413;
  bool _1420;
  bool _1421;
  int _1422;
  int _1423;
  float _1426;
  float _1427;
  uint _1428;
  uint _1429;
  float _1436;
  float _1437;
  float _1443;
  float _1445;
  float _1469;
  float _1470;
  uint _1480;
  uint _1481;
  uint _1482;
  float _1510;
  float _1511;
  float _1512;
  float _1515;
  float4 _1531;
  float _1538;
  float _1539;
  float _1540;
  bool _1541;
  bool _1553;
  float _1557;
  float _1558;
  float _1559;
  float _1560;
  float4 _1562;
  float4 _1567;
  float4 _1572;
  float _1583;
  float _1584;
  float _1585;
  float _1586;
  float _1600;
  float _1601;
  float _1602;
  int _1619;
  float _1635;
  int _1644;
  uint _1645;
  uint _1646;
  uint _1649;
  uint _1650;
  uint _1652;
  uint _1654;
  uint _1656;
  uint _1658;
  uint _1660;
  uint _1662;
  uint _1664;
  float _1676;
  float _1724;
  float _1725;
  float _1726;
  int _1728;
  float _1730;
  float _1731;
  float _1732;
  int _1734;
  int _1737;
  int _1739;
  int _1741;
  uint _1742;
  uint _1743;
  uint _1744;
  float _1747;
  float _1748;
  float _1754;
  float _1755;
  float _1756;
  float _1757;
  float _1758;
  float _1759;
  float _1760;
  float _1762;
  float _1763;
  float _1764;
  float _1765;
  float _1766;
  float _1767;
  float _1771;
  float _1772;
  float _1773;
  float _1777;
  float _1778;
  float _1779;
  float _1790;
  float _1791;
  float _1801;
  float _1803;
  float _1805;
  float _1812;
  float _1814;
  float _1817;
  float _1833;
  float _1849;
  float _1850;
  float _1851;
  int _1876;
  int _1877;
  int _1878;
  int _1879;
  int _1880;
  int _1881;
  int _1882;
  uint _1895;
  uint _1899;
  uint _1900;
  uint _1928;
  int _1929;
  float _1942;
  float _1945;
  float _1946;
  float _1947;
  float _1958;
  float _1959;
  uint _1975;
  float _2001;
  float _2002;
  float _2003;
  float _2013;
  float _2015;
  float _2017;
  float _2023;
  float _2054;
  float _2057;
  float _2058;
  float _2065;
  float _2068;
  float _2069;
  float _2071;
  float _2072;
  float _2073;
  float _2074;
  float _2075;
  float _2106;
  float _2116;
  float _2121;
  float _2122;
  float _2123;
  float _2150;
  float _2162;
  float _2173;
  float _2186;
  float _2191;
  float _2192;
  float4 _2195;
  float4 _2200;
  float4 _2231;
  float _2255;
  float _2271;
  float _2272;
  float _2273;
  float _2274;
  float _2296;
  float _2313;
  bool _2329;
  float _2333;
  float _2334;
  float _2344;
  float4 _2374;
  float _2388;
  float _2399;
  float _2400;
  float _2401;
  float _2403;
  float _2408;
  bool _2440;
  bool _2452;
  float _2464;
  float _2465;
  float _2466;
  float _2467;
  float _2468;
  float _2469;
  int __loop_jump_target = -1;
  int _48[6];
  if ((uint)(int)(SV_DispatchThreadID.x) < (uint)(((uint)(CompactedTraceTexelAllocator.Load(0))).x)) {
    _55 = CompactedTraceTexelData.Load((int)(SV_DispatchThreadID.x));
    _57 = _55.x & 4095;
    _59 = ((uint)((uint)(_55.x)) >> 12) & 4095;
    _66 = ReflectionDownsampleFactor * _57;
    _67 = ReflectionDownsampleFactor * _59;
    _92 = DownsampledDepth.Load(int4(_57, _59, 0, 0));
    _101 = ((View.BufferSizeAndInvSize.z * min(((View.ViewRectMin.x + 0.5f) + float((uint)_66)), ((View.ViewRectMin.x + -1.0f) + View.ViewSizeAndInvSize.x))) - View.ScreenPositionScaleBias.w) / View.ScreenPositionScaleBias.x;
    _102 = ((View.BufferSizeAndInvSize.w * min(((View.ViewRectMin.y + 0.5f) + float((uint)_67)), ((View.ViewRectMin.y + -1.0f) + View.ViewSizeAndInvSize.y))) - View.ScreenPositionScaleBias.z) / View.ScreenPositionScaleBias.y;
    _130 = ((View.ViewToClip[3].w) >= 1.0f);
    _131 = select(_130, _101, (_101 * _92.x));
    _132 = select(_130, _102, (_102 * _92.x));
    _136 = (View.ViewOriginHigh.x + (View.ScreenToRelativeWorld[3].x)) + mad(_92.x, (View.ScreenToRelativeWorld[2].x), mad(_132, (View.ScreenToRelativeWorld[1].x), (_131 * (View.ScreenToRelativeWorld[0].x))));
    _140 = (View.ViewOriginHigh.y + (View.ScreenToRelativeWorld[3].y)) + mad(_92.x, (View.ScreenToRelativeWorld[2].y), mad(_132, (View.ScreenToRelativeWorld[1].y), (_131 * (View.ScreenToRelativeWorld[0].y))));
    _144 = (View.ViewOriginHigh.z + (View.ScreenToRelativeWorld[3].z)) + mad(_92.x, (View.ScreenToRelativeWorld[2].z), mad(_132, (View.ScreenToRelativeWorld[1].z), (_131 * (View.ScreenToRelativeWorld[0].z))));
    _174 = RayBuffer.Load(int4(_57, _59, 0, 0));
    _183 = f16tof32(((uint)((((uint)(RayTraceDistance.Load(int4(_57, _59, 0, 0)))).x) & 32767)));
    _189 = (SurfaceBias * _174.x) + _136;
    _190 = (SurfaceBias * _174.y) + _140;
    _191 = (SurfaceBias * _174.z) + _144;
    _196 = max((abs((RWTraceHit.Load(int3(_57, _59, 0))).x) - SurfaceBias), 0.0f);
    _200 = (UseHighResSurface != 0);
    _219 = CardGridPixelSizeShift & 31;
    _227 = (((int)((CullGridSize.y * ((int)min((uint)((int)(uint(max(0.0f, (CardGridZParams.z * log2((CardGridZParams.x * _92.x) + CardGridZParams.y)))))), (uint)(((int)((uint)(CullGridSize.z) + (uint)(-1))))))) + ((uint)((uint)(_67) >> _219)))) * CullGridSize.x) + ((uint)((uint)(_66) >> _219));
    _229 = NumGridCulledMeshSDFObjects.Load(_227);
    if (MaxMeshSDFTraceDistance > _196) {
      if (!(_229.x == 0)) {
        _239 = 0;
        _240 = 0;
        _241 = MaxMeshSDFTraceDistance;
        while(true) {
          _533 = _240;
          _534 = _241;
          _244 = GridCulledMeshSDFObjectIndicesArray.Load((int)(_239 + ((uint)(((uint)(GridCulledMeshSDFObjectStartOffsetArray.Load(_227))).x))));
          _246 = _244.x * 10;
          _249 = SceneObjectData[_246].x;
          _250 = SceneObjectData[_246].y;
          _251 = SceneObjectData[_246].z;
          _254 = SceneObjectData[(_246 | 1)].x;
          _255 = SceneObjectData[(_246 | 1)].y;
          _256 = SceneObjectData[(_246 | 1)].z;
          _257 = SceneObjectData[(_246 | 1)].w;
          _260 = SceneObjectData[((int)(_246 + 2u))].x;
          _261 = SceneObjectData[((int)(_246 + 2u))].y;
          _262 = SceneObjectData[((int)(_246 + 2u))].z;
          _263 = SceneObjectData[((int)(_246 + 2u))].w;
          _266 = SceneObjectData[((int)(_246 + 3u))].x;
          _267 = SceneObjectData[((int)(_246 + 3u))].y;
          _268 = SceneObjectData[((int)(_246 + 3u))].z;
          _269 = SceneObjectData[((int)(_246 + 3u))].w;
          _272 = SceneObjectData[((int)(_246 + 4u))].x;
          _273 = SceneObjectData[((int)(_246 + 4u))].y;
          _274 = SceneObjectData[((int)(_246 + 4u))].z;
          _275 = SceneObjectData[((int)(_246 + 4u))].w;
          _276 = abs(_275);
          _279 = SceneObjectData[((int)(_246 + 9u))].x;
          _280 = SceneObjectData[((int)(_246 + 9u))].y;
          _281 = SceneObjectData[((int)(_246 + 9u))].z;
          _282 = -0.0f - _249;
          _283 = -0.0f - _250;
          _284 = -0.0f - _251;
          _298 = min(MaxMeshSDFTraceDistance, (_276 + _241));
          _302 = (_298 * _174.x) + _189;
          _303 = (_298 * _174.y) + _190;
          _304 = (_298 * _174.z) + _191;
          _307 = mad(_191, _256, mad(_190, _255, (_254 * _189)));
          _308 = (mad(_284, _256, mad(_283, _255, (_254 * _282))) + _257) + _307;
          _311 = mad(_191, _262, mad(_190, _261, (_260 * _189)));
          _312 = (mad(_284, _262, mad(_283, _261, (_260 * _282))) + _263) + _311;
          _315 = mad(_191, _268, mad(_190, _267, (_266 * _189)));
          _316 = (mad(_284, _268, mad(_283, _267, (_266 * _282))) + _269) + _315;
          _326 = mad(_304, _256, mad(_303, _255, (_302 * _254))) - _307;
          _327 = mad(_304, _262, mad(_303, _261, (_302 * _260))) - _311;
          _328 = mad(_304, _268, mad(_303, _267, (_302 * _266))) - _315;
          _334 = sqrt(((_327 * _327) + (_326 * _326)) + (_328 * _328));
          _337 = _326 / _334;
          _338 = _327 / _334;
          _339 = _328 / _334;
          _343 = 1.0f / _326;
          _344 = 1.0f / _327;
          _345 = 1.0f / _328;
          _349 = _343 * ((-0.0f - _272) - _308);
          _350 = _344 * ((-0.0f - _273) - _312);
          _351 = _345 * ((-0.0f - _274) - _316);
          _355 = _343 * (_272 - _308);
          _356 = _344 * (_273 - _312);
          _357 = _345 * (_274 - _316);
          _371 = saturate(min(max(_349, _355), min(max(_350, _356), max(_351, _357)))) * _334;
          _372 = max((saturate(max(min(_349, _355), max(min(_350, _356), min(_351, _357)))) * _334), ((_196 / _298) * _334));
          [branch]
          if (_372 < _371) {
            _375 = SceneObjectData[((int)(_246 + 9u))].w;
            _377 = asint(_375) * 9;
            _380 = SceneDistanceFieldAssetData[_377].x;
            _385 = (_377 + (uint)(-3)) + ((uint)(((uint)((uint)(asint(_380))) >> 30) * 3));
            _387 = SceneDistanceFieldAssetData[_385].x;
            _388 = SceneDistanceFieldAssetData[_385].y;
            _389 = asint(_387);
            _393 = SceneDistanceFieldAssetData[((int)(_385 + 1u))].x;
            _394 = SceneDistanceFieldAssetData[((int)(_385 + 1u))].y;
            _395 = SceneDistanceFieldAssetData[((int)(_385 + 1u))].z;
            _396 = SceneDistanceFieldAssetData[((int)(_385 + 1u))].w;
            _399 = SceneDistanceFieldAssetData[((int)(_385 + 2u))].x;
            _400 = SceneDistanceFieldAssetData[((int)(_385 + 2u))].y;
            _401 = SceneDistanceFieldAssetData[((int)(_385 + 2u))].z;
            _402 = SceneDistanceFieldAssetData[((int)(_385 + 2u))].w;
            _407 = _372;
            _408 = 0;
            _409 = 0.0f;
            while(true) {
              _419 = (((_407 * _337) + _308) * _393) + _399;
              _420 = (((_407 * _338) + _312) * _394) + _400;
              _421 = (((_407 * _339) + _316) * _395) + _401;
              _422 = int(_419);
              _423 = int(_420);
              _424 = int(_421);
              _433 = asint(DistanceFieldIndirectionTable.Load(((int)(((int)((_422 + (uint)(asint(_388))) + (((int)((_424 * (((uint)(_389) >> 10) & 1023)) + _423)) * (_389 & 1023)))) << 2))));
              if (!(_433 == -1)) {
                _488 = ((((float4)(DistanceFieldBrickTexture.SampleLevel(D3DStaticBilinearWrappedSampler, float3((((DistanceFieldUniqueDataBrickSizeInAtlasTexels.x * (_419 - float((int)(_422)))) + (DistanceFieldBrickOffsetToAtlasUVScale.x * float((uint)((uint)(DistanceFieldBrickAtlasMask.x & _433))))) + DistanceFieldBrickAtlasHalfTexelSize.x), (((DistanceFieldUniqueDataBrickSizeInAtlasTexels.y * (_420 - float((int)(_423)))) + (float((uint)((uint)(((uint)(_433) >> (DistanceFieldBrickAtlasSizeLog2.x & 31)) & DistanceFieldBrickAtlasMask.y))) * DistanceFieldBrickOffsetToAtlasUVScale.y)) + DistanceFieldBrickAtlasHalfTexelSize.y), ((DistanceFieldBrickAtlasHalfTexelSize.z + (DistanceFieldUniqueDataBrickSizeInAtlasTexels.z * (_421 - float((int)(_424))))) + (float((uint)((uint)((uint)(_433) >> (((int)((uint)(DistanceFieldBrickAtlasSizeLog2.y) + (uint)(DistanceFieldBrickAtlasSizeLog2.x))) & 31)))) * DistanceFieldBrickOffsetToAtlasUVScale.z))), 0.0f))).x) * _396);
              } else {
                _488 = _396;
              }
              _489 = _402 + _488;
              _490 = max(_489, _409);
              _494 = saturate(_490 / (_276 * 2.0f)) * _276;
              if (_489 < _494) {
                _512 = min(max(((_489 + _407) - _494), _372), _371);
                _513 = _408;
                _514 = true;
              } else {
                _503 = max(_489, 0.0009765625f) + _407;
                if (_503 > (_494 + _371)) {
                  _510 = _408;
                  _512 = _503;
                  _513 = _510;
                  _514 = false;
                } else {
                  _507 = _408 + 1;
                  if ((uint)_507 < (uint)64) {
                    _407 = _503;
                    _408 = _507;
                    _409 = _490;
                    continue;
                  } else {
                    _510 = _507;
                    _512 = _503;
                    _513 = _510;
                    _514 = false;
                  }
                }
              }
              if ((_513 == 64) || _514) {
                _519 = (_337 * _279) * _512;
                _521 = (_338 * _280) * _512;
                _523 = (_339 * _281) * _512;
                _529 = sqrt(((_519 * _519) + (_521 * _521)) + (_523 * _523));
                if (_529 < _241) {
                  _533 = _244.x;
                  _534 = _529;
                } else {
                  _533 = _240;
                  _534 = _241;
                }
              } else {
                _533 = _240;
                _534 = _241;
              }
              break;
            }
          } else {
            _533 = _240;
            _534 = _241;
          }
          _535 = _239 + 1u;
          if (!(_535 == _229.x)) {
            _239 = _535;
            _240 = _533;
            _241 = _534;
            continue;
          }
          _539 = _533;
          _540 = _534;
          break;
        }
      } else {
        _539 = 0;
        _540 = MaxMeshSDFTraceDistance;
      }
      if (_540 < MaxMeshSDFTraceDistance) {
        _543 = _539 * 10;
        _546 = SceneObjectData[_543].x;
        _547 = SceneObjectData[_543].y;
        _548 = SceneObjectData[_543].z;
        _551 = SceneObjectData[(_543 | 1)].x;
        _552 = SceneObjectData[(_543 | 1)].y;
        _553 = SceneObjectData[(_543 | 1)].z;
        _554 = SceneObjectData[(_543 | 1)].w;
        _557 = SceneObjectData[((int)(_543 + 2u))].x;
        _558 = SceneObjectData[((int)(_543 + 2u))].y;
        _559 = SceneObjectData[((int)(_543 + 2u))].z;
        _560 = SceneObjectData[((int)(_543 + 2u))].w;
        _563 = SceneObjectData[((int)(_543 + 3u))].x;
        _564 = SceneObjectData[((int)(_543 + 3u))].y;
        _565 = SceneObjectData[((int)(_543 + 3u))].z;
        _566 = SceneObjectData[((int)(_543 + 3u))].w;
        _569 = SceneObjectData[((int)(_543 + 4u))].x;
        _570 = SceneObjectData[((int)(_543 + 4u))].y;
        _571 = SceneObjectData[((int)(_543 + 4u))].z;
        _574 = SceneObjectData[((int)(_543 + 5u))].w;
        _578 = SceneObjectData[((int)(_543 + 9u))].w;
        _580 = -0.0f - _546;
        _581 = -0.0f - _547;
        _582 = -0.0f - _548;
        _598 = (_540 * _174.x) + _189;
        _599 = (_540 * _174.y) + _190;
        _600 = (_540 * _174.z) + _191;
        _619 = min(max(((mad(_582, _553, mad(_581, _552, (_551 * _580))) + _554) + mad(_600, _553, mad(_599, _552, (_551 * _598)))), (-0.0f - _569)), _569);
        _620 = min(max(((mad(_582, _559, mad(_581, _558, (_557 * _580))) + _560) + mad(_600, _559, mad(_599, _558, (_557 * _598)))), (-0.0f - _570)), _570);
        _621 = min(max(((mad(_582, _565, mad(_581, _564, (_563 * _580))) + _566) + mad(_600, _565, mad(_599, _564, (_563 * _598)))), (-0.0f - _571)), _571);
        _622 = asint(_578) * 9;
        _625 = SceneDistanceFieldAssetData[_622].x;
        _630 = (_622 + (uint)(-3)) + ((uint)(((uint)((uint)(asint(_625))) >> 30) * 3));
        _632 = SceneDistanceFieldAssetData[_630].x;
        _633 = SceneDistanceFieldAssetData[_630].y;
        _634 = asint(_632);
        _635 = asint(_633);
        _638 = SceneDistanceFieldAssetData[((int)(_630 + 1u))].x;
        _639 = SceneDistanceFieldAssetData[((int)(_630 + 1u))].y;
        _640 = SceneDistanceFieldAssetData[((int)(_630 + 1u))].z;
        _641 = SceneDistanceFieldAssetData[((int)(_630 + 1u))].w;
        _644 = SceneDistanceFieldAssetData[((int)(_630 + 2u))].x;
        _645 = SceneDistanceFieldAssetData[((int)(_630 + 2u))].y;
        _646 = SceneDistanceFieldAssetData[((int)(_630 + 2u))].z;
        _647 = _634 & 1023;
        _649 = ((uint)(_634) >> 10) & 1023;
        _657 = 0.5f / (DistanceFieldUniqueDataBrickSize.x * _638);
        _658 = 0.5f / (DistanceFieldUniqueDataBrickSize.y * _639);
        _659 = 0.5f / (DistanceFieldUniqueDataBrickSize.z * _640);
        _664 = ((_657 + _619) * _638) + _644;
        _665 = _645 + (_639 * _620);
        _666 = _646 + (_640 * _621);
        _667 = int(_664);
        _668 = int(_665);
        _669 = int(_666);
        _670 = _669 * _649;
        _672 = ((int)(_670 + _668)) * _647;
        _678 = asint(DistanceFieldIndirectionTable.Load(((int)(((int)((_667 + _635) + _672)) << 2))));
        if (!(_678 == -1)) {
          _733 = ((((float4)(DistanceFieldBrickTexture.SampleLevel(D3DStaticBilinearWrappedSampler, float3((((DistanceFieldUniqueDataBrickSizeInAtlasTexels.x * (_664 - float((int)(_667)))) + (DistanceFieldBrickOffsetToAtlasUVScale.x * float((uint)((uint)(DistanceFieldBrickAtlasMask.x & _678))))) + DistanceFieldBrickAtlasHalfTexelSize.x), (((DistanceFieldUniqueDataBrickSizeInAtlasTexels.y * (_665 - float((int)(_668)))) + (float((uint)((uint)(((uint)(_678) >> (DistanceFieldBrickAtlasSizeLog2.x & 31)) & DistanceFieldBrickAtlasMask.y))) * DistanceFieldBrickOffsetToAtlasUVScale.y)) + DistanceFieldBrickAtlasHalfTexelSize.y), ((DistanceFieldBrickAtlasHalfTexelSize.z + (DistanceFieldUniqueDataBrickSizeInAtlasTexels.z * (_666 - float((int)(_669))))) + (float((uint)((uint)((uint)(_678) >> (((int)((uint)(DistanceFieldBrickAtlasSizeLog2.y) + (uint)(DistanceFieldBrickAtlasSizeLog2.x))) & 31)))) * DistanceFieldBrickOffsetToAtlasUVScale.z))), 0.0f))).x) * _641);
        } else {
          _733 = _641;
        }
        _736 = ((_619 - _657) * _638) + _644;
        _737 = int(_736);
        _742 = asint(DistanceFieldIndirectionTable.Load(((int)(((int)((_737 + _635) + _672)) << 2))));
        if (!(_742 == -1)) {
          _797 = ((((float4)(DistanceFieldBrickTexture.SampleLevel(D3DStaticBilinearWrappedSampler, float3((((DistanceFieldUniqueDataBrickSizeInAtlasTexels.x * (_736 - float((int)(_737)))) + (DistanceFieldBrickOffsetToAtlasUVScale.x * float((uint)((uint)(DistanceFieldBrickAtlasMask.x & _742))))) + DistanceFieldBrickAtlasHalfTexelSize.x), (((DistanceFieldUniqueDataBrickSizeInAtlasTexels.y * (_665 - float((int)(_668)))) + (float((uint)((uint)(((uint)(_742) >> (DistanceFieldBrickAtlasSizeLog2.x & 31)) & DistanceFieldBrickAtlasMask.y))) * DistanceFieldBrickOffsetToAtlasUVScale.y)) + DistanceFieldBrickAtlasHalfTexelSize.y), ((DistanceFieldBrickAtlasHalfTexelSize.z + (DistanceFieldUniqueDataBrickSizeInAtlasTexels.z * (_666 - float((int)(_669))))) + (float((uint)((uint)((uint)(_742) >> (((int)((uint)(DistanceFieldBrickAtlasSizeLog2.y) + (uint)(DistanceFieldBrickAtlasSizeLog2.x))) & 31)))) * DistanceFieldBrickOffsetToAtlasUVScale.z))), 0.0f))).x) * _641);
        } else {
          _797 = _641;
        }
        _801 = _644 + (_638 * _619);
        _802 = ((_658 + _620) * _639) + _645;
        _803 = int(_801);
        _804 = int(_802);
        _807 = _803 + _635;
        _811 = asint(DistanceFieldIndirectionTable.Load(((int)(((int)(_807 + (((int)(_804 + _670)) * _647))) << 2))));
        if (!(_811 == -1)) {
          _866 = ((((float4)(DistanceFieldBrickTexture.SampleLevel(D3DStaticBilinearWrappedSampler, float3((((DistanceFieldUniqueDataBrickSizeInAtlasTexels.x * (_801 - float((int)(_803)))) + (DistanceFieldBrickOffsetToAtlasUVScale.x * float((uint)((uint)(DistanceFieldBrickAtlasMask.x & _811))))) + DistanceFieldBrickAtlasHalfTexelSize.x), (((DistanceFieldUniqueDataBrickSizeInAtlasTexels.y * (_802 - float((int)(_804)))) + (float((uint)((uint)(((uint)(_811) >> (DistanceFieldBrickAtlasSizeLog2.x & 31)) & DistanceFieldBrickAtlasMask.y))) * DistanceFieldBrickOffsetToAtlasUVScale.y)) + DistanceFieldBrickAtlasHalfTexelSize.y), ((DistanceFieldBrickAtlasHalfTexelSize.z + (DistanceFieldUniqueDataBrickSizeInAtlasTexels.z * (_666 - float((int)(_669))))) + (float((uint)((uint)((uint)(_811) >> (((int)((uint)(DistanceFieldBrickAtlasSizeLog2.y) + (uint)(DistanceFieldBrickAtlasSizeLog2.x))) & 31)))) * DistanceFieldBrickOffsetToAtlasUVScale.z))), 0.0f))).x) * _641);
        } else {
          _866 = _641;
        }
        _869 = ((_620 - _658) * _639) + _645;
        _870 = int(_869);
        _876 = asint(DistanceFieldIndirectionTable.Load(((int)(((int)(_807 + (((int)(_870 + _670)) * _647))) << 2))));
        if (!(_876 == -1)) {
          _931 = ((((float4)(DistanceFieldBrickTexture.SampleLevel(D3DStaticBilinearWrappedSampler, float3((((DistanceFieldUniqueDataBrickSizeInAtlasTexels.x * (_801 - float((int)(_803)))) + (DistanceFieldBrickOffsetToAtlasUVScale.x * float((uint)((uint)(DistanceFieldBrickAtlasMask.x & _876))))) + DistanceFieldBrickAtlasHalfTexelSize.x), (((DistanceFieldUniqueDataBrickSizeInAtlasTexels.y * (_869 - float((int)(_870)))) + (float((uint)((uint)(((uint)(_876) >> (DistanceFieldBrickAtlasSizeLog2.x & 31)) & DistanceFieldBrickAtlasMask.y))) * DistanceFieldBrickOffsetToAtlasUVScale.y)) + DistanceFieldBrickAtlasHalfTexelSize.y), ((DistanceFieldBrickAtlasHalfTexelSize.z + (DistanceFieldUniqueDataBrickSizeInAtlasTexels.z * (_666 - float((int)(_669))))) + (float((uint)((uint)((uint)(_876) >> (((int)((uint)(DistanceFieldBrickAtlasSizeLog2.y) + (uint)(DistanceFieldBrickAtlasSizeLog2.x))) & 31)))) * DistanceFieldBrickOffsetToAtlasUVScale.z))), 0.0f))).x) * _641);
        } else {
          _931 = _641;
        }
        _934 = ((_659 + _621) * _640) + _646;
        _935 = int(_934);
        _942 = asint(DistanceFieldIndirectionTable.Load(((int)(((int)(_807 + (((int)((_935 * _649) + _668)) * _647))) << 2))));
        if (!(_942 == -1)) {
          _997 = ((((float4)(DistanceFieldBrickTexture.SampleLevel(D3DStaticBilinearWrappedSampler, float3((((DistanceFieldUniqueDataBrickSizeInAtlasTexels.x * (_801 - float((int)(_803)))) + (DistanceFieldBrickOffsetToAtlasUVScale.x * float((uint)((uint)(DistanceFieldBrickAtlasMask.x & _942))))) + DistanceFieldBrickAtlasHalfTexelSize.x), (((DistanceFieldUniqueDataBrickSizeInAtlasTexels.y * (_665 - float((int)(_668)))) + (float((uint)((uint)(((uint)(_942) >> (DistanceFieldBrickAtlasSizeLog2.x & 31)) & DistanceFieldBrickAtlasMask.y))) * DistanceFieldBrickOffsetToAtlasUVScale.y)) + DistanceFieldBrickAtlasHalfTexelSize.y), ((DistanceFieldBrickAtlasHalfTexelSize.z + (DistanceFieldUniqueDataBrickSizeInAtlasTexels.z * (_934 - float((int)(_935))))) + (float((uint)((uint)((uint)(_942) >> (((int)((uint)(DistanceFieldBrickAtlasSizeLog2.y) + (uint)(DistanceFieldBrickAtlasSizeLog2.x))) & 31)))) * DistanceFieldBrickOffsetToAtlasUVScale.z))), 0.0f))).x) * _641);
        } else {
          _997 = _641;
        }
        _1000 = ((_621 - _659) * _640) + _646;
        _1001 = int(_1000);
        _1008 = asint(DistanceFieldIndirectionTable.Load(((int)(((int)(_807 + (((int)((_1001 * _649) + _668)) * _647))) << 2))));
        if (!(_1008 == -1)) {
          _1063 = ((((float4)(DistanceFieldBrickTexture.SampleLevel(D3DStaticBilinearWrappedSampler, float3((((DistanceFieldUniqueDataBrickSizeInAtlasTexels.x * (_801 - float((int)(_803)))) + (DistanceFieldBrickOffsetToAtlasUVScale.x * float((uint)((uint)(DistanceFieldBrickAtlasMask.x & _1008))))) + DistanceFieldBrickAtlasHalfTexelSize.x), (((DistanceFieldUniqueDataBrickSizeInAtlasTexels.y * (_665 - float((int)(_668)))) + (float((uint)((uint)(((uint)(_1008) >> (DistanceFieldBrickAtlasSizeLog2.x & 31)) & DistanceFieldBrickAtlasMask.y))) * DistanceFieldBrickOffsetToAtlasUVScale.y)) + DistanceFieldBrickAtlasHalfTexelSize.y), ((DistanceFieldBrickAtlasHalfTexelSize.z + (DistanceFieldUniqueDataBrickSizeInAtlasTexels.z * (_1000 - float((int)(_1001))))) + (float((uint)((uint)((uint)(_1008) >> (((int)((uint)(DistanceFieldBrickAtlasSizeLog2.y) + (uint)(DistanceFieldBrickAtlasSizeLog2.x))) & 31)))) * DistanceFieldBrickOffsetToAtlasUVScale.z))), 0.0f))).x) * _641);
        } else {
          _1063 = _641;
        }
        _1064 = _733 - _797;
        _1065 = _866 - _931;
        _1066 = _997 - _1063;
        _1072 = sqrt(((_1065 * _1065) + (_1064 * _1064)) + (_1066 * _1066));
        if (_1072 > 0.0f) {
          _1079 = (_1064 / _1072);
          _1080 = (_1065 / _1072);
          _1081 = (_1066 / _1072);
        } else {
          _1079 = 0.0f;
          _1080 = 0.0f;
          _1081 = 0.0f;
        }
        _1084 = mad(_1081, _563, mad(_1080, _557, (_1079 * _551)));
        _1087 = mad(_1081, _564, mad(_1080, _558, (_1079 * _552)));
        _1090 = mad(_1081, _565, mad(_1080, _559, (_1079 * _553)));
        _1096 = sqrt(((_1087 * _1087) + (_1084 * _1084)) + (_1090 * _1090));
        if (_1096 > 0.0f) {
          _1103 = (_1084 / _1096);
          _1104 = (_1087 / _1096);
          _1105 = (_1090 / _1096);
        } else {
          _1103 = 0.0f;
          _1104 = 0.0f;
          _1105 = 0.0f;
        }
        _1109 = asint(LumenCardScene_SceneInstanceIndexToMeshCardsIndexBuffer.Load(((int)(asint(_574) << 2))));
        if ((uint)_1109 < (uint)LumenCardScene.NumMeshCards) {
          _1115 = _1109 * 6;
          _1118 = LumenCardScene_MeshCardsData[_1115].x;
          _1119 = LumenCardScene_MeshCardsData[_1115].y;
          _1120 = LumenCardScene_MeshCardsData[_1115].z;
          _1123 = LumenCardScene_MeshCardsData[(_1115 | 1)].x;
          _1124 = LumenCardScene_MeshCardsData[(_1115 | 1)].y;
          _1125 = LumenCardScene_MeshCardsData[(_1115 | 1)].z;
          _1126 = LumenCardScene_MeshCardsData[(_1115 | 1)].w;
          _1129 = LumenCardScene_MeshCardsData[((int)(_1115 + 2u))].x;
          _1130 = LumenCardScene_MeshCardsData[((int)(_1115 + 2u))].y;
          _1131 = LumenCardScene_MeshCardsData[((int)(_1115 + 2u))].z;
          _1132 = LumenCardScene_MeshCardsData[((int)(_1115 + 2u))].w;
          _1135 = LumenCardScene_MeshCardsData[((int)(_1115 + 3u))].x;
          _1136 = LumenCardScene_MeshCardsData[((int)(_1115 + 3u))].y;
          _1137 = LumenCardScene_MeshCardsData[((int)(_1115 + 3u))].z;
          _1138 = LumenCardScene_MeshCardsData[((int)(_1115 + 3u))].w;
          _1141 = LumenCardScene_MeshCardsData[((int)(_1115 + 4u))].x;
          _1142 = LumenCardScene_MeshCardsData[((int)(_1115 + 4u))].y;
          _1143 = LumenCardScene_MeshCardsData[((int)(_1115 + 4u))].z;
          _1144 = LumenCardScene_MeshCardsData[((int)(_1115 + 4u))].w;
          _1145 = asint(_1141);
          _1146 = asint(_1142);
          _1149 = LumenCardScene_MeshCardsData[((int)(_1115 + 5u))].x;
          _1150 = LumenCardScene_MeshCardsData[((int)(_1115 + 5u))].y;
          _1151 = LumenCardScene_MeshCardsData[((int)(_1115 + 5u))].z;
          _1152 = LumenCardScene_MeshCardsData[((int)(_1115 + 5u))].w;
          _1154 = ((_1146 & 65536) != 0);
          _48[0] = asuint(_1143);
          _48[1] = asuint(_1144);
          _48[2] = asuint(_1149);
          _48[3] = asuint(_1150);
          _48[4] = asuint(_1151);
          _48[5] = asuint(_1152);
          _1169 = select(((_1146 & 131072) != 0), 70.0f, 20.0f);
          _1171 = (_598 - _1118) - _1126;
          _1173 = (_599 - _1119) - _1132;
          _1175 = (_600 - _1120) - _1138;
          _1178 = mad(_1175, _1135, mad(_1173, _1129, (_1171 * _1123)));
          _1181 = mad(_1175, _1136, mad(_1173, _1130, (_1171 * _1124)));
          _1184 = mad(_1175, _1137, mad(_1173, _1131, (_1171 * _1125)));
          _1187 = mad(_1105, _1135, mad(_1104, _1129, (_1123 * _1103)));
          _1190 = mad(_1105, _1136, mad(_1104, _1130, (_1124 * _1103)));
          _1193 = mad(_1105, _1137, mad(_1104, _1131, (_1125 * _1103)));
          _1194 = _1187 * _1187;
          _1195 = _1190 * _1190;
          _1196 = _1193 * _1193;
          if (_1194 > 0.0f) {
            _1204 = (_48[min((uint)(((int)(uint)((int)(!(_1187 < 0.0f))))), 5u)]);
          } else {
            _1204 = 0;
          }
          if (_1195 > 0.0f) {
            _1213 = ((_48[min((uint)(select((_1190 < 0.0f), 2, 3)), 5u)]) | _1204);
          } else {
            _1213 = _1204;
          }
          if (_1196 > 0.0f) {
            _1222 = ((_48[min((uint)(select((_1193 < 0.0f), 4, 5)), 5u)]) | _1213);
          } else {
            _1222 = _1213;
          }
          if (!(_1222 == 0)) {
            _1226 = _1222;
            _1227 = 0;
            while(true) {
              _1228 = firstbitlow(_1226);
              _1230 = 1 << (_1228 & 31);
              _1233 = ((int)(_1228 + _1145)) * 10;
              _1237 = LumenCardScene_CardData[((int)(_1233 + 6u))].w;
              _1240 = LumenCardScene_CardData[((int)(_1233 + 7u))].w;
              _1243 = LumenCardScene_CardData[((int)(_1233 + 8u))].w;
              _1246 = LumenCardScene_CardData[((int)(_1233 + 9u))].x;
              _1247 = LumenCardScene_CardData[((int)(_1233 + 9u))].y;
              _1248 = LumenCardScene_CardData[((int)(_1233 + 9u))].z;
              _1255 = _1169 * 0.5f;
              _1265 = select((((abs(_1178 - _1237) <= (_1246 + _1255)) && (abs(_1181 - _1240) <= (_1247 + _1255))) && (abs(_1184 - _1243) <= (_1248 + _1255))), _1230, 0) | _1227;
              if (!(_1226 == _1230)) {
                _1226 = (_1230 ^ _1226);
                _1227 = _1265;
                continue;
              }
              _1269 = _1265;
              break;
            }
          } else {
            _1269 = 0;
          }
          _1270 = select(_1154, 1, _1269);
          if (!(_1270 == 0)) {
            _1274 = 0;
            _1275 = 0;
            _1276 = 0;
            _1277 = 0.0f;
            _1278 = 0.0f;
            _1279 = 0.0f;
            _1280 = 0.0f;
            _1281 = 0.0f;
            _1282 = _1270;
            while(true) {
              _1297 = _1274;
              _1298 = _1275;
              _1299 = _1276;
              _1300 = _1277;
              _1301 = _1278;
              _1302 = _1279;
              _1303 = _1280;
              _1304 = _1281;
              _1283 = firstbitlow(_1282);
              _1285 = 1 << (_1283 & 31);
              _1287 = _1283 + _1145;
              _1288 = _1287 * 10;
              _1292 = LumenCardScene_CardData[((int)(_1288 + 4u))].w;
              _1293 = asint(_1292);
              if (!((_1293 & 16777216) == 0)) {
                if ((uint)_1287 < (uint)LumenCardScene.NumCards) {
                  _1311 = LumenCardScene_CardData[((int)(_1288 + 4u))].x;
                  _1312 = LumenCardScene_CardData[((int)(_1288 + 4u))].y;
                  _1313 = LumenCardScene_CardData[((int)(_1288 + 4u))].z;
                  _1322 = abs(_1311);
                  _1323 = abs(_1312);
                  _1324 = abs(_1313);
                  _1326 = ((uint)(_1293) >> 16) & 15;
                  _1327 = LumenCardScene_CardData[((int)(_1288 + 8u))].w;
                  _1328 = LumenCardScene_CardData[((int)(_1288 + 8u))].z;
                  _1329 = LumenCardScene_CardData[((int)(_1288 + 8u))].y;
                  _1330 = LumenCardScene_CardData[((int)(_1288 + 8u))].x;
                  _1331 = LumenCardScene_CardData[((int)(_1288 + 7u))].w;
                  _1332 = LumenCardScene_CardData[((int)(_1288 + 7u))].z;
                  _1333 = LumenCardScene_CardData[((int)(_1288 + 7u))].y;
                  _1334 = LumenCardScene_CardData[((int)(_1288 + 7u))].x;
                  _1335 = LumenCardScene_CardData[((int)(_1288 + 6u))].w;
                  _1336 = LumenCardScene_CardData[((int)(_1288 + 6u))].z;
                  _1337 = LumenCardScene_CardData[((int)(_1288 + 6u))].y;
                  _1338 = LumenCardScene_CardData[((int)(_1288 + 6u))].x;
                  _1339 = _1178 - _1335;
                  _1340 = _1181 - _1331;
                  _1341 = _1184 - _1327;
                  _1344 = mad(_1341, _1330, mad(_1340, _1334, (_1339 * _1338)));
                  _1347 = mad(_1341, _1329, mad(_1340, _1333, (_1339 * _1337)));
                  _1350 = mad(_1341, _1328, mad(_1340, _1332, (_1339 * _1336)));
                  _1354 = _1169 * 0.5f;
                  if (((abs(_1344) <= (_1322 + _1354)) && (abs(_1347) <= (_1323 + _1354))) && (abs(_1350) <= (_1324 + _1354))) {
                    _1367 = LumenCardScene_CardData[((int)(_1288 + 5u))].w;
                    _1368 = LumenCardScene_CardData[((int)(_1288 + 5u))].z;
                    _1369 = LumenCardScene_CardData[((int)(_1288 + 5u))].y;
                    _1370 = LumenCardScene_CardData[((int)(_1288 + 5u))].x;
                    _1385 = min(saturate(((min(max(_1344, (-0.0f - _1322)), _1322) / _1322) * 0.5f) + 0.5f), 0.9999989867210388f);
                    _1386 = min(saturate(0.5f - ((min(max(_1347, (-0.0f - _1323)), _1323) / _1323) * 0.5f)), 0.9999989867210388f);
                    _1388 = asint(select(_200, _1368, _1370));
                    _1389 = _1388 & 65535;
                    _1405 = asint(LumenCardScene_PageTableBuffer.Load2(((int)(((int)((uint(_1385 * float((uint)_1389)) + (uint)(asint(select(_200, _1367, _1369)))) + ((int)(uint(_1386 * float((uint)((uint)((uint)(_1388) >> 16))))) * _1389))) << 3)))).x;
                    _1406 = asint(LumenCardScene_PageTableBuffer.Load2(((int)(((int)((uint(_1385 * float((uint)_1389)) + (uint)(asint(select(_200, _1367, _1369)))) + ((int)(uint(_1386 * float((uint)((uint)((uint)(_1388) >> 16))))) * _1389))) << 3)))).y;
                    _1412 = ((uint)(_1405) >> 24) & 15;
                    _1413 = (uint)(_1405) >> 28;
                    _1420 = ((uint)_1412 > (uint)7);
                    _1421 = ((int)_1405 < (int)0);
                    _1422 = select(_1420, ((int)(1 << ((_1412 + 25) & 31))), 1);
                    _1423 = select(_1421, ((int)(1 << ((_1413 + 25) & 31))), 1);
                    _1426 = float((uint)_1422) * _1385;
                    _1427 = float((uint)_1423) * _1386;
                    _1428 = uint(_1426);
                    _1429 = uint(_1427);
                    _1436 = select((_1428 == 0), 0.0f, 0.5f);
                    _1437 = select((_1429 == 0), 0.0f, 0.5f);
                    _1443 = select(_1420, 128.0f, float((uint)(1 << _1412)));
                    _1445 = select(_1421, 128.0f, float((uint)(1 << _1413)));
                    _1469 = LumenCardScene.InvPhysicalAtlasSize.x * (min(max(((((_1443 - _1436) + select((((int)(_1428 + 1u)) == _1422), -0.0f, -0.5f)) * frac(_1426)) + _1436), 0.5f), (_1443 + -1.5f)) + float((uint)((uint)(((int)(_1405 << 3)) & 32760))));
                    _1470 = LumenCardScene.InvPhysicalAtlasSize.y * (min(max(((((_1445 - _1437) + select((((int)(_1429 + 1u)) == _1423), -0.0f, -0.5f)) * frac(_1427)) + _1437), 0.5f), (_1445 + -1.5f)) + float((uint)((uint)(((uint)(_1405) >> 9) & 32760))));
                    _1480 = uint(min(max((SurfaceCacheFeedbackResLevelBias + log2(max(_1322, _1323) / max((_540 * tan(View.EyeToPixelSpreadAngle + _174.w)), 1.0f))), 3.0f), 11.0f));
                    _1481 = _1480 - ((uint)(_1293 & 255));
                    _1482 = _1480 - ((uint)(((uint)(_1293) >> 8) & 255));
                    _1510 = frac((LumenCardScene.PhysicalAtlasSize.x * _1469) + 0.501953125f);
                    _1511 = frac((LumenCardScene.PhysicalAtlasSize.y * _1470) + 0.501953125f);
                    _1512 = 1.0f - _1510;
                    _1515 = 1.0f - _1511;
                    if (!(_1412 == 0)) {
                      if (!_1154) {
                        if (!((uint)_1326 < (uint)2)) {
                          _1526 = select(((uint)_1326 < (uint)4), _1195, _1196);
                        } else {
                          _1526 = _1194;
                        }
                      } else {
                        _1526 = 1.0f;
                      }
                      if (_1526 > 0.0f) {
                        _1531 = DepthAtlas.GatherRed(D3DStaticPointClampedSampler, float2(_1469, _1470));
                        _1538 = 0.5f - ((_1350 / _1324) * 0.5f);
                        _1539 = _1169 / _1324;
                        _1540 = _1539 * 0.25f;
                        _1541 = !(_1531.x < 1.0f);
                        if (!(_1154 || _1541)) {
                          _1552 = (1.0f - saturate((abs(_1538 - _1531.x) - _1539) / _1540));
                        } else {
                          _1552 = select(_1541, 0.0f, 1.0f);
                        }
                        _1553 = !(_1531.y < 1.0f);
                        if (!(_1154 || _1553)) {
                          _2439 = (1.0f - saturate((abs(_1538 - _1531.y) - _1539) / _1540));
                        } else {
                          _2439 = select(_1553, 0.0f, 1.0f);
                        }
                        _2440 = !(_1531.z < 1.0f);
                        if (!(_1154 || _2440)) {
                          _2451 = (1.0f - saturate((abs(_1538 - _1531.z) - _1539) / _1540));
                        } else {
                          _2451 = select(_2440, 0.0f, 1.0f);
                        }
                        _2452 = !(_1531.w < 1.0f);
                        if (!(_1154 || _2452)) {
                          _2463 = (1.0f - saturate((abs(_1538 - _1531.w) - _1539) / _1540));
                        } else {
                          _2463 = select(_2452, 0.0f, 1.0f);
                        }
                        _2464 = _1552 * (_1512 * _1511);
                        _2465 = _2439 * (_1511 * _1510);
                        _2466 = _2451 * (_1515 * _1510);
                        _2467 = _2463 * (_1515 * _1512);
                        _2468 = dot(float4(_2464, _2465, _2466, _2467), float4(1.0f, 1.0f, 1.0f, 1.0f));
                        _2469 = _2468 * _1526;
                        if (_2469 > 0.0f) {
                          while(true) {
                            _1557 = _2464 / _2468;
                            _1558 = _2465 / _2468;
                            _1559 = _2466 / _2468;
                            _1560 = _2467 / _2468;
                            _1562 = FinalLightingAtlas.GatherRed(D3DStaticPointClampedSampler, float2(_1469, _1470));
                            _1567 = FinalLightingAtlas.GatherGreen(D3DStaticPointClampedSampler, float2(_1469, _1470));
                            _1572 = FinalLightingAtlas.GatherBlue(D3DStaticPointClampedSampler, float2(_1469, _1470));
                            _1583 = (dot(float4(_1562.x, _1562.y, _1562.z, _1562.w), float4(_1557, _1558, _1559, _1560)) * _2469) + _1278;
                            _1584 = (dot(float4(_1567.x, _1567.y, _1567.z, _1567.w), float4(_1557, _1558, _1559, _1560)) * _2469) + _1279;
                            _1585 = (dot(float4(_1572.x, _1572.y, _1572.z, _1572.w), float4(_1557, _1558, _1559, _1560)) * _2469) + _1280;
                            _1586 = _2469 + _1281;
                            if (_2469 > _1277) {
                              _1297 = _1406;
                              _1298 = (((int)(_1480 << 24)) | _1287);
                              _1299 = ((int)(((int)(uint(select(((uint)_1482 > (uint)7), float((uint)(1 << (((int)(_1482 + 25u)) & 31))), 1.0f) * _1386)) << 8) + uint(select(((uint)_1481 > (uint)7), float((uint)(1 << (((int)(_1481 + 25u)) & 31))), 1.0f) * _1385)));
                              _1300 = _2469;
                              _1301 = _1583;
                              _1302 = _1584;
                              _1303 = _1585;
                              _1304 = _1586;
                            } else {
                              _1297 = _1274;
                              _1298 = _1275;
                              _1299 = _1276;
                              _1300 = _1277;
                              _1301 = _1583;
                              _1302 = _1584;
                              _1303 = _1585;
                              _1304 = _1586;
                            }
                            break;
                          }
                        } else {
                          _1297 = _1274;
                          _1298 = _1275;
                          _1299 = _1276;
                          _1300 = _1277;
                          _1301 = _1278;
                          _1302 = _1279;
                          _1303 = _1280;
                          _1304 = _1281;
                        }
                      } else {
                        _1297 = _1274;
                        _1298 = _1275;
                        _1299 = _1276;
                        _1300 = _1277;
                        _1301 = _1278;
                        _1302 = _1279;
                        _1303 = _1280;
                        _1304 = _1281;
                      }
                    } else {
                      _1297 = _1274;
                      _1298 = _1275;
                      _1299 = _1276;
                      _1300 = _1277;
                      _1301 = _1278;
                      _1302 = _1279;
                      _1303 = _1280;
                      _1304 = _1281;
                    }
                  } else {
                    _1297 = _1274;
                    _1298 = _1275;
                    _1299 = _1276;
                    _1300 = _1277;
                    _1301 = _1278;
                    _1302 = _1279;
                    _1303 = _1280;
                    _1304 = _1281;
                  }
                } else {
                  _1297 = _1274;
                  _1298 = _1275;
                  _1299 = _1276;
                  _1300 = _1277;
                  _1301 = _1278;
                  _1302 = _1279;
                  _1303 = _1280;
                  _1304 = _1281;
                }
              } else {
                _1297 = _1274;
                _1298 = _1275;
                _1299 = _1276;
                _1300 = _1277;
                _1301 = _1278;
                _1302 = _1279;
                _1303 = _1280;
                _1304 = _1281;
              }
              while(true) {
                if (!(_1282 == _1285)) {
                  _1274 = _1297;
                  _1275 = _1298;
                  _1276 = _1299;
                  _1277 = _1300;
                  _1278 = _1301;
                  _1279 = _1302;
                  _1280 = _1303;
                  _1281 = _1304;
                  _1282 = (_1285 ^ _1282);
                  __loop_jump_target = 1273;
                  break;
                }
                _1591 = _1297;
                _1592 = _1298;
                _1593 = _1299;
                _1594 = _1301;
                _1595 = _1302;
                _1596 = _1303;
                _1597 = _1304;
                break;
              }
              if (__loop_jump_target == 1273) {
                __loop_jump_target = -1;
                continue;
              }
              if (__loop_jump_target != -1) {
                break;
              }
              break;
            }
          } else {
            _1591 = 0;
            _1592 = 0;
            _1593 = 0;
            _1594 = 0.0f;
            _1595 = 0.0f;
            _1596 = 0.0f;
            _1597 = 0.0f;
          }
        } else {
          _1591 = 0;
          _1592 = 0;
          _1593 = 0;
          _1594 = 0.0f;
          _1595 = 0.0f;
          _1596 = 0.0f;
          _1597 = 0.0f;
        }
        if (_1597 > 0.0f) {
          _1600 = _1594 / _1597;
          _1601 = _1595 / _1597;
          _1602 = _1596 / _1597;
          if (((SurfaceCacheFeedbackBufferTileWrapMask & _57) == SurfaceCacheFeedbackBufferTileJitter.x) && ((SurfaceCacheFeedbackBufferTileWrapMask & _59) == SurfaceCacheFeedbackBufferTileJitter.y)) {
            if ((_1597 > 0.10000000149011612f) && (SurfaceCacheFeedbackBufferSize != 0)) {
              InterlockedAdd(RWSurfaceCacheFeedbackBufferAllocator[0], 1, _1619);
              if ((uint)_1619 < (uint)SurfaceCacheFeedbackBufferSize) {
                RWSurfaceCacheFeedbackBuffer[_1619] = int2(_1592, _1593);
              }
              RWCardPageHighResLastUsedBuffer[_1591] = SurfaceCacheUpdateFrameIndex;
              _1630 = _1600;
              _1631 = _1601;
              _1632 = _1602;
              _1633 = 0.0f;
              _1634 = _540;
            } else {
              _1630 = _1600;
              _1631 = _1601;
              _1632 = _1602;
              _1633 = 0.0f;
              _1634 = _540;
            }
          } else {
            _1630 = _1600;
            _1631 = _1601;
            _1632 = _1602;
            _1633 = 0.0f;
            _1634 = _540;
          }
        } else {
          _1630 = 0.0f;
          _1631 = 0.0f;
          _1632 = 0.0f;
          _1633 = 0.0f;
          _1634 = _540;
        }
      } else {
        _1630 = 0.0f;
        _1631 = 0.0f;
        _1632 = 0.0f;
        _1633 = 1.0f;
        _1634 = _540;
      }
    } else {
      _1630 = 0.0f;
      _1631 = 0.0f;
      _1632 = 0.0f;
      _1633 = 1.0f;
      _1634 = _183;
    }
    _1635 = min(_183, _1634);
    _1644 = select(((uint)VirtualVoxel.JitterMode > (uint)1), 0, View.StateFrameIndexMod8);
    if (InjectionToggle(TOGGLE_USE_ISFAST_REFLECTIONS)) {
      float2 _isfast_sdf_a = ISFASTNoiseLoad(uint(_57) % 128u, uint(_59) % 128u, uint(float(InjectionFrameIndex())) % 32u);
      float2 _isfast_sdf_b = ISFASTNoiseLoad((uint(_57) + 3u) % 128u, (uint(_59) + 21u) % 128u, (uint(float(InjectionFrameIndex())) + 1u) % 32u);
      _1658 = uint(_isfast_sdf_a.x * 65535.0f) | (uint(_isfast_sdf_a.y * 65535.0f) << 16u);
      _1656 = _1658 ^ 0xA5A5A5A5u;
      _1654 = _1658 ^ 0x5A5A5A5Au;
      _1664 = uint(_isfast_sdf_b.x * 65535.0f) | (uint(_isfast_sdf_b.y * 65535.0f) << 16u);
      _1662 = _1664 ^ 0xA5A5A5A5u;
      _1650 = _1664 ^ 0x5A5A5A5Au;
    } else {
      _1645 = _57 * 1664525;
      _1646 = _59 * 1664525;
      _1649 = _1646 + 1013904223u;
      _1650 = (_1644 * 1664525) + 1013904223u;
      _1652 = (_1645 + 1013904223u) + (_1650 * _1649);
      _1654 = (_1652 * _1650) + _1649;
      _1656 = (_1654 * _1652) + _1650;
      _1658 = (_1656 * _1654) + _1652;
      _1660 = _1646 + 1042201148u;
      _1662 = (_1645 + 1042201148u) + (_1650 * _1660);
      _1664 = (_1662 * _1650) + _1660;
    }
    if (!(VirtualVoxel.JitterMode == 0)) {
      _1676 = float((uint)_1644) * 0.125f;
      _1694 = (frac((float((uint)((uint)((uint)(_1658) >> 16))) * 1.52587890625e-05f) + _1676) + -0.5f);
      _1695 = ((float((uint)((uint)((uint)((uint)(reversebits(_1644) ^ ((int)((_1658 * _1656) + _1654)))) >> 16))) * 1.52587890625e-05f) + -0.5f);
      _1696 = (frac((float((uint)((uint)((uint)((((int)((_1664 * _1662) + _1650)) * _1664) + _1662) >> 16))) * 1.52587890625e-05f) + _1676) + -0.5f);
    } else {
      _1694 = -0.5f;
      _1695 = -0.5f;
      _1696 = -0.5f;
    }
    if (!(VirtualVoxel.NodeDescCount == 0)) {
      _1718 = 0;
      _1719 = 0;
      _1720 = _1635;
      _1721 = 1.0f;
      while(true) {
        _1724 = VirtualVoxel_NodeDescBuffer[_1718].TranslatedWorldMinAABB.x;
        _1725 = VirtualVoxel_NodeDescBuffer[_1718].TranslatedWorldMinAABB.y;
        _1726 = VirtualVoxel_NodeDescBuffer[_1718].TranslatedWorldMinAABB.z;
        _1728 = VirtualVoxel_NodeDescBuffer[_1718].PackedPageIndexResolution;
        _1730 = VirtualVoxel_NodeDescBuffer[_1718].TranslatedWorldMaxAABB.x;
        _1731 = VirtualVoxel_NodeDescBuffer[_1718].TranslatedWorldMaxAABB.y;
        _1732 = VirtualVoxel_NodeDescBuffer[_1718].TranslatedWorldMaxAABB.z;
        _1734 = VirtualVoxel_NodeDescBuffer[_1718].PageIndexOffset_VoxelWorldSize;
        _1737 = _1728 & 255;
        _1739 = ((uint)(_1728) >> 8) & 255;
        _1741 = ((uint)(_1728) >> 16) & 255;
        _1742 = VirtualVoxel.PageResolution * _1737;
        _1743 = VirtualVoxel.PageResolution * _1739;
        _1744 = VirtualVoxel.PageResolution * _1741;
        _1747 = float((uint)((uint)((uint)(_1734) >> 22)));
        _1748 = _1747 * 0.009775171056389809f;
        _1754 = _1748 * (_1694 + (VirtualVoxel.DepthBiasScale_Shadow * _174.x));
        _1755 = _1748 * (_1695 + (VirtualVoxel.DepthBiasScale_Shadow * _174.y));
        _1756 = _1748 * (_1696 + (VirtualVoxel.DepthBiasScale_Shadow * _174.z));
        _1757 = (mad(_92.x, (View.ScreenToTranslatedWorld[2].x), mad(_132, (View.ScreenToTranslatedWorld[1].x), (_131 * (View.ScreenToTranslatedWorld[0].x)))) + (View.ScreenToTranslatedWorld[3].x)) + _1754;
        _1758 = (mad(_92.x, (View.ScreenToTranslatedWorld[2].y), mad(_132, (View.ScreenToTranslatedWorld[1].y), (_131 * (View.ScreenToTranslatedWorld[0].y)))) + (View.ScreenToTranslatedWorld[3].y)) + _1755;
        _1759 = (mad(_92.x, (View.ScreenToTranslatedWorld[2].z), mad(_132, (View.ScreenToTranslatedWorld[1].z), (_131 * (View.ScreenToTranslatedWorld[0].z)))) + (View.ScreenToTranslatedWorld[3].z)) + _1756;
        _1760 = 102.30000305175781f / _1747;
        if ((_1741 != 0) && ((_1737 != 0) && (_1739 != 0))) {
          _1762 = (_1635 * _174.x) - _1754;
          _1763 = (_1635 * _174.y) - _1755;
          _1764 = (_1635 * _174.z) - _1756;
          _1765 = 1.0f / _1762;
          _1766 = 1.0f / _1763;
          _1767 = 1.0f / _1764;
          _1771 = _1765 * (_1724 - _1757);
          _1772 = _1766 * (_1725 - _1758);
          _1773 = _1767 * (_1726 - _1759);
          _1777 = _1765 * (_1730 - _1757);
          _1778 = _1766 * (_1731 - _1758);
          _1779 = _1767 * (_1732 - _1759);
          _1790 = saturate(max(min(_1771, _1777), max(min(_1772, _1778), min(_1773, _1779))));
          _1791 = saturate(min(max(_1771, _1777), min(max(_1772, _1778), max(_1773, _1779))));
          if (_1790 < _1791) {
            _1801 = _1762 * (_1791 - _1790);
            _1803 = _1763 * (_1791 - _1790);
            _1805 = _1764 * (_1791 - _1790);
            _1812 = min(sqrt(((_1801 * _1801) + (_1803 * _1803)) + (_1805 * _1805)), _1635);
            _1814 = rsqrt(dot(float3(_1801, _1803, _1805), float3(_1801, _1803, _1805)));
            _1817 = min(ceil(_1812 / _1748), 1024.0f);
            if (_1817 > 0.0f) {
              _1822 = 9999;
              _1823 = 9999;
              _1824 = 9999;
              _1825 = 0;
              _1826 = 0;
              _1827 = 0;
              _1828 = 0;
              _1829 = 1.0f;
              _1830 = 0.0f;
              _1831 = 0.0f;
              while(true) {
                _1905 = _1822;
                _1906 = _1823;
                _1907 = _1824;
                _1908 = _1825;
                _1833 = max((_1829 * (_1812 / _1817)), 0.0f);
                _1849 = (((_1790 * _1762) + _1757) + (((_1801 * _1748) * _1814) * _1830)) + (_1694 * _1833);
                _1850 = (((_1790 * _1763) + _1758) + (((_1803 * _1748) * _1814) * _1830)) + (_1695 * _1833);
                _1851 = (((_1790 * _1764) + _1759) + (((_1805 * _1748) * _1814) * _1830)) + (_1696 * _1833);
                _1876 = (int)min((uint)((int)(uint(saturate((_1849 - _1724) / (_1730 - _1724)) * float((uint)_1742)))), (uint)(((int)(_1742 + (uint)(-1)))));
                _1877 = (int)min((uint)((int)(uint(saturate((_1850 - _1725) / (_1731 - _1725)) * float((uint)_1743)))), (uint)(((int)(_1743 + (uint)(-1)))));
                _1878 = (int)min((uint)((int)(uint(saturate((_1851 - _1726) / (_1732 - _1726)) * float((uint)_1744)))), (uint)(((int)(_1744 + (uint)(-1)))));
                _1879 = VirtualVoxel.PageResolutionLog2 & 31;
                _1880 = (uint)(_1876) >> _1879;
                _1881 = (uint)(_1877) >> _1879;
                _1882 = (uint)(_1878) >> _1879;
                if (((_1880 != _1822) || (_1881 != _1823)) || (_1882 != _1824)) {
                  _1895 = VirtualVoxel_PageIndexBuffer.Load((int)((_1880 + ((uint)(_1734 & 4194303))) + (((int)((_1882 * _1739) + _1881)) * _1737)));
                  _1899 = VirtualVoxel.PageCountResolution.x * VirtualVoxel.PageCountResolution.y;
                  _1900 = _1895.x % _1899;
                  _1905 = _1880;
                  _1906 = _1881;
                  _1907 = _1882;
                  _1908 = ((int)(uint)((int)(_1895.x != -1)));
                  _1909 = ((int)(_1900 % VirtualVoxel.PageCountResolution.x));
                  _1910 = ((int)(_1900 / (uint)(VirtualVoxel.PageCountResolution.x)));
                  _1911 = ((int)((uint)(_1895.x) / _1899));
                } else {
                  _1905 = _1822;
                  _1906 = _1823;
                  _1907 = _1824;
                  _1908 = _1825;
                  _1909 = _1826;
                  _1910 = _1827;
                  _1911 = _1828;
                }
                bool __branch_chain_1904;
                if (_1908 == 0) {
                  _1955 = _1831;
                  __branch_chain_1904 = true;
                } else {
                  _1928 = uint(log2(_1833 * _1760));
                  _1929 = _1928 & 31;
                  _1942 = ((((VirtualVoxel.DensityScale_Shadow * 0.0010000000474974513f) * _1760) * _1833) * float((uint)((uint)((((uint)(VirtualVoxel_PageTexture.Load(int4(((uint)((_1876 - (_1880 << _1879)) + (_1909 << _1879)) >> _1929), ((uint)((_1877 - (_1881 << _1879)) + (_1910 << _1879)) >> _1929), ((uint)((_1878 - (_1882 << _1879)) + (_1911 << _1879)) >> _1929), _1928)))).x) & 16777215)))) + _1831;
                  if (!(_1942 > 1.0f)) {
                    _1955 = _1942;
                    __branch_chain_1904 = true;
                  } else {
                    __branch_chain_1904 = false;
                  }
                }
                if (__branch_chain_1904) {
                  _1958 = min(float((uint)(uint)(VirtualVoxel.PageResolution)), (_1829 * VirtualVoxel.SteppingScale_Shadow));
                  _1959 = _1958 + _1830;
                  if (_1959 < _1817) {
                    _1822 = _1905;
                    _1823 = _1906;
                    _1824 = _1907;
                    _1825 = _1908;
                    _1826 = _1909;
                    _1827 = _1910;
                    _1828 = _1911;
                    _1829 = _1958;
                    _1830 = _1959;
                    _1831 = _1955;
                    continue;
                  } else {
                    _1963 = -1.0f;
                    _1964 = _1955;
                  }
                } else {
                  _1945 = _1849 - _1757;
                  _1946 = _1850 - _1758;
                  _1947 = _1851 - _1759;
                  _1963 = sqrt(((_1945 * _1945) + (_1946 * _1946)) + (_1947 * _1947));
                  _1964 = _1942;
                }
                break;
              }
            } else {
              _1963 = -1.0f;
              _1964 = 0.0f;
            }
          } else {
            _1963 = -1.0f;
            _1964 = 0.0f;
          }
        } else {
          _1963 = -1.0f;
          _1964 = 0.0f;
        }
        if (!(_1963 < 0.0f)) {
          _1972 = min(_1721, saturate(1.0f - _1964));
          _1973 = min(_1720, _1963);
          _1974 = 1;
        } else {
          _1972 = _1721;
          _1973 = _1720;
          _1974 = _1719;
        }
        _1975 = _1718 + 1u;
        if ((_1972 > 0.009999999776482582f) && ((uint)_1975 < (uint)VirtualVoxel.NodeDescCount)) {
          _1718 = _1975;
          _1719 = _1974;
          _1720 = _1973;
          _1721 = _1972;
          continue;
        }
        _1981 = _1974;
        _1982 = _1973;
        _1983 = _1972;
        break;
      }
    } else {
      _1981 = 0;
      _1982 = _1635;
      _1983 = 1.0f;
    }
    if ((_1982 < _1635) && (_1981 != 0)) {
      _1994 = (_1983 * _1630);
      _1995 = (_1983 * _1631);
      _1996 = (_1983 * _1632);
      _1997 = (_1983 * _1633);
      _1998 = min(_1982, _1634);
    } else {
      _1994 = _1630;
      _1995 = _1631;
      _1996 = _1632;
      _1997 = _1633;
      _1998 = _1634;
    }
    _2001 = View.PreExposure * _1994;
    _2002 = View.PreExposure * _1995;
    _2003 = View.PreExposure * _1996;
    _2013 = (View.ViewOriginHigh.x - _136) + View.ViewOriginLow.x;
    _2015 = (View.ViewOriginHigh.y - _140) + View.ViewOriginLow.y;
    _2017 = (View.ViewOriginHigh.z - _144) + View.ViewOriginLow.z;
    _2023 = sqrt(((_2013 * _2013) + (_2015 * _2015)) + (_2017 * _2017));
    if (!((View.ViewToClip[3].w) < 1.0f)) {
      _2036 = ((_2023 / dot(float3(_2013, _2015, _2017), float3(View.ViewForward.x, View.ViewForward.y, View.ViewForward.z))) * _2023);
    } else {
      _2036 = _2023;
    }
    _2054 = 1.0f - _1997;
    if (!(SampleHeightFog == 0)) {
      _2057 = _1998 * _174.x;
      _2058 = _1998 * _174.y;
      _2065 = min((View.ViewOriginLow.z + View.ViewOriginHigh.z), FogStruct.ExponentialFogParameters.z);
      _2068 = (((_1998 * _174.z) - _2065) + View.ViewOriginHigh.z) + View.ViewOriginLow.z;
      _2069 = dot(float3(_2057, _2058, _2068), float3(_2057, _2058, _2068));
      _2071 = rsqrt(max(_2069, 9.99999993922529e-09f));
      _2072 = _2071 * _2069;
      _2073 = _2071 * _2057;
      _2074 = _2071 * _2058;
      _2075 = _2068 * _2071;
      [branch]
      if (dot(float3(View.GlobalClippingPlane.x, View.GlobalClippingPlane.y, View.GlobalClippingPlane.z), float3(1.0f, 1.0f, 1.0f)) > 0.0f) {
        _2106 = (-0.0f - dot(float4(View.GlobalClippingPlane.x, View.GlobalClippingPlane.y, View.GlobalClippingPlane.z, View.GlobalClippingPlane.w), float4((((View.ViewOriginLow.x + View.ViewOriginHigh.x) + View.PreViewTranslationHigh.x) + View.PreViewTranslationLow.x), (((View.ViewOriginLow.y + View.ViewOriginHigh.y) + View.PreViewTranslationHigh.y) + View.PreViewTranslationLow.y), ((View.PreViewTranslationHigh.z + _2065) + View.PreViewTranslationLow.z), 1.0f))) / dot(float3(_2057, _2058, _2068), float3(View.GlobalClippingPlane.x, View.GlobalClippingPlane.y, View.GlobalClippingPlane.z));
        if ((_2106 > 0.0f) && (_2106 < 1.0f)) {
          _2114 = max(0.0f, (_2106 * _2072));
        } else {
          _2114 = 0.0f;
        }
      } else {
        _2114 = 0.0f;
      }
      _2116 = max(_2114, FogStruct.ExponentialFogParameters.w);
      if (_2116 > 0.0f) {
        _2121 = _2116 * _2071;
        _2122 = _2121 * _2068;
        _2123 = _2122 + _2065;
        _2145 = (FogStruct.ExponentialFogParameters3.x * exp2(-0.0f - max(-127.0f, ((_2123 - FogStruct.ExponentialFogParameters3.y) * FogStruct.ExponentialFogParameters.y))));
        _2146 = (FogStruct.ExponentialFogParameters2.z * exp2(-0.0f - max(-127.0f, ((_2123 - FogStruct.ExponentialFogParameters2.w) * FogStruct.ExponentialFogParameters2.y))));
        _2147 = ((1.0f - _2121) * _2072);
        _2148 = (_2068 - _2122);
      } else {
        _2145 = FogStruct.ExponentialFogParameters.x;
        _2146 = FogStruct.ExponentialFogParameters2.x;
        _2147 = _2072;
        _2148 = _2068;
      }
      _2150 = max(-127.0f, (FogStruct.ExponentialFogParameters.y * _2148));
      _2162 = max(-127.0f, (FogStruct.ExponentialFogParameters2.y * _2148));
      _2173 = (select((abs(_2162) > 0.009999999776482582f), ((1.0f - exp2(-0.0f - _2162)) / _2162), (0.6931471824645996f - (_2162 * 0.24022650718688965f))) * _2146) + (select((abs(_2150) > 0.009999999776482582f), ((1.0f - exp2(-0.0f - _2150)) / _2150), (0.6931471824645996f - (_2150 * 0.24022650718688965f))) * _2145);
      [branch]
      if (FogStruct.ExponentialFogParameters3.z > 0.0f) {
        _2186 = saturate((FogStruct.FogInscatteringTextureParameters.x * _2072) + FogStruct.FogInscatteringTextureParameters.y);
        _2191 = dot(float2(_2057, _2058), float2(FogStruct.SinCosInscatteringColorCubemapRotation.y, (-0.0f - FogStruct.SinCosInscatteringColorCubemapRotation.x)));
        _2192 = dot(float2(_2057, _2058), float2(FogStruct.SinCosInscatteringColorCubemapRotation.x, FogStruct.SinCosInscatteringColorCubemapRotation.y));
        _2195 = FogStruct_FogInscatteringColorCubemap.SampleLevel(FogStruct_FogInscatteringColorSampler, float3(_2191, _2192, _2068), 0.0f);
        _2200 = FogStruct_FogInscatteringColorCubemap.SampleLevel(FogStruct_FogInscatteringColorSampler, float3(_2191, _2192, _2068), FogStruct.FogInscatteringTextureParameters.z);
        _2217 = ((lerp(_2200.x, _2195.x, _2186)) * FogStruct.ExponentialFogColorParameter.x);
        _2218 = ((lerp(_2200.y, _2195.y, _2186)) * FogStruct.ExponentialFogColorParameter.y);
        _2219 = ((lerp(_2200.z, _2195.z, _2186)) * FogStruct.ExponentialFogColorParameter.z);
      } else {
        _2217 = FogStruct.ExponentialFogColorParameter.x;
        _2218 = FogStruct.ExponentialFogColorParameter.y;
        _2219 = FogStruct.ExponentialFogColorParameter.z;
      }
      _2231 = View_DistantSkyLightLutTexture.SampleLevel(View_DistantSkyLightLutTextureSampler, float2(0.5f, 0.5f), 0.0f);
      if ((FogStruct.InscatteringLightDirection.w >= 0.0f) && (FogStruct.ExponentialFogParameters3.z == 0.0f)) {
        _2255 = View.SkyAtmosphereHeightFogContribution * 0.07957746833562851f;
        _2271 = exp2(log2(saturate(dot(float3(_2073, _2074, _2075), float3((View.AtmosphereLightDirection[0].x), (View.AtmosphereLightDirection[0].y), (View.AtmosphereLightDirection[0].z))))) * FogStruct.DirectionalInscatteringColor.w);
        _2272 = _2271 * ((_2255 * (View.AtmosphereLightIlluminanceOnGroundPostTransmittance[0].x)) + FogStruct.DirectionalInscatteringColor.x);
        _2273 = _2271 * ((_2255 * (View.AtmosphereLightIlluminanceOnGroundPostTransmittance[0].y)) + FogStruct.DirectionalInscatteringColor.y);
        _2274 = _2271 * ((_2255 * (View.AtmosphereLightIlluminanceOnGroundPostTransmittance[0].z)) + FogStruct.DirectionalInscatteringColor.z);
        if ((View.AtmosphereLightIlluminanceOnGroundPostTransmittance[1].w) > 0.0f) {
          _2296 = exp2(log2(saturate(dot(float3(_2073, _2074, _2075), float3((View.AtmosphereLightDirection[1].x), (View.AtmosphereLightDirection[1].y), (View.AtmosphereLightDirection[1].z))))) * FogStruct.DirectionalInscatteringColor.w);
          _2304 = ((_2296 * ((_2255 * (View.AtmosphereLightIlluminanceOnGroundPostTransmittance[1].x)) + FogStruct.DirectionalInscatteringColor.x)) + _2272);
          _2305 = ((_2296 * ((_2255 * (View.AtmosphereLightIlluminanceOnGroundPostTransmittance[1].y)) + FogStruct.DirectionalInscatteringColor.y)) + _2273);
          _2306 = ((_2296 * ((_2255 * (View.AtmosphereLightIlluminanceOnGroundPostTransmittance[1].z)) + FogStruct.DirectionalInscatteringColor.z)) + _2274);
        } else {
          _2304 = _2272;
          _2305 = _2273;
          _2306 = _2274;
        }
        _2313 = 1.0f - saturate(exp2(-0.0f - (_2173 * max((_2147 - FogStruct.InscatteringLightDirection.w), 0.0f))));
        _2318 = (_2313 * _2304);
        _2319 = (_2313 * _2305);
        _2320 = (_2313 * _2306);
      } else {
        _2318 = 0.0f;
        _2319 = 0.0f;
        _2320 = 0.0f;
      }
      _2329 = (FogStruct.ExponentialFogParameters3.w > 0.0f) && (_2072 > FogStruct.ExponentialFogParameters3.w);
      _2333 = select(_2329, 1.0f, max(saturate(exp2(-0.0f - (_2147 * _2173))), FogStruct.ExponentialFogColorParameter.w));
      _2334 = 1.0f - _2333;
      _2344 = View.PreExposure * saturate(_2054);
      _2352 = ((_2344 * ((_2334 * (((View.SkyAtmosphereHeightFogContribution * FogStruct.SkyAtmosphereAmbientContributionColorScale.x) * _2231.x) + _2217)) + select(_2329, 0.0f, _2318))) + (_2333 * _2001));
      _2353 = ((_2344 * ((_2334 * (((View.SkyAtmosphereHeightFogContribution * FogStruct.SkyAtmosphereAmbientContributionColorScale.y) * _2231.y) + _2218)) + select(_2329, 0.0f, _2319))) + (_2333 * _2002));
      _2354 = ((_2344 * ((_2334 * (((View.SkyAtmosphereHeightFogContribution * FogStruct.SkyAtmosphereAmbientContributionColorScale.z) * _2231.z) + _2219)) + select(_2329, 0.0f, _2320))) + (_2333 * _2003));
    } else {
      _2352 = _2001;
      _2353 = _2002;
      _2354 = _2003;
    }
    if (ReflectionStruct.SkyLightParameters.y > 0.0f) {
      if (SkylightLeaking > 0.0f) {
        _2374 = ReflectionStruct_SkyLightCubemap.SampleLevel(ReflectionStruct_SkyLightCubemapSampler, float3(_174.x, _174.y, _174.z), ((ReflectionStruct.SkyLightParameters.x + -2.0f) + (log2(max(SkylightLeakingRoughness, 0.0010000000474974513f)) * 1.2000000476837158f)));
        _2388 = saturate(InvFullSkylightLeakingDistance * _1998) * SkylightLeaking;
        _2393 = ((View.SkyLightColor.x * _2374.x) * _2388);
        _2394 = ((View.SkyLightColor.y * _2374.y) * _2388);
        _2395 = ((View.SkyLightColor.z * _2374.z) * _2388);
      } else {
        _2393 = 0.0f;
        _2394 = 0.0f;
        _2395 = 0.0f;
      }
    } else {
      _2393 = 0.0f;
      _2394 = 0.0f;
      _2395 = 0.0f;
    }
    _2399 = (View.PreExposure * _2393) + _2352;
    _2400 = (View.PreExposure * _2394) + _2353;
    _2401 = (View.PreExposure * _2395) + _2354;
    _2403 = max(_2399, max(_2400, _2401));
    if (_2403 > MaxRayIntensity) {
      _2408 = MaxRayIntensity / _2403;
      _2413 = (_2408 * _2399);
      _2414 = (_2408 * _2400);
      _2415 = (_2408 * _2401);
    } else {
      _2413 = _2399;
      _2414 = _2400;
      _2415 = _2401;
    }
    RWTraceRadiance[int3(_57, _59, 0)] = float3(_2413, _2414, _2415);
    float _ign_hit_threshold;
    if (InjectionToggle(TOGGLE_USE_ISFAST_REFLECTIONS)) {
      _ign_hit_threshold = ISFASTNoiseLoad((uint(_57) + 5u) % 128u, (uint(_59) + 35u) % 128u, uint(float(InjectionFrameIndex())) % 32u).x;
    } else {
      _ign_hit_threshold = frac(frac(dot(float2((float((uint)_57) + 0.5f), (float((uint)_59) + 0.5f)), float2(0.0671105608344078f, 0.005837149918079376f))) * 52.98291778564453f);
    }
    RWTraceHit[int3(_57, _59, 0)] = (select((((max(saturate(((_2036 * 4.0f) / CardTraceEndDistanceFromCamera) + -3.0f), saturate((_1998 - (MaxMeshSDFTraceDistance * 0.699999988079071f)) / (MaxMeshSDFTraceDistance * 0.30000001192092896f))) * _2054) + _1997) < _ign_hit_threshold), -1.0f, 1.0f) * max(_1998, 0.0f));
  }
}