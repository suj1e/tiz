package io.github.suj1e.auth.error;

import io.github.suj1e.common.exception.BusinessException;

/**
 * 认证异常.
 */
public class AuthException extends BusinessException {

    public AuthException(AuthErrorCode errorCode) {
        super(errorCode);
    }

    public AuthException(AuthErrorCode errorCode, String message) {
        super(errorCode, message);
    }
}
