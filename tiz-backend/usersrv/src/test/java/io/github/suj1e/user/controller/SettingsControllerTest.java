package io.github.suj1e.user.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import io.github.suj1e.user.dto.SettingsRequest;
import io.github.suj1e.user.dto.SettingsResponse;
import io.github.suj1e.user.entity.UserSettings;
import io.github.suj1e.user.service.SettingsService;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.http.MediaType;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

import java.time.Instant;
import java.util.UUID;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.patch;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

/**
 * SettingsController 测试.
 */
@WebMvcTest(SettingsController.class)
class SettingsControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockitoBean
    private SettingsService settingsService;

    @Test
    @DisplayName("获取设置 - 成功")
    @WithMockUser
    void getSettings_Success() throws Exception {
        // Arrange
        UUID userId = UUID.randomUUID();
        UserSettings settings = UserSettings.builder()
            .userId(userId)
            .theme("dark")
            .createdAt(Instant.now())
            .updatedAt(Instant.now())
            .build();

        when(settingsService.getOrCreateSettings(any(UUID.class))).thenReturn(settings);

        // Act & Assert
        mockMvc.perform(get("/api/user/v1/settings"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data.theme").value("dark"));
    }

    @Test
    @DisplayName("获取设置 - 自动创建默认设置")
    @WithMockUser
    void getSettings_AutoCreate() throws Exception {
        // Arrange
        UUID userId = UUID.randomUUID();
        UserSettings settings = UserSettings.builder()
            .userId(userId)
            .theme("system")
            .createdAt(Instant.now())
            .updatedAt(Instant.now())
            .build();

        when(settingsService.getOrCreateSettings(any(UUID.class))).thenReturn(settings);

        // Act & Assert
        mockMvc.perform(get("/api/user/v1/settings"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data.theme").value("system"));
    }

    @Test
    @DisplayName("更新设置 - 成功")
    @WithMockUser
    void updateSettings_Success() throws Exception {
        // Arrange
        UUID userId = UUID.randomUUID();
        SettingsRequest request = new SettingsRequest("light");
        UserSettings settings = UserSettings.builder()
            .userId(userId)
            .theme("light")
            .createdAt(Instant.now())
            .updatedAt(Instant.now())
            .build();

        when(settingsService.updateSettings(any(UUID.class), any(SettingsRequest.class)))
            .thenReturn(settings);

        // Act & Assert
        mockMvc.perform(patch("/api/user/v1/settings")
                .with(csrf().ignoringRequestMatchers("/api/**"))
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data.theme").value("light"));
    }

    @Test
    @DisplayName("更新设置 - 无效主题")
    @WithMockUser
    void updateSettings_InvalidTheme() throws Exception {
        // Arrange
        SettingsRequest request = new SettingsRequest("invalid");

        // Act & Assert
        mockMvc.perform(patch("/api/user/v1/settings")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isBadRequest());
    }

    @Test
    @DisplayName("获取设置 - 未认证")
    void getSettings_Unauthorized() throws Exception {
        // Act & Assert
        mockMvc.perform(get("/api/user/v1/settings"))
            .andExpect(status().isUnauthorized());
    }
}
