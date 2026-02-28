package io.github.suj1e.content.api.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

import java.util.List;

/**
 * 生成题目响应 DTO.
 */
public record GenerateResponse(
    @JsonProperty("knowledge_set") KnowledgeSetResponse knowledgeSet,
    List<QuestionResponse> questions,
    BatchInfo batch
) {}
