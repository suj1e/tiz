package io.github.suj1e.auth.adapter.infra.domainservice.impl;

import io.github.suj1e.auth.core.domain.TokenInfo;
import io.github.suj1e.auth.core.domain.User;
import io.github.suj1e.auth.core.domainservice.AuthDomainService;
import io.github.suj1e.auth.core.domainservice.TokenDomainService;
import io.github.suj1e.auth.infra.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Authentication domain service implementation.
 *
 * @author sujie
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class AuthDomainServiceImpl implements AuthDomainService {

    private static final long ACCESS_TOKEN_EXPIRES_IN = 900L; // 15 minutes

    private final UserRepository userRepository;
    private final TokenDomainService tokenDomainService;
    private final PasswordEncoder passwordEncoder;

    @Override
    @Transactional
    public void register(String username, String email, String password) {
        if (userRepository.existsByUsername(username)) {
            throw new IllegalArgumentException("Username already exists");
        }
        if (userRepository.existsByEmail(email)) {
            throw new IllegalArgumentException("Email already exists");
        }

        User user = User.builder()
                .username(username)
                .email(email)
                .password(passwordEncoder.encode(password))
                .status(User.Status.ACTIVE)
                .build();

        userRepository.save(user);
        log.info("User registered: {}", username);
    }

    @Override
    @Transactional
    public TokenInfo login(String username, String password) {
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new BadCredentialsException("Invalid username or password"));

        // Check account status
        if (user.getStatus() != User.Status.ACTIVE) {
            throw new IllegalStateException("Account is not active");
        }

        // Verify password
        if (!passwordEncoder.matches(password, user.getPassword())) {
            log.warn("Login failed for user: {}", username);
            throw new BadCredentialsException("Invalid username or password");
        }

        // Generate tokens
        String accessToken = tokenDomainService.generateAccessToken(username);
        String refreshToken = tokenDomainService.generateRefreshToken(username);

        log.info("User logged in: {}", username);

        return new TokenInfo(
                accessToken,
                refreshToken,
                ACCESS_TOKEN_EXPIRES_IN
        );
    }

    @Override
    @Transactional
    public void logout(String username) {
        // Remove refresh token from Redis
        // Token blacklist is handled by TokenDomainService.addToBlacklist()
        log.info("User logged out: {}", username);
    }
}
