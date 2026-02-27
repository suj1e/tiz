package io.github.suj1e.content.controller;

import io.github.suj1e.common.response.ApiResponse;
import io.github.suj1e.content.dto.KnowledgeSetInternalResponse;
import io.github.suj1e.content.dto.QuestionResponse;
import io.github.suj1e.content.entity.Category;
import io.github.suj1e.content.entity.KnowledgeSet;
import io.github.suj1e.content.entity.Tag;
import io.github.suj1e.content.service.CategoryService;
import io.github.suj1e.content.service.LibraryService;
import io.github.suj1e.content.service.QuestionService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

/**
 * 内部内容控制器 (供其他微服务调用).
 */
@RestController
@RequestMapping("/internal/content/v1")
@RequiredArgsConstructor
public class InternalContentController {

    private final LibraryService libraryService;
    private final QuestionService questionService;
    private final CategoryService categoryService;

    /**
     * 获取题库信息.
     */
    @GetMapping("/knowledge-sets/{id}")
    public ApiResponse<KnowledgeSetInternalResponse> getKnowledgeSet(@PathVariable UUID id) {
        KnowledgeSet ks = libraryService.getKnowledgeSetEntityById(id);

        String categoryName = null;
        if (ks.getCategoryId() != null) {
            try {
                Category category = categoryService.getCategoryEntityById(ks.getCategoryId());
                categoryName = category.getName();
            } catch (Exception e) {
                // Category not found, ignore
            }
        }

        List<String> tagNames = ks.getTags().stream()
            .map(Tag::getName)
            .toList();

        KnowledgeSetInternalResponse response = new KnowledgeSetInternalResponse(
            ks.getId(),
            ks.getTitle(),
            categoryName,
            tagNames,
            ks.getDifficulty().name(),
            ks.getQuestionCount()
        );

        return ApiResponse.of(response);
    }

    /**
     * 获取题库中的题目列表.
     */
    @GetMapping("/knowledge-sets/{id}/questions")
    public ApiResponse<List<QuestionResponse>> getQuestions(
        @PathVariable UUID id,
        @RequestParam(required = false) Integer limit
    ) {
        return ApiResponse.of(questionService.getQuestionsByKnowledgeSetId(id, limit));
    }

    /**
     * 获取单个题目.
     */
    @GetMapping("/questions/{id}")
    public ApiResponse<QuestionResponse> getQuestion(@PathVariable UUID id) {
        return ApiResponse.of(questionService.getQuestionById(id));
    }
}
