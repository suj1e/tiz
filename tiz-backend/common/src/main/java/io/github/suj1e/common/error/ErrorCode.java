package io.github.suj1e.common.error;

import org.springframework.http.HttpStatus;

/**
 * 错误码接口.
 */
public interface ErrorCode {

    /**
     * 错误类型 (validation_error, authentication_error, etc.)
     */
    String getType();

    /**
     * 错误码 (AUTH_1001, CONTENT_2001, etc.)
     */
    String getCode();

    /**
     * 错误消息
     */
    String getMessage();

    /**
     * HTTP 状态码
     */
    HttpStatus getHttpStatus();
}
