package io.github.suj1e.auth.adapter.rest;

import io.github.suj1e.auth.exception.BusinessException;
import io.github.suj1e.auth.exception.ErrorCode;
import io.github.suj1e.auth.mapper.UserMapper;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import io.github.suj1e.auth.api.dto.response.MessageResponse;
import io.github.suj1e.auth.api.dto.response.UserResponse;
import io.github.suj1e.auth.adapter.service.UserService;
import io.github.suj1e.auth.core.domain.User;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * User management REST controller.
 *
 * <p>Returns DTOs directly - wrapped by nexora-spring-boot-starter-web as Result<T>
 *
 * @author sujie
 */
@Slf4j
@RestController
@RequestMapping("/v1/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    /**
     * Get current user profile.
     */
    @GetMapping("/me")
    public UserResponse getCurrentProfile(@AuthenticationPrincipal UserDetails userDetails) {
        return userService.findByUsername(userDetails.getUsername())
            .map(UserMapper::toResponse)
            .orElseThrow(() -> new BusinessException(ErrorCode.USER_NOT_FOUND));
    }

    /**
     * Get user by ID (admin only).
     * Compatible with @HttpExchange client interface.
     */
    @GetMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public UserResponse getUserById(@PathVariable Long id) {
        return userService.findById(id)
            .orElseThrow(() -> new BusinessException(ErrorCode.USER_NOT_FOUND));
    }

    /**
     * Get user by username.
     * Compatible with @HttpExchange client interface.
     */
    @GetMapping("/username/{username}")
    public UserResponse getUserByUsername(@PathVariable String username) {
        return userService.findByUsername(username)
            .map(UserMapper::toResponse)
            .orElseThrow(() -> new BusinessException(ErrorCode.USER_NOT_FOUND));
    }

    /**
     * Get multiple users by IDs.
     * Compatible with @HttpExchange client interface.
     */
    @GetMapping("/batch")
    @PreAuthorize("hasRole('ADMIN')")
    public List<UserResponse> getUsersByIds(@RequestParam("ids") List<Long> ids) {
        return userService.findByIds(ids);
    }

    /**
     * Check if user exists by ID.
     * Compatible with @HttpExchange client interface.
     */
    @GetMapping("/{id}/exists")
    public boolean existsById(@PathVariable Long id) {
        return userService.existsById(id);
    }

    /**
     * Update user profile.
     */
    @PutMapping("/me")
    public UserResponse updateProfile(
            @AuthenticationPrincipal UserDetails userDetails,
            @RequestParam(required = false) String name) {
        Long userId = Long.parseLong(userDetails.getUsername());
        return userService.updateProfile(userId, name)
            .orElseThrow(() -> new BusinessException(ErrorCode.USER_NOT_FOUND));
    }

    /**
     * Change password.
     */
    @PostMapping("/me/password")
    public MessageResponse changePassword(
            @AuthenticationPrincipal UserDetails userDetails,
            @RequestParam String oldPassword,
            @RequestParam String newPassword) {
        Long userId = Long.parseLong(userDetails.getUsername());
        boolean changed = userService.changePassword(userId, oldPassword, newPassword);
        if (!changed) {
            throw new BusinessException(ErrorCode.INVALID_PASSWORD);
        }
        return MessageResponse.of("Password changed successfully");
    }

    /**
     * Enable/disable user (admin only).
     * Compatible with @HttpExchange client interface.
     */
    @PutMapping("/{id}/status")
    @PreAuthorize("hasRole('ADMIN')")
    public MessageResponse setUserStatus(
            @PathVariable Long id,
            @RequestParam boolean enabled) {
        userService.setEnabled(id, enabled);
        return MessageResponse.of("User status updated");
    }

    /**
     * Lock user account (admin only).
     * Compatible with @HttpExchange client interface.
     */
    @PostMapping("/{id}/lock")
    @PreAuthorize("hasRole('ADMIN')")
    public MessageResponse lockAccount(
            @PathVariable Long id,
            @RequestParam(defaultValue = "15") int durationMinutes) {
        userService.lockAccount(id, durationMinutes);
        return MessageResponse.of("Account locked for " + durationMinutes + " minutes");
    }

    /**
     * Unlock user account (admin only).
     * Compatible with @HttpExchange client interface.
     */
    @PostMapping("/{id}/unlock")
    @PreAuthorize("hasRole('ADMIN')")
    public MessageResponse unlockAccount(@PathVariable Long id) {
        userService.unlockAccount(id);
        return MessageResponse.of("Account unlocked");
    }

    /**
     * Assign role to user (admin only).
     * Compatible with @HttpExchange client interface.
     */
    @PostMapping("/{id}/roles")
    @PreAuthorize("hasRole('ADMIN')")
    public MessageResponse assignRole(
            @PathVariable Long id,
            @RequestParam String roleName) {
        userService.assignRole(id, roleName);
        return MessageResponse.of("Role assigned");
    }

    /**
     * Revoke role from user (admin only).
     * Compatible with @HttpExchange client interface.
     */
    @DeleteMapping("/{id}/roles")
    @PreAuthorize("hasRole('ADMIN')")
    public MessageResponse revokeRole(
            @PathVariable Long id,
            @RequestParam String roleName) {
        userService.revokeRole(id, roleName);
        return MessageResponse.of("Role revoked");
    }
}
