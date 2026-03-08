package io.github.suj1e.user.service;

import io.github.suj1e.user.dto.SettingsRequest;
import io.github.suj1e.user.entity.UserSettings;
import io.github.suj1e.user.repository.UserSettingsRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

/**
 * 用户设置服务.
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class SettingsService {

    private final UserSettingsRepository userSettingsRepository;

    /**
     * 获取或创建用户设置.
     * 如果用户设置不存在，自动创建默认设置.
     */
    @Transactional
    public UserSettings getOrCreateSettings(UUID userId) {
        return userSettingsRepository.findByUserId(userId)
            .orElseGet(() -> {
                log.info("Creating default settings for user: {}", userId);
                UserSettings settings = UserSettings.builder()
                    .userId(userId)
                    .theme("system")
                    .build();
                return userSettingsRepository.save(settings);
            });
    }

    /**
     * 更新用户设置.
     */
    @Transactional
    public UserSettings updateSettings(UUID userId, SettingsRequest request) {
        UserSettings settings = getOrCreateSettings(userId);
        settings.setTheme(request.theme());
        return userSettingsRepository.save(settings);
    }
}
