package io.github.suj1e.user.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;

/**
 * 用户设置请求 DTO.
 */
public record SettingsRequest(
    @NotBlank(message = "主题不能为空")
    @Pattern(regexp = "^(light|dark|system)$", message = "主题必须是 light、dark 或 system")
    String theme
) {}
