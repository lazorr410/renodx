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


Texture3D<float4> View_GlobalDistanceFieldPageAtlasTexture : register(t0);

Texture3D<float4> View_GlobalDistanceFieldCoverageAtlasTexture : register(t1);

Texture3D<uint> View_GlobalDistanceFieldPageTableTexture : register(t2);

Texture3D<float4> View_GlobalDistanceFieldMipTexture : register(t3);

Texture2D<float4> View_DistantSkyLightLutTexture : register(t4);

StructuredBuffer<float4> LumenCardScene_CardData : register(t5);

StructuredBuffer<float4> LumenCardScene_MeshCardsData : register(t6);

ByteAddressBuffer LumenCardScene_PageTableBuffer : register(t7);

ByteAddressBuffer LumenCardScene_SceneInstanceIndexToMeshCardsIndexBuffer : register(t8);

TextureCube<float4> ReflectionStruct_SkyLightCubemap : register(t9);

TextureCube<float4> FogStruct_FogInscatteringColorCubemap : register(t10);

Texture2D<float4> SceneDepthTexture : register(t11);

Texture2D<float4> GBufferVelocityTexture : register(t12);

Texture2D<float4> FinalLightingAtlas : register(t13);

Texture2D<float4> DepthAtlas : register(t14);

StructuredBuffer<uint4> GlobalDistanceFieldPageObjectGridBuffer : register(t15);

Texture3D<uint> RadianceProbeIndirectionTexture : register(t16);

Texture2D<float3> RadianceCacheFinalRadianceAtlas : register(t17);

StructuredBuffer<float4> ProbeWorldOffset : register(t18);

Texture2DArray<float4> DownsampledDepth : register(t19);

Texture2DArray<float4> RayBuffer : register(t20);

Texture2DArray<uint> RayTraceDistance : register(t21);

Buffer<uint> CompactedTraceTexelAllocator : register(t22);

Buffer<uint> CompactedTraceTexelData : register(t23);

Texture2D<float4> PrevSceneColorTexture : register(t24);

Texture2D<float4> HistorySceneDepth : register(t25);

Texture2D<float4> DistantScreenTraceFurthestHZBTexture : register(t26);

RWStructuredBuffer<uint> RWCardPageHighResLastUsedBuffer : register(u0);

RWStructuredBuffer<uint> RWSurfaceCacheFeedbackBufferAllocator : register(u1);

RWStructuredBuffer<uint2> RWSurfaceCacheFeedbackBuffer : register(u2);

RWTexture2DArray<float> RWTraceHit : register(u3);

RWTexture2DArray<float3> RWTraceRadiance : register(u4);

cbuffer _RootShaderParameters : register(b0) {
  uint4 _RootShaderParameters_raw[84];
};

