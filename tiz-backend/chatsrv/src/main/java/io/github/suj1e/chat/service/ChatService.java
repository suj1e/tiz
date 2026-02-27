package io.github.suj1e.chat.service;

import io.github.suj1e.chat.dto.ConfirmResponse;
import io.github.suj1e.chat.entity.ChatMessage;
import io.github.suj1e.chat.entity.ChatSession;
import io.github.suj1e.chat.error.ChatErrorCode;
import io.github.suj1e.chat.repository.ChatMessageRepository;
import io.github.suj1e.chat.repository.ChatSessionRepository;
import io.github.suj1e.common.client.ContentClient;
import io.github.suj1e.common.client.LlmClient;
import io.github.suj1e.common.exception.BusinessException;
import io.github.suj1e.common.exception.NotFoundException;
import io.github.suj1e.common.response.ApiResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import reactor.core.publisher.Flux;

import java.util.List;
import java.util.UUID;

/**
 * 对话服务.
 * 管理对话流程和会话状态.
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class ChatService {

    private final ChatSessionRepository sessionRepository;
    private final ChatMessageRepository messageRepository;
    private final LlmClient llmClient;
    private final ContentClient contentClient;

    /**
     * 处理对话请求.
     *
     * @param userId    用户 ID
     * @param sessionId 会话 ID（可选）
     * @param message   用户消息
     * @return SSE 事件流
     */
    @Transactional
    public Flux<LlmClient.ChatEvent> chat(UUID userId, UUID sessionId, String message) {
        // 获取或创建会话
        ChatSession session = getOrCreateSession(userId, sessionId);

        // 验证会话状态
        validateSession(session, userId);

        // 保存用户消息
        saveMessage(session.getId(), ChatMessage.MessageRole.USER, message);

        // 获取历史消息
        List<ChatMessage> history = messageRepository.findBySessionIdOrderByCreatedAtAsc(session.getId());
        List<LlmClient.ChatMessage> chatHistory = history.stream()
            .map(m -> new LlmClient.ChatMessage(
                m.getRole().name().toLowerCase(),
                m.getContent()
            ))
            .toList();

        // 构建请求
        LlmClient.ChatRequest request = new LlmClient.ChatRequest(
            session.getId(),
            message,
            chatHistory
        );

        // 调用 LLM 服务并处理响应
        return llmClient.chatStream(request)
            .map(event -> {
                // 如果是确认事件，保存摘要
                if ("confirm".equals(event.type()) && event.data() != null) {
                    saveSummary(session.getId(), event.data().toString());
                }
                return event;
            })
            .doOnSubscribe(s -> log.debug("Starting chat stream for session: {}", session.getId()))
            .doOnComplete(() -> log.debug("Chat stream completed for session: {}", session.getId()))
            .doOnError(e -> log.error("Chat stream error for session: {}", session.getId(), e));
    }

    /**
     * 确认生成题库.
     *
     * @param sessionId 会话 ID
     * @param userId    用户 ID
     * @return 确认响应
     */
    @Transactional
    public ConfirmResponse confirm(UUID sessionId, UUID userId) {
        // 查找会话
        ChatSession session = sessionRepository.findById(sessionId)
            .orElseThrow(() -> new NotFoundException(ChatErrorCode.CHAT_4001));

        // 验证权限
        if (!session.getUserId().equals(userId)) {
            throw new BusinessException(ChatErrorCode.CHAT_4004);
        }

        // 验证状态
        if (session.getStatus() != ChatSession.SessionStatus.ACTIVE) {
            throw new BusinessException(ChatErrorCode.CHAT_4003);
        }

        // 验证摘要
        if (session.getGeneratedSummary() == null || session.getGeneratedSummary().isEmpty()) {
            throw new BusinessException(ChatErrorCode.CHAT_4021);
        }

        // 调用 LLM 服务生成题目
        LlmClient.GenerateRequest generateRequest = new LlmClient.GenerateRequest(
            sessionId,
            10,  // batchSize
            1    // batchNumber
        );

        ApiResponse<LlmClient.GenerateResponse> generateResponse;
        try {
            generateResponse = llmClient.generateQuestions(generateRequest);
        } catch (Exception e) {
            log.error("Failed to generate questions for session: {}", sessionId, e);
            throw new BusinessException(ChatErrorCode.CHAT_4030);
        }

        // 调用 Content 服务创建题库
        // TODO: 调用 ContentClient 创建题库
        // 这里简化处理，返回模拟数据
        UUID knowledgeSetId = UUID.randomUUID();
        String title = "Generated Knowledge Set";
        int questionCount = generateResponse.data().questions().size();

        // 更新会话状态
        session.setStatus(ChatSession.SessionStatus.CONFIRMED);
        session.setConfirmedKnowledgeSetId(knowledgeSetId);
        sessionRepository.save(session);

        log.info("Confirmed session {} and created knowledge set {}", sessionId, knowledgeSetId);

        return new ConfirmResponse(knowledgeSetId, title, questionCount);
    }

    /**
     * 获取或创建会话.
     */
    private ChatSession getOrCreateSession(UUID userId, UUID sessionId) {
        if (sessionId != null) {
            return sessionRepository.findById(sessionId)
                .orElseThrow(() -> new NotFoundException(ChatErrorCode.CHAT_4001));
        }

        // 创建新会话
        ChatSession session = ChatSession.builder()
            .userId(userId)
            .status(ChatSession.SessionStatus.ACTIVE)
            .build();
        return sessionRepository.save(session);
    }

    /**
     * 验证会话状态.
     */
    private void validateSession(ChatSession session, UUID userId) {
        // 验证权限
        if (!session.getUserId().equals(userId)) {
            throw new BusinessException(ChatErrorCode.CHAT_4004);
        }

        // 验证状态
        if (session.getStatus() == ChatSession.SessionStatus.EXPIRED) {
            throw new BusinessException(ChatErrorCode.CHAT_4002);
        }

        if (session.getStatus() == ChatSession.SessionStatus.CONFIRMED) {
            throw new BusinessException(ChatErrorCode.CHAT_4003);
        }
    }

    /**
     * 保存消息.
     */
    private void saveMessage(UUID sessionId, ChatMessage.MessageRole role, String content) {
        ChatMessage message = ChatMessage.builder()
            .sessionId(sessionId)
            .role(role)
            .content(content)
            .build();
        messageRepository.save(message);
    }

    /**
     * 保存摘要.
     */
    @Transactional
    public void saveSummary(UUID sessionId, String summary) {
        sessionRepository.findById(sessionId).ifPresent(session -> {
            session.setGeneratedSummary(summary);
            sessionRepository.save(session);
        });
    }
}
