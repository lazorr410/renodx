#ifndef SRC_CLAIROBSCUR_EXPEDITION33_GRAPHICS_INJECT_H_
#define SRC_CLAIROBSCUR_EXPEDITION33_GRAPHICS_INJECT_H_

// expedition33-graphics — the cbuffer payload for the graphics-quality
// bundle. Hosts embed a single `Inject` field of this type into their
// `ShaderInjectData` struct. Bit layout:
//
// `toggles_and_frame`:
//   bits  0-10: boolean toggles (TOGGLE_* below)
//   bits 11-15: frame_index (0-31)
//   bits 16-17: fog_filter_mode (0-3)
//   bits 18-19: hair-shadow filtering toggles (TOGGLE_HAIR_SHADOW_*)
//
// `enums`:
//   bits  0-3 : debug_noise (0-1)
//   bits  4-7 : debug_dof (0-5)
//   bits  8-11: debug_shadows (0-1)
//   bits 12-15: debug_fog (0-2)
//   bits 16-19: debug_reflections (0-8)

#define EXPEDITION33_GRAPHICS_TOGGLE_USE_ISFAST_NOISE                  0u
#define EXPEDITION33_GRAPHICS_TOGGLE_USE_ISFAST_DOF                    1u
#define EXPEDITION33_GRAPHICS_TOGGLE_USE_ISFAST_SHADOWS                2u
#define EXPEDITION33_GRAPHICS_TOGGLE_USE_ISFAST_FOG                    3u
#define EXPEDITION33_GRAPHICS_TOGGLE_USE_ISFAST_REFLECTIONS            4u
#define EXPEDITION33_GRAPHICS_TOGGLE_USE_REFLECTION_LEAN_WIDENING      5u
// Bit 6 reserved (was R2 progressive sequence; removed after testing
// showed IS-FAST blue noise was strictly better in this pipeline. R2's
// temporal-stratification benefit could not overcome the spatial
// blue-noise advantage IS-FAST holds under the bilateral filter that
// runs every frame. See project-docs/006_genraysb-investigation.)
#define EXPEDITION33_GRAPHICS_TOGGLE_USE_SUPERIOR_REFLECTION_FILTER    7u
#define EXPEDITION33_GRAPHICS_TOGGLE_USE_SUPERIOR_REFLECTION_TEMPORAL  8u
#define EXPEDITION33_GRAPHICS_TOGGLE_USE_SINGLEPASS_DOF                      9u
#define EXPEDITION33_GRAPHICS_TOGGLE_USE_SMOOTH_DOF                    10u
// Bits 11-17 are owned by frame_index + fog_filter_mode (see layout above).
#define EXPEDITION33_GRAPHICS_TOGGLE_HAIR_SHADOW_BOOST_RAYS            18u
#define EXPEDITION33_GRAPHICS_TOGGLE_HAIR_SHADOW_TIGHTEN_CONE          19u

#define EXPEDITION33_GRAPHICS_FRAME_INDEX_SHIFT     11u
#define EXPEDITION33_GRAPHICS_FRAME_INDEX_MASK      0x1Fu
#define EXPEDITION33_GRAPHICS_FOG_FILTER_MODE_SHIFT 16u
#define EXPEDITION33_GRAPHICS_FOG_FILTER_MODE_MASK  0x3u

#define EXPEDITION33_GRAPHICS_ENUM_DEBUG_NOISE_SHIFT       0u
#define EXPEDITION33_GRAPHICS_ENUM_DEBUG_DOF_SHIFT         4u
#define EXPEDITION33_GRAPHICS_ENUM_DEBUG_SHADOWS_SHIFT     8u
#define EXPEDITION33_GRAPHICS_ENUM_DEBUG_FOG_SHIFT         12u
#define EXPEDITION33_GRAPHICS_ENUM_DEBUG_REFLECTIONS_SHIFT 16u

// DoF confidence threshold packed into toggles_and_frame bits 20-23
// (enums bits 20+ exceed float's 24-bit integer precision when combined
// with lower debug enum bits, causing silent corruption via asuint).
#define EXPEDITION33_GRAPHICS_DOF_CONFIDENCE_SHIFT        20u
#define EXPEDITION33_GRAPHICS_DOF_CONFIDENCE_MASK         0xFu

