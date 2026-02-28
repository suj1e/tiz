package io.github.suj1e.content.api.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

import java.util.UUID;

/**
 * 生成题目请求 DTO.
 */
public record GenerateRequest(
    @JsonProperty("session_id") UUID sessionId,
    boolean save
) {}
