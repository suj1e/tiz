package io.github.suj1e.llm.api.client;

import io.github.suj1e.llm.api.dto.*;
import io.github.suj1e.common.response.ApiResponse;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.service.annotation.HttpExchange;
import org.springframework.web.service.annotation.PostExchange;
import reactor.core.publisher.Flux;

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
}
