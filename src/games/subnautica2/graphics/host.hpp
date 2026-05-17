/*
 * Copyright (C) 2026
 * SPDX-License-Identifier: MIT
 *
 * subnautica2-graphics — composable graphics-quality bundle for Subnautica 2.
 *
 * This is a header-only module. Include it from the host addon, then call:
 *
 *   subnautica2_graphics::Use(h_module, fdw_reason, &shader_injection);
 *   subnautica2_graphics::AppendSettings(host_settings_vector);
 *   subnautica2_graphics::AppendCustomShaders(host_custom_shaders_map);
 *   subnautica2_graphics::OnPresent();   // call from host's present hook
 *
 * The host owns the swapchain pipeline, the `ShaderInjectData` cbuffer,
 * and the settings UI. This bundle plugs in IS-FAST noise injection and
 * volumetric fog quality improvements, driven via the host's bit-packed
 * `graphics_inject.toggles_and_frame` / `graphics_inject.enums` fields.
 */

#ifndef SRC_SUBNAUTICA2_GRAPHICS_HOST_HPP_
#define SRC_SUBNAUTICA2_GRAPHICS_HOST_HPP_

#define ImTextureID ImU64
#define DEBUG_LEVEL_0

#include <atomic>
#include <cstring>
#include <mutex>
#include <sstream>
#include <string>
#include <vector>

#include <deps/imgui/imgui.h>
#include <embed/shaders.h>
#include <include/reshade.hpp>

#include "../../../mods/shader.hpp"
#include "../../../utils/settings.hpp"
#include "../shared.h"  // host's shared.h provides ShaderInjectData + bit-packing helpers
#include "../assets/noise/fast_noise_rg8.h"  // embedded IS-FAST noise data

