package io.github.suj1e.user.controller;

import io.github.suj1e.common.response.ApiResponse;
import io.github.suj1e.user.dto.AiConfigResponse;
import io.github.suj1e.user.service.SettingsService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

/**
 * 内部 AI 配置控制器.
 * 供其他微服务调用.
 */
@RestController
@RequestMapping("/internal/user/v1")
@RequiredArgsConstructor
public class InternalAiConfigController {

    private final SettingsService settingsService;

    /**
     * 获取用户的 AI 配置.
     * 供其他服务查询用户的 AI 配置以便调用 LLM.
     * 如果用户未配置，返回 404.
     */
    @GetMapping("/ai-config")
    public ResponseEntity<ApiResponse<AiConfigResponse>> getAiConfig(
        @RequestParam("user_id") UUID userId
    ) {
        if (!settingsService.hasAiConfig(userId)) {
            return ResponseEntity.notFound().build();
        }
        AiConfigResponse response = settingsService.getAiConfig(userId);
        return ResponseEntity.ok(ApiResponse.of(response));
    }

    /**
     * 检查用户是否已配置 AI.
     * 供其他服务快速检查用户 AI 配置状态.
     */
    @GetMapping("/ai-config/status")
    public ResponseEntity<ApiResponse<AiConfigStatusResponse>> getAiConfigStatus(
        @RequestParam("user_id") UUID userId
    ) {
        boolean configured = settingsService.hasAiConfig(userId);
        return ResponseEntity.ok(ApiResponse.of(new AiConfigStatusResponse(configured)));
    }

    /**
     * AI 配置状态响应.
     */
    public record AiConfigStatusResponse(boolean configured) {}
}
