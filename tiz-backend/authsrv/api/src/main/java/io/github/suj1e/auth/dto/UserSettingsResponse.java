package io.github.suj1e.auth.dto;

/**
 * 用户设置响应 DTO.
 */
public record UserSettingsResponse(
    String theme
) {
    /**
     * 默认设置.
     */
    public static UserSettingsResponse defaultSettings() {
        return new UserSettingsResponse("system");
    }
}
