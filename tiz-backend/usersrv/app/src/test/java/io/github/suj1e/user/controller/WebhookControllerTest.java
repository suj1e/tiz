package io.github.suj1e.user.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import io.github.suj1e.common.exception.NotFoundException;
import io.github.suj1e.user.dto.WebhookRequest;
import io.github.suj1e.user.entity.Webhook;
import io.github.suj1e.user.service.WebhookService;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.http.MediaType;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

/**
 * WebhookController 测试.
 */
@WebMvcTest(WebhookController.class)
class WebhookControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockitoBean
    private WebhookService webhookService;

    @Test
    @DisplayName("获取 Webhook - 成功")
    @WithMockUser
    void getWebhook_Success() throws Exception {
        // Arrange
        UUID userId = UUID.randomUUID();
        Webhook webhook = Webhook.builder()
            .id(UUID.randomUUID())
            .userId(userId)
            .url("https://example.com/webhook")
            .enabled(true)
            .events(List.of("practice.completed", "quiz.completed"))
            .secret("secret123")
            .createdAt(Instant.now())
            .updatedAt(Instant.now())
            .build();

        when(webhookService.getWebhook(any(UUID.class))).thenReturn(webhook);

        // Act & Assert
        mockMvc.perform(get("/api/user/v1/webhook"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data.url").value("https://example.com/webhook"))
            .andExpect(jsonPath("$.data.enabled").value(true))
            .andExpect(jsonPath("$.data.events[0]").value("practice.completed"));
    }

    @Test
    @DisplayName("获取 Webhook - 不存在")
    @WithMockUser
    void getWebhook_NotFound() throws Exception {
        // Arrange
        when(webhookService.getWebhook(any(UUID.class)))
            .thenThrow(new NotFoundException("Webhook", UUID.randomUUID()));

        // Act & Assert
        mockMvc.perform(get("/api/user/v1/webhook"))
            .andExpect(status().isNotFound());
    }

    @Test
    @DisplayName("保存 Webhook - 成功")
    @WithMockUser
    void saveWebhook_Success() throws Exception {
        // Arrange
        UUID userId = UUID.randomUUID();
        WebhookRequest request = new WebhookRequest(
            "https://example.com/webhook",
            true,
            List.of("practice.completed"),
            "secret123"
        );

        Webhook webhook = Webhook.builder()
            .id(UUID.randomUUID())
            .userId(userId)
            .url(request.url())
            .enabled(request.enabled())
            .events(request.events())
            .secret(request.secret())
            .createdAt(Instant.now())
            .updatedAt(Instant.now())
            .build();

        when(webhookService.saveWebhook(any(UUID.class), any(WebhookRequest.class)))
            .thenReturn(webhook);

        // Act & Assert
        mockMvc.perform(post("/api/user/v1/webhook")
                .with(csrf().ignoringRequestMatchers("/api/**"))
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data.url").value("https://example.com/webhook"))
            .andExpect(jsonPath("$.data.enabled").value(true));
    }

    @Test
    @DisplayName("保存 Webhook - 无效 URL")
    @WithMockUser
    void saveWebhook_InvalidUrl() throws Exception {
        // Arrange
        WebhookRequest request = new WebhookRequest(
            "invalid-url",
            true,
            List.of("practice.completed"),
            null
        );

        // Act & Assert
        mockMvc.perform(post("/api/user/v1/webhook")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isBadRequest());
    }

    @Test
    @DisplayName("保存 Webhook - 空事件列表")
    @WithMockUser
    void saveWebhook_EmptyEvents() throws Exception {
        // Arrange
        WebhookRequest request = new WebhookRequest(
            "https://example.com/webhook",
            true,
            List.of(),
            null
        );

        // Act & Assert
        mockMvc.perform(post("/api/user/v1/webhook")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isBadRequest());
    }

    @Test
    @DisplayName("保存 Webhook - 无效事件类型")
    @WithMockUser
    void saveWebhook_InvalidEventType() throws Exception {
        // Arrange
        WebhookRequest request = new WebhookRequest(
            "https://example.com/webhook",
            true,
            List.of("invalid.event"),
            null
        );

        // Act & Assert
        mockMvc.perform(post("/api/user/v1/webhook")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isBadRequest());
    }

    @Test
    @DisplayName("删除 Webhook - 成功")
    @WithMockUser
    void deleteWebhook_Success() throws Exception {
        // Arrange
        doNothing().when(webhookService).deleteWebhook(any(UUID.class));

        // Act & Assert
        mockMvc.perform(delete("/api/user/v1/webhook")
                .with(csrf().ignoringRequestMatchers("/api/**")))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data").doesNotExist());
    }

    @Test
    @DisplayName("删除 Webhook - 不存在")
    @WithMockUser
    void deleteWebhook_NotFound() throws Exception {
        // Arrange
        doThrow(new NotFoundException("Webhook", UUID.randomUUID()))
            .when(webhookService).deleteWebhook(any(UUID.class));

        // Act & Assert
        mockMvc.perform(delete("/api/user/v1/webhook")
                .with(csrf().ignoringRequestMatchers("/api/**")))
            .andExpect(status().isNotFound());
    }

    @Test
    @DisplayName("获取 Webhook - 未认证")
    void getWebhook_Unauthorized() throws Exception {
        // Act & Assert
        mockMvc.perform(get("/api/user/v1/webhook"))
            .andExpect(status().isUnauthorized());
    }
}
