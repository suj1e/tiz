package com.nexora.auth.core.domainservice.impl;

import lombok.extern.slf4j.Slf4j;
import com.nexora.auth.core.domainservice.AuthDomainService;
import com.nexora.auth.core.domain.User;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;

/**
 * Authentication domain service implementation.
 *
 * @author sujie
 */
@Slf4j
public class AuthDomainServiceImpl implements AuthDomainService {

    private final PasswordEncoder passwordEncoder = new BCryptPasswordEncoder(12);

    @Override
    public boolean validateCredentials(User user, String rawPassword, String encodedPassword) {
        if (rawPassword == null || rawPassword.isBlank()) {
            return false;
        }
        if (encodedPassword == null || encodedPassword.isBlank()) {
            return false;
        }
        return passwordEncoder.matches(rawPassword, encodedPassword);
    }

    @Override
    public boolean isAccountLocked(User user) {
        return user.isAccountLocked();
    }

    @Override
    public boolean handleLoginFailure(User user, int maxAttempts, int lockoutDurationMinutes) {
        user.incrementFailedLoginAttempts();
        int attempts = user.getFailedLoginAttempts();

        if (attempts >= maxAttempts) {
            user.lock(lockoutDurationMinutes);
            log.warn("User {} locked after {} failed login attempts", user.getUsername(), attempts);
            return true;
        }

        log.debug("User {} failed login attempt {}/{}", user.getUsername(), attempts, maxAttempts);
        return false;
    }

    @Override
    public void handleLoginSuccess(User user) {
        user.resetFailedLoginAttempts();
        user.updateLastLoginAt();
    }

    @Override
    public void checkEligibleForAuth(User user) {
        if (!user.getEnabled()) {
            throw new IllegalArgumentException("Account is disabled");
        }
        if (user.getExpired()) {
            throw new IllegalArgumentException("Account has expired");
        }
        if (user.getCredentialsExpired()) {
            throw new IllegalArgumentException("Credentials have expired");
        }
        if (isAccountLocked(user)) {
            throw new IllegalArgumentException("Account is locked");
        }
    }
}
