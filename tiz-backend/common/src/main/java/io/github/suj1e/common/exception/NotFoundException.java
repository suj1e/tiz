package io.github.suj1e.common.exception;

import io.github.suj1e.common.error.CommonErrorCode;

/**
 * 资源不存在异常.
 */
public class NotFoundException extends BusinessException {

    public NotFoundException(String resourceName, Object identifier) {
        super(CommonErrorCode.NOT_FOUND, String.format("%s not found with id: %s", resourceName, identifier));
    }

    public NotFoundException(String message) {
        super(CommonErrorCode.NOT_FOUND, message);
    }
}
