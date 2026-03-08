package io.github.suj1e.auth.service;

import io.github.suj1e.auth.dto.LarkLoginRequest;
import io.github.suj1e.auth.dto.LoginResponse;
import io.github.suj1e.auth.dto.TokenResponse;
import io.github.suj1e.auth.dto.UserResponse;
import io.github.suj1e.auth.dto.UserSettingsResponse;
import io.github.suj1e.auth.entity.User;
import io.github.suj1e.auth.error.AuthErrorCode;
import io.github.suj1e.auth.error.AuthException;
import io.github.suj1e.auth.lark.LarkApiException;
import io.github.suj1e.auth.lark.LarkApiClient;
import io.github.suj1e.auth.lark.LarkUserInfo;
import io.github.suj1e.auth.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * 飞书登录服务.
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class LarkAuthService {

    private final UserRepository userRepository;
    private final TokenService tokenService;
    private final LarkApiClient larkApiClient;

    @Value("${lark.app-id:}")
    private String larkAppId;

    @Value("${lark.app-secret:}")
    private String larkAppSecret;

    /**
     * 飞书免登.
     * <p>
     * 流程:
     * 1. 通过 code 获取用户 access_token
     * 2. 通过 access_token 获取用户信息
     * 3. 查找或创建用户
     * 4. 生成 JWT token
     */
    @Transactional
    public LoginResponse login(LarkLoginRequest request) {
        LarkUserInfo larkUser;
        try {
            // 1. 获取 access_token
            var tokenResponse = larkApiClient.getAccessToken(larkAppId, larkAppSecret, request.code());
            if (tokenResponse == null || tokenResponse.accessToken() == null) {
                throw new AuthException(AuthErrorCode.AUTH_2002);
            }

            // 2. 获取用户信息
            larkUser = larkApiClient.getUserInfo(tokenResponse.accessToken());
            if (larkUser == null || larkUser.openId() == null) {
                throw new AuthException(AuthErrorCode.AUTH_2001);
            }
        } catch (LarkApiException e) {
            log.error("Lark API error: {}", e.getMessage());
            throw new AuthException(AuthErrorCode.AUTH_2003);
        }

        // 3. 查找或创建用户
        User user = findOrCreateUser(larkUser);

        // 4. 生成 Token
        TokenResponse tokens = tokenService.generateTokens(user);

        log.info("Lark login successful: open_id={}, email={}", larkUser.openId(), user.getEmail());

        return new LoginResponse(tokens.accessToken(), toUserResponse(user));
    }

    /**
     * 查找或创建用户.
     * <p>
     * 逻辑:
     * 1. 优先通过 lark_open_id 查找
     * 2. 如果没有，通过 email 查找并绑定
     * 3. 如果都没有，创建新用户
     */
    private User findOrCreateUser(LarkUserInfo larkUser) {
        // 1. 通过 lark_open_id 查找
        var existingUser = userRepository.findByLarkOpenId(larkUser.openId());
        if (existingUser.isPresent()) {
            return existingUser.get();
        }

        // 2. 通过 email 查找并绑定
        if (larkUser.email() != null && !larkUser.email().isBlank()) {
            existingUser = userRepository.findByEmail(larkUser.email());
            if (existingUser.isPresent()) {
                User user = existingUser.get();
                user.setLarkOpenId(larkUser.openId());
                if (user.getName() == null && larkUser.name() != null) {
                    user.setName(larkUser.name());
                }
                return userRepository.save(user);
            }
        }

        // 3. 创建新用户
        User newUser = User.builder()
            .email(larkUser.email() != null ? larkUser.email() : "lark_" + larkUser.openId() + "@lark.temp")
            .passwordHash("") // 飞书用户没有密码
            .larkOpenId(larkUser.openId())
            .name(larkUser.name())
            .status(User.UserStatus.ACTIVE)
            .build();

        return userRepository.save(newUser);
    }

    private UserResponse toUserResponse(User user) {
        return new UserResponse(
            user.getId(),
            user.getEmail(),
            user.getCreatedAt(),
            UserSettingsResponse.defaultSettings()
        );
    }
}
