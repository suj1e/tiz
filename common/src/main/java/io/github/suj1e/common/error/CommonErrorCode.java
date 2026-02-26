package io.github.suj1e.common.error;

import lombok.Getter;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;

/**
 * 通用错误码枚举.
 */
@Getter
@RequiredArgsConstructor
public enum CommonErrorCode implements ErrorCode {

    // Validation (COMMON_1xxx)
    INVALID_INPUT("validation_error", "COMMON_1001", "Invalid input", HttpStatus.BAD_REQUEST),
    MISSING_PARAMETER("validation_error", "COMMON_1002", "Missing required parameter", HttpStatus.BAD_REQUEST),
    INVALID_FORMAT("validation_error", "COMMON_1003", "Invalid format", HttpStatus.BAD_REQUEST),

    // Authentication (COMMON_2xxx)
    UNAUTHORIZED("authentication_error", "COMMON_2001", "Unauthorized", HttpStatus.UNAUTHORIZED),
    INVALID_TOKEN("authentication_error", "COMMON_2002", "Invalid token", HttpStatus.UNAUTHORIZED),
    EXPIRED_TOKEN("authentication_error", "COMMON_2003", "Token expired", HttpStatus.UNAUTHORIZED),
    INVALID_CREDENTIALS("authentication_error", "COMMON_2004", "Invalid credentials", HttpStatus.UNAUTHORIZED),
    TOKEN_REVOKED("authentication_error", "COMMON_2005", "Token has been revoked", HttpStatus.UNAUTHORIZED),

    // Authorization (COMMON_3xxx)
    FORBIDDEN("authorization_error", "COMMON_3001", "Access denied", HttpStatus.FORBIDDEN),

    // Not Found (COMMON_4xxx)
    NOT_FOUND("not_found_error", "COMMON_4001", "Resource not found", HttpStatus.NOT_FOUND),

    // Conflict (COMMON_5xxx)
    CONFLICT("conflict_error", "COMMON_5001", "Resource conflict", HttpStatus.CONFLICT),

    // Rate Limit (COMMON_6xxx)
    RATE_LIMIT_EXCEEDED("rate_limit_error", "COMMON_6001", "Rate limit exceeded", HttpStatus.TOO_MANY_REQUESTS),

    // Server Error (COMMON_9xxx)
    INTERNAL_ERROR("api_error", "COMMON_9001", "Internal server error", HttpStatus.INTERNAL_SERVER_ERROR),
    SERVICE_UNAVAILABLE("api_error", "COMMON_9002", "Service unavailable", HttpStatus.SERVICE_UNAVAILABLE);

    private final String type;
    private final String code;
    private final String message;
    private final HttpStatus httpStatus;
}
