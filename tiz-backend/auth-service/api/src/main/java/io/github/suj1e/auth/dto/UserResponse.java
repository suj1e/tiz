package io.github.suj1e.auth.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

import java.time.Instant;
import java.util.UUID;

/**
 * 用户响应 DTO.
 */
public record UserResponse(
    UUID id,
    String email,
    @JsonProperty("created_at") Instant createdAt,
    UserSettingsResponse settings
) {
}
