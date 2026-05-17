/*
 * Copyright (C) 2024 Carlos Lopez
 * SPDX-License-Identifier: MIT
 */

#define ImTextureID ImU64
#define DEBUG_LEVEL_1

#include <deps/imgui/imgui.h>
#include <embed/shaders.h>
#include <include/reshade.hpp>

#include "../../mods/shader.hpp"
#include "../../mods/swapchain.hpp"
#include "../../utils/date.hpp"
#include "../../utils/path.hpp"
#include "../../utils/platform.hpp"
#include "../../utils/random.hpp"
#include "../../utils/settings.hpp"
#include "../../utils/shader.hpp"
#include "../../utils/swapchain.hpp"
#include "./shared.h"
#include "./graphics/host.hpp"

namespace {

renodx::mods::shader::CustomShaders custom_shaders = {__ALL_CUSTOM_SHADERS};

ShaderInjectData shader_injection;

// --- Staging variables for settings UI (packed into shader_injection on present) ---
struct StagingSettings {
  float tone_map_type = 1.f;
  float peak_white_nits = 1000.f;
  float diffuse_white_nits = 203.f;
  float graphics_white_nits = 203.f;
  float gamma_correction = 1.f;
  float gamma_correction_ui = 1.f;
  float tone_map_scaling = 1.f;
  float blend_factor = 0.5f;
  float tone_map_exposure = 1.f;
  float tone_map_highlights = 1.f;
  float tone_map_shadows = 1.f;
  float tone_map_contrast = 1.f;
  float tone_map_saturation = 1.f;
  float tone_map_highlight_saturation = 1.f;
  float tone_map_blowout = 0.f;
  float tone_map_flare = 0.f;
  float custom_lut_strength = 1.f;
  float tm_under_ui = 1.f;
  float custom_sharpness = 0.f;
  float custom_random = 0.f;
  // Fixed defaults (not exposed in UI)
  float tone_map_hue_correction_type = 0.f;
  float tone_map_hue_correction = 0.f;
  float tone_map_per_ch_peak = 5.f;
  float tone_map_hue_shift = 0.f;
  float tone_map_chroma_correct_blowout = 0.f;
  float override_black_clip = 0.f;
  float custom_grain_type = 0.f;
  float custom_grain_strength = 0.f;
  float processing_path = 0.f;
  float processing_use_scrgb = 0.f;
  float custom_lut_scaling = 0.f;
  float custom_lut_gamut_restoration = 0.f;
  float fx_upgrade_render = 1.f;
} staging;

// Pack staging settings into the shader_injection struct
void PackShaderInjection() {
  using namespace subnautica2_inject;

  // Full-precision nits
  shader_injection.peak_white_nits = staging.peak_white_nits;
  shader_injection.diffuse_white_nits = staging.diffuse_white_nits;
  shader_injection.graphics_white_nits = staging.graphics_white_nits;

  // Bit-packed flags
  PackHdrFlags(shader_injection,
               static_cast<uint32_t>(staging.tone_map_type + 0.5f),
               staging.gamma_correction > 0.5f,
               staging.gamma_correction_ui > 0.5f,
               staging.tone_map_hue_correction_type > 0.5f,
               staging.custom_grain_type > 0.5f,
               staging.tm_under_ui > 0.5f,
               staging.processing_path > 0.5f,
               staging.processing_use_scrgb > 0.5f,
               staging.tone_map_scaling > 0.5f,
               staging.custom_lut_scaling > 0.5f,
               staging.custom_lut_gamut_restoration > 0.5f,
               staging.override_black_clip > 0.5f);

  // f16x2 packed pairs
  PackF16Pair(shader_injection.packed_exposure_highlights, staging.tone_map_exposure, staging.tone_map_highlights);
  PackF16Pair(shader_injection.packed_shadows_contrast, staging.tone_map_shadows, staging.tone_map_contrast);
  PackF16Pair(shader_injection.packed_saturation_highlightsat, staging.tone_map_saturation, staging.tone_map_highlight_saturation);
  PackF16Pair(shader_injection.packed_blowout_flare, staging.tone_map_blowout, staging.tone_map_flare);
  PackF16Pair(shader_injection.packed_lut_perch, staging.custom_lut_strength, staging.tone_map_per_ch_peak);
  PackF16Pair(shader_injection.packed_hue_hueshift, staging.tone_map_hue_correction, staging.tone_map_hue_shift);
  PackF16Pair(shader_injection.packed_chroma_blackclip, staging.tone_map_chroma_correct_blowout, staging.override_black_clip);
  PackF16Pair(shader_injection.packed_grain_random, staging.custom_grain_strength, staging.custom_random);
  PackF16Pair(shader_injection.packed_sharpness_blend, staging.custom_sharpness, staging.blend_factor);
}

renodx::utils::settings::Settings settings = {
    new renodx::utils::settings::Setting{
        .key = "ToneMapType",
        .binding = &staging.tone_map_type,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 1.f,
        .can_reset = false,
        .label = "Tone Mapper",
        .section = "Tone Mapping",
        .tooltip = "Sets the tone mapper type",
        .labels = {"UE Vanilla (SDR)", "UE Filmic Extended (HDR)"},
    },

    new renodx::utils::settings::Setting{
        .key = "ToneMapPeakNits",
        .binding = &staging.peak_white_nits,
        .default_value = 1000.f,
        .can_reset = false,
        .label = "Peak Brightness",
        .section = "Tone Mapping",
        .tooltip = "Sets the value of peak white in nits",
        .min = 48.f,
        .max = 4000.f,
        .is_enabled = []() { return staging.tone_map_type == 1.f; },
    },

    new renodx::utils::settings::Setting{
        .key = "ToneMapGameNits",
        .binding = &staging.diffuse_white_nits,
        .default_value = 203.f,
        .label = "Game Brightness",
        .section = "Tone Mapping",
        .tooltip = "Sets the value of 100% white in nits",
        .min = 48.f,
        .max = 500.f,
    },

    new renodx::utils::settings::Setting{
        .key = "ToneMapUINits",
        .binding = &staging.graphics_white_nits,
        .default_value = 203.f,
        .label = "UI Brightness",
        .section = "Tone Mapping",
        .tooltip = "Sets the brightness of UI and HUD elements in nits",
        .min = 48.f,
        .max = 500.f,
    },

    new renodx::utils::settings::Setting{
        .key = "ToneMapGammaCorrection",
        .binding = &staging.gamma_correction,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 1.f,
        .label = "SDR EOTF Emulation",
        .section = "Tone Mapping",
        .tooltip = "Emulates a 2.2 EOTF",
        .labels = {"Off", "2.2"},
    },

    new renodx::utils::settings::Setting{
        .key = "ToneMapScaling",
        .binding = &staging.tone_map_scaling,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 1.f,
        .label = "Tonemap Scaling",
        .section = "Tone Mapping",
        .labels = {"Max Channel", "LMS"},
        .is_enabled = []() { return staging.tone_map_type == 1.f; },
    },

    new renodx::utils::settings::Setting{
        .key = "BlendFactor",
        .binding = &staging.blend_factor,
        .default_value = 50.f,
        .label = "Blend Factor",
        .section = "Tone Mapping",
        .min = 0.f,
        .max = 100.f,
        .is_enabled = []() { return staging.tone_map_type == 1.f; },
        .parse = [](float value) { return value * 0.01f; },
    },

    new renodx::utils::settings::Setting{
        .key = "ColorGradeExposure",
        .binding = &staging.tone_map_exposure,
        .default_value = 1.f,
        .label = "Exposure",
        .section = "Color Grading",
        .max = 2.f,
        .format = "%.2f",
        .is_enabled = []() { return staging.tone_map_type != 0; },
    },
    new renodx::utils::settings::Setting{
        .key = "ColorGradeHighlights",
        .binding = &staging.tone_map_highlights,
        .default_value = 50.f,
        .label = "Highlights",
        .section = "Color Grading",
        .max = 100.f,
        .is_enabled = []() { return staging.tone_map_type != 0; },
        .parse = [](float value) { return value * 0.02f; },
    },
    new renodx::utils::settings::Setting{
        .key = "ColorGradeShadows",
        .binding = &staging.tone_map_shadows,
        .default_value = 50.f,
        .label = "Shadows",
        .section = "Color Grading",
        .max = 100.f,
        .is_enabled = []() { return staging.tone_map_type != 0; },
        .parse = [](float value) { return value * 0.02f; },
    },
    new renodx::utils::settings::Setting{
        .key = "ColorGradeContrast",
        .binding = &staging.tone_map_contrast,
        .default_value = 50.f,
        .label = "Contrast",
        .section = "Color Grading",
        .max = 100.f,
        .is_enabled = []() { return staging.tone_map_type != 0; },
        .parse = [](float value) { return value * 0.02f; },
    },
    new renodx::utils::settings::Setting{
        .key = "ColorGradeSaturation",
        .binding = &staging.tone_map_saturation,
        .default_value = 50.f,
        .label = "Saturation",
        .section = "Color Grading",
        .max = 100.f,
        .is_enabled = []() { return staging.tone_map_type != 0; },
        .parse = [](float value) { return value * 0.02f; },
    },
    new renodx::utils::settings::Setting{
        .key = "ColorGradeHighlightSaturation",
        .binding = &staging.tone_map_highlight_saturation,
        .default_value = 50.f,
        .label = "Highlight Saturation",
        .section = "Color Grading",
        .max = 100.f,
        .is_enabled = []() { return staging.tone_map_type != 0; },
        .parse = [](float value) { return value * 0.02f; },
    },
    new renodx::utils::settings::Setting{
        .key = "ColorGradeBlowout",
        .binding = &staging.tone_map_blowout,
        .default_value = 0.f,
        .label = "Dechroma",
        .section = "Color Grading",
        .max = 100.f,
        .is_enabled = []() { return staging.tone_map_type != 0; },
        .parse = [](float value) { return value * 0.01f; },
    },
    new renodx::utils::settings::Setting{
        .key = "ColorGradeFlare",
        .binding = &staging.tone_map_flare,
        .default_value = 0.f,
        .label = "Flare",
        .section = "Color Grading",
        .max = 100.f,
        .is_enabled = []() { return staging.tone_map_type != 0; },
        .parse = [](float value) { return value * 0.02f; },
    },
    new renodx::utils::settings::Setting{
        .key = "ColorGradeLUTStrength",
        .binding = &staging.custom_lut_strength,
        .default_value = 100.f,
        .label = "LUT Strength",
        .section = "Color Grading",
        .max = 100.f,
        .is_enabled = []() { return staging.tone_map_type != 0; },
        .parse = [](float value) { return value * 0.01f; },
    },

    new renodx::utils::settings::Setting{
        .key = "TonemapUnderUI",
        .binding = &staging.tm_under_ui,
        .value_type = renodx::utils::settings::SettingValueType::BOOLEAN,
        .default_value = 1.f,
        .label = "Tonemap Under UI",
        .section = "Effects",
        .labels = {"Off", "On"},
        .is_enabled = []() { return staging.tone_map_type != 0; },
    },
    new renodx::utils::settings::Setting{
        .key = "UIGammaCorrection",
        .binding = &staging.gamma_correction_ui,
        .value_type = renodx::utils::settings::SettingValueType::BOOLEAN,
        .default_value = 1.f,
        .label = "UI SDR EOTF Emulation",
        .section = "Effects",
        .labels = {"Off", "2.2"},
        .is_enabled = []() { return staging.tone_map_type != 0; },
    },
    new renodx::utils::settings::Setting{
        .key = "FxSharpening",
        .binding = &staging.custom_sharpness,
        .default_value = 0.f,
        .label = "RCAS Sharpening",
        .section = "Effects",
        .is_enabled = []() { return staging.tone_map_type != 0; },
        .parse = [](float value) { return value == 0 ? 0.f : exp2(-(1.f - (value * 0.01f))); },
    },
    new renodx::utils::settings::Setting{
        .key = "FxUpgradeRender",
        .binding = &staging.fx_upgrade_render,
        .value_type = renodx::utils::settings::SettingValueType::BOOLEAN,
        .default_value = 0.f,
        .label = "Upgrade Render Precision (DON'T USE WITH AMD)",
        .section = "Effects",
        .tooltip = "Upgrades R11G11B10 render targets to R16G16B16A16F (reduces fog banding) - won't work on AMD.",
        .labels = {"Off", "On"},
    },

    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::TEXT,
        .label = std::string("Build: ") + renodx::utils::date::ISO_DATE_TIME,
        .section = "About",
    },
};

