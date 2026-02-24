package io.github.suj1e.tiz.adapter.rest;

import io.github.suj1e.tiz.api.dto.response.CategoryResponse;
import io.github.suj1e.tiz.core.domain.Category;
import io.github.suj1e.tiz.core.domainservice.ContentDomainService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

/**
 * Category controller.
 *
 * @author sujie
 */
@RestController
@RequestMapping("/v1/categories")
@RequiredArgsConstructor
public class CategoryController {

    private final ContentDomainService contentDomainService;

    /**
     * Get all categories.
     */
    @GetMapping
    public ResponseEntity<List<CategoryResponse>> getAllCategories() {
        List<Category> categories = contentDomainService.getAllCategories();
        List<CategoryResponse> responses = categories.stream()
                .map(this::toCategoryResponse)
                .collect(Collectors.toList());
        return ResponseEntity.ok(responses);
    }

    /**
     * Get category by ID.
     */
    @GetMapping("/{id}")
    public ResponseEntity<CategoryResponse> getCategoryById(@PathVariable Long id) {
        Category category = contentDomainService.getCategoryById(id);
        return ResponseEntity.ok(toCategoryResponse(category));
    }

    private CategoryResponse toCategoryResponse(Category category) {
        long contentCount = contentDomainService.getContentCountByCategory(category.getId());
        return CategoryResponse.builder()
                .id(category.getId())
                .name(category.getName())
                .description(category.getDescription())
                .iconUrl(category.getIconUrl())
                .parentId(category.getParentId())
                .sortOrder(category.getSortOrder())
                .contentCount(contentCount)
                .build();
    }
}
