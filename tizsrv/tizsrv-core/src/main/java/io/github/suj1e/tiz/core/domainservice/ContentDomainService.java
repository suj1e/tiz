package io.github.suj1e.tiz.core.domainservice;

import io.github.suj1e.tiz.core.domain.Category;
import io.github.suj1e.tiz.core.domain.Content;

import java.util.List;

/**
 * Content domain service interface.
 *
 * @author sujie
 */
public interface ContentDomainService {

    /**
     * Get featured content.
     */
    List<Content> getFeaturedContent(int limit);

    /**
     * Get trending content.
     */
    List<Content> getTrendingContent(int limit);

    /**
     * Get all content with pagination.
     */
    List<Content> getContent(int page, int size);

    /**
     * Get content by category.
     */
    List<Content> getContentByCategory(Long categoryId, int page, int size);

    /**
     * Search content by keyword.
     */
    List<Content> searchContent(String keyword, int page, int size);

    /**
     * Get content by ID.
     */
    Content getContentById(Long id);

    /**
     * Get all categories.
     */
    List<Category> getAllCategories();

    /**
     * Get category by ID.
     */
    Category getCategoryById(Long id);

    /**
     * Get content count by category.
     */
    long getContentCountByCategory(Long categoryId);
}