namespace subnautica2_graphics {

// Public configuration. Hosts populate this once via `Configure(...)` from
// their DllMain at DLL_PROCESS_ATTACH, BEFORE any framework `Use(...)` call.
struct Config {
  ShaderInjectData* host_shader_injection = nullptr;
  renodx::utils::settings::Settings* host_settings = nullptr;
  renodx::mods::shader::CustomShaders* host_custom_shaders = nullptr;
};

namespace internal {

static Config current_config = {};
inline ShaderInjectData* host_shader_injection = nullptr;

}  // namespace internal

namespace {

// --- Individual setting floats (bound by the settings UI) ---
static float setting_use_isfast_noise = 1.0f;
static float setting_use_isfast_fog = 1.0f;
static float setting_fog_filter_mode = 2.0f;
static float setting_jittered_upscale = 1.0f;
static float setting_use_isfast_reflections = 1.0f;
static float setting_use_reflection_lean = 0.0f;
static float setting_debug_noise = 0.0f;
static float setting_debug_fog = 0.0f;

// Pack individual settings into the host's ShaderInjectData struct.
static void PackShaderInjection() {
  if (internal::host_shader_injection == nullptr) return;
  ShaderInjectData& data = *internal::host_shader_injection;

  // Pack toggles
  uint32_t toggle_bits = 0u;
  if (setting_use_isfast_noise > 0.5f) toggle_bits |= (1u << SUBNAUTICA2_GRAPHICS_TOGGLE_USE_ISFAST_NOISE);
  if (setting_use_isfast_fog > 0.5f) toggle_bits |= (1u << SUBNAUTICA2_GRAPHICS_TOGGLE_USE_ISFAST_FOG);
  if (setting_jittered_upscale > 0.5f) toggle_bits |= (1u << SUBNAUTICA2_GRAPHICS_TOGGLE_JITTERED_UPSCALE);
  if (setting_use_isfast_reflections > 0.5f) toggle_bits |= (1u << SUBNAUTICA2_GRAPHICS_TOGGLE_USE_ISFAST_REFLECTIONS);
  if (setting_use_reflection_lean > 0.5f) toggle_bits |= (1u << SUBNAUTICA2_GRAPHICS_TOGGLE_USE_REFLECTION_LEAN);

  // Pack frame index (incremented each present)
  static uint32_t frame_counter = 0u;
  uint32_t frame_index = frame_counter % 32u;
  toggle_bits |= ((frame_index & SUBNAUTICA2_GRAPHICS_FRAME_INDEX_MASK) << SUBNAUTICA2_GRAPHICS_FRAME_INDEX_SHIFT);

  // Pack fog filter mode
  uint32_t fog_mode = static_cast<uint32_t>(setting_fog_filter_mode + 0.5f);
  toggle_bits |= ((fog_mode & SUBNAUTICA2_GRAPHICS_FOG_FILTER_MODE_MASK) << SUBNAUTICA2_GRAPHICS_FOG_FILTER_MODE_SHIFT);

  std::memcpy(&data.graphics_inject.toggles_and_frame, &toggle_bits, sizeof(toggle_bits));

  // Pack enums (debug modes)
  uint32_t enum_bits = 0u;
  enum_bits |= ((static_cast<uint32_t>(setting_debug_noise + 0.5f) & 0xFu) << SUBNAUTICA2_GRAPHICS_ENUM_DEBUG_NOISE_SHIFT);
  enum_bits |= ((static_cast<uint32_t>(setting_debug_fog + 0.5f) & 0xFu) << SUBNAUTICA2_GRAPHICS_ENUM_DEBUG_FOG_SHIFT);
  std::memcpy(&data.graphics_inject.enums, &enum_bits, sizeof(enum_bits));

  frame_counter++;
}

// --- Buffer SRV state (NOT a texture; see below) ---
//
// We deliberately use a structured buffer — not a Texture2DArray — for
// the IS-FAST noise. The reason is mechanical, not stylistic:
//
// ReShade's D3D12 `cmd_list->push_descriptors` has two paths. For
// `buffer_shader_resource_view` (and CBV / UAV) it calls
// `SetGraphicsRootShaderResourceView(gpu_va)` — a root descriptor that
// resolves directly to a GPU virtual address with NO descriptor heap
// involvement. For `texture_shader_resource_view` it has to allocate
// in ReShade's transient view heap and call SetGraphicsRootDescriptorTable,
// which forces `SetDescriptorHeaps` to swap to ReShade's heap before the
// next draw. That swap invalidates any of the GAME's previously-bound
// root descriptor tables for the rest of the command list — they still
// point at offsets in the game's heap, but the GPU now resolves them
// against ReShade's transient heap, sampling whatever happened to be at
// that offset (often the noise descriptor we just copied).
//
// Drivers vary in how aggressively they validate this; on some hardware
// the corruption is visible as bright dots/particles all over the
// screen, on others it's invisible. Going through a buffer SRV avoids
// the heap swap entirely and is hardware-independent.
//
// See `project-docs/011_buffer-srv-injection-no-heap-swap/` for the full
// analysis.
reshade::api::resource fast_noise_resource = {0};
reshade::api::resource_view fast_noise_srv = {0};
std::atomic<bool> fast_noise_created{false};
reshade::api::device* texture_owner_device = nullptr;  // device that owns the buffer

static constexpr uint32_t NOISE_WIDTH = 128;
static constexpr uint32_t NOISE_HEIGHT = 128;
static constexpr uint32_t NOISE_SLICES = 32;
static constexpr uint32_t NOISE_SLICE_BYTES = NOISE_WIDTH * NOISE_HEIGHT * 2;  // RG8 source = 2 bytes/pixel
// In the GPU-side StructuredBuffer<float2> we expand each RG8 pixel to
// two 32-bit floats normalized [0,1]. 128*128*32 elements = 524288.
static constexpr uint32_t NOISE_TEXEL_COUNT = NOISE_WIDTH * NOISE_HEIGHT * NOISE_SLICES;
static constexpr uint32_t NOISE_BYTES_PER_ELEMENT = static_cast<uint32_t>(sizeof(float) * 2u);
static constexpr uint64_t NOISE_BUFFER_BYTES = static_cast<uint64_t>(NOISE_TEXEL_COUNT) * NOISE_BYTES_PER_ELEMENT;

static HMODULE s_module_handle = nullptr;
reshade::api::device* pending_device = nullptr;

// --- Buffer creation from embedded data ---

void CreateFASTNoiseTexture(reshade::api::device* device) {
  if (fast_noise_created) return;

  // Verify embedded data size
  static_assert(sizeof(__fast_noise_rg8_base) == NOISE_WIDTH * NOISE_HEIGHT * 2 * NOISE_SLICES,
                "Embedded noise data size mismatch");

  // Decode RG8 → float2 once at upload time. Cost is one ~4 MiB
  // allocation paid at addon attach; the GPU buffer holds the decoded
  // floats for the lifetime of the device.
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
        "subnautica2-graphics: Failed to create IS-FAST noise buffer resource");
    return;
  }

  // Raw (byte-address) buffer SRV. format = r32_typeless tells ReShade's
  // D3D12 backend to set D3D12_BUFFER_SRV_FLAG_RAW on the descriptor.
  // The shader declares ByteAddressBuffer to match.
  //
  // The descriptor itself is irrelevant for the root-SRV bind path —
  // ReShade routes `buffer_shader_resource_view` push_descriptors
  // through SetGraphicsRootShaderResourceView(gpu_va), which uses the
  // resource's GPU virtual address directly and never consults the CPU
  // descriptor. We still create a valid descriptor so ReShade's
  // tracking map records the view as a buffer (so
  // get_resource_view_gpu_address takes the buffer path and returns
  // resource->GetGPUVirtualAddress() rather than treating the view
  // handle as an opaque GPU address). Raw buffer SRVs work without a
  // StructureByteStride field, which is good because ReShade's API
  // doesn't expose one.
  //
  // For RAW: NumElements is the count of 4-byte words in the view.
  reshade::api::resource_view_desc srv_desc(
      reshade::api::format::r32_typeless,
      0u,                                                            // offset (in 4-byte words; 0 = start)
      static_cast<uint64_t>(NOISE_BUFFER_BYTES / sizeof(uint32_t))); // size (in 4-byte words)

