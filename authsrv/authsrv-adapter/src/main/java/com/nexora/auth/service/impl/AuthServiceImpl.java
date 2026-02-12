package com.nexora.auth.adapter.service.impl;

import com.nexora.auth.exception.BusinessException;
import com.nexora.auth.exception.ErrorCode;
import com.nexora.auth.mapper.UserMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import com.nexora.auth.api.dto.request.LoginRequest;
import com.nexora.auth.api.dto.request.RefreshTokenRequest;
import com.nexora.auth.api.dto.request.RegisterRequest;
import com.nexora.auth.api.dto.response.LoginResponse;
import com.nexora.auth.api.dto.response.TokenResponse;
import com.nexora.auth.api.dto.response.UserResponse;
import com.nexora.auth.adapter.infra.event.EventPublisher;
import com.nexora.auth.adapter.service.AuditService;
import com.nexora.auth.adapter.service.AuthService;
import com.nexora.auth.adapter.service.TokenService;
import com.nexora.auth.adapter.service.UserService;
import com.nexora.auth.api.event.UserEventType;
import com.nexora.auth.core.domainservice.AuthDomainService;
import com.nexora.auth.core.domainservice.UserDomainService;
import com.nexora.auth.core.domain.Role;
import com.nexora.auth.core.domain.User;
import com.nexora.auth.core.support.Entities;
import com.nexora.auth.adapter.infra.repository.RoleRepository;
import com.nexora.auth.adapter.infra.repository.UserRepository;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Map;
import java.util.Optional;

/**
 * Authentication service implementation.
 *
 * @author sujie
 */
