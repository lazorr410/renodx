#ifndef SRC_EXPEDITION33_SHARED_H_
#define SRC_EXPEDITION33_SHARED_H_

// Composable bundle: graphics-quality (IS-FAST noise, A-trous reflections,
// DoF/fog/shadow tuning). Adds a single nested field to ShaderInjectData.
#include "./graphics/inject.h"

// #define RENODX_PEAK_WHITE_NITS                 1000.f
// #define RENODX_DIFFUSE_WHITE_NITS              renodx::color::bt2408::REFERENCE_WHITE
// #define RENODX_GRAPHICS_WHITE_NITS             renodx::color::bt2408::GRAPHICS_WHITE
// #define RENODX_COLOR_GRADE_STRENGTH            1.f
// #define RENODX_TONE_MAP_TYPE                   TONE_MAP_TYPE_RENO_DRT
// #define RENODX_TONE_MAP_EXPOSURE               1.f
// #define RENODX_TONE_MAP_HIGHLIGHTS             1.f
// #define RENODX_TONE_MAP_SHADOWS                1.f
// #define RENODX_TONE_MAP_CONTRAST               1.f
// #define RENODX_TONE_MAP_SATURATION             1.f
// #define RENODX_TONE_MAP_HIGHLIGHT_SATURATION   1.f
// #define RENODX_TONE_MAP_BLOWOUT                0
// #define RENODX_TONE_MAP_FLARE                  0
// #define RENODX_TONE_MAP_HUE_CORRECTION         1.f
// #define RENODX_TONE_MAP_HUE_SHIFT              0
// #define RENODX_TONE_MAP_WORKING_COLOR_SPACE    color::convert::COLOR_SPACE_BT709
// #define RENODX_TONE_MAP_CLAMP_COLOR_SPACE      color::convert::COLOR_SPACE_NONE
// #define RENODX_TONE_MAP_CLAMP_PEAK             color::convert::COLOR_SPACE_BT709
// #define RENODX_TONE_MAP_HUE_PROCESSOR          HUE_PROCESSOR_OKLAB
// #define RENODX_TONE_MAP_PER_CHANNEL            0
// #define RENODX_GAMMA_CORRECTION                GAMMA_CORRECTION_GAMMA_2_2
// #define RENODX_INTERMEDIATE_SCALING            (RENODX_DIFFUSE_WHITE_NITS / RENODX_GRAPHICS_WHITE_NITS)
// #define RENODX_INTERMEDIATE_ENCODING           (RENODX_GAMMA_CORRECTION + 1.f)
// #define RENODX_INTERMEDIATE_COLOR_SPACE        color::convert::COLOR_SPACE_BT709
// #define RENODX_SWAP_CHAIN_DECODING             RENODX_INTERMEDIATE_ENCODING
// #define RENODX_SWAP_CHAIN_DECODING_COLOR_SPACE RENODX_INTERMEDIATE_COLOR_SPACE
// #define RENODX_SWAP_CHAIN_CUSTOM_COLOR_SPACE   COLOR_SPACE_CUSTOM_BT709D65
// #define RENODX_SWAP_CHAIN_SCALING_NITS         RENODX_GRAPHICS_WHITE_NITS
// #define RENODX_SWAP_CHAIN_CLAMP_NITS           RENODX_PEAK_WHITE_NITS
// #define RENODX_SWAP_CHAIN_CLAMP_COLOR_SPACE    color::convert::COLOR_SPACE_UNKNOWN
// #define RENODX_SWAP_CHAIN_ENCODING             ENCODING_SCRGB
// #define RENODX_SWAP_CHAIN_ENCODING_COLOR_SPACE color::convert::COLOR_SPACE_BT709

