package com.nexora.auth.core.domainservice.impl;

import lombok.extern.slf4j.Slf4j;
import com.nexora.auth.core.domainservice.UserDomainService;
import com.nexora.auth.core.domain.User;
import com.nexora.common.security.PasswordUtil;

import java.util.function.Function;

/**
 * User domain service implementation.
 *
 * @author sujie
 */
@Slf4j
public class UserDomainServiceImpl implements UserDomainService {

    @Override
    public void validateUserUniqueness(String username, String email,
            Function<String, Boolean> existsByUsername,
            Function<String, Boolean> existsByEmail) {
        String normalizedUsername = normalizeUsername(username);
        String normalizedEmail = normalizeEmail(email);

        if (existsByUsername.apply(normalizedUsername)) {
            throw new IllegalArgumentException("Username already exists");
        }
        if (existsByEmail.apply(normalizedEmail)) {
            throw new IllegalArgumentException("Email already exists");
        }
    }

    @Override
    public void validateUserData(String username, String email, String password) {
        if (username == null || username.isBlank()) {
            throw new IllegalArgumentException("Username cannot be blank");
        }
        if (username.length() < 3 || username.length() > 50) {
            throw new IllegalArgumentException("Username must be between 3 and 50 characters");
        }
        if (email == null || email.isBlank()) {
            throw new IllegalArgumentException("Email cannot be blank");
        }
        if (!email.matches("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$")) {
            throw new IllegalArgumentException("Invalid email format");
        }
        PasswordUtil.validate(password);
    }

    @Override
    public boolean canUseLocalAuth(User user) {
        return user != null && "local".equals(user.getAuthProvider())
                && user.getPasswordHash() != null && !user.getPasswordHash().isBlank();
    }

    @Override
    public boolean canUseOAuth2Auth(User user, String provider) {
        return user != null && provider.equals(user.getAuthProvider())
                && user.getProviderUserId() != null && !user.getProviderUserId().isBlank();
    }

    @Override
    public boolean isEnabled(User user) {
        return user != null && Boolean.TRUE.equals(user.getEnabled());
    }

    @Override
    public String normalizeUsername(String username) {
        if (username == null || username.isBlank()) {
            throw new IllegalArgumentException("Username cannot be blank");
        }
        return username.toLowerCase().trim();
    }

    @Override
    public String normalizeEmail(String email) {
        if (email == null || email.isBlank()) {
            throw new IllegalArgumentException("Email cannot be blank");
        }
        return email.toLowerCase().trim();
    }
}
