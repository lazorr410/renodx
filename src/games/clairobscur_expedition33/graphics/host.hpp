/*
 * Copyright (C) 2026
 * SPDX-License-Identifier: MIT
 *
 * expedition33-graphics â€” composable graphics-quality bundle for Expedition 33.
 *
 * This is a header-only module. Include it from a host addon (e.g. the
 * base HDR addon `clairobscur_expedition33`), then call:
 *
 *   expedition33_graphics::Use(h_module, fdw_reason, &shader_injection);
 *   expedition33_graphics::AppendSettings(host_settings_vector);
 *   expedition33_graphics::AppendCustomShaders(host_custom_shaders_map);
 *   expedition33_graphics::OnPresent();   // call from host's present hook
 *
 * The host owns the swapchain pipeline, the `ShaderInjectData` cbuffer,
 * and the settings UI. This bundle plugs in additional shader replacements,
 * IS-FAST noise injection, multi-pass A-trous reflections, custom DoF, and
 * shadow/fog quality work, all driven via the host's bit-packed
 * `graphics_toggles_and_frame` / `graphics_enums` fields (declared in
 * `clairobscur_expedition33/shared.h`).
 */

#ifndef SRC_CLAIROBSCUR_EXPEDITION33_GRAPHICS_HOST_HPP_
#define SRC_CLAIROBSCUR_EXPEDITION33_GRAPHICS_HOST_HPP_

#define ImTextureID ImU64
#define DEBUG_LEVEL_0

#include <cstring>
#include <mutex>
#include <sstream>
#include <string>
#include <unordered_map>
#include <vector>

#include <deps/imgui/imgui.h>
#include <include/reshade.hpp>

#include "../../../mods/shader.hpp"
#include "../../../mods/swapchain.hpp"
#include "../../../utils/settings.hpp"
#include "../../../utils/render.hpp"
#include "../../../utils/descriptor.hpp"
#include "../../../utils/pipeline_layout.hpp"
#include "../../../utils/state.hpp"
#include "../../../utils/resource.hpp"
#include "../../../utils/data.hpp"
#include "../shared.h"  // host's shared.h provides ShaderInjectData + bit-packing helpers
#include "../assets/noise/fast_noise_rg8.h"  // embedded IS-FAST noise data
#include "../assets/noise/disk_noise_rg8.h"  // embedded UniformCircle disk noise data