// Append graphics-quality bundle settings
struct GraphicsSettingsInit {
  GraphicsSettingsInit() { subnautica2_graphics::AppendSettings(settings); }
};
static GraphicsSettingsInit graphics_settings_init;

// Append graphics-quality bundle custom shaders (with ViewBindings for IS-FAST noise)
struct GraphicsShadersInit {
  GraphicsShadersInit() { subnautica2_graphics::AppendCustomShaders(custom_shaders); }
};
static GraphicsShadersInit graphics_shaders_init;

void OnPresetOff() {
  renodx::utils::settings::UpdateSettings({
      {"ToneMapType", 0.f},
      {"ToneMapPeakNits", 203.f},
      {"ToneMapGameNits", 203.f},
      {"ToneMapUINits", 203.f},
      {"ToneMapGammaCorrection", 0.f},
      {"UIGammaCorrection", 0.f},
      {"ColorGradeExposure", 1.f},
      {"ColorGradeHighlights", 50.f},
      {"ColorGradeShadows", 50.f},
      {"ColorGradeContrast", 50.f},
      {"ColorGradeSaturation", 50.f},
      {"ColorGradeHighlightSaturation", 50.f},
      {"ColorGradeBlowout", 0.f},
      {"ColorGradeFlare", 0.f},
      {"ColorGradeLUTStrength", 100.f},
  });
}

