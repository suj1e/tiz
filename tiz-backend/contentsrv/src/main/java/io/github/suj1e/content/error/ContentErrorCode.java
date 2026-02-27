package io.github.suj1e.content.error;

import io.github.suj1e.common.error.ErrorCode;
import lombok.Getter;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;

/**
 * 内容服务错误码枚举.
 */
@Getter
@RequiredArgsConstructor
public enum ContentErrorCode implements ErrorCode {

    // KnowledgeSet (CONTENT_3xxx)
    KNOWLEDGE_SET_NOT_FOUND("not_found_error", "CONTENT_3001", "Knowledge set not found", HttpStatus.NOT_FOUND),
    KNOWLEDGE_SET_ALREADY_DELETED("validation_error", "CONTENT_3002", "Knowledge set already deleted", HttpStatus.BAD_REQUEST),
    KNOWLEDGE_SET_ACCESS_DENIED("authorization_error", "CONTENT_3003", "Access denied to knowledge set", HttpStatus.FORBIDDEN),

    // Question (CONTENT_4xxx)
    QUESTION_NOT_FOUND("not_found_error", "CONTENT_4001", "Question not found", HttpStatus.NOT_FOUND),
    QUESTION_GENERATION_FAILED("api_error", "CONTENT_4002", "Failed to generate questions", HttpStatus.INTERNAL_SERVER_ERROR),

    // Category (CONTENT_5xxx)
    CATEGORY_NOT_FOUND("not_found_error", "CONTENT_5001", "Category not found", HttpStatus.NOT_FOUND),
    CATEGORY_ALREADY_EXISTS("conflict_error", "CONTENT_5002", "Category already exists", HttpStatus.CONFLICT),

    // Tag (CONTENT_6xxx)
    TAG_NOT_FOUND("not_found_error", "CONTENT_6001", "Tag not found", HttpStatus.NOT_FOUND),
    TAG_ALREADY_EXISTS("conflict_error", "CONTENT_6002", "Tag already exists", HttpStatus.CONFLICT);

    private final String type;
    private final String code;
    private final String message;
    private final HttpStatus httpStatus;
}
