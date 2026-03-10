package io.github.suj1e.user.controller;

import io.github.suj1e.common.response.ApiResponse;
import io.github.suj1e.user.dto.AiConfigRequest;
import io.github.suj1e.user.dto.AiConfigResponse;
import io.github.suj1e.user.service.SettingsService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.UUID;

/**
 * AI 配置控制器.
 * 提供对外 API.
 */
@RestController
@RequestMapping("/api/user/v1")
@RequiredArgsConstructor
public class AiConfigController {

    private final SettingsService settingsService;

    /**
     * 获取用户 AI 配置.
     */
    @GetMapping("/ai-config")
    public ResponseEntity<ApiResponse<AiConfigResponse>> getAiConfig(@AuthenticationPrincipal UUID userId) {
        AiConfigResponse response = settingsService.getAiConfig(userId);
        return ResponseEntity.ok(ApiResponse.of(response));
    }

    /**
     * 更新用户 AI 配置.
     */
    @PutMapping("/ai-config")
    public ResponseEntity<ApiResponse<AiConfigResponse>> updateAiConfig(
        @AuthenticationPrincipal UUID userId,
        @Valid @RequestBody AiConfigRequest request
    ) {
        AiConfigResponse response = settingsService.updateAiConfig(userId, request);
        return ResponseEntity.ok(ApiResponse.of(response));
    }

    /**
     * 检查用户是否已配置 AI.
     */
    @GetMapping("/ai-config/status")
    public ResponseEntity<ApiResponse<Map<String, Boolean>>> getAiConfigStatus(
        @AuthenticationPrincipal UUID userId
    ) {
        boolean configured = settingsService.hasAiConfig(userId);
        return ResponseEntity.ok(ApiResponse.of(Map.of("configured", configured)));
    }
}
