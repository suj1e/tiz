package com.nexora.gateway.exception;

import com.nexora.gateway.constants.ErrorCode;

/**
 * 熔断器异常.
 */
public final class CircuitBreakerException extends GatewayException {

    private final String serviceName;

    public CircuitBreakerException(ErrorCode errorCode, String message, String serviceName) {
        super(errorCode, message);
        this.serviceName = serviceName;
    }

    public CircuitBreakerException(ErrorCode errorCode, String serviceName) {
        super(errorCode, String.format("%s: %s", serviceName, errorCode.getMessage()));
        this.serviceName = serviceName;
    }

    public String getServiceName() {
        return serviceName;
    }
}
