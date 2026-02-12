package com.nexora.gateway.exception;

import com.nexora.gateway.constants.ErrorCode;

/**
 * 认证异常.
 */
public final class AuthenticationException extends GatewayException {

    public AuthenticationException(ErrorCode errorCode) {
        super(errorCode);
    }

    public AuthenticationException(ErrorCode errorCode, String message) {
        super(errorCode, message);
    }

    public AuthenticationException(ErrorCode errorCode, Throwable cause) {
        super(errorCode, cause);
    }
}