bool fired_on_init_swapchain = false;

void OnInitSwapchain(reshade::api::swapchain* swapchain, bool resize) {
  if (fired_on_init_swapchain) return;
  auto peak = renodx::utils::swapchain::GetPeakNits(swapchain);
  if (peak.has_value()) {
    settings[1]->default_value = peak.value();
    settings[1]->can_reset = true;
    fired_on_init_swapchain = true;
  }
}

void OnPresent(reshade::api::command_queue*, reshade::api::swapchain*,
               const reshade::api::rect*, const reshade::api::rect*,
               uint32_t, const reshade::api::rect*) {
  PackShaderInjection();
  subnautica2_graphics::OnPresent();
}

bool initialized = false;

}  // namespace

extern "C" __declspec(dllexport) constexpr const char* NAME = "RenoDX";
extern "C" __declspec(dllexport) constexpr const char* DESCRIPTION = "RenoDX for Subnautica 2";

BOOL APIENTRY DllMain(HMODULE h_module, DWORD fdw_reason, LPVOID lpv_reserved) {
  switch (fdw_reason) {
    case DLL_PROCESS_ATTACH:
      if (!reshade::register_addon(h_module)) return FALSE;

      renodx::utils::settings::Use(fdw_reason, &settings, &OnPresetOff);

      reshade::register_event<reshade::addon_event::init_swapchain>(OnInitSwapchain);
      reshade::register_event<reshade::addon_event::present>(OnPresent);

      renodx::mods::shader::on_create_pipeline_layout = [](auto, auto params) {
        return (params.size() < 20);
      };

      if (!initialized) {
        renodx::mods::shader::expected_constant_buffer_index = 13;
        renodx::mods::shader::expected_constant_buffer_space = 50;
        renodx::mods::shader::allow_multiple_push_constants = true;
        renodx::mods::shader::force_pipeline_cloning = true;

        renodx::mods::swapchain::expected_constant_buffer_index = 13;
        renodx::mods::swapchain::expected_constant_buffer_space = 50;

        renodx::mods::swapchain::use_resource_cloning = true;
        renodx::mods::swapchain::use_resize_buffer = true;
        renodx::mods::swapchain::set_color_space = false;
        renodx::mods::swapchain::force_borderless = false;
        renodx::mods::swapchain::prevent_full_screen = false;
        renodx::mods::swapchain::force_screen_tearing = false;
        renodx::mods::swapchain::SetUseHDR10(true);

        // Upgrade the 32x32x32 LUT texture to float16
        renodx::mods::swapchain::swap_chain_upgrade_targets.push_back({
            .old_format = reshade::api::format::r10g10b10a2_unorm,
            .new_format = reshade::api::format::r16g16b16a16_float,
            .dimensions = {.width = 32, .height = 32, .depth = 32},
            .resource_tag = 1.f,
        });

        // Upgrade R11G11B10 render targets to float16 — eliminates fog banding
        // Note: may have issues on AMD GPUs — FxUpgradeRender setting allows disabling
        if (renodx::utils::settings::FindSetting("FxUpgradeRender")->GetValue() > 0.5f) {
          renodx::mods::swapchain::swap_chain_upgrade_targets.push_back({
              .old_format = reshade::api::format::r11g11b10_float,
              .new_format = reshade::api::format::r16g16b16a16_float,
              .ignore_size = true,
              .use_resource_view_cloning = true,
          });
        }

        staging.processing_path = 0.f;

        initialized = true;
      }
      renodx::utils::random::binds.push_back(&staging.custom_random);

      break;
    case DLL_PROCESS_DETACH:
      reshade::unregister_event<reshade::addon_event::init_swapchain>(OnInitSwapchain);
      reshade::unregister_event<reshade::addon_event::present>(OnPresent);
      break;
  }

  renodx::utils::random::Use(fdw_reason);
  renodx::mods::swapchain::Use(fdw_reason, &shader_injection);
  renodx::mods::shader::Use(fdw_reason, custom_shaders, &shader_injection);
  subnautica2_graphics::Use(h_module, fdw_reason, &shader_injection);

  if (fdw_reason == DLL_PROCESS_ATTACH) {
    std::stringstream s;
    s << "subnautica2::DllMain(post-Use: ";
    s << "use_resource_cloning=" << (renodx::mods::swapchain::use_resource_cloning ? "true" : "false");
    s << ", targets=" << renodx::mods::swapchain::resource_upgrade_infos.size();
    s << ")";
    reshade::log::message(reshade::log::level::info, s.str().c_str());
  }

  if (fdw_reason == DLL_PROCESS_DETACH) {
    reshade::unregister_addon(h_module);
  }

  return TRUE;
}
