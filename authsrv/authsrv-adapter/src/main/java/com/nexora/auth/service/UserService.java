package com.nexora.auth.adapter.service;

import com.nexora.auth.api.dto.response.UserResponse;
import com.nexora.auth.core.domain.User;

import java.util.List;
import java.util.Optional;

/**
 * User service interface.
 *
 * @author sujie
 */
public interface UserService {

    /**
     * Find user by ID.
     *
     * @param id user ID
     * @return user response
     */
    Optional<UserResponse> findById(Long id);

    /**
     * Find user by username.
     *
     * @param username username
     * @return user entity
     */
    Optional<User> findByUsername(String username);

    /**
     * Find user by email.
     *
     * @param email email
     * @return user entity
     */
    Optional<User> findByEmail(String email);

    /**
     * Find multiple users by IDs.
     *
     * @param ids user IDs
     * @return list of user responses
     */
    List<UserResponse> findByIds(List<Long> ids);

    /**
     * Check if user exists by ID.
     *
     * @param id user ID
     * @return true if user exists
     */
    boolean existsById(Long id);

    /**
     * Update user profile.
     *
     * @param id user ID
     * @param name new name
     * @return updated user response
     */
    Optional<UserResponse> updateProfile(Long id, String name);

    /**
     * Change user password.
     *
     * @param id user ID
     * @param oldPassword old password
     * @param newPassword new password
     * @return true if password was changed
     */
    boolean changePassword(Long id, String oldPassword, String newPassword);

    /**
     * Enable/disable user.
     *
     * @param id user ID
     * @param enabled enabled status
     */
    void setEnabled(Long id, boolean enabled);

    /**
     * Lock user account.
     *
     * @param id user ID
     * @param durationMinutes lock duration
     */
    void lockAccount(Long id, int durationMinutes);

    /**
     * Unlock user account.
     *
     * @param id user ID
     */
    void unlockAccount(Long id);

    /**
     * Assign role to user.
     *
     * @param userId user ID
     * @param roleName role name
     */
    void assignRole(Long userId, String roleName);

    /**
     * Revoke role from user.
     *
     * @param userId user ID
     * @param roleName role name
     */
    void revokeRole(Long userId, String roleName);
}
