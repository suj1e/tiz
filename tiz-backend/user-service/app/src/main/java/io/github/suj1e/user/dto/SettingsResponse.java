package io.github.suj1e.user.dto;

import io.github.suj1e.user.entity.UserSettings;

import java.time.Instant;

/**
 * 用户设置响应 DTO.
 */
public record SettingsResponse(
    String theme,
    Instant createdAt,
    Instant updatedAt
) {
    public static SettingsResponse from(UserSettings settings) {
        return new SettingsResponse(
            settings.getTheme(),
            settings.getCreatedAt(),
            settings.getUpdatedAt()
        );
    }
}
