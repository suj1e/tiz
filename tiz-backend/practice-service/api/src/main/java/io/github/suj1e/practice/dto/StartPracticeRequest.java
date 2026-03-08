package io.github.suj1e.practice.dto;

import jakarta.validation.constraints.NotNull;

import java.util.UUID;

/**
 * 开始练习请求.
 */
public record StartPracticeRequest(
    @NotNull(message = "Knowledge set ID is required")
    UUID knowledgeSetId
) {}
