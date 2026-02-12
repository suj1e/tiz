package com.nexora.gateway.exception;

import com.nexora.gateway.constants.ErrorCode;

/**
 * 限流异常.
 */
public final class RateLimitException extends GatewayException {

    private final int limit;
    private final int remaining;

    public RateLimitException(ErrorCode errorCode, String message, int limit, int remaining) {
        super(errorCode, message);
        this.limit = limit;
        this.remaining = remaining;
    }

    public int getLimit() {
        return limit;
    }

    public int getRemaining() {
        return remaining;
    }
}
