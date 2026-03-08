package io.github.suj1e.practice.exception;

import io.github.suj1e.common.error.ErrorCode;
import io.github.suj1e.common.exception.BusinessException;

/**
 * 评分异常.
 */
public class GradingException extends BusinessException {

    public GradingException(ErrorCode errorCode) {
        super(errorCode);
    }

    public GradingException(ErrorCode errorCode, String message) {
        super(errorCode, message);
    }

    public GradingException(ErrorCode errorCode, String message, Throwable cause) {
        super(errorCode, message, cause);
    }
}
