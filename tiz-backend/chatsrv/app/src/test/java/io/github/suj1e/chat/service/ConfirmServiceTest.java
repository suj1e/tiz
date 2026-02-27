package io.github.suj1e.chat.service;

import io.github.suj1e.chat.dto.ConfirmResponse;
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
 * 确认生成服务测试.
 */
@SpringBootTest
@ActiveProfiles("test")
@Transactional
class ConfirmServiceTest {

    @Autowired
    private ChatService chatService;

    @Autowired
    private ChatSessionRepository sessionRepository;

    @Autowired
    private ChatMessageRepository messageRepository;

    private UUID testUserId;

    @BeforeEach
    void setUp() {
        testUserId = UUID.randomUUID();
    }

    @Test
    @DisplayName("确认生成 - 会话不存在")
    void confirm_sessionNotFound() {
        UUID nonExistentId = UUID.randomUUID();

        assertThrows(NotFoundException.class, () ->
            chatService.confirm(nonExistentId, testUserId)
        );
    }

    @Test
    @DisplayName("确认生成 - 无权访问")
    void confirm_forbidden() {
        // 创建属于其他用户的会话
        UUID otherUserId = UUID.randomUUID();
        ChatSession session = ChatSession.builder()
            .userId(otherUserId)
            .status(ChatSession.SessionStatus.ACTIVE)
            .generatedSummary("{\"title\":\"Test\"}")
            .build();
        session = sessionRepository.save(session);

        assertThrows(BusinessException.class, () ->
            chatService.confirm(session.getId(), testUserId)
        );
    }

    @Test
    @DisplayName("确认生成 - 会话已确认")
    void confirm_alreadyConfirmed() {
        ChatSession session = ChatSession.builder()
            .userId(testUserId)
            .status(ChatSession.SessionStatus.CONFIRMED)
            .generatedSummary("{\"title\":\"Test\"}")
            .build();
        session = sessionRepository.save(session);

        assertThrows(BusinessException.class, () ->
            chatService.confirm(session.getId(), testUserId)
        );
    }

    @Test
    @DisplayName("确认生成 - 摘要为空")
    void confirm_noSummary() {
        ChatSession session = ChatSession.builder()
            .userId(testUserId)
            .status(ChatSession.SessionStatus.ACTIVE)
            .build();
        session = sessionRepository.save(session);

        assertThrows(BusinessException.class, () ->
            chatService.confirm(session.getId(), testUserId)
        );
    }
}
