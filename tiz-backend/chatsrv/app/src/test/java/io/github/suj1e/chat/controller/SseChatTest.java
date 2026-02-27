package io.github.suj1e.chat.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import io.github.suj1e.chat.dto.ChatRequest;
import io.github.suj1e.chat.entity.ChatSession;
import io.github.suj1e.chat.repository.ChatSessionRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.transaction.annotation.Transactional;

import java.util.Collections;
import java.util.UUID;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

/**
 * SSE 对话测试.
 */
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
@Transactional
class SseChatTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private ChatSessionRepository sessionRepository;

    private UUID testUserId;

    @BeforeEach
    void setUp() {
        testUserId = UUID.randomUUID();

        UsernamePasswordAuthenticationToken authentication =
            new UsernamePasswordAuthenticationToken(testUserId, null, Collections.emptyList());
        SecurityContextHolder.getContext().setAuthentication(authentication);
    }

    @Test
    @DisplayName("SSE 对话 - 开始新会话")
    void sseChat_newSession() throws Exception {
        ChatRequest request = new ChatRequest(null, "我想学习 Spring Boot");

        mockMvc.perform(post("/api/chat/v1/stream")
                .principal(() -> testUserId.toString())
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isOk())
            .andExpect(request().asyncStarted());
    }

    @Test
    @DisplayName("SSE 对话 - 继续现有会话")
    void sseChat_existingSession() throws Exception {
        // 创建已存在的会话
        ChatSession session = ChatSession.builder()
            .userId(testUserId)
            .status(ChatSession.SessionStatus.ACTIVE)
            .build();
        session = sessionRepository.save(session);

        ChatRequest request = new ChatRequest(session.getId(), "继续学习");

        mockMvc.perform(post("/api/chat/v1/stream")
                .principal(() -> testUserId.toString())
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isOk())
            .andExpect(request().asyncStarted());
    }

    @Test
    @DisplayName("SSE 对话 - 会话不存在")
    void sseChat_sessionNotFound() throws Exception {
        UUID nonExistentId = UUID.randomUUID();
        ChatRequest request = new ChatRequest(nonExistentId, "测试消息");

        // SSE 端点会启动流，错误会在流中返回
        mockMvc.perform(post("/api/chat/v1/stream")
                .principal(() -> testUserId.toString())
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isOk());
    }

    @Test
    @DisplayName("SSE 对话 - 消息为空")
    void sseChat_emptyMessage() throws Exception {
        ChatRequest request = new ChatRequest(null, "");

        mockMvc.perform(post("/api/chat/v1/stream")
                .principal(() -> testUserId.toString())
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isBadRequest());
    }
}
