package io.github.suj1e.practice.error;

import io.github.suj1e.common.error.ErrorCode;
import lombok.Getter;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;

/**
 * 练习服务错误码枚举.
 */
@Getter
@RequiredArgsConstructor
public enum PracticeErrorCode implements ErrorCode {

    // Session (PRACTICE_5xxx)
    SESSION_NOT_FOUND("not_found_error", "PRACTICE_5001", "Practice session not found", HttpStatus.NOT_FOUND),
    SESSION_ACCESS_DENIED("authorization_error", "PRACTICE_5002", "Access denied to practice session", HttpStatus.FORBIDDEN),
    SESSION_ALREADY_COMPLETED("validation_error", "PRACTICE_5003", "Practice session already completed", HttpStatus.BAD_REQUEST),
    SESSION_ALREADY_ABANDONED("validation_error", "PRACTICE_5004", "Practice session already abandoned", HttpStatus.BAD_REQUEST),
    SESSION_IN_PROGRESS_EXISTS("conflict_error", "PRACTICE_5005", "An in-progress session already exists for this knowledge set", HttpStatus.CONFLICT),

    // Answer (PRACTICE_6xxx)
    ANSWER_NOT_FOUND("not_found_error", "PRACTICE_6001", "Answer not found", HttpStatus.NOT_FOUND),
    ANSWER_ALREADY_SUBMITTED("conflict_error", "PRACTICE_6002", "Answer already submitted for this question", HttpStatus.CONFLICT),

    // Grading (PRACTICE_7xxx)
    GRADING_FAILED("api_error", "PRACTICE_7001", "Failed to grade answer", HttpStatus.INTERNAL_SERVER_ERROR),
    INVALID_QUESTION_TYPE("validation_error", "PRACTICE_7002", "Invalid question type", HttpStatus.BAD_REQUEST);

    private final String type;
    private final String code;
    private final String message;
    private final HttpStatus httpStatus;
}
