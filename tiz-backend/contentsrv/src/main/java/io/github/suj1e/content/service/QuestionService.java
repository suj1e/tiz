package io.github.suj1e.content.service;

import io.github.suj1e.content.dto.QuestionResponse;
import io.github.suj1e.content.entity.Question;
import io.github.suj1e.content.repository.QuestionRepository;
import io.github.suj1e.common.exception.NotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

/**
 * 题目服务.
 */
@Service
@RequiredArgsConstructor
public class QuestionService {

    private final QuestionRepository questionRepository;

    /**
     * 获取题库中的所有题目.
     */
    @Transactional(readOnly = true)
    public List<QuestionResponse> getQuestionsByKnowledgeSetId(UUID knowledgeSetId) {
        return questionRepository.findByKnowledgeSetIdOrderBySortOrderAsc(knowledgeSetId)
            .stream()
            .map(this::toResponse)
            .toList();
    }

    /**
     * 获取题库中的前N个题目.
     */
    @Transactional(readOnly = true)
    public List<QuestionResponse> getQuestionsByKnowledgeSetId(UUID knowledgeSetId, Integer limit) {
        if (limit != null && limit > 0) {
            return questionRepository
                .findTopByKnowledgeSetIdOrderBySortOrderAsc(knowledgeSetId, PageRequest.of(0, limit))
                .stream()
                .map(this::toResponse)
                .toList();
        }
        return getQuestionsByKnowledgeSetId(knowledgeSetId);
    }

    /**
     * 获取单个题目.
     */
    @Transactional(readOnly = true)
    public QuestionResponse getQuestionById(UUID id) {
        Question question = questionRepository.findById(id)
            .orElseThrow(() -> new NotFoundException("Question", id));
        return toResponse(question);
    }

    /**
     * 获取题目实体.
     */
    @Transactional(readOnly = true)
    public Question getQuestionEntityById(UUID id) {
        return questionRepository.findById(id)
            .orElseThrow(() -> new NotFoundException("Question", id));
    }

    /**
     * 统计题库中的题目数量.
     */
    @Transactional(readOnly = true)
    public long countByKnowledgeSetId(UUID knowledgeSetId) {
        return questionRepository.countByKnowledgeSetId(knowledgeSetId);
    }

    private QuestionResponse toResponse(Question question) {
        return new QuestionResponse(
            question.getId(),
            question.getType().name(),
            question.getContent(),
            question.getOptions(),
            question.getAnswer(),
            question.getExplanation(),
            question.getRubric()
        );
    }
}
