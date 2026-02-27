package io.github.suj1e.chat.dto;

import java.util.UUID;

/**
 * 确认生成响应 DTO.
 */
public record ConfirmResponse(
    /**
     * 新创建的题库 ID.
     */
    UUID knowledgeSetId,

    /**
     * 题库标题.
     */
    String title,

    /**
     * 生成的题目数量.
     */
    Integer questionCount
) {}
