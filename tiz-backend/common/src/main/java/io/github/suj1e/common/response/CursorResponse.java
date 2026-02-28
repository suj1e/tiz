package io.github.suj1e.common.response;

import com.fasterxml.jackson.annotation.JsonProperty;

import java.util.List;

/**
 * 游标分页响应封装.
 *
 * @param <T> 数据项类型
 */
public record CursorResponse<T>(
    List<T> data,
    @JsonProperty("has_more") boolean hasMore,
    @JsonProperty("next_token") String nextToken
) {
    public static <T> CursorResponse<T> of(List<T> data, boolean hasMore, String nextToken) {
        return new CursorResponse<>(data, hasMore, hasMore ? nextToken : null);
    }
}
