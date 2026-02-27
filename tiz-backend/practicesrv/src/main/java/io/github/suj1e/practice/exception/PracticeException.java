package io.github.suj1e.practice.exception;

import io.github.suj1e.common.error.ErrorCode;
import io.github.suj1e.common.exception.BusinessException;

/**
 * 练习服务异常.
 */
public class PracticeException extends BusinessException {

    public PracticeException(ErrorCode errorCode) {
        super(errorCode);
    }

    public PracticeException(ErrorCode errorCode, String message) {
        super(errorCode, message);
    }
}
