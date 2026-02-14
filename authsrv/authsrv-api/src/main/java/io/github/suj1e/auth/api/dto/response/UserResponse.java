package io.github.suj1e.auth.api.dto.response;

import java.time.LocalDateTime;

/**
 * User response.
 *
 * @author sujie
 */
public record UserResponse(
        Long id,
        String username,
        String email,
        String nickname,
        String avatar,
        String status,
        LocalDateTime createdAt
) {}
