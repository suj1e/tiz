package com.nexora.auth.core.domain;

import jakarta.persistence.*;
import java.time.Instant;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;
import com.nexora.datajp.support.BaseEntity;

/**
 * Refresh token entity for JWT token renewal.
 *
 * @author sujie
 */
@Entity
@Table(name = "refresh_tokens", indexes = {
    @Index(name = "idx_refresh_tokens_user", columnList = "user_id"),
    @Index(name = "idx_refresh_tokens_token", columnList = "token"),
    @Index(name = "idx_refresh_tokens_expires", columnList = "expires_at")
})
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class RefreshToken extends BaseEntity {

    @Column(nullable = false, unique = true, length = 500)
    private String token;

    @Column(name = "user_id", nullable = false)
    private Long userId;

    @Column(name = "expires_at", nullable = false)
    private Instant expiresAt;

    @Column(nullable = false)
    private Boolean revoked = false;

    @Column(name = "revoked_at")
    private Instant revokedAt;

    /**
     * Factory method - Create refresh token.
     */
    public static RefreshToken create(String token, Long userId, Instant expiresAt) {
        validateToken(token);
        validateUserId(userId);
        validateExpiresAt(expiresAt);

        RefreshToken refreshToken = new RefreshToken();
        refreshToken.token = token;
        refreshToken.userId = userId;
        refreshToken.expiresAt = expiresAt;
        refreshToken.revoked = false;
        return refreshToken;
    }

    /**
     * Check if token is expired.
     */
    public boolean isExpired() {
        return Instant.now().isAfter(expiresAt);
    }

    /**
     * Check if token is valid (not expired and not revoked).
     */
    public boolean isValid() {
        return !revoked && !isExpired();
    }

    /**
     * Revoke token.
     */
    public void revoke() {
        this.revoked = true;
        this.revokedAt = Instant.now();
    }

    private static void validateToken(String token) {
        if (token == null || token.isBlank()) {
            throw new IllegalArgumentException("Token cannot be blank");
        }
    }

    private static void validateUserId(Long userId) {
        if (userId == null) {
            throw new IllegalArgumentException("User ID cannot be null");
        }
    }

    private static void validateExpiresAt(Instant expiresAt) {
        if (expiresAt == null) {
            throw new IllegalArgumentException("Expiration time cannot be null");
        }
        if (expiresAt.isBefore(Instant.now())) {
            throw new IllegalArgumentException("Expiration time must be in the future");
        }
    }
}
