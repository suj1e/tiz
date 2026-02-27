package io.github.suj1e.chat.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import io.github.suj1e.chat.dto.ChatRequest;
import io.github.suj1e.chat.dto.ConfirmRequest;
import io.github.suj1e.chat.entity.ChatSession;
import io.github.suj1e.chat.repository.ChatMessageRepository;
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

import static org.hamcrest.Matchers.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

/**
 * 对话控制器测试.
 */
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
@Transactional
class ChatControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private ChatSessionRepository sessionRepository;

    @Autowired
    private ChatMessageRepository messageRepository;

    private UUID testUserId;

    @BeforeEach
    void setUp() {
        testUserId = UUID.randomUUID();

        // 设置认证
        UsernamePasswordAuthenticationToken authentication =
            new UsernamePasswordAuthenticationToken(testUserId, null, Collections.emptyList());
        SecurityContextHolder.getContext().setAuthentication(authentication);
    }

    @Test
    @DisplayName("开始新对话 - 应返回 SSE 流")
    void startNewChat_shouldReturnSseStream() throws Exception {
        ChatRequest request = new ChatRequest(null, "我想学习 Java 基础知识");

        mockMvc.perform(post("/api/chat/v1/stream")
                .principal(() -> testUserId.toString())
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isOk())
            .andExpect(request().asyncStarted());
    }

    @Test
    @DisplayName("获取对话历史 - 会话不存在应返回 404")
    void getHistory_sessionNotFound_shouldReturn404() throws Exception {
        UUID nonExistentSessionId = UUID.randomUUID();

        mockMvc.perform(get("/api/chat/v1/history/{id}", nonExistentSessionId)
                .principal(() -> testUserId.toString()))
            .andExpect(status().isNotFound());
    }

    @Test
    @DisplayName("获取对话历史 - 成功")
    void getHistory_success() throws Exception {
        // 创建测试会话
        ChatSession session = ChatSession.builder()
            .userId(testUserId)
            .status(ChatSession.SessionStatus.ACTIVE)
            .build();
        session = sessionRepository.save(session);

        mockMvc.perform(get("/api/chat/v1/history/{id}", session.getId())
                .principal(() -> testUserId.toString()))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data.sessionId").value(session.getId().toString()))
            .andExpect(jsonPath("$.data.status").value("active"))
            .andExpect(jsonPath("$.data.messages").isArray());
    }

    @Test
    @DisplayName("确认生成 - 会话不存在应返回 404")
    void confirm_sessionNotFound_shouldReturn404() throws Exception {
        ConfirmRequest request = new ConfirmRequest(UUID.randomUUID());

        mockMvc.perform(post("/api/chat/v1/confirm")
                .principal(() -> testUserId.toString())
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isNotFound());
    }

    @Test
    @DisplayName("确认生成 - 会话不属于用户应返回 403")
    void confirm_notOwner_shouldReturn403() throws Exception {
        // 创建属于其他用户的会话
        UUID otherUserId = UUID.randomUUID();
        ChatSession session = ChatSession.builder()
            .userId(otherUserId)
            .status(ChatSession.SessionStatus.ACTIVE)
            .build();
        session = sessionRepository.save(session);

        ConfirmRequest request = new ConfirmRequest(session.getId());

        mockMvc.perform(post("/api/chat/v1/confirm")
                .principal(() -> testUserId.toString())
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isForbidden());
    }

    @Test
    @DisplayName("确认生成 - 会话已确认应返回 400")
    void confirm_alreadyConfirmed_shouldReturn400() throws Exception {
        // 创建已确认的会话
        ChatSession session = ChatSession.builder()
            .userId(testUserId)
            .status(ChatSession.SessionStatus.CONFIRMED)
            .build();
        session = sessionRepository.save(session);

        ConfirmRequest request = new ConfirmRequest(session.getId());

        mockMvc.perform(post("/api/chat/v1/confirm")
                .principal(() -> testUserId.toString())
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isBadRequest());
    }
}