// Must be 32bit aligned
// Should be 4x32
struct ShaderInjectData {
  // expedition33-graphics composable bundle at offset 0 so graphics-only
  // shaders can declare a minimal 2-float cbuffer covering just these fields.
#ifdef __cplusplus
  expedition33_graphics::Inject graphics_inject = {};
#else
  expedition33_graphics_Inject graphics_inject;
#endif
  // --- Full-precision nits values (need wide range) ---
  float peak_white_nits;
  float diffuse_white_nits;
  float graphics_white_nits;
  // --- Bit-packed integer flags ---
  // bits 0-2: tone_map_type (0-4)
  // bit  3:   tone_map_per_channel (0 or 1)
  // bit  4:   custom_enable_post_filmgrain (0 or 1)
  // bit  5:   custom_is_engine_hdr (0 or 1)
  float hdr_flags;
  // --- Half-precision pairs (f16x2 packed into uint32 via f32tof16) ---
  float packed_exposure_highlights;          // f16(tone_map_exposure) | f16(tone_map_highlights) << 16
  float packed_shadows_contrast;             // f16(tone_map_shadows) | f16(tone_map_contrast) << 16
  float packed_saturation_highlight_sat;     // f16(tone_map_saturation) | f16(tone_map_highlight_saturation) << 16
  float packed_blowout_flare;                // f16(tone_map_blowout) | f16(tone_map_flare) << 16
  float packed_scene_grade_sat_hue;          // f16(scene_grade_saturation_correction) | f16(scene_grade_hue_correction) << 16
  float packed_grain_strength_random;        // f16(custom_grain_strength) | f16(custom_random) << 16
  float packed_sharpness_spare;              // f16(custom_sharpness) | f16(0) << 16
};

// --- expedition33-graphics bit layout (members of `graphics_inject`, at offset 0) ---
//
// graphics_inject.toggles_and_frame: see graphics/inject.h
// graphics_inject.enums:             see graphics/inject.h

