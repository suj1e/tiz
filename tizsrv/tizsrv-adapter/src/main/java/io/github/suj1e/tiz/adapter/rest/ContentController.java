package io.github.suj1e.tiz.adapter.rest;

import io.github.suj1e.tiz.api.dto.response.CategoryResponse;
import io.github.suj1e.tiz.api.dto.response.ContentResponse;
import io.github.suj1e.tiz.core.domain.Category;
import io.github.suj1e.tiz.core.domain.Content;
import io.github.suj1e.tiz.core.domainservice.ContentDomainService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * Content controller for Explore feature.
 *
 * @author sujie
 */
@RestController
@RequestMapping("/v1/contents")
@RequiredArgsConstructor
public class ContentController {

    private final ContentDomainService contentDomainService;

    /**
     * Get featured content.
     */
    @GetMapping("/featured")
    public ResponseEntity<Map<String, Object>> getFeaturedContent(
            @RequestParam(defaultValue = "10") int limit) {
        List<Content> contentList = contentDomainService.getFeaturedContent(limit);
        List<ContentResponse> responses = contentList.stream()
                .map(this::toContentResponse)
                .collect(Collectors.toList());
        return ResponseEntity.ok(Map.of("content", responses));
    }

    /**
     * Get trending content.
     */
    @GetMapping("/trending")
    public ResponseEntity<Map<String, Object>> getTrendingContent(
            @RequestParam(defaultValue = "10") int limit) {
        List<Content> contentList = contentDomainService.getTrendingContent(limit);
        List<ContentResponse> responses = contentList.stream()
                .map(this::toContentResponse)
                .collect(Collectors.toList());
        return ResponseEntity.ok(Map.of("content", responses));
    }

    /**
     * Get all content with pagination.
     */
    @GetMapping
    public ResponseEntity<Map<String, Object>> getContent(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        List<Content> contentList = contentDomainService.getContent(page, size);
        List<ContentResponse> responses = contentList.stream()
                .map(this::toContentResponse)
                .collect(Collectors.toList());
        return ResponseEntity.ok(Map.of("content", responses));
    }

    /**
     * Get content by category.
     */
    @GetMapping("/category/{categoryId}")
    public ResponseEntity<Map<String, Object>> getContentByCategory(
            @PathVariable Long categoryId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        List<Content> contentList = contentDomainService.getContentByCategory(categoryId, page, size);
        List<ContentResponse> responses = contentList.stream()
                .map(this::toContentResponse)
                .collect(Collectors.toList());
        return ResponseEntity.ok(Map.of("content", responses));
    }

    /**
     * Search content.
     */
    @GetMapping("/search")
    public ResponseEntity<Map<String, Object>> searchContent(
            @RequestParam String keyword,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        List<Content> contentList = contentDomainService.searchContent(keyword, page, size);
        List<ContentResponse> responses = contentList.stream()
                .map(this::toContentResponse)
                .collect(Collectors.toList());
        return ResponseEntity.ok(Map.of("content", responses, "keyword", keyword));
    }

    /**
     * Get content by ID.
     */
    @GetMapping("/{id}")
    public ResponseEntity<ContentResponse> getContentById(@PathVariable Long id) {
        Content content = contentDomainService.getContentById(id);
        return ResponseEntity.ok(toContentResponse(content));
    }

    private ContentResponse toContentResponse(Content content) {
        return ContentResponse.builder()
                .id(content.getId())
                .title(content.getTitle())
                .description(content.getDescription())
                .imageUrl(content.getImageUrl())
                .contentUrl(content.getContentUrl())
                .type(content.getType().name())
                .categoryId(content.getCategoryId())
                .authorId(content.getAuthorId())
                .authorName(content.getAuthorName())
                .viewCount(content.getViewCount())
                .likeCount(content.getLikeCount())
                .isFeatured(content.getIsFeatured())
                .isTrending(content.getIsTrending())
                .publishedAt(content.getPublishedAt())
                .build();
    }
}
