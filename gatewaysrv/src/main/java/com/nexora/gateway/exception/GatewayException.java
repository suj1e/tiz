package com.nexora.gateway.exception;

import com.nexora.gateway.constants.ErrorCode;
import org.springframework.http.HttpStatus;

/**
 * Gateway 基础异常.
 */
public sealed class GatewayException extends RuntimeException
    permits AuthenticationException, RateLimitException, CircuitBreakerException {

    private final ErrorCode errorCode;

    public GatewayException(ErrorCode errorCode) {
        super(errorCode.getMessage());
        this.errorCode = errorCode;
    }

    public GatewayException(ErrorCode errorCode, String message) {
        super(message);
        this.errorCode = errorCode;
    }

    public GatewayException(ErrorCode errorCode, Throwable cause) {
        super(errorCode.getMessage(), cause);
        this.errorCode = errorCode;
    }

    public ErrorCode getErrorCode() {
        return errorCode;
    }

    public HttpStatus getHttpStatus() {
        return errorCode.getHttpStatus();
    }
}
