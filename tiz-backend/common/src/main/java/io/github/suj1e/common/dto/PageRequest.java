package io.github.suj1e.common.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import lombok.Getter;
import lombok.Setter;
import org.springframework.data.domain.Sort;

/**
 * 分页请求参数.
 */
@Getter
@Setter
public class PageRequest {

    @Min(1)
    private int page = 1;

    @Min(1)
    @Max(100)
    private int pageSize = 10;

    private String sortBy;

    private Sort.Direction sortOrder = Sort.Direction.DESC;

    /**
     * 转换为 Spring Data Pageable.
     */
    public org.springframework.data.domain.Pageable toPageable() {
        if (sortBy != null && !sortBy.isBlank()) {
            return org.springframework.data.domain.PageRequest.of(
                page - 1,
                pageSize,
                Sort.by(sortOrder, sortBy)
            );
        }
        return org.springframework.data.domain.PageRequest.of(page - 1, pageSize);
    }

    /**
     * 计算偏移量.
     */
    public long offset() {
        return (long) (page - 1) * pageSize;
    }
}
