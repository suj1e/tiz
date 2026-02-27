package io.github.suj1e.common.exception;

import io.github.suj1e.common.error.CommonErrorCode;

/**
 * 授权异常.
 */
public class AuthorizationException extends BusinessException {

    public AuthorizationException(String message) {
        super(CommonErrorCode.FORBIDDEN, message);
    }
}
