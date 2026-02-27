package io.github.suj1e.auth.service;

import io.github.suj1e.auth.entity.User;
import io.github.suj1e.auth.error.AuthErrorCode;
import io.github.suj1e.auth.error.AuthException;
import io.github.suj1e.auth.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

/**
 * 用户服务.
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;

    /**
     * 根据ID获取用户.
     */
    @Transactional(readOnly = true)
    public User getUserById(UUID userId) {
        return userRepository.findById(userId)
            .orElseThrow(() -> new AuthException(AuthErrorCode.AUTH_1009));
    }

    /**
     * 根据邮箱获取用户.
     */
    @Transactional(readOnly = true)
    public User getUserByEmail(String email) {
        return userRepository.findByEmail(email)
            .orElseThrow(() -> new AuthException(AuthErrorCode.AUTH_1009));
    }

    /**
     * 检查用户是否存在.
     */
    @Transactional(readOnly = true)
    public boolean existsByEmail(String email) {
        return userRepository.existsByEmail(email);
    }

    /**
     * 保存用户.
     */
    @Transactional
    public User save(User user) {
        return userRepository.save(user);
    }
}
