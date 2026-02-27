package io.github.suj1e.content.service;

import io.github.suj1e.content.dto.CategoryResponse;
import io.github.suj1e.content.entity.Category;
import io.github.suj1e.content.error.ContentErrorCode;
import io.github.suj1e.content.repository.CategoryRepository;
import io.github.suj1e.common.exception.NotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

/**
 * 分类服务.
 */
@Service
@RequiredArgsConstructor
public class CategoryService {

    private final CategoryRepository categoryRepository;

    /**
     * 获取所有分类.
     */
    @Transactional(readOnly = true)
    public List<CategoryResponse> getAllCategories() {
        return categoryRepository.findAllByOrderBySortOrderAsc()
            .stream()
            .map(this::toResponse)
            .toList();
    }

    /**
     * 根据ID获取分类.
     */
    @Transactional(readOnly = true)
    public CategoryResponse getCategoryById(UUID id) {
        Category category = categoryRepository.findById(id)
            .orElseThrow(() -> new NotFoundException("Category", id));
        return toResponse(category);
    }

    /**
     * 根据ID获取分类实体.
     */
    @Transactional(readOnly = true)
    public Category getCategoryEntityById(UUID id) {
        return categoryRepository.findById(id)
            .orElseThrow(() -> new NotFoundException("Category", id));
    }

    private CategoryResponse toResponse(Category category) {
        return new CategoryResponse(
            category.getId(),
            category.getName(),
            category.getDescription(),
            category.getSortOrder()
        );
    }
}
