package io.github.suj1e.common.client;

import io.github.suj1e.common.response.ApiResponse;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.service.annotation.GetExchange;
import org.springframework.web.service.annotation.HttpExchange;

import java.util.List;
import java.util.UUID;

/**
 * 内容服务客户端.
 */
@HttpExchange
public interface ContentClient {

    @GetExchange("/internal/content/v1/knowledge-sets/{id}")
    ApiResponse<KnowledgeSetResponse> getKnowledgeSet(@PathVariable UUID id);

    @GetExchange("/internal/content/v1/knowledge-sets/{id}/questions")
    ApiResponse<List<QuestionResponse>> getQuestions(
        @PathVariable UUID id,
        @RequestParam(required = false) Integer limit
    );

    @GetExchange("/internal/content/v1/questions/{id}")
    ApiResponse<QuestionResponse> getQuestion(@PathVariable UUID id);

    /**
     * 题库响应.
     */
    record KnowledgeSetResponse(
        UUID id,
        String title,
        String category,
        List<String> tags,
        String difficulty,
        Integer questionCount
    ) {}

    /**
     * 题目响应.
     */
    record QuestionResponse(
        UUID id,
        String type,
        String content,
        List<String> options,
        String answer,
        String explanation,
        String rubric
    ) {}
}
