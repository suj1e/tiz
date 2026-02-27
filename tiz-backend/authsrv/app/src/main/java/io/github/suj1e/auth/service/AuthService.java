package io.github.suj1e.auth.service;

import io.github.suj1e.auth.dto.LoginRequest;
import io.github.suj1e.auth.dto.RegisterRequest;
import io.github.suj1e.auth.dto.TokenResponse;
import io.github.suj1e.auth.dto.UserResponse;
import io.github.suj1e.auth.entity.User;
import io.github.suj1e.auth.error.AuthErrorCode;
import io.github.suj1e.auth.error.AuthException;
import io.github.suj1e.auth.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

/**
 * 认证服务.
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final TokenService tokenService;
    private final PasswordEncoder passwordEncoder;

    /**
     * 用户注册.
     */
    @Transactional
    public UserResponse register(RegisterRequest request) {
        // 检查邮箱是否已存在
        if (userRepository.existsByEmail(request.email())) {
            throw new AuthException(AuthErrorCode.AUTH_1002);
        }

        // 创建用户
        User user = User.builder()
            .email(request.email())
            .passwordHash(passwordEncoder.encode(request.password()))
            .status(User.UserStatus.ACTIVE)
            .build();

        user = userRepository.save(user);

        log.info("User registered: {}", user.getEmail());

        return toUserResponse(user);
    }

    /**
     * 用户登录.
     */
    @Transactional
    public TokenResponse login(LoginRequest request) {
        // 查找用户
        User user = userRepository.findByEmail(request.email())
            .orElseThrow(() -> new AuthException(AuthErrorCode.AUTH_1001));

        // 验证密码
        if (!passwordEncoder.matches(request.password(), user.getPasswordHash())) {
            throw new AuthException(AuthErrorCode.AUTH_1001);
        }

        // 检查用户状态
        if (user.getStatus() != User.UserStatus.ACTIVE) {
            throw new AuthException(AuthErrorCode.AUTH_1008);
        }

        // 生成 Token
        TokenResponse tokens = tokenService.generateTokens(user);

        log.info("User logged in: {}", user.getEmail());

        return tokens;
    }

    /**
     * 用户登出.
     */
    @Transactional
    public void logout(UUID userId, String refreshToken) {
        // 撤销用户的刷新令牌
        tokenService.revokeAllTokens(userId);

        // 将当前刷新令牌加入黑名单
        if (refreshToken != null && !refreshToken.isBlank()) {
            tokenService.addToBlacklist(refreshToken, 7 * 24 * 60 * 60); // 7天
        }

        log.info("User logged out: {}", userId);
    }

    /**
     * 刷新 Token.
     */
    @Transactional
    public TokenResponse refreshToken(String refreshToken) {
        return tokenService.refreshAccessToken(refreshToken);
    }

    /**
     * 获取当前用户.
     */
    @Transactional(readOnly = true)
    public UserResponse getCurrentUser(UUID userId) {
        User user = userRepository.findById(userId)
            .orElseThrow(() -> new AuthException(AuthErrorCode.AUTH_1009));
        return toUserResponse(user);
    }

    private UserResponse toUserResponse(User user) {
        return new UserResponse(
            user.getId(),
            user.getEmail(),
            user.getStatus().name().toLowerCase(),
            user.getCreatedAt()
        );
    }
}
