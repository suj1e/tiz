package io.github.suj1e.common.client;

import io.github.suj1e.common.response.ApiResponse;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.service.annotation.HttpExchange;
import org.springframework.web.service.annotation.PostExchange;
import reactor.core.publisher.Flux;

import java.util.List;
import java.util.UUID;

/**
 * LLM 服务客户端.
 */
@HttpExchange
public interface LlmClient {

    @PostExchange("/internal/llm/v1/chat/stream")
    Flux<ChatEvent> chatStream(@RequestBody ChatRequest request);

    @PostExchange("/internal/llm/v1/generate")
    ApiResponse<GenerateResponse> generateQuestions(@RequestBody GenerateRequest request);

    @PostExchange("/internal/llm/v1/grade")
    ApiResponse<GradeResponse> gradeAnswer(@RequestBody GradeRequest request);

    /**
     * 对话请求.
     */
    record ChatRequest(
        UUID sessionId,
        String message,
        List<ChatMessage> history
    ) {}

    /**
     * 对话消息.
     */
    record ChatMessage(
        String role,
        String content
    ) {}

    /**
     * 对话事件.
     */
    record ChatEvent(
        String type,
        Object data
    ) {}

    /**
     * 生成题目请求.
     */
    record GenerateRequest(
        UUID sessionId,
        Integer batchSize,
        Integer batchNumber
    ) {}

    /**
     * 生成题目响应.
     */
    record GenerateResponse(
        List<ContentClient.QuestionResponse> questions,
        BatchInfo batch
    ) {}

    /**
     * 批次信息.
     */
    record BatchInfo(
        int current,
        int total,
        boolean hasMore
    ) {}

    /**
     * 评分请求.
     */
    record GradeRequest(
        UUID questionId,
        String questionContent,
        String correctAnswer,
        String rubric,
        String userAnswer
    ) {}

    /**
     * 评分响应.
     */
    record GradeResponse(
        Integer score,
        Integer maxScore,
        Boolean correct,
        String feedback
    ) {}
}
