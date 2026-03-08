package io.github.suj1e.llm.api.dto;

/**
 * 批次信息.
 */
public record BatchInfo(
    int current,
    int total,
    boolean hasMore
) {}
