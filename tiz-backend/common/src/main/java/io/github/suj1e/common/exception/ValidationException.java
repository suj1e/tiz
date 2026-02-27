package io.github.suj1e.common.exception;

import io.github.suj1e.common.error.CommonErrorCode;
import io.github.suj1e.common.error.ErrorCode;

/**
 * 校验异常.
 */
public class ValidationException extends BusinessException {

    public ValidationException(ErrorCode errorCode) {
        super(errorCode);
    }

    public ValidationException(ErrorCode errorCode, String message) {
        super(errorCode, message);
    }

    public ValidationException(String message) {
        super(CommonErrorCode.INVALID_INPUT, message);
    }
}
