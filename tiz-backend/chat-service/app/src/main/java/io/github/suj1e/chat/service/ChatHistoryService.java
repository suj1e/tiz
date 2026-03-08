package io.github.suj1e.chat.service;

import io.github.suj1e.chat.dto.HistoryResponse;
import io.github.suj1e.chat.entity.ChatMessage;
import io.github.suj1e.chat.entity.ChatSession;
import io.github.suj1e.chat.error.ChatErrorCode;
import io.github.suj1e.chat.repository.ChatMessageRepository;
import io.github.suj1e.chat.repository.ChatSessionRepository;
import io.github.suj1e.common.exception.BusinessException;
import io.github.suj1e.common.exception.NotFoundException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

/**
 * 对话历史服务.
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class ChatHistoryService {

    private final ChatSessionRepository sessionRepository;
    private final ChatMessageRepository messageRepository;

    /**
     * 获取对话历史.
     *
     * @param sessionId 会话 ID
     * @param userId    用户 ID
     * @return 对话历史响应
     */
    @Transactional(readOnly = true)
    public HistoryResponse getHistory(UUID sessionId, UUID userId) {
        // 查找会话
        ChatSession session = sessionRepository.findById(sessionId)
            .orElseThrow(() -> new NotFoundException("ChatSession", sessionId));

        // 验证权限
        if (!session.getUserId().equals(userId)) {
            throw new BusinessException(ChatErrorCode.CHAT_4004);
        }

        // 获取消息列表
        List<ChatMessage> messages = messageRepository.findBySessionIdOrderByCreatedAtAsc(sessionId);

        // 转换为响应
        List<HistoryResponse.MessageItem> messageItems = messages.stream()
            .map(m -> new HistoryResponse.MessageItem(
                m.getId(),
                m.getRole().name().toLowerCase(),
                m.getContent(),
                m.getCreatedAt()
            ))
            .toList();

        return new HistoryResponse(
            session.getId(),
            session.getStatus().name().toLowerCase(),
            messageItems
        );
    }

    /**
     * 获取用户的所有对话会话.
     *
     * @param userId 用户 ID
     * @return 会话列表
     */
    @Transactional(readOnly = true)
    public List<ChatSession> getUserSessions(UUID userId) {
        return sessionRepository.findByUserIdOrderByCreatedAtDesc(userId);
    }

    /**
     * 获取会话的消息列表（用于发送给 LLM 服务）.
     *
     * @param sessionId 会话 ID
     * @return 消息列表
     */
    @Transactional(readOnly = true)
    public List<ChatMessage> getSessionMessages(UUID sessionId) {
        return messageRepository.findBySessionIdOrderByCreatedAtAsc(sessionId);
    }
}
