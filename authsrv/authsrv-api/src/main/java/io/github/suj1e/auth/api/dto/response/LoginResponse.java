package io.github.suj1e.auth.api.dto.response;

/**
 * Login response DTO.
 *
 * @author sujie
 */
public record LoginResponse(
    String accessToken,
    String refreshToken,
    String tokenType,
    Long expiresIn,
    UserResponse user
) {
    public static LoginResponse of(String accessToken, String refreshToken, Long expiresIn, UserResponse user) {
        return new LoginResponse(
            accessToken,
            refreshToken,
            "Bearer",
            expiresIn,
            user
        );
    }
}
