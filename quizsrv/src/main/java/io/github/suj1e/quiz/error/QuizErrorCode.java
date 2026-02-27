package io.github.suj1e.quiz.error;

import io.github.suj1e.common.error.ErrorCode;
import lombok.Getter;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;

/**
 * 测验服务错误码枚举.
 */
@Getter
@RequiredArgsConstructor
public enum QuizErrorCode implements ErrorCode {

    // QuizSession (QUIZ_6xxx)
    SESSION_NOT_FOUND("not_found_error", "QUIZ_6001", "Quiz session not found", HttpStatus.NOT_FOUND),
    SESSION_EXPIRED("validation_error", "QUIZ_6002", "Quiz session has expired", HttpStatus.BAD_REQUEST),
    SESSION_ALREADY_COMPLETED("validation_error", "QUIZ_6003", "Quiz session already completed", HttpStatus.BAD_REQUEST),
    SESSION_ACCESS_DENIED("authorization_error", "QUIZ_6004", "Access denied to quiz session", HttpStatus.FORBIDDEN),
    SESSION_IN_PROGRESS("validation_error", "QUIZ_6005", "Quiz session is still in progress", HttpStatus.BAD_REQUEST),

    // QuizResult (QUIZ_7xxx)
    RESULT_NOT_FOUND("not_found_error", "QUIZ_7001", "Quiz result not found", HttpStatus.NOT_FOUND),
    RESULT_NOT_READY("validation_error", "QUIZ_7002", "Quiz result is not ready yet", HttpStatus.BAD_REQUEST),

    // QuizAnswer (QUIZ_8xxx)
    ANSWER_VALIDATION_FAILED("validation_error", "QUIZ_8001", "Answer validation failed", HttpStatus.BAD_REQUEST),
    MISSING_ANSWERS("validation_error", "QUIZ_8002", "Some questions are not answered", HttpStatus.BAD_REQUEST),

    // Grading (QUIZ_9xxx)
    GRADING_FAILED("api_error", "QUIZ_9001", "Failed to grade quiz answers", HttpStatus.INTERNAL_SERVER_ERROR);

    private final String type;
    private final String code;
    private final String message;
    private final HttpStatus httpStatus;
}
