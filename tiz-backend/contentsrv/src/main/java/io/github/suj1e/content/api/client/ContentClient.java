package io.github.suj1e.content.api.client;

import io.github.suj1e.content.api.dto.KnowledgeSetResponse;
import io.github.suj1e.content.api.dto.QuestionResponse;
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
}
