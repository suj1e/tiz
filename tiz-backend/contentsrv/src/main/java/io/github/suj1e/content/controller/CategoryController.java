package io.github.suj1e.content.controller;

import io.github.suj1e.common.response.ApiResponse;
import io.github.suj1e.content.dto.CategoryResponse;
import io.github.suj1e.content.service.CategoryService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

/**
 * 分类控制器 (对外 API).
 */
@RestController
@RequestMapping("/api/content/v1/categories")
@RequiredArgsConstructor
public class CategoryController {

    private final CategoryService categoryService;

    /**
     * 获取所有分类.
     */
    @GetMapping
    public ApiResponse<List<CategoryResponse>> getAllCategories() {
        return ApiResponse.of(categoryService.getAllCategories());
    }

    /**
     * 获取单个分类.
     */
    @GetMapping("/{id}")
    public ApiResponse<CategoryResponse> getCategoryById(@PathVariable UUID id) {
        return ApiResponse.of(categoryService.getCategoryById(id));
    }
}
