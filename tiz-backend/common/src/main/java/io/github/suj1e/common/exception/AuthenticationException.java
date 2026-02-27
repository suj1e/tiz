package io.github.suj1e.common.exception;

import io.github.suj1e.common.error.CommonErrorCode;
import io.github.suj1e.common.error.ErrorCode;

/**
 * 认证异常.
 */
public class AuthenticationException extends BusinessException {

    public AuthenticationException(ErrorCode errorCode) {
        super(errorCode);
    }

    public AuthenticationException(ErrorCode errorCode, String message) {
        super(errorCode, message);
    }

    public AuthenticationException(String message) {
        super(CommonErrorCode.UNAUTHORIZED, message);
    }
}
