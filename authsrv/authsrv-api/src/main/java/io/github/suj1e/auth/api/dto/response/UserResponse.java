package io.github.suj1e.auth.api.dto.response;

import java.time.LocalDateTime;
import java.util.Set;

/**
 * User response DTO.
 *
 * @author sujie
 */
public record UserResponse(
    Long id,
    String username,
    String email,
    String name,
    String avatarUrl,
    String authProvider,
    Set<String> roles,
    Boolean enabled,
    LocalDateTime lastLoginAt
) {
}
