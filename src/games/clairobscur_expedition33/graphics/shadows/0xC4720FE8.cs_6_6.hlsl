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

struct FBlueNoiseConstants {
  int3 Dimensions;
  int Padding12;
  int3 ModuloMasks;
  int Padding28;
  uint BindlessSRV_ScalarTexture;
  uint Padding36;
  uint BindlessSRV_Vec2Texture;
};

struct FPackedVirtualVoxelNodeDesc {
  float3 TranslatedWorldMinAABB;
  uint PackedPageIndexResolution;
  float3 TranslatedWorldMaxAABB;
  uint PageIndexOffset_VoxelWorldSize;
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


Texture2D<float4> SceneTexturesStruct_SceneDepthTexture : register(t0);

Texture2D<float4> SceneTexturesStruct_GBufferATexture : register(t1);

Texture2D<float4> SceneTexturesStruct_GBufferBTexture : register(t2);

Texture2D<float4> SceneTexturesStruct_GBufferDTexture : register(t3);

StructuredBuffer<float4> ForwardLightData_ForwardLocalLightBuffer : register(t4);

StructuredBuffer<uint> ForwardLightData_NumCulledLightsGrid : register(t5);

ByteAddressBuffer VirtualShadowMap_ProjectionData : register(t6);

StructuredBuffer<uint> VirtualShadowMap_PageTable : register(t7);

Texture2DArray<uint> VirtualShadowMap_PhysicalPagePool : register(t8);

StructuredBuffer<uint> VirtualShadowMap_LightGridData : register(t9);

StructuredBuffer<uint> VirtualShadowMap_NumCulledLightsGrid : register(t10);

Texture2D<float4> BlueNoise_ScalarTexture : register(t11);

Texture2D<float4> BlueNoise_Vec2Texture : register(t12);

Texture2D<float4> HairStrands_HairOnlyDepthTexture : register(t13);

Buffer<uint> VirtualVoxel_PageIndexBuffer : register(t14);

StructuredBuffer<FPackedVirtualVoxelNodeDesc> VirtualVoxel_NodeDescBuffer : register(t15);

Texture3D<uint> VirtualVoxel_PageTexture : register(t16);

RWTexture2D<uint4> OutShadowMaskBits : register(u0);

cbuffer _RootShaderParameters : register(b0) {
  float ScreenRayLength : packoffset(c007.x);
  int SMRTRayCount : packoffset(c007.y);
  int SMRTSamplesPerRay : packoffset(c007.z);
  float SMRTCotMaxRayAngleFromLight : packoffset(c008.x);
  float SMRTTexelDitherScale : packoffset(c008.y);
  float SMRTExtrapolateSlope : packoffset(c008.z);
  float SMRTMaxSlopeBias : packoffset(c008.w);
  uint SMRTAdaptiveRayCount : packoffset(c009.x);
  int4 ProjectionRect : packoffset(c010.x);
  float NormalBias : packoffset(c011.x);
  uint InputType : packoffset(c011.z);
  uint bCullBackfacingPixels : packoffset(c011.w);
  int VisualizeVirtualShadowMapId : packoffset(c023.w);
};

cbuffer View : register(b1) {
  FViewConstants View : packoffset(c000.x);
};

cbuffer ForwardLightData : register(b2) {
  FForwardLightDataConstants ForwardLightData : packoffset(c000.x);
};

cbuffer VirtualShadowMap : register(b3) {
  FVirtualShadowMapConstants VirtualShadowMap : packoffset(c000.x);
};

cbuffer BlueNoise : register(b4) {
  FBlueNoiseConstants BlueNoise : packoffset(c000.x);
};

cbuffer VirtualVoxel : register(b5) {
  FVirtualVoxelConstants VirtualVoxel : packoffset(c000.x);
};

SamplerState SceneTexturesStruct_PointClampSampler : register(s0);

// DXIL FirstbitHi: returns bit position counting from MSB (leading zeros count)
uint firstbithigh_msb(int value) { return (value == 0) ? 0xFFFFFFFF : (31u - firstbithigh(value)); }
uint firstbithigh_msb(uint value) { return (value == 0) ? 0xFFFFFFFF : (31u - firstbithigh(value)); }

[numthreads(8, 8, 1)]
void main(
  uint3 SV_DispatchThreadID : SV_DispatchThreadID,
  uint3 SV_GroupID : SV_GroupID,
  uint3 SV_GroupThreadID : SV_GroupThreadID,
  uint SV_GroupIndex : SV_GroupIndex
) {
  int _37;
  int _40;
  int _43;
  int _45;
  int _51;
  int _54;
  int _57;
  int _59;
  uint _64;
  uint _65;
  uint _69;
  uint _70;
  float _89;
  float _216;
  float _217;
  int _257;
  int _258;
  int _259;
  int _260;
  int _261;
  float _324;
  int _354;
  float _511;
  float _516;
  int _600;
  int _603;
  float _769;
  int _770;
  int _771;
  float _772;
  float _938;
  float _939;
  float _940;
  int _1019;
  float _1045;
  float _1140;
  float _1141;
  float _1142;
  float _1143;
  int _1144;
  float _1153;
  int _1178;
  bool _1206;
  float _1207;
  float _1211;
  int _1212;
  float _1237;
  float _1238;
  float _1239;
  float _1240;
  float _1247;
  float _1248;
  float _1249;
  float _1250;
  int _1272;
  int _1291;
  int _1472;
  float _1473;
  float _1474;
  float _1475;
  float _1476;
  int _1477;
  float _1486;
  int _1513;
  bool _1541;
  float _1542;
  float _1546;
  int _1547;
  int _1574;
  float _1602;
  bool _1603;
  int _1631;
  bool _1659;
  float _1660;
  int _1664;
  float _1665;
  float _1666;
  float _1667;
  float _1668;
  int _1669;
  float _1694;
  float _1695;
  float _1696;
  float _1697;
  float _1704;
  float _1705;
  float _1706;
  float _1707;
  float _1711;
  int _1712;
  int _1714;
  float _1715;
  int _1716;
  float _1804;
  float _1805;
  float _1806;
  float _1807;
  int _1808;
  float _1817;
  int _1842;
  float _1870;
  bool _1871;
  float _1875;
  int _1876;
  float _1901;
  float _1902;
  float _1903;
  float _1904;
  float _1911;
  float _1912;
  float _1913;
  float _1914;
  float _1918;
  int _1919;
  float _1921;
  int _1922;
  int _1924;
  float _1925;
  float _1926;
  int _1927;
  int _1959;
  float _1960;
  int _1983;
  int _2086;
  int _2120;
  int _2121;
  int _2122;
  int _2123;
  int _2124;
  int _2125;
  int _2126;
  int _2127;
  int _2128;
  int _2129;
  int _2130;
  int _2131;
  int _2132;
  int _2133;
  int _2134;
  int _2135;
  int _2136;
  int _2137;
  int _2138;
  int _2188;
  float _2217;
  float _2218;
  int _2219;
  int _2220;
  bool _2221;
  int _2222;
  int _2223;
  float _2224;
  float _2326;
  float _2327;
  float _2340;
  float _2564;
  float _2565;
  float _2566;
  float _2567;
  float _2568;
  float _2569;
  float _2573;
  float _2574;
  float _2575;
  float _2576;
  float _2577;
  float _2578;
  int _2579;
  float _2580;
  float _2581;
  float _2582;
  float _2610;
  int _2611;
  int _2709;
  int _2710;
  int _2711;
  int _2712;
  int _2713;
  int _2714;
  int _2715;
  float _2716;
  float _2717;
  float _2718;
  int _2795;
  int _2796;
  int _2797;
  int _2798;
  int _2799;
  int _2800;
  int _2801;
  float _2834;
  float _2838;
  float _2845;
  float _2847;
  float _2855;
  float _2881;
  int _2893;
  int _2901;
  int _2909;
  int _2917;
  int _2920;
  int _2921;
  int _2922;
  int _2923;
  int _2928;
  int _2929;
  int _2930;
  int _2931;
  bool _82;
  float _100;
  float _103;
  float _104;
  float _140;
  float _141;
  float _142;
  float _143;
  float _151;
  float _154;
  float _162;
  float4 _164;
  uint _173;
  int _174;
  float _178;
  float _179;
  float _180;
  float _182;
  int _188;
  bool _189;
  float _209;
  int _234;
  uint _242;
  int _247;
  int _250;
  int _253;
  int _265;
  uint _266;
  float _270;
  float _273;
  float _274;
  float _277;
  float _278;
  float _279;
  float _281;
  float _282;
  float _283;
  float _284;
  int _285;
  float _288;
  float _289;
  float _292;
  bool _298;
  float _303;
  float _304;
  float _305;
  float _311;
  float _331;
  float _332;
  float _333;
  float _334;
  float _336;
  float _337;
  float _338;
  float _339;
  int _347;
  bool _364;
  float _365;
  float _366;
  float _367;
  float _371;
  float _372;
  float _373;
  float _401;
  float _405;
  float _409;
  float _413;
  float _414;
  float _415;
  float _416;
  float _432;
  float _433;
  float _434;
  float _435;
  float _441;
  float _449;
  float _450;
  float _451;
  float _452;
  float _454;
  float _455;
  float _472;
  float _485;
  float _498;
  bool _529;
  float _530;
  float _531;
  float _532;
  float _533;
  float _536;
  float _537;
  float _538;
  float _539;
  float _540;
  int _550;
  int _553;
  int _556;
  int _559;
  int _563;
  int _566;
  int _569;
  int _572;
  float _582;
  float _583;
  float _585;
  uint _604;
  int _608;
  int _616;
  int _617;
  int _618;
  int _624;
  int _625;
  int _626;
  int _632;
  int _633;
  int _634;
  int _640;
  int _641;
  int _642;
  int _648;
  int _649;
  int _650;
  int _656;
  int _657;
  int _658;
  int _664;
  int _668;
  float _687;
  float _688;
  float _689;
  float _691;
  float _703;
  float _727;
  float _731;
  float _734;
  float _736;
  float _739;
  float _741;
  float _745;
  float _746;
  float _748;
  float _751;
  float _752;
  float _761;
  int _767;
  uint _780;
  int _782;
  int _785;
  int _792;
  int _794;
  int _795;
  int _804;
  int _812;
  int _820;
  int _828;
  int _836;
  int _847;
  int _849;
  uint _853;
  int _855;
  uint _859;
  int _861;
  uint _862;
  int _864;
  float _871;
  float _872;
  float _873;
  float _874;
  float _879;
  bool _880;
  float _881;
  float _888;
  float _889;
  float _890;
  float _893;
  float _896;
  float _899;
  float _902;
  float _919;
  float _920;
  float _924;
  float _947;
  float _949;
  float _953;
  float _954;
  float _955;
  float _959;
  float _960;
  float _961;
  int _966;
  int _967;
  int _968;
  int _973;
  int _974;
  int _975;
  int _980;
  int _981;
  int _982;
  int _987;
  int _988;
  int _989;
  float _1004;
  float _1005;
  float _1006;
  bool _1007;
  int _1022;
  float _1027;
  float _1028;
  float _1029;
  uint _1047;
  int _1051;
  int _1052;
  int _1053;
  int _1054;
  float _1055;
  float _1056;
  float _1057;
  float _1058;
  int _1061;
  int _1062;
  int _1063;
  int _1064;
  float _1065;
  float _1066;
  float _1067;
  float _1068;
  int _1071;
  int _1072;
  int _1073;
  int _1074;
  float _1075;
  float _1076;
  float _1077;
  float _1078;
  int _1081;
  int _1082;
  int _1083;
  int _1084;
  float _1085;
  float _1086;
  float _1087;
  float _1088;
  float _1104;
  float _1120;
  float _1121;
  float _1122;
  float _1123;
  float _1129;
  float _1132;
  float _1133;
  float _1150;
  float _1157;
  float _1158;
  float _1159;
  bool _1166;
  int _1181;
  float _1187;
  float _1220;
  float _1224;
  float _1241;
  float _1254;
  float _1255;
  float _1257;
  float _1273;
  float _1274;
  float _1276;
  bool _1293;
  uint _1294;
  uint _1295;
  uint _1297;
  uint _1298;
  uint _1299;
  uint _1300;
  float _1302;
  float _1303;
  bool _1304;
  uint _1306;
  uint _1307;
  int _1310;
  int _1311;
  int _1312;
  int _1313;
  float _1314;
  float _1315;
  float _1316;
  float _1317;
  int _1320;
  int _1321;
  int _1322;
  int _1323;
  float _1324;
  float _1325;
  float _1326;
  float _1327;
  int _1330;
  int _1331;
  int _1332;
  int _1333;
  float _1334;
  float _1335;
  float _1336;
  float _1337;
  int _1340;
  int _1341;
  int _1342;
  int _1343;
  float _1344;
  float _1345;
  float _1346;
  float _1347;
  float _1363;
  float _1379;
  float _1380;
  float _1381;
  float _1382;
  float _1386;
  float _1387;
  float _1388;
  float _1389;
  float _1390;
  int _1392;
  int _1393;
  int _1394;
  int _1395;
  float _1396;
  float _1397;
  float _1398;
  float _1399;
  int _1401;
  int _1402;
  int _1403;
  int _1404;
  float _1405;
  float _1406;
  float _1407;
  float _1408;
  int _1410;
  int _1411;
  int _1412;
  int _1413;
  float _1414;
  float _1415;
  float _1416;
  float _1417;
  int _1419;
  int _1420;
  int _1421;
  int _1422;
  float _1423;
  float _1424;
  float _1425;
  float _1426;
  float _1442;
  float _1458;
  float _1459;
  float _1460;
  float _1461;
  float _1467;
  float _1468;
  float _1483;
  float _1492;
  float _1493;
  bool _1501;
  int _1516;
  float _1522;
  float _1553;
  float _1554;
  float _1555;
  bool _1562;
  int _1577;
  float _1583;
  float _1610;
  float _1611;
  float _1612;
  bool _1619;
  int _1634;
  float _1640;
  float _1677;
  float _1681;
  float _1698;
  bool _1717;
  int _1722;
  int _1723;
  int _1724;
  int _1725;
  float _1726;
  float _1727;
  float _1728;
  float _1729;
  int _1731;
  int _1732;
  int _1733;
  int _1734;
  float _1735;
  float _1736;
  float _1737;
  float _1738;
  int _1740;
  int _1741;
  int _1742;
  int _1743;
  float _1744;
  float _1745;
  float _1746;
  float _1747;
  int _1749;
  int _1750;
  int _1751;
  int _1752;
  float _1753;
  float _1754;
  float _1755;
  float _1756;
  float _1772;
  float _1788;
  float _1789;
  float _1790;
  float _1791;
  float _1797;
  float _1800;
  float _1801;
  float _1814;
  float _1821;
  float _1822;
  float _1823;
  bool _1830;
  int _1845;
  float _1851;
  float _1884;
  float _1888;
  float _1905;
  bool _1928;
  float _1935;
  uint _1937;
  int _1941;
  float _1942;
  int _1945;
  float _1946;
  bool _1965;
  uint _1974;
  uint _1980;
  int _1985;
  float _1994;
  uint _1995;
  int _1999;
  int _2002;
  int _2005;
  int _2006;
  int _2007;
  int _2008;
  int _2011;
  int _2012;
  int _2013;
  int _2014;
  int _2017;
  int _2018;
  int _2019;
  int _2020;
  int _2023;
  int _2024;
  int _2025;
  int _2026;
  int _2029;
  int _2032;
  int _2033;
  int _2034;
  int _2040;
  int _2041;
  int _2042;
  float _2063;
  float _2064;
  float _2065;
  float _2068;
  float _2069;
  float _2071;
  uint _2087;
  uint _2088;
  int _2091;
  int _2094;
  int _2097;
  int _2098;
  int _2099;
  int _2100;
  int _2103;
  int _2104;
  int _2105;
  int _2106;
  int _2109;
  int _2110;
  int _2111;
  int _2112;
  int _2115;
  int _2116;
  int _2117;
  int _2118;
  float _2155;
  float _2156;
  float _2172;
  float _2173;
  float _2174;
  float _2175;
  bool _2176;
  int _2191;
  int _2195;
  float _2198;
  float _2199;
  float _2200;
  uint _2201;
  uint _2202;
  uint _2226;
  int _2229;
  int _2233;
  int _2234;
  int _2235;
  int _2241;
  int _2242;
  int _2243;
  int _2249;
  int _2250;
  int _2251;
  int _2257;
  int _2258;
  int _2259;
  float _2264;
  float _2276;
  float _2283;
  float _2315;
  float _2334;
  float _2337;
  uint _2362;
  float4 _2365;
  float4 _2373;
  float _2375;
  float _2376;
  float _2377;
  float _2378;
  float _2381;
  float _2382;
  float _2383;
  float _2384;
  float _2385;
  bool _2392;
  int _2405;
  int _2408;
  int _2411;
  int _2414;
  int _2418;
  int _2421;
  int _2424;
  int _2427;
  uint _2439;
  int _2441;
  int _2444;
  int _2482;
  int _2484;
  uint _2488;
  int _2490;
  float _2500;
  float _2501;
  float _2502;
  float _2503;
  float _2508;
  bool _2509;
  float _2510;
  float _2517;
  float _2518;
  float _2519;
  float _2522;
  float _2524;
  float _2527;
  float _2529;
  float _2556;
  float _2590;
  float _2591;
  float _2592;
  float _2614;
  float _2615;
  float _2616;
  int _2618;
  float _2620;
  float _2621;
  float _2622;
  int _2624;
  int _2627;
  int _2629;
  int _2631;
  uint _2632;
  uint _2633;
  uint _2634;
  float _2637;
  float _2638;
  float _2647;
  float _2648;
  float _2649;
  float _2652;
  float _2653;
  float _2654;
  float _2655;
  float _2656;
  float _2657;
  float _2661;
  float _2662;
  float _2663;
  float _2667;
  float _2668;
  float _2669;
  float _2680;
  float _2681;
  float _2688;
  float _2690;
  float _2692;
  float _2699;
  float _2701;
  float _2704;
  float _2720;
  int _2766;
  int _2767;
  int _2768;
  int _2769;
  int _2770;
  int _2771;
  int _2772;
  uint _2789;
  uint _2790;
  float _2816;
  uint _2818;
  int _2819;
  float _2835;
  float _2841;
  float _2842;
  float _2850;
  uint _2851;
  int _2885;
  int _2886;
  uint _2924;
  _37 = (int)(SV_GroupIndex) & 1431655765;
  _40 = (((uint)(_37) >> 1) | _37) & 858993459;
  _43 = (((uint)(_40) >> 2) | _40) & 252645135;
  _45 = ((uint)(_43) >> 4) | _43;
  _51 = ((uint)(SV_GroupIndex) >> 1) & 1431655765;
  _54 = (((uint)(_51) >> 1) | _51) & 858993459;
  _57 = (((uint)(_54) >> 2) | _54) & 252645135;
  _59 = ((uint)(_57) >> 4) | _57;
  _64 = ((uint)((((uint)(_45) >> 8) & 65280) | (_45 & 255))) + ((int)(SV_GroupID.x) << 3);
  _65 = ((uint)((((uint)(_59) >> 8) & 65280) | (_59 & 255))) + ((int)(SV_GroupID.y) << 3);
  _69 = _64 + (uint)(ProjectionRect.x);
  _70 = _65 + (uint)(ProjectionRect.y);
  if (!((int)((uint)_69 >= (uint)ProjectionRect.z) || (int)((uint)_70 >= (uint)ProjectionRect.w))) {
    _82 = (InputType == 1);
    bool __branch_chain_76;
    if (!_82) {
      _89 = (((float4)(SceneTexturesStruct_SceneDepthTexture.Load(int3(_69, _70, 0)))).x);
      __branch_chain_76 = true;
    } else {
      if (!((((float4)(HairStrands_HairOnlyDepthTexture.Load(int3(_69, _70, 0)))).x) == 0.0f)) {
        _89 = (((float4)(HairStrands_HairOnlyDepthTexture.Load(int3(_69, _70, 0)))).x);
        __branch_chain_76 = true;
      } else {
        __branch_chain_76 = false;
      }
    }
    if (__branch_chain_76) {
      _100 = ((_89 * View.InvDeviceZToWorldZTransform.x) + View.InvDeviceZToWorldZTransform.y) + (1.0f / ((_89 * View.InvDeviceZToWorldZTransform.z) - View.InvDeviceZToWorldZTransform.w));
      _103 = float((uint)_69) + 0.5f;
      _104 = float((uint)_70) + 0.5f;
      _140 = mad(1.0f, (View.SVPositionToTranslatedWorld[3].w), mad(_89, (View.SVPositionToTranslatedWorld[2].w), mad(_104, (View.SVPositionToTranslatedWorld[1].w), (_103 * (View.SVPositionToTranslatedWorld[0].w)))));
      _141 = mad(1.0f, (View.SVPositionToTranslatedWorld[3].x), mad(_89, (View.SVPositionToTranslatedWorld[2].x), mad(_104, (View.SVPositionToTranslatedWorld[1].x), (_103 * (View.SVPositionToTranslatedWorld[0].x))))) / _140;
      _142 = mad(1.0f, (View.SVPositionToTranslatedWorld[3].y), mad(_89, (View.SVPositionToTranslatedWorld[2].y), mad(_104, (View.SVPositionToTranslatedWorld[1].y), (_103 * (View.SVPositionToTranslatedWorld[0].y))))) / _140;
      _143 = mad(1.0f, (View.SVPositionToTranslatedWorld[3].z), mad(_89, (View.SVPositionToTranslatedWorld[2].z), mad(_104, (View.SVPositionToTranslatedWorld[1].z), (_103 * (View.SVPositionToTranslatedWorld[0].z))))) / _140;
      _151 = ((ScreenRayLength * _100) * View.ScreenRayLengthMultiplier.y) + View.ScreenRayLengthMultiplier.w;
      _154 = float((uint)(uint)(View.StateFrameIndexMod8));
      if (InjectionToggle(TOGGLE_USE_ISFAST_SHADOWS)) {
        _162 = ISFASTNoiseLoad(uint(_69) % 128u, uint(_70) % 128u, uint(float(InjectionFrameIndex())) % 32u).x;
      } else {
        _162 = frac(frac(dot(float2(((_154 * 32.665000915527344f) + _103), ((_154 * 11.8149995803833f) + _104)), float2(0.0671105608344078f, 0.005837149918079376f))) * 52.98291778564453f);
      }
      _164 = SceneTexturesStruct_GBufferATexture.Load(int3(_69, _70, 0));
      _173 = uint(((((float4)(SceneTexturesStruct_GBufferBTexture.Load(int3(_69, _70, 0)))).w) * 255.0f) + 0.5f);
      _174 = _173 & 15;
      _178 = (_164.x * 2.0f) + -1.0f;
      _179 = (_164.y * 2.0f) + -1.0f;
      _180 = (_164.z * 2.0f) + -1.0f;
      _182 = rsqrt(dot(float3(_178, _179, _180), float3(_178, _179, _180)));
      _188 = _173 & 14;
      _189 = (_188 == 2);
      if (((int)(_189 || (int)(_174 == 6))) && ((int)(!_82))) {
        _209 = min(select(((int)(_188 == 8) || ((int)((int)((_173 & 12) == 4) || _189))), (((float4)(SceneTexturesStruct_GBufferDTexture.Load(int3(_69, _70, 0)))).w), 0.0f), 0.9900000095367432f);
        _216 = ((log2(1.0f - min(_209, 0.9900000095367432f)) * -0.03465735912322998f) * -1.4426950216293335f);
        _217 = _209;
      } else {
        _216 = -0.0f;
        _217 = 1.0f;
      }
      _234 = ForwardLightData.LightGridPixelSizeShift & 31;
      _242 = (((int)((ForwardLightData.CulledGridSize.y * ((int)min((uint)((int)(uint(max(0.0f, (ForwardLightData.LightGridZParams.z * log2(ForwardLightData.LightGridZParams.y + (_100 * ForwardLightData.LightGridZParams.x))))))), (uint)((ForwardLightData.CulledGridSize.z + -1))))) + ((uint)((uint)(_65) >> _234)))) * ForwardLightData.CulledGridSize.x) + ((uint)((uint)(_64) >> _234));
      _247 = ForwardLightData_NumCulledLightsGrid[(((int)(_242 << 1)) | 1)];
      _250 = VirtualShadowMap_NumCulledLightsGrid[_242];
      _253 = (int)min((uint)(VirtualShadowMap.PackedShadowMaskMaxLightCount), (uint)(_250));
      if (!(_253 == 0)) {
        _257 = 0;
        _258 = 0;
        _259 = 0;
        _260 = 0;
        _261 = 0;
        while(true) {
          _265 = VirtualShadowMap_LightGridData[((int)(_261 + _247))];
          _266 = _265 * 6;
          _270 = ForwardLightData_ForwardLocalLightBuffer[((int)(_266 + 5u))].w;
          _273 = ForwardLightData_ForwardLocalLightBuffer[((int)(_266 + 3u))].x;
          _274 = ForwardLightData_ForwardLocalLightBuffer[((int)(_266 + 3u))].y;
          _277 = ForwardLightData_ForwardLocalLightBuffer[((int)(_266 + 2u))].x;
          _278 = ForwardLightData_ForwardLocalLightBuffer[((int)(_266 + 2u))].y;
          _279 = ForwardLightData_ForwardLocalLightBuffer[((int)(_266 + 2u))].z;
          _281 = ForwardLightData_ForwardLocalLightBuffer[_266].x;
          _282 = ForwardLightData_ForwardLocalLightBuffer[_266].y;
          _283 = ForwardLightData_ForwardLocalLightBuffer[_266].z;
          _284 = ForwardLightData_ForwardLocalLightBuffer[_266].w;
          _285 = int(_270);
          if (!(_285 == -1)) {
            _288 = ForwardLightData_ForwardLocalLightBuffer[((int)(_266 + 3u))].z;
            _289 = ForwardLightData_ForwardLocalLightBuffer[((int)(_266 + 5u))].z;
            _292 = f16tof32(((uint)(asint(_288) & 65535)));
            _298 = (InputType == 1);
            _303 = _141 - View.TranslatedWorldCameraOrigin.x;
            _304 = _142 - View.TranslatedWorldCameraOrigin.y;
            _305 = _143 - View.TranslatedWorldCameraOrigin.z;
            _311 = sqrt((_305 * _305) + ((_303 * _303) + (_304 * _304)));
            if (!(!((View.ViewToClip[3].w) >= 1.0f))) {
              _324 = (_311 * (_311 / dot(float3(_303, _304, _305), float3(View.ViewForward.x, View.ViewForward.y, View.ViewForward.z))));
            } else {
              _324 = _311;
            }
            _331 = max(0.019999999552965164f, ((_324 * NormalBias) / View.TanAndInvTanHalfFOV.z));
            _332 = _281 - _141;
            _333 = _282 - _142;
            _334 = _283 - _143;
            _336 = rsqrt(dot(float3(_332, _333, _334), float3(_332, _333, _334)));
            _337 = _332 * _336;
            _338 = _333 * _336;
            _339 = _334 * _336;
            _347 = (int)(uint)((int)((int)(_336 >= _284) && (int)(saturate(_274 * (dot(float3(_337, _338, _339), float3(_277, _278, _279)) - _273)) > 0.0f)));
            if (f16tof32(((uint)(asint(_289) & 65535))) > -2.0f) {
              if (dot(float3(_332, _333, _334), float3(_277, _278, _279)) < 0.0f) {
                _354 = 0;
              } else {
                _354 = _347;
              }
            } else {
              _354 = _347;
            }
            if (((int)((int)(_174 != 0) || _298)) && (int)(_354 != 0)) {
              _364 = (int)(_174 == 7) || _298;
              _365 = select(_364, _337, (_178 * _182));
              _366 = select(_364, _338, (_179 * _182));
              _367 = select(_364, _339, (_180 * _182));
              _371 = _141 + (_331 * _365);
              _372 = _142 + (_331 * _366);
              _373 = _143 + (_331 * _367);
              if ((int)(_151 > 0.0f) && ((int)(!_298))) {
                _401 = mad(_373, (View.TranslatedWorldToClip[2].x), mad(_372, (View.TranslatedWorldToClip[1].x), ((View.TranslatedWorldToClip[0].x) * _371))) + (View.TranslatedWorldToClip[3].x);
                _405 = mad(_373, (View.TranslatedWorldToClip[2].y), mad(_372, (View.TranslatedWorldToClip[1].y), ((View.TranslatedWorldToClip[0].y) * _371))) + (View.TranslatedWorldToClip[3].y);
                _409 = mad(_373, (View.TranslatedWorldToClip[2].z), mad(_372, (View.TranslatedWorldToClip[1].z), ((View.TranslatedWorldToClip[0].z) * _371))) + (View.TranslatedWorldToClip[3].z);
                _413 = mad(_373, (View.TranslatedWorldToClip[2].w), mad(_372, (View.TranslatedWorldToClip[1].w), ((View.TranslatedWorldToClip[0].w) * _371))) + (View.TranslatedWorldToClip[3].w);
                _414 = _337 * _151;
                _415 = _338 * _151;
                _416 = _339 * _151;
                _432 = mad(_416, (View.TranslatedWorldToClip[2].w), mad(_415, (View.TranslatedWorldToClip[1].w), ((View.TranslatedWorldToClip[0].w) * _414))) + _413;
                _433 = _401 / _413;
                _434 = _405 / _413;
                _435 = _409 / _413;
                _441 = ((mad(_416, (View.TranslatedWorldToClip[2].z), mad(_415, (View.TranslatedWorldToClip[1].z), ((View.TranslatedWorldToClip[0].z) * _414))) + _409) / _432) - _435;
                _449 = (View.ScreenPositionScaleBias.x * _433) + View.ScreenPositionScaleBias.w;
                _450 = (View.ScreenPositionScaleBias.y * _434) + View.ScreenPositionScaleBias.z;
                _451 = View.ScreenPositionScaleBias.x * (((mad(_416, (View.TranslatedWorldToClip[2].x), mad(_415, (View.TranslatedWorldToClip[1].x), ((View.TranslatedWorldToClip[0].x) * _414))) + _401) / _432) - _433);
                _452 = View.ScreenPositionScaleBias.y * (((mad(_416, (View.TranslatedWorldToClip[2].y), mad(_415, (View.TranslatedWorldToClip[1].y), ((View.TranslatedWorldToClip[0].y) * _414))) + _405) / _432) - _434);
                _454 = (_162 + -0.5f) * 0.25f;
                _455 = _454 + 0.25f;
                if ((int)((((float4)(SceneTexturesStruct_SceneDepthTexture.SampleLevel(SceneTexturesStruct_PointClampSampler, float2(((_451 * _455) + _449), ((_452 * _455) + _450)), 0.0f))).x) != (((float4)(SceneTexturesStruct_SceneDepthTexture.SampleLevel(SceneTexturesStruct_PointClampSampler, float2(_449, _450), 0.0f))).x)) && (int)(((_441 * _455) + _435) < (((float4)(SceneTexturesStruct_SceneDepthTexture.SampleLevel(SceneTexturesStruct_PointClampSampler, float2(((_451 * _455) + _449), ((_452 * _455) + _450)), 0.0f))).x))) {
                  _511 = _455;
                  _516 = (max(0.0f, (_511 + -0.375f)) * _151);
                } else {
                  _472 = _454 + 0.5f;
                  if ((int)((((float4)(SceneTexturesStruct_SceneDepthTexture.SampleLevel(SceneTexturesStruct_PointClampSampler, float2(((_451 * _472) + _449), ((_452 * _472) + _450)), 0.0f))).x) != (((float4)(SceneTexturesStruct_SceneDepthTexture.SampleLevel(SceneTexturesStruct_PointClampSampler, float2(_449, _450), 0.0f))).x)) && (int)(((_441 * _472) + _435) < (((float4)(SceneTexturesStruct_SceneDepthTexture.SampleLevel(SceneTexturesStruct_PointClampSampler, float2(((_451 * _472) + _449), ((_452 * _472) + _450)), 0.0f))).x))) {
                    _511 = _472;
                    _516 = (max(0.0f, (_511 + -0.375f)) * _151);
                  } else {
                    _485 = _454 + 0.75f;
                    if ((int)((((float4)(SceneTexturesStruct_SceneDepthTexture.SampleLevel(SceneTexturesStruct_PointClampSampler, float2(((_451 * _485) + _449), ((_452 * _485) + _450)), 0.0f))).x) != (((float4)(SceneTexturesStruct_SceneDepthTexture.SampleLevel(SceneTexturesStruct_PointClampSampler, float2(_449, _450), 0.0f))).x)) && (int)(((_441 * _485) + _435) < (((float4)(SceneTexturesStruct_SceneDepthTexture.SampleLevel(SceneTexturesStruct_PointClampSampler, float2(((_451 * _485) + _449), ((_452 * _485) + _450)), 0.0f))).x))) {
                      _511 = _485;
                      _516 = (max(0.0f, (_511 + -0.375f)) * _151);
                    } else {
                      _498 = _454 + 1.0f;
                      if ((int)((((float4)(SceneTexturesStruct_SceneDepthTexture.SampleLevel(SceneTexturesStruct_PointClampSampler, float2(((_451 * _498) + _449), ((_452 * _498) + _450)), 0.0f))).x) != (((float4)(SceneTexturesStruct_SceneDepthTexture.SampleLevel(SceneTexturesStruct_PointClampSampler, float2(_449, _450), 0.0f))).x)) && (int)(((_441 * _498) + _435) < (((float4)(SceneTexturesStruct_SceneDepthTexture.SampleLevel(SceneTexturesStruct_PointClampSampler, float2(((_451 * _498) + _449), ((_452 * _498) + _450)), 0.0f))).x))) {
                        _511 = _498;
                        _516 = (max(0.0f, (_511 + -0.375f)) * _151);
                      } else {
                        _516 = _151;
                      }
                    }
                  }
                }
              } else {
                _516 = _151;
              }
              if ((int)SMRTRayCount > (int)0) {
                _529 = (_273 > -2.0f);
                _530 = _281 - _371;
                _531 = _282 - _372;
                _532 = _283 - _373;
                _533 = dot(float3(_530, _531, _532), float3(_530, _531, _532));
                _536 = rsqrt(_533);
                _537 = _530 * _536;
                _538 = _531 * _536;
                _539 = _532 * _536;
                _540 = _536 * _292;
                // Hair shadow: tighten penumbra cone — narrower cone → less per-ray variance.
                // _364 = (_174 == 7) || _298 was set above in the hair branch.
                if (InjectionToggle(TOGGLE_HAIR_SHADOW_TIGHTEN_CONE) && _364) {
                  _540 = _540 * 0.5f;
                }
                if (!((int)(dot(float3(_365, _366, _367), float3(_537, _538, _539)) < (-0.0f - sqrt(saturate((_292 * _292) * (1.0f / (_533 + 1.0f)))))) && ((int)(!(((int)((int)(_174 == 9) || ((int)(_189 || (int)((uint)(_174 + -5) < (uint)3))))) || ((int)(_298 || (int)(bCullBackfacingPixels == 0)))))))) {
                  _550 = _69 & 65535;
                  _553 = ((_550 << 8) | _550) & 16711935;
                  _556 = ((_553 << 4) | _553) & 252645135;
                  _559 = ((_556 << 2) | _556) & 858993459;
                  _563 = _70 & 65535;
                  _566 = ((_563 << 8) | _563) & 16711935;
                  _569 = ((_566 << 4) | _566) & 252645135;
                  _572 = ((_569 << 2) | _569) & 858993459;
                  if (!_529) {
                    _582 = abs(-0.0f - _530);
                    _583 = abs(-0.0f - _531);
                    _585 = abs(-0.0f - _532);
                    if (((int)(!(_582 >= _583))) || ((int)(!(_582 >= _585)))) {
                      if (_583 > _585) {
                        _600 = select((_531 < -0.0f), 2, 3);
                      } else {
                        _600 = select((_532 < -0.0f), 4, 5);
                      }
                    } else {
                      _600 = ((int)(uint)((int)(!(_530 < -0.0f))));
                    }
                    _603 = ((int)(_600 + _285));
                  } else {
                    _603 = _285;
                  }
                  _604 = _603 * 288;
                  _608 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_604 + 48u)))).z;
                  _616 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_604 + 128u)))).x;
                  _617 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_604 + 128u)))).y;
                  _618 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_604 + 128u)))).z;
                  _624 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_604 + 144u)))).x;
                  _625 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_604 + 144u)))).y;
                  _626 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_604 + 144u)))).z;
                  _632 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_604 + 160u)))).x;
                  _633 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_604 + 160u)))).y;
                  _634 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_604 + 160u)))).z;
                  _640 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_604 + 176u)))).x;
                  _641 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_604 + 176u)))).y;
                  _642 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_604 + 176u)))).z;
                  _648 = asint(VirtualShadowMap_ProjectionData.Load3(((int)(_604 + 208u)))).x;
                  _649 = asint(VirtualShadowMap_ProjectionData.Load3(((int)(_604 + 208u)))).y;
                  _650 = asint(VirtualShadowMap_ProjectionData.Load3(((int)(_604 + 208u)))).z;
                  _656 = asint(VirtualShadowMap_ProjectionData.Load3(((int)(_604 + 224u)))).x;
                  _657 = asint(VirtualShadowMap_ProjectionData.Load3(((int)(_604 + 224u)))).y;
                  _658 = asint(VirtualShadowMap_ProjectionData.Load3(((int)(_604 + 224u)))).z;
                  _664 = asint(VirtualShadowMap_ProjectionData.Load(((int)(_604 + 236u))));
                  _668 = asint(VirtualShadowMap_ProjectionData.Load(((int)(_604 + 280u))));
                  _687 = ((asfloat(_648) - View.PreViewTranslationHigh.x) + (asfloat(_656) - View.PreViewTranslationLow.x)) + _371;
                  _688 = ((asfloat(_649) - View.PreViewTranslationHigh.y) + (asfloat(_657) - View.PreViewTranslationLow.y)) + _372;
                  _689 = ((asfloat(_650) - View.PreViewTranslationHigh.z) + (asfloat(_658) - View.PreViewTranslationLow.z)) + _373;
                  _691 = -0.0f - dot(float3(_365, _366, _367), float3(_687, _688, _689));
                  _703 = mad(_691, asfloat(_642), mad(_367, asfloat(_634), mad(_366, asfloat(_626), (asfloat(_618) * _365))));
                  _727 = max(0.10000000149011612f, ((exp2(asfloat(_664)) * min((1.0f / ((View.ViewToClip[0].x) * View.ViewSizeAndInvSize.x)), (1.0f / ((View.ViewToClip[1].y) * View.ViewSizeAndInvSize.y)))) * (((View.ViewToClip[2].w) * _100) + (View.ViewToClip[3].w))));
                  _731 = (asfloat(_668) * SMRTTexelDitherScale) * _727;
                  _734 = (_727 * SMRTMaxSlopeBias) * abs(asfloat(_608) / _533);
                  _736 = select((_539 >= 0.0f), 1.0f, -1.0f);
                  _739 = -0.0f - (1.0f / (_736 + _539));
                  _741 = (_537 * _538) * _739;
                  _745 = (((_537 * _537) * _736) * _739) + 1.0f;
                  _746 = _741 * _736;
                  _748 = -0.0f - (_537 * _736);
                  _751 = ((_538 * _538) * _739) + _736;
                  _752 = -0.0f - _538;
                  _761 = mad(_539, _367, mad(_538, _366, (_537 * _365)));
                  _767 = select((_540 == 0.0f), 0, SMRTSamplesPerRay);
                  _769 = _162;
                  _770 = 0;
                  _771 = 0;
                  _772 = 0.0f;
                  // Hair shadow: per-pixel boosted SMRT ray count.
                  // _364 = (_174 == 7) || _298 was set above in the hair branch.
                  int _hair_smrt_ray_count = SMRTRayCount;
                  if (InjectionToggle(TOGGLE_HAIR_SHADOW_BOOST_RAYS) && _364) {
                    _hair_smrt_ray_count = max((int)(SMRTRayCount * 2), (int)8);
                  }
                  while(true) {
                    _780 = (uint)(reversebits((uint)((((int)((View.StateFrameIndex << 16) + ((uint)((((int)(((_572 << 1) | _572) << 1)) & -1431655766) | (((_559 << 1) | _559) & 1431655765))))) * _hair_smrt_ray_count) + _770))) + 1216234700u;
                    _782 = ((int)(_780 * -1676577210)) ^ _780;
                    _785 = reversebits((int)(((int)(_782 * -529506958)) ^ _782));
                    _792 = ((0 - (((uint)(_785) >> 1) & 1)) & 3) ^ (_785 & 1);
                    _794 = ((uint)(_785) >> 2) & 1;
                    _795 = 0 - _794;
                    _804 = 0 - (((uint)(_785) >> 3) & 1);
                    _812 = 0 - (((uint)(_785) >> 4) & 1);
                    _820 = 0 - (((uint)(_785) >> 5) & 1);
                    _828 = 0 - (((uint)(_785) >> 6) & 1);
                    _836 = 0 - (((uint)(_785) >> 7) & 1);
                    _847 = (_785 & 255) + -1862497895;
                    _849 = ((int)(_847 * -1676577210)) ^ _847;
                    _853 = ((uint)((((((_792 ^ (_795 & 5)) ^ (_804 & 15)) ^ (_812 & 17)) ^ (_820 & 51)) ^ (_828 & 85)) ^ (_836 & 255))) + (uint)(-646066581);
                    _855 = ((int)(_853 * -1676577210)) ^ _853;
                    _859 = ((uint)((((((_792 ^ (_795 & 6)) ^ (_804 & 9)) ^ (_812 & 23)) ^ (_820 & 58)) ^ (_828 & 113)) ^ (_836 & 163))) + 570102578u;
                    _861 = ((int)(_859 * -1676577210)) ^ _859;
                    _862 = ((uint)((((((_812 & 31) ^ (_804 & 10)) ^ (_820 & 46)) ^ (_828 & 69)) ^ (_836 & 201)) ^ (_792 | (_794 << 2)))) + 1786441729u;
                    _864 = ((int)(_862 * -1676577210)) ^ _862;
                    _871 = (float((uint)((uint)((uint)((uint)(reversebits((int)(((int)(_849 * -529506958)) ^ _849)))) >> 8))) * 8.429369557916289e-08f) + -0.7071067690849304f;
                    _872 = (float((uint)((uint)((uint)((uint)(reversebits((int)(((int)(_855 * -529506958)) ^ _855)))) >> 8))) * 8.429369557916289e-08f) + -0.7071067690849304f;
                    _873 = _871 * _871;
                    _874 = _872 * _872;
                    _879 = sqrt((max(_873, _874) * 2.0f) - min(_873, _874));
                    _880 = (_873 > _874);
                    _881 = -0.0f - _879;
                    _888 = select(_880, select((_871 > 0.0f), _879, _881), _871) * _540;
                    _889 = select(_880, _872, select((_872 > 0.0f), _879, _881)) * _540;
                    _890 = dot(float2(_888, _889), float2(_888, _889));
                    _893 = sqrt(1.0f - _890);
                    _896 = mad(_893, _537, mad(_889, _741, (_888 * _745)));
                    _899 = mad(_893, _538, mad(_889, _751, (_888 * _746)));
                    _902 = mad(_893, _539, mad(_889, _752, (_888 * _748)));
                    if (_731 > 0.0f) {
                      _919 = ((float((uint)((uint)((uint)((uint)(reversebits((int)(((int)(_861 * -529506958)) ^ _861)))) >> 8))) * 5.960464477539063e-08f) + -0.5f) * _731;
                      _920 = ((float((uint)((uint)((uint)((uint)(reversebits((int)(((int)(_864 * -529506958)) ^ _864)))) >> 8))) * 5.960464477539063e-08f) + -0.5f) * _731;
                      _924 = min((_731 * SMRTMaxSlopeBias), (max(0.0f, dot(float2(((-0.0f - mad(_748, _367, mad(_746, _366, (_745 * _365)))) / _761), ((-0.0f - mad(_752, _367, mad(_751, _366, (_741 * _365)))) / _761)), float2(_919, _920))) * 2.0f));
                      _938 = (mad(_924, _537, mad(_920, _741, (_919 * _745))) + _687);
                      _939 = (mad(_924, _538, mad(_920, _751, (_919 * _746))) + _688);
                      _940 = (mad(_924, _539, mad(_920, _752, (_919 * _748))) + _689);
                    } else {
                      _938 = _687;
                      _939 = _688;
                      _940 = _689;
                    }
                    _947 = ((_533 * 0.75f) * _536) * saturate(1.5f / (_893 + (sqrt(_890) * SMRTCotMaxRayAngleFromLight)));
                    _949 = min(_516, (_947 + -9.999999974752427e-07f));
                    _953 = (_949 * _896) + _938;
                    _954 = (_949 * _899) + _939;
                    _955 = (_949 * _902) + _940;
                    _959 = (_947 * _896) + _938;
                    _960 = (_947 * _899) + _939;
                    _961 = (_947 * _902) + _940;
                    if (_734 > 0.0f) {
                      _966 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_604 + 64u)))).x;
                      _967 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_604 + 64u)))).y;
                      _968 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_604 + 64u)))).w;
                      _973 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_604 + 80u)))).x;
                      _974 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_604 + 80u)))).y;
                      _975 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_604 + 80u)))).w;
                      _980 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_604 + 96u)))).x;
                      _981 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_604 + 96u)))).y;
                      _982 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_604 + 96u)))).w;
                      _987 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_604 + 112u)))).x;
                      _988 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_604 + 112u)))).y;
                      _989 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_604 + 112u)))).w;
                      _1004 = mad(_955, asfloat(_982), mad(_954, asfloat(_975), (asfloat(_968) * _953))) + asfloat(_989);
                      _1005 = (mad(_955, asfloat(_980), mad(_954, asfloat(_973), (asfloat(_966) * _953))) + asfloat(_987)) / _1004;
                      _1006 = (mad(_955, asfloat(_981), mad(_954, asfloat(_974), (asfloat(_967) * _953))) + asfloat(_988)) / _1004;
                      _1007 = ((uint)_603 < (uint)8192);
                      if (!_1007) {
                        _1019 = ((int)((((_603 * 21845) + (uint)(-178946048)) + uint(_1005 * 128.0f)) + ((int)(uint(_1006 * 128.0f)) << 7)));
                      } else {
                        _1019 = _603;
                      }
                      _1022 = VirtualShadowMap_PageTable[_1019];
                      _1027 = select(_1007, 128.0f, float((uint)((uint)((uint)(16384u) >> (((uint)(_1022) >> 20) & 31)))));
                      _1028 = _1027 * _1005;
                      _1029 = _1027 * _1006;
                      _1045 = min(_734, (max(0.0f, dot(float2(((-0.0f - mad(_691, asfloat(_640), mad(_367, asfloat(_632), mad(_366, asfloat(_624), (asfloat(_616) * _365))))) / _703), ((-0.0f - mad(_691, asfloat(_641), mad(_367, asfloat(_633), mad(_366, asfloat(_625), (asfloat(_617) * _365))))) / _703)), float2((((0.5f - _1028) + float((uint)uint(_1028))) / _1027), (((0.5f - _1029) + float((uint)uint(_1029))) / _1027)))) * 2.0f));
                    } else {
                      _1045 = 0.0f;
                    }
                    if (_529) {
                      _1047 = _285 * 288;
                      _1051 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_1047 + 64u)))).x;
                      _1052 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_1047 + 64u)))).y;
                      _1053 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_1047 + 64u)))).z;
                      _1054 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_1047 + 64u)))).w;
                      _1055 = asfloat(_1051);
                      _1056 = asfloat(_1052);
                      _1057 = asfloat(_1053);
                      _1058 = asfloat(_1054);
                      _1061 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_1047 + 80u)))).x;
                      _1062 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_1047 + 80u)))).y;
                      _1063 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_1047 + 80u)))).z;
                      _1064 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_1047 + 80u)))).w;
                      _1065 = asfloat(_1061);
                      _1066 = asfloat(_1062);
                      _1067 = asfloat(_1063);
                      _1068 = asfloat(_1064);
                      _1071 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_1047 + 96u)))).x;
                      _1072 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_1047 + 96u)))).y;
                      _1073 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_1047 + 96u)))).z;
                      _1074 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_1047 + 96u)))).w;
                      _1075 = asfloat(_1071);
                      _1076 = asfloat(_1072);
                      _1077 = asfloat(_1073);
                      _1078 = asfloat(_1074);
                      _1081 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_1047 + 112u)))).x;
                      _1082 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_1047 + 112u)))).y;
                      _1083 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_1047 + 112u)))).z;
                      _1084 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_1047 + 112u)))).w;
                      _1085 = asfloat(_1081);
                      _1086 = asfloat(_1082);
                      _1087 = asfloat(_1083);
                      _1088 = asfloat(_1084);
                      _1104 = mad(_955, _1078, mad(_954, _1068, (_1058 * _953))) + _1088;
                      _1120 = mad(_961, _1078, mad(_960, _1068, (_1058 * _959))) + _1088;
                      _1121 = (mad(_955, _1075, mad(_954, _1065, (_1055 * _953))) + _1085) / _1104;
                      _1122 = (mad(_955, _1076, mad(_954, _1066, (_1056 * _953))) + _1086) / _1104;
                      _1123 = (mad(_955, _1077, mad(_954, _1067, (_1057 * _953))) + _1087) / _1104;
                      _1129 = ((mad(_961, _1077, mad(_960, _1067, (_1057 * _959))) + _1087) / _1120) - _1123;
                      _1132 = _1123 + _1045;
                      _1133 = _1129 * SMRTExtrapolateSlope;
                      if ((int)_767 > (int)-1) {
                        _1140 = -10000.0f;
                        _1141 = -1.0f;
                        _1142 = 0.0f;
                        _1143 = -1.0f;
                        _1144 = 0;
                        while(true) {
                          if (!(_1144 == _767)) {
                            _1150 = ((float((int)(_1144)) + (1.0f - _769)) * (-1.0f / float((int)(_767)))) + 1.0f;
                            _1153 = (_1150 * _1150);
                          } else {
                            _1153 = 0.0f;
                          }
                          _1157 = (_1153 * (((mad(_961, _1075, mad(_960, _1065, (_1055 * _959))) + _1085) / _1120) - _1121)) + saturate(_1121);
                          _1158 = (_1153 * (((mad(_961, _1076, mad(_960, _1066, (_1056 * _959))) + _1086) / _1120) - _1122)) + saturate(_1122);
                          _1159 = (_1153 * _1129) + _1132;
                          if ((int)(_1157 == saturate(_1157)) && (int)(_1158 == saturate(_1158))) {
                            _1166 = ((uint)_285 < (uint)8192);
                            if (!_1166) {
                              _1178 = ((int)((((_285 * 21845) + (uint)(-178946048)) + uint(_1157 * 128.0f)) + ((int)(uint(_1158 * 128.0f)) << 7)));
                            } else {
                              _1178 = _285;
                            }
                            _1181 = VirtualShadowMap_PageTable[_1178];
                            _1187 = select(_1166, 128.0f, float((uint)((uint)((uint)(16384u) >> (((uint)(_1181) >> 20) & 31)))));
                            if ((int)_1181 < (int)0) {
                              _1206 = true;
                              _1207 = asfloat((((uint)(VirtualShadowMap_PhysicalPagePool.Load(int4((((int)(uint(_1187 * _1157)) & 127) | (((int)(_1181 << 7)) & 130944)), (((int)(uint(_1187 * _1158)) & 127) | (((uint)(_1181) >> 3) & 130944)), 0, 0)))).x));
                            } else {
                              _1206 = false;
                              _1207 = 0.0f;
                            }
                            _1211 = select(_1206, _1207, 0.0f);
                            _1212 = ((int)(uint)(_1206));
                          } else {
                            _1211 = 0.0f;
                            _1212 = 0;
                          }
                          if (_1212 == 0) {
                            _1247 = _1140;
                            _1248 = _1141;
                            _1249 = _1142;
                            _1250 = _1143;
                            if ((int)_1144 < (int)_767) {
                              _1140 = _1247;
                              _1141 = _1248;
                              _1142 = _1249;
                              _1143 = _1250;
                              _1144 = (_1144 + 1);
                              continue;
                            } else {
                              _1918 = -1.0f;
                              _1919 = 0;
                            }
                          } else {
                            if (_1140 == -10000.0f) {
                              if (!(_1211 > _1159)) {
                                _1247 = _1211;
                                _1248 = _1153;
                                _1249 = _1142;
                                _1250 = _1159;
                                if ((int)_1144 < (int)_767) {
                                  _1140 = _1247;
                                  _1141 = _1248;
                                  _1142 = _1249;
                                  _1143 = _1250;
                                  _1144 = (_1144 + 1);
                                  continue;
                                } else {
                                  _1918 = -1.0f;
                                  _1919 = 0;
                                }
                              } else {
                                _1918 = _1211;
                                _1919 = 1;
                              }
                            } else {
                              _1220 = abs(_1159 - _1143);
                              _1224 = _1153 - _1141;
                              if ((_1211 - _1159) > (_1220 * 1.0499999523162842f)) {
                                _1237 = _1140;
                                _1238 = _1141;
                                _1239 = _1142;
                                _1240 = ((_1224 * _1142) + _1140);
                              } else {
                                if (_1211 != _1140) {
                                  _1237 = _1211;
                                  _1238 = _1153;
                                  _1239 = min(max(((_1211 - _1140) / _1224), (-0.0f - _1133)), _1133);
                                  _1240 = _1211;
                                } else {
                                  _1237 = _1140;
                                  _1238 = _1141;
                                  _1239 = _1142;
                                  _1240 = _1211;
                                }
                              }
                              _1241 = _1220 * 0.5249999761581421f;
                              if (!(abs((_1241 + _1159) - _1240) < _1241)) {
                                _1247 = _1237;
                                _1248 = _1238;
                                _1249 = _1239;
                                _1250 = _1159;
                                if ((int)_1144 < (int)_767) {
                                  _1140 = _1247;
                                  _1141 = _1248;
                                  _1142 = _1249;
                                  _1143 = _1250;
                                  _1144 = (_1144 + 1);
                                  continue;
                                } else {
                                  _1918 = -1.0f;
                                  _1919 = 0;
                                }
                              } else {
                                _1918 = _1240;
                                _1919 = 1;
                              }
                            }
                          }
                          _1924 = _285;
                          _1925 = _1132;
                          _1926 = _1918;
                          _1927 = _1919;
                          break;
                        }
                      } else {
                        _1924 = _285;
                        _1925 = _1132;
                        _1926 = -1.0f;
                        _1927 = 0;
                      }
                    } else {
                      _1254 = abs(_953);
                      _1255 = abs(_954);
                      _1257 = abs(_955);
                      if ((int)(_1254 < _1255) || (int)(_1254 < _1257)) {
                        if (_1255 > _1257) {
                          _1272 = select((_954 > 0.0f), 2, 3);
                        } else {
                          _1272 = select((_955 > 0.0f), 4, 5);
                        }
                      } else {
                        _1272 = ((int)(uint)((int)(!(_953 > 0.0f))));
                      }
                      _1273 = abs(_959);
                      _1274 = abs(_960);
                      _1276 = abs(_961);
                      if ((int)(_1273 < _1274) || (int)(_1273 < _1276)) {
                        if (_1274 > _1276) {
                          _1291 = select((_960 > 0.0f), 2, 3);
                        } else {
                          _1291 = select((_961 > 0.0f), 4, 5);
                        }
                      } else {
                        _1291 = ((int)(uint)((int)(!(_959 > 0.0f))));
                      }
                      _1293 = WaveActiveAnyTrue(_1272 != _1291);
                      _1294 = _1291 + _285;
                      _1295 = _1294 * 288;
                      _1297 = _1295 + 64u;
                      _1298 = _1295 + 80u;
                      _1299 = _1295 + 96u;
                      _1300 = _1295 + 112u;
                      _1302 = -1.0f / float((int)(_767));
                      _1303 = 1.0f - _769;
                      _1304 = ((int)_767 > (int)-1);
                      if (_1293) {
                        _1306 = _1272 + _285;
                        _1307 = _1306 * 288;
                        _1310 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_1307 + 64u)))).x;
                        _1311 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_1307 + 64u)))).y;
                        _1312 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_1307 + 64u)))).z;
                        _1313 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_1307 + 64u)))).w;
                        _1314 = asfloat(_1310);
                        _1315 = asfloat(_1311);
                        _1316 = asfloat(_1312);
                        _1317 = asfloat(_1313);
                        _1320 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_1307 + 80u)))).x;
                        _1321 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_1307 + 80u)))).y;
                        _1322 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_1307 + 80u)))).z;
                        _1323 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_1307 + 80u)))).w;
                        _1324 = asfloat(_1320);
                        _1325 = asfloat(_1321);
                        _1326 = asfloat(_1322);
                        _1327 = asfloat(_1323);
                        _1330 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_1307 + 96u)))).x;
                        _1331 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_1307 + 96u)))).y;
                        _1332 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_1307 + 96u)))).z;
                        _1333 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_1307 + 96u)))).w;
                        _1334 = asfloat(_1330);
                        _1335 = asfloat(_1331);
                        _1336 = asfloat(_1332);
                        _1337 = asfloat(_1333);
                        _1340 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_1307 + 112u)))).x;
                        _1341 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_1307 + 112u)))).y;
                        _1342 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_1307 + 112u)))).z;
                        _1343 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_1307 + 112u)))).w;
                        _1344 = asfloat(_1340);
                        _1345 = asfloat(_1341);
                        _1346 = asfloat(_1342);
                        _1347 = asfloat(_1343);
                        _1363 = mad(_955, _1337, mad(_954, _1327, (_1317 * _953))) + _1347;
                        _1379 = mad(_961, _1337, mad(_960, _1327, (_1317 * _959))) + _1347;
                        _1380 = (mad(_955, _1334, mad(_954, _1324, (_1314 * _953))) + _1344) / _1363;
                        _1381 = (mad(_955, _1335, mad(_954, _1325, (_1315 * _953))) + _1345) / _1363;
                        _1382 = (mad(_955, _1336, mad(_954, _1326, (_1316 * _953))) + _1346) / _1363;
                        _1386 = ((mad(_961, _1334, mad(_960, _1324, (_1314 * _959))) + _1344) / _1379) - _1380;
                        _1387 = ((mad(_961, _1335, mad(_960, _1325, (_1315 * _959))) + _1345) / _1379) - _1381;
                        _1388 = ((mad(_961, _1336, mad(_960, _1326, (_1316 * _959))) + _1346) / _1379) - _1382;
                        _1389 = _1382 + _1045;
                        _1390 = _1388 * SMRTExtrapolateSlope;
                        _1392 = asint(VirtualShadowMap_ProjectionData.Load4(_1297)).x;
                        _1393 = asint(VirtualShadowMap_ProjectionData.Load4(_1297)).y;
                        _1394 = asint(VirtualShadowMap_ProjectionData.Load4(_1297)).z;
                        _1395 = asint(VirtualShadowMap_ProjectionData.Load4(_1297)).w;
                        _1396 = asfloat(_1392);
                        _1397 = asfloat(_1393);
                        _1398 = asfloat(_1394);
                        _1399 = asfloat(_1395);
                        _1401 = asint(VirtualShadowMap_ProjectionData.Load4(_1298)).x;
                        _1402 = asint(VirtualShadowMap_ProjectionData.Load4(_1298)).y;
                        _1403 = asint(VirtualShadowMap_ProjectionData.Load4(_1298)).z;
                        _1404 = asint(VirtualShadowMap_ProjectionData.Load4(_1298)).w;
                        _1405 = asfloat(_1401);
                        _1406 = asfloat(_1402);
                        _1407 = asfloat(_1403);
                        _1408 = asfloat(_1404);
                        _1410 = asint(VirtualShadowMap_ProjectionData.Load4(_1299)).x;
                        _1411 = asint(VirtualShadowMap_ProjectionData.Load4(_1299)).y;
                        _1412 = asint(VirtualShadowMap_ProjectionData.Load4(_1299)).z;
                        _1413 = asint(VirtualShadowMap_ProjectionData.Load4(_1299)).w;
                        _1414 = asfloat(_1410);
                        _1415 = asfloat(_1411);
                        _1416 = asfloat(_1412);
                        _1417 = asfloat(_1413);
                        _1419 = asint(VirtualShadowMap_ProjectionData.Load4(_1300)).x;
                        _1420 = asint(VirtualShadowMap_ProjectionData.Load4(_1300)).y;
                        _1421 = asint(VirtualShadowMap_ProjectionData.Load4(_1300)).z;
                        _1422 = asint(VirtualShadowMap_ProjectionData.Load4(_1300)).w;
                        _1423 = asfloat(_1419);
                        _1424 = asfloat(_1420);
                        _1425 = asfloat(_1421);
                        _1426 = asfloat(_1422);
                        _1442 = mad(_955, _1417, mad(_954, _1408, (_1399 * _953))) + _1426;
                        _1458 = mad(_961, _1417, mad(_960, _1408, (_1399 * _959))) + _1426;
                        _1459 = (mad(_955, _1414, mad(_954, _1405, (_1396 * _953))) + _1423) / _1442;
                        _1460 = (mad(_955, _1415, mad(_954, _1406, (_1397 * _953))) + _1424) / _1442;
                        _1461 = (mad(_955, _1416, mad(_954, _1407, (_1398 * _953))) + _1425) / _1442;
                        _1467 = ((mad(_961, _1416, mad(_960, _1407, (_1398 * _959))) + _1425) / _1458) - _1461;
                        _1468 = _1461 + _1045;
                        if (_1304) {
                          _1472 = 1;
                          _1473 = -10000.0f;
                          _1474 = -1.0f;
                          _1475 = 0.0f;
                          _1476 = -1.0f;
                          _1477 = 0;
                          while(true) {
                            if (!(_1477 == _767)) {
                              _1483 = ((float((int)(_1477)) + _1303) * _1302) + 1.0f;
                              _1486 = (_1483 * _1483);
                            } else {
                              _1486 = 0.0f;
                            }
                            if (_1472 == 0) {
                              _1610 = (_1486 * _1386) + _1380;
                              _1611 = (_1486 * _1387) + _1381;
                              _1612 = (_1486 * _1388) + _1389;
                              if ((int)(_1610 == saturate(_1610)) && (int)(_1611 == saturate(_1611))) {
                                _1619 = ((uint)_1306 < (uint)8192);
                                if (!_1619) {
                                  _1631 = ((int)((((_1306 * 21845) + (uint)(-178946048)) + uint(_1610 * 128.0f)) + ((int)(uint(_1611 * 128.0f)) << 7)));
                                } else {
                                  _1631 = _1306;
                                }
                                _1634 = VirtualShadowMap_PageTable[_1631];
                                _1640 = select(_1619, 128.0f, float((uint)((uint)((uint)(16384u) >> (((uint)(_1634) >> 20) & 31)))));
                                if ((int)_1634 < (int)0) {
                                  _1659 = true;
                                  _1660 = asfloat((((uint)(VirtualShadowMap_PhysicalPagePool.Load(int4((((int)(uint(_1640 * _1610)) & 127) | (((int)(_1634 << 7)) & 130944)), (((int)(uint(_1640 * _1611)) & 127) | (((uint)(_1634) >> 3) & 130944)), 0, 0)))).x));
                                } else {
                                  _1659 = false;
                                  _1660 = 0.0f;
                                }
                                _1664 = 0;
                                _1665 = _1475;
                                _1666 = _1390;
                                _1667 = _1612;
                                _1668 = select(_1659, _1660, 0.0f);
                                _1669 = ((int)(uint)(_1659));
                              } else {
                                _1664 = 0;
                                _1665 = _1475;
                                _1666 = _1390;
                                _1667 = _1612;
                                _1668 = 0.0f;
                                _1669 = 0;
                              }
                            } else {
                              _1492 = (_1486 * (((mad(_961, _1414, mad(_960, _1405, (_1396 * _959))) + _1423) / _1458) - _1459)) + _1459;
                              _1493 = (_1486 * (((mad(_961, _1415, mad(_960, _1406, (_1397 * _959))) + _1424) / _1458) - _1460)) + _1460;
                              if ((int)(_1492 == saturate(_1492)) && (int)(_1493 == saturate(_1493))) {
                                _1501 = ((uint)_1294 < (uint)8192);
                                if (!_1501) {
                                  _1513 = ((int)((((_1294 * 21845) + (uint)(-178946048)) + uint(_1492 * 128.0f)) + ((int)(uint(_1493 * 128.0f)) << 7)));
                                } else {
                                  _1513 = _1294;
                                }
                                _1516 = VirtualShadowMap_PageTable[_1513];
                                _1522 = select(_1501, 128.0f, float((uint)((uint)((uint)(16384u) >> (((uint)(_1516) >> 20) & 31)))));
                                if ((int)_1516 < (int)0) {
                                  _1541 = true;
                                  _1542 = asfloat((((uint)(VirtualShadowMap_PhysicalPagePool.Load(int4((((int)(uint(_1522 * _1492)) & 127) | (((int)(_1516 << 7)) & 130944)), (((int)(uint(_1522 * _1493)) & 127) | (((uint)(_1516) >> 3) & 130944)), 0, 0)))).x));
                                } else {
                                  _1541 = false;
                                  _1542 = 0.0f;
                                }
                                _1546 = select(_1541, _1542, 0.0f);
                                _1547 = ((int)(uint)(_1541));
                              } else {
                                _1546 = 0.0f;
                                _1547 = 0;
                              }
                              if (_1547 == 0) {
                                _1553 = (_1486 * _1386) + _1380;
                                _1554 = (_1486 * _1387) + _1381;
                                _1555 = (_1486 * _1388) + _1389;
                                if ((int)(_1553 == saturate(_1553)) && (int)(_1554 == saturate(_1554))) {
                                  _1562 = ((uint)_1306 < (uint)8192);
                                  if (!_1562) {
                                    _1574 = ((int)((((_1306 * 21845) + (uint)(-178946048)) + uint(_1553 * 128.0f)) + ((int)(uint(_1554 * 128.0f)) << 7)));
                                  } else {
                                    _1574 = _1306;
                                  }
                                  _1577 = VirtualShadowMap_PageTable[_1574];
                                  _1583 = select(_1562, 128.0f, float((uint)((uint)((uint)(16384u) >> (((uint)(_1577) >> 20) & 31)))));
                                  if ((int)_1577 < (int)0) {
                                    _1602 = asfloat((((uint)(VirtualShadowMap_PhysicalPagePool.Load(int4((((int)(uint(_1583 * _1553)) & 127) | (((int)(_1577 << 7)) & 130944)), (((int)(uint(_1583 * _1554)) & 127) | (((uint)(_1577) >> 3) & 130944)), 0, 0)))).x));
                                    _1603 = true;
                                  } else {
                                    _1602 = 0.0f;
                                    _1603 = false;
                                  }
                                  _1664 = 0;
                                  _1665 = _1390;
                                  _1666 = _1390;
                                  _1667 = _1555;
                                  _1668 = select(_1603, _1602, 0.0f);
                                  _1669 = ((int)(uint)(_1603));
                                } else {
                                  _1664 = 0;
                                  _1665 = _1390;
                                  _1666 = _1390;
                                  _1667 = _1555;
                                  _1668 = 0.0f;
                                  _1669 = 0;
                                }
                              } else {
                                _1664 = _1472;
                                _1665 = _1475;
                                _1666 = (_1467 * SMRTExtrapolateSlope);
                                _1667 = ((_1486 * _1467) + _1468);
                                _1668 = _1546;
                                _1669 = _1547;
                              }
                            }
                            if (_1669 == 0) {
                              _1704 = _1473;
                              _1705 = _1474;
                              _1706 = _1665;
                              _1707 = _1476;
                              if ((int)_1477 < (int)_767) {
                                _1472 = _1664;
                                _1473 = _1704;
                                _1474 = _1705;
                                _1475 = _1706;
                                _1476 = _1707;
                                _1477 = (_1477 + 1);
                                continue;
                              } else {
                                _1711 = -1.0f;
                                _1712 = 0;
                              }
                            } else {
                              if (_1473 == -10000.0f) {
                                if (!(_1668 > _1667)) {
                                  _1704 = _1668;
                                  _1705 = _1486;
                                  _1706 = _1665;
                                  _1707 = _1667;
                                  if ((int)_1477 < (int)_767) {
                                    _1472 = _1664;
                                    _1473 = _1704;
                                    _1474 = _1705;
                                    _1475 = _1706;
                                    _1476 = _1707;
                                    _1477 = (_1477 + 1);
                                    continue;
                                  } else {
                                    _1711 = -1.0f;
                                    _1712 = 0;
                                  }
                                } else {
                                  _1711 = _1668;
                                  _1712 = 1;
                                }
                              } else {
                                _1677 = abs(_1667 - _1476);
                                _1681 = _1486 - _1474;
                                if ((_1668 - _1667) > (_1677 * 1.0499999523162842f)) {
                                  _1694 = _1473;
                                  _1695 = _1474;
                                  _1696 = _1665;
                                  _1697 = ((_1665 * _1681) + _1473);
                                } else {
                                  if (_1668 != _1473) {
                                    _1694 = _1668;
                                    _1695 = _1486;
                                    _1696 = min(max(((_1668 - _1473) / _1681), (-0.0f - _1666)), _1666);
                                    _1697 = _1668;
                                  } else {
                                    _1694 = _1473;
                                    _1695 = _1474;
                                    _1696 = _1665;
                                    _1697 = _1668;
                                  }
                                }
                                _1698 = _1677 * 0.5249999761581421f;
                                if (!(abs((_1698 + _1667) - _1697) < _1698)) {
                                  _1704 = _1694;
                                  _1705 = _1695;
                                  _1706 = _1696;
                                  _1707 = _1667;
                                  if ((int)_1477 < (int)_767) {
                                    _1472 = _1664;
                                    _1473 = _1704;
                                    _1474 = _1705;
                                    _1475 = _1706;
                                    _1476 = _1707;
                                    _1477 = (_1477 + 1);
                                    continue;
                                  } else {
                                    _1711 = -1.0f;
                                    _1712 = 0;
                                  }
                                } else {
                                  _1711 = _1697;
                                  _1712 = 1;
                                }
                              }
                            }
                            _1714 = _1664;
                            _1715 = _1711;
                            _1716 = _1712;
                            break;
                          }
                        } else {
                          _1714 = 1;
                          _1715 = -1.0f;
                          _1716 = 0;
                        }
                        _1717 = (_1714 != 0);
                        _1924 = select(_1717, _1294, _1306);
                        _1925 = select(_1717, _1468, _1389);
                        _1926 = _1715;
                        _1927 = _1716;
                      } else {
                        _1722 = asint(VirtualShadowMap_ProjectionData.Load4(_1297)).x;
                        _1723 = asint(VirtualShadowMap_ProjectionData.Load4(_1297)).y;
                        _1724 = asint(VirtualShadowMap_ProjectionData.Load4(_1297)).z;
                        _1725 = asint(VirtualShadowMap_ProjectionData.Load4(_1297)).w;
                        _1726 = asfloat(_1722);
                        _1727 = asfloat(_1723);
                        _1728 = asfloat(_1724);
                        _1729 = asfloat(_1725);
                        _1731 = asint(VirtualShadowMap_ProjectionData.Load4(_1298)).x;
                        _1732 = asint(VirtualShadowMap_ProjectionData.Load4(_1298)).y;
                        _1733 = asint(VirtualShadowMap_ProjectionData.Load4(_1298)).z;
                        _1734 = asint(VirtualShadowMap_ProjectionData.Load4(_1298)).w;
                        _1735 = asfloat(_1731);
                        _1736 = asfloat(_1732);
                        _1737 = asfloat(_1733);
                        _1738 = asfloat(_1734);
                        _1740 = asint(VirtualShadowMap_ProjectionData.Load4(_1299)).x;
                        _1741 = asint(VirtualShadowMap_ProjectionData.Load4(_1299)).y;
                        _1742 = asint(VirtualShadowMap_ProjectionData.Load4(_1299)).z;
                        _1743 = asint(VirtualShadowMap_ProjectionData.Load4(_1299)).w;
                        _1744 = asfloat(_1740);
                        _1745 = asfloat(_1741);
                        _1746 = asfloat(_1742);
                        _1747 = asfloat(_1743);
                        _1749 = asint(VirtualShadowMap_ProjectionData.Load4(_1300)).x;
                        _1750 = asint(VirtualShadowMap_ProjectionData.Load4(_1300)).y;
                        _1751 = asint(VirtualShadowMap_ProjectionData.Load4(_1300)).z;
                        _1752 = asint(VirtualShadowMap_ProjectionData.Load4(_1300)).w;
                        _1753 = asfloat(_1749);
                        _1754 = asfloat(_1750);
                        _1755 = asfloat(_1751);
                        _1756 = asfloat(_1752);
                        _1772 = mad(_955, _1747, mad(_954, _1738, (_1729 * _953))) + _1756;
                        _1788 = mad(_961, _1747, mad(_960, _1738, (_1729 * _959))) + _1756;
                        _1789 = (mad(_955, _1744, mad(_954, _1735, (_1726 * _953))) + _1753) / _1772;
                        _1790 = (mad(_955, _1745, mad(_954, _1736, (_1727 * _953))) + _1754) / _1772;
                        _1791 = (mad(_955, _1746, mad(_954, _1737, (_1728 * _953))) + _1755) / _1772;
                        _1797 = ((mad(_961, _1746, mad(_960, _1737, (_1728 * _959))) + _1755) / _1788) - _1791;
                        _1800 = _1791 + _1045;
                        _1801 = _1797 * SMRTExtrapolateSlope;
                        if (_1304) {
                          _1804 = -10000.0f;
                          _1805 = -1.0f;
                          _1806 = 0.0f;
                          _1807 = -1.0f;
                          _1808 = 0;
                          while(true) {
                            if (!(_1808 == _767)) {
                              _1814 = ((float((int)(_1808)) + _1303) * _1302) + 1.0f;
                              _1817 = (_1814 * _1814);
                            } else {
                              _1817 = 0.0f;
                            }
                            _1821 = (_1817 * (((mad(_961, _1744, mad(_960, _1735, (_1726 * _959))) + _1753) / _1788) - _1789)) + saturate(_1789);
                            _1822 = (_1817 * (((mad(_961, _1745, mad(_960, _1736, (_1727 * _959))) + _1754) / _1788) - _1790)) + saturate(_1790);
                            _1823 = (_1817 * _1797) + _1800;
                            if ((int)(_1821 == saturate(_1821)) && (int)(_1822 == saturate(_1822))) {
                              _1830 = ((uint)_1294 < (uint)8192);
                              if (!_1830) {
                                _1842 = ((int)((((_1294 * 21845) + (uint)(-178946048)) + uint(_1821 * 128.0f)) + ((int)(uint(_1822 * 128.0f)) << 7)));
                              } else {
                                _1842 = _1294;
                              }
                              _1845 = VirtualShadowMap_PageTable[_1842];
                              _1851 = select(_1830, 128.0f, float((uint)((uint)((uint)(16384u) >> (((uint)(_1845) >> 20) & 31)))));
                              if ((int)_1845 < (int)0) {
                                _1870 = asfloat((((uint)(VirtualShadowMap_PhysicalPagePool.Load(int4((((int)(uint(_1851 * _1821)) & 127) | (((int)(_1845 << 7)) & 130944)), (((int)(uint(_1851 * _1822)) & 127) | (((uint)(_1845) >> 3) & 130944)), 0, 0)))).x));
                                _1871 = true;
                              } else {
                                _1870 = 0.0f;
                                _1871 = false;
                              }
                              _1875 = select(_1871, _1870, 0.0f);
                              _1876 = ((int)(uint)(_1871));
                            } else {
                              _1875 = 0.0f;
                              _1876 = 0;
                            }
                            if (_1876 == 0) {
                              _1911 = _1804;
                              _1912 = _1805;
                              _1913 = _1806;
                              _1914 = _1807;
                              if ((int)_1808 < (int)_767) {
                                _1804 = _1911;
                                _1805 = _1912;
                                _1806 = _1913;
                                _1807 = _1914;
                                _1808 = (_1808 + 1);
                                continue;
                              } else {
                                _1921 = -1.0f;
                                _1922 = 0;
                              }
                            } else {
                              if (_1804 == -10000.0f) {
                                if (!(_1875 > _1823)) {
                                  _1911 = _1875;
                                  _1912 = _1817;
                                  _1913 = _1806;
                                  _1914 = _1823;
                                  if ((int)_1808 < (int)_767) {
                                    _1804 = _1911;
                                    _1805 = _1912;
                                    _1806 = _1913;
                                    _1807 = _1914;
                                    _1808 = (_1808 + 1);
                                    continue;
                                  } else {
                                    _1921 = -1.0f;
                                    _1922 = 0;
                                  }
                                } else {
                                  _1921 = _1875;
                                  _1922 = 1;
                                }
                              } else {
                                _1884 = abs(_1823 - _1807);
                                _1888 = _1817 - _1805;
                                if ((_1875 - _1823) > (_1884 * 1.0499999523162842f)) {
                                  _1901 = _1804;
                                  _1902 = _1805;
                                  _1903 = _1806;
                                  _1904 = ((_1888 * _1806) + _1804);
                                } else {
                                  if (_1875 != _1804) {
                                    _1901 = _1875;
                                    _1902 = _1817;
                                    _1903 = min(max(((_1875 - _1804) / _1888), (-0.0f - _1801)), _1801);
                                    _1904 = _1875;
                                  } else {
                                    _1901 = _1804;
                                    _1902 = _1805;
                                    _1903 = _1806;
                                    _1904 = _1875;
                                  }
                                }
                                _1905 = _1884 * 0.5249999761581421f;
                                if (!(abs((_1905 + _1823) - _1904) < _1905)) {
                                  _1911 = _1901;
                                  _1912 = _1902;
                                  _1913 = _1903;
                                  _1914 = _1823;
                                  if ((int)_1808 < (int)_767) {
                                    _1804 = _1911;
                                    _1805 = _1912;
                                    _1806 = _1913;
                                    _1807 = _1914;
                                    _1808 = (_1808 + 1);
                                    continue;
                                  } else {
                                    _1921 = -1.0f;
                                    _1922 = 0;
                                  }
                                } else {
                                  _1921 = _1904;
                                  _1922 = 1;
                                }
                              }
                            }
                            _1924 = _1294;
                            _1925 = _1800;
                            _1926 = _1921;
                            _1927 = _1922;
                            break;
                          }
                        } else {
                          _1924 = _1294;
                          _1925 = _1800;
                          _1926 = -1.0f;
                          _1927 = 0;
                        }
                      }
                    }
                    _1928 = (_1927 == 0);
                    if (_1928) {
                      _1959 = ((int)(_771 + 1u));
                      _1960 = _772;
                    } else {
                      _1935 = sqrt(((_953 * _953) + (_954 * _954)) + (_955 * _955));
                      _1937 = _1924 * 288;
                      _1941 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_1937 + 32u)))).z;
                      _1942 = asfloat(_1941);
                      _1945 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_1937 + 48u)))).z;
                      _1946 = asfloat(_1945);
                      _1959 = _771;
                      _1960 = (max(9.999999974752427e-07f, (_1935 - ((((saturate(_1925) - _1942) * _1935) / _1946) * (_1946 / (_1926 - _1942))))) + _772);
                    }
                    if (!(SMRTAdaptiveRayCount == 0)) {
                      if (_770 == 0) {
                        _1965 = WaveActiveAllTrue(_1928);
                        if (!_1965) {
                          _1974 = (asint(_769) * -1835707051) + 1216271409u;
                          _1980 = _770 + 1u;
                          if ((uint)_1980 < (uint)_hair_smrt_ray_count) {
                            _769 = (float((uint)((uint)((uint)((uint)(((uint)(_1974) >> 15) ^ _1974)) >> 8))) * 5.960464477539063e-08f);
                            _770 = _1980;
                            _771 = _1959;
                            _772 = _1960;
                            continue;
                          } else {
                            _1983 = _1980;
                          }
                        } else {
                          _1983 = 0;
                        }
                      } else {
                        if (((uint)_770 < (uint)SMRTAdaptiveRayCount) | !(WaveActiveAllTrue(_1959 == 0))) {
                          _1974 = (asint(_769) * -1835707051) + 1216271409u;
                          _1980 = _770 + 1u;
                          if ((uint)_1980 < (uint)_hair_smrt_ray_count) {
                            _769 = (float((uint)((uint)((uint)((uint)(((uint)(_1974) >> 15) ^ _1974)) >> 8))) * 5.960464477539063e-08f);
                            _770 = _1980;
                            _771 = _1959;
                            _772 = _1960;
                            continue;
                          } else {
                            _1983 = _1980;
                          }
                        } else {
                          _1983 = _770;
                        }
                      }
                    } else {
                      _1974 = (asint(_769) * -1835707051) + 1216271409u;
                      _1980 = _770 + 1u;
                      if ((uint)_1980 < (uint)_hair_smrt_ray_count) {
                        _769 = (float((uint)((uint)((uint)((uint)(((uint)(_1974) >> 15) ^ _1974)) >> 8))) * 5.960464477539063e-08f);
                        _770 = _1980;
                        _771 = _1959;
                        _772 = _1960;
                        continue;
                      } else {
                        _1983 = _1980;
                      }
                    }
                    _1985 = (int)min((uint)(((int)(_1983 + 1u))), (uint)(_hair_smrt_ray_count));
                    _2326 = (float((uint)_1959) / float((uint)_1985));
                    _2327 = (_1960 / float((uint)((uint)((int)max((uint)(1), (uint)(((int)(_1985 - _1959))))))));
                    break;
                  }
                } else {
                  _2326 = 0.0f;
                  _2327 = -1.0f;
                }
              } else {
                _1994 = max(_516, 0.0f);
                _1995 = _285 * 288;
                _1999 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_1995 + 32u)))).z;
                _2002 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_1995 + 48u)))).z;
                _2005 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_1995 + 64u)))).x;
                _2006 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_1995 + 64u)))).y;
                _2007 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_1995 + 64u)))).z;
                _2008 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_1995 + 64u)))).w;
                _2011 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_1995 + 80u)))).x;
                _2012 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_1995 + 80u)))).y;
                _2013 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_1995 + 80u)))).z;
                _2014 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_1995 + 80u)))).w;
                _2017 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_1995 + 96u)))).x;
                _2018 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_1995 + 96u)))).y;
                _2019 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_1995 + 96u)))).z;
                _2020 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_1995 + 96u)))).w;
                _2023 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_1995 + 112u)))).x;
                _2024 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_1995 + 112u)))).y;
                _2025 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_1995 + 112u)))).z;
                _2026 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_1995 + 112u)))).w;
                _2029 = asint(VirtualShadowMap_ProjectionData.Load(((int)(_1995 + 204u))));
                _2032 = asint(VirtualShadowMap_ProjectionData.Load3(((int)(_1995 + 208u)))).x;
                _2033 = asint(VirtualShadowMap_ProjectionData.Load3(((int)(_1995 + 208u)))).y;
                _2034 = asint(VirtualShadowMap_ProjectionData.Load3(((int)(_1995 + 208u)))).z;
                _2040 = asint(VirtualShadowMap_ProjectionData.Load3(((int)(_1995 + 224u)))).x;
                _2041 = asint(VirtualShadowMap_ProjectionData.Load3(((int)(_1995 + 224u)))).y;
                _2042 = asint(VirtualShadowMap_ProjectionData.Load3(((int)(_1995 + 224u)))).z;
                _2063 = ((asfloat(_2032) - View.PreViewTranslationHigh.x) + (asfloat(_2040) - View.PreViewTranslationLow.x)) + _371;
                _2064 = ((asfloat(_2033) - View.PreViewTranslationHigh.y) + (asfloat(_2041) - View.PreViewTranslationLow.y)) + _372;
                _2065 = ((asfloat(_2034) - View.PreViewTranslationHigh.z) + (asfloat(_2042) - View.PreViewTranslationLow.z)) + _373;
                if (!(_2029 == 2)) {
                  _2068 = abs(_2063);
                  _2069 = abs(_2064);
                  _2071 = abs(_2065);
                  if ((int)(_2068 < _2069) || (int)(_2068 < _2071)) {
                    if (_2069 > _2071) {
                      _2086 = select((_2064 > 0.0f), 2, 3);
                    } else {
                      _2086 = select((_2065 > 0.0f), 4, 5);
                    }
                  } else {
                    _2086 = ((int)(uint)((int)(!(_2063 > 0.0f))));
                  }
                  _2087 = _2086 + _285;
                  _2088 = _2087 * 288;
                  _2091 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_2088 + 32u)))).z;
                  _2094 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_2088 + 48u)))).z;
                  _2097 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_2088 + 64u)))).x;
                  _2098 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_2088 + 64u)))).y;
                  _2099 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_2088 + 64u)))).z;
                  _2100 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_2088 + 64u)))).w;
                  _2103 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_2088 + 80u)))).x;
                  _2104 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_2088 + 80u)))).y;
                  _2105 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_2088 + 80u)))).z;
                  _2106 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_2088 + 80u)))).w;
                  _2109 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_2088 + 96u)))).x;
                  _2110 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_2088 + 96u)))).y;
                  _2111 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_2088 + 96u)))).z;
                  _2112 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_2088 + 96u)))).w;
                  _2115 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_2088 + 112u)))).x;
                  _2116 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_2088 + 112u)))).y;
                  _2117 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_2088 + 112u)))).z;
                  _2118 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_2088 + 112u)))).w;
                  _2120 = _2091;
                  _2121 = _2094;
                  _2122 = _2097;
                  _2123 = _2098;
                  _2124 = _2099;
                  _2125 = _2100;
                  _2126 = _2103;
                  _2127 = _2104;
                  _2128 = _2105;
                  _2129 = _2106;
                  _2130 = _2109;
                  _2131 = _2110;
                  _2132 = _2111;
                  _2133 = _2112;
                  _2134 = _2115;
                  _2135 = _2116;
                  _2136 = _2117;
                  _2137 = _2118;
                  _2138 = _2087;
                } else {
                  _2120 = _1999;
                  _2121 = _2002;
                  _2122 = _2005;
                  _2123 = _2006;
                  _2124 = _2007;
                  _2125 = _2008;
                  _2126 = _2011;
                  _2127 = _2012;
                  _2128 = _2013;
                  _2129 = _2014;
                  _2130 = _2017;
                  _2131 = _2018;
                  _2132 = _2019;
                  _2133 = _2020;
                  _2134 = _2023;
                  _2135 = _2024;
                  _2136 = _2025;
                  _2137 = _2026;
                  _2138 = _285;
                }
                _2155 = asfloat(_2121);
                _2156 = asfloat(_2120);
                _2172 = mad(_2065, asfloat(_2133), mad(_2064, asfloat(_2129), (asfloat(_2125) * _2063))) + asfloat(_2137);
                _2173 = (mad(_2065, asfloat(_2130), mad(_2064, asfloat(_2126), (asfloat(_2122) * _2063))) + asfloat(_2134)) / _2172;
                _2174 = (mad(_2065, asfloat(_2131), mad(_2064, asfloat(_2127), (asfloat(_2123) * _2063))) + asfloat(_2135)) / _2172;
                _2175 = (mad(_2065, asfloat(_2132), mad(_2064, asfloat(_2128), (asfloat(_2124) * _2063))) + asfloat(_2136)) / _2172;
                _2176 = ((uint)_2138 < (uint)8192);
                if (!_2176) {
                  _2188 = ((int)((((_2138 * 21845) + (uint)(-178946048)) + uint(_2173 * 128.0f)) + ((int)(uint(_2174 * 128.0f)) << 7)));
                } else {
                  _2188 = _2138;
                }
                _2191 = VirtualShadowMap_PageTable[_2188];
                _2195 = select(_2176, 7, (((uint)(_2191) >> 20) & 63));
                _2198 = float((uint)((uint)((uint)(16384u) >> (_2195 & 31))));
                _2199 = _2198 * _2173;
                _2200 = _2198 * _2174;
                _2201 = uint(_2199);
                _2202 = uint(_2200);
                if ((int)_2191 < (int)0) {
                  _2217 = _2199;
                  _2218 = _2200;
                  _2219 = _2201;
                  _2220 = _2202;
                  _2221 = true;
                  _2222 = _2138;
                  _2223 = _2195;
                  _2224 = asfloat((((uint)(VirtualShadowMap_PhysicalPagePool.Load(int4(((_2201 & 127) | (((int)(_2191 << 7)) & 130944)), ((_2202 & 127) | (((uint)(_2191) >> 3) & 130944)), 0, 0)))).x));
                } else {
                  _2217 = 0.0f;
                  _2218 = 0.0f;
                  _2219 = 0;
                  _2220 = 0;
                  _2221 = false;
                  _2222 = -1;
                  _2223 = 0;
                  _2224 = 0.0f;
                }
                if (_2221) {
                  _2226 = _2222 * 288;
                  _2229 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_2226 + 32u)))).z;
                  _2233 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_2226 + 128u)))).x;
                  _2234 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_2226 + 128u)))).y;
                  _2235 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_2226 + 128u)))).z;
                  _2241 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_2226 + 144u)))).x;
                  _2242 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_2226 + 144u)))).y;
                  _2243 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_2226 + 144u)))).z;
                  _2249 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_2226 + 160u)))).x;
                  _2250 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_2226 + 160u)))).y;
                  _2251 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_2226 + 160u)))).z;
                  _2257 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_2226 + 176u)))).x;
                  _2258 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_2226 + 176u)))).y;
                  _2259 = asint(VirtualShadowMap_ProjectionData.Load4(((int)(_2226 + 176u)))).z;
                  _2264 = -0.0f - dot(float3(_365, _366, _367), float3(_2063, _2064, _2065));
                  _2276 = mad(_2264, asfloat(_2259), mad(_367, asfloat(_2251), mad(_366, asfloat(_2243), (asfloat(_2235) * _365))));
                  _2283 = float((uint)((uint)((uint)(16384u) >> (_2223 & 31))));
                  if (((_2224 - (min((max(0.0f, dot(float2(((-0.0f - mad(_2264, asfloat(_2257), mad(_367, asfloat(_2249), mad(_366, asfloat(_2241), (asfloat(_2233) * _365))))) / _2276), ((-0.0f - mad(_2264, asfloat(_2258), mad(_367, asfloat(_2250), mad(_366, asfloat(_2242), (asfloat(_2234) * _365))))) / _2276)), float2((((0.5f - _2217) + float((uint)_2219)) / _2283), (((0.5f - _2218) + float((uint)_2220)) / _2283)))) * 2.0f), abs(asfloat(_2229) * 100.0f)) * float((uint)(1 << ((_2222 - _2138) & 31))))) - ((-0.0f - (_1994 * _2156)) / _2172)) > _2175) {
                    _2315 = sqrt(((_2063 * _2063) + (_2064 * _2064)) + (_2065 * _2065));
                    _2326 = 0.0f;
                    _2327 = (max(9.999999974752427e-07f, (_2315 - (((_2315 * (_2175 - _2156)) / _2155) * (_2155 / (_2224 - _2156))))) + _1994);
                  } else {
                    _2326 = 1.0f;
                    _2327 = -1.0f;
                  }
                } else {
                  _2326 = 1.0f;
                  _2327 = -1.0f;
                }
              }
              if ((int)(_217 < 1.0f) && (int)(_2326 < 1.0f)) {
                _2334 = saturate(exp2(_216 * _2327));
                _2337 = ((1.0f - _2334) * _2326) + _2334;
                _2340 = (_2337 * _2337);
              } else {
                _2340 = _2326;
              }
              if (!_298) {
                if (_2340 > 0.0f) {
                  _2362 = (BlueNoise.ModuloMasks.z & View.StateFrameIndexMod8) * BlueNoise.Dimensions.y;
                  if (InjectionToggle(TOGGLE_USE_ISFAST_SHADOWS)) {
                    float2 _isfast_ray0 = ISFASTNoiseLoad(uint(_69) % 128u, uint(_70) % 128u, uint(float(InjectionFrameIndex())) % 32u);
                    float2 _isfast_ray1 = ISFASTNoiseLoad((uint(_69) + 97u) % 128u, (uint(_70) + 97u * 7u) % 128u, (uint(float(InjectionFrameIndex())) + 97u) % 32u);
                    _2365 = float4(_isfast_ray0.x, _isfast_ray0.y, 0, 0);
                    _2373 = float4(_isfast_ray1.x, _isfast_ray1.y, 0, 0);
                  } else {
                    _2365 = BlueNoise_Vec2Texture.Load(int3((BlueNoise.ModuloMasks.x & _69), ((int)(_2362 + ((uint)(BlueNoise.ModuloMasks.y & _70)))), 0));
                    _2373 = BlueNoise_Vec2Texture.Load(int3((BlueNoise.ModuloMasks.x & ((int)((uint)(int(float((int)(BlueNoise.Dimensions.x)) * 0.7548776268959045f)) + _69))), ((int)(_2362 + ((uint)(BlueNoise.ModuloMasks.y & ((int)((uint)(int(float((int)(BlueNoise.Dimensions.y)) * 0.5698402523994446f)) + _70)))))), 0));
                  }
                  _2375 = _281 - _371;
                  _2376 = _282 - _372;
                  _2377 = _283 - _373;
                  _2378 = dot(float3(_2375, _2376, _2377), float3(_2375, _2376, _2377));
                  _2381 = rsqrt(_2378);
                  _2382 = _2381 * _2375;
                  _2383 = _2381 * _2376;
                  _2384 = _2381 * _2377;
                  _2385 = _2381 * _292;
                  _2392 = (dot(float3(_365, _366, _367), float3(_2382, _2383, _2384)) < (-0.0f - sqrt(saturate((_292 * _292) * (1.0f / (_2378 + 1.0f))))));
                  if (!_2392) {
                    _2405 = _69 & 65535;
                    _2408 = ((_2405 << 8) | _2405) & 16711935;
                    _2411 = ((_2408 << 4) | _2408) & 252645135;
                    _2414 = ((_2411 << 2) | _2411) & 858993459;
                    _2418 = _70 & 65535;
                    _2421 = ((_2418 << 8) | _2418) & 16711935;
                    _2424 = ((_2421 << 4) | _2421) & 252645135;
                    _2427 = ((_2424 << 2) | _2424) & 858993459;
                    _2439 = (uint)(reversebits((uint)((((int)((View.StateFrameIndex << 16) + ((uint)((((int)(((_2427 << 1) | _2427) << 1)) & -1431655766) | (((_2414 << 1) | _2414) & 1431655765))))) * SMRTRayCount) + uint(min((float((int)(SMRTRayCount)) * _2373.y), float((int)(SMRTRayCount + -1))))))) + 1216234700u;
                    _2441 = ((int)(_2439 * -1676577210)) ^ _2439;
                    _2444 = reversebits((int)(((int)(_2441 * -529506958)) ^ _2441));
                    _2482 = (_2444 & 255) + -1862497895;
                    _2484 = ((int)(_2482 * -1676577210)) ^ _2482;
                    _2488 = ((uint)(((((((((0 - (((uint)(_2444) >> 1) & 1)) & 3) ^ (_2444 & 1)) ^ ((0 - (((uint)(_2444) >> 2) & 1)) & 5)) ^ ((0 - (((uint)(_2444) >> 3) & 1)) & 15)) ^ ((0 - (((uint)(_2444) >> 4) & 1)) & 17)) ^ ((0 - (((uint)(_2444) >> 5) & 1)) & 51)) ^ ((0 - (((uint)(_2444) >> 6) & 1)) & 85)) ^ ((0 - (((uint)(_2444) >> 7) & 1)) & 255))) + (uint)(-646066581);
                    _2490 = ((int)(_2488 * -1676577210)) ^ _2488;
                    _2500 = (float((uint)((uint)((uint)((uint)(reversebits((int)(((int)(_2484 * -529506958)) ^ _2484)))) >> 8))) * 8.429369557916289e-08f) + -0.7071067690849304f;
                    _2501 = (float((uint)((uint)((uint)((uint)(reversebits((int)(((int)(_2490 * -529506958)) ^ _2490)))) >> 8))) * 8.429369557916289e-08f) + -0.7071067690849304f;
                    _2502 = _2500 * _2500;
                    _2503 = _2501 * _2501;
                    _2508 = sqrt((max(_2502, _2503) * 2.0f) - min(_2502, _2503));
                    _2509 = (_2502 > _2503);
                    _2510 = -0.0f - _2508;
                    _2517 = select(_2509, select((_2500 > 0.0f), _2508, _2510), _2500) * _2385;
                    _2518 = select(_2509, _2501, select((_2501 > 0.0f), _2508, _2510)) * _2385;
                    _2519 = dot(float2(_2517, _2518), float2(_2517, _2518));
                    _2522 = sqrt(1.0f - _2519);
                    _2524 = select((_2384 >= 0.0f), 1.0f, -1.0f);
                    _2527 = -0.0f - (1.0f / (_2524 + _2384));
                    _2529 = (_2382 * _2383) * _2527;
                    _2556 = ((_2378 * 0.75f) * _2381) * saturate(1.5f / (_2522 + (sqrt(_2519) * SMRTCotMaxRayAngleFromLight)));
                    _2564 = _371;
                    _2565 = _372;
                    _2566 = _373;
                    _2567 = ((_2556 * mad(_2522, _2382, mad(_2518, _2529, (((((_2382 * _2382) * _2524) * _2527) + 1.0f) * _2517)))) + _371);
                    _2568 = ((_2556 * mad(_2522, _2383, mad(_2518, (((_2383 * _2383) * _2527) + _2524), ((_2517 * _2524) * _2529)))) + _372);
                    _2569 = ((_2556 * mad(_2522, _2384, mad(_2518, (-0.0f - _2383), (-0.0f - ((_2382 * _2524) * _2517))))) + _373);
                  } else {
                    _2564 = 0.0f;
                    _2565 = 0.0f;
                    _2566 = 0.0f;
                    _2567 = 0.0f;
                    _2568 = 0.0f;
                    _2569 = 0.0f;
                  }
                  _2573 = _2564;
                  _2574 = _2565;
                  _2575 = _2566;
                  _2576 = _2567;
                  _2577 = _2568;
                  _2578 = _2569;
                  _2579 = (((int)(uint)(_2392)) ^ 1);
                  _2580 = _2365.x;
                  _2581 = _2365.y;
                  _2582 = _2373.x;
                } else {
                  _2573 = 0.0f;
                  _2574 = 0.0f;
                  _2575 = 0.0f;
                  _2576 = 0.0f;
                  _2577 = 0.0f;
                  _2578 = 0.0f;
                  _2579 = 0;
                  _2580 = 0.0f;
                  _2581 = 0.0f;
                  _2582 = 0.0f;
                }
                if (!(_2579 == 0)) {
                  _2590 = _2580 + -0.5f;
                  _2591 = _2581 + -0.5f;
                  _2592 = _2582 + -0.5f;
                  if (!(VirtualVoxel.NodeDescCount == 0)) {
                    _2610 = _2340;
                    _2611 = 0;
                    while(true) {
                      _2614 = VirtualVoxel_NodeDescBuffer[_2611].TranslatedWorldMinAABB.x;
                      _2615 = VirtualVoxel_NodeDescBuffer[_2611].TranslatedWorldMinAABB.y;
                      _2616 = VirtualVoxel_NodeDescBuffer[_2611].TranslatedWorldMinAABB.z;
                      _2618 = VirtualVoxel_NodeDescBuffer[_2611].PackedPageIndexResolution;
                      _2620 = VirtualVoxel_NodeDescBuffer[_2611].TranslatedWorldMaxAABB.x;
                      _2621 = VirtualVoxel_NodeDescBuffer[_2611].TranslatedWorldMaxAABB.y;
                      _2622 = VirtualVoxel_NodeDescBuffer[_2611].TranslatedWorldMaxAABB.z;
                      _2624 = VirtualVoxel_NodeDescBuffer[_2611].PageIndexOffset_VoxelWorldSize;
                      _2627 = _2618 & 255;
                      _2629 = ((uint)(_2618) >> 8) & 255;
                      _2631 = ((uint)(_2618) >> 16) & 255;
                      _2632 = VirtualVoxel.PageResolution * _2627;
                      _2633 = VirtualVoxel.PageResolution * _2629;
                      _2634 = VirtualVoxel.PageResolution * _2631;
                      _2637 = float((uint)((uint)((uint)(_2624) >> 22)));
                      _2638 = _2637 * 0.009775171056389809f;
                      _2647 = (_2638 * (_2590 + (VirtualVoxel.DepthBiasScale_Shadow * _337))) + _2573;
                      _2648 = (_2638 * (_2591 + (VirtualVoxel.DepthBiasScale_Shadow * _338))) + _2574;
                      _2649 = (_2638 * (_2592 + (VirtualVoxel.DepthBiasScale_Shadow * _339))) + _2575;
                      if ((int)(_2631 != 0) && ((int)((int)(_2627 != 0) && (int)(_2629 != 0)))) {
                        _2652 = _2576 - _2647;
                        _2653 = _2577 - _2648;
                        _2654 = _2578 - _2649;
                        _2655 = 1.0f / _2652;
                        _2656 = 1.0f / _2653;
                        _2657 = 1.0f / _2654;
                        _2661 = _2655 * (_2614 - _2647);
                        _2662 = _2656 * (_2615 - _2648);
                        _2663 = _2657 * (_2616 - _2649);
                        _2667 = _2655 * (_2620 - _2647);
                        _2668 = _2656 * (_2621 - _2648);
                        _2669 = _2657 * (_2622 - _2649);
                        _2680 = saturate(max(min(_2661, _2667), max(min(_2662, _2668), min(_2663, _2669))));
                        _2681 = saturate(min(max(_2661, _2667), min(max(_2662, _2668), max(_2663, _2669))));
                        if (_2680 < _2681) {
                          _2688 = _2652 * (_2681 - _2680);
                          _2690 = _2653 * (_2681 - _2680);
                          _2692 = _2654 * (_2681 - _2680);
                          _2699 = min(sqrt(((_2688 * _2688) + (_2690 * _2690)) + (_2692 * _2692)), 1e+05f);
                          _2701 = rsqrt(dot(float3(_2688, _2690, _2692), float3(_2688, _2690, _2692)));
                          _2704 = min(ceil(_2699 / _2638), 1024.0f);
                          if (_2704 > 0.0f) {
                            _2709 = 9999;
                            _2710 = 9999;
                            _2711 = 9999;
                            _2712 = 0;
                            _2713 = 0;
                            _2714 = 0;
                            _2715 = 0;
                            _2716 = 1.0f;
                            _2717 = 0.0f;
                            _2718 = 0.0f;
                            while(true) {
                              _2720 = max((_2716 * (_2699 / _2704)), 0.0f);
                              _2766 = (int)min((uint)((int)(uint(saturate(((((_2647 - _2614) + (_2680 * _2652)) + (((_2688 * _2638) * _2701) * _2717)) + (_2590 * _2720)) / (_2620 - _2614)) * float((uint)_2632)))), (uint)(((int)(_2632 + (uint)(-1)))));
                              _2767 = (int)min((uint)((int)(uint(saturate(((((_2648 - _2615) + (_2680 * _2653)) + (((_2690 * _2638) * _2701) * _2717)) + (_2591 * _2720)) / (_2621 - _2615)) * float((uint)_2633)))), (uint)(((int)(_2633 + (uint)(-1)))));
                              _2768 = (int)min((uint)((int)(uint(saturate(((((_2649 - _2616) + (_2680 * _2654)) + (((_2692 * _2638) * _2701) * _2717)) + (_2592 * _2720)) / (_2622 - _2616)) * float((uint)_2634)))), (uint)(((int)(_2634 + (uint)(-1)))));
                              _2769 = VirtualVoxel.PageResolutionLog2 & 31;
                              _2770 = (uint)(_2766) >> _2769;
                              _2771 = (uint)(_2767) >> _2769;
                              _2772 = (uint)(_2768) >> _2769;
                              if (((int)((int)(_2770 != _2709) || (int)(_2771 != _2710))) || (int)(_2772 != _2711)) {
                                _2789 = VirtualVoxel.PageCountResolution.x * VirtualVoxel.PageCountResolution.y;
                                _2790 = (((uint)(VirtualVoxel_PageIndexBuffer.Load((int)((_2770 + ((uint)(_2624 & 4194303))) + (((int)((_2772 * _2629) + _2771)) * _2627))))).x) % _2789;
                                _2795 = _2770;
                                _2796 = _2771;
                                _2797 = _2772;
                                _2798 = ((int)(uint)((int)((((uint)(VirtualVoxel_PageIndexBuffer.Load((int)((_2770 + ((uint)(_2624 & 4194303))) + (((int)((_2772 * _2629) + _2771)) * _2627))))).x) != -1)));
                                _2799 = ((int)(_2790 % VirtualVoxel.PageCountResolution.x));
                                _2800 = ((int)(_2790 / (uint)(VirtualVoxel.PageCountResolution.x)));
                                _2801 = ((int)(((uint)(((uint)(VirtualVoxel_PageIndexBuffer.Load((int)((_2770 + ((uint)(_2624 & 4194303))) + (((int)((_2772 * _2629) + _2771)) * _2627))))).x)) / _2789));
                              } else {
                                _2795 = _2709;
                                _2796 = _2710;
                                _2797 = _2711;
                                _2798 = _2712;
                                _2799 = _2713;
                                _2800 = _2714;
                                _2801 = _2715;
                              }
                              if (_2798 == 0) {
                                _2838 = _2718;
                              } else {
                                _2816 = _2720 * (102.30000305175781f / _2637);
                                _2818 = uint(log2(_2816));
                                _2819 = _2818 & 31;
                                if ((int)(((uint)(VirtualVoxel_PageTexture.Load(int4(((uint)((_2766 - (_2770 << _2769)) + (_2799 << _2769)) >> _2819), ((uint)((_2767 - (_2771 << _2769)) + (_2800 << _2769)) >> _2819), ((uint)((_2768 - (_2772 << _2769)) + (_2801 << _2769)) >> _2819), _2818)))).x) > (int)-1) {
                                  _2834 = (((VirtualVoxel.DensityScale_Shadow * 0.0010000000474974513f) * _2816) * float((uint)((uint)((((uint)(VirtualVoxel_PageTexture.Load(int4(((uint)((_2766 - (_2770 << _2769)) + (_2799 << _2769)) >> _2819), ((uint)((_2767 - (_2771 << _2769)) + (_2800 << _2769)) >> _2819), ((uint)((_2768 - (_2772 << _2769)) + (_2801 << _2769)) >> _2819), _2818)))).x) & 16777215))));
                                } else {
                                  _2834 = 0.0f;
                                }
                                _2835 = _2834 + _2718;
                                if (!(_2835 > 1.0f)) {
                                  _2838 = _2835;
                                } else {
                                  _2845 = _2835;
                                }
                              }
                              _2841 = min(float((uint)(uint)(VirtualVoxel.PageResolution)), (_2716 * VirtualVoxel.SteppingScale_Shadow));
                              _2842 = _2841 + _2717;
                              if (_2842 < _2704) {
                                _2709 = _2795;
                                _2710 = _2796;
                                _2711 = _2797;
                                _2712 = _2798;
                                _2713 = _2799;
                                _2714 = _2800;
                                _2715 = _2801;
                                _2716 = _2841;
                                _2717 = _2842;
                                _2718 = _2838;
                                continue;
                              } else {
                                _2845 = _2838;
                              }
                              _2847 = _2845;
                              break;
                            }
                          } else {
                            _2847 = 0.0f;
                          }
                        } else {
                          _2847 = 0.0f;
                        }
                      } else {
                        _2847 = 0.0f;
                      }
                      _2850 = min(_2610, saturate(1.0f - _2847));
                      _2851 = _2611 + 1u;
                      if (!(_2851 == VirtualVoxel.NodeDescCount)) {
                        _2610 = _2850;
                        _2611 = _2851;
                        continue;
                      }
                      _2855 = _2850;
                      break;
                    }
                  } else {
                    _2855 = _2340;
                  }
                } else {
                  _2855 = _2340;
                }
              } else {
                _2855 = _2340;
              }
            } else {
              _2855 = 1.0f;
            }
            if ((int)(_2855 > 0.01666666753590107f) && (int)(_2855 < 1.0f)) {
              if (InjectionToggle(TOGGLE_USE_ISFAST_SHADOWS)) {
                float _isfast_scalar = ISFASTNoiseLoad(uint(_69) % 128u, uint(_70) % 128u, uint(float(InjectionFrameIndex())) % 32u).x;
                _2881 = saturate(((_isfast_scalar + -0.5f) * 0.06666667014360428f) + _2855);
              } else {
                _2881 = saturate((((((float4)(BlueNoise_ScalarTexture.Load(int3((BlueNoise.ModuloMasks.x & _69), ((int)(((BlueNoise.ModuloMasks.z & View.StateFrameIndex) * BlueNoise.Dimensions.y) + ((uint)(BlueNoise.ModuloMasks.y & _70)))), 0)))).x) + -0.5f) * 0.06666667014360428f) + _2855);
              }
            } else {
              _2881 = _2855;
            }
            _2885 = (int)(uint(round(_2881 * 15.0f))) & 15;
            _2886 = (uint)(_261) >> 3;
            if (_2886 == 0) {
              _2893 = ((int)(_2885 << (((int)(_261 << 2)) & 28)));
            } else {
              _2893 = 0;
            }
            if (_2886 == 1) {
              _2901 = ((int)(_2885 << (((int)(_261 << 2)) & 28)));
            } else {
              _2901 = 0;
            }
            if (_2886 == 2) {
              _2909 = ((int)(_2885 << (((int)(_261 << 2)) & 28)));
            } else {
              _2909 = 0;
            }
            if (_2886 == 3) {
              _2917 = ((int)(_2885 << (((int)(_261 << 2)) & 28)));
            } else {
              _2917 = 0;
            }
            _2920 = (_2893 ^ _257);
            _2921 = (_2901 ^ _258);
            _2922 = (_2909 ^ _259);
            _2923 = (_2917 ^ _260);
          } else {
            _2920 = _257;
            _2921 = _258;
            _2922 = _259;
            _2923 = _260;
          }
          _2924 = _261 + 1u;
          if (!(_2924 == _253)) {
            _257 = _2920;
            _258 = _2921;
            _259 = _2922;
            _260 = _2923;
            _261 = _2924;
            continue;
          }
          _2928 = _2920;
          _2929 = _2921;
          _2930 = _2922;
          _2931 = _2923;
          break;
        }
      } else {
        _2928 = 0;
        _2929 = 0;
        _2930 = 0;
        _2931 = 0;
      }
      if ((InjectionEnum(ENUM_DEBUG_SHADOWS_SHIFT) > 0u)) {
        float2 _dbg_noise = ISFASTNoiseLoad(uint(_69) % 128u, uint(_70) % 128u, uint(float(InjectionFrameIndex())) % 32u);
        float _dbg_diff = saturate(abs(_dbg_noise.x - (((float4)(BlueNoise_ScalarTexture.Load(int3((BlueNoise.ModuloMasks.x & _69), ((int)(((BlueNoise.ModuloMasks.z & View.StateFrameIndex) * BlueNoise.Dimensions.y) + ((uint)(BlueNoise.ModuloMasks.y & _70)))), 0)))).x)) * 50.0f);
        uint _dbg_val = (uint(round((1.0f - _dbg_diff) * 15.0f))) & 15;
        int _dbg_packed = (int)(_dbg_val | (_dbg_val << 4) | (_dbg_val << 8) | (_dbg_val << 12) | (_dbg_val << 16) | (_dbg_val << 20) | (_dbg_val << 24) | (_dbg_val << 28));
        OutShadowMaskBits[int2(_69, _70)] = int4(_dbg_packed, _dbg_packed, _dbg_packed, _dbg_packed);
      } else {
        OutShadowMaskBits[int2(_69, _70)] = int4(_2928, _2929, _2930, _2931);
      }
    }
  }
}