package io.github.suj1e.auth.core.domainservice;

import io.github.suj1e.auth.core.domain.User;

/**
 * User domain service interface.
 *
 * @author sujie
 */
public interface UserDomainService {

    /**
     * Get user by username.
     */
    User getUserByUsername(String username);

    /**
     * Update user profile.
     */
    void updateProfile(String username, String nickname, String email);

    /**
     * Change password.
     */
    void changePassword(String username, String oldPassword, String newPassword);
}
