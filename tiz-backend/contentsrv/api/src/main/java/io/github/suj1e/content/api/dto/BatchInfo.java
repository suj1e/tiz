package io.github.suj1e.content.api.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

/**
 * 批次信息 DTO.
 */
public record BatchInfo(
    int current,
    int total,
    @JsonProperty("has_more") boolean hasMore
) {}
