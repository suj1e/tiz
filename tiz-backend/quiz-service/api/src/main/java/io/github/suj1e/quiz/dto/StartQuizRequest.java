package io.github.suj1e.quiz.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

/**
 * 开始测验请求 DTO.
 */
public record StartQuizRequest(
    @JsonProperty("knowledge_set_id") java.util.UUID knowledgeSetId,
    @JsonProperty("time_limit") Integer timeLimit
) {}
