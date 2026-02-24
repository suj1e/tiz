package io.github.suj1e.auth.api.dto.response;

import java.time.LocalDateTime;

/**
 * Token validation response.
 *
 * @author sujie
 */
public record TokenValidationResponse(
        boolean valid,
        String username,
        LocalDateTime expiresAt,
        String message
) {
    public static TokenValidationResponse valid(String username, LocalDateTime expiresAt) {
        return new TokenValidationResponse(true, username, expiresAt, null);
    }

    public static TokenValidationResponse invalid(String message) {
        return new TokenValidationResponse(false, null, null, message);
    }
}
