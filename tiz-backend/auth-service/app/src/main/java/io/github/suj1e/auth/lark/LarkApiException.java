package io.github.suj1e.auth.lark;

/**
 * 飞书 API 异常.
 */
public class LarkApiException extends RuntimeException {

    public LarkApiException(String message) {
        super(message);
    }

    public LarkApiException(String message, Throwable cause) {
        super(message, cause);
    }
}
