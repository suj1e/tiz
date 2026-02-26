package io.github.suj1e.common.response;

import java.util.List;

/**
 * 分页响应封装.
 *
 * @param <T> 数据项类型
 */
public record PagedResponse<T>(
    List<T> items,
    long total,
    int page,
    int limit
) {
    public int totalPages() {
        return (int) Math.ceil((double) total / limit);
    }

    public boolean hasNext() {
        return page < totalPages();
    }

    public boolean hasPrevious() {
        return page > 1;
    }

    public static <T> PagedResponse<T> of(List<T> items, long total, int page, int limit) {
        return new PagedResponse<>(items, total, page, limit);
    }
}
