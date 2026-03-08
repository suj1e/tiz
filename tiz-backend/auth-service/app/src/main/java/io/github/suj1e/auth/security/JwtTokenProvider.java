package io.github.suj1e.auth.security;

import io.github.suj1e.auth.config.JwtProperties;
import io.github.suj1e.auth.entity.User;
import io.github.suj1e.auth.error.AuthErrorCode;
import io.github.suj1e.auth.error.AuthException;
import io.github.suj1e.auth.repository.UserRepository;
import io.github.suj1e.common.util.JwtUtils;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

import javax.crypto.SecretKey;
import java.util.UUID;

/**
 * JWT Token 提供者.
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class JwtTokenProvider {

    private final JwtProperties jwtProperties;
    private final UserRepository userRepository;

    /**
     * 从请求中提取 Token.
     */
    public String resolveToken(HttpServletRequest request) {
        String bearerToken = request.getHeader("Authorization");
        if (StringUtils.hasText(bearerToken) && bearerToken.startsWith("Bearer ")) {
            return bearerToken.substring(7);
        }
        return null;
    }

    /**
     * 验证 Token 并返回用户 ID.
     */
    public UUID validateTokenAndGetUserId(String token) {
        SecretKey key = getSecretKey();

        // 验证 Token 格式
        if (!JwtUtils.isValid(token, key)) {
            throw new AuthException(AuthErrorCode.AUTH_1006);
        }

        // 检查 Token 类型
        String tokenType = JwtUtils.extractType(token, key);
        if (!"access".equals(tokenType)) {
            throw new AuthException(AuthErrorCode.AUTH_1006);
        }

        // 提取用户 ID
        UUID userId = JwtUtils.extractUserId(token, key);

        // 验证用户是否存在且状态正常
        User user = userRepository.findById(userId)
            .orElseThrow(() -> new AuthException(AuthErrorCode.AUTH_1009));

        if (user.getStatus() != User.UserStatus.ACTIVE) {
            throw new AuthException(AuthErrorCode.AUTH_1008);
        }

        return userId;
    }

    /**
     * 获取签名密钥.
     */
    private SecretKey getSecretKey() {
        return JwtUtils.toSecretKey(jwtProperties.getSecret());
    }
}
