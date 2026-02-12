package com.nexora.auth.core.domain;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.Set;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;
import com.nexora.datajp.support.BaseEntity;

/**
 * User entity representing an authenticated user.
 *
 * <p>Supports both local authentication and OAuth2 providers.
 *
 * @author sujie
 */
@Entity
@Table(name = "users", indexes = {
    @Index(name = "idx_users_username", columnList = "username"),
    @Index(name = "idx_users_email", columnList = "email"),
    @Index(name = "idx_users_provider", columnList = "auth_provider, provider_user_id")
})
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class User extends BaseEntity {

    @Column(nullable = false, unique = true, length = 50)
    private String username;

    @Column(nullable = false, unique = true, length = 100)
    private String email;

    @Column(name = "password_hash")
    private String passwordHash;

    @Column(length = 100)
    private String name;

    @Column(name = "avatar_url", length = 500)
    private String avatarUrl;

    @Column(name = "auth_provider", nullable = false, length = 20)
    private String authProvider = "local";

    @Column(name = "provider_user_id")
    private String providerUserId;

    @Column(nullable = false)
    private Boolean enabled = true;

    @Column(nullable = false)
    private Boolean locked = false;

    @Column(nullable = false)
    private Boolean expired = false;

    @Column(name = "credentials_expired", nullable = false)
    private Boolean credentialsExpired = false;

    @Column(name = "failed_login_attempts", nullable = false)
    private Integer failedLoginAttempts = 0;

    @Column(name = "last_failed_login")
    private LocalDateTime lastFailedLogin;

    @Column(name = "locked_until")
    private LocalDateTime lockedUntil;

    @Column(name = "last_login_at")
    private LocalDateTime lastLoginAt;

    /**
     * User roles - LAZY loading by default.
     * Use @EntityGraph in repository queries when roles are needed.
     */
    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(
        name = "user_roles",
        joinColumns = @JoinColumn(name = "user_id"),
        inverseJoinColumns = @JoinColumn(name = "role_id")
    )
    private Set<Role> roles = new HashSet<>();

    /**
     * Factory method - Create local user with username/password.
     */
    public static User createLocalUser(String username, String email, String passwordHash, String name) {
        validateUsername(username);
        validateEmail(email);

        User user = new User();
        user.username = username.toLowerCase();
        user.email = email.toLowerCase();
        user.passwordHash = passwordHash;
        user.name = name;
        user.authProvider = "local";
        user.enabled = true;
        return user;
    }

    /**
     * Factory method - Create OAuth2 user.
     */
    public static User createOAuth2User(String provider, String providerUserId,
            String username, String email, String name, String avatarUrl) {
        validateProvider(provider);

        User user = new User();
        user.authProvider = provider;
        user.providerUserId = providerUserId;
        user.username = username != null ? username.toLowerCase() : email.toLowerCase();
        user.email = email != null ? email.toLowerCase() : username.toLowerCase();
        user.name = name;
        user.avatarUrl = avatarUrl;
        user.enabled = true;
        return user;
    }

    /**
     * Check if account is currently locked.
     */
    public boolean isAccountLocked() {
        if (!locked) {
            return false;
        }
        if (lockedUntil == null) {
            return true;
        }
        if (LocalDateTime.now().isAfter(lockedUntil)) {
            unlock();
            return false;
        }
        return true;
    }

    /**
     * Increment failed login attempts counter.
     */
    public void incrementFailedLoginAttempts() {
        this.failedLoginAttempts++;
        this.lastFailedLogin = LocalDateTime.now();
    }

    /**
     * Reset failed login attempts counter.
     */
    public void resetFailedLoginAttempts() {
        this.failedLoginAttempts = 0;
        this.lastFailedLogin = null;
    }

    /**
     * Lock account for specified duration.
     */
    public void lock(int durationMinutes) {
        this.locked = true;
        this.lockedUntil = LocalDateTime.now().plusMinutes(durationMinutes);
    }

    /**
     * Unlock account.
     */
    public void unlock() {
        this.locked = false;
        this.lockedUntil = null;
    }

    /**
     * Update last login timestamp.
     */
    public void updateLastLoginAt() {
        this.lastLoginAt = LocalDateTime.now();
    }

    /**
     * Update user name.
     */
    public void updateName(String name) {
        this.name = name;
    }

    /**
     * Update password hash.
     */
    public void updatePasswordHash(String passwordHash) {
        this.passwordHash = passwordHash;
    }

    /**
     * Set enabled status.
     */
    public void setEnabledStatus(boolean enabled) {
        this.enabled = enabled;
    }

    /**
     * Remove role from user.
     */
    public void removeRole(Role role) {
        if (this.roles != null) {
            this.roles.remove(role);
        }
    }

    /**
     * Add role to user.
     */
    public void addRole(Role role) {
        if (this.roles == null) {
            this.roles = new HashSet<>();
        }
        this.roles.add(role);
    }

    /**
     * Check if user has specified role.
     */
    public boolean hasRole(String roleName) {
        return roles.stream().anyMatch(r -> r.getName().equals(roleName));
    }

    /**
     * Check if user has any of the specified roles.
     */
    public boolean hasAnyRole(String... roleNames) {
        return roles.stream().anyMatch(r -> Set.of(roleNames).contains(r.getName()));
    }

    private static void validateUsername(String username) {
        if (username == null || username.isBlank()) {
            throw new IllegalArgumentException("Username cannot be blank");
        }
        if (username.length() < 3 || username.length() > 50) {
            throw new IllegalArgumentException("Username must be between 3 and 50 characters");
        }
    }

    private static void validateEmail(String email) {
        if (email == null || email.isBlank()) {
            throw new IllegalArgumentException("Email cannot be blank");
        }
        if (!email.matches("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$")) {
            throw new IllegalArgumentException("Invalid email format");
        }
    }

    private static void validateProvider(String provider) {
        if (provider == null || provider.isBlank()) {
            throw new IllegalArgumentException("Provider cannot be blank");
        }
    }
}
