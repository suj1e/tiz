package io.github.suj1e.user.service;

import io.github.suj1e.user.dto.AiConfigRequest;
import io.github.suj1e.user.dto.AiConfigResponse;
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

    /**
     * 获取用户 AI 配置.
     */
    @Transactional(readOnly = true)
    public AiConfigResponse getAiConfig(UUID userId) {
        UserSettings settings = getOrCreateSettings(userId);
        return AiConfigResponse.from(settings);
    }

    /**
     * 更新用户 AI 配置.
     */
    @Transactional
    public AiConfigResponse updateAiConfig(UUID userId, AiConfigRequest request) {
        UserSettings settings = getOrCreateSettings(userId);
        settings.setPreferredModel(request.preferredModel());
        settings.setTemperature(request.temperature());
        settings.setMaxTokens(request.maxTokens());
        settings.setSystemPrompt(request.systemPrompt());
        settings.setResponseLanguage(request.responseLanguage());
        settings.setCustomApiUrl(request.customApiUrl());
        settings.setCustomApiKey(request.customApiKey());
        UserSettings saved = userSettingsRepository.save(settings);
        return AiConfigResponse.from(saved);
    }

    /**
     * 检查用户是否已配置 AI.
     * 用户已配置当且仅当所有 AI 配置字段都非空.
     */
    @Transactional(readOnly = true)
    public boolean hasAiConfig(UUID userId) {
        return userSettingsRepository.findByUserId(userId)
            .map(settings ->
                settings.getPreferredModel() != null && !settings.getPreferredModel().isBlank() &&
                settings.getSystemPrompt() != null && !settings.getSystemPrompt().isBlank() &&
                settings.getResponseLanguage() != null && !settings.getResponseLanguage().isBlank() &&
                settings.getCustomApiUrl() != null && !settings.getCustomApiUrl().isBlank() &&
                settings.getCustomApiKey() != null && !settings.getCustomApiKey().isBlank()
            )
            .orElse(false);
    }
}