  if (!device->create_resource_view(fast_noise_resource,
          reshade::api::resource_usage::shader_resource, srv_desc, &fast_noise_srv)) {
    reshade::log::message(reshade::log::level::error,
        "subnautica2-graphics: Failed to create SRV for IS-FAST noise buffer");
    device->destroy_resource(fast_noise_resource);
    fast_noise_resource = {0};
    return;
  }

  fast_noise_created = true;
  texture_owner_device = device;
  reshade::log::message(reshade::log::level::info,
      "subnautica2-graphics: IS-FAST noise buffer (ByteAddressBuffer, 128x128x32 float2) "
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
  texture_owner_device = nullptr;
}

// --- ViewBinding get_view callback ---
reshade::api::resource_view GetNoiseSRV(reshade::api::command_list* cmd_list) {
  if (!fast_noise_created) {
    static std::mutex creation_mutex;
    std::lock_guard lock(creation_mutex);
    if (!fast_noise_created) {  // double-check after lock
      reshade::api::device* device = cmd_list ? cmd_list->get_device() : pending_device;
      if (device) {
        pending_device = device;
        CreateFASTNoiseTexture(device);
      }
    }
  }
  return fast_noise_srv;
}

}  // anonymous namespace

// ============================================================================
// Public API
// ============================================================================

inline void Configure(const Config& config) {
  internal::current_config = config;
  internal::host_shader_injection = config.host_shader_injection;
}

inline void AppendSettings(renodx::utils::settings::Settings& host_settings) {
  host_settings.push_back(new renodx::utils::settings::Setting{
      .key = "GraphicsISFASTNoise",
      .binding = &setting_use_isfast_noise,
      .value_type = renodx::utils::settings::SettingValueType::BOOLEAN,
      .default_value = 1.f,
      .label = "IS-FAST Noise (Volumetrics)",
      .section = "Volumetrics",
      .tooltip = "Replaces InterleavedGradientNoise with IS-FAST blue noise for volumetric fog",
      .labels = {"Off", "On"},
  });
  host_settings.push_back(new renodx::utils::settings::Setting{
      .key = "GraphicsISFASTFog",
      .binding = &setting_use_isfast_fog,
      .value_type = renodx::utils::settings::SettingValueType::BOOLEAN,
      .default_value = 1.f,
      .label = "IS-FAST Fog Dithering",
      .section = "Volumetrics",
      .tooltip = "Uses IS-FAST noise for volumetric fog ray marching dither",
      .labels = {"Off", "On"},
  });
  host_settings.push_back(new renodx::utils::settings::Setting{
      .key = "GraphicsFogFilterMode",
      .binding = &setting_fog_filter_mode,
      .value_type = renodx::utils::settings::SettingValueType::INTEGER,
      .default_value = 1.f,
      .label = "Fog History Filter",
      .section = "Volumetrics",
      .tooltip = "Filter mode for volumetric fog temporal reprojection",
      .labels = {"Bilinear", "B-Spline Tricubic", "Catmull-Rom Tricubic", "Triquadratic B-Spline"},
  });
  host_settings.push_back(new renodx::utils::settings::Setting{
      .key = "GraphicsJitteredUpscale",
      .binding = &setting_jittered_upscale,
      .value_type = renodx::utils::settings::SettingValueType::BOOLEAN,
      .default_value = 1.f,
      .label = "Jittered Fog Upscale",
      .section = "Volumetrics",
      .tooltip = "Adds sub-pixel jitter to the half-res fog bilateral upscale for temporal super-resolution",
      .labels = {"Off", "On"},
  });
  host_settings.push_back(new renodx::utils::settings::Setting{
      .key = "GraphicsDebugNoise",
      .binding = &setting_debug_noise,
      .value_type = renodx::utils::settings::SettingValueType::INTEGER,
      .default_value = 0.f,
      .label = "Debug: Noise",
      .section = "Volumetrics",
      .tooltip = "Visualize noise pattern",
      .labels = {"Off", "Show Pattern"},
  });
  host_settings.push_back(new renodx::utils::settings::Setting{
      .key = "GraphicsISFASTReflections",
      .binding = &setting_use_isfast_reflections,
      .value_type = renodx::utils::settings::SettingValueType::BOOLEAN,
      .default_value = 1.f,
      .label = "IS-FAST Noise (Reflections)",
      .section = "Reflections",
      .tooltip = "Replaces BlueNoise/IGN with IS-FAST blue noise in Lumen reflection shaders",
      .labels = {"Off", "On"},
  });
  host_settings.push_back(new renodx::utils::settings::Setting{
      .key = "GraphicsReflectionLEAN",
      .binding = &setting_use_reflection_lean,
      .value_type = renodx::utils::settings::SettingValueType::BOOLEAN,
      .default_value = 0.f,
      .label = "LEAN Lobe Widening (Reflections)",
      .section = "Reflections",
      .tooltip = "Widens GGX lobe by sub-pixel normal variance to reduce temporal boil. Experimental.",
      .labels = {"Off", "On"},
  });
}

