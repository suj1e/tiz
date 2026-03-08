package io.github.suj1e.user.error;

import io.github.suj1e.common.error.ErrorCode;
import lombok.Getter;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;

/**
 * 用户服务错误码.
 */
@Getter
@RequiredArgsConstructor
public enum UserErrorCode implements ErrorCode {

    // 2xxx - 用户设置相关
    USER_2001("validation_error", "USER_2001", "无效的主题设置", HttpStatus.BAD_REQUEST),
    USER_2002("not_found_error", "USER_2002", "用户设置不存在", HttpStatus.NOT_FOUND),

    // 2xxx - Webhook 相关
    USER_2010("validation_error", "USER_2010", "无效的 Webhook URL", HttpStatus.BAD_REQUEST),
    USER_2011("validation_error", "USER_2011", "无效的 Webhook 事件类型", HttpStatus.BAD_REQUEST),
    USER_2012("not_found_error", "USER_2012", "Webhook 不存在", HttpStatus.NOT_FOUND),
    USER_2013("conflict_error", "USER_2013", "用户已存在 Webhook 配置", HttpStatus.CONFLICT);

    private final String type;
    private final String code;
    private final String message;
    private final HttpStatus httpStatus;
}
