package com.nexora.auth.core.domainservice;

import com.nexora.auth.core.domain.User;

/**
 * Authentication domain service interface.
 *
 * <p>Handles core authentication business logic.
 *
 * @author sujie
 */
public interface AuthDomainService {

    /**
     * Validate user credentials.
     *
     * @param user the user to validate
     * @param rawPassword the raw password to validate
     * @param encodedPassword the encoded password from database
     * @return true if credentials are valid
     */
    boolean validateCredentials(User user, String rawPassword, String encodedPassword);

    /**
     * Check if account is locked.
     *
     * @param user the user to check
     * @return true if account is locked
     */
    boolean isAccountLocked(User user);

    /**
     * Handle login failure - increment counter and lock if needed.
     *
     * @param user the user that failed login
     * @param maxAttempts maximum allowed attempts
     * @param lockoutDurationMinutes duration to lock account
     * @return true if account was locked due to max attempts
     */
    boolean handleLoginFailure(User user, int maxAttempts, int lockoutDurationMinutes);

    /**
     * Handle login success - reset failure counter.
     *
     * @param user the user that logged in successfully
     */
    void handleLoginSuccess(User user);

    /**
     * Check if user is eligible for authentication.
     *
     * @param user the user to check
     * @throws IllegalArgumentException if user is not eligible
     */
    void checkEligibleForAuth(User user);
}