cbuffer View : register(b1) {
  uint4 View_raw[358];
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

SamplerState D3DStaticPointClampedSampler : register(s1, space1000);

SamplerState D3DStaticBilinearClampedSampler : register(s3, space1000);

SamplerState D3DStaticTrilinearWrappedSampler : register(s4, space1000);

SamplerState D3DStaticTrilinearClampedSampler : register(s5, space1000);

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
  int _217;
  int _257;
  int _259;
  int _302;
  int _342;
  int _344;
  float _350;
  int _351;
  int _352;
  float _353;
  float _354;
  float _407;
  float _408;
  int _409;
  float _552;
  float _561;
  float _562;
  float _598;
  float _599;
  int _600;
  float _601;
  float _610;
  int _611;
  float _704;
  float _750;
  float _800;
  float _846;
  float _893;
  float _940;
  float _956;
  float _957;
  float _958;
  int _1039;
  int _1040;
  int _1041;
  int _1042;
  float _1043;
  float _1044;
  float _1045;
  float _1046;
  float _1047;
  int _1048;
  int _1157;
  int _1166;
  int _1175;
  int _1179;
  int _1180;
  int _1222;
  float _1227;
  float _1228;
  float _1229;
  float _1230;
  float _1231;
  int _1232;
  int _1233;
  int _1234;
  int _1235;
  float _1250;
  float _1251;
  float _1252;
  float _1253;
  float _1254;
  int _1255;
  int _1256;
  int _1257;
  float _1479;
  float _1505;
  float _1544;
  float _1545;
  float _1546;
  float _1547;
  float _1548;
  int _1549;
  int _1550;
  int _1551;
  float _1554;
  float _1555;
  float _1556;
  float _1557;
  float _1558;
  int _1559;
  int _1560;
  int _1561;
  float _1569;
  float _1570;
  float _1571;
  float _1572;
  int _1573;
  int _1574;
  int _1575;
  float _1577;
  float _1578;
  float _1579;
  float _1580;
  int _1581;
  int _1582;
  int _1583;
  float _1616;
  float _1617;
  float _1618;
  float _1619;
  float _1620;
  float _1621;
  float _1622;
  float _1623;
  float _1626;
  float _1627;
  float _1628;
  float _1629;
  float _1630;
  float _1631;
  float _1632;
  float _1633;
  float _1816;
  float _1817;
  float _1818;
  int _1879;
  float _1925;
  float _1926;
  float _1927;
  float _1993;
  float _1994;
  float _1995;
  float _1996;
  float _2094;
  float _2173;
  float _2195;
  int _2196;
  bool _2259;
  bool _2260;
  bool _2261;
  bool _2262;
  float _2263;
  int _2264;
  float _2282;
  float _2359;
  float _2360;
  float _2431;
  float _2432;
  float _2433;
  int _2434;
  float _2438;
  float _2439;
  float _2440;
  int _2441;
  int _2465;
  int _2522;
  float _2615;
  float _2710;
  float _2711;
  float _2712;
  float _2746;
  float _2836;
  float _2837;
  float _2838;
  float _2872;
  float _2962;
  float _2963;
  float _2964;
  float _2994;
  float _3084;
  float _3085;
  float _3086;
  float _3121;
  float _3211;
  float _3212;
  float _3213;
  float _3243;
  float _3333;
  float _3334;
  float _3335;
  float _3365;
  float _3455;
  float _3456;
  float _3457;
  float _3487;
  float _3577;
  float _3578;
  float _3579;
  float _3686;
  float _3687;
  float _3688;
  float _3689;
  float _3690;
  float _3727;
  float _3728;
  float _3729;
  float _3807;
  float _3838;
  float _3839;
  float _3840;
  float _3841;
  float _3910;
  float _3911;
  float _3912;
  float _3997;
  float _3998;
  float _3999;
  float _4011;
  float _4012;
  float _4013;
  float _4045;
  float _4046;
  float _4047;
  float _4059;
  float _4060;
  float _4061;
  float _4077;
  float _4089;
  float _4101;
  uint _59;
  int _61;
  int _63;
  float _67;
  float4 _96;
  float _105;
  float _106;
  bool _134;
  float _135;
  float _136;
  float _140;
  float _144;
  float _148;
  float _168;
  float _173;
  float _178;
  float4 _181;
  float _190;
  float _196;
  float _197;
  float _198;
  bool _205;
  float _209;
  float _210;
  float _211;
  float4 _219;
  uint _252;
  float4 _261;
  float _268;
  float _271;
  float _272;
  float _273;
  float _282;
  float _294;
  float _295;
  float _296;
  float4 _304;
  uint _337;
  float4 _356;
  float _360;
  float _364;
  float _368;
  float _369;
  float _370;
  float _371;
  float _373;
  float _375;
  float _377;
  float _378;
  float _379;
  float _383;
  float _384;
  float _385;
  float _399;
  float _401;
  float _405;
  float _413;
  float _414;
  float _415;
  float4 _417;
  float _431;
  float _432;
  float _433;
  float4 _435;
  float4 _443;
  float4 _459;
  float _472;
  uint _483;
  int _491;
  int _493;
  int _495;
  float _499;
  float _500;
  float _501;
  float _563;
  float _575;
  float _589;
  int _594;
  uint _602;
  float _617;
  float _618;
  float _619;
  float4 _624;
  float _638;
  float _639;
  float _640;
  float _643;
  float _645;
  float _646;
  float _647;
  float _653;
  float _658;
  int _661;
  int _662;
  uint _664;
  float _706;
  uint _710;
  float _752;
  float _753;
  int _758;
  uint _760;
  float _802;
  uint _806;
  float _848;
  uint _853;
  float _895;
  uint _900;
  float _941;
  float _942;
  float _943;
  float _949;
  float4 _960;
  float _962;
  float _984;
  float _985;
  float _986;
  uint _991;
  uint _1004;
  uint _1005;
  uint _1006;
  int _1028;
  int _1029;
  int _1030;
  int _1031;
  int _1053;
  float _1058;
  uint _1060;
  float _1063;
  float _1064;
  float _1065;
  float _1068;
  float _1069;
  float _1070;
  float _1071;
  float _1074;
  float _1075;
  float _1076;
  float _1077;
  float _1080;
  float _1081;
  float _1082;
  float _1083;
  float _1086;
  float _1087;
  float _1088;
  float _1089;
  int _1090;
  int _1091;
  float _1094;
  float _1095;
  float _1096;
  float _1097;
  bool _1099;
  float _1115;
  float _1116;
  float _1120;
  float _1124;
  float _1128;
  float _1131;
  float _1134;
  float _1137;
  float _1140;
  float _1143;
  float _1146;
  float _1147;
  float _1148;
  float _1149;
  int _1181;
  uint _1183;
  uint _1186;
  float _1190;
  float _1193;
  float _1196;
  float _1199;
  float _1200;
  float _1201;
  float _1208;
  int _1218;
  int _1223;
  int _1236;
  uint _1238;
  uint _1240;
  uint _1241;
  float _1245;
  int _1246;
  float _1264;
  float _1265;
  float _1266;
  float _1275;
  float _1276;
  float _1277;
  int _1279;
  float _1280;
  float _1281;
  float _1282;
  float _1283;
  float _1284;
  float _1285;
  float _1286;
  float _1287;
  float _1288;
  float _1289;
  float _1290;
  float _1291;
  float _1292;
  float _1293;
  float _1294;
  float _1297;
  float _1300;
  float _1303;
  float _1307;
  float _1320;
  float _1321;
  float _1322;
  float _1323;
  float _1338;
  float _1339;
  int _1341;
  int _1342;
  int _1358;
  int _1359;
  int _1365;
  int _1366;
  bool _1373;
  bool _1374;
  int _1375;
  int _1376;
  float _1379;
  float _1380;
  uint _1381;
  uint _1382;
  float _1389;
  float _1390;
  float _1396;
  float _1398;
  float _1422;
  float _1423;
  uint _1433;
  uint _1434;
  uint _1435;
  float _1463;
  float _1464;
  float _1465;
  float _1468;
  float4 _1484;
  float _1491;
  float _1492;
  float _1493;
  bool _1494;
  bool _1506;
  float _1510;
  float _1511;
  float _1512;
  float _1513;
  float4 _1515;
  float4 _1520;
  float4 _1525;
  float _1536;
  float _1537;
  float _1538;
  float _1539;
  int _1562;
  int _1566;
  float _1586;
  float _1587;
  float _1588;
  int _1605;
  bool _1634;
  int _1636;
  float _1641;
  float _1642;
  float _1643;
  float _1657;
  float _1676;
  float _1677;
  float _1678;
  float _1679;
  float _1691;
  float _1692;
  float4 _1695;
  float _1707;
  float _1712;
  float _1713;
  float _1714;
  float _1716;
  bool _1720;
  float _1778;
  float4 _1786;
  float _1819;
  float _1820;
  float _1827;
  float _1828;
  float _1836;
  float _1837;
  float _1844;
  float _1854;
  bool _1855;
  float4 _1901;
  float _1929;
  float _1935;
  float _1936;
  float _1937;
  float4 _1939;
  float _1944;
  float _1948;
  float _1949;
  float _1950;
  float _1957;
  float _1958;
  float _1959;
  float _1966;
  float _1967;
  float _1968;
  float _1980;
  float _2022;
  float _2026;
  float _2030;
  float _2034;
  float _2037;
  float _2046;
  float _2056;
  float _2064;
  float _2065;
  float _2067;
  float _2076;
  float _2098;
  float _2099;
  float _2100;
  float _2117;
  float _2118;
  float _2119;
  float _2120;
  float _2121;
  float _2134;
  float _2135;
  float _2141;
  float _2160;
  float _2161;
  float _2166;
  float _2180;
  float _2183;
  float _2186;
  float _2187;
  float _2191;
  float _2192;
  float _2193;
  float _2197;
  float _2198;
  float _2205;
  float _2212;
  float _2219;
  float _2236;
  float _2237;
  float _2238;
  float _2239;
  bool _2248;
  bool _2249;
  bool _2250;
  int _2256;
  float _2265;
  float _2273;
  float _2288;
  float _2298;
  float _2299;
  int _2300;
  float _2306;
  float _2307;
  float _2335;
  float4 _2341;
  float _2361;
  float _2362;
  float _2369;
  float _2370;
  float _2380;
  float _2381;
  int _2387;
  float4 _2409;
  float _2423;
  float _2451;
  float4 _2467;
  float4 _2473;
  float _2477;
  float _2478;
  float _2479;
  float _2493;
  uint _2513;
  float4 _2524;
  float4 _2530;
  float _2539;
  float _2545;
  float _2547;
  float _2549;
  float _2551;
  int _2555;
  int _2556;
  int _2557;
  float _2558;
  float _2559;
  float _2560;
  uint _2564;
  uint _2565;
  uint _2567;
  float4 _2577;
  float _2581;
  float _2582;
  float _2583;
  float _2586;
  float _2587;
  float _2588;
  float _2594;
  float _2595;
  float _2596;
  float _2597;
  float _2599;
  float _2601;
  float _2602;
  float _2605;
  float _2607;
  float _2619;
  float _2620;
  float _2621;
  float _2625;
  float _2627;
  float _2628;
  float _2629;
  float _2630;
  float _2631;
  float _2632;
  float _2635;
  float _2639;
  float _2650;
  float _2655;
  float _2656;
  bool _2657;
  float _2661;
  float3 _2705;
  float _2713;
  float _2714;
  float _2715;
  uint _2716;
  uint _2717;
  float _2721;
  float _2723;
  float _2724;
  float _2725;
  float _2729;
  float _2730;
  float _2731;
  float _2734;
  float _2738;
  float _2750;
  float _2751;
  float _2752;
  float _2756;
  float _2758;
  float _2759;
  float _2760;
  float _2761;
  float _2762;
  float _2763;
  float _2766;
  float _2770;
  float _2781;
  float _2786;
  float _2787;
  bool _2788;
  float3 _2831;
  uint _2842;
  uint _2843;
  float _2847;
  float _2849;
  float _2850;
  float _2851;
  float _2855;
  float _2856;
  float _2857;
  float _2860;
  float _2864;
  float _2876;
  float _2877;
  float _2878;
  float _2882;
  float _2884;
  float _2885;
  float _2886;
  float _2887;
  float _2888;
  float _2889;
  float _2892;
  float _2896;
  float _2907;
  float _2912;
  float _2913;
  bool _2914;
  float3 _2957;
  float _2965;
  float _2966;
  float _2967;
  uint _2968;
  float _2971;
  float _2972;
  float _2973;
  float _2977;
  float _2978;
  float _2979;
  float _2982;
  float _2986;
  float _2998;
  float _2999;
  float _3000;
  float _3004;
  float _3006;
  float _3007;
  float _3008;
  float _3009;
  float _3010;
  float _3011;
  float _3014;
  float _3018;
  float _3029;
  float _3034;
  float _3035;
  bool _3036;
  float3 _3079;
  uint _3090;
  uint _3091;
  uint _3092;
  float _3096;
  float _3098;
  float _3099;
  float _3100;
  float _3104;
  float _3105;
  float _3106;
  float _3109;
  float _3113;
  float _3125;
  float _3126;
  float _3127;
  float _3131;
  float _3133;
  float _3134;
  float _3135;
  float _3136;
  float _3137;
  float _3138;
  float _3141;
  float _3145;
  float _3156;
  float _3161;
  float _3162;
  bool _3163;
  float3 _3206;
  float _3214;
  float _3215;
  float _3216;
  uint _3217;
  float _3220;
  float _3221;
  float _3222;
  float _3226;
  float _3227;
  float _3228;
  float _3231;
  float _3235;
  float _3247;
  float _3248;
  float _3249;
  float _3253;
  float _3255;
  float _3256;
  float _3257;
  float _3258;
  float _3259;
  float _3260;
  float _3263;
  float _3267;
  float _3278;
  float _3283;
  float _3284;
  bool _3285;
  float3 _3328;
  uint _3339;
  float _3342;
  float _3343;
  float _3344;
  float _3348;
  float _3349;
  float _3350;
  float _3353;
  float _3357;
  float _3369;
  float _3370;
  float _3371;
  float _3375;
  float _3377;
  float _3378;
  float _3379;
  float _3380;
  float _3381;
  float _3382;
  float _3385;
  float _3389;
  float _3400;
  float _3405;
  float _3406;
  bool _3407;
  float3 _3450;
  float _3458;
  float _3459;
  float _3460;
  uint _3461;
  float _3464;
  float _3465;
  float _3466;
  float _3470;
  float _3471;
  float _3472;
  float _3475;
  float _3479;
  float _3491;
  float _3492;
  float _3493;
  float _3497;
  float _3499;
  float _3500;
  float _3501;
  float _3502;
  float _3503;
  float _3504;
  float _3507;
  float _3511;
  float _3522;
  float _3527;
  float _3528;
  bool _3529;
  float3 _3572;
  float _3589;
  float _3590;
  float _3591;
  float _3604;
  float _3605;
  float _3606;
  float _3622;
  float _3623;
  float _3624;
  float _3643;
  float _3644;
  float _3645;
  float4 _3668;
  float4 _3708;
  float _3722;
  float _3735;
  float _3736;
  float _3737;
  float _3742;
  float _3743;
  float _3754;
  float _3757;
  float _3758;
  float _3760;
  float _3761;
  float _3762;
  float _3763;
  float _3764;
  float _3799;
  float _3809;
  float _3814;
  float _3815;
  float _3816;
  float _3843;
  float _3855;
  float _3866;
  float _3879;
  float _3884;
  float _3885;
  float4 _3888;
  float4 _3893;
  float4 _3924;
  float _3948;
  float _3964;
  float _3965;
  float _3966;
  float _3967;
  float _3989;
  float _4006;
  bool _4022;
  float _4026;
  float _4027;
  float _4037;
  float _4049;
  float _4054;
  bool _4078;
  bool _4090;
  float _4102;
  float _4103;
  float _4104;
  float _4105;
  float _4106;
  float _4107;
  int __loop_jump_target = -1;
  int _51[6];
  int _52[4];
  if ((uint)(int)(SV_DispatchThreadID.x) < (uint)(((uint)(CompactedTraceTexelAllocator.Load(0))).x)) {
    _59 = CompactedTraceTexelData.Load((int)(SV_DispatchThreadID.x));
    _61 = _59.x & 4095;
    _63 = ((uint)((uint)(_59.x)) >> 12) & 4095;
    _67 = abs((RWTraceHit.Load(int3(_61, _63, 0))).x);
    _96 = DownsampledDepth.Load(int4(_61, _63, 0, 0));
    _105 = ((asfloat(View_raw[139u].z) * min(((asfloat(View_raw[135u].x) + 0.5f) + float((uint)(asint(_RootShaderParameters_raw[17u].x) * _61))), ((asfloat(View_raw[135u].x) + -1.0f) + asfloat(View_raw[136u].x)))) - asfloat(View_raw[67u].w)) / asfloat(View_raw[67u].x);
    _106 = ((asfloat(View_raw[139u].w) * min(((asfloat(View_raw[135u].y) + 0.5f) + float((uint)(asint(_RootShaderParameters_raw[17u].x) * _63))), ((asfloat(View_raw[135u].y) + -1.0f) + asfloat(View_raw[136u].y)))) - asfloat(View_raw[67u].z)) / asfloat(View_raw[67u].y);
    _134 = (asfloat(View_raw[31u].w) >= 1.0f);
    _135 = select(_134, _105, (_105 * _96.x));
    _136 = select(_134, _106, (_106 * _96.x));
    _140 = (asfloat(View_raw[60u].x) + asfloat(View_raw[51u].x)) + mad(_96.x, asfloat(View_raw[50u].x), mad(_136, asfloat(View_raw[49u].x), (_135 * asfloat(View_raw[48u].x))));
    _144 = (asfloat(View_raw[60u].y) + asfloat(View_raw[51u].y)) + mad(_96.x, asfloat(View_raw[50u].y), mad(_136, asfloat(View_raw[49u].y), (_135 * asfloat(View_raw[48u].y))));
    _148 = (asfloat(View_raw[60u].z) + asfloat(View_raw[51u].z)) + mad(_96.x, asfloat(View_raw[50u].z), mad(_136, asfloat(View_raw[49u].z), (_135 * asfloat(View_raw[48u].z))));
    _168 = mad(_96.x, asfloat(View_raw[54u].x), mad(_136, asfloat(View_raw[53u].x), (_135 * asfloat(View_raw[52u].x)))) + asfloat(View_raw[55u].x);
    _173 = mad(_96.x, asfloat(View_raw[54u].y), mad(_136, asfloat(View_raw[53u].y), (_135 * asfloat(View_raw[52u].y)))) + asfloat(View_raw[55u].y);
    _178 = mad(_96.x, asfloat(View_raw[54u].z), mad(_136, asfloat(View_raw[53u].z), (_135 * asfloat(View_raw[52u].z)))) + asfloat(View_raw[55u].z);
    _181 = RayBuffer.Load(int4(_61, _63, 0, 0));
    _190 = f16tof32(((uint)((((uint)(RayTraceDistance.Load(int4(_61, _63, 0, 0)))).x) & 32767)));
    _196 = (asfloat(_RootShaderParameters_raw[33u].x) * _181.x) + _168;
    _197 = (asfloat(_RootShaderParameters_raw[33u].x) * _181.y) + _173;
    _198 = (asfloat(_RootShaderParameters_raw[33u].x) * _181.z) + _178;
    _205 = (asint(_RootShaderParameters_raw[19u].z) != 0);
    _209 = (_181.x * _67) + _168;
    _210 = (_181.y * _67) + _173;
    _211 = (_181.z * _67) + _178;
    if (!(asint(View_raw[234u].z) == 0)) {
      _217 = 0;
      while(true) {
        _219 = asfloat(View_raw[((uint)(_217 + 207u))]);
        if (!(min(min(max(((_219.w + _209) - _219.x), 0.0f), max(((_219.w - _209) + _219.x), 0.0f)), min(min(max(((_219.w + _210) - _219.y), 0.0f), max(((_219.w - _210) + _219.y), 0.0f)), min(max(((_219.w + _211) - _219.z), 0.0f), max(((_219.w - _211) + _219.z), 0.0f)))) > (asfloat(View_raw[234u].x) * _219.w))) {
          _252 = _217 + 1u;
          if ((uint)_252 < (uint)asint(View_raw[234u].z)) {
            _217 = _252;
            continue;
          } else {
            _257 = 0;
          }
        } else {
          _257 = _217;
        }
        _259 = _257;
        break;
      }
    } else {
      _259 = 0;
    }
    _261 = asfloat(View_raw[((uint)(_259 + 207u))]);
    _268 = max((_67 - ((_261.w * 4.0f) * asfloat(View_raw[234u].x))), 0.0f);
    _271 = float((uint)(uint)(asint(_RootShaderParameters_raw[20u].z)));
    _272 = float((uint)_61);
    _273 = float((uint)_63);
    if (InjectionToggle(TOGGLE_USE_ISFAST_REFLECTIONS)) {
      _282 = ISFASTNoiseLoad(uint(_61) % 128u, uint(_63) % 128u, uint(float(InjectionFrameIndex())) % 32u).x * 0.10263162851333618f;
    } else {
      _282 = frac(frac(dot(float2(((_271 * 32.665000915527344f) + _272), ((_271 * 11.8149995803833f) + _273)), float2(0.0671105608344078f, 0.005837149918079376f))) * 52.98291778564453f) * 0.10263162851333618f;
    }
    if (_268 < _190) {
      _294 = (_268 * _181.x) + _196;
      _295 = (_268 * _181.y) + _197;
      _296 = (_268 * _181.z) + _198;
      if (!(asint(View_raw[234u].z) == 0)) {
        _302 = 0;
        while(true) {
          _304 = asfloat(View_raw[((uint)(_302 + 207u))]);
          if (!(min(min(max(((_304.w + _294) - _304.x), 0.0f), max(((_304.w - _294) + _304.x), 0.0f)), min(min(max(((_304.w + _295) - _304.y), 0.0f), max(((_304.w - _295) + _304.y), 0.0f)), min(max(((_304.w + _296) - _304.z), 0.0f), max(((_304.w - _296) + _304.z), 0.0f)))) > (asfloat(View_raw[234u].x) * _304.w))) {
            _337 = _302 + 1u;
            if ((uint)_337 < (uint)asint(View_raw[234u].z)) {
              _302 = _337;
              continue;
            } else {
              _342 = 0;
            }
          } else {
            _342 = _302;
          }
          _344 = _342;
          break;
        }
      } else {
        _344 = 0;
      }
      if ((uint)_344 < (uint)asint(View_raw[234u].z)) {
        _350 = -1.0f;
        _351 = 0;
        _352 = _344;
        _353 = _268;
        _354 = 0.0f;
        while(true) {
          _598 = _354;
          _599 = _353;
          _600 = _351;
          _601 = _350;
          _356 = asfloat(View_raw[((uint)(_352 + 207u))]);
          _360 = asfloat(View_raw[234u].x) * _356.w;
          _364 = _356.w - _360;
          _368 = 1.0f / (_190 * _181.x);
          _369 = 1.0f / (_190 * _181.y);
          _370 = 1.0f / (_190 * _181.z);
          _371 = _356.x - _196;
          _373 = _356.y - _197;
          _375 = _356.z - _198;
          _377 = (_371 - _364) * _368;
          _378 = (_373 - _364) * _369;
          _379 = (_375 - _364) * _370;
          _383 = (_371 + _364) * _368;
          _384 = (_373 + _364) * _369;
          _385 = (_375 + _364) * _370;
          _399 = saturate(min(max(_377, _383), min(max(_378, _384), max(_379, _385)))) * _190;
          _401 = max(max((saturate(max(min(_377, _383), max(min(_378, _384), min(_379, _385)))) * _190), _353), 0.0f);
          if (_401 < _399) {
            _405 = (_356.w * 8.0f) * asfloat(View_raw[234u].x);
            _407 = _354;
            _408 = _401;
            _409 = 0;
            while(true) {
              _413 = (_408 * _181.x) + _196;
              _414 = (_408 * _181.y) + _197;
              _415 = (_408 * _181.z) + _198;
              _417 = asfloat(View_raw[((uint)(_352 + 213u))]);
              _431 = frac(frac((_417.w * _413) + _417.x));
              _432 = frac(frac((_417.w * _414) + _417.y));
              _433 = frac(frac((_417.w * _415) + _417.z));
              _435 = asfloat(View_raw[((uint)(_352 + 219u))]);
              _443 = asfloat(View_raw[((uint)(_352 + 225u))]);
              _459 = View_GlobalDistanceFieldMipTexture.SampleLevel(D3DStaticTrilinearClampedSampler, float3(saturate((_435.x * _413) + _443.x), saturate((_435.y * _414) + _443.y), min(max(saturate((_435.z * _415) + _443.z), _435.w), _443.w)), 0.0f);
              _472 = float((int)(asint(View_raw[231u].z)));
              _483 = View_GlobalDistanceFieldPageTableTexture.Load(int4(int(_472 * saturate(_431)), int(_472 * saturate(_432)), int(float((int)((int)(asint(View_raw[231u].z) * _352))) + (_472 * saturate(_433))), 0));
              if ((_483.x != -1) && (_459.x < asfloat(View_raw[231u].y))) {
                _491 = _483.x & 127;
                _493 = ((uint)((uint)(_483.x)) >> 7) & 127;
                _495 = ((uint)((uint)(_483.x)) >> 14) & 1023;
                _499 = frac(_472 * _431);
                _500 = frac(_472 * _432);
                _501 = frac(_472 * _433);
                if ((int)_483.x < (int)0) {
                  _552 = (((float4)(View_GlobalDistanceFieldCoverageAtlasTexture.SampleLevel(D3DStaticTrilinearWrappedSampler, float3((asfloat(View_raw[233u].x) * ((float((uint)((uint)(_491 << 2))) + 0.5f) + (_499 * 3.0f))), (asfloat(View_raw[233u].y) * ((float((uint)((uint)(_493 << 2))) + 0.5f) + (_500 * 3.0f))), (((float((uint)((uint)(_495 << 2))) + 0.5f) + (_501 * 3.0f)) * asfloat(View_raw[233u].z))), 0.0f))).x);
                } else {
                  _552 = 1.0f;
                }
                _561 = ((((((float4)(View_GlobalDistanceFieldPageAtlasTexture.SampleLevel(D3DStaticTrilinearWrappedSampler, float3((asfloat(View_raw[232u].x) * ((float((uint)((uint)(_491 << 3))) + 0.5f) + (_499 * 7.0f))), (((float((uint)((uint)(_493 << 3))) + 0.5f) + (_500 * 7.0f)) * asfloat(View_raw[232u].y)), (((float((uint)((uint)(_495 << 3))) + 0.5f) + (_501 * 7.0f)) * asfloat(View_raw[232u].z))), 0.0f))).x) * 2.0f) + -1.0f) * _405);
                _562 = _552;
              } else {
                _561 = ((asfloat(View_raw[231u].x) * _405) * ((_459.x * 2.0f) + -1.0f));
                _562 = 1.0f;
              }
              _563 = max(_561, _407);
              _575 = (saturate(_563 / (_360 * 2.0f)) * _360) * (((asfloat(View_raw[234u].w) - asfloat(View_raw[235u].x)) * _562) + asfloat(View_raw[235u].x));
              if (_561 < _575) {
                _598 = _563;
                _599 = _399;
                _600 = _352;
                _601 = max(((_561 + _408) - _575), 0.0f);
              } else {
                _589 = max((_561 * ((_282 + 0.949999988079071f) + ((0.050000011920928955f - _282) * saturate(_181.w * 81.4873275756836f)))), ((((1.0f - asfloat(View_raw[235u].y)) * _562) + asfloat(View_raw[235u].y)) * _360)) + _408;
                if ((_350 >= 0.0f) || (_589 > _399)) {
                  _598 = _563;
                  _599 = _399;
                  _600 = _351;
                  _601 = _350;
                } else {
                  _594 = _409 + 1;
                  if ((uint)_594 < (uint)256) {
                    _407 = _563;
                    _408 = _589;
                    _409 = _594;
                    continue;
                  } else {
                    _598 = _563;
                    _599 = _399;
                    _600 = _351;
                    _601 = _350;
                  }
                }
              }
              break;
            }
          } else {
            _598 = _354;
            _599 = _353;
            _600 = _351;
            _601 = _350;
          }
          _602 = _352 + 1u;
          if ((_601 < 0.0f) && ((uint)_602 < (uint)asint(View_raw[234u].z))) {
            _350 = _601;
            _351 = _600;
            _352 = _602;
            _353 = _599;
            _354 = _598;
            continue;
          }
          _610 = _601;
          _611 = _600;
          break;
        }
      } else {
        _610 = -1.0f;
        _611 = 0;
      }
      if (!(_610 < 0.0f)) {
        _617 = (_610 * _181.x) + _196;
        _618 = (_610 * _181.y) + _197;
        _619 = (_610 * _181.z) + _198;
        _624 = asfloat(View_raw[((uint)(_611 + 213u))]);
        _638 = frac(frac((_624.w * _617) + _624.x));
        _639 = frac(frac((_624.w * _618) + _624.y));
        _640 = frac(frac((_624.w * _619) + _624.z));
        _643 = asfloat(View_raw[234u].x) * 0.5f;
        _645 = frac(_643 + _638);
        _646 = frac(_639);
        _647 = frac(_640);
        _653 = float((int)(asint(View_raw[231u].z)));
        _658 = float((int)((int)(asint(View_raw[231u].z) * _611)));
        _661 = int(_653 * saturate(_646));
        _662 = int(_658 + (_653 * saturate(_647)));
        _664 = View_GlobalDistanceFieldPageTableTexture.Load(int4(int(_653 * saturate(_645)), _661, _662, 0));
        if (!(_664.x == -1)) {
          _704 = (((float4)(View_GlobalDistanceFieldPageAtlasTexture.SampleLevel(D3DStaticTrilinearWrappedSampler, float3((asfloat(View_raw[232u].x) * ((float((uint)((uint)(((int)(_664.x << 3)) & 1016))) + 0.5f) + (frac(_653 * _645) * 7.0f))), (((float((uint)((uint)(((uint)((uint)(_664.x)) >> 4) & 1016))) + 0.5f) + (frac(_653 * _646) * 7.0f)) * asfloat(View_raw[232u].y)), (((float((uint)((uint)(((uint)((uint)(_664.x)) >> 11) & 8184))) + 0.5f) + (frac(_653 * _647) * 7.0f)) * asfloat(View_raw[232u].z))), 0.0f))).x);
        } else {
          _704 = 1.0f;
        }
        _706 = frac(_638 - _643);
        _710 = View_GlobalDistanceFieldPageTableTexture.Load(int4(int(_653 * saturate(_706)), _661, _662, 0));
        if (!(_710.x == -1)) {
          _750 = (((float4)(View_GlobalDistanceFieldPageAtlasTexture.SampleLevel(D3DStaticTrilinearWrappedSampler, float3((asfloat(View_raw[232u].x) * ((float((uint)((uint)(((int)(_710.x << 3)) & 1016))) + 0.5f) + (frac(_653 * _706) * 7.0f))), (((float((uint)((uint)(((uint)((uint)(_710.x)) >> 4) & 1016))) + 0.5f) + (frac(_653 * _646) * 7.0f)) * asfloat(View_raw[232u].y)), (((float((uint)((uint)(((uint)((uint)(_710.x)) >> 11) & 8184))) + 0.5f) + (frac(_653 * _647) * 7.0f)) * asfloat(View_raw[232u].z))), 0.0f))).x);
        } else {
          _750 = 1.0f;
        }
        _752 = frac(_638);
        _753 = frac(_643 + _639);
        _758 = int(_653 * saturate(_752));
        _760 = View_GlobalDistanceFieldPageTableTexture.Load(int4(_758, int(_653 * saturate(_753)), _662, 0));
        if (!(_760.x == -1)) {
          _800 = (((float4)(View_GlobalDistanceFieldPageAtlasTexture.SampleLevel(D3DStaticTrilinearWrappedSampler, float3((asfloat(View_raw[232u].x) * ((float((uint)((uint)(((int)(_760.x << 3)) & 1016))) + 0.5f) + (frac(_653 * _752) * 7.0f))), (((float((uint)((uint)(((uint)((uint)(_760.x)) >> 4) & 1016))) + 0.5f) + (frac(_653 * _753) * 7.0f)) * asfloat(View_raw[232u].y)), (((float((uint)((uint)(((uint)((uint)(_760.x)) >> 11) & 8184))) + 0.5f) + (frac(_653 * _647) * 7.0f)) * asfloat(View_raw[232u].z))), 0.0f))).x);
        } else {
          _800 = 1.0f;
        }
        _802 = frac(_639 - _643);
        _806 = View_GlobalDistanceFieldPageTableTexture.Load(int4(_758, int(_653 * saturate(_802)), _662, 0));
        if (!(_806.x == -1)) {
          _846 = (((float4)(View_GlobalDistanceFieldPageAtlasTexture.SampleLevel(D3DStaticTrilinearWrappedSampler, float3((asfloat(View_raw[232u].x) * ((float((uint)((uint)(((int)(_806.x << 3)) & 1016))) + 0.5f) + (frac(_653 * _752) * 7.0f))), (((float((uint)((uint)(((uint)((uint)(_806.x)) >> 4) & 1016))) + 0.5f) + (frac(_653 * _802) * 7.0f)) * asfloat(View_raw[232u].y)), (((float((uint)((uint)(((uint)((uint)(_806.x)) >> 11) & 8184))) + 0.5f) + (frac(_653 * _647) * 7.0f)) * asfloat(View_raw[232u].z))), 0.0f))).x);
        } else {
          _846 = 1.0f;
        }
        _848 = frac(_643 + _640);
        _853 = View_GlobalDistanceFieldPageTableTexture.Load(int4(_758, _661, int(_658 + (_653 * saturate(_848))), 0));
        if (!(_853.x == -1)) {
          _893 = (((float4)(View_GlobalDistanceFieldPageAtlasTexture.SampleLevel(D3DStaticTrilinearWrappedSampler, float3((asfloat(View_raw[232u].x) * ((float((uint)((uint)(((int)(_853.x << 3)) & 1016))) + 0.5f) + (frac(_653 * _752) * 7.0f))), (((float((uint)((uint)(((uint)((uint)(_853.x)) >> 4) & 1016))) + 0.5f) + (frac(_653 * _646) * 7.0f)) * asfloat(View_raw[232u].y)), (((float((uint)((uint)(((uint)((uint)(_853.x)) >> 11) & 8184))) + 0.5f) + (frac(_653 * _848) * 7.0f)) * asfloat(View_raw[232u].z))), 0.0f))).x);
        } else {
          _893 = 1.0f;
        }
        _895 = frac(_640 - _643);
        _900 = View_GlobalDistanceFieldPageTableTexture.Load(int4(_758, _661, int(_658 + (_653 * saturate(_895))), 0));
        if (!(_900.x == -1)) {
          _940 = (((float4)(View_GlobalDistanceFieldPageAtlasTexture.SampleLevel(D3DStaticTrilinearWrappedSampler, float3((asfloat(View_raw[232u].x) * ((float((uint)((uint)(((int)(_900.x << 3)) & 1016))) + 0.5f) + (frac(_653 * _752) * 7.0f))), (((float((uint)((uint)(((uint)((uint)(_900.x)) >> 4) & 1016))) + 0.5f) + (frac(_653 * _646) * 7.0f)) * asfloat(View_raw[232u].y)), (((float((uint)((uint)(((uint)((uint)(_900.x)) >> 11) & 8184))) + 0.5f) + (frac(_653 * _895) * 7.0f)) * asfloat(View_raw[232u].z))), 0.0f))).x);
        } else {
          _940 = 1.0f;
        }
        _941 = _704 - _750;
        _942 = _800 - _846;
        _943 = _893 - _940;
        _949 = sqrt(((_942 * _942) + (_941 * _941)) + (_943 * _943));
        if (_949 > 0.0010000000474974513f) {
          _956 = (_941 / _949);
          _957 = (_942 / _949);
          _958 = (_943 / _949);
        } else {
          _956 = (-0.0f - _181.x);
          _957 = (-0.0f - _181.y);
          _958 = (-0.0f - _181.z);
        }
        _960 = asfloat(View_raw[((uint)(_611 + 207u))]);
        _962 = asfloat(View_raw[234u].x) * _960.w;
        _984 = _653 * saturate(frac(frac((((_962 * _956) + _617) * _624.w) + _624.x)));
        _985 = _653 * saturate(frac(frac((((_962 * _957) + _618) * _624.w) + _624.y)));
        _986 = _653 * saturate(frac(frac((((_962 * _958) + _619) * _624.w) + _624.z)));
        _991 = View_GlobalDistanceFieldPageTableTexture.Load(int4(int(_984), int(_985), int(_658 + _986), 0));
        if (!(_991.x == -1)) {
          _1004 = uint(frac(frac(_984)) * 4.0f);
          _1005 = uint(frac(frac(_985)) * 4.0f);
          _1006 = uint(frac(frac(_986)) * 4.0f);
          _1028 = GlobalDistanceFieldPageObjectGridBuffer[(((((((_1004 & 1) | (((int)(_991.x << 6)) & 1073741760)) | (((int)(_1004 << 2)) & 8)) | (((int)(_1005 << 1)) & 2)) | (((int)(_1005 << 3)) & 16)) | (((int)(_1006 << 2)) & 4)) | (((int)(_1006 << 4)) & 32))].x;
          _1029 = GlobalDistanceFieldPageObjectGridBuffer[(((((((_1004 & 1) | (((int)(_991.x << 6)) & 1073741760)) | (((int)(_1004 << 2)) & 8)) | (((int)(_1005 << 1)) & 2)) | (((int)(_1005 << 3)) & 16)) | (((int)(_1006 << 2)) & 4)) | (((int)(_1006 << 4)) & 32))].y;
          _1030 = GlobalDistanceFieldPageObjectGridBuffer[(((((((_1004 & 1) | (((int)(_991.x << 6)) & 1073741760)) | (((int)(_1004 << 2)) & 8)) | (((int)(_1005 << 1)) & 2)) | (((int)(_1005 << 3)) & 16)) | (((int)(_1006 << 2)) & 4)) | (((int)(_1006 << 4)) & 32))].z;
          _1031 = GlobalDistanceFieldPageObjectGridBuffer[(((((((_1004 & 1) | (((int)(_991.x << 6)) & 1073741760)) | (((int)(_1004 << 2)) & 8)) | (((int)(_1005 << 1)) & 2)) | (((int)(_1005 << 3)) & 16)) | (((int)(_1006 << 2)) & 4)) | (((int)(_1006 << 4)) & 32))].w;
          _52[0] = _1028;
          _52[1] = _1029;
          _52[2] = _1030;
          _52[3] = _1031;
          if (!(_1028 == -1)) {
            _1039 = 0;
            _1040 = 0;
            _1041 = 0;
            _1042 = 0;
            _1043 = 0.0f;
            _1044 = 0.0f;
            _1045 = 0.0f;
            _1046 = 0.0f;
            _1047 = 0.0f;
            _1048 = _1028;
            while(true) {
              _1554 = _1047;
              _1555 = _1046;
              _1556 = _1045;
              _1557 = _1044;
              _1558 = _1043;
              _1559 = _1042;
              _1560 = _1041;
              _1561 = _1040;
              _1053 = asint(LumenCardScene_SceneInstanceIndexToMeshCardsIndexBuffer.Load((((int)(_1048 << 2)) & 67108860)));
              if ((uint)_1053 < (uint)LumenCardScene.NumMeshCards) {
                _1058 = _962 * 3.0f;
                _1060 = _1053 * 6;
                _1063 = LumenCardScene_MeshCardsData[_1060].x;
                _1064 = LumenCardScene_MeshCardsData[_1060].y;
                _1065 = LumenCardScene_MeshCardsData[_1060].z;
                _1068 = LumenCardScene_MeshCardsData[(_1060 | 1)].x;
                _1069 = LumenCardScene_MeshCardsData[(_1060 | 1)].y;
                _1070 = LumenCardScene_MeshCardsData[(_1060 | 1)].z;
                _1071 = LumenCardScene_MeshCardsData[(_1060 | 1)].w;
                _1074 = LumenCardScene_MeshCardsData[((int)(_1060 + 2u))].x;
                _1075 = LumenCardScene_MeshCardsData[((int)(_1060 + 2u))].y;
                _1076 = LumenCardScene_MeshCardsData[((int)(_1060 + 2u))].z;
                _1077 = LumenCardScene_MeshCardsData[((int)(_1060 + 2u))].w;
                _1080 = LumenCardScene_MeshCardsData[((int)(_1060 + 3u))].x;
                _1081 = LumenCardScene_MeshCardsData[((int)(_1060 + 3u))].y;
                _1082 = LumenCardScene_MeshCardsData[((int)(_1060 + 3u))].z;
                _1083 = LumenCardScene_MeshCardsData[((int)(_1060 + 3u))].w;
                _1086 = LumenCardScene_MeshCardsData[((int)(_1060 + 4u))].x;
                _1087 = LumenCardScene_MeshCardsData[((int)(_1060 + 4u))].y;
                _1088 = LumenCardScene_MeshCardsData[((int)(_1060 + 4u))].z;
                _1089 = LumenCardScene_MeshCardsData[((int)(_1060 + 4u))].w;
                _1090 = asint(_1086);
                _1091 = asint(_1087);
                _1094 = LumenCardScene_MeshCardsData[((int)(_1060 + 5u))].x;
                _1095 = LumenCardScene_MeshCardsData[((int)(_1060 + 5u))].y;
                _1096 = LumenCardScene_MeshCardsData[((int)(_1060 + 5u))].z;
                _1097 = LumenCardScene_MeshCardsData[((int)(_1060 + 5u))].w;
                _1099 = ((_1091 & 65536) != 0);
                _51[0] = asuint(_1088);
                _51[1] = asuint(_1089);
                _51[2] = asuint(_1094);
                _51[3] = asuint(_1095);
                _51[4] = asuint(_1096);
                _51[5] = asuint(_1097);
                _1115 = select(((_1091 & 131072) != 0), (_1058 + 50.0f), _1058);
                _1116 = _610 + asfloat(_RootShaderParameters_raw[33u].x);
                _1120 = ((_140 - _1063) - _1071) + (_1116 * _181.x);
                _1124 = ((_144 - _1064) - _1077) + (_1116 * _181.y);
                _1128 = ((_148 - _1065) - _1083) + (_1116 * _181.z);
                _1131 = mad(_1128, _1080, mad(_1124, _1074, (_1120 * _1068)));
                _1134 = mad(_1128, _1081, mad(_1124, _1075, (_1120 * _1069)));
                _1137 = mad(_1128, _1082, mad(_1124, _1076, (_1120 * _1070)));
                _1140 = mad(_958, _1080, mad(_957, _1074, (_1068 * _956)));
                _1143 = mad(_958, _1081, mad(_957, _1075, (_1069 * _956)));
                _1146 = mad(_958, _1082, mad(_957, _1076, (_1070 * _956)));
                _1147 = _1140 * _1140;
                _1148 = _1143 * _1143;
                _1149 = _1146 * _1146;
                if (_1147 > 0.0f) {
                  _1157 = (_51[min((uint)(((int)(uint)((int)(!(_1140 < 0.0f))))), 5u)]);
                } else {
                  _1157 = 0;
                }
                if (_1148 > 0.0f) {
                  _1166 = ((_51[min((uint)(select((_1143 < 0.0f), 2, 3)), 5u)]) | _1157);
                } else {
                  _1166 = _1157;
                }
                if (_1149 > 0.0f) {
                  _1175 = ((_51[min((uint)(select((_1146 < 0.0f), 4, 5)), 5u)]) | _1166);
                } else {
                  _1175 = _1166;
                }
                if (!(_1175 == 0)) {
                  _1179 = _1175;
                  _1180 = 0;
                  while(true) {
                    _1181 = firstbitlow(_1179);
                    _1183 = 1 << (_1181 & 31);
                    _1186 = ((int)(_1181 + _1090)) * 10;
                    _1190 = LumenCardScene_CardData[((int)(_1186 + 6u))].w;
                    _1193 = LumenCardScene_CardData[((int)(_1186 + 7u))].w;
                    _1196 = LumenCardScene_CardData[((int)(_1186 + 8u))].w;
                    _1199 = LumenCardScene_CardData[((int)(_1186 + 9u))].x;
                    _1200 = LumenCardScene_CardData[((int)(_1186 + 9u))].y;
                    _1201 = LumenCardScene_CardData[((int)(_1186 + 9u))].z;
                    _1208 = _1115 * 0.5f;
                    _1218 = select((((abs(_1131 - _1190) <= (_1199 + _1208)) && (abs(_1134 - _1193) <= (_1200 + _1208))) && (abs(_1137 - _1196) <= (_1201 + _1208))), _1183, 0) | _1180;
                    if (!(_1179 == _1183)) {
                      _1179 = (_1183 ^ _1179);
                      _1180 = _1218;
                      continue;
                    }
                    _1222 = _1218;
                    break;
                  }
                } else {
                  _1222 = 0;
                }
                _1223 = select(_1099, 1, _1222);
                if (!(_1223 == 0)) {
                  _1227 = _1047;
                  _1228 = _1046;
                  _1229 = _1045;
                  _1230 = _1044;
                  _1231 = _1043;
                  _1232 = _1042;
                  _1233 = _1041;
                  _1234 = _1040;
                  _1235 = _1223;
                  while(true) {
                    _1250 = _1227;
                    _1251 = _1228;
                    _1252 = _1229;
                    _1253 = _1230;
                    _1254 = _1231;
                    _1255 = _1232;
                    _1256 = _1233;
                    _1257 = _1234;
                    _1236 = firstbitlow(_1235);
                    _1238 = 1 << (_1236 & 31);
                    _1240 = _1236 + _1090;
                    _1241 = _1240 * 10;
                    _1245 = LumenCardScene_CardData[((int)(_1241 + 4u))].w;
                    _1246 = asint(_1245);
                    if (!((_1246 & 16777216) == 0)) {
                      if ((uint)_1240 < (uint)LumenCardScene.NumCards) {
                        _1264 = LumenCardScene_CardData[((int)(_1241 + 4u))].x;
                        _1265 = LumenCardScene_CardData[((int)(_1241 + 4u))].y;
                        _1266 = LumenCardScene_CardData[((int)(_1241 + 4u))].z;
                        _1275 = abs(_1264);
                        _1276 = abs(_1265);
                        _1277 = abs(_1266);
                        _1279 = ((uint)(_1246) >> 16) & 15;
                        _1280 = LumenCardScene_CardData[((int)(_1241 + 8u))].w;
                        _1281 = LumenCardScene_CardData[((int)(_1241 + 8u))].z;
                        _1282 = LumenCardScene_CardData[((int)(_1241 + 8u))].y;
                        _1283 = LumenCardScene_CardData[((int)(_1241 + 8u))].x;
                        _1284 = LumenCardScene_CardData[((int)(_1241 + 7u))].w;
                        _1285 = LumenCardScene_CardData[((int)(_1241 + 7u))].z;
                        _1286 = LumenCardScene_CardData[((int)(_1241 + 7u))].y;
                        _1287 = LumenCardScene_CardData[((int)(_1241 + 7u))].x;
                        _1288 = LumenCardScene_CardData[((int)(_1241 + 6u))].w;
                        _1289 = LumenCardScene_CardData[((int)(_1241 + 6u))].z;
                        _1290 = LumenCardScene_CardData[((int)(_1241 + 6u))].y;
                        _1291 = LumenCardScene_CardData[((int)(_1241 + 6u))].x;
                        _1292 = _1131 - _1288;
                        _1293 = _1134 - _1284;
                        _1294 = _1137 - _1280;
                        _1297 = mad(_1294, _1283, mad(_1293, _1287, (_1292 * _1291)));
                        _1300 = mad(_1294, _1282, mad(_1293, _1286, (_1292 * _1290)));
                        _1303 = mad(_1294, _1281, mad(_1293, _1285, (_1292 * _1289)));
                        _1307 = _1115 * 0.5f;
                        if (((abs(_1297) <= (_1275 + _1307)) && (abs(_1300) <= (_1276 + _1307))) && (abs(_1303) <= (_1277 + _1307))) {
                          _1320 = LumenCardScene_CardData[((int)(_1241 + 5u))].w;
                          _1321 = LumenCardScene_CardData[((int)(_1241 + 5u))].z;
                          _1322 = LumenCardScene_CardData[((int)(_1241 + 5u))].y;
                          _1323 = LumenCardScene_CardData[((int)(_1241 + 5u))].x;
                          _1338 = min(saturate(((min(max(_1297, (-0.0f - _1275)), _1275) / _1275) * 0.5f) + 0.5f), 0.9999989867210388f);
                          _1339 = min(saturate(0.5f - ((min(max(_1300, (-0.0f - _1276)), _1276) / _1276) * 0.5f)), 0.9999989867210388f);
                          _1341 = asint(select(_205, _1321, _1323));
                          _1342 = _1341 & 65535;
                          _1358 = asint(LumenCardScene_PageTableBuffer.Load2(((int)(((int)((uint(_1338 * float((uint)_1342)) + (uint)(asint(select(_205, _1320, _1322)))) + ((int)(uint(_1339 * float((uint)((uint)((uint)(_1341) >> 16))))) * _1342))) << 3)))).x;
                          _1359 = asint(LumenCardScene_PageTableBuffer.Load2(((int)(((int)((uint(_1338 * float((uint)_1342)) + (uint)(asint(select(_205, _1320, _1322)))) + ((int)(uint(_1339 * float((uint)((uint)((uint)(_1341) >> 16))))) * _1342))) << 3)))).y;
                          _1365 = ((uint)(_1358) >> 24) & 15;
                          _1366 = (uint)(_1358) >> 28;
                          _1373 = ((uint)_1365 > (uint)7);
                          _1374 = ((int)_1358 < (int)0);
                          _1375 = select(_1373, ((int)(1 << ((_1365 + 25) & 31))), 1);
                          _1376 = select(_1374, ((int)(1 << ((_1366 + 25) & 31))), 1);
                          _1379 = float((uint)_1375) * _1338;
                          _1380 = float((uint)_1376) * _1339;
                          _1381 = uint(_1379);
                          _1382 = uint(_1380);
                          _1389 = select((_1381 == 0), 0.0f, 0.5f);
                          _1390 = select((_1382 == 0), 0.0f, 0.5f);
                          _1396 = select(_1373, 128.0f, float((uint)(1 << _1365)));
                          _1398 = select(_1374, 128.0f, float((uint)(1 << _1366)));
                          _1422 = LumenCardScene.InvPhysicalAtlasSize.x * (min(max(((((_1396 - _1389) + select((((int)(_1381 + 1u)) == _1375), -0.0f, -0.5f)) * frac(_1379)) + _1389), 0.5f), (_1396 + -1.5f)) + float((uint)((uint)(((int)(_1358 << 3)) & 32760))));
                          _1423 = LumenCardScene.InvPhysicalAtlasSize.y * (min(max(((((_1398 - _1390) + select((((int)(_1382 + 1u)) == _1376), -0.0f, -0.5f)) * frac(_1380)) + _1390), 0.5f), (_1398 + -1.5f)) + float((uint)((uint)(((uint)(_1358) >> 9) & 32760))));
                          _1433 = uint(min(max((asfloat(_RootShaderParameters_raw[10u].x) + log2(max(_1275, _1276) / max((_610 * tan(asfloat(View_raw[247u].x) + _181.w)), 1.0f))), 3.0f), 11.0f));
                          _1434 = _1433 - ((uint)(_1246 & 255));
                          _1435 = _1433 - ((uint)(((uint)(_1246) >> 8) & 255));
                          _1463 = frac((LumenCardScene.PhysicalAtlasSize.x * _1422) + 0.501953125f);
                          _1464 = frac((LumenCardScene.PhysicalAtlasSize.y * _1423) + 0.501953125f);
                          _1465 = 1.0f - _1463;
                          _1468 = 1.0f - _1464;
                          if (!(_1365 == 0)) {
                            if (!_1099) {
                              if (!((uint)_1279 < (uint)2)) {
                                _1479 = select(((uint)_1279 < (uint)4), _1148, _1149);
                              } else {
                                _1479 = _1147;
                              }
                            } else {
                              _1479 = 1.0f;
                            }
                            if (_1479 > 0.0f) {
                              _1484 = DepthAtlas.GatherRed(D3DStaticPointClampedSampler, float2(_1422, _1423));
                              _1491 = 0.5f - ((_1303 / _1277) * 0.5f);
                              _1492 = _1115 / _1277;
                              _1493 = _1492 * 0.25f;
                              _1494 = !(_1484.x < 1.0f);
                              if (!(_1099 || _1494)) {
                                _1505 = (1.0f - saturate((abs(_1491 - _1484.x) - _1492) / _1493));
                              } else {
                                _1505 = select(_1494, 0.0f, 1.0f);
                              }
                              _1506 = !(_1484.y < 1.0f);
                              if (!(_1099 || _1506)) {
                                _4077 = (1.0f - saturate((abs(_1491 - _1484.y) - _1492) / _1493));
                              } else {
                                _4077 = select(_1506, 0.0f, 1.0f);
                              }
                              _4078 = !(_1484.z < 1.0f);
                              if (!(_1099 || _4078)) {
                                _4089 = (1.0f - saturate((abs(_1491 - _1484.z) - _1492) / _1493));
                              } else {
                                _4089 = select(_4078, 0.0f, 1.0f);
                              }
                              _4090 = !(_1484.w < 1.0f);
                              if (!(_1099 || _4090)) {
                                _4101 = (1.0f - saturate((abs(_1491 - _1484.w) - _1492) / _1493));
                              } else {
                                _4101 = select(_4090, 0.0f, 1.0f);
                              }
                              _4102 = _1505 * (_1465 * _1464);
                              _4103 = _4077 * (_1464 * _1463);
                              _4104 = _4089 * (_1468 * _1463);
                              _4105 = _4101 * (_1468 * _1465);
                              _4106 = dot(float4(_4102, _4103, _4104, _4105), float4(1.0f, 1.0f, 1.0f, 1.0f));
                              _4107 = _4106 * _1479;
                              if (_4107 > 0.0f) {
                                while(true) {
                                  _1510 = _4102 / _4106;
                                  _1511 = _4103 / _4106;
                                  _1512 = _4104 / _4106;
                                  _1513 = _4105 / _4106;
                                  _1515 = FinalLightingAtlas.GatherRed(D3DStaticPointClampedSampler, float2(_1422, _1423));
                                  _1520 = FinalLightingAtlas.GatherGreen(D3DStaticPointClampedSampler, float2(_1422, _1423));
                                  _1525 = FinalLightingAtlas.GatherBlue(D3DStaticPointClampedSampler, float2(_1422, _1423));
                                  _1536 = (dot(float4(_1515.x, _1515.y, _1515.z, _1515.w), float4(_1510, _1511, _1512, _1513)) * _4107) + _1228;
                                  _1537 = (dot(float4(_1520.x, _1520.y, _1520.z, _1520.w), float4(_1510, _1511, _1512, _1513)) * _4107) + _1229;
                                  _1538 = (dot(float4(_1525.x, _1525.y, _1525.z, _1525.w), float4(_1510, _1511, _1512, _1513)) * _4107) + _1230;
                                  _1539 = _4107 + _1227;
                                  if (_4107 > _1231) {
                                    _1250 = _1539;
                                    _1251 = _1536;
                                    _1252 = _1537;
                                    _1253 = _1538;
                                    _1254 = _4107;
                                    _1255 = (((int)(_1433 << 24)) | _1240);
                                    _1256 = ((int)(((int)(uint(select(((uint)_1435 > (uint)7), float((uint)(1 << (((int)(_1435 + 25u)) & 31))), 1.0f) * _1339)) << 8) + uint(select(((uint)_1434 > (uint)7), float((uint)(1 << (((int)(_1434 + 25u)) & 31))), 1.0f) * _1338)));
                                    _1257 = _1359;
                                  } else {
                                    _1250 = _1539;
                                    _1251 = _1536;
                                    _1252 = _1537;
                                    _1253 = _1538;
                                    _1254 = _1231;
                                    _1255 = _1232;
                                    _1256 = _1233;
                                    _1257 = _1234;
                                  }
                                  break;
                                }
                              } else {
                                _1250 = _1227;
                                _1251 = _1228;
                                _1252 = _1229;
                                _1253 = _1230;
                                _1254 = _1231;
                                _1255 = _1232;
                                _1256 = _1233;
                                _1257 = _1234;
                              }
                            } else {
                              _1250 = _1227;
                              _1251 = _1228;
                              _1252 = _1229;
                              _1253 = _1230;
                              _1254 = _1231;
                              _1255 = _1232;
                              _1256 = _1233;
                              _1257 = _1234;
                            }
                          } else {
                            _1250 = _1227;
                            _1251 = _1228;
                            _1252 = _1229;
                            _1253 = _1230;
                            _1254 = _1231;
                            _1255 = _1232;
                            _1256 = _1233;
                            _1257 = _1234;
                          }
                        } else {
                          _1250 = _1227;
                          _1251 = _1228;
                          _1252 = _1229;
                          _1253 = _1230;
                          _1254 = _1231;
                          _1255 = _1232;
                          _1256 = _1233;
                          _1257 = _1234;
                        }
                      } else {
                        _1250 = _1227;
                        _1251 = _1228;
                        _1252 = _1229;
                        _1253 = _1230;
                        _1254 = _1231;
                        _1255 = _1232;
                        _1256 = _1233;
                        _1257 = _1234;
                      }
                    } else {
                      _1250 = _1227;
                      _1251 = _1228;
                      _1252 = _1229;
                      _1253 = _1230;
                      _1254 = _1231;
                      _1255 = _1232;
                      _1256 = _1233;
                      _1257 = _1234;
                    }
                    while(true) {
                      if (!(_1235 == _1238)) {
                        _1227 = _1250;
                        _1228 = _1251;
                        _1229 = _1252;
                        _1230 = _1253;
                        _1231 = _1254;
                        _1232 = _1255;
                        _1233 = _1256;
                        _1234 = _1257;
                        _1235 = (_1238 ^ _1235);
                        __loop_jump_target = 1226;
                        break;
                      }
                      _1544 = _1250;
                      _1545 = _1251;
                      _1546 = _1252;
                      _1547 = _1253;
                      _1548 = _1254;
                      _1549 = _1255;
                      _1550 = _1256;
                      _1551 = _1257;
                      break;
                    }
                    if (__loop_jump_target == 1226) {
                      __loop_jump_target = -1;
                      continue;
                    }
                    if (__loop_jump_target != -1) {
                      break;
                    }
                    break;
                  }
                } else {
                  _1544 = _1047;
                  _1545 = _1046;
                  _1546 = _1045;
                  _1547 = _1044;
                  _1548 = _1043;
                  _1549 = _1042;
                  _1550 = _1041;
                  _1551 = _1040;
                }
                if (_1544 < 0.8999999761581421f) {
                  _1554 = _1544;
                  _1555 = _1545;
                  _1556 = _1546;
                  _1557 = _1547;
                  _1558 = _1548;
                  _1559 = _1549;
                  _1560 = _1550;
                  _1561 = _1551;
                  _1562 = _1039 + 1;
                  if ((uint)_1562 < (uint)4) {
                    _1566 = _52[min((uint)(_1562), 3u)];
                    if (!(_1566 == -1)) {
                      _1039 = _1562;
                      _1040 = _1561;
                      _1041 = _1560;
                      _1042 = _1559;
                      _1043 = _1558;
                      _1044 = _1557;
                      _1045 = _1556;
                      _1046 = _1555;
                      _1047 = _1554;
                      _1048 = _1566;
                      continue;
                    } else {
                      _1569 = _1554;
                      _1570 = _1555;
                      _1571 = _1556;
                      _1572 = _1557;
                      _1573 = _1559;
                      _1574 = _1560;
                      _1575 = _1561;
                    }
                  } else {
                    _1569 = _1554;
                    _1570 = _1555;
                    _1571 = _1556;
                    _1572 = _1557;
                    _1573 = _1559;
                    _1574 = _1560;
                    _1575 = _1561;
                  }
                } else {
                  _1569 = _1544;
                  _1570 = _1545;
                  _1571 = _1546;
                  _1572 = _1547;
                  _1573 = _1549;
                  _1574 = _1550;
                  _1575 = _1551;
                }
              } else {
                _1554 = _1047;
                _1555 = _1046;
                _1556 = _1045;
                _1557 = _1044;
                _1558 = _1043;
                _1559 = _1042;
                _1560 = _1041;
                _1561 = _1040;
                _1562 = _1039 + 1;
                if ((uint)_1562 < (uint)4) {
                  _1566 = _52[min((uint)(_1562), 3u)];
                  if (!(_1566 == -1)) {
                    _1039 = _1562;
                    _1040 = _1561;
                    _1041 = _1560;
                    _1042 = _1559;
                    _1043 = _1558;
                    _1044 = _1557;
                    _1045 = _1556;
                    _1046 = _1555;
                    _1047 = _1554;
                    _1048 = _1566;
                    continue;
                  } else {
                    _1569 = _1554;
                    _1570 = _1555;
                    _1571 = _1556;
                    _1572 = _1557;
                    _1573 = _1559;
                    _1574 = _1560;
                    _1575 = _1561;
                  }
                } else {
                  _1569 = _1554;
                  _1570 = _1555;
                  _1571 = _1556;
                  _1572 = _1557;
                  _1573 = _1559;
                  _1574 = _1560;
                  _1575 = _1561;
                }
              }
              _1577 = _1569;
              _1578 = _1570;
              _1579 = _1571;
              _1580 = _1572;
              _1581 = _1573;
              _1582 = _1574;
              _1583 = _1575;
              break;
            }
          } else {
            _1577 = 0.0f;
            _1578 = 0.0f;
            _1579 = 0.0f;
            _1580 = 0.0f;
            _1581 = 0;
            _1582 = 0;
            _1583 = 0;
          }
          if (_1577 > 0.0f) {
            _1586 = _1578 / _1577;
            _1587 = _1579 / _1577;
            _1588 = _1580 / _1577;
            if (((asint(_RootShaderParameters_raw[9u].y) & _61) == asint(_RootShaderParameters_raw[9u].z)) && ((asint(_RootShaderParameters_raw[9u].y) & _63) == asint(_RootShaderParameters_raw[9u].w))) {
              if ((_1577 > 0.10000000149011612f) && (asint(_RootShaderParameters_raw[9u].x) != 0)) {
                InterlockedAdd(RWSurfaceCacheFeedbackBufferAllocator[0], 1, _1605);
                if ((uint)_1605 < (uint)asint(_RootShaderParameters_raw[9u].x)) {
                  RWSurfaceCacheFeedbackBuffer[_1605] = int2(_1581, _1582);
                }
                RWCardPageHighResLastUsedBuffer[_1583] = asint(_RootShaderParameters_raw[10u].y);
                _1616 = _956;
                _1617 = _957;
                _1618 = _958;
                _1619 = _610;
                _1620 = 0.0f;
                _1621 = _1586;
                _1622 = _1587;
                _1623 = _1588;
              } else {
                _1616 = _956;
                _1617 = _957;
                _1618 = _958;
                _1619 = _610;
                _1620 = 0.0f;
                _1621 = _1586;
                _1622 = _1587;
                _1623 = _1588;
              }
            } else {
              _1616 = _956;
              _1617 = _957;
              _1618 = _958;
              _1619 = _610;
              _1620 = 0.0f;
              _1621 = _1586;
              _1622 = _1587;
              _1623 = _1588;
            }
          } else {
            _1616 = _956;
            _1617 = _957;
            _1618 = _958;
            _1619 = _610;
            _1620 = 0.0f;
            _1621 = 0.0f;
            _1622 = 0.0f;
            _1623 = 0.0f;
          }
        } else {
          _1616 = _956;
          _1617 = _957;
          _1618 = _958;
          _1619 = _610;
          _1620 = 0.0f;
          _1621 = 0.0f;
          _1622 = 0.0f;
          _1623 = 0.0f;
        }
      } else {
        _1616 = 0.0f;
        _1617 = 0.0f;
        _1618 = 0.0f;
        _1619 = _190;
        _1620 = 1.0f;
        _1621 = 0.0f;
        _1622 = 0.0f;
        _1623 = 0.0f;
      }
      _1626 = _1616;
      _1627 = _1617;
      _1628 = _1618;
      _1629 = min(_190, _1619);
      _1630 = _1620;
      _1631 = _1621;
      _1632 = _1622;
      _1633 = _1623;
    } else {
      _1626 = 0.0f;
      _1627 = 0.0f;
      _1628 = 0.0f;
      _1629 = _190;
      _1630 = 1.0f;
      _1631 = 0.0f;
      _1632 = 0.0f;
      _1633 = 0.0f;
    }
    _1634 = (_1630 <= 0.5f);
    _1636 = (int)(uint)(_1634);
    if (_1634) {
      _1641 = (_1629 * _181.x) + _196;
      _1642 = (_1629 * _181.y) + _197;
      _1643 = (_1629 * _181.z) + _198;
      _1657 = mad(_1643, asfloat(View_raw[2u].w), mad(_1642, asfloat(View_raw[1u].w), (asfloat(View_raw[0u].w) * _1641))) + asfloat(View_raw[3u].w);
      if (_1657 > 0.0f) {
        _1676 = (mad(_1643, asfloat(View_raw[2u].x), mad(_1642, asfloat(View_raw[1u].x), (asfloat(View_raw[0u].x) * _1641))) + asfloat(View_raw[3u].x)) / _1657;
        _1677 = (mad(_1643, asfloat(View_raw[2u].y), mad(_1642, asfloat(View_raw[1u].y), (asfloat(View_raw[0u].y) * _1641))) + asfloat(View_raw[3u].y)) / _1657;
        _1678 = abs(_1676);
        _1679 = abs(_1677);
        if ((_1678 < 1.0f) && (_1679 < 1.0f)) {
          _1691 = (asfloat(View_raw[67u].x) * _1676) + asfloat(View_raw[67u].w);
          _1692 = (asfloat(View_raw[67u].y) * _1677) + asfloat(View_raw[67u].z);
          _1695 = SceneDepthTexture.SampleLevel(D3DStaticPointClampedSampler, float2(_1691, _1692), 0.0f);
          _1707 = ((asfloat(View_raw[66u].x) * _1695.x) + asfloat(View_raw[66u].y)) + (1.0f / ((asfloat(View_raw[66u].z) * _1695.x) - asfloat(View_raw[66u].w)));
          _1712 = _1641 - asfloat(View_raw[69u].x);
          _1713 = _1642 - asfloat(View_raw[69u].y);
          _1714 = _1643 - asfloat(View_raw[69u].z);
          _1716 = rsqrt(dot(float3(_1712, _1713, _1714), float3(_1712, _1713, _1714)));
          _1720 = (asfloat(View_raw[31u].w) >= 1.0f);
          if (abs(_1657 - _1707) < (max(_1707, 9.999999747378752e-06f) * asfloat(_RootShaderParameters_raw[82u].x))) {
            if (!(dot(float3((-0.0f - select(_1720, asfloat(View_raw[61u].x), (_1712 * _1716))), (-0.0f - select(_1720, asfloat(View_raw[61u].y), (_1713 * _1716))), (-0.0f - select(_1720, asfloat(View_raw[61u].z), (_1714 * _1716)))), float3(_1626, _1627, _1628)) < asfloat(_RootShaderParameters_raw[82u].y))) {
              _1778 = mad(_1695.x, asfloat(View_raw[126u].w), mad(_1677, asfloat(View_raw[125u].w), (asfloat(View_raw[124u].w) * _1676))) + asfloat(View_raw[127u].w);
              _1786 = GBufferVelocityTexture.SampleLevel(D3DStaticPointClampedSampler, float2(_1691, _1692), 0.0f);
              if (_1786.x > 0.0f) {
                _1816 = (((_1786.x * 2.0040080547332764f) + -1.0019887685775757f) * abs((_1786.x * 4.008016109466553f) + -2.0039775371551514f));
                _1817 = (((_1786.y * 2.0040080547332764f) + -1.0019887685775757f) * abs((_1786.y * 4.008016109466553f) + -2.0039775371551514f));
                _1818 = asfloat((((int)(uint(round(_1786.w * 65535.0f))) & 65534) | ((int)((int)(uint(round(_1786.z * 65535.0f))) << 16))));
              } else {
                _1816 = (_1676 - ((mad(_1695.x, asfloat(View_raw[126u].x), mad(_1677, asfloat(View_raw[125u].x), (asfloat(View_raw[124u].x) * _1676))) + asfloat(View_raw[127u].x)) / _1778));
                _1817 = (_1677 - ((mad(_1695.x, asfloat(View_raw[126u].y), mad(_1677, asfloat(View_raw[125u].y), (asfloat(View_raw[124u].y) * _1676))) + asfloat(View_raw[127u].y)) / _1778));
                _1818 = (_1695.x - ((mad(_1695.x, asfloat(View_raw[126u].z), mad(_1677, asfloat(View_raw[125u].z), (asfloat(View_raw[124u].z) * _1676))) + asfloat(View_raw[127u].z)) / _1778));
              }
              _1819 = _1676 - _1816;
              _1820 = _1677 - _1817;
              _1827 = saturate((abs(_1819) * 5.0f) + -4.0f);
              _1828 = saturate((abs(_1820) * 5.0f) + -4.0f);
              _1836 = saturate((_1678 * 5.0f) + -4.0f);
              _1837 = saturate((_1679 * 5.0f) + -4.0f);
              _1844 = float((uint)(uint)(asint(View_raw[152u].y)));
              if (InjectionToggle(TOGGLE_USE_ISFAST_REFLECTIONS)) {
                _1854 = ISFASTNoiseLoad((uint(_61) + 1u) % 128u, (uint(_63) + 7u) % 128u, uint(float(InjectionFrameIndex())) % 32u).x;
              } else {
                _1854 = frac(frac(dot(float2(((_272 + 0.5f) + (_1844 * 32.665000915527344f)), ((_273 + 0.5f) + (_1844 * 11.8149995803833f))), float2(0.0671105608344078f, 0.005837149918079376f))) * 52.98291778564453f);
              }
              _1855 = !(min(saturate(1.0f - dot(float2(_1836, _1837), float2(_1836, _1837))), saturate(1.0f - dot(float2(_1827, _1828), float2(_1827, _1828)))) < _1854);
              if (_1855) {
                _1879 = ((int)(uint)((int)(abs((_1818 - _1695.x) + (((float4)(HistorySceneDepth.SampleLevel(D3DStaticPointClampedSampler, float2(((asfloat(_RootShaderParameters_raw[74u].x) * _1819) + asfloat(_RootShaderParameters_raw[74u].z)), ((asfloat(_RootShaderParameters_raw[74u].y) * _1820) + asfloat(_RootShaderParameters_raw[74u].w))), 0.0f))).x)) < (((_1854 * 1.5f) + 0.5f) * asfloat(_RootShaderParameters_raw[82u].x)))));
              } else {
                _1879 = ((int)(uint)(_1855));
              }
              if (!(_1879 == 0)) {
                _1901 = PrevSceneColorTexture.SampleLevel(D3DStaticPointClampedSampler, float2(min(max(((asfloat(_RootShaderParameters_raw[73u].x) * _1819) + asfloat(_RootShaderParameters_raw[73u].z)), asfloat(_RootShaderParameters_raw[72u].x)), asfloat(_RootShaderParameters_raw[72u].z)), min(max(((asfloat(_RootShaderParameters_raw[73u].y) * _1820) + asfloat(_RootShaderParameters_raw[73u].w)), asfloat(_RootShaderParameters_raw[72u].y)), asfloat(_RootShaderParameters_raw[72u].w))), 0.0f);
                _1925 = (-0.0f - ((min((-0.0f - _1901.x), 0.0f) * asfloat(_RootShaderParameters_raw[75u].x)) * asfloat(View_raw[143u].w)));
                _1926 = (-0.0f - ((min((-0.0f - _1901.y), 0.0f) * asfloat(_RootShaderParameters_raw[75u].x)) * asfloat(View_raw[143u].w)));
                _1927 = (-0.0f - ((min((-0.0f - _1901.z), 0.0f) * asfloat(_RootShaderParameters_raw[75u].x)) * asfloat(View_raw[143u].w)));
              } else {
                _1925 = _1631;
                _1926 = _1632;
                _1927 = _1633;
              }
            } else {
              _1925 = _1631;
              _1926 = _1632;
              _1927 = _1633;
            }
          } else {
            _1925 = _1631;
            _1926 = _1632;
            _1927 = _1633;
          }
        } else {
          _1925 = _1631;
          _1926 = _1632;
          _1927 = _1633;
        }
      } else {
        _1925 = _1631;
        _1926 = _1632;
        _1927 = _1633;
      }
    } else {
      _1925 = _1631;
      _1926 = _1632;
      _1927 = _1633;
    }
    _1929 = saturate(1.0f - _1630);
    if (!_1634) {
      _1935 = asfloat(_RootShaderParameters_raw[83u].y) * _181.x;
      _1936 = asfloat(_RootShaderParameters_raw[83u].y) * _181.y;
      _1937 = asfloat(_RootShaderParameters_raw[83u].y) * _181.z;
      _1939 = asfloat(View_raw[((uint)((uint)(asint(View_raw[234u].z)) + 206u))]);
      _1944 = _1939.w - (asfloat(View_raw[234u].x) * _1939.w);
      _1948 = 1.0f / _1935;
      _1949 = 1.0f / _1936;
      _1950 = 1.0f / _1937;
      _1957 = (((-0.0f - _168) - _1944) + _1939.x) * _1948;
      _1958 = (((-0.0f - _173) - _1944) + _1939.y) * _1949;
      _1959 = (((-0.0f - _178) - _1944) + _1939.z) * _1950;
      _1966 = ((_1944 - _168) + _1939.x) * _1948;
      _1967 = ((_1944 - _173) + _1939.y) * _1949;
      _1968 = ((_1944 - _178) + _1939.z) * _1950;
      _1980 = saturate(min(max(_1957, _1966), min(max(_1958, _1967), max(_1959, _1968))));
      if (saturate(max(min(_1957, _1966), max(min(_1958, _1967), min(_1959, _1968)))) < _1980) {
        _1993 = ((_1935 * _1980) + _168);
        _1994 = ((_1936 * _1980) + _173);
        _1995 = ((_1937 * _1980) + _178);
        _1996 = max(((1.0f - _1980) * asfloat(_RootShaderParameters_raw[83u].y)), 0.0f);
      } else {
        _1993 = _168;
        _1994 = _173;
        _1995 = _178;
        _1996 = asfloat(_RootShaderParameters_raw[83u].y);
      }
      if (_1996 > 0.0f) {
        _2022 = mad(_1995, asfloat(View_raw[2u].x), mad(_1994, asfloat(View_raw[1u].x), (asfloat(View_raw[0u].x) * _1993))) + asfloat(View_raw[3u].x);
        _2026 = mad(_1995, asfloat(View_raw[2u].y), mad(_1994, asfloat(View_raw[1u].y), (asfloat(View_raw[0u].y) * _1993))) + asfloat(View_raw[3u].y);
        _2030 = mad(_1995, asfloat(View_raw[2u].z), mad(_1994, asfloat(View_raw[1u].z), (asfloat(View_raw[0u].z) * _1993))) + asfloat(View_raw[3u].z);
        _2034 = mad(_1995, asfloat(View_raw[2u].w), mad(_1994, asfloat(View_raw[1u].w), (asfloat(View_raw[0u].w) * _1993))) + asfloat(View_raw[3u].w);
        if (!(_2034 < 0.0f)) {
          _2037 = -0.0f - _2034;
          if ((_2022 >= _2037) && (_2026 >= _2037)) {
            if ((_2022 <= _2034) && (_2026 <= _2034)) {
              _2046 = _2030 / _2034;
              _2056 = float((uint)(uint)(asint(View_raw[152u].y)));
              if (InjectionToggle(TOGGLE_USE_ISFAST_REFLECTIONS)) {
                _2064 = ISFASTNoiseLoad((uint(_61) + 2u) % 128u, (uint(_63) + 14u) % 128u, uint(float(InjectionFrameIndex())) % 32u).x;
              } else {
                _2064 = frac(frac(dot(float2(((_272 + 0.5f) + (_2056 * 32.665000915527344f)), ((_273 + 0.5f) + (_2056 * 11.8149995803833f))), float2(0.0671105608344078f, 0.005837149918079376f))) * 52.98291778564453f);
              }
              _2065 = _2064 + -0.5f;
              _2067 = min(_1996, 1e+06f);
              _2076 = mad(_181.z, asfloat(View_raw[14u].z), mad(_181.y, asfloat(View_raw[13u].z), (asfloat(View_raw[12u].z) * _181.x)));
              if (_2076 < 0.0f) {
                _2094 = min((((((asfloat(View_raw[66u].x) * _2046) + asfloat(View_raw[66u].y)) + (1.0f / ((asfloat(View_raw[66u].z) * _2046) - asfloat(View_raw[66u].w)))) * -0.949999988079071f) / _2076), _2067);
              } else {
                _2094 = _2067;
              }
              _2098 = (_2094 * _181.x) + _1993;
              _2099 = (_2094 * _181.y) + _1994;
              _2100 = (_2094 * _181.z) + _1995;
              _2117 = 1.0f / _2034;
              _2118 = _2117 * _2022;
              _2119 = _2117 * _2026;
              _2120 = _2117 * _2030;
              _2121 = 1.0f / (mad(_2100, asfloat(View_raw[2u].w), mad(_2099, asfloat(View_raw[1u].w), (asfloat(View_raw[0u].w) * _2098))) + asfloat(View_raw[3u].w));
              _2134 = (_2121 * (mad(_2100, asfloat(View_raw[2u].x), mad(_2099, asfloat(View_raw[1u].x), (asfloat(View_raw[0u].x) * _2098))) + asfloat(View_raw[3u].x))) - _2118;
              _2135 = (_2121 * (mad(_2100, asfloat(View_raw[2u].y), mad(_2099, asfloat(View_raw[1u].y), (asfloat(View_raw[0u].y) * _2098))) + asfloat(View_raw[3u].y))) - _2119;
              _2141 = sqrt((_2134 * _2134) + (_2135 * _2135)) * 0.5f;
              _2160 = min((min((1.0f - (max((abs((_2141 * _2118) + _2134) - _2141), 0.0f) / abs(_2134))), (1.0f - (max((abs((_2141 * _2119) + _2135) - _2141), 0.0f) / abs(_2135)))) / _2141), 1.0f);
              _2161 = _2160 * ((_2121 * (mad(_2100, asfloat(View_raw[2u].z), mad(_2099, asfloat(View_raw[1u].z), (asfloat(View_raw[0u].z) * _2098))) + asfloat(View_raw[3u].z))) - _2120);
              _2166 = (_2120 - ((1.0f / (mad(_2094, asfloat(View_raw[30u].w), 0.0f) + _2034)) * (mad(_2094, asfloat(View_raw[30u].z), 0.0f) + _2030))) * asfloat(_RootShaderParameters_raw[83u].x);
              if (asfloat(View_raw[31u].w) < 1.0f) {
                _2173 = max(abs(_2161), _2166);
              } else {
                _2173 = max(0.0f, _2166);
              }
              _2180 = _2173 * 0.0625f;
              _2183 = ((asfloat(_RootShaderParameters_raw[71u].x) * 0.03125f) * _2134) * _2160;
              _2186 = ((asfloat(_RootShaderParameters_raw[71u].y) * -0.03125f) * _2135) * _2160;
              _2187 = _2161 * 0.0625f;
              _2191 = (_2183 * _2065) + (((_2118 * 0.5f) + 0.5f) * asfloat(_RootShaderParameters_raw[71u].x));
              _2192 = (_2186 * _2065) + ((0.5f - (_2119 * 0.5f)) * asfloat(_RootShaderParameters_raw[71u].y));
              _2193 = (_2187 * _2065) + _2120;
              _2195 = 0.0f;
              _2196 = 0;
              while(true) {
                _2197 = float((uint)_2196);
                _2198 = _2197 + 1.0f;
                _2205 = _2197 + 2.0f;
                _2212 = _2197 + 3.0f;
                _2219 = _2197 + 4.0f;
                _2236 = ((_2198 * _2187) + _2193) - (((float4)(DistantScreenTraceFurthestHZBTexture.SampleLevel(D3DStaticPointClampedSampler, float2(((_2198 * _2183) + _2191), ((_2198 * _2186) + _2192)), 0.0f))).x);
                _2237 = ((_2205 * _2187) + _2193) - (((float4)(DistantScreenTraceFurthestHZBTexture.SampleLevel(D3DStaticPointClampedSampler, float2(((_2205 * _2183) + _2191), ((_2205 * _2186) + _2192)), 0.0f))).x);
                _2238 = ((_2212 * _2187) + _2193) - (((float4)(DistantScreenTraceFurthestHZBTexture.SampleLevel(D3DStaticPointClampedSampler, float2(((_2212 * _2183) + _2191), ((_2212 * _2186) + _2192)), 0.0f))).x);
                _2239 = ((_2219 * _2187) + _2193) - (((float4)(DistantScreenTraceFurthestHZBTexture.SampleLevel(D3DStaticPointClampedSampler, float2(((_2219 * _2183) + _2191), ((_2219 * _2186) + _2192)), 0.0f))).x);
                _2248 = (abs(_2236 + _2180) < _2180);
                _2249 = (abs(_2237 + _2180) < _2180);
                _2250 = (abs(_2238 + _2180) < _2180);
                if (!(((_2248 || _2249) || _2250) || (abs(_2239 + _2180) < _2180))) {
                  _2256 = _2196 + 4;
                  if ((uint)_2256 < (uint)16) {
                    _2195 = _2239;
                    _2196 = _2256;
                    continue;
                  } else {
                    _2259 = false;
                    _2260 = false;
                    _2261 = false;
                    _2262 = false;
                    _2263 = _2239;
                    _2264 = _2256;
                  }
                } else {
                  _2259 = true;
                  _2260 = _2250;
                  _2261 = _2249;
                  _2262 = _2248;
                  _2263 = _2195;
                  _2264 = _2196;
                }
                _2265 = float((uint)_2264);
                [branch]
                if (_2259) {
                  _2273 = select(_2262, _2263, select(_2261, _2236, select(_2260, _2237, _2238)));
                  _2282 = ((_2265 + select(_2262, 0.0f, select(_2261, 1.0f, select(_2260, 2.0f, 3.0f)))) + saturate(_2273 / (_2273 - select(_2262, _2236, select(_2261, _2237, select(_2260, _2238, _2239))))));
                } else {
                  _2282 = _2265;
                }
                _2288 = (_2282 * _2187) + _2193;
                _2298 = (((asfloat(_RootShaderParameters_raw[71u].z) * 2.0f) * ((_2282 * _2183) + _2191)) + -1.0f) * asfloat(View_raw[67u].x);
                _2299 = (1.0f - ((asfloat(_RootShaderParameters_raw[71u].w) * 2.0f) * ((_2282 * _2186) + _2192))) * asfloat(View_raw[67u].y);
                _2300 = (int)(uint)(_2259);
                if (_2259) {
                  _2306 = _2298 / asfloat(View_raw[67u].x);
                  _2307 = _2299 / asfloat(View_raw[67u].y);
                  _2335 = mad(_2288, asfloat(View_raw[126u].w), mad(_2307, asfloat(View_raw[125u].w), (asfloat(View_raw[124u].w) * _2306))) + asfloat(View_raw[127u].w);
                  _2341 = GBufferVelocityTexture.SampleLevel(D3DStaticPointClampedSampler, float2((_2298 + asfloat(View_raw[67u].w)), (_2299 + asfloat(View_raw[67u].z))), 0.0f);
                  if (_2341.x > 0.0f) {
                    _2359 = (((_2341.x * 2.0040080547332764f) + -1.0019887685775757f) * abs((_2341.x * 4.008016109466553f) + -2.0039775371551514f));
                    _2360 = (((_2341.y * 2.0040080547332764f) + -1.0019887685775757f) * abs((_2341.y * 4.008016109466553f) + -2.0039775371551514f));
                  } else {
                    _2359 = (_2306 - ((mad(_2288, asfloat(View_raw[126u].x), mad(_2307, asfloat(View_raw[125u].x), (asfloat(View_raw[124u].x) * _2306))) + asfloat(View_raw[127u].x)) / _2335));
                    _2360 = (_2307 - ((mad(_2288, asfloat(View_raw[126u].y), mad(_2307, asfloat(View_raw[125u].y), (asfloat(View_raw[124u].y) * _2306))) + asfloat(View_raw[127u].y)) / _2335));
                  }
                  _2361 = _2306 - _2359;
                  _2362 = _2307 - _2360;
                  _2369 = saturate((abs(_2361) * 5.0f) + -4.0f);
                  _2370 = saturate((abs(_2362) * 5.0f) + -4.0f);
                  _2380 = saturate((abs(_2306) * 5.0f) + -4.0f);
                  _2381 = saturate((abs(_2307) * 5.0f) + -4.0f);
                  _2387 = select((min(saturate(1.0f - dot(float2(_2380, _2381), float2(_2380, _2381))), saturate(1.0f - dot(float2(_2369, _2370), float2(_2369, _2370)))) < _2064), 0, _2300);
                  if (!(_2387 == 0)) {
                    _2409 = PrevSceneColorTexture.SampleLevel(D3DStaticPointClampedSampler, float2(min(max(((asfloat(_RootShaderParameters_raw[73u].x) * _2361) + asfloat(_RootShaderParameters_raw[73u].z)), asfloat(_RootShaderParameters_raw[72u].x)), asfloat(_RootShaderParameters_raw[72u].z)), min(max(((asfloat(_RootShaderParameters_raw[73u].y) * _2362) + asfloat(_RootShaderParameters_raw[73u].w)), asfloat(_RootShaderParameters_raw[72u].y)), asfloat(_RootShaderParameters_raw[72u].w))), 0.0f);
                    _2423 = asfloat(View_raw[143u].w) * asfloat(_RootShaderParameters_raw[75u].x);
                    _2431 = (-0.0f - (min((-0.0f - _2409.x), 0.0f) * _2423));
                    _2432 = (-0.0f - (min((-0.0f - _2409.y), 0.0f) * _2423));
                    _2433 = (-0.0f - (min((-0.0f - _2409.z), 0.0f) * _2423));
                    _2434 = _2387;
                  } else {
                    _2431 = _1925;
                    _2432 = _1926;
                    _2433 = _1927;
                    _2434 = 0;
                  }
                } else {
                  _2431 = _1925;
                  _2432 = _1926;
                  _2433 = _1927;
                  _2434 = _2300;
                }
                _2438 = _2431;
                _2439 = _2432;
                _2440 = _2433;
                _2441 = ((int)(uint)((int)(_2434 != 0)));
                break;
              }
            } else {
              _2438 = _1925;
              _2439 = _1926;
              _2440 = _1927;
              _2441 = _1636;
            }
          } else {
            _2438 = _1925;
            _2439 = _1926;
            _2440 = _1927;
            _2441 = _1636;
          }
        } else {
          _2438 = _1925;
          _2439 = _1926;
          _2440 = _1927;
          _2441 = _1636;
        }
      } else {
        _2438 = _1925;
        _2439 = _1926;
        _2440 = _1927;
        _2441 = _1636;
      }
    } else {
      _2438 = _1925;
      _2439 = _1926;
      _2440 = _1927;
      _2441 = _1636;
    }
    if (_2441 == 0) {
      if (_190 < (asfloat(_RootShaderParameters_raw[32u].z) * 0.9900000095367432f)) {
        _2451 = float((uint)(uint)(asint(_RootShaderParameters_raw[20u].z)));
        if (asint(_RootShaderParameters_raw[42u].w) == 0) {
          _2522 = asint(_RootShaderParameters_raw[42u].w);
        } else {
          _2465 = 0;
          while(true) {
            _2467 = asfloat(_RootShaderParameters_raw[((uint)(_2465 + 48u))]);
            _2473 = asfloat(_RootShaderParameters_raw[((uint)(_2465 + 54u))]);
            _2477 = (_2467.y * _140) + _2473.x;
            _2478 = (_2467.y * _144) + _2473.y;
            _2479 = (_2467.y * _148) + _2473.z;
            _2493 = float((uint)(uint)(asint(_RootShaderParameters_raw[42u].z)));
            float _ign_clipmap_threshold;
            // Clipmap selection uses original IGN unconditionally — IS-FAST
            // interacts badly with the `> threshold` test when RadianceCache
            // is enabled, producing black flicker from invalid probe lookups.
            _ign_clipmap_threshold = frac(frac(dot(float2(((_2451 * 32.665000915527344f) + _272), ((_2451 * 11.8149995803833f) + _273)), float2(0.0671105608344078f, 0.005837149918079376f))) * 52.98291778564453f);
            if (min(min(saturate((_2477 + -0.5f) * asfloat(_RootShaderParameters_raw[41u].w)), min(saturate((_2478 + -0.5f) * asfloat(_RootShaderParameters_raw[41u].w)), saturate((_2479 + -0.5f) * asfloat(_RootShaderParameters_raw[41u].w)))), min(saturate(((-0.5f - _2477) + _2493) * asfloat(_RootShaderParameters_raw[41u].w)), min(saturate(((-0.5f - _2478) + _2493) * asfloat(_RootShaderParameters_raw[41u].w)), saturate(((-0.5f - _2479) + _2493) * asfloat(_RootShaderParameters_raw[41u].w))))) > _ign_clipmap_threshold) {
              _2522 = _2465;
            } else {
              _2513 = _2465 + 1u;
              if ((uint)_2513 < (uint)asint(_RootShaderParameters_raw[42u].w)) {
                _2465 = _2513;
                continue;
              } else {
                _2522 = asint(_RootShaderParameters_raw[42u].w);
              }
            }
            break;
          }
        }
        _2524 = asfloat(_RootShaderParameters_raw[((uint)(_2522 + 48u))]);
        _2530 = asfloat(_RootShaderParameters_raw[((uint)(_2522 + 54u))]);
        _2539 = float((uint)(uint)(asint(_RootShaderParameters_raw[43u].x)));
        _2545 = min(max(log2(_2539 * sqrt(1.0f - cos(_181.w))), 0.0f), float((uint)(uint)(asint(_RootShaderParameters_raw[43u].z))));
        _2547 = (_2530.x + -0.5f) + (_2524.y * _140);
        _2549 = (_2530.y + -0.5f) + (_2524.y * _144);
        _2551 = (_2530.z + -0.5f) + (_2524.y * _148);
        _2555 = int(floor(_2547));
        _2556 = int(floor(_2549));
        _2557 = int(floor(_2551));
        _2558 = frac(_2547);
        _2559 = frac(_2549);
        _2560 = frac(_2551);
        _2564 = asint(_RootShaderParameters_raw[42u].z) * _2522;
        _2565 = _2564 + _2555;
        _2567 = RadianceProbeIndirectionTexture.Load(int4(_2565, _2556, _2557, 0));
        _2577 = asfloat(_RootShaderParameters_raw[((uint)(_2522 + 60u))]);
        _2581 = (_2524.z * float((uint)_2555)) + _2577.x;
        _2582 = (_2524.z * float((uint)_2556)) + _2577.y;
        _2583 = (_2524.z * float((uint)_2557)) + _2577.z;
        _2586 = ProbeWorldOffset[_2567.x].x;
        _2587 = ProbeWorldOffset[_2567.x].y;
        _2588 = ProbeWorldOffset[_2567.x].z;
        _2594 = asfloat(_RootShaderParameters_raw[41u].x) * _2524.x;
        _2595 = _140 - (_2581 + _2586);
        _2596 = _144 - (_2582 + _2587);
        _2597 = _148 - (_2583 + _2588);
        _2599 = dot(float3(_181.x, _181.y, _181.z), float3(_181.x, _181.y, _181.z));
        _2601 = dot(float3(_181.x, _181.y, _181.z), float3(_2595, _2596, _2597)) * 2.0f;
        _2602 = _2594 * _2594;
        _2605 = _2599 * 4.0f;
        _2607 = (_2601 * _2601) - (_2605 * (dot(float3(_2595, _2596, _2597), float3(_2595, _2596, _2597)) - _2602));
        [branch]
        if (!(_2607 < 0.0f)) {
          _2615 = ((sqrt(_2607) - _2601) / (_2599 * 2.0f));
        } else {
          _2615 = -1.0f;
        }
        _2619 = _2595 + (_2615 * _181.x);
        _2620 = _2596 + (_2615 * _181.y);
        _2621 = _2597 + (_2615 * _181.z);
        _2625 = (_2615 * _2615) / (dot(float3(_2619, _2620, _2621), float3(_181.x, _181.y, _181.z)) * _2594);
        _2627 = rsqrt(dot(float3(_2619, _2620, _2621), float3(_2619, _2620, _2621)));
        _2628 = _2627 * _2619;
        _2629 = _2627 * _2620;
        _2630 = _2627 * _2621;
        _2631 = abs(_2628);
        _2632 = abs(_2629);
        _2635 = sqrt(1.0f - abs(_2630));
        _2639 = min(_2631, _2632) / (max(_2631, _2632) + 5.421010862427522e-20f);
        _2650 = (((((((((0.04190388321876526f - (_2639 * 0.02513909712433815f)) * _2639) + 0.08817707002162933f) * _2639) + -0.24733373522758484f) * _2639) + 0.006157201714813709f) * _2639) + 0.6362265348434448f) * _2639;
        _2655 = select((_2631 < _2632), (0.9999959468841553f - _2650), (_2650 + 4.067585450684419e-06f)) * _2635;
        _2656 = _2635 - _2655;
        _2657 = (_2630 < 0.0f);
        _2661 = float((uint)(1 << (asint(_RootShaderParameters_raw[43u].z) & 31)));
        if (!(_2567.x == -1)) {
          _2705 = RadianceCacheFinalRadianceAtlas.SampleLevel(D3DStaticBilinearClampedSampler, float2(((((((asfloat((asint(select(_2657, (1.0f - _2655), _2656)) ^ (asint(_2628) & -2147483648))) * 0.5f) + 0.5f) * _2539) + _2661) + float((uint)((asint(_RootShaderParameters_raw[68u].x) & _2567.x) * asint(_RootShaderParameters_raw[43u].y)))) * asfloat(_RootShaderParameters_raw[66u].x)), ((((((asfloat((asint(select(_2657, (1.0f - _2656), _2655)) ^ (asint(_2629) & -2147483648))) * 0.5f) + 0.5f) * _2539) + _2661) + float((uint)(((uint)((uint)(_2567.x)) >> (asint(_RootShaderParameters_raw[68u].y) & 31)) * asint(_RootShaderParameters_raw[43u].y)))) * asfloat(_RootShaderParameters_raw[66u].y))), _2545);
          _2710 = _2705.x;
          _2711 = _2705.y;
          _2712 = _2705.z;
        } else {
          _2710 = 0.0f;
          _2711 = 0.0f;
          _2712 = 0.0f;
        }
        _2713 = _2710 * _2625;
        _2714 = _2711 * _2625;
        _2715 = _2712 * _2625;
        _2716 = _2557 + 1u;
        _2717 = RadianceProbeIndirectionTexture.Load(int4(_2565, _2556, _2716, 0));
        _2721 = (_2524.z * float((uint)_2716)) + _2577.z;
        _2723 = ProbeWorldOffset[_2717.x].x;
        _2724 = ProbeWorldOffset[_2717.x].y;
        _2725 = ProbeWorldOffset[_2717.x].z;
        _2729 = _140 - (_2581 + _2723);
        _2730 = _144 - (_2582 + _2724);
        _2731 = _148 - (_2721 + _2725);
        _2734 = dot(float3(_181.x, _181.y, _181.z), float3(_2729, _2730, _2731)) * 2.0f;
        _2738 = (_2734 * _2734) - (_2605 * (dot(float3(_2729, _2730, _2731), float3(_2729, _2730, _2731)) - _2602));
        [branch]
        if (!(_2738 < 0.0f)) {
          _2746 = ((sqrt(_2738) - _2734) / (_2599 * 2.0f));
        } else {
          _2746 = -1.0f;
        }
        _2750 = _2729 + (_2746 * _181.x);
        _2751 = _2730 + (_2746 * _181.y);
        _2752 = _2731 + (_2746 * _181.z);
        _2756 = (_2746 * _2746) / (dot(float3(_2750, _2751, _2752), float3(_181.x, _181.y, _181.z)) * _2594);
        _2758 = rsqrt(dot(float3(_2750, _2751, _2752), float3(_2750, _2751, _2752)));
        _2759 = _2758 * _2750;
        _2760 = _2758 * _2751;
        _2761 = _2758 * _2752;
        _2762 = abs(_2759);
        _2763 = abs(_2760);
        _2766 = sqrt(1.0f - abs(_2761));
        _2770 = min(_2762, _2763) / (max(_2762, _2763) + 5.421010862427522e-20f);
        _2781 = (((((((((0.04190388321876526f - (_2770 * 0.02513909712433815f)) * _2770) + 0.08817707002162933f) * _2770) + -0.24733373522758484f) * _2770) + 0.006157201714813709f) * _2770) + 0.6362265348434448f) * _2770;
        _2786 = select((_2762 < _2763), (0.9999959468841553f - _2781), (_2781 + 4.067585450684419e-06f)) * _2766;
        _2787 = _2766 - _2786;
        _2788 = (_2761 < 0.0f);
        if (!(_2717.x == -1)) {
          _2831 = RadianceCacheFinalRadianceAtlas.SampleLevel(D3DStaticBilinearClampedSampler, float2(((((((asfloat((asint(select(_2788, (1.0f - _2786), _2787)) ^ (asint(_2759) & -2147483648))) * 0.5f) + 0.5f) * _2539) + _2661) + float((uint)((asint(_RootShaderParameters_raw[68u].x) & _2717.x) * asint(_RootShaderParameters_raw[43u].y)))) * asfloat(_RootShaderParameters_raw[66u].x)), ((((((asfloat((asint(select(_2788, (1.0f - _2787), _2786)) ^ (asint(_2760) & -2147483648))) * 0.5f) + 0.5f) * _2539) + _2661) + float((uint)(((uint)((uint)(_2717.x)) >> (asint(_RootShaderParameters_raw[68u].y) & 31)) * asint(_RootShaderParameters_raw[43u].y)))) * asfloat(_RootShaderParameters_raw[66u].y))), _2545);
          _2836 = _2831.x;
          _2837 = _2831.y;
          _2838 = _2831.z;
        } else {
          _2836 = 0.0f;
          _2837 = 0.0f;
          _2838 = 0.0f;
        }
        _2842 = _2556 + 1u;
        _2843 = RadianceProbeIndirectionTexture.Load(int4(_2565, _2842, _2557, 0));
        _2847 = (_2524.z * float((uint)_2842)) + _2577.y;
        _2849 = ProbeWorldOffset[_2843.x].x;
        _2850 = ProbeWorldOffset[_2843.x].y;
        _2851 = ProbeWorldOffset[_2843.x].z;
        _2855 = _140 - (_2581 + _2849);
        _2856 = _144 - (_2847 + _2850);
        _2857 = _148 - (_2583 + _2851);
        _2860 = dot(float3(_181.x, _181.y, _181.z), float3(_2855, _2856, _2857)) * 2.0f;
        _2864 = (_2860 * _2860) - (_2605 * (dot(float3(_2855, _2856, _2857), float3(_2855, _2856, _2857)) - _2602));
        [branch]
        if (!(_2864 < 0.0f)) {
          _2872 = ((sqrt(_2864) - _2860) / (_2599 * 2.0f));
        } else {
          _2872 = -1.0f;
        }
        _2876 = _2855 + (_2872 * _181.x);
        _2877 = _2856 + (_2872 * _181.y);
        _2878 = _2857 + (_2872 * _181.z);
        _2882 = (_2872 * _2872) / (dot(float3(_2876, _2877, _2878), float3(_181.x, _181.y, _181.z)) * _2594);
        _2884 = rsqrt(dot(float3(_2876, _2877, _2878), float3(_2876, _2877, _2878)));
        _2885 = _2884 * _2876;
        _2886 = _2884 * _2877;
        _2887 = _2884 * _2878;
        _2888 = abs(_2885);
        _2889 = abs(_2886);
        _2892 = sqrt(1.0f - abs(_2887));
        _2896 = min(_2888, _2889) / (max(_2888, _2889) + 5.421010862427522e-20f);
        _2907 = (((((((((0.04190388321876526f - (_2896 * 0.02513909712433815f)) * _2896) + 0.08817707002162933f) * _2896) + -0.24733373522758484f) * _2896) + 0.006157201714813709f) * _2896) + 0.6362265348434448f) * _2896;
        _2912 = select((_2888 < _2889), (0.9999959468841553f - _2907), (_2907 + 4.067585450684419e-06f)) * _2892;
        _2913 = _2892 - _2912;
        _2914 = (_2887 < 0.0f);
        if (!(_2843.x == -1)) {
          _2957 = RadianceCacheFinalRadianceAtlas.SampleLevel(D3DStaticBilinearClampedSampler, float2(((((((asfloat((asint(select(_2914, (1.0f - _2912), _2913)) ^ (asint(_2885) & -2147483648))) * 0.5f) + 0.5f) * _2539) + _2661) + float((uint)((asint(_RootShaderParameters_raw[68u].x) & _2843.x) * asint(_RootShaderParameters_raw[43u].y)))) * asfloat(_RootShaderParameters_raw[66u].x)), ((((((asfloat((asint(select(_2914, (1.0f - _2913), _2912)) ^ (asint(_2886) & -2147483648))) * 0.5f) + 0.5f) * _2539) + _2661) + float((uint)(((uint)((uint)(_2843.x)) >> (asint(_RootShaderParameters_raw[68u].y) & 31)) * asint(_RootShaderParameters_raw[43u].y)))) * asfloat(_RootShaderParameters_raw[66u].y))), _2545);
          _2962 = _2957.x;
          _2963 = _2957.y;
          _2964 = _2957.z;
        } else {
          _2962 = 0.0f;
          _2963 = 0.0f;
          _2964 = 0.0f;
        }
        _2965 = _2962 * _2882;
        _2966 = _2963 * _2882;
        _2967 = _2964 * _2882;
        _2968 = RadianceProbeIndirectionTexture.Load(int4(_2565, _2842, _2716, 0));
        _2971 = ProbeWorldOffset[_2968.x].x;
        _2972 = ProbeWorldOffset[_2968.x].y;
        _2973 = ProbeWorldOffset[_2968.x].z;
        _2977 = _140 - (_2581 + _2971);
        _2978 = _144 - (_2847 + _2972);
        _2979 = _148 - (_2721 + _2973);
        _2982 = dot(float3(_181.x, _181.y, _181.z), float3(_2977, _2978, _2979)) * 2.0f;
        _2986 = (_2982 * _2982) - (_2605 * (dot(float3(_2977, _2978, _2979), float3(_2977, _2978, _2979)) - _2602));
        [branch]
        if (!(_2986 < 0.0f)) {
          _2994 = ((sqrt(_2986) - _2982) / (_2599 * 2.0f));
        } else {
          _2994 = -1.0f;
        }
        _2998 = _2977 + (_2994 * _181.x);
        _2999 = _2978 + (_2994 * _181.y);
        _3000 = _2979 + (_2994 * _181.z);
        _3004 = (_2994 * _2994) / (dot(float3(_2998, _2999, _3000), float3(_181.x, _181.y, _181.z)) * _2594);
        _3006 = rsqrt(dot(float3(_2998, _2999, _3000), float3(_2998, _2999, _3000)));
        _3007 = _3006 * _2998;
        _3008 = _3006 * _2999;
        _3009 = _3006 * _3000;
        _3010 = abs(_3007);
        _3011 = abs(_3008);
        _3014 = sqrt(1.0f - abs(_3009));
        _3018 = min(_3010, _3011) / (max(_3010, _3011) + 5.421010862427522e-20f);
        _3029 = (((((((((0.04190388321876526f - (_3018 * 0.02513909712433815f)) * _3018) + 0.08817707002162933f) * _3018) + -0.24733373522758484f) * _3018) + 0.006157201714813709f) * _3018) + 0.6362265348434448f) * _3018;
        _3034 = select((_3010 < _3011), (0.9999959468841553f - _3029), (_3029 + 4.067585450684419e-06f)) * _3014;
        _3035 = _3014 - _3034;
        _3036 = (_3009 < 0.0f);
        if (!(_2968.x == -1)) {
          _3079 = RadianceCacheFinalRadianceAtlas.SampleLevel(D3DStaticBilinearClampedSampler, float2(((((((asfloat((asint(select(_3036, (1.0f - _3034), _3035)) ^ (asint(_3007) & -2147483648))) * 0.5f) + 0.5f) * _2539) + _2661) + float((uint)((asint(_RootShaderParameters_raw[68u].x) & _2968.x) * asint(_RootShaderParameters_raw[43u].y)))) * asfloat(_RootShaderParameters_raw[66u].x)), ((((((asfloat((asint(select(_3036, (1.0f - _3035), _3034)) ^ (asint(_3008) & -2147483648))) * 0.5f) + 0.5f) * _2539) + _2661) + float((uint)(((uint)((uint)(_2968.x)) >> (asint(_RootShaderParameters_raw[68u].y) & 31)) * asint(_RootShaderParameters_raw[43u].y)))) * asfloat(_RootShaderParameters_raw[66u].y))), _2545);
          _3084 = _3079.x;
          _3085 = _3079.y;
          _3086 = _3079.z;
        } else {
          _3084 = 0.0f;
          _3085 = 0.0f;
          _3086 = 0.0f;
        }
        _3090 = _2555 + 1u;
        _3091 = _2564 + _3090;
        _3092 = RadianceProbeIndirectionTexture.Load(int4(_3091, _2556, _2557, 0));
        _3096 = (_2524.z * float((uint)_3090)) + _2577.x;
        _3098 = ProbeWorldOffset[_3092.x].x;
        _3099 = ProbeWorldOffset[_3092.x].y;
        _3100 = ProbeWorldOffset[_3092.x].z;
        _3104 = _140 - (_3096 + _3098);
        _3105 = _144 - (_2582 + _3099);
        _3106 = _148 - (_2583 + _3100);
        _3109 = dot(float3(_181.x, _181.y, _181.z), float3(_3104, _3105, _3106)) * 2.0f;
        _3113 = (_3109 * _3109) - (_2605 * (dot(float3(_3104, _3105, _3106), float3(_3104, _3105, _3106)) - _2602));
        [branch]
        if (!(_3113 < 0.0f)) {
          _3121 = ((sqrt(_3113) - _3109) / (_2599 * 2.0f));
        } else {
          _3121 = -1.0f;
        }
        _3125 = _3104 + (_3121 * _181.x);
        _3126 = _3105 + (_3121 * _181.y);
        _3127 = _3106 + (_3121 * _181.z);
        _3131 = (_3121 * _3121) / (dot(float3(_3125, _3126, _3127), float3(_181.x, _181.y, _181.z)) * _2594);
        _3133 = rsqrt(dot(float3(_3125, _3126, _3127), float3(_3125, _3126, _3127)));
        _3134 = _3133 * _3125;
        _3135 = _3133 * _3126;
        _3136 = _3133 * _3127;
        _3137 = abs(_3134);
        _3138 = abs(_3135);
        _3141 = sqrt(1.0f - abs(_3136));
        _3145 = min(_3137, _3138) / (max(_3137, _3138) + 5.421010862427522e-20f);
        _3156 = (((((((((0.04190388321876526f - (_3145 * 0.02513909712433815f)) * _3145) + 0.08817707002162933f) * _3145) + -0.24733373522758484f) * _3145) + 0.006157201714813709f) * _3145) + 0.6362265348434448f) * _3145;
        _3161 = select((_3137 < _3138), (0.9999959468841553f - _3156), (_3156 + 4.067585450684419e-06f)) * _3141;
        _3162 = _3141 - _3161;
        _3163 = (_3136 < 0.0f);
        if (!(_3092.x == -1)) {
          _3206 = RadianceCacheFinalRadianceAtlas.SampleLevel(D3DStaticBilinearClampedSampler, float2(((((((asfloat((asint(select(_3163, (1.0f - _3161), _3162)) ^ (asint(_3134) & -2147483648))) * 0.5f) + 0.5f) * _2539) + _2661) + float((uint)((asint(_RootShaderParameters_raw[68u].x) & _3092.x) * asint(_RootShaderParameters_raw[43u].y)))) * asfloat(_RootShaderParameters_raw[66u].x)), ((((((asfloat((asint(select(_3163, (1.0f - _3162), _3161)) ^ (asint(_3135) & -2147483648))) * 0.5f) + 0.5f) * _2539) + _2661) + float((uint)(((uint)((uint)(_3092.x)) >> (asint(_RootShaderParameters_raw[68u].y) & 31)) * asint(_RootShaderParameters_raw[43u].y)))) * asfloat(_RootShaderParameters_raw[66u].y))), _2545);
          _3211 = _3206.x;
          _3212 = _3206.y;
          _3213 = _3206.z;
        } else {
          _3211 = 0.0f;
          _3212 = 0.0f;
          _3213 = 0.0f;
        }
        _3214 = _3211 * _3131;
        _3215 = _3212 * _3131;
        _3216 = _3213 * _3131;
        _3217 = RadianceProbeIndirectionTexture.Load(int4(_3091, _2556, _2716, 0));
        _3220 = ProbeWorldOffset[_3217.x].x;
        _3221 = ProbeWorldOffset[_3217.x].y;
        _3222 = ProbeWorldOffset[_3217.x].z;
        _3226 = _140 - (_3096 + _3220);
        _3227 = _144 - (_2582 + _3221);
        _3228 = _148 - (_2721 + _3222);
        _3231 = dot(float3(_181.x, _181.y, _181.z), float3(_3226, _3227, _3228)) * 2.0f;
        _3235 = (_3231 * _3231) - (_2605 * (dot(float3(_3226, _3227, _3228), float3(_3226, _3227, _3228)) - _2602));
        [branch]
        if (!(_3235 < 0.0f)) {
          _3243 = ((sqrt(_3235) - _3231) / (_2599 * 2.0f));
        } else {
          _3243 = -1.0f;
        }
        _3247 = _3226 + (_3243 * _181.x);
        _3248 = _3227 + (_3243 * _181.y);
        _3249 = _3228 + (_3243 * _181.z);
        _3253 = (_3243 * _3243) / (dot(float3(_3247, _3248, _3249), float3(_181.x, _181.y, _181.z)) * _2594);
        _3255 = rsqrt(dot(float3(_3247, _3248, _3249), float3(_3247, _3248, _3249)));
        _3256 = _3255 * _3247;
        _3257 = _3255 * _3248;
        _3258 = _3255 * _3249;
        _3259 = abs(_3256);
        _3260 = abs(_3257);
        _3263 = sqrt(1.0f - abs(_3258));
        _3267 = min(_3259, _3260) / (max(_3259, _3260) + 5.421010862427522e-20f);
        _3278 = (((((((((0.04190388321876526f - (_3267 * 0.02513909712433815f)) * _3267) + 0.08817707002162933f) * _3267) + -0.24733373522758484f) * _3267) + 0.006157201714813709f) * _3267) + 0.6362265348434448f) * _3267;
        _3283 = select((_3259 < _3260), (0.9999959468841553f - _3278), (_3278 + 4.067585450684419e-06f)) * _3263;
        _3284 = _3263 - _3283;
        _3285 = (_3258 < 0.0f);
        if (!(_3217.x == -1)) {
          _3328 = RadianceCacheFinalRadianceAtlas.SampleLevel(D3DStaticBilinearClampedSampler, float2(((((((asfloat((asint(select(_3285, (1.0f - _3283), _3284)) ^ (asint(_3256) & -2147483648))) * 0.5f) + 0.5f) * _2539) + _2661) + float((uint)((asint(_RootShaderParameters_raw[68u].x) & _3217.x) * asint(_RootShaderParameters_raw[43u].y)))) * asfloat(_RootShaderParameters_raw[66u].x)), ((((((asfloat((asint(select(_3285, (1.0f - _3284), _3283)) ^ (asint(_3257) & -2147483648))) * 0.5f) + 0.5f) * _2539) + _2661) + float((uint)(((uint)((uint)(_3217.x)) >> (asint(_RootShaderParameters_raw[68u].y) & 31)) * asint(_RootShaderParameters_raw[43u].y)))) * asfloat(_RootShaderParameters_raw[66u].y))), _2545);
          _3333 = _3328.x;
          _3334 = _3328.y;
          _3335 = _3328.z;
        } else {
          _3333 = 0.0f;
          _3334 = 0.0f;
          _3335 = 0.0f;
        }
        _3339 = RadianceProbeIndirectionTexture.Load(int4(_3091, _2842, _2557, 0));
        _3342 = ProbeWorldOffset[_3339.x].x;
        _3343 = ProbeWorldOffset[_3339.x].y;
        _3344 = ProbeWorldOffset[_3339.x].z;
        _3348 = _140 - (_3096 + _3342);
        _3349 = _144 - (_2847 + _3343);
        _3350 = _148 - (_2583 + _3344);
        _3353 = dot(float3(_181.x, _181.y, _181.z), float3(_3348, _3349, _3350)) * 2.0f;
        _3357 = (_3353 * _3353) - (_2605 * (dot(float3(_3348, _3349, _3350), float3(_3348, _3349, _3350)) - _2602));
        [branch]
        if (!(_3357 < 0.0f)) {
          _3365 = ((sqrt(_3357) - _3353) / (_2599 * 2.0f));
        } else {
          _3365 = -1.0f;
        }
        _3369 = _3348 + (_3365 * _181.x);
        _3370 = _3349 + (_3365 * _181.y);
        _3371 = _3350 + (_3365 * _181.z);
        _3375 = (_3365 * _3365) / (dot(float3(_3369, _3370, _3371), float3(_181.x, _181.y, _181.z)) * _2594);
        _3377 = rsqrt(dot(float3(_3369, _3370, _3371), float3(_3369, _3370, _3371)));
        _3378 = _3377 * _3369;
        _3379 = _3377 * _3370;
        _3380 = _3377 * _3371;
        _3381 = abs(_3378);
        _3382 = abs(_3379);
        _3385 = sqrt(1.0f - abs(_3380));
        _3389 = min(_3381, _3382) / (max(_3381, _3382) + 5.421010862427522e-20f);
        _3400 = (((((((((0.04190388321876526f - (_3389 * 0.02513909712433815f)) * _3389) + 0.08817707002162933f) * _3389) + -0.24733373522758484f) * _3389) + 0.006157201714813709f) * _3389) + 0.6362265348434448f) * _3389;
        _3405 = select((_3381 < _3382), (0.9999959468841553f - _3400), (_3400 + 4.067585450684419e-06f)) * _3385;
        _3406 = _3385 - _3405;
        _3407 = (_3380 < 0.0f);
        if (!(_3339.x == -1)) {
          _3450 = RadianceCacheFinalRadianceAtlas.SampleLevel(D3DStaticBilinearClampedSampler, float2(((((((asfloat((asint(select(_3407, (1.0f - _3405), _3406)) ^ (asint(_3378) & -2147483648))) * 0.5f) + 0.5f) * _2539) + _2661) + float((uint)((asint(_RootShaderParameters_raw[68u].x) & _3339.x) * asint(_RootShaderParameters_raw[43u].y)))) * asfloat(_RootShaderParameters_raw[66u].x)), ((((((asfloat((asint(select(_3407, (1.0f - _3406), _3405)) ^ (asint(_3379) & -2147483648))) * 0.5f) + 0.5f) * _2539) + _2661) + float((uint)(((uint)((uint)(_3339.x)) >> (asint(_RootShaderParameters_raw[68u].y) & 31)) * asint(_RootShaderParameters_raw[43u].y)))) * asfloat(_RootShaderParameters_raw[66u].y))), _2545);
          _3455 = _3450.x;
          _3456 = _3450.y;
          _3457 = _3450.z;
        } else {
          _3455 = 0.0f;
          _3456 = 0.0f;
          _3457 = 0.0f;
        }
        _3458 = _3455 * _3375;
        _3459 = _3456 * _3375;
        _3460 = _3457 * _3375;
        _3461 = RadianceProbeIndirectionTexture.Load(int4(_3091, _2842, _2716, 0));
        _3464 = ProbeWorldOffset[_3461.x].x;
        _3465 = ProbeWorldOffset[_3461.x].y;
        _3466 = ProbeWorldOffset[_3461.x].z;
        _3470 = _140 - (_3096 + _3464);
        _3471 = _144 - (_2847 + _3465);
        _3472 = _148 - (_2721 + _3466);
        _3475 = dot(float3(_181.x, _181.y, _181.z), float3(_3470, _3471, _3472)) * 2.0f;
        _3479 = (_3475 * _3475) - (_2605 * (dot(float3(_3470, _3471, _3472), float3(_3470, _3471, _3472)) - _2602));
        [branch]
        if (!(_3479 < 0.0f)) {
          _3487 = ((sqrt(_3479) - _3475) / (_2599 * 2.0f));
        } else {
          _3487 = -1.0f;
        }
        _3491 = _3470 + (_3487 * _181.x);
        _3492 = _3471 + (_3487 * _181.y);
        _3493 = _3472 + (_3487 * _181.z);
        _3497 = (_3487 * _3487) / (dot(float3(_3491, _3492, _3493), float3(_181.x, _181.y, _181.z)) * _2594);
        _3499 = rsqrt(dot(float3(_3491, _3492, _3493), float3(_3491, _3492, _3493)));
        _3500 = _3499 * _3491;
        _3501 = _3499 * _3492;
        _3502 = _3499 * _3493;
        _3503 = abs(_3500);
        _3504 = abs(_3501);
        _3507 = sqrt(1.0f - abs(_3502));
        _3511 = min(_3503, _3504) / (max(_3503, _3504) + 5.421010862427522e-20f);
        _3522 = (((((((((0.04190388321876526f - (_3511 * 0.02513909712433815f)) * _3511) + 0.08817707002162933f) * _3511) + -0.24733373522758484f) * _3511) + 0.006157201714813709f) * _3511) + 0.6362265348434448f) * _3511;
        _3527 = select((_3503 < _3504), (0.9999959468841553f - _3522), (_3522 + 4.067585450684419e-06f)) * _3507;
        _3528 = _3507 - _3527;
        _3529 = (_3502 < 0.0f);
        if (!(_3461.x == -1)) {
          _3572 = RadianceCacheFinalRadianceAtlas.SampleLevel(D3DStaticBilinearClampedSampler, float2(((((((asfloat((asint(select(_3529, (1.0f - _3527), _3528)) ^ (asint(_3500) & -2147483648))) * 0.5f) + 0.5f) * _2539) + _2661) + float((uint)((asint(_RootShaderParameters_raw[68u].x) & _3461.x) * asint(_RootShaderParameters_raw[43u].y)))) * asfloat(_RootShaderParameters_raw[66u].x)), ((((((asfloat((asint(select(_3529, (1.0f - _3528), _3527)) ^ (asint(_3501) & -2147483648))) * 0.5f) + 0.5f) * _2539) + _2661) + float((uint)(((uint)((uint)(_3461.x)) >> (asint(_RootShaderParameters_raw[68u].y) & 31)) * asint(_RootShaderParameters_raw[43u].y)))) * asfloat(_RootShaderParameters_raw[66u].y))), _2545);
          _3577 = _3572.x;
          _3578 = _3572.y;
          _3579 = _3572.z;
        } else {
          _3577 = 0.0f;
          _3578 = 0.0f;
          _3579 = 0.0f;
        }
        _3589 = (((_2836 * _2756) - _2713) * _2560) + _2713;
        _3590 = (((_2837 * _2756) - _2714) * _2560) + _2714;
        _3591 = (((_2838 * _2756) - _2715) * _2560) + _2715;
        _3604 = (((_3333 * _3253) - _3214) * _2560) + _3214;
        _3605 = (((_3334 * _3253) - _3215) * _2560) + _3215;
        _3606 = (((_3335 * _3253) - _3216) * _2560) + _3216;
        _3622 = (((_2965 - _3589) + (((_3084 * _3004) - _2965) * _2560)) * _2559) + _3589;
        _3623 = (((_2966 - _3590) + (((_3085 * _3004) - _2966) * _2560)) * _2559) + _3590;
        _3624 = (((_2967 - _3591) + (((_3086 * _3004) - _2967) * _2560)) * _2559) + _3591;
        _3643 = (((_3604 - _3622) + (((_3458 - _3604) + (((_3577 * _3497) - _3458) * _2560)) * _2559)) * _2558) + _3622;
        _3644 = (((_3605 - _3623) + (((_3459 - _3605) + (((_3578 * _3497) - _3459) * _2560)) * _2559)) * _2558) + _3623;
        _3645 = (((_3606 - _3624) + (((_3460 - _3606) + (((_3579 * _3497) - _3460) * _2560)) * _2559)) * _2558) + _3624;
        if (asint(_RootShaderParameters_raw[67u].z) == 0) {
          if (asint(_RootShaderParameters_raw[67u].w) == 0) {
            _3686 = ((_3643 * _1630) + _2438);
            _3687 = ((_3644 * _1630) + _2439);
            _3688 = ((_3645 * _1630) + _2440);
            _3689 = _190;
            _3690 = _1929;
          } else {
            _3686 = _2438;
            _3687 = _2439;
            _3688 = _2440;
            _3689 = _190;
            _3690 = _1929;
          }
        } else {
          _3686 = _3643;
          _3687 = _3644;
          _3688 = _3645;
          _3689 = _190;
          _3690 = _1929;
        }
      } else {
        if (ReflectionStruct.SkyLightParameters.y > 0.0f) {
          _3668 = ReflectionStruct_SkyLightCubemap.SampleLevel(ReflectionStruct_SkyLightCubemapSampler, float3(_181.x, _181.y, _181.z), (ReflectionStruct.SkyLightParameters.x + -13.958941459655762f));
          _3686 = (((_3668.x * _1630) * asfloat(View_raw[194u].x)) + _2438);
          _3687 = (((_3668.y * _1630) * asfloat(View_raw[194u].y)) + _2439);
          _3688 = (((_3668.z * _1630) * asfloat(View_raw[194u].z)) + _2440);
          _3689 = asfloat(_RootShaderParameters_raw[32u].z);
          _3690 = 1.0f;
        } else {
          _3686 = _2438;
          _3687 = _2439;
          _3688 = _2440;
          _3689 = asfloat(_RootShaderParameters_raw[32u].z);
          _3690 = 1.0f;
        }
      }
    } else {
      _3686 = _2438;
      _3687 = _2439;
      _3688 = _2440;
      _3689 = select(_1634, _1629, 65504.0f);
      _3690 = _1929;
    }
    if (ReflectionStruct.SkyLightParameters.y > 0.0f) {
      if (asfloat(_RootShaderParameters_raw[4u].y) > 0.0f) {
        _3708 = ReflectionStruct_SkyLightCubemap.SampleLevel(ReflectionStruct_SkyLightCubemapSampler, float3(_181.x, _181.y, _181.z), ((ReflectionStruct.SkyLightParameters.x + -2.0f) + (log2(max(asfloat(_RootShaderParameters_raw[4u].z), 0.0010000000474974513f)) * 1.2000000476837158f)));
        _3722 = saturate(asfloat(_RootShaderParameters_raw[4u].w) * _1629) * asfloat(_RootShaderParameters_raw[4u].y);
        _3727 = ((asfloat(View_raw[194u].x) * _3708.x) * _3722);
        _3728 = ((asfloat(View_raw[194u].y) * _3708.y) * _3722);
        _3729 = ((asfloat(View_raw[194u].z) * _3708.z) * _3722);
      } else {
        _3727 = 0.0f;
        _3728 = 0.0f;
        _3729 = 0.0f;
      }
    } else {
      _3727 = 0.0f;
      _3728 = 0.0f;
      _3729 = 0.0f;
    }
    _3735 = asfloat(View_raw[143u].z) * (_3727 + _3686);
    _3736 = asfloat(View_raw[143u].z) * (_3728 + _3687);
    _3737 = asfloat(View_raw[143u].z) * (_3729 + _3688);
    if (!(asint(_RootShaderParameters_raw[5u].x) == 0)) {
      _3742 = _3689 * _181.x;
      _3743 = _3689 * _181.y;
      _3754 = min((asfloat(View_raw[68u].z) + asfloat(View_raw[60u].z)), FogStruct.ExponentialFogParameters.z);
      _3757 = (((_3689 * _181.z) - _3754) + asfloat(View_raw[60u].z)) + asfloat(View_raw[68u].z);
      _3758 = dot(float3(_3742, _3743, _3757), float3(_3742, _3743, _3757));
      _3760 = rsqrt(max(_3758, 9.99999993922529e-09f));
      _3761 = _3760 * _3758;
      _3762 = _3760 * _3742;
      _3763 = _3760 * _3743;
      _3764 = _3757 * _3760;
      [branch]
      if (dot(float3(asfloat(View_raw[133u].x), asfloat(View_raw[133u].y), asfloat(View_raw[133u].z)), float3(1.0f, 1.0f, 1.0f)) > 0.0f) {
        _3799 = (-0.0f - dot(float4(asfloat(View_raw[133u].x), asfloat(View_raw[133u].y), asfloat(View_raw[133u].z), asfloat(View_raw[133u].w)), float4((((asfloat(View_raw[68u].x) + asfloat(View_raw[60u].x)) + asfloat(View_raw[72u].x)) + asfloat(View_raw[73u].x)), (((asfloat(View_raw[68u].y) + asfloat(View_raw[60u].y)) + asfloat(View_raw[72u].y)) + asfloat(View_raw[73u].y)), ((asfloat(View_raw[72u].z) + _3754) + asfloat(View_raw[73u].z)), 1.0f))) / dot(float3(_3742, _3743, _3757), float3(asfloat(View_raw[133u].x), asfloat(View_raw[133u].y), asfloat(View_raw[133u].z)));
        if ((_3799 > 0.0f) && (_3799 < 1.0f)) {
          _3807 = max(0.0f, (_3799 * _3761));
        } else {
          _3807 = 0.0f;
        }
      } else {
        _3807 = 0.0f;
      }
      _3809 = max(_3807, FogStruct.ExponentialFogParameters.w);
      if (_3809 > 0.0f) {
        _3814 = _3809 * _3760;
        _3815 = _3814 * _3757;
        _3816 = _3815 + _3754;
        _3838 = (FogStruct.ExponentialFogParameters3.x * exp2(-0.0f - max(-127.0f, ((_3816 - FogStruct.ExponentialFogParameters3.y) * FogStruct.ExponentialFogParameters.y))));
        _3839 = (FogStruct.ExponentialFogParameters2.z * exp2(-0.0f - max(-127.0f, ((_3816 - FogStruct.ExponentialFogParameters2.w) * FogStruct.ExponentialFogParameters2.y))));
        _3840 = ((1.0f - _3814) * _3761);
        _3841 = (_3757 - _3815);
      } else {
        _3838 = FogStruct.ExponentialFogParameters.x;
        _3839 = FogStruct.ExponentialFogParameters2.x;
        _3840 = _3761;
        _3841 = _3757;
      }
      _3843 = max(-127.0f, (FogStruct.ExponentialFogParameters.y * _3841));
      _3855 = max(-127.0f, (FogStruct.ExponentialFogParameters2.y * _3841));
      _3866 = (select((abs(_3855) > 0.009999999776482582f), ((1.0f - exp2(-0.0f - _3855)) / _3855), (0.6931471824645996f - (_3855 * 0.24022650718688965f))) * _3839) + (select((abs(_3843) > 0.009999999776482582f), ((1.0f - exp2(-0.0f - _3843)) / _3843), (0.6931471824645996f - (_3843 * 0.24022650718688965f))) * _3838);
      [branch]
      if (FogStruct.ExponentialFogParameters3.z > 0.0f) {
        _3879 = saturate((FogStruct.FogInscatteringTextureParameters.x * _3761) + FogStruct.FogInscatteringTextureParameters.y);
        _3884 = dot(float2(_3742, _3743), float2(FogStruct.SinCosInscatteringColorCubemapRotation.y, (-0.0f - FogStruct.SinCosInscatteringColorCubemapRotation.x)));
        _3885 = dot(float2(_3742, _3743), float2(FogStruct.SinCosInscatteringColorCubemapRotation.x, FogStruct.SinCosInscatteringColorCubemapRotation.y));
        _3888 = FogStruct_FogInscatteringColorCubemap.SampleLevel(FogStruct_FogInscatteringColorSampler, float3(_3884, _3885, _3757), 0.0f);
        _3893 = FogStruct_FogInscatteringColorCubemap.SampleLevel(FogStruct_FogInscatteringColorSampler, float3(_3884, _3885, _3757), FogStruct.FogInscatteringTextureParameters.z);
        _3910 = ((lerp(_3893.x, _3888.x, _3879)) * FogStruct.ExponentialFogColorParameter.x);
        _3911 = ((lerp(_3893.y, _3888.y, _3879)) * FogStruct.ExponentialFogColorParameter.y);
        _3912 = ((lerp(_3893.z, _3888.z, _3879)) * FogStruct.ExponentialFogColorParameter.z);
      } else {
        _3910 = FogStruct.ExponentialFogColorParameter.x;
        _3911 = FogStruct.ExponentialFogColorParameter.y;
        _3912 = FogStruct.ExponentialFogColorParameter.z;
      }
      _3924 = View_DistantSkyLightLutTexture.SampleLevel(View_DistantSkyLightLutTextureSampler, float2(0.5f, 0.5f), 0.0f);
      if ((FogStruct.InscatteringLightDirection.w >= 0.0f) && (FogStruct.ExponentialFogParameters3.z == 0.0f)) {
        _3948 = asfloat(View_raw[186u].y) * 0.07957746833562851f;
        _3964 = exp2(log2(saturate(dot(float3(_3762, _3763, _3764), float3(asfloat(View_raw[168u].x), asfloat(View_raw[168u].y), asfloat(View_raw[168u].z))))) * FogStruct.DirectionalInscatteringColor.w);
        _3965 = _3964 * ((_3948 * asfloat(View_raw[170u].x)) + FogStruct.DirectionalInscatteringColor.x);
        _3966 = _3964 * ((_3948 * asfloat(View_raw[170u].y)) + FogStruct.DirectionalInscatteringColor.y);
        _3967 = _3964 * ((_3948 * asfloat(View_raw[170u].z)) + FogStruct.DirectionalInscatteringColor.z);
        if (asfloat(View_raw[171u].w) > 0.0f) {
          _3989 = exp2(log2(saturate(dot(float3(_3762, _3763, _3764), float3(asfloat(View_raw[169u].x), asfloat(View_raw[169u].y), asfloat(View_raw[169u].z))))) * FogStruct.DirectionalInscatteringColor.w);
          _3997 = ((_3989 * ((_3948 * asfloat(View_raw[171u].x)) + FogStruct.DirectionalInscatteringColor.x)) + _3965);
          _3998 = ((_3989 * ((_3948 * asfloat(View_raw[171u].y)) + FogStruct.DirectionalInscatteringColor.y)) + _3966);
          _3999 = ((_3989 * ((_3948 * asfloat(View_raw[171u].z)) + FogStruct.DirectionalInscatteringColor.z)) + _3967);
        } else {
          _3997 = _3965;
          _3998 = _3966;
          _3999 = _3967;
        }
        _4006 = 1.0f - saturate(exp2(-0.0f - (_3866 * max((_3840 - FogStruct.InscatteringLightDirection.w), 0.0f))));
        _4011 = (_4006 * _3997);
        _4012 = (_4006 * _3998);
        _4013 = (_4006 * _3999);
      } else {
        _4011 = 0.0f;
        _4012 = 0.0f;
        _4013 = 0.0f;
      }
      _4022 = (FogStruct.ExponentialFogParameters3.w > 0.0f) && (_3761 > FogStruct.ExponentialFogParameters3.w);
      _4026 = select(_4022, 1.0f, max(saturate(exp2(-0.0f - (_3840 * _3866))), FogStruct.ExponentialFogColorParameter.w));
      _4027 = 1.0f - _4026;
      _4037 = asfloat(View_raw[143u].z) * _3690;
      _4045 = ((_4037 * ((_4027 * (((asfloat(View_raw[186u].y) * FogStruct.SkyAtmosphereAmbientContributionColorScale.x) * _3924.x) + _3910)) + select(_4022, 0.0f, _4011))) + (_4026 * _3735));
      _4046 = ((_4037 * ((_4027 * (((asfloat(View_raw[186u].y) * FogStruct.SkyAtmosphereAmbientContributionColorScale.y) * _3924.y) + _3911)) + select(_4022, 0.0f, _4012))) + (_4026 * _3736));
      _4047 = ((_4037 * ((_4027 * (((asfloat(View_raw[186u].y) * FogStruct.SkyAtmosphereAmbientContributionColorScale.z) * _3924.z) + _3912)) + select(_4022, 0.0f, _4013))) + (_4026 * _3737));
    } else {
      _4045 = _3735;
      _4046 = _3736;
      _4047 = _3737;
    }
    _4049 = max(_4045, max(_4046, _4047));
    if (_4049 > asfloat(_RootShaderParameters_raw[18u].z)) {
      _4054 = asfloat(_RootShaderParameters_raw[18u].z) / _4049;
      _4059 = (_4054 * _4045);
      _4060 = (_4054 * _4046);
      _4061 = (_4054 * _4047);
    } else {
      _4059 = _4045;
      _4060 = _4046;
      _4061 = _4047;
    }
    RWTraceRadiance[int3(_61, _63, 0)] = float3(_4059, _4060, _4061);
    RWTraceHit[int3(_61, _63, 0)] = (max(_3689, 0.0f) * select((_2441 != 0), -1.0f, 1.0f));
  }
}