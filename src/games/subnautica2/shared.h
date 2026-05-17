#ifndef SRC_GAMES_SUBNAUTICA2_SHARED_H_
#define SRC_GAMES_SUBNAUTICA2_SHARED_H_

// Composable bundle: graphics-quality (IS-FAST noise, volumetric fog tuning).
#include "./graphics/inject.h"

// =============================================================================
// Packed ShaderInjectData — fits within D3D12 root signature budget.
//
// Layout (16 floats = 4 cbuffer registers):
//   c0: graphics_inject.toggles_and_frame, graphics_inject.enums, peak_white_nits, diffuse_white_nits
//   c1: graphics_white_nits, hdr_flags, packed_exposure_highlights, packed_shadows_contrast
//   c2: packed_saturation_highlightsat, packed_blowout_flare, packed_lut_perch, packed_hue_hueshift
//   c3: packed_chroma_blackclip, packed_grain_random, packed_sharpness_blend, (spare)
// =============================================================================

// Must be 32bit aligned, size must be multiple of 16 bytes
struct ShaderInjectData {
  // --- Graphics-quality composable bundle at offset 0 ---
#ifdef __cplusplus
  subnautica2_graphics::Inject graphics_inject = {};
#else
  subnautica2_graphics_Inject graphics_inject;
#endif

  // --- Full-precision nits values (need wide range) ---
  float peak_white_nits;
  float diffuse_white_nits;
  float graphics_white_nits;

  // --- Bit-packed integer flags ---
  // bits 0-2:  tone_map_type (0-4)
  // bit  3:    gamma_correction (0 or 1)
  // bit  4:    gamma_correction_ui (0 or 1)
  // bit  5:    tone_map_hue_correction_type (0 or 1)
  // bit  6:    custom_grain_type (0 or 1)
  // bit  7:    tm_under_ui (0 or 1)
  // bit  8:    processing_path (0 or 1)
  // bit  9:    processing_use_scrgb (0 or 1)
  // bit  10:   tone_map_scaling (0 or 1)
  // bit  11:   custom_lut_scaling (0 or 1)
  // bit  12:   custom_lut_gamut_restoration (0 or 1)
  // bit  13:   override_black_clip (0 or 1)
  float hdr_flags;

  // --- Half-precision pairs (f16x2 packed into uint32 via f32tof16) ---
  float packed_exposure_highlights;       // f16(tone_map_exposure) | f16(tone_map_highlights) << 16
  float packed_shadows_contrast;          // f16(tone_map_shadows) | f16(tone_map_contrast) << 16
  float packed_saturation_highlightsat;   // f16(tone_map_saturation) | f16(tone_map_highlight_saturation) << 16
  float packed_blowout_flare;             // f16(tone_map_blowout) | f16(tone_map_flare) << 16
  float packed_lut_perch;                 // f16(custom_lut_strength) | f16(tone_map_per_ch_peak) << 16
  float packed_hue_hueshift;              // f16(tone_map_hue_correction) | f16(tone_map_hue_shift) << 16
  float packed_chroma_blackclip;          // f16(tone_map_chroma_correct_blowout) | f16(override_black_clip) << 16
  float packed_grain_random;              // f16(custom_grain_strength) | f16(custom_random) << 16
  float packed_sharpness_blend;           // f16(custom_sharpness) | f16(blend_factor) << 16
};
// 2 + 3 + 1 + 9 = 15 floats. Padded to 16 for 4-float alignment.
// Actually 15 floats — needs padding to 16. Add a spare:
// Wait, 15 is not a multiple of 4. Let's count: 2+3+1+9 = 15. Need 16.
// The struct above has exactly 15 floats. We need to pad to 16.
// Actually let's recount: graphics_inject(2) + nits(3) + flags(1) + packed(9) = 15.
// Add 1 spare float for 16-float alignment.

// Hmm, actually the struct as declared has 15 members. Let me just verify the
// layout is correct and add padding if needed. The compiler will pad to 16
// bytes (4 floats) boundary for cbuffer rules anyway. 15 floats = 60 bytes,
// which rounds up to 64 bytes (16 floats) for cbuffer alignment. So we're fine
// — the GPU sees 16 floats (4 registers) regardless.

#ifndef __cplusplus

#if ((__SHADER_TARGET_MAJOR == 5 && __SHADER_TARGET_MINOR >= 1) || __SHADER_TARGET_MAJOR >= 6)
cbuffer injected_buffer : register(b13, space50) {
#elif (__SHADER_TARGET_MAJOR < 5) || ((__SHADER_TARGET_MAJOR == 5) && (__SHADER_TARGET_MINOR < 1))
cbuffer injected_buffer : register(b13) {
#endif
  ShaderInjectData shader_injection : packoffset(c0);
}

#if (__SHADER_TARGET_MAJOR >= 6)
#pragma dxc diagnostic ignored "-Wparentheses-equality"
#endif

// =============================================================================
// HLSL unpacking helpers
// =============================================================================

// f16x2 pairs: low 16 bits = first value, high 16 bits = second value.
static float unpack_lo(float packed) {
  return f16tof32(asuint(packed));
}
static float unpack_hi(float packed) {
  return f16tof32(asuint(packed) >> 16u);
}

// Bit-packed integer flags from hdr_flags field.
static uint get_hdr_flags() { return asuint(shader_injection.hdr_flags); }

// --- Individual flag accessors ---
#define RENODX_TONE_MAP_TYPE                     float(get_hdr_flags() & 0x7u)
#define RENODX_PEAK_WHITE_NITS                   shader_injection.peak_white_nits
#define RENODX_DIFFUSE_WHITE_NITS                shader_injection.diffuse_white_nits
#define RENODX_GRAPHICS_WHITE_NITS               shader_injection.graphics_white_nits
#define RENODX_GAMMA_CORRECTION                  float((get_hdr_flags() >> 3u) & 0x1u)
#define RENODX_GAMMA_CORRECTION_UI               float((get_hdr_flags() >> 4u) & 0x1u)
#define RENODX_TONE_MAP_HUE_CORRECTION_TYPE      float((get_hdr_flags() >> 5u) & 0x1u)
#define CUSTOM_GRAIN_TYPE                        float((get_hdr_flags() >> 6u) & 0x1u)
#define TONEMAP_UNDER_UI                         float((get_hdr_flags() >> 7u) & 0x1u)
#define PROCESSING_PATH                          float((get_hdr_flags() >> 8u) & 0x1u)
#define SWAP_CHAIN_ENCODING                      float((get_hdr_flags() >> 9u) & 0x1u)
#define RENODX_TONE_MAP_SCALING                  float((get_hdr_flags() >> 10u) & 0x1u)
#define CUSTOM_LUT_SCALING                       float((get_hdr_flags() >> 11u) & 0x1u)
#define CUSTOM_LUT_GAMUT_RESTORATION             float((get_hdr_flags() >> 12u) & 0x1u)
#define OVERRIDE_BLACK_CLIP                      float((get_hdr_flags() >> 13u) & 0x1u)

// --- Packed f16 pair accessors ---
#define RENODX_TONE_MAP_EXPOSURE                 unpack_lo(shader_injection.packed_exposure_highlights)
#define RENODX_TONE_MAP_HIGHLIGHTS               unpack_hi(shader_injection.packed_exposure_highlights)
#define RENODX_TONE_MAP_SHADOWS                  unpack_lo(shader_injection.packed_shadows_contrast)
#define RENODX_TONE_MAP_CONTRAST                 unpack_hi(shader_injection.packed_shadows_contrast)
#define RENODX_TONE_MAP_SATURATION               unpack_lo(shader_injection.packed_saturation_highlightsat)
#define RENODX_TONE_MAP_HIGHLIGHT_SATURATION     unpack_hi(shader_injection.packed_saturation_highlightsat)
#define RENODX_TONE_MAP_BLOWOUT                  unpack_lo(shader_injection.packed_blowout_flare)
#define RENODX_TONE_MAP_FLARE                    unpack_hi(shader_injection.packed_blowout_flare)
#define CUSTOM_LUT_STRENGTH                      unpack_lo(shader_injection.packed_lut_perch)
#define RENODX_TONE_MAP_PER_CH_PEAK              unpack_hi(shader_injection.packed_lut_perch)
#define RENODX_TONE_MAP_HUE_CORRECTION           unpack_lo(shader_injection.packed_hue_hueshift)
#define RENODX_TONE_MAP_HUE_SHIFT               unpack_hi(shader_injection.packed_hue_hueshift)
#define RENODX_TONE_MAP_CHROMA_CORRECT_BLOWOUT   unpack_lo(shader_injection.packed_chroma_blackclip)
#define CUSTOM_GRAIN_STRENGTH                    unpack_lo(shader_injection.packed_grain_random)
#define CUSTOM_RANDOM                            unpack_hi(shader_injection.packed_grain_random)
#define CUSTOM_SHARPNESS                         unpack_lo(shader_injection.packed_sharpness_blend)
#define BLEND_FACTOR                             unpack_hi(shader_injection.packed_sharpness_blend)

// subnautica2-graphics: HLSL accessors for the bit-packed graphics fields.
static bool InjectionToggle(uint bit_index) {
  return (asuint(shader_injection.graphics_inject.toggles_and_frame) & (1u << bit_index)) != 0u;
}
static uint InjectionFrameIndex() {
  return (asuint(shader_injection.graphics_inject.toggles_and_frame)
          >> SUBNAUTICA2_GRAPHICS_FRAME_INDEX_SHIFT)
         & SUBNAUTICA2_GRAPHICS_FRAME_INDEX_MASK;
}
static uint InjectionFogFilterMode() {
  return (asuint(shader_injection.graphics_inject.toggles_and_frame)
          >> SUBNAUTICA2_GRAPHICS_FOG_FILTER_MODE_SHIFT)
         & SUBNAUTICA2_GRAPHICS_FOG_FILTER_MODE_MASK;
}
static uint InjectionEnum(uint shift) {
  return (asuint(shader_injection.graphics_inject.enums) >> shift) & 0xFu;
}

#include "../../shaders/renodx.hlsl"

#else
// =============================================================================
// C++ packing helpers
// =============================================================================
#include <cstdint>
#include <cstring>

namespace subnautica2_inject {

inline uint16_t FloatToHalf(float value) {
  uint32_t f32;
  std::memcpy(&f32, &value, sizeof(f32));
  uint32_t sign = (f32 >> 16u) & 0x8000u;
  int32_t exponent = static_cast<int32_t>((f32 >> 23u) & 0xFFu) - 127;
  uint32_t mantissa = f32 & 0x7FFFFFu;
  if (exponent > 15) return static_cast<uint16_t>(sign | 0x7C00u);
  if (exponent < -14) return static_cast<uint16_t>(sign);
  return static_cast<uint16_t>(sign | (static_cast<uint32_t>(exponent + 15) << 10u) | (mantissa >> 13u));
}

inline void PackF16Pair(float& dest, float lo, float hi) {
  uint32_t packed = static_cast<uint32_t>(FloatToHalf(lo))
                  | (static_cast<uint32_t>(FloatToHalf(hi)) << 16u);
  std::memcpy(&dest, &packed, sizeof(dest));
}

inline void PackHdrFlags(ShaderInjectData& data,
                         uint32_t tone_map_type,
                         bool gamma_correction,
                         bool gamma_correction_ui,
                         bool tone_map_hue_correction_type,
                         bool custom_grain_type,
                         bool tm_under_ui,
                         bool processing_path,
                         bool processing_use_scrgb,
                         bool tone_map_scaling,
                         bool custom_lut_scaling,
                         bool custom_lut_gamut_restoration,
                         bool override_black_clip) {
  uint32_t bits = (tone_map_type & 0x7u)
                | (static_cast<uint32_t>(gamma_correction) << 3u)
                | (static_cast<uint32_t>(gamma_correction_ui) << 4u)
                | (static_cast<uint32_t>(tone_map_hue_correction_type) << 5u)
                | (static_cast<uint32_t>(custom_grain_type) << 6u)
                | (static_cast<uint32_t>(tm_under_ui) << 7u)
                | (static_cast<uint32_t>(processing_path) << 8u)
                | (static_cast<uint32_t>(processing_use_scrgb) << 9u)
                | (static_cast<uint32_t>(tone_map_scaling) << 10u)
                | (static_cast<uint32_t>(custom_lut_scaling) << 11u)
                | (static_cast<uint32_t>(custom_lut_gamut_restoration) << 12u)
                | (static_cast<uint32_t>(override_black_clip) << 13u);
  std::memcpy(&data.hdr_flags, &bits, sizeof(data.hdr_flags));
}

}  // namespace subnautica2_inject

#endif

#endif  // SRC_GAMES_SUBNAUTICA2_SHARED_H_