inline void AppendCustomShaders(renodx::mods::shader::CustomShaders& host_custom_shaders) {
  // All four IS-FAST noise consumers use a `buffer_shader_resource_view`
  // (StructuredBuffer<float2>) rather than a typed texture SRV. This
  // routes ReShade's push_descriptors through SetGraphicsRootShaderResourceView
  // (root descriptor → GPU virtual address) instead of through a
  // descriptor table allocated in ReShade's transient view heap. The
  // texture path corrupts the game's previously-bound root descriptor
  // tables on some drivers because it forces a SetDescriptorHeaps swap
  // before the next draw. See `project-docs/011_buffer-srv-injection-no-heap-swap/`
  // and `tmp/DESCRIPTOR_TABLE_BLEED_INVESTIGATION.md`.

  // Volumetrics fog composite shader with IS-FAST noise injection
  host_custom_shaders[0x0930DD4E] = {
      .crc32 = 0x0930DD4E,
      .code = __0x0930DD4E,
      .views = {
          {
              .type = reshade::api::descriptor_type::buffer_shader_resource_view,
              .slot = 0,
              .space = 50u,
              .get_view = &GetNoiseSRV,
          },
      },
  };

  // LightScatteringCS — IS-FAST jitter + tricubic history filter
  host_custom_shaders[0xD1F85C42] = {
      .crc32 = 0xD1F85C42,
      .code = __0xD1F85C42,
      .views = {
          {
              .type = reshade::api::descriptor_type::buffer_shader_resource_view,
              .slot = 0,
              .space = 50u,
              .get_view = &GetNoiseSRV,
          },
      },
  };

  // UWEFogReconstructCS — IS-FAST jitter replaces 3D blue noise (8→32 temporal phases)
  host_custom_shaders[0xF996B96B] = {
      .crc32 = 0xF996B96B,
      .code = __0xF996B96B,
      .views = {
          {
              .type = reshade::api::descriptor_type::buffer_shader_resource_view,
              .slot = 0,
              .space = 50u,
              .get_view = &GetNoiseSRV,
          },
      },
  };

  // ReflectionGenerateRaysCS — IS-FAST GGX jitter + LEAN lobe widening
  host_custom_shaders[0xC55C32A6] = {
      .crc32 = 0xC55C32A6,
      .code = __0xC55C32A6,
      .views = {
          {
              .type = reshade::api::descriptor_type::buffer_shader_resource_view,
              .slot = 0,
              .space = 50u,
              .get_view = &GetNoiseSRV,
          },
      },
  };
}

inline void OnPresent() {
  PackShaderInjection();
}

inline void OnInitDevice(reshade::api::device* device) {
  pending_device = device;
}

inline void OnDestroyDevice(reshade::api::device* device) {
  if (fast_noise_created && device == texture_owner_device) {
    DestroyFASTNoiseTexture(device);
  }
  if (device == pending_device) {
    pending_device = nullptr;
  }
}

inline void Use(HMODULE h_module, DWORD fdw_reason, ShaderInjectData* shader_injection) {
  switch (fdw_reason) {
    case DLL_PROCESS_ATTACH:
      s_module_handle = h_module;
      internal::host_shader_injection = shader_injection;
      reshade::register_event<reshade::addon_event::init_device>(OnInitDevice);
      reshade::register_event<reshade::addon_event::destroy_device>(OnDestroyDevice);
      break;
    case DLL_PROCESS_DETACH:
      reshade::unregister_event<reshade::addon_event::init_device>(OnInitDevice);
      reshade::unregister_event<reshade::addon_event::destroy_device>(OnDestroyDevice);
      internal::host_shader_injection = nullptr;
      break;
  }
}

}  // namespace subnautica2_graphics

#endif  // SRC_SUBNAUTICA2_GRAPHICS_HOST_HPP_
