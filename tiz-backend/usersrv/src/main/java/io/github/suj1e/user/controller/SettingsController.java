package io.github.suj1e.user.controller;

import io.github.suj1e.common.response.ApiResponse;
import io.github.suj1e.user.dto.SettingsRequest;
import io.github.suj1e.user.dto.SettingsResponse;
import io.github.suj1e.user.entity.UserSettings;
import io.github.suj1e.user.service.SettingsService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

/**
 * 用户设置控制器.
 * 提供对外 API.
 */
@RestController
@RequestMapping("/api/user/v1")
@RequiredArgsConstructor
public class SettingsController {

    private final SettingsService settingsService;

    /**
     * 获取用户设置.
     */
    @GetMapping("/settings")
    public ResponseEntity<ApiResponse<SettingsResponse>> getSettings(@AuthenticationPrincipal UUID userId) {
        UserSettings settings = settingsService.getOrCreateSettings(userId);
        return ResponseEntity.ok(ApiResponse.of(SettingsResponse.from(settings)));
    }

    /**
     * 更新用户设置.
     */
    @PatchMapping("/settings")
    public ResponseEntity<ApiResponse<SettingsResponse>> updateSettings(
        @AuthenticationPrincipal UUID userId,
        @Valid @RequestBody SettingsRequest request
    ) {
        UserSettings settings = settingsService.updateSettings(userId, request);
        return ResponseEntity.ok(ApiResponse.of(SettingsResponse.from(settings)));
    }
}
