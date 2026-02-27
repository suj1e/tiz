package io.github.suj1e.chat.controller;

import io.github.suj1e.chat.dto.ChatRequest;
import io.github.suj1e.chat.dto.ConfirmRequest;
import io.github.suj1e.chat.dto.ConfirmResponse;
import io.github.suj1e.chat.dto.HistoryResponse;
import io.github.suj1e.chat.service.ChatHistoryService;
import io.github.suj1e.chat.service.ChatService;
import io.github.suj1e.chat.sse.SseEmitterService;
import io.github.suj1e.common.client.LlmClient;
import io.github.suj1e.common.response.ApiResponse;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.util.UUID;

/**
 * 对话控制器.
 * 提供对外 API.
 */
@Slf4j
@RestController
@RequestMapping("/api/chat/v1")
@RequiredArgsConstructor
public class ChatController {

    private final ChatService chatService;
    private final ChatHistoryService historyService;
    private final SseEmitterService sseEmitterService;

    /**
     * SSE 流式对话.
     * POST /api/chat/v1/stream
     */
    @PostMapping(value = "/stream", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
    public SseEmitter streamChat(
        @AuthenticationPrincipal UUID userId,
        @Valid @RequestBody ChatRequest request
    ) {
        log.info("Stream chat request from user: {}, session: {}", userId, request.sessionId());

        // 创建 SSE emitter
        SseEmitter emitter = sseEmitterService.createEmitter();

        // 异步处理对话流
        sseEmitterService.sendFlux(
            chatService.chat(userId, request.sessionId(), request.message())
        );

        return emitter;
    }

    /**
     * 确认生成题库.
     * POST /api/chat/v1/confirm
     */
    @PostMapping("/confirm")
    public ResponseEntity<ApiResponse<ConfirmResponse>> confirmGeneration(
        @AuthenticationPrincipal UUID userId,
        @Valid @RequestBody ConfirmRequest request
    ) {
        log.info("Confirm generation request from user: {}, session: {}", userId, request.sessionId());

        ConfirmResponse response = chatService.confirm(request.sessionId(), userId);
        return ResponseEntity.ok(ApiResponse.of(response));
    }

    /**
     * 获取对话历史.
     * GET /api/chat/v1/history/{id}
     */
    @GetMapping("/history/{id}")
    public ResponseEntity<ApiResponse<HistoryResponse>> getHistory(
        @AuthenticationPrincipal UUID userId,
        @PathVariable UUID id
    ) {
        log.info("Get history request from user: {}, session: {}", userId, id);

        HistoryResponse response = historyService.getHistory(id, userId);
        return ResponseEntity.ok(ApiResponse.of(response));
    }
}