#ifndef __cplusplus
#if ((__SHADER_TARGET_MAJOR == 5 && __SHADER_TARGET_MINOR >= 1) || __SHADER_TARGET_MAJOR >= 6)
cbuffer shader_injection : register(b13, space50) {
#elif (__SHADER_TARGET_MAJOR < 5) || ((__SHADER_TARGET_MAJOR == 5) && (__SHADER_TARGET_MINOR < 1))
cbuffer shader_injection : register(b13) {
#endif
  ShaderInjectData shader_injection : packoffset(c0);
}

// --- HDR settings unpacking helpers ---
// f16x2 pairs: low 16 bits = first value, high 16 bits = second value.
static float shader_injection_unpack_lo(float packed) {
  return f16tof32(asuint(packed));
}
static float shader_injection_unpack_hi(float packed) {
  return f16tof32(asuint(packed) >> 16u);
}
// Bit-packed integer flags from hdr_flags field.
static float shader_injection_tone_map_type() {
  return float(asuint(shader_injection.hdr_flags) & 0x7u);
}
static float shader_injection_tone_map_per_channel() {
  return float((asuint(shader_injection.hdr_flags) >> 3u) & 0x1u);
}
static float shader_injection_custom_enable_post_filmgrain() {
  return float((asuint(shader_injection.hdr_flags) >> 4u) & 0x1u);
}
static float shader_injection_custom_is_engine_hdr() {
  return float((asuint(shader_injection.hdr_flags) >> 5u) & 0x1u);
}

#define RENODX_TONE_MAP_TYPE                     shader_injection_tone_map_type()
#define RENODX_PEAK_WHITE_NITS                   shader_injection.peak_white_nits
#define RENODX_DIFFUSE_WHITE_NITS                shader_injection.diffuse_white_nits
#define RENODX_GRAPHICS_WHITE_NITS               shader_injection.graphics_white_nits
#define RENODX_TONE_MAP_PER_CHANNEL              shader_injection_tone_map_per_channel()
#define RENODX_TONE_MAP_EXPOSURE                 shader_injection_unpack_lo(shader_injection.packed_exposure_highlights)
#define RENODX_TONE_MAP_HIGHLIGHTS               shader_injection_unpack_hi(shader_injection.packed_exposure_highlights)
#define RENODX_TONE_MAP_SHADOWS                  shader_injection_unpack_lo(shader_injection.packed_shadows_contrast)
#define RENODX_TONE_MAP_CONTRAST                 shader_injection_unpack_hi(shader_injection.packed_shadows_contrast)
#define RENODX_TONE_MAP_SATURATION               shader_injection_unpack_lo(shader_injection.packed_saturation_highlight_sat)
#define RENODX_TONE_MAP_HIGHLIGHT_SATURATION     shader_injection_unpack_hi(shader_injection.packed_saturation_highlight_sat)
#define RENODX_TONE_MAP_BLOWOUT                  shader_injection_unpack_lo(shader_injection.packed_blowout_flare)
#define RENODX_TONE_MAP_FLARE                    shader_injection_unpack_hi(shader_injection.packed_blowout_flare)
#define RENODX_RENO_DRT_TONE_MAP_METHOD          renodx::tonemap::renodrt::config::tone_map_method::REINHARD
#define RENODX_SWAP_CHAIN_ENCODING_COLOR_SPACE   color::convert::COLOR_SPACE_BT2020
#define RENODX_SWAP_CHAIN_ENCODING               renodx::draw::ENCODING_PQ
#define RENODX_TONE_MAP_HUE_SHIFT                0.f
#define RENODX_TONE_MAP_PASS_AUTOCORRECTION      1.f
#define CUSTOM_COLOR_GRADE_BLOWOUT_RESTORATION   0.75f
#define CUSTOM_COLOR_GRADE_HUE_CORRECTION        shader_injection_unpack_hi(shader_injection.packed_scene_grade_sat_hue)
#define CUSTOM_COLOR_GRADE_SATURATION_CORRECTION shader_injection_unpack_lo(shader_injection.packed_scene_grade_sat_hue)
#define CUSTOM_COLOR_GRADE_HUE_SHIFT             0.f
#define CUSTOM_GRAIN_TYPE                        0.f
#define CUSTOM_GRAIN_STRENGTH                    shader_injection_unpack_lo(shader_injection.packed_grain_strength_random)
#define CUSTOM_RANDOM                            shader_injection_unpack_hi(shader_injection.packed_grain_strength_random)
#define CUSTOM_ENABLE_POST_FILMGRAIN             shader_injection_custom_enable_post_filmgrain()
#define CUSTOM_DICE_PEAK                         2.f
#define CUSTOM_DICE_SHOULDER                     0.5f
#define CUSTOM_SHARPNESS                         shader_injection_unpack_lo(shader_injection.packed_sharpness_spare)
#define CUSTOM_UNREAL_HDR                        shader_injection_custom_is_engine_hdr()
#define RENODX_GAMMA_CORRECTION_UI               1.f
#define RENODX_GAMMA_CORRECTION                  1.f
#define CUSTOM_LUT_STRENGTH                      1.f
#define CUSTOM_LUT_SCALING                       0.f
#define CUSTOM_IS_ENGINE_HDR                     shader_injection_custom_is_engine_hdr()
#define OVERRIDE_BLACK_CLIP                      1.f  // 0 - Off, 1 - 0 nits
#define RENODX_TONE_MAP_HUE_CORRECTION_TYPE      1.f  // 0 - Highlights, Midtones, & Shadows; 1 - Midtones, & Shadows

// expedition33-graphics: HLSL accessors for the bit-packed graphics fields.
static bool InjectionToggle(uint bit_index) {
  return (asuint(shader_injection.graphics_inject.toggles_and_frame) & (1u << bit_index)) != 0u;
}
static uint InjectionFrameIndex() {
  return (asuint(shader_injection.graphics_inject.toggles_and_frame)
          >> EXPEDITION33_GRAPHICS_FRAME_INDEX_SHIFT)
         & EXPEDITION33_GRAPHICS_FRAME_INDEX_MASK;
}
static uint InjectionFogFilterMode() {
  return (asuint(shader_injection.graphics_inject.toggles_and_frame)
          >> EXPEDITION33_GRAPHICS_FOG_FILTER_MODE_SHIFT)
         & EXPEDITION33_GRAPHICS_FOG_FILTER_MODE_MASK;
}
static uint InjectionEnum(uint shift) {
  return (asuint(shader_injection.graphics_inject.enums) >> shift) & 0xFu;
}

#include "../../shaders/renodx.hlsl"

#else
// expedition33-graphics: C++ helpers for packing host-side settings into the
// bit-packed `graphics_inject.toggles_and_frame` / `graphics_inject.enums`
// fields.
#include <cstdint>
#include <cstring>

namespace expedition33_inject {

inline uint32_t GetBits(const float& f) {
  uint32_t bits;
  std::memcpy(&bits, &f, sizeof(bits));
  return bits;
}

inline void SetBits(float& f, uint32_t bits) {
  std::memcpy(&f, &bits, sizeof(bits));
}

inline void SetToggle(ShaderInjectData& data, uint32_t bit, bool value) {
  uint32_t bits = GetBits(data.graphics_inject.toggles_and_frame);
  if (value) bits |= (1u << bit);
  else       bits &= ~(1u << bit);
  SetBits(data.graphics_inject.toggles_and_frame, bits);
}

inline void SetFrameIndex(ShaderInjectData& data, uint32_t frame) {
  uint32_t bits = GetBits(data.graphics_inject.toggles_and_frame);
  bits &= ~(EXPEDITION33_GRAPHICS_FRAME_INDEX_MASK << EXPEDITION33_GRAPHICS_FRAME_INDEX_SHIFT);
  bits |= ((frame & EXPEDITION33_GRAPHICS_FRAME_INDEX_MASK) << EXPEDITION33_GRAPHICS_FRAME_INDEX_SHIFT);
  SetBits(data.graphics_inject.toggles_and_frame, bits);
}

inline void SetFogFilterMode(ShaderInjectData& data, uint32_t mode) {
  uint32_t bits = GetBits(data.graphics_inject.toggles_and_frame);
  bits &= ~(EXPEDITION33_GRAPHICS_FOG_FILTER_MODE_MASK << EXPEDITION33_GRAPHICS_FOG_FILTER_MODE_SHIFT);
  bits |= ((mode & EXPEDITION33_GRAPHICS_FOG_FILTER_MODE_MASK) << EXPEDITION33_GRAPHICS_FOG_FILTER_MODE_SHIFT);
  SetBits(data.graphics_inject.toggles_and_frame, bits);
}

inline void SetEnum(ShaderInjectData& data, uint32_t shift, uint32_t value) {
  uint32_t bits = GetBits(data.graphics_inject.enums);
  bits &= ~(0xFu << shift);
  bits |= ((value & 0xFu) << shift);
  SetBits(data.graphics_inject.enums, bits);
}

// --- HDR settings packing helpers ---
// Converts a float to IEEE 754 half-precision (16-bit) using DirectXMath-
// compatible bit manipulation. Matches HLSL f32tof16 semantics.
inline uint16_t FloatToHalf(float value) {
  uint32_t f32;
  std::memcpy(&f32, &value, sizeof(f32));
  uint32_t sign = (f32 >> 16u) & 0x8000u;
  int32_t exponent = static_cast<int32_t>((f32 >> 23u) & 0xFFu) - 127;
  uint32_t mantissa = f32 & 0x7FFFFFu;
  if (exponent > 15) {
    // Overflow → infinity
    return static_cast<uint16_t>(sign | 0x7C00u);
  }
  if (exponent < -14) {
    // Underflow → zero (subnormals negligible for our [0,2] range)
    return static_cast<uint16_t>(sign);
  }
  return static_cast<uint16_t>(sign | (static_cast<uint32_t>(exponent + 15) << 10u) | (mantissa >> 13u));
}

// Packs two floats into a single uint32 as f16x2 (lo = first, hi = second).
inline void PackF16Pair(float& dest, float lo, float hi) {
  uint32_t packed = static_cast<uint32_t>(FloatToHalf(lo))
                  | (static_cast<uint32_t>(FloatToHalf(hi)) << 16u);
  std::memcpy(&dest, &packed, sizeof(dest));
}

// Packs integer flags into hdr_flags field.
inline void PackHdrFlags(ShaderInjectData& data, uint32_t tone_map_type,
                         bool per_channel, bool post_filmgrain, bool is_engine_hdr) {
  uint32_t bits = (tone_map_type & 0x7u)
                | (static_cast<uint32_t>(per_channel) << 3u)
                | (static_cast<uint32_t>(post_filmgrain) << 4u)
                | (static_cast<uint32_t>(is_engine_hdr) << 5u);
  std::memcpy(&data.hdr_flags, &bits, sizeof(data.hdr_flags));
}

}  // namespace expedition33_inject

#endif

#endif  // SRC_EXPEDITION33_SHARED_H_
