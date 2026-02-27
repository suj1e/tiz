package io.github.suj1e.auth.error;

import io.github.suj1e.common.error.ErrorCode;
import lombok.Getter;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;

/**
 * 认证服务错误码.
 */
@Getter
@RequiredArgsConstructor
public enum AuthErrorCode implements ErrorCode {

    // 1xxx - 认证相关
    AUTH_1001("authentication_error", "AUTH_1001", "邮箱或密码错误", HttpStatus.UNAUTHORIZED),
    AUTH_1002("authentication_error", "AUTH_1002", "用户已存在", HttpStatus.CONFLICT),
    AUTH_1003("authentication_error", "AUTH_1003", "无效的刷新令牌", HttpStatus.UNAUTHORIZED),
    AUTH_1004("authentication_error", "AUTH_1004", "刷新令牌已过期", HttpStatus.UNAUTHORIZED),
    AUTH_1005("authentication_error", "AUTH_1005", "刷新令牌已被撤销", HttpStatus.UNAUTHORIZED),
    AUTH_1006("authentication_error", "AUTH_1006", "无效的访问令牌", HttpStatus.UNAUTHORIZED),
    AUTH_1007("authentication_error", "AUTH_1007", "访问令牌已过期", HttpStatus.UNAUTHORIZED),
    AUTH_1008("authentication_error", "AUTH_1008", "用户已被禁用", HttpStatus.FORBIDDEN),
    AUTH_1009("validation_error", "AUTH_1009", "用户不存在", HttpStatus.NOT_FOUND),
    AUTH_1010("authentication_error", "AUTH_1010", "未授权访问", HttpStatus.UNAUTHORIZED);

    private final String type;
    private final String code;
    private final String message;
    private final HttpStatus httpStatus;
}
