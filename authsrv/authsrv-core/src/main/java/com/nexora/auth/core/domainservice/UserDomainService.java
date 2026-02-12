package com.nexora.auth.core.domainservice;

import com.nexora.auth.core.domain.User;

/**
 * User domain service interface.
 *
 * <p>Handles user-related business logic.
 *
 * @author sujie
 */
public interface UserDomainService {

    /**
     * Validate user uniqueness.
     *
     * @param username the username to check
     * @param email the email to check
     * @param existsByUsername function to check username existence
     * @param existsByEmail function to check email existence
     * @throws IllegalArgumentException if username or email already exists
     */
    void validateUserUniqueness(String username, String email,
            java.util.function.Function<String, Boolean> existsByUsername,
            java.util.function.Function<String, Boolean> existsByEmail);

    /**
     * Validate user data for creation.
     *
     * @param username the username
     * @param email the email
     * @param password the raw password
     * @throws IllegalArgumentException if any validation fails
     */
    void validateUserData(String username, String email, String password);

    /**
     * Check if user can authenticate with local credentials.
     *
     * @param user the user to check
     * @return true if user can use local authentication
     */
    boolean canUseLocalAuth(User user);

    /**
     * Check if user can authenticate with OAuth2.
     *
     * @param user the user to check
     * @param provider the OAuth2 provider
     * @return true if user can use the specified OAuth2 provider
     */
    boolean canUseOAuth2Auth(User user, String provider);

    /**
     * Check if user is enabled for authentication.
     *
     * @param user the user to check
     * @return true if user is enabled
     */
    boolean isEnabled(User user);

    /**
     * Normalize username for storage and comparison.
     *
     * @param username the username to normalize
     * @return normalized username
     */
    String normalizeUsername(String username);

    /**
     * Normalize email for storage and comparison.
     *
     * @param email the email to normalize
     * @return normalized email
     */
    String normalizeEmail(String email);
}