namespace expedition33_graphics {

// Public configuration. Hosts populate this once via `Configure(...)` from
// their DllMain at DLL_PROCESS_ATTACH, BEFORE any framework `Use(...)` call.
// `Configure` immediately appends our settings + custom_shaders into the
// host-owned containers so they're visible by the time `mods::shader::Use`
// snapshots them.
struct Config {
  ShaderInjectData* host_shader_injection = nullptr;
  renodx::utils::settings::Settings* host_settings = nullptr;
  renodx::mods::shader::CustomShaders* host_custom_shaders = nullptr;
};

namespace internal {

static Config current_config = {};
// `host_shader_injection` was the original global pointer; keep it as a
// thin alias so call sites that were written against it stay compiling.
// Set by `Configure`; cleared on DLL_PROCESS_DETACH.
inline ShaderInjectData* host_shader_injection = nullptr;

}  // namespace internal

namespace {

// --- Individual setting floats (bound by the settings UI) ---
// These get packed into shader_injection.toggles/enums each frame in OnPresent.
static float setting_use_isfast_noise = 1.0f;
static float setting_use_isfast_dof = 1.0f;
static float setting_use_isfast_shadows = 1.0f;
static float setting_use_isfast_fog = 1.0f;
static float setting_use_isfast_reflections = 1.0f;
static float setting_use_reflection_lean_widening = 0.0f;
static float setting_use_superior_reflection_filter = 1.0f;
static float setting_use_superior_reflection_temporal = 0.0f;
static float setting_use_singlepassdof_dof = 1.0f;
static float setting_use_smooth_dof = 1.0f;
static float setting_dof_confidence_threshold = 5.0f;
static float setting_hair_shadow_boost_rays = 1.0f;
static float setting_hair_shadow_tighten_cone = 1.0f;
static float setting_debug_noise = 0.0f;
static float setting_debug_dof = 0.0f;
static float setting_debug_shadows = 0.0f;
static float setting_debug_fog = 0.0f;
static float setting_debug_reflections = 0.0f;
static float setting_fog_filter_mode = 2.0f;

// Pack individual settings into the host's ShaderInjectData struct.
static void PackShaderInjection() {
  using namespace expedition33_inject;
  if (internal::host_shader_injection == nullptr) return;
  ShaderInjectData& shader_injection = *internal::host_shader_injection;
  SetToggle(shader_injection, TOGGLE_USE_ISFAST_NOISE, setting_use_isfast_noise > 0.5f);
  SetToggle(shader_injection, TOGGLE_USE_ISFAST_DOF, setting_use_isfast_dof > 0.5f);
  SetToggle(shader_injection, TOGGLE_USE_ISFAST_SHADOWS, setting_use_isfast_shadows > 0.5f);
  SetToggle(shader_injection, TOGGLE_USE_ISFAST_FOG, setting_use_isfast_fog > 0.5f);
  SetToggle(shader_injection, TOGGLE_USE_ISFAST_REFLECTIONS, setting_use_isfast_reflections > 0.5f);
  SetToggle(shader_injection, TOGGLE_USE_REFLECTION_LEAN_WIDENING, setting_use_reflection_lean_widening > 0.5f);
  SetToggle(shader_injection, TOGGLE_USE_SUPERIOR_REFLECTION_FILTER, setting_use_superior_reflection_filter > 0.5f);
  SetToggle(shader_injection, TOGGLE_USE_SUPERIOR_REFLECTION_TEMPORAL, setting_use_superior_reflection_temporal > 0.5f);
  SetToggle(shader_injection, TOGGLE_USE_SINGLEPASS_DOF, setting_use_singlepassdof_dof > 0.5f);
  SetToggle(shader_injection, TOGGLE_USE_SMOOTH_DOF, setting_use_smooth_dof > 0.5f);
  // Pack confidence threshold as 4-bit quantized value (0-15) into
  // toggles_and_frame bits 20-23 (NOT enums â€” enums bits 20+ exceed
  // float's 24-bit integer precision when combined with debug values).
  // Maps slider range [2.0, 16.0] â†’ [0, 15]. Shader reconstructs: value * (14.0/15.0) + 2.0.
  float conf_normalized = (setting_dof_confidence_threshold - 2.0f) * (15.0f / 14.0f);
  if (conf_normalized < 0.0f) conf_normalized = 0.0f;
  if (conf_normalized > 15.0f) conf_normalized = 15.0f;
  uint32_t conf_quantized = static_cast<uint32_t>(conf_normalized + 0.5f);
  {
    uint32_t bits = expedition33_inject::GetBits(shader_injection.graphics_inject.toggles_and_frame);
    bits &= ~(EXPEDITION33_GRAPHICS_DOF_CONFIDENCE_MASK << EXPEDITION33_GRAPHICS_DOF_CONFIDENCE_SHIFT);
    bits |= ((conf_quantized & EXPEDITION33_GRAPHICS_DOF_CONFIDENCE_MASK) << EXPEDITION33_GRAPHICS_DOF_CONFIDENCE_SHIFT);
    expedition33_inject::SetBits(shader_injection.graphics_inject.toggles_and_frame, bits);
  }
  SetToggle(shader_injection, TOGGLE_HAIR_SHADOW_BOOST_RAYS, setting_hair_shadow_boost_rays > 0.5f);
  SetToggle(shader_injection, TOGGLE_HAIR_SHADOW_TIGHTEN_CONE, setting_hair_shadow_tighten_cone > 0.5f);
  SetFogFilterMode(shader_injection, static_cast<uint32_t>(setting_fog_filter_mode + 0.5f));

  SetEnum(shader_injection, ENUM_DEBUG_NOISE_SHIFT, static_cast<uint32_t>(setting_debug_noise + 0.5f));
  SetEnum(shader_injection, ENUM_DEBUG_DOF_SHIFT, static_cast<uint32_t>(setting_debug_dof + 0.5f));
  SetEnum(shader_injection, ENUM_DEBUG_SHADOWS_SHIFT, static_cast<uint32_t>(setting_debug_shadows + 0.5f));
  SetEnum(shader_injection, ENUM_DEBUG_FOG_SHIFT, static_cast<uint32_t>(setting_debug_fog + 0.5f));
  SetEnum(shader_injection, ENUM_DEBUG_REFLECTIONS_SHIFT, static_cast<uint32_t>(setting_debug_reflections + 0.5f));
}

// --- Texture state ---
reshade::api::resource fast_noise_resource = {0};
reshade::api::resource_view fast_noise_srv = {0};
bool fast_noise_created = false;

// --- Disk-distributed noise texture for DOF (UniformCircle) ---
reshade::api::resource fast_noise_disk_resource = {0};
reshade::api::resource_view fast_noise_disk_srv = {0};
bool fast_noise_disk_created = false;

// --- Custom DoF blur state (reserved for future multi-pass approach) ---
// Currently unused â€” the blur is done inline in the Recombine shader.
// Kept for potential future use if we solve the descriptor table tracking.
reshade::api::resource dof_intermediate_resource = {0};
reshade::api::resource_view dof_intermediate_srv = {0};
reshade::api::resource_view dof_intermediate_uav = {0};
reshade::api::resource dof_output_resource = {0};
reshade::api::resource_view dof_output_srv = {0};
reshade::api::resource_view dof_output_uav = {0};
bool dof_textures_created = false;
uint32_t dof_width = 0;
uint32_t dof_height = 0;

renodx::utils::render::RenderPass dof_hblur_pass;
renodx::utils::render::RenderPass dof_vblur_pass;

// --- Scene color SRV tracking ---
// Tracks the most recent SRV pushed to compute stage slot t0 (SceneColorInput for Recombine).
// Protected by mutex since push_descriptors and dispatch can fire on different threads.
std::mutex scene_color_mutex;
std::unordered_map<uint64_t, reshade::api::resource_view> scene_color_srv_per_cmd_list;

struct DofBlurConstants {
  uint32_t width;
  uint32_t height;
  float coc_scale;
  float max_blur_radius;
};
static constexpr uint32_t NOISE_WIDTH = 128;
static constexpr uint32_t NOISE_HEIGHT = 128;
static constexpr uint32_t NOISE_SLICES = 32;

static HMODULE s_module_handle = nullptr;
reshade::api::device* pending_device = nullptr;

// --- Path resolution & PNG loading ---
// REMOVED: Noise textures are now embedded in the binary.
// See assets/noise/fast_noise_rg8.h and assets/noise/disk_noise_rg8.h

static constexpr uint32_t NOISE_SLICE_BYTES = NOISE_WIDTH * NOISE_HEIGHT * 2;  // RG8 source = 2 bytes/pixel
static constexpr uint32_t NOISE_TEXEL_COUNT = NOISE_WIDTH * NOISE_HEIGHT * NOISE_SLICES;
// Each pixel of the source RG8 expands to a float2 in the GPU buffer.
static constexpr uint32_t NOISE_BYTES_PER_ELEMENT = static_cast<uint32_t>(sizeof(float) * 2u);
static constexpr uint64_t NOISE_BUFFER_BYTES = static_cast<uint64_t>(NOISE_TEXEL_COUNT) * NOISE_BYTES_PER_ELEMENT;

// --- Buffer SRV creation from embedded data ---
//
// Both noise resources are bound to game shaders as
// `descriptor_type::buffer_shader_resource_view` (a D3D12 root SRV) rather
// than `shader_resource_view` (a typed texture SRV). Background:
//
// ReShade's `cmd_list->push_descriptors` for a typed texture SRV falls
// into a slow path that allocates a transient slot in its own GPU view
// heap and calls `SetDescriptorHeaps` to swap the bound heap to ReShade's
// heap. That swap invalidates every root descriptor table the GAME has
// previously bound on the same command list â€” those tables still index
// into the game's heap, but the GPU now resolves them against ReShade's
// transient heap, sampling whatever happens to be at the same offset
// (usually the noise descriptor we just copied). The result is the
// well-known "noise dots covering the screen" artifact, and it shows up
// even when the shader's IS-FAST toggle is OFF because the corruption
// hits the GAME's draws between our push and the next time something
// restores the heap. See `project-docs/011_buffer-srv-injection-no-heap-swap/`
// and `tmp/DESCRIPTOR_TABLE_BLEED_INVESTIGATION.md`.
//
// `buffer_shader_resource_view` routes through ReShade's fast path
// (`SetGraphicsRootShaderResourceView(gpu_va)`) which is heap-independent.
// D3D12 root SRVs only support raw / structured buffers, so the source
// RG8 data is decoded to float2 and stored as a `ByteAddressBuffer`.
//
// We use ByteAddressBuffer (raw) rather than StructuredBuffer because
// ReShade's resource_view_desc has no StructureByteStride field â€” a
// StructuredBuffer with `format=unknown` ends up with a malformed
// D3D12_SHADER_RESOURCE_VIEW_DESC and crashes some drivers. Raw works
// with `format=r32_typeless` + size in 4-byte words.

void CreateFASTNoiseTexture(reshade::api::device* device) {
  if (fast_noise_created) return;

  static_assert(sizeof(__fast_noise_rg8_base) == NOISE_WIDTH * NOISE_HEIGHT * 2 * NOISE_SLICES,
                "Embedded FAST noise data size mismatch");

  // RG8 â†’ float2 decode at upload time. ~4 MiB allocation, paid once.
  std::vector<float> decoded(NOISE_TEXEL_COUNT * 2u);
  for (uint32_t i = 0; i < NOISE_TEXEL_COUNT; ++i) {
    decoded[i * 2u + 0u] = static_cast<float>(__fast_noise_rg8_base[i * 2u + 0u]) / 255.0f;
    decoded[i * 2u + 1u] = static_cast<float>(__fast_noise_rg8_base[i * 2u + 1u]) / 255.0f;
  }

  reshade::api::subresource_data initial_data = {};
  initial_data.data = decoded.data();
  initial_data.row_pitch = static_cast<uint32_t>(NOISE_BUFFER_BYTES);
  initial_data.slice_pitch = static_cast<uint32_t>(NOISE_BUFFER_BYTES);

  reshade::api::resource_desc buf_desc(
      NOISE_BUFFER_BYTES,
      reshade::api::memory_heap::gpu_only,
      reshade::api::resource_usage::shader_resource);

  if (!device->create_resource(buf_desc, &initial_data,
          reshade::api::resource_usage::shader_resource, &fast_noise_resource)) {
    reshade::log::message(reshade::log::level::error,
        "expedition33-graphics: Failed to create IS-FAST noise buffer resource");
    return;
  }

  // Raw byte-address SRV: format=r32_typeless triggers
  // D3D12_BUFFER_SRV_FLAG_RAW; size is in 4-byte words.
  reshade::api::resource_view_desc srv_desc(
      reshade::api::format::r32_typeless,
      0u,
      static_cast<uint64_t>(NOISE_BUFFER_BYTES / sizeof(uint32_t)));

  if (!device->create_resource_view(fast_noise_resource,
          reshade::api::resource_usage::shader_resource, srv_desc, &fast_noise_srv)) {
    reshade::log::message(reshade::log::level::error,
        "expedition33-graphics: Failed to create SRV for IS-FAST noise buffer");
    device->destroy_resource(fast_noise_resource);
    fast_noise_resource = {0};
    return;
  }

  fast_noise_created = true;
  reshade::log::message(reshade::log::level::info,
      "expedition33-graphics: IS-FAST noise buffer (ByteAddressBuffer, 128x128x32 float2) "
      "created from embedded data; using buffer SRV path to avoid heap-swap corruption");
}

void DestroyFASTNoiseTexture(reshade::api::device* device) {
  if (!fast_noise_created) return;
  if (fast_noise_srv.handle) {
    device->destroy_resource_view(fast_noise_srv);
    fast_noise_srv = {0};
  }
  if (fast_noise_resource.handle) {
    device->destroy_resource(fast_noise_resource);
    fast_noise_resource = {0};
  }
  fast_noise_created = false;
}

// --- Disk-distributed noise texture (UniformCircle) for DOF ---

void CreateFASTNoiseDiskTexture(reshade::api::device* device) {
  if (fast_noise_disk_created) return;

  static_assert(sizeof(__disk_noise_rg8_base) == NOISE_WIDTH * NOISE_HEIGHT * 2 * NOISE_SLICES,
                "Embedded disk noise data size mismatch");

  std::vector<float> decoded(NOISE_TEXEL_COUNT * 2u);
  for (uint32_t i = 0; i < NOISE_TEXEL_COUNT; ++i) {
    decoded[i * 2u + 0u] = static_cast<float>(__disk_noise_rg8_base[i * 2u + 0u]) / 255.0f;
    decoded[i * 2u + 1u] = static_cast<float>(__disk_noise_rg8_base[i * 2u + 1u]) / 255.0f;
  }

  reshade::api::subresource_data initial_data = {};
  initial_data.data = decoded.data();
  initial_data.row_pitch = static_cast<uint32_t>(NOISE_BUFFER_BYTES);
  initial_data.slice_pitch = static_cast<uint32_t>(NOISE_BUFFER_BYTES);

  reshade::api::resource_desc buf_desc(
      NOISE_BUFFER_BYTES,
      reshade::api::memory_heap::gpu_only,
      reshade::api::resource_usage::shader_resource);

  if (!device->create_resource(buf_desc, &initial_data,
          reshade::api::resource_usage::shader_resource, &fast_noise_disk_resource)) {
    reshade::log::message(reshade::log::level::error,
        "expedition33-graphics: Failed to create disk noise buffer resource");
    return;
  }

  reshade::api::resource_view_desc srv_desc(
      reshade::api::format::r32_typeless,
      0u,
      static_cast<uint64_t>(NOISE_BUFFER_BYTES / sizeof(uint32_t)));

  if (!device->create_resource_view(fast_noise_disk_resource,
          reshade::api::resource_usage::shader_resource, srv_desc, &fast_noise_disk_srv)) {
    reshade::log::message(reshade::log::level::error,
        "expedition33-graphics: Failed to create SRV for disk noise buffer");
    device->destroy_resource(fast_noise_disk_resource);
    fast_noise_disk_resource = {0};
    return;
  }

  fast_noise_disk_created = true;
  reshade::log::message(reshade::log::level::info,
      "expedition33-graphics: Disk noise buffer (ByteAddressBuffer, 128x128x32 float2 UniformCircle) "
      "created from embedded data");
}

void DestroyFASTNoiseDiskTexture(reshade::api::device* device) {
  if (!fast_noise_disk_created) return;
  if (fast_noise_disk_srv.handle) {
    device->destroy_resource_view(fast_noise_disk_srv);
    fast_noise_disk_srv = {0};
  }
  if (fast_noise_disk_resource.handle) {
    device->destroy_resource(fast_noise_disk_resource);
    fast_noise_disk_resource = {0};
  }
  fast_noise_disk_created = false;
}

// --- ViewBinding get_view callback ---
// Returns the IS-FAST noise SRV. If the texture hasn't been created yet, creates it lazily.
// Uses a mutex to prevent racing with BuildReplacementPipeline on the immediate command list.
reshade::api::resource_view GetNoiseSRV(reshade::api::command_list* cmd_list) {
  if (!fast_noise_created) {
    static std::mutex creation_mutex;
    std::lock_guard lock(creation_mutex);
    if (!fast_noise_created) {
      reshade::api::device* device = cmd_list ? cmd_list->get_device() : pending_device;
      if (device) {
        pending_device = device;
        CreateFASTNoiseTexture(device);
      }
    }
  }
  return fast_noise_srv;
}

// Returns the disk-distributed IS-FAST noise SRV for DOF shaders.
// Falls back to the square noise SRV if disk textures aren't available.
reshade::api::resource_view GetNoiseSRVDisk(reshade::api::command_list* cmd_list) {
  if (!fast_noise_disk_created) {
    static std::mutex creation_mutex;
    std::lock_guard lock(creation_mutex);
    if (!fast_noise_disk_created) {
      reshade::api::device* device = cmd_list ? cmd_list->get_device() : pending_device;
      if (device) {
        pending_device = device;
        CreateFASTNoiseDiskTexture(device);
      }
    }
  }
  if (fast_noise_disk_created) return fast_noise_disk_srv;
  // Fallback: use square noise (DOF shader handles both via toggle)
  return GetNoiseSRV(cmd_list);
}

// Forward declaration.
static void OnAfterBilateral(reshade::api::command_list* cmd_list);

// Per-command-list snapshot of the bilateral's compute pipeline layout +
// descriptor tables, captured at `on_inject` time (synchronously, BEFORE
// the dispatch, while the bilateral's bindings are still authoritative).
// `OnAfterBilateral` runs on a deferred drain after the wrapper's
// `_orig->Dispatch`, by which point the game may have already bound the
// next compute shader and live state would point at the wrong layout.
// Keying by `cmd_list` handle is safe because each command list is only
// recorded by one thread at a time (D3D12 contract).
std::mutex bilateral_state_mutex;
struct BilateralCapturedState {
  reshade::api::pipeline_layout layout = {0};
  std::vector<reshade::api::descriptor_table> tables;
};
std::unordered_map<uint64_t, BilateralCapturedState> bilateral_state_per_cmd_list;

static bool CaptureBilateralState(reshade::api::command_list* cmd_list) {
  // Runs as the bilateral's `on_inject` callback. Snapshot the live
  // compute state â€” at this point in HandleStatesAndBypass, the framework
  // has not yet pushed our injected bindings, so the layout + tables
  // genuinely reflect the bilateral's pipeline.
  if (cmd_list == nullptr) return true;
  const auto* state = renodx::utils::state::GetCurrentState(cmd_list);
  if (state == nullptr) return true;
  if (state->compute_pipeline_layout.handle == 0u) return true;

  const auto handle = reinterpret_cast<uint64_t>(cmd_list);
  std::lock_guard lock(bilateral_state_mutex);
  auto& captured = bilateral_state_per_cmd_list[handle];
  captured.layout = state->compute_pipeline_layout;
  captured.tables = state->compute_descriptor_tables;
  return true;  // continue with normal injection
}

// get_view for the temporal reprojection shader (0x8473BC79). This fires
// right before the temporal dispatch â€” at which point the bilateral has
// already completed. We use this as the trigger point for multipass.
reshade::api::resource_view GetNoiseSRVAndTriggerMultipass(reshade::api::command_list* cmd_list) {
  if (!fast_noise_created) {
    static std::mutex creation_mutex;
    std::lock_guard lock(creation_mutex);
    if (!fast_noise_created) {
      reshade::api::device* device = cmd_list ? cmd_list->get_device() : pending_device;
      if (device) {
        pending_device = device;
        CreateFASTNoiseTexture(device);
      }
    }
  }
  // Fire multipass passes between bilateral and temporal.
  OnAfterBilateral(cmd_list);
  return fast_noise_srv;
}

// --- Custom DoF blur textures ---
void CreateDofTextures(reshade::api::device* device, uint32_t width, uint32_t height) {
  if (dof_textures_created && dof_width == width && dof_height == height) return;
  if (dof_textures_created) {
    // Destroy old if size changed
    device->destroy_resource_view(dof_intermediate_srv);
    device->destroy_resource_view(dof_intermediate_uav);
    device->destroy_resource(dof_intermediate_resource);
    device->destroy_resource_view(dof_output_srv);
    device->destroy_resource_view(dof_output_uav);
    device->destroy_resource(dof_output_resource);
  }

  reshade::api::resource_desc tex_desc = {};
  tex_desc.type = reshade::api::resource_type::texture_2d;
  tex_desc.texture.width = width;
  tex_desc.texture.height = height;
  tex_desc.texture.depth_or_layers = 1;
  tex_desc.texture.levels = 1;
  tex_desc.texture.format = reshade::api::format::r16g16b16a16_float;
  tex_desc.texture.samples = 1;
  tex_desc.heap = reshade::api::memory_heap::gpu_only;
  tex_desc.usage = reshade::api::resource_usage::shader_resource
                 | reshade::api::resource_usage::unordered_access;

  // Intermediate (H-blur output)
  device->create_resource(tex_desc, nullptr,
      reshade::api::resource_usage::unordered_access, &dof_intermediate_resource);

  reshade::api::resource_view_desc srv_desc = {};
  srv_desc.type = reshade::api::resource_view_type::texture_2d;
  srv_desc.format = reshade::api::format::r16g16b16a16_float;
  srv_desc.texture.first_level = 0;
  srv_desc.texture.level_count = 1;
  srv_desc.texture.first_layer = 0;
  srv_desc.texture.layer_count = 1;

  device->create_resource_view(dof_intermediate_resource,
      reshade::api::resource_usage::shader_resource, srv_desc, &dof_intermediate_srv);

  reshade::api::resource_view_desc uav_desc = {};
  uav_desc.type = reshade::api::resource_view_type::texture_2d;
  uav_desc.format = reshade::api::format::r16g16b16a16_float;
  uav_desc.texture.first_level = 0;
  uav_desc.texture.level_count = 1;
  uav_desc.texture.first_layer = 0;
  uav_desc.texture.layer_count = 1;

  device->create_resource_view(dof_intermediate_resource,
      reshade::api::resource_usage::unordered_access, uav_desc, &dof_intermediate_uav);

  // Output (V-blur output = final custom DoF)
  device->create_resource(tex_desc, nullptr,
      reshade::api::resource_usage::unordered_access, &dof_output_resource);
  device->create_resource_view(dof_output_resource,
      reshade::api::resource_usage::shader_resource, srv_desc, &dof_output_srv);
  device->create_resource_view(dof_output_resource,
      reshade::api::resource_usage::unordered_access, uav_desc, &dof_output_uav);

  dof_width = width;
  dof_height = height;
  dof_textures_created = true;

  std::ostringstream msg;
  msg << "expedition33-graphics: Custom DoF textures created (" << width << "x" << height << ")";
  reshade::log::message(reshade::log::level::info, msg.str().c_str());
}

void DestroyDofTextures(reshade::api::device* device) {
  if (!dof_textures_created) return;
  device->destroy_resource_view(dof_intermediate_srv);
  device->destroy_resource_view(dof_intermediate_uav);
  device->destroy_resource(dof_intermediate_resource);
  device->destroy_resource_view(dof_output_srv);
  device->destroy_resource_view(dof_output_uav);
  device->destroy_resource(dof_output_resource);
  dof_intermediate_resource = {0}; dof_intermediate_srv = {0}; dof_intermediate_uav = {0};
  dof_output_resource = {0}; dof_output_srv = {0}; dof_output_uav = {0};
  dof_textures_created = false;
}

// Returns the custom DoF output SRV â€” currently unused since blur is inline.
reshade::api::resource_view GetDofOutputSRV(reshade::api::command_list*) {
  return dof_output_srv;
}

// Bypass callback: skips the draw when custom DoF replacement is active.
// Currently unused â€” kept for future multi-pass approach.
bool ShouldDrawGatherPass(reshade::api::command_list*) {
  return true;  // Always draw (bypass disabled)
}

// =============================================================================
// Multi-pass A-trous (Lumen reflections) â€” custom compute passes injected after
// the game's 0x88E6E1DB bilateral dispatch. This adds two A-trous passes at
// step sizes 3 and 7 (coprime with the step=1 pass already baked into the
// modified bilateral shader), extending the effective filter footprint to
// ~29x29 and killing the single-pass 5-pixel grid period.
//
// Binding strategy (v2, descriptor-tables reuse):
//   Instead of heap-walking to recover the game's bindings, we clone UE5's
//   compute root signature, append our own descriptor table + push_constants
//   range in space 100, and let our shader read UE5's t0..t6 SRVs and u0 UAV
//   at their native register slots. Our ping texture + params plug into
//   space 100. The game's descriptor tables from the bilateral's state are
//   rebound under the cloned layout unchanged; we only push descriptors for
//   our extra SRV/UAV pair and push_constants.
//
// Per-device state lives in AtrousDeviceData (created in OnInitDevice,
// destroyed in OnDestroyDevice) so ReShade device tear-down cleans up all
// owned resources, views, pipeline layout, and pipelines.
// =============================================================================

struct AtrousPushConstants {
  uint32_t step_size;            // 3 for pass 2, 7 for pass 3
  uint32_t input_source;         // 0 = SpecularIndirect (t6, s0), 1 = PingInput (t0, s100)
  uint32_t output_target;        // 0 = PingOutput (u0, s100), 1 = RWSpecularIndirect (u0, s0)
  uint32_t pass_index;           // 1 for step=3 (pass 2), 2 for step=7 (pass 3). 0 reserved for inline.
  uint32_t rect_min_x, rect_min_y;
  uint32_t rect_size_x, rect_size_y;
  uint32_t frame_index;          // 0..31 â€” IS-FAST temporal slice
  float    variance_attenuation; // 1.0 (inline pass 1), 9.0 (pass 2), 81.0 (pass 3)
  uint32_t _pad_0;
  uint32_t _pad_1;
};
static_assert(sizeof(AtrousPushConstants) == 48u,
              "AtrousPushConstants must be 12 DWORDs");

struct __declspec(uuid("c1a3d55e-ef1e-4f9a-9c1c-6e4e1b2d3a55")) AtrousDeviceData {
  // Ping texture matches SpecularIndirect (RGBA8/R11G11B10/RGBA16F depending
  // on the game's reflection buffer format). Declared as Texture2DArray for
  // shader compatibility with UE5's t6 SRV dimension.
  reshade::api::resource      ping_resource = {0};
  reshade::api::resource_view ping_srv      = {0};
  reshade::api::resource_view ping_uav      = {0};
  bool                        textures_created = false;
  uint32_t                    width = 0;
  uint32_t                    height = 0;
  reshade::api::format        specular_format_cached = reshade::api::format::unknown;

