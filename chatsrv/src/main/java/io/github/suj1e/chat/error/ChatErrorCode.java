package io.github.suj1e.chat.error;

import io.github.suj1e.common.error.ErrorCode;
import lombok.Getter;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;

/**
 * 对话服务错误码.
 */
@Getter
@RequiredArgsConstructor
public enum ChatErrorCode implements ErrorCode {

    // 4xxx - 对话会话相关
    CHAT_4001("not_found_error", "CHAT_4001", "对话会话不存在", HttpStatus.NOT_FOUND),
    CHAT_4002("validation_error", "CHAT_4002", "对话会话已过期", HttpStatus.BAD_REQUEST),
    CHAT_4003("validation_error", "CHAT_4003", "对话会话已确认，无法继续对话", HttpStatus.BAD_REQUEST),
    CHAT_4004("validation_error", "CHAT_4004", "无权访问该对话会话", HttpStatus.FORBIDDEN),

    // 4xxx - 对话消息相关
    CHAT_4010("validation_error", "CHAT_4010", "消息内容不能为空", HttpStatus.BAD_REQUEST),
    CHAT_4011("validation_error", "CHAT_4011", "消息内容过长", HttpStatus.BAD_REQUEST),

    // 4xxx - 确认生成相关
    CHAT_4020("validation_error", "CHAT_4020", "对话尚未完成，无法确认生成", HttpStatus.BAD_REQUEST),
    CHAT_4021("validation_error", "CHAT_4021", "生成摘要为空，无法确认", HttpStatus.BAD_REQUEST),

    // 4xxx - AI 服务相关
    CHAT_4030("api_error", "CHAT_4030", "AI 服务暂时不可用", HttpStatus.SERVICE_UNAVAILABLE),
    CHAT_4031("api_error", "CHAT_4031", "AI 服务响应超时", HttpStatus.GATEWAY_TIMEOUT),
    CHAT_4032("api_error", "CHAT_4032", "AI 服务返回错误", HttpStatus.BAD_GATEWAY);

    private final String type;
    private final String code;
    private final String message;
    private final HttpStatus httpStatus;
}
