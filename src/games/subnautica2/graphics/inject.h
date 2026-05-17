#ifndef SRC_SUBNAUTICA2_GRAPHICS_INJECT_H_
#define SRC_SUBNAUTICA2_GRAPHICS_INJECT_H_

// subnautica2-graphics — the cbuffer payload for the graphics-quality
// bundle. Hosts embed a single `Inject` field of this type into their
// `ShaderInjectData` struct. Bit layout:
//
// `toggles_and_frame`:
//   bits  0-7 : boolean toggles (TOGGLE_* below)
//   bits  8-12: frame_index (0-31)
//   bits 13-14: fog_filter_mode (0-3)
//
// `enums`:
//   bits  0-3 : debug_noise (0-1)
//   bits  4-7 : debug_fog (0-2)

#define SUBNAUTICA2_GRAPHICS_TOGGLE_USE_ISFAST_NOISE        0u
#define SUBNAUTICA2_GRAPHICS_TOGGLE_USE_ISFAST_FOG          1u
#define SUBNAUTICA2_GRAPHICS_TOGGLE_JITTERED_UPSCALE        2u
#define SUBNAUTICA2_GRAPHICS_TOGGLE_USE_ISFAST_REFLECTIONS  3u
#define SUBNAUTICA2_GRAPHICS_TOGGLE_USE_REFLECTION_LEAN     4u

#define SUBNAUTICA2_GRAPHICS_FRAME_INDEX_SHIFT              8u
#define SUBNAUTICA2_GRAPHICS_FRAME_INDEX_MASK               0x1Fu
#define SUBNAUTICA2_GRAPHICS_FOG_FILTER_MODE_SHIFT          13u
#define SUBNAUTICA2_GRAPHICS_FOG_FILTER_MODE_MASK           0x3u

#define SUBNAUTICA2_GRAPHICS_ENUM_DEBUG_NOISE_SHIFT         0u
#define SUBNAUTICA2_GRAPHICS_ENUM_DEBUG_FOG_SHIFT           4u

// Shader-side compatibility aliases (shorter names for HLSL readability)
#define TOGGLE_USE_ISFAST_NOISE       SUBNAUTICA2_GRAPHICS_TOGGLE_USE_ISFAST_NOISE
#define TOGGLE_USE_ISFAST_FOG         SUBNAUTICA2_GRAPHICS_TOGGLE_USE_ISFAST_FOG
#define TOGGLE_JITTERED_UPSCALE       SUBNAUTICA2_GRAPHICS_TOGGLE_JITTERED_UPSCALE
#define TOGGLE_USE_ISFAST_REFLECTIONS SUBNAUTICA2_GRAPHICS_TOGGLE_USE_ISFAST_REFLECTIONS
#define TOGGLE_USE_REFLECTION_LEAN    SUBNAUTICA2_GRAPHICS_TOGGLE_USE_REFLECTION_LEAN
#define ENUM_DEBUG_NOISE_SHIFT        SUBNAUTICA2_GRAPHICS_ENUM_DEBUG_NOISE_SHIFT
#define ENUM_DEBUG_FOG_SHIFT          SUBNAUTICA2_GRAPHICS_ENUM_DEBUG_FOG_SHIFT

#ifdef __cplusplus
namespace subnautica2_graphics {

struct Inject {
  float toggles_and_frame = 0.f;
  float enums = 0.f;
};

}  // namespace subnautica2_graphics

#else
// HLSL — struct for embedding in the host's cbuffer.
struct subnautica2_graphics_Inject {
  float toggles_and_frame;
  float enums;
};
#endif  // __cplusplus

#endif  // SRC_SUBNAUTICA2_GRAPHICS_INJECT_H_