@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class AuthServiceImpl implements AuthService {

    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final PasswordEncoder passwordEncoder;
    private final TokenService tokenService;
    private final UserService userService;
    private final AuditService auditService;
    private final AuthDomainService authDomainService;
    private final UserDomainService userDomainService;
    private final EventPublisher eventPublisher;

    @Value("${auth.local.brute-force-protection.max-attempts:5}")
    private int maxFailedAttempts;

    @Value("${auth.local.brute-force-protection.lockout-duration:15}")
    private int lockoutDurationMinutes;

    @Value("${auth.jwt.access-token-expiry:15m}")
    private String accessTokenExpiry;

    @Override
    @Transactional
    public Optional<LoginResponse> login(LoginRequest request) {
        return userRepository.findByUsernameIgnoreCase(request.username())
            .or(() -> userRepository.findByEmailIgnoreCase(request.username()))
            .map(user -> {
                // Check account eligibility
                try {
                    authDomainService.checkEligibleForAuth(user);
                } catch (IllegalArgumentException e) {
                    auditService.logLoginFailure(user, e.getMessage());
                    // Convert to BusinessException for proper error response
                    throw new BusinessException(ErrorCode.INVALID_CREDENTIALS, e.getMessage());
                }

                // Check local auth capability
                if (!userDomainService.canUseLocalAuth(user)) {
                    auditService.logLoginFailure(user, "Local authentication not available for this account");
                    throw new BusinessException(ErrorCode.INVALID_CREDENTIALS);
                }

                // Validate credentials
                if (!authDomainService.validateCredentials(user, request.password(), user.getPasswordHash())) {
                    boolean locked = authDomainService.handleLoginFailure(user, maxFailedAttempts, lockoutDurationMinutes);
                    userRepository.save(user);
                    auditService.logLoginFailure(user, locked ? "Account locked" : "Invalid credentials");

                    // Publish account locked event if applicable
                    if (locked) {
                        try {
                            eventPublisher.publishUserEvent(
                                UserEventType.ACCOUNT_LOCKED,
                                user.getId(),
                                user.getUsername(),
                                user.getEmail(),
                                user.getName(),
                                Map.of("reason", "too_many_failed_attempts", "duration", lockoutDurationMinutes + "m")
                            );
                        } catch (Exception e) {
                            log.error("Failed to publish ACCOUNT_LOCKED event", e);
                        }
                    }
                    throw new BusinessException(ErrorCode.INVALID_CREDENTIALS);
                }

                // Login success
                authDomainService.handleLoginSuccess(user);
                userRepository.save(user);

                String accessToken = tokenService.generateAccessToken(user);
                tokenService.generateRefreshToken(user);

                auditService.logLoginSuccess(user);

                // Publish login event
                try {
                    eventPublisher.publishUserEvent(
                        UserEventType.USER_LOGIN,
                        user.getId(),
                        user.getUsername(),
                        user.getEmail(),
                        user.getName()
                    );
                } catch (Exception e) {
                    log.error("Failed to publish USER_LOGIN event", e);
                }

                return LoginResponse.of(
                    accessToken,
                    null, // refresh token returned in header
                    parseExpiryMinutes(accessTokenExpiry) * 60L,
                    UserMapper.toResponse(user)
                );
            });
    }

    @Override
    @Transactional
    public Optional<LoginResponse> register(RegisterRequest request) {
        // Validate user data
        userDomainService.validateUserData(request.username(), request.email(), request.password());

        // Check uniqueness
        userDomainService.validateUserUniqueness(
            request.username(),
            request.email(),
            userRepository::existsByUsernameIgnoreCase,
            userRepository::existsByEmailIgnoreCase
        );

        // Create user
        Role userRole = roleRepository.findByNameIgnoreCase("ROLE_USER")
            .orElseGet(() -> roleRepository.save(Role.createUserRole()));

        return Entities.create(userRepository)
            .with(request, r -> User.createLocalUser(
                r.username(),
                r.email(),
                passwordEncoder.encode(r.password()),
                r.name()
            ))
            .execute()
            .map(user -> {
                user.addRole(userRole);
                User savedUser = userRepository.save(user);

                String accessToken = tokenService.generateAccessToken(savedUser);
                tokenService.generateRefreshToken(savedUser);

                auditService.logRegister(savedUser);

                // Publish user created event
                try {
                    eventPublisher.publishUserEvent(
                        UserEventType.USER_CREATED,
                        savedUser.getId(),
                        savedUser.getUsername(),
                        savedUser.getEmail(),
                        savedUser.getName(),
                        Map.of("authProvider", "local")
                    );
                } catch (Exception e) {
                    log.error("Failed to publish USER_CREATED event", e);
                }

                return LoginResponse.of(
                    accessToken,
                    null,
                    parseExpiryMinutes(accessTokenExpiry) * 60L,
                    UserMapper.toResponse(savedUser)
                );
            });
    }

    @Override
    @Transactional
    public Optional<TokenResponse> refreshToken(RefreshTokenRequest request) {
        return tokenService.refreshAccessToken(request.refreshToken());
    }

    @Override
    @Transactional
    public void logout(String token) {
        Long userId = tokenService.getUserIdFromToken(token);
        tokenService.revokeAllUserTokens(userId);
        userRepository.findById(userId).ifPresent(user -> {
            auditService.logLogout(user);

            // Publish logout event
            try {
                eventPublisher.publishUserEvent(
                    UserEventType.USER_LOGOUT,
                    user.getId(),
                    user.getUsername(),
                    user.getEmail(),
                    user.getName()
                );
            } catch (Exception e) {
                log.error("Failed to publish USER_LOGOUT event", e);
            }
        });
    }

    @Override
    public Optional<UserResponse> getCurrentUser(String token) {
        Long userId = tokenService.getUserIdFromToken(token);
        return userRepository.findById(userId).map(UserMapper::toResponse);
    }

    private int parseExpiryMinutes(String expiry) {
        if (expiry.endsWith("m")) {
            return Integer.parseInt(expiry.substring(0, expiry.length() - 1));
        } else if (expiry.endsWith("h")) {
            return Integer.parseInt(expiry.substring(0, expiry.length() - 1)) * 60;
        }
        return 15; // default
    }
}