// Shader-side compatibility aliases for the original (un-prefixed) macro
// names. The replacement HLSL files reference TOGGLE_* / ENUM_*_SHIFT
// directly; until they're rewritten we forward the prefixed names.
#define TOGGLE_USE_ISFAST_NOISE                 EXPEDITION33_GRAPHICS_TOGGLE_USE_ISFAST_NOISE
#define TOGGLE_USE_ISFAST_DOF                   EXPEDITION33_GRAPHICS_TOGGLE_USE_ISFAST_DOF
#define TOGGLE_USE_ISFAST_SHADOWS               EXPEDITION33_GRAPHICS_TOGGLE_USE_ISFAST_SHADOWS
#define TOGGLE_USE_ISFAST_FOG                   EXPEDITION33_GRAPHICS_TOGGLE_USE_ISFAST_FOG
#define TOGGLE_USE_ISFAST_REFLECTIONS           EXPEDITION33_GRAPHICS_TOGGLE_USE_ISFAST_REFLECTIONS
#define TOGGLE_USE_REFLECTION_LEAN_WIDENING     EXPEDITION33_GRAPHICS_TOGGLE_USE_REFLECTION_LEAN_WIDENING
#define TOGGLE_USE_SUPERIOR_REFLECTION_FILTER   EXPEDITION33_GRAPHICS_TOGGLE_USE_SUPERIOR_REFLECTION_FILTER
#define TOGGLE_USE_SUPERIOR_REFLECTION_TEMPORAL EXPEDITION33_GRAPHICS_TOGGLE_USE_SUPERIOR_REFLECTION_TEMPORAL
#define TOGGLE_USE_SINGLEPASS_DOF                     EXPEDITION33_GRAPHICS_TOGGLE_USE_SINGLEPASS_DOF
#define TOGGLE_USE_SMOOTH_DOF                   EXPEDITION33_GRAPHICS_TOGGLE_USE_SMOOTH_DOF
#define TOGGLE_HAIR_SHADOW_BOOST_RAYS           EXPEDITION33_GRAPHICS_TOGGLE_HAIR_SHADOW_BOOST_RAYS
#define TOGGLE_HAIR_SHADOW_TIGHTEN_CONE         EXPEDITION33_GRAPHICS_TOGGLE_HAIR_SHADOW_TIGHTEN_CONE
#define ENUM_DEBUG_NOISE_SHIFT                  EXPEDITION33_GRAPHICS_ENUM_DEBUG_NOISE_SHIFT
#define ENUM_DEBUG_DOF_SHIFT                    EXPEDITION33_GRAPHICS_ENUM_DEBUG_DOF_SHIFT
#define ENUM_DEBUG_SHADOWS_SHIFT                EXPEDITION33_GRAPHICS_ENUM_DEBUG_SHADOWS_SHIFT
#define ENUM_DEBUG_FOG_SHIFT                    EXPEDITION33_GRAPHICS_ENUM_DEBUG_FOG_SHIFT
#define ENUM_DEBUG_REFLECTIONS_SHIFT            EXPEDITION33_GRAPHICS_ENUM_DEBUG_REFLECTIONS_SHIFT
#define DOF_CONFIDENCE_SHIFT                    EXPEDITION33_GRAPHICS_DOF_CONFIDENCE_SHIFT
#define DOF_CONFIDENCE_MASK                     EXPEDITION33_GRAPHICS_DOF_CONFIDENCE_MASK

#ifdef __cplusplus
namespace expedition33_graphics {

struct Inject {
  float toggles_and_frame = 0.f;
  float enums = 0.f;
};

}  // namespace expedition33_graphics

#else
// HLSL — `Inject` is a member type inside the host's cbuffer. Declared
// here as a struct so the host's `shared.h` can embed it as a field.
struct expedition33_graphics_Inject {
  float toggles_and_frame;
  float enums;
};
#endif  // __cplusplus

#endif  // SRC_CLAIROBSCUR_EXPEDITION33_GRAPHICS_INJECT_H_
