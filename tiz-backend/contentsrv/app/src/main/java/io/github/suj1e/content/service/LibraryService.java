package io.github.suj1e.content.service;

import io.github.suj1e.common.dto.PageRequest;
import io.github.suj1e.common.exception.NotFoundException;
import io.github.suj1e.common.response.CursorResponse;
import io.github.suj1e.content.dto.*;
import io.github.suj1e.content.entity.Category;
import io.github.suj1e.content.entity.KnowledgeSet;
import io.github.suj1e.content.entity.Tag;
import io.github.suj1e.content.repository.KnowledgeSetRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.nio.charset.StandardCharsets;
import java.util.Base64;
import java.util.Collections;
import java.util.List;
import java.util.UUID;

/**
 * 题库服务.
 */
@Service
@RequiredArgsConstructor
public class LibraryService {

    private final KnowledgeSetRepository knowledgeSetRepository;
    private final CategoryService categoryService;
    private final TagService tagService;
    private final QuestionService questionService;

    /**
     * 分页查询用户的题库列表.
     */
    @Transactional(readOnly = true)
    public CursorResponse<LibrarySummaryResponse> getLibraries(UUID userId, LibraryFilterRequest filter) {
        Pageable pageable = filter.toPageable();

        Page<KnowledgeSet> page = knowledgeSetRepository.findByUserIdWithFilters(
            userId,
            filter.getCategoryId(),
            filter.getDifficulty(),
            filter.getTags(),
            pageable
        );

        List<LibrarySummaryResponse> items = page.getContent().stream()
            .map(this::toSummaryResponse)
            .toList();

        boolean hasMore = page.hasNext();
        String nextToken = null;

        if (hasMore && !items.isEmpty()) {
            // Create a simple token based on the last item's ID
            LibrarySummaryResponse lastItem = items.get(items.size() - 1);
            nextToken = encodeToken(lastItem.id().toString());
        }

        return CursorResponse.of(items, hasMore, nextToken);
    }

    /**
     * Encode token for cursor pagination.
     */
    private String encodeToken(String value) {
        return Base64.getEncoder().encodeToString(
            ("{\"id\":\"" + value + "\"}").getBytes(StandardCharsets.UTF_8)
        );
    }

    /**
     * 获取题库详情.
     */
    @Transactional(readOnly = true)
    public LibraryResponse getLibraryById(UUID id, UUID userId) {
        KnowledgeSet knowledgeSet = knowledgeSetRepository.findByIdAndUserId(id, userId)
            .orElseThrow(() -> new NotFoundException("KnowledgeSet", id));
        return toDetailResponse(knowledgeSet);
    }

    /**
     * 更新题库.
     */
    @Transactional
    public LibraryResponse updateLibrary(UUID id, UUID userId, LibraryRequest request) {
        KnowledgeSet knowledgeSet = knowledgeSetRepository.findByIdAndUserId(id, userId)
            .orElseThrow(() -> new NotFoundException("KnowledgeSet", id));

        // 更新基本信息
        knowledgeSet.setTitle(request.getTitle());
        knowledgeSet.setCategoryId(request.getCategoryId());
        knowledgeSet.setDifficulty(request.getDifficulty());

        // 更新标签
        if (request.getTags() != null) {
            List<Tag> tags = tagService.getOrCreateTags(request.getTags());
            knowledgeSet.getTags().clear();
            knowledgeSet.getTags().addAll(tags);
        }

        knowledgeSet = knowledgeSetRepository.save(knowledgeSet);
        return toDetailResponse(knowledgeSet);
    }

    /**
     * 删除题库 (软删除).
     */
    @Transactional
    public void deleteLibrary(UUID id, UUID userId) {
        KnowledgeSet knowledgeSet = knowledgeSetRepository.findByIdAndUserId(id, userId)
            .orElseThrow(() -> new NotFoundException("KnowledgeSet", id));
        knowledgeSetRepository.delete(knowledgeSet);
    }

    /**
     * 获取题库实体 (内部使用).
     */
    @Transactional(readOnly = true)
    public KnowledgeSet getKnowledgeSetEntityById(UUID id) {
        return knowledgeSetRepository.findById(id)
            .orElseThrow(() -> new NotFoundException("KnowledgeSet", id));
    }

    /**
     * 更新题库的题目数量.
     */
    @Transactional
    public void updateQuestionCount(UUID knowledgeSetId) {
        KnowledgeSet knowledgeSet = knowledgeSetRepository.findById(knowledgeSetId)
            .orElseThrow(() -> new NotFoundException("KnowledgeSet", knowledgeSetId));
        long count = questionService.countByKnowledgeSetId(knowledgeSetId);
        knowledgeSet.setQuestionCount((int) count);
        knowledgeSetRepository.save(knowledgeSet);
    }

    private LibrarySummaryResponse toSummaryResponse(KnowledgeSet ks) {
        String categoryName = null;
        if (ks.getCategoryId() != null) {
            try {
                Category category = categoryService.getCategoryEntityById(ks.getCategoryId());
                categoryName = category.getName();
            } catch (NotFoundException e) {
                // Category was deleted, ignore
            }
        }

        List<String> tagNames = ks.getTags().stream()
            .map(Tag::getName)
            .toList();

        return new LibrarySummaryResponse(
            ks.getId(),
            ks.getTitle(),
            categoryName,
            tagNames,
            ks.getDifficulty().name(),
            ks.getQuestionCount(),
            ks.getCreatedAt()
        );
    }

    private LibraryResponse toDetailResponse(KnowledgeSet ks) {
        String categoryName = null;
        if (ks.getCategoryId() != null) {
            try {
                Category category = categoryService.getCategoryEntityById(ks.getCategoryId());
                categoryName = category.getName();
            } catch (NotFoundException e) {
                // Category was deleted, ignore
            }
        }

        List<String> tagNames = ks.getTags().stream()
            .map(Tag::getName)
            .toList();

        return new LibraryResponse(
            ks.getId(),
            ks.getTitle(),
            ks.getCategoryId(),
            categoryName,
            tagNames,
            ks.getDifficulty().name(),
            ks.getQuestionCount(),
            ks.getCreatedAt(),
            ks.getUpdatedAt()
        );
    }
}
