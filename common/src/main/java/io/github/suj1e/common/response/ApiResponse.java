package io.github.suj1e.common.response;

import com.fasterxml.jackson.annotation.JsonInclude;

/**
 * 统一 API 响应封装.
 *
 * @param <T> 响应数据类型
 */
@JsonInclude(JsonInclude.Include.NON_NULL)
public record ApiResponse<T>(T data) {

    public static <T> ApiResponse<T> of(T data) {
        return new ApiResponse<>(data);
    }

    public static <T> ApiResponse<T> empty() {
        return new ApiResponse<>(null);
    }
}
