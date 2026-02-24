package io.github.suj1e.tiz.adapter.infra.domainservice.impl;

import io.github.suj1e.tiz.core.domain.Category;
import io.github.suj1e.tiz.core.domain.Content;
import io.github.suj1e.tiz.core.domainservice.ContentDomainService;
import io.github.suj1e.tiz.infra.repository.CategoryRepository;
import io.github.suj1e.tiz.infra.repository.ContentRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * Content domain service implementation.
 *
 * @author sujie
 */
@Service
@RequiredArgsConstructor
public class ContentDomainServiceImpl implements ContentDomainService {

    private final ContentRepository contentRepository;
    private final CategoryRepository categoryRepository;

    @Override
    public List<Content> getFeaturedContent(int limit) {
        Page<Content> page = contentRepository.findFeatured(PageRequest.of(0, limit));
        return page.getContent();
    }

    @Override
    public List<Content> getTrendingContent(int limit) {
        Page<Content> page = contentRepository.findTrending(PageRequest.of(0, limit));
        return page.getContent();
    }

    @Override
    public List<Content> getContent(int page, int size) {
        Page<Content> contentPage = contentRepository
                .findByStatusOrderByPublishedAtDesc(Content.Status.PUBLISHED, PageRequest.of(page, size));
        return contentPage.getContent();
    }

    @Override
    public List<Content> getContentByCategory(Long categoryId, int page, int size) {
        Page<Content> contentPage = contentRepository
                .findByCategoryIdAndStatusOrderByPublishedAtDesc(categoryId, Content.Status.PUBLISHED, PageRequest.of(page, size));
        return contentPage.getContent();
    }

    @Override
    public List<Content> searchContent(String keyword, int page, int size) {
        Page<Content> contentPage = contentRepository.searchByKeyword(keyword, PageRequest.of(page, size));
        return contentPage.getContent();
    }

    @Override
    public Content getContentById(Long id) {
        return contentRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Content not found"));
    }

    @Override
    public List<Category> getAllCategories() {
        return categoryRepository.findByIsActiveTrueOrderBySortOrderAsc();
    }

    @Override
    public Category getCategoryById(Long id) {
        return categoryRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Category not found"));
    }

    @Override
    public long getContentCountByCategory(Long categoryId) {
        return contentRepository.countByCategoryIdAndStatus(categoryId, Content.Status.PUBLISHED);
    }
}