  // Cloned compute root signature: UE5's bilateral layout params + one
  // descriptor_table of (SRV at t0,s100; UAV at u0,s100) + push_constants
  // at b0,s100. Built on the first dispatch where we see the game's
  // compute layout, then reused until device destruction.
  uint64_t                    cloned_from_layout_handle = 0u;
  uint32_t                    game_param_count = 0u;
  reshade::api::pipeline_layout cloned_layout = {0};

  // One RenderPass per dispatch phase. Both use the cloned layout at param
  // indices [game_param_count, game_param_count+1] for our
  // descriptor_table/push_constants. Pipeline + pipeline_subobjects are
  // owned and created lazily on the first Render() call.
  renodx::utils::render::RenderPass pass2;  // SpecularIndirect â†’ ping
  renodx::utils::render::RenderPass pass3;  // ping            â†’ RWSpecularIndirect

  AtrousPushConstants params_pass2 = {};
  AtrousPushConstants params_pass3 = {};

  bool logged_first_run   = false;
  bool logged_miss        = false;
  bool logged_pass_result = false;
};

static AtrousDeviceData* GetAtrousData(reshade::api::device* device) {
  if (device == nullptr) return nullptr;
  return renodx::utils::data::Get<AtrousDeviceData>(device);
}

static void CreateAtrousTextures(reshade::api::device* device,
                                 AtrousDeviceData* data,
                                 uint32_t width, uint32_t height,
                                 reshade::api::format format) {
  if (data->textures_created
      && data->width == width
      && data->height == height
      && data->specular_format_cached == format) {
    return;
  }
  if (data->textures_created) {
    if (data->ping_srv.handle)      device->destroy_resource_view(data->ping_srv);
    if (data->ping_uav.handle)      device->destroy_resource_view(data->ping_uav);
    if (data->ping_resource.handle) device->destroy_resource(data->ping_resource);
    data->ping_resource = {0}; data->ping_srv = {0}; data->ping_uav = {0};
    data->textures_created = false;
  }

  // Use a 4-channel float format the shader can load typed. R11G11B10 UAV
  // loads are not universally supported on pre-SM6.0 hardware; we only
  // STORE to ping, then read it via an SRV (typed load on the SRV path is
  // well-supported across vendors).
  reshade::api::format tex_format = format;

  reshade::api::resource_desc tex_desc = {};
  tex_desc.type                    = reshade::api::resource_type::texture_2d;
  tex_desc.texture.width           = width;
  tex_desc.texture.height          = height;
  tex_desc.texture.depth_or_layers = 1;
  tex_desc.texture.levels          = 1;
  tex_desc.texture.format          = tex_format;
  tex_desc.texture.samples         = 1;
  tex_desc.heap                    = reshade::api::memory_heap::gpu_only;
  tex_desc.usage                   = reshade::api::resource_usage::shader_resource
                                   | reshade::api::resource_usage::unordered_access;

  reshade::api::resource_view_desc srv_desc = {};
  srv_desc.type = reshade::api::resource_view_type::texture_2d_array;
  srv_desc.format = tex_format;
  srv_desc.texture.first_level = 0;
  srv_desc.texture.level_count = 1;
  srv_desc.texture.first_layer = 0;
  srv_desc.texture.layer_count = 1;
  reshade::api::resource_view_desc uav_desc = srv_desc;

  if (!device->create_resource(tex_desc, nullptr,
          reshade::api::resource_usage::unordered_access, &data->ping_resource)) {
    reshade::log::message(reshade::log::level::error,
        "expedition33-graphics: Failed to create atrous ping resource");
    return;
  }
  device->create_resource_view(data->ping_resource,
      reshade::api::resource_usage::shader_resource, srv_desc, &data->ping_srv);
  device->create_resource_view(data->ping_resource,
      reshade::api::resource_usage::unordered_access, uav_desc, &data->ping_uav);

  data->width = width;
  data->height = height;
  data->specular_format_cached = format;
  data->textures_created = true;

  std::ostringstream msg;
  msg << "expedition33-graphics: Atrous ping texture created ("
      << width << "x" << height
      << " fmt=" << static_cast<uint32_t>(tex_format) << ")";
  reshade::log::message(reshade::log::level::info, msg.str().c_str());
}

static void DestroyAtrousTextures(reshade::api::device* device, AtrousDeviceData* data) {
  if (data == nullptr || !data->textures_created) return;
  if (data->ping_srv.handle)      device->destroy_resource_view(data->ping_srv);
  if (data->ping_uav.handle)      device->destroy_resource_view(data->ping_uav);
  if (data->ping_resource.handle) device->destroy_resource(data->ping_resource);
  data->ping_resource = {0}; data->ping_srv = {0}; data->ping_uav = {0};
  data->textures_created = false;
}

// Clone the game's compute root signature and append our space-100 params.
// The cloned layout has UE5's params 0..N-1 at the same indices (so
// bind_descriptor_tables with the game's tables works unchanged), then:
//   [game_param_count]     descriptor_table: SRV (t0,s100) + UAV (u0,s100)
//   [game_param_count + 1] push_constants  : b0, s100, 8 DWORDs
//
// This single descriptor_table with two ranges in a row costs only 1 root
// signature DWORD (vs 2 for separate push_descriptors params). It also
// aligns with how RenderPass::Render emits push_descriptors â€” a single
// descriptor_table_update of type texture_shader_resource_view / uav gets
// bound per layout_param, and we now have those at param [N] and [N+1].
// So we use TWO push_descriptors params in the cloned layout instead, to
// stay 1:1 with RenderPass's auto-generated descriptor_table_updates.
static bool EnsureClonedLayout(reshade::api::device* device,
                               AtrousDeviceData* data,
                               reshade::api::pipeline_layout game_layout) {
  if (game_layout.handle == 0u) return false;

  if (data->cloned_layout.handle != 0u
      && data->cloned_from_layout_handle == game_layout.handle) {
    return true;
  }

  // Layout changed or first-time build. If we had an old clone, tear it
  // down first; any pipelines/RenderPass caches tied to it are invalidated.
  if (data->cloned_layout.handle != 0u) {
    if (data->pass2.pipeline.handle != 0u && data->pass2.generated_pipeline) {
      device->destroy_pipeline(data->pass2.pipeline);
    }
    data->pass2.pipeline = {0};
    data->pass2.generated_pipeline = false;
    data->pass2.layout = {0};
    data->pass2.generated_layout = false;

    if (data->pass3.pipeline.handle != 0u && data->pass3.generated_pipeline) {
      device->destroy_pipeline(data->pass3.pipeline);
    }
    data->pass3.pipeline = {0};
    data->pass3.generated_pipeline = false;
    data->pass3.layout = {0};
    data->pass3.generated_layout = false;

    device->destroy_pipeline_layout(data->cloned_layout);
    data->cloned_layout = {0};
    data->cloned_from_layout_handle = 0u;
    data->game_param_count = 0u;
  }

  std::vector<reshade::api::pipeline_layout_param> params;
  // Own storage for descriptor_table ranges. PipelineLayoutData caches
  // ranges only for `descriptor_table` params (not for
  // descriptor_table_with_static_samplers or push_descriptors_*_ranges
  // variants). By snapshotting into our own vector we make every
  // descriptor_table param's ranges pointer valid for the lifetime of
  // this call, regardless of what the framework stored.
  std::vector<std::vector<reshade::api::descriptor_range>> owned_ranges;
  uint32_t game_count = 0u;
  bool cloned_ok = renodx::utils::pipeline_layout::GetPipelineLayoutData(
      game_layout, [&](const auto& local) {
    const auto& info = *local;
    params.assign(info.params.begin(), info.params.end());
    game_count = static_cast<uint32_t>(info.params.size());
    owned_ranges.resize(game_count);
    for (uint32_t i = 0; i < game_count; ++i) {
      auto& p = params[i];
      // For each param that carries `descriptor_range` data, point it at
      // our locally-owned snapshot in `owned_ranges[i]`. This serves two
      // purposes:
      //
      //   1. The framework's PipelineLayoutData cache retains the range
      //      arrays for `descriptor_table` and `descriptor_table_with_*`
      //      params, but the param struct's `ranges` pointer still
      //      references the GAME's original allocation, which may not be
      //      valid by the time WE invoke `create_pipeline_layout`.
      //
      //   2. For `descriptor_table_with_static_samplers` (type=5) and
      //      `push_descriptors_with_ranges_and_flags` (type=7), the param
      //      type uses an extended range struct (with static-sampler /
      //      flag fields) that the framework stores in a parallel cache.
      //      We don't use static samplers or flags in our atrous shader,
      //      so we DOWNGRADE these to plain `descriptor_table` params.
      //      The cloned layout still binds the game's descriptor tables
      //      correctly because the descriptor ranges (binding, register,
      //      space, count, type) are preserved â€” only static-sampler
      //      definitions are dropped, which doesn't affect us.
      switch (p.type) {
        case reshade::api::pipeline_layout_param_type::descriptor_table: {
          const uint32_t rc = p.descriptor_table.count;
          if (rc > 0u && i < info.ranges.size() && !info.ranges[i].empty()) {
            owned_ranges[i].assign(info.ranges[i].begin(), info.ranges[i].end());
            p.descriptor_table.ranges = owned_ranges[i].data();
            p.descriptor_table.count  = static_cast<uint32_t>(owned_ranges[i].size());
          }
          break;
        }
        case reshade::api::pipeline_layout_param_type::descriptor_table_with_static_samplers:
        case reshade::api::pipeline_layout_param_type::push_descriptors_with_static_samplers: {
          // Downgrade either static-sampler variant to plain
          // descriptor_table. Drop sampler ranges â€” the game's original
          // layout has them as STATIC samplers (baked into the root
          // signature, no descriptor heap entry, no overlap-conflict),
          // but our downgraded copy would treat them as RUNTIME sampler
          // descriptor tables, which D3D12 then sees as overlapping with
          // sampler ranges already declared in another root param. Our
          // atrous shader doesn't sample anything (Texture2DArray::Load
          // only) so dropping samplers here is harmless.
          //
          // The framework's PipelineLayout cache stores ranges as plain
          // `descriptor_range` (sliced from the static-sampler variant),
          // so the data we copy already has no sampler-desc pointers.
          //
          // If filtering leaves the param empty (the original was a pure
          // static-sampler container), we substitute a non-conflicting
          // placeholder SRV range at a register/space we don't otherwise
          // use; the bind loop later will skip this slot because the
          // game's `compute_descriptor_tables[i]` is zero for static-
          // sampler params (the game never bound a runtime descriptor
          // table here).
          if (i < info.ranges.size()) {
            owned_ranges[i].clear();
            owned_ranges[i].reserve(info.ranges[i].size());
            for (const auto& range : info.ranges[i]) {
              if (range.type == reshade::api::descriptor_type::sampler) continue;
              owned_ranges[i].push_back(range);
            }
          }
          if (owned_ranges[i].empty()) {
            // Placeholder â€” won't be bound at runtime, won't conflict.
            owned_ranges[i].push_back(reshade::api::descriptor_range{
                .binding = 0u,
                .dx_register_index = 99u,
                .dx_register_space = 999u,
                .count = 1u,
                .visibility = reshade::api::shader_stage::all,
                .array_size = 1u,
                .type = reshade::api::descriptor_type::texture_shader_resource_view,
            });
          }
          p.type = reshade::api::pipeline_layout_param_type::descriptor_table;
          p.descriptor_table.count  = static_cast<uint32_t>(owned_ranges[i].size());
          p.descriptor_table.ranges = owned_ranges[i].data();
          break;
        }
        default:
          // push_descriptors / push_constants / push_descriptors_with_*
          // either contain inline range structs (no pointer to fix up)
          // or pointers we can't rewrite cleanly. They're left as-is.
          // If a future game presents one that crashes here, add a case.
          break;
      }
    }
  });
  if (!cloned_ok) {
    reshade::log::message(reshade::log::level::error,
        "expedition33-graphics: atrous EnsureClonedLayout GetPipelineLayoutData returned false");
    return false;
  }

  // Diagnostic dump of the game's params so we can see exactly what we're
  // cloning if create_pipeline_layout fails below.
  {
    std::ostringstream s;
    s << "expedition33-graphics: atrous cloning game compute layout "
      << game_layout.handle << " game_param_count=" << game_count;
    for (uint32_t i = 0; i < game_count; ++i) {
      const auto& p = params[i];
      s << " [" << i << " type=" << static_cast<uint32_t>(p.type);
      switch (p.type) {
        case reshade::api::pipeline_layout_param_type::push_descriptors:
          s << " pd(reg=" << p.push_descriptors.dx_register_index
            << " s=" << p.push_descriptors.dx_register_space
            << " cnt=" << p.push_descriptors.count
            << " dt=" << static_cast<uint32_t>(p.push_descriptors.type) << ")";
          break;
        case reshade::api::pipeline_layout_param_type::push_constants:
          s << " pc(reg=" << p.push_constants.dx_register_index
            << " s=" << p.push_constants.dx_register_space
            << " cnt=" << p.push_constants.count << ")";
          break;
        case reshade::api::pipeline_layout_param_type::descriptor_table:
          s << " dt(ranges=" << p.descriptor_table.count << ")";
          break;
        default:
          s << " (other)";
          break;
      }
      s << "]";
    }
    reshade::log::message(reshade::log::level::info, s.str().c_str());
  }

  // Append our descriptor_table params (SRV + UAV) + push_constants.
  // We use descriptor_table type (not push_descriptors) so that the new
  // render.hpp can allocate_descriptor_table from these params.
  // SRV table holds two slots: PingInput (t0, s100) + ISFASTNoise (t1, s100).
  // RenderPass auto-generates exactly one descriptor_table_update per
  // SRV-list, so packing both into a single range with count=2 is the
  // simplest 1:1 mapping. The shader declares them as adjacent registers.
  static reshade::api::descriptor_range atrous_srv_range = {
      .binding = 0,
      .dx_register_index = 0,
      .dx_register_space = 100,
      .count = 2,
      .visibility = reshade::api::shader_stage::all_compute,
      .array_size = 1,
      .type = reshade::api::descriptor_type::texture_shader_resource_view,
  };
  static reshade::api::descriptor_range atrous_uav_range = {
      .binding = 0,
      .dx_register_index = 0,
      .dx_register_space = 100,
      .count = 1,
      .visibility = reshade::api::shader_stage::all_compute,
      .array_size = 1,
      .type = reshade::api::descriptor_type::texture_unordered_access_view,
  };
  params.emplace_back(1, &atrous_srv_range);
  params.emplace_back(1, &atrous_uav_range);
  {
    reshade::api::pipeline_layout_param p = {};
    p.type = reshade::api::pipeline_layout_param_type::push_constants;
    p.push_constants.count               = sizeof(AtrousPushConstants) / sizeof(uint32_t);
    p.push_constants.dx_register_index   = 0;
    p.push_constants.dx_register_space   = 100;
    p.push_constants.visibility          = reshade::api::shader_stage::all_compute;
    params.push_back(p);
  }

  reshade::api::pipeline_layout new_layout = {0};
  if (!device->create_pipeline_layout(
          static_cast<uint32_t>(params.size()),
          params.data(),
          &new_layout)
      || new_layout.handle == 0u) {
    std::ostringstream s;
    s << "expedition33-graphics: atrous EnsureClonedLayout create_pipeline_layout failed"
      << " total_params=" << params.size()
      << " game_params=" << game_count
      << " src_layout=" << game_layout.handle;
    reshade::log::message(reshade::log::level::error, s.str().c_str());
    return false;
  }

  data->cloned_layout = new_layout;
  data->cloned_from_layout_handle = game_layout.handle;
  data->game_param_count = game_count;

  std::ostringstream msg;
  msg << "expedition33-graphics: atrous cloned compute layout (game_params="
      << game_count
      << " total_params=" << params.size()
      << " new=" << new_layout.handle
      << ")";
  reshade::log::message(reshade::log::level::info, msg.str().c_str());
  return true;
}

// Configure a RenderPass for one atrous dispatch under the cloned layout.
// Caller sets compute_shader (pipeline_subobjects), dispatch_group_counts,
// and revert_state_after_render BEFORE calling this (we don't touch the
// latter here so the caller controls the whole dispatch sequence).
//
// `srv_input` is the ping (t0, s100). `srv_isfast` is the IS-FAST noise
// texture (t1, s100). Both are bound on every pass â€” the shader chooses
// which to read from `t0,s100` vs the game's `t6,s0` (SpecularIndirect)
// based on the `input_source` push constant.
static void ConfigureAtrousPass(renodx::utils::render::RenderPass& pass,
                                AtrousDeviceData* data,
                                reshade::api::resource_view srv_input,
                                reshade::api::resource_view srv_isfast,
                                reshade::api::resource_view uav_output,
                                std::span<const float> push_constants_span) {
  pass.layout                    = data->cloned_layout;
  pass.generated_layout          = false;  // cloned layout owned by AtrousDeviceData
  pass.first_layout_param_index  = data->game_param_count;

  pass.shader_resource_slots     = renodx::utils::render::ShaderResourceSlots({srv_input, srv_isfast});
  pass.unordered_access_slots    = renodx::utils::render::UnorderedAccessSlots({uav_output});

  pass.push_constants.clear();
  // Key {slot=0, space=100} for the push_constants in our appended param.
  // RenderPass will call cmd_list->push_constants at layout_param =
  // first_layout_param_index + 2 (after the two push_descriptors params).
  pass.push_constants[{.slot = 0, .space = 100}] = push_constants_span;

  pass.auto_generate_descriptor_table_updates = true;
}

void OnAfterBilateral(reshade::api::command_list* cmd_list) {
  auto* device = cmd_list->get_device();
  auto* data = GetAtrousData(device);
  if (data == nullptr) return;

  // ===========================================================================
  // Multipass A-trous is currently DORMANT.
  // ===========================================================================
  // The pipeline plumbing (cloned root signature, ping texture, RenderPass
  // caches, descriptor walking) is preserved as a base for future multi-pass
  // experiments. The shader replacement (`0xFF71ABCD.cs_6_6.hlsl`) and the
  // shared kernel header (`atrous_kernel.hlsli`) are kept too.
  //
  // Eleven design iterations against single-pass + multi-pass A-trous (see
  // `project-docs/005_bilateral-atrous-rework`) failed to outperform the
  // simple linear-accumulation + log-luma color weight on the original
  // bilateral path (the `TOGGLE_USE_SUPERIOR_REFLECTION_FILTER` enhancement
  // in `0x88E6E1DB.cs_6_6.hlsl`). Single-pass was unstable; multi-pass
  // either lost too much detail or produced low-frequency boiling. We
  // shipped the simple version and disabled the kernel pipeline to keep
  // the option open for a future multi-pass approach.
  //
  // To re-enable, remove this early-return and reintroduce a toggle.
  return;
  // ===========================================================================

  // IS-FAST noise must be loaded â€” the injected pass shader requires it.
  // If it's not yet available (very first frames before texture creation
  // completed) we skip multipass for this frame; the inline pass-1 still
  // runs and the user sees the single-pass A-trous result.
  if (!fast_noise_created || fast_noise_srv.handle == 0u) return;

  // Recover the bilateral's compute layout + descriptor tables from the
  // snapshot taken at `on_inject` time (CaptureBilateralState). The live
  // `CommandListState` is unreliable here because `on_drawn` runs on a
  // deferred drain â€” the game may have already bound the next compute
  // shader, in which case live state points at a different layout.
  reshade::api::pipeline_layout game_layout = {0};
  std::vector<reshade::api::descriptor_table> game_tables;
  {
    const auto handle = reinterpret_cast<uint64_t>(cmd_list);
    std::lock_guard lock(bilateral_state_mutex);
    auto it = bilateral_state_per_cmd_list.find(handle);
    if (it != bilateral_state_per_cmd_list.end()) {
      game_layout = it->second.layout;
      game_tables = it->second.tables;
    }
  }
  if (game_layout.handle == 0u) {
    // No snapshot â€” fall back to live state (works when bilateral was the
    // most recently bound compute shader, which is the historical "launch
    // with toggle on" code path).
    const auto* state = renodx::utils::state::GetCurrentState(cmd_list);
    if (state == nullptr) return;
    game_layout = state->compute_pipeline_layout;
    game_tables = state->compute_descriptor_tables;
    if (game_layout.handle == 0u) return;
  }

  // Build (or reuse) our cloned root signature. We always do this even
  // when the multipass toggle is off so the cache is warm by the time
  // the user toggles ON. Otherwise we'd be hitting the cloning code
  // path for the first time at toggle-on, and any anomaly in the
  // current bilateral's pipeline-layout variant (e.g. a static-sampler
  // param requiring a downgrade) would surface as a runtime failure
  // instead of being absorbed silently here.
  if (!EnsureClonedLayout(device, data, game_layout)) return;

  // (Was: toggle gate for multipass A-trous. Removed when the feature
  // was retired â€” see the early-return at the top of this function. If
  // you re-enable, gate dispatching here.)

  // Resolve SpecularIndirect dimensions. We need the resource behind UE5's
  // u0 (RWSpecularIndirect) to size our ping texture and the dispatch grid.
  // Rather than peek at descriptor contents, walk the game's bindings via
  // the pipeline layout params + descriptor tables (tracked by the state
  // utility) until we land on a Texture2DArray UAV resource_view â€” that's
  // SpecularIndirect. If we can't find it, bail out cleanly.
  reshade::api::resource specular_resource = {0};
  reshade::api::format   specular_format   = reshade::api::format::unknown;
  uint32_t w = 0u, h = 0u;

  {
    auto* desc_data = renodx::utils::data::Get<renodx::utils::descriptor::DeviceData>(device);
    if (desc_data == nullptr) return;

    const bool walked_ok = renodx::utils::pipeline_layout::GetPipelineLayoutData(
        game_layout, [&](const auto& local_layout_data) {
      const auto& info = *local_layout_data;
      const auto& tables = game_tables;
      for (size_t param_index = 0;
           param_index < info.params.size() && specular_resource.handle == 0u;
           ++param_index) {
        if (param_index >= tables.size()) continue;
        const auto& param = info.params[param_index];
        if (param.type != reshade::api::pipeline_layout_param_type::descriptor_table) continue;
        const auto& table = tables[param_index];
        if (table.handle == 0u) continue;

        const uint32_t range_count = param.descriptor_table.count;
        const auto* ranges = param.descriptor_table.ranges;
        for (uint32_t j = 0; j < range_count && specular_resource.handle == 0u; ++j) {
          const auto& range = ranges[j];
          if (range.count == 0u || range.count == UINT32_MAX) continue;
          if (range.type != reshade::api::descriptor_type::texture_unordered_access_view) continue;
          if (range.dx_register_space != 0u) continue;
          if (range.dx_register_index != 0u) continue;  // UE5 RWSpecularIndirect at u0

          uint32_t base_offset = 0u;
          reshade::api::descriptor_heap heap = {0};
          device->get_descriptor_heap_offset(table, range.binding, 0, &heap, &base_offset);
          const std::shared_lock desc_lock(desc_data->mutex);
          auto heap_it = desc_data->heaps.find(heap.handle);
          if (heap_it == desc_data->heaps.end()) continue;
          const auto& heap_slots = heap_it->second;
          if (base_offset >= heap_slots.size()) continue;
          const auto& slot = heap_slots[base_offset];
          if (!slot.HasResourceView()) continue;

          specular_resource = renodx::utils::resource::GetResourceFromView(
              device, slot.resource_view);
          if (specular_resource.handle == 0u) continue;
          auto rdesc = renodx::utils::resource::GetResourceDesc(device, specular_resource);
          if (rdesc.type == reshade::api::resource_type::unknown) {
            specular_resource = {0};
            continue;
          }
          specular_format = rdesc.texture.format;
          w = rdesc.texture.width;
          h = rdesc.texture.height;
        }
      }
    });
    if (!walked_ok || specular_resource.handle == 0u) {
      if (!data->logged_miss) {
        reshade::log::message(reshade::log::level::warning,
            "expedition33-graphics: atrous couldn't resolve SpecularIndirect from game bindings");
        data->logged_miss = true;
      }
      return;
    }
  }

  CreateAtrousTextures(device, data, w, h, specular_format);
  if (!data->textures_created) return;

  if (!data->logged_first_run) {
    std::ostringstream s;
    s << "expedition33-graphics: atrous v2 first run"
      << " specular_res=" << specular_resource.handle
      << " format=" << static_cast<uint32_t>(specular_format)
      << " dims=" << w << "x" << h
      << " cloned_layout=" << data->cloned_layout.handle
      << " game_params=" << data->game_param_count;
    reshade::log::message(reshade::log::level::info, s.str().c_str());
    data->logged_first_run = true;
  }

  // Read the live frame_index from the cbuffer the host already updates
  // each frame (OnPresent â†’ SetFrameIndex). Keeps the IS-FAST temporal
  // slice in sync with the inline pass-1 and the rest of the pipeline.
  uint32_t live_frame_index = 0u;
  if (internal::host_shader_injection != nullptr) {
    uint32_t bits = expedition33_inject::GetBits(
        internal::host_shader_injection->graphics_inject.toggles_and_frame);
    live_frame_index = (bits >> EXPEDITION33_GRAPHICS_FRAME_INDEX_SHIFT)
                       & EXPEDITION33_GRAPHICS_FRAME_INDEX_MASK;
  }

  // Populate push constants. Per-pass `variance_attenuation` follows the
  // variance-contraction schedule documented in `atrous_kernel.hlsli` â€”
  // B3-spline N_eff ~ 9 effective taps means each pass contracts variance
  // by ~1/9. Pass 1 (inline) sees raw variance (1.0), pass 2 sees var/9,
  // pass 3 sees var/81. The shader uses the attenuated variance to drive
  // both the filter-strength gate (so most pixels passthrough on later
  // passes) AND the color sigma (narrower tolerance preserves detail).
  data->params_pass2.step_size            = 3u;
  data->params_pass2.input_source         = 0u;  // SpecularIndirect (t6, s0)
  data->params_pass2.output_target        = 0u;  // PingOutput     (u0, s100)
  data->params_pass2.pass_index           = 1u;  // pass 0 is inline; this is pass 1 of injected.
  data->params_pass2.rect_min_x           = 0u;
  data->params_pass2.rect_min_y           = 0u;
  data->params_pass2.rect_size_x          = w;
  data->params_pass2.rect_size_y          = h;
  data->params_pass2.frame_index          = live_frame_index;
  data->params_pass2.variance_attenuation = 9.0f;
  data->params_pass2._pad_0               = 0u;
  data->params_pass2._pad_1               = 0u;

  data->params_pass3                      = data->params_pass2;
  data->params_pass3.step_size            = 7u;
  data->params_pass3.input_source         = 1u;  // PingInput          (t0, s100)
  data->params_pass3.output_target        = 1u;  // RWSpecularIndirect (u0, s0)
  data->params_pass3.pass_index           = 2u;
  data->params_pass3.variance_attenuation = 81.0f;

  const auto params_span_pass2 = std::span<const float>(
      reinterpret_cast<const float*>(&data->params_pass2),
      sizeof(AtrousPushConstants) / sizeof(float));
  const auto params_span_pass3 = std::span<const float>(
      reinterpret_cast<const float*>(&data->params_pass3),
      sizeof(AtrousPushConstants) / sizeof(float));

  const uint32_t group_x = (w + 7u) / 8u;
  const uint32_t group_y = (h + 7u) / 8u;

  // Snapshot current state for restoration after our passes.
  const auto* current_state = renodx::utils::state::GetCurrentState(cmd_list);
  std::optional<renodx::utils::state::CommandListState> saved_state;
  if (current_state != nullptr) {
    saved_state.emplace(*current_state);
  }

  // Bind the game's compute descriptor tables under our cloned layout.
  // This sets up UE5's bindings at their native indices (0..N-1); our
  // appended params get populated per-pass via RenderPass::Render().
  //
  // Some game param indices may be sparse (e.g., a static-sampler param
  // that has no descriptor-table binding). Bind contiguous runs of
  // non-zero-handle tables so we don't push a zero handle into a slot,
  // which would either crash D3D12 or noisily clear bindings the game
  // still needed for the bilateral itself if we re-applied the saved
  // state later.
  for (uint32_t run_begin = 0u; run_begin < game_tables.size();) {
    if (game_tables[run_begin].handle == 0u) {
      ++run_begin;
      continue;
    }
    uint32_t run_end = run_begin + 1u;
    while (run_end < game_tables.size() && game_tables[run_end].handle != 0u) {
      ++run_end;
    }
    cmd_list->bind_descriptor_tables(
        reshade::api::shader_stage::all_compute,
        data->cloned_layout,
        run_begin,
        run_end - run_begin,
        game_tables.data() + run_begin);
    run_begin = run_end;
  }

  // SpecularIndirect was written by the bilateral as a UAV. Make those
  // writes visible to our SRV read (pass 2 reads it at t6) and also to
  // pass 3's UAV write-back (same resource, SIMULTANEOUS_ACCESS).
  cmd_list->barrier(specular_resource,
      reshade::api::resource_usage::unordered_access,
      reshade::api::resource_usage::unordered_access);

  // --- Pass 2: SpecularIndirect â†’ ping (step=3) ---
  data->pass2.pipeline_subobjects.compute_shader = __0xFF71ABCD;
  data->pass2.dispatch_group_counts              = std::make_tuple(group_x, group_y, 1u);
  data->pass2.revert_state_after_render          = false;
  ConfigureAtrousPass(data->pass2, data,
                      data->ping_srv,    // unused when input_source == 0 â€” shader reads t6 instead
                      fast_noise_srv,    // IS-FAST at t1, s100
                      data->ping_uav,    // our output
                      params_span_pass2);
  const bool ok2 = data->pass2.Render(cmd_list);

  // Ping writes must be visible to pass 3's SRV reads.
  cmd_list->barrier(data->ping_resource,
      reshade::api::resource_usage::unordered_access,
      reshade::api::resource_usage::unordered_access);

  // --- Pass 3: ping â†’ RWSpecularIndirect (step=7) ---
  data->pass3.pipeline_subobjects.compute_shader = __0xFF71ABCD;
  data->pass3.dispatch_group_counts              = std::make_tuple(group_x, group_y, 1u);
  data->pass3.revert_state_after_render          = false;
  ConfigureAtrousPass(data->pass3, data,
                      data->ping_srv,    // our input at t0,s100
                      fast_noise_srv,    // IS-FAST at t1, s100
                      data->ping_uav,    // unused when output_target == 1
                      params_span_pass3);
  const bool ok3 = data->pass3.Render(cmd_list);

  // Pass 3 wrote into SpecularIndirect (u0, s0). The barrier here is
  // conservative â€” makes our writes visible to whatever the next
  // dispatch/draw reads (usually the temporal reprojection CS). Without
  // this, the next shader could see ping-only or partially-updated data.
  cmd_list->barrier(specular_resource,
      reshade::api::resource_usage::unordered_access,
      reshade::api::resource_usage::unordered_access);

  // Restore the game's compute state (pipeline, layout, tables, etc.).
  if (saved_state.has_value()) {
    saved_state->Apply(cmd_list);
  }

  if (!data->logged_pass_result) {
    std::ostringstream s;
    s << "expedition33-graphics: atrous v2 pass Render results"
      << " pass2=" << ok2 << " (pipeline=" << data->pass2.pipeline.handle << ")"
      << " pass3=" << ok3 << " (pipeline=" << data->pass3.pipeline.handle << ")"
      << " desc_tables2=" << data->pass2.descriptor_tables.size()
      << " desc_tables3=" << data->pass3.descriptor_tables.size();
    reshade::log::message(reshade::log::level::info, s.str().c_str());
    data->logged_pass_result = true;
  }
}


// --- Settings ---
renodx::utils::settings::Settings settings = {
    new renodx::utils::settings::Setting{
        .key = "UseISFAST",
        .binding = &setting_use_isfast_noise,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 1.f,
        .label = "IS-FAST: Screen Probes",
        .section = "Lumen GI",
        .tooltip = "Toggle IS-FAST noise for Lumen screen probe compositing",
        .labels = {"Original Blue Noise", "IS-FAST"},
    },
    new renodx::utils::settings::Setting{
        .key = "DebugNoise",
        .binding = &setting_debug_noise,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 0.f,
        .label = "Debug: Screen Probes",
        .section = "Lumen GI",
        .tooltip = "Visualize noise in screen probe output",
        .labels = {"Off", "On"},
    },
    new renodx::utils::settings::Setting{
        .key = "UseISFASTDoF",
        .binding = &setting_use_isfast_dof,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 1.f,
        .label = "IS-FAST: Depth of Field",
        .section = "Depth of Field",
        .tooltip = "Toggle IS-FAST noise for DoF bokeh sampling",
        .labels = {"Original", "IS-FAST"},
    },
    new renodx::utils::settings::Setting{
        .key = "DebugDoF",
        .binding = &setting_debug_dof,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 0.f,
        .label = "Debug: Depth of Field",
        .section = "Depth of Field",
        .tooltip = "1=CoC zones (cyan/yellow), 2=Hair gaps (green=gap detected), 3=Background bokeh only, 4=Translucency alpha, 5=Raw gather output (shows noise pattern)",
        .labels = {"Off", "CoC Zones", "Hair Gaps", "BG Bokeh Only", "Translucency Alpha", "Raw Gather"},
    },
    new renodx::utils::settings::Setting{
        .key = "UseSinglePassDoF",
        .binding = &setting_use_singlepassdof_dof,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 1.f,
        .label = "DOF: SinglePass",
        .section = "Depth of Field",
        .tooltip = "Replace original depth of field with a single pass approach in the recombine shader to resolve disocclusion noise and issues with hair",
        .labels = {"Original", "Single Pass"},
    },
    new renodx::utils::settings::Setting{
        .key = "UseSmoothDoF",
        .binding = &setting_use_smooth_dof,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 1.f,
        .label = "Smooth: DoF Transitions",
        .section = "Depth of Field",
        .tooltip = "Smooth hard CoC thresholds to reduce 8x8 tile boundary stairsteps",
        .labels = {"Original (Hard)", "Smoothed"},
    },
    new renodx::utils::settings::Setting{
        .key = "DoFConfidenceThreshold",
        .binding = &setting_dof_confidence_threshold,
        .value_type = renodx::utils::settings::SettingValueType::FLOAT,
        .default_value = 5.f,
        .label = "Single-Pass: Confidence Threshold",
        .section = "Depth of Field",
        .tooltip = "UE5 bokeh weight at which the blend fully trusts UE5's tile-based gather. Lower = more single-pass (better hair, softer BG). Higher = more UE5 (sharper bokeh, more tile artifacts at hair).",
        .min = 2.f,
        .max = 16.f,
    },
    new renodx::utils::settings::Setting{
        .key = "UseISFASTShadows",
        .binding = &setting_use_isfast_shadows,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 1.f,
        .label = "IS-FAST: Shadows",
        .section = "Shadows",
        .tooltip = "Toggle IS-FAST noise for VSM shadow ray marching",
        .labels = {"Original", "IS-FAST"},
    },
    new renodx::utils::settings::Setting{
        .key = "DebugShadows",
        .binding = &setting_debug_shadows,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 0.f,
        .label = "Debug: Shadows",
        .section = "Shadows",
        .tooltip = "Red = zero read from IS-FAST SRV (binding failure)",
        .labels = {"Off", "On"},
    },
    new renodx::utils::settings::Setting{
        .key = "HairShadowBoostRays",
        .binding = &setting_hair_shadow_boost_rays,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 1.f,
        .label = "Hair shadow: boost ray count",
        .section = "Shadows",
        .tooltip = "Doubles SMRT ray count on hair pixels (shading model 7) to halve binomial speckle. Cost ~2x SMRT only on hair fragments.",
        .labels = {"Off", "On"},
    },
    new renodx::utils::settings::Setting{
        .key = "HairShadowTightenCone",
        .binding = &setting_hair_shadow_tighten_cone,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 1.f,
        .label = "Hair shadow: tighten penumbra",
        .section = "Shadows",
        .tooltip = "Narrows the SMRT source-radius cone on hair (Ã—0.5). Trades softness for less per-ray variance.",
        .labels = {"Off", "On"},
    },
    new renodx::utils::settings::Setting{
        .key = "UseISFASTFog",
        .binding = &setting_use_isfast_fog,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 1.f,
        .label = "IS-FAST: Volumetric Fog",
        .section = "Volumetric Fog",
        .tooltip = "Toggle IS-FAST noise for volumetric fog temporal jitter",
        .labels = {"Original LCG", "IS-FAST"},
    },
    new renodx::utils::settings::Setting{
        .key = "FogFilterMode",
        .binding = &setting_fog_filter_mode,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 1.f,
        .label = "Fog History Filter",
        .section = "Volumetric Fog",
        .tooltip = "Filter used for fog history reprojection. Higher quality = smoother fog, less banding.",
        .labels = {"Bilinear (Original)", "B-Spline Tricubic (Smooth)", "Catmull-Rom Tricubic (Sharp)", "Triquadratic (Fast)"},
    },
    new renodx::utils::settings::Setting{
        .key = "DebugFog",
        .binding = &setting_debug_fog,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 0.f,
        .label = "Debug: Volumetric Fog",
        .section = "Volumetric Fog",
        .tooltip = "1=Noise source (green=IS-FAST, red=binding fail, yellow=LCG), 2=Filter diff (brightness=correction magnitude, color=filter type)",
        .labels = {"Off", "Noise Source", "Filter Diff"},
    },
    new renodx::utils::settings::Setting{
        .key = "UseISFASTReflections",
        .binding = &setting_use_isfast_reflections,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 1.f,
        .label = "IS-FAST: Reflections",
        .section = "Lumen Reflections",
        .tooltip = "Toggle IS-FAST noise for Lumen reflection ray generation, tracing, and denoising",
        .labels = {"Original", "IS-FAST"},
    },
    new renodx::utils::settings::Setting{
        .key = "DebugReflections",
        .binding = &setting_debug_reflections,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 0.f,
        .label = "Debug: Reflections",
        .section = "Lumen Reflections",
        .tooltip = "Green = IS-FAST active, Red = SRV binding failure (zero read)",
        .labels = {"Off", "Noise Source"},
    },
    new renodx::utils::settings::Setting{
        .key = "UseSuperiorReflectionFilter",
        .binding = &setting_use_superior_reflection_filter,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 1.f,
        .label = "Bilateral: Tonemap-Free",
        .section = "Lumen Reflections",
        .tooltip = "Replace UE5's Karis tonemap bilateral with linear accumulation + color-range weight. Preserves highlights on reflections of bright surfaces (sky, lights). Works with both Original and A-trous spatial filters.",
        .labels = {"Original (Karis tonemap)", "Linear + Color-Aware"},
    },
    new renodx::utils::settings::Setting{
        .key = "UseSuperiorReflectionTemporal",
        .binding = &setting_use_superior_reflection_temporal,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 0.f,
        .label = "Temporal: Enhanced (EXPERIMENTAL)",
        .section = "Lumen Reflections",
        .tooltip = "EXPERIMENTAL, disabled by default. Percentile firefly clamp + Catmull-Rom history resample + hysteretic reprojection pick. Currently produces visible ringing on edges during camera motion and shimmer on bright surfaces. Investigation ongoing.",
        .labels = {"Original", "Enhanced"},
    },
    new renodx::utils::settings::Setting{
        .key = "UseReflectionLeanWidening",
        .binding = &setting_use_reflection_lean_widening,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 1.f,
        .label = "Ray Gen: Lobe Widening (EXPERIMENTAL)",
        .section = "Lumen Reflections",
        .tooltip = "EXPERIMENTAL, disabled by default. LEAN-style sub-pixel normal-variance widening of the GGX lobe in ReflectionGenerateRaysCS. Reduces temporal boil and edge crawling on rough surfaces and silhouettes by absorbing sub-pixel geometry variance into the sampling lobe. Slight bias: reflections become marginally less sharp at silhouettes in exchange for stability. ~0.05ms cost (4 extra GBuffer normal loads).",
        .labels = {"Off", "On (widen lobe by sub-pixel âˆ†normal)"},
    },
};

// --- Shader registration with ViewBinding ---

renodx::mods::shader::CustomShaders custom_shaders = {
    // 0xA9B4E725: LightScattering (Volumetric Fog) â€” IS-FAST noise at t0, space50
    {0xA9B4E725, {
        .crc32 = 0xA9B4E725,
        .code = __0xA9B4E725,
        .views = {
            {
                .type = reshade::api::descriptor_type::buffer_shader_resource_view,
                .slot = 0,
                .space = 50u,
                .get_view = &GetNoiseSRV,
            },
        },
    }},
    // 0xEA465E60: FinalIntegration (Fog Integration Dithering) â€” IS-FAST noise at t0, space50
    {0xEA465E60, {
        .crc32 = 0xEA465E60,
        .code = __0xEA465E60,
        .views = {
            {
                .type = reshade::api::descriptor_type::buffer_shader_resource_view,
                .slot = 0,
                .space = 50u,
                .get_view = &GetNoiseSRV,
            },
        },
    }},
    // 0xE28560FF: ExponentialPixelMain (Fog Apply + Upsample Jitter) â€” IS-FAST noise at t0, space50
    {0xE28560FF, {
        .crc32 = 0xE28560FF,
        .code = __0xE28560FF,
        .views = {
            {
                .type = reshade::api::descriptor_type::buffer_shader_resource_view,
                .slot = 0,
                .space = 50u,
                .get_view = &GetNoiseSRV,
            },
        },
    }},
    // 0xAD818E14: DoF GatherForeground â€” IS-FAST disk noise at t0, space50
    {0xAD818E14, {
        .crc32 = 0xAD818E14,
        .code = __0xAD818E14,
        .views = {
            {
                .type = reshade::api::descriptor_type::buffer_shader_resource_view,
                .slot = 0,
                .space = 50u,
                .get_view = &GetNoiseSRVDisk,
            },
        },
    }},
    // 0xDB158E50: DoF GatherBackground â€” IS-FAST disk noise at t0, space50
    {0xDB158E50, {
        .crc32 = 0xDB158E50,
        .code = __0xDB158E50,
        .views = {
            {
                .type = reshade::api::descriptor_type::buffer_shader_resource_view,
                .slot = 0,
                .space = 50u,
                .get_view = &GetNoiseSRVDisk,
            },
        },
    }},
    // 0xB25D54BC: DoF GatherVariant4 â€” IS-FAST disk noise at t0, space50
    {0xB25D54BC, {
        .crc32 = 0xB25D54BC,
        .code = __0xB25D54BC,
        .views = {
            {
                .type = reshade::api::descriptor_type::buffer_shader_resource_view,
                .slot = 0,
                .space = 50u,
                .get_view = &GetNoiseSRVDisk,
            },
        },
    }},
    // 0xD55A9AAC: DoF Postfilter â€” k-DOP variance clipping
    {0xD55A9AAC, {
        .crc32 = 0xD55A9AAC,
        .code = __0xD55A9AAC,
    }},
    // 0xC7D0BB80: DoF GatherRing
    {0xC7D0BB80, {
        .crc32 = 0xC7D0BB80,
        .code = __0xC7D0BB80,
    }},
    // 0xC6C3379F: DoF GatherVariant5 (scatter occlusion) â€” IS-FAST disk noise at t0, space50
    {0xC6C3379F, {
        .crc32 = 0xC6C3379F,
        .code = __0xC6C3379F,
        .views = {
            {
                .type = reshade::api::descriptor_type::buffer_shader_resource_view,
                .slot = 0,
                .space = 50u,
                .get_view = &GetNoiseSRVDisk,
            },
        },
    }},
    // 0xCAF10EB9: DoF Reduce (mip generation + scatter list build)
    {0xCAF10EB9, {
        .crc32 = 0xCAF10EB9,
        .code = __0xCAF10EB9,
    }},
    // 0x1F55F359: DoF Recombine â€” CoC smoothing + single-pass disc DoF with IS-FAST noise
    {0x1F55F359, {
        .crc32 = 0x1F55F359,
        .code = __0x1F55F359,
        .views = {
            {
                .type = reshade::api::descriptor_type::buffer_shader_resource_view,
                .slot = 0,       // t0 in space50 â€” IS-FAST noise texture
                .space = 50u,
                .get_view = &GetNoiseSRV,
            },
        },
    }},
    // TODO: 0xFCCD914D â€” Deferred light pixel shader (needs modified HLSL)
    // TODO: 0xC9A3A621 â€” ScreenProbeCompositeTracesWithScatterCS (needs modified HLSL)
    // 0x56C468C3: VSM Shadow Projection (directional) â€” IS-FAST noise at t0, space50
    {0x56C468C3, {
        .crc32 = 0x56C468C3,
        .code = __0x56C468C3,
        .views = {
            {
                .type = reshade::api::descriptor_type::buffer_shader_resource_view,
                .slot = 0,
                .space = 50u,
                .get_view = &GetNoiseSRV,
            },
        },
    }},
    // 0xC4720FE8: VSM Shadow Projection (local lights) â€” IS-FAST noise at t0, space50
    {0xC4720FE8, {
        .crc32 = 0xC4720FE8,
        .code = __0xC4720FE8,
        .views = {
            {
                .type = reshade::api::descriptor_type::buffer_shader_resource_view,
                .slot = 0,
                .space = 50u,
                .get_view = &GetNoiseSRV,
            },
        },
    }},
    // --- Lumen Reflections: IS-FAST noise at t0, space50 ---
    // 0xDC5A7A48: ReflectionGenerateRaysCS â€” ray direction importance sampling
    {0xDC5A7A48, {
        .crc32 = 0xDC5A7A48,
        .code = __0xDC5A7A48,
        .views = {
            {
                .type = reshade::api::descriptor_type::buffer_shader_resource_view,
                .slot = 0,
                .space = 50u,
                .get_view = &GetNoiseSRV,
            },
        },
    }},
    // 0xFF71CCB7: ReflectionResolveCS â€” spatial reconstruction jitter
    {0xFF71CCB7, {
        .crc32 = 0xFF71CCB7,
        .code = __0xFF71CCB7,
        .views = {
            {
                .type = reshade::api::descriptor_type::buffer_shader_resource_view,
                .slot = 0,
                .space = 50u,
                .get_view = &GetNoiseSRV,
            },
        },
    }},
    // 0x1873FC64: ReflectionTraceVoxelsCS â€” voxel trace dithering
    {0x1873FC64, {
        .crc32 = 0x1873FC64,
        .code = __0x1873FC64,
        .views = {
            {
                .type = reshade::api::descriptor_type::buffer_shader_resource_view,
                .slot = 0,
                .space = 50u,
                .get_view = &GetNoiseSRV,
            },
        },
    }},
    // 0x8A5C2B58: ReflectionTraceMeshSDFsCS â€” mesh SDF trace jitter
    {0x8A5C2B58, {
        .crc32 = 0x8A5C2B58,
        .code = __0x8A5C2B58,
        .views = {
            {
                .type = reshade::api::descriptor_type::buffer_shader_resource_view,
                .slot = 0,
                .space = 50u,
                .get_view = &GetNoiseSRV,
            },
        },
    }},
    // 0x88E6E1DB: ReflectionBilateralFilterCS â€” bilateral filter.
    // The framework bug that used to break combining `.on_drawn` with
    // `.views` (tmp/ON_DRAWN_DISPATCH_BUG.md) is fixed via the deferred
    // drain queue in `mods/shader.hpp`, so both are safe together now.
    //
    // `on_inject` runs synchronously before the dispatch, with the
    // bilateral's bindings still authoritative â€” we use it to snapshot
    // the bilateral's compute layout + descriptor tables so the deferred
    // `on_drawn` (which fires after the next command-list event) can
    // recover them. Without this snapshot, late-toggling multipass
    // captures whatever the game has bound NEXT, which often differs.
    {0x88E6E1DB, {
        .crc32 = 0x88E6E1DB,
        .code = __0x88E6E1DB,
        .on_inject = &CaptureBilateralState,
        .on_drawn  = &OnAfterBilateral,
        .views = {
            {
                .type = reshade::api::descriptor_type::buffer_shader_resource_view,
                .slot = 0,
                .space = 50u,
                .get_view = &GetNoiseSRV,
            },
        },
    }},
    // 0x628A2F0F: ReflectionTraceScreenTexturesCS â€” screen trace history rejection
    {0x628A2F0F, {
        .crc32 = 0x628A2F0F,
        .code = __0x628A2F0F,
        .views = {
            {
                .type = reshade::api::descriptor_type::buffer_shader_resource_view,
                .slot = 0,
                .space = 50u,
                .get_view = &GetNoiseSRV,
            },
        },
    }},
    // 0x8473BC79: ReflectionTemporalReprojectionCS â€” stochastic blend + clamp via IS-FAST
    {0x8473BC79, {
        .crc32 = 0x8473BC79,
        .code = __0x8473BC79,
        .views = {
            {
                .type = reshade::api::descriptor_type::buffer_shader_resource_view,
                .slot = 0,
                .space = 50u,
                .get_view = &GetNoiseSRV,
            },
        },
    }},
};

void OnInitDevice(reshade::api::device* device) {
  pending_device = device;
  renodx::utils::data::Create<AtrousDeviceData>(device);
}

void OnDestroyDevice(reshade::api::device* device) {
  DestroyFASTNoiseTexture(device);
  DestroyFASTNoiseDiskTexture(device);
  DestroyDofTextures(device);
  dof_hblur_pass.DestroyAll(device);
  dof_vblur_pass.DestroyAll(device);
  {
    std::lock_guard lock(scene_color_mutex);
    scene_color_srv_per_cmd_list.clear();
  }
  if (auto* atrous_data = GetAtrousData(device)) {
    // Pass 2/3 share the cloned layout â€” don't let RenderPass destroy it
    // (generated_layout stays false). We destroy the cloned layout once
    // here, after tearing down both pipelines via DestroyAll.
    atrous_data->pass2.DestroyAll(device);
    atrous_data->pass3.DestroyAll(device);
    if (atrous_data->cloned_layout.handle != 0u) {
      device->destroy_pipeline_layout(atrous_data->cloned_layout);
      atrous_data->cloned_layout = {0};
      atrous_data->cloned_from_layout_handle = 0u;
    }
    DestroyAtrousTextures(device, atrous_data);
  }
  renodx::utils::data::Delete<AtrousDeviceData>(device);
  pending_device = nullptr;
}

// Forward declarations for command-list reset/destroy handlers â€” clear
// the bilateral state snapshot keyed on this command list to avoid
// leaking entries across command-list reuse.
static void OnResetCommandList(reshade::api::command_list* cmd_list) {
  if (cmd_list == nullptr) return;
  const auto handle = reinterpret_cast<uint64_t>(cmd_list);
  std::lock_guard lock(bilateral_state_mutex);
  bilateral_state_per_cmd_list.erase(handle);
}

static void OnDestroyCommandList(reshade::api::command_list* cmd_list) {
  if (cmd_list == nullptr) return;
  const auto handle = reinterpret_cast<uint64_t>(cmd_list);
  std::lock_guard lock(bilateral_state_mutex);
  bilateral_state_per_cmd_list.erase(handle);
}

void OnPresent(reshade::api::command_queue*, reshade::api::swapchain*, const reshade::api::rect*, const reshade::api::rect*, uint32_t, const reshade::api::rect*) {
  static uint32_t frame_counter = 0u;
  frame_counter = (frame_counter + 1u) % 32u;
  if (internal::host_shader_injection != nullptr) {
    expedition33_inject::SetFrameIndex(*internal::host_shader_injection, frame_counter);
  }
  PackShaderInjection();
}

}  // namespace

// ============================================================================
// Public API
// ============================================================================

// One-time host wiring. Call from your addon's DllMain at DLL_PROCESS_ATTACH
// BEFORE any framework `Use(...)` call. This:
//   - captures pointers to the host's ShaderInjectData / settings / shaders;
//   - appends our settings into the host's settings vector;
//   - merges our shader replacements (with `.views` / `.on_drawn`) into the
//     host's CustomShaders map, overriding any earlier bare entries that
//     `__ALL_CUSTOM_SHADERS` may have inserted.
inline void Configure(const Config& config) {
  internal::current_config = config;
  internal::host_shader_injection = config.host_shader_injection;

  if (config.host_settings != nullptr) {
    for (auto* s : settings) config.host_settings->push_back(s);
  }
  if (config.host_custom_shaders != nullptr) {
    for (const auto& [hash, shader] : custom_shaders) {
      config.host_custom_shaders->insert_or_assign(hash, shader);
    }
  }
}

// Per-DllMain-reason hook. Mirrors framework `Use(fdw_reason)` shape.
// Registers our event handlers on attach, unregisters on detach, and forwards
// to any framework utilities we depend on (state/descriptor/pipeline-layout
// trackers + render-pass utilities). The host still owns its own call to
// `renodx::mods::shader::Use(...)` â€” we don't call it here because we'd
// double-register handlers if we did.
inline void Use(HMODULE h_module, DWORD fdw_reason) {
  switch (fdw_reason) {
    case DLL_PROCESS_ATTACH:
      s_module_handle = h_module;
      renodx::utils::descriptor::trace_descriptor_tables = true;
      reshade::register_event<reshade::addon_event::init_device>(OnInitDevice);
      reshade::register_event<reshade::addon_event::destroy_device>(OnDestroyDevice);
      reshade::register_event<reshade::addon_event::present>(OnPresent);
      reshade::register_event<reshade::addon_event::reset_command_list>(OnResetCommandList);
      reshade::register_event<reshade::addon_event::destroy_command_list>(OnDestroyCommandList);
      break;
    case DLL_PROCESS_DETACH:
      reshade::unregister_event<reshade::addon_event::init_device>(OnInitDevice);
      reshade::unregister_event<reshade::addon_event::destroy_device>(OnDestroyDevice);
      reshade::unregister_event<reshade::addon_event::present>(OnPresent);
      reshade::unregister_event<reshade::addon_event::reset_command_list>(OnResetCommandList);
      reshade::unregister_event<reshade::addon_event::destroy_command_list>(OnDestroyCommandList);
      {
        std::lock_guard lock(bilateral_state_mutex);
        bilateral_state_per_cmd_list.clear();
      }
      internal::host_shader_injection = nullptr;
      internal::current_config = {};
      break;
  }
  renodx::utils::pipeline_layout::Use(fdw_reason);
  renodx::utils::descriptor::Use(fdw_reason);
  renodx::utils::state::Use(fdw_reason);
  renodx::utils::resource::Use(fdw_reason);
  renodx::utils::settings::Use(fdw_reason, &settings);
}

}  // namespace expedition33_graphics

#endif  // SRC_CLAIROBSCUR_EXPEDITION33_GRAPHICS_HOST_HPP_
