package io.github.suj1e.chat.service;

import io.github.suj1e.chat.dto.HistoryResponse;
import io.github.suj1e.chat.entity.ChatMessage;
import io.github.suj1e.chat.entity.ChatSession;
import io.github.suj1e.chat.repository.ChatMessageRepository;
import io.github.suj1e.chat.repository.ChatSessionRepository;
import io.github.suj1e.common.exception.BusinessException;
import io.github.suj1e.common.exception.NotFoundException;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;

/**
 * 对话历史服务测试.
 */
@SpringBootTest
@ActiveProfiles("test")
@Transactional
class ChatHistoryServiceTest {

    @Autowired
    private ChatHistoryService historyService;

    @Autowired
    private ChatSessionRepository sessionRepository;

    @Autowired
    private ChatMessageRepository messageRepository;

    private UUID testUserId;
    private ChatSession testSession;

    @BeforeEach
    void setUp() {
        testUserId = UUID.randomUUID();

        // 创建测试会话
        testSession = ChatSession.builder()
            .userId(testUserId)
            .status(ChatSession.SessionStatus.ACTIVE)
            .build();
        testSession = sessionRepository.save(testSession);

        // 创建测试消息
        ChatMessage userMessage = ChatMessage.builder()
            .sessionId(testSession.getId())
            .role(ChatMessage.MessageRole.USER)
            .content("我想学习 Java")
            .build();
        messageRepository.save(userMessage);

        ChatMessage assistantMessage = ChatMessage.builder()
            .sessionId(testSession.getId())
            .role(ChatMessage.MessageRole.ASSISTANT)
            .content("好的，让我帮你制定学习计划")
            .build();
        messageRepository.save(assistantMessage);
    }

    @Test
    @DisplayName("获取对话历史 - 成功")
    void getHistory_success() {
        HistoryResponse response = historyService.getHistory(testSession.getId(), testUserId);

        assertNotNull(response);
        assertEquals(testSession.getId(), response.sessionId());
        assertEquals("active", response.status());
        assertEquals(2, response.messages().size());
    }

    @Test
    @DisplayName("获取对话历史 - 会话不存在")
    void getHistory_sessionNotFound() {
        UUID nonExistentId = UUID.randomUUID();

        assertThrows(NotFoundException.class, () ->
            historyService.getHistory(nonExistentId, testUserId)
        );
    }

    @Test
    @DisplayName("获取对话历史 - 无权访问")
    void getHistory_forbidden() {
        UUID otherUserId = UUID.randomUUID();

        assertThrows(BusinessException.class, () ->
            historyService.getHistory(testSession.getId(), otherUserId)
        );
    }

    @Test
    @DisplayName("获取用户会话列表")
    void getUserSessions_success() {
        var sessions = historyService.getUserSessions(testUserId);

        assertNotNull(sessions);
        assertFalse(sessions.isEmpty());
        assertEquals(1, sessions.size());
    }
}
