package com.nexora.auth.adapter.service.impl;

import com.nexora.auth.exception.BusinessException;
import com.nexora.auth.exception.ErrorCode;
import com.nexora.auth.mapper.UserMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import com.nexora.auth.api.dto.response.UserResponse;
import com.nexora.auth.adapter.infra.event.EventPublisher;
import com.nexora.auth.adapter.infra.repository.RoleRepository;
import com.nexora.auth.adapter.infra.repository.UserRepository;
import com.nexora.auth.adapter.service.UserService;
import com.nexora.auth.api.event.UserEventType;
import com.nexora.auth.config.CacheConfig;
import com.nexora.auth.core.domainservice.AuthDomainService;
import com.nexora.auth.core.domain.Role;
import com.nexora.auth.core.domain.User;
import com.nexora.auth.core.support.Entities;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * User service implementation.
 *
 * @author sujie
 */
@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class UserServiceImpl implements UserService {

    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final PasswordEncoder passwordEncoder;
    private final AuthDomainService authDomainService;
    private final EventPublisher eventPublisher;

    @Override
    @Cacheable(value = CacheConfig.CACHE_USER, key = "#id")
    public Optional<UserResponse> findById(Long id) {
        return userRepository.findById(id).map(UserMapper::toResponse);
    }

    @Override
    @Cacheable(value = CacheConfig.CACHE_USER, key = "'username:' + #username")
    public Optional<User> findByUsername(String username) {
        return userRepository.findByUsernameIgnoreCase(username);
    }

    @Override
    @Cacheable(value = CacheConfig.CACHE_USER, key = "'email:' + #email")
    public Optional<User> findByEmail(String email) {
        return userRepository.findByEmailIgnoreCase(email);
    }

    @Override
    public List<UserResponse> findByIds(List<Long> ids) {
        return userRepository.findAllById(ids).stream()
            .map(UserMapper::toResponse)
            .toList();
    }

    @Override
    public boolean existsById(Long id) {
        return userRepository.existsById(id);
    }

    @Override
    @Transactional
    @CacheEvict(value = CacheConfig.CACHE_USER, key = "#id")
    public Optional<UserResponse> updateProfile(Long id, String name) {
        return Entities.update(userRepository, id)
            .apply(user -> {
                if (name != null && !name.isBlank()) {
                    user.updateName(name.trim());
                }
                return user;
            })
            .execute()
            .map(UserMapper::toResponse);
    }

    @Override
    @Transactional
    @CacheEvict(value = CacheConfig.CACHE_USER, key = "#id")
    public boolean changePassword(Long id, String oldPassword, String newPassword) {
        return userRepository.findById(id)
            .map(user -> {
                if (!authDomainService.validateCredentials(user, oldPassword, user.getPasswordHash())) {
                    throw new BusinessException(ErrorCode.INVALID_PASSWORD);
                }
                user.updatePasswordHash(passwordEncoder.encode(newPassword));
                userRepository.save(user);
                log.info("Password changed for user: {}", user.getUsername());

                // Publish password changed event
                try {
                    eventPublisher.publishUserEvent(
                        UserEventType.PASSWORD_CHANGED,
                        user.getId(),
                        user.getUsername(),
                        user.getEmail(),
                        user.getName()
                    );
                } catch (Exception e) {
                    log.error("Failed to publish PASSWORD_CHANGED event", e);
                }

                return true;
            })
            .orElse(false);
    }

    @Override
    @Transactional
    @CacheEvict(value = CacheConfig.CACHE_USER, key = "#id")
    public void setEnabled(Long id, boolean enabled) {
        userRepository.findById(id).ifPresent(user -> {
            user.setEnabledStatus(enabled);
            userRepository.save(user);
            log.info("User {} {}", user.getUsername(), enabled ? "enabled" : "disabled");
        });
    }

    @Override
    @Transactional
    @CacheEvict(value = CacheConfig.CACHE_USER, key = "#id")
    public void lockAccount(Long id, int durationMinutes) {
        userRepository.findById(id).ifPresent(user -> {
            user.lock(durationMinutes);
            userRepository.save(user);
            log.warn("User {} locked for {} minutes", user.getUsername(), durationMinutes);

            // Publish account locked event
            try {
                eventPublisher.publishUserEvent(
                    UserEventType.ACCOUNT_LOCKED,
                    user.getId(),
                    user.getUsername(),
                    user.getEmail(),
                    user.getName(),
                    Map.of("reason", "admin_action", "duration", durationMinutes + "m")
                );
            } catch (Exception e) {
                log.error("Failed to publish ACCOUNT_LOCKED event", e);
            }
        });
    }

    @Override
    @Transactional
    @CacheEvict(value = CacheConfig.CACHE_USER, key = "#id")
    public void unlockAccount(Long id) {
        userRepository.findById(id).ifPresent(user -> {
            user.unlock();
            user.resetFailedLoginAttempts();
            userRepository.save(user);
            log.info("User {} unlocked", user.getUsername());

            // Publish account unlocked event
            try {
                eventPublisher.publishUserEvent(
                    UserEventType.ACCOUNT_UNLOCKED,
                    user.getId(),
                    user.getUsername(),
                    user.getEmail(),
                    user.getName(),
                    Map.of("reason", "admin_action")
                );
            } catch (Exception e) {
                log.error("Failed to publish ACCOUNT_UNLOCKED event", e);
            }
        });
    }

    @Override
    @Transactional
    @CacheEvict(value = CacheConfig.CACHE_USER, key = "#userId")
    public void assignRole(Long userId, String roleName) {
        Role role = roleRepository.findByNameIgnoreCase(roleName)
            .orElseThrow(() -> new BusinessException(ErrorCode.ROLE_NOT_FOUND, "Role not found: " + roleName));

        userRepository.findById(userId).ifPresent(user -> {
            if (!user.hasRole(role.getName())) {
                user.addRole(role);
                userRepository.save(user);
                log.info("Role {} assigned to user {}", role.getName(), user.getUsername());

                // Publish role assigned event
                try {
                    eventPublisher.publishUserEvent(
                        UserEventType.ROLE_ASSIGNED,
                        user.getId(),
                        user.getUsername(),
                        user.getEmail(),
                        user.getName(),
                        Map.of("role", role.getName())
                    );
                } catch (Exception e) {
                    log.error("Failed to publish ROLE_ASSIGNED event", e);
                }
            }
        });
    }

    @Override
    @Transactional
    @CacheEvict(value = CacheConfig.CACHE_USER, key = "#userId")
    public void revokeRole(Long userId, String roleName) {
        userRepository.findById(userId).ifPresent(user -> {
            boolean removed = user.getRoles().removeIf(r -> r.getName().equalsIgnoreCase(roleName));
            if (removed) {
                userRepository.save(user);
                log.info("Role {} revoked from user {}", roleName, user.getUsername());

                // Publish role revoked event
                try {
                    eventPublisher.publishUserEvent(
                        UserEventType.ROLE_REVOKED,
                        user.getId(),
                        user.getUsername(),
                        user.getEmail(),
                        user.getName(),
                        Map.of("role", roleName)
                    );
                } catch (Exception e) {
                    log.error("Failed to publish ROLE_REVOKED event", e);
                }
            }
        });
    }
}
