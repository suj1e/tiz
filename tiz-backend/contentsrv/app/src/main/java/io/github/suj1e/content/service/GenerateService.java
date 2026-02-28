package io.github.suj1e.content.service;

import io.github.suj1e.common.exception.NotFoundException;
import io.github.suj1e.common.response.ApiResponse;
import io.github.suj1e.content.api.dto.*;
import io.github.suj1e.content.entity.KnowledgeSet;
import io.github.suj1e.content.entity.Question;
import io.github.suj1e.content.repository.KnowledgeSetRepository;
import io.github.suj1e.content.repository.QuestionRepository;
import io.github.suj1e.llm.api.client.LlmClient;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

/**
 * 生成题目服务.
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class GenerateService {

    private final LlmClient llmClient;
    private final KnowledgeSetRepository knowledgeSetRepository;
    private final QuestionRepository questionRepository;

    private static final int DEFAULT_BATCH_SIZE = 10;

    /**
     * 生成题目.
     *
     * @param userId  用户 ID
     * @param request 生成请求
     * @return 生成响应
     */
    @Transactional
    public GenerateResponse generate(UUID userId, io.github.suj1e.content.api.dto.GenerateRequest request) {
        // 调用 LLM 服务生成题目
        io.github.suj1e.llm.api.dto.GenerateRequest llmRequest =
            new io.github.suj1e.llm.api.dto.GenerateRequest(
                request.sessionId(),
                DEFAULT_BATCH_SIZE,
                1
            );

        ApiResponse<io.github.suj1e.llm.api.dto.GenerateResponse> llmResponse =
            llmClient.generateQuestions(llmRequest);

        io.github.suj1e.llm.api.dto.GenerateResponse llmData = llmResponse.data();

        // 如果需要保存，创建题库和题目
        KnowledgeSetResponse knowledgeSetResponse = null;
        List<QuestionResponse> questionResponses = new ArrayList<>();

        if (request.save() && llmData.questions() != null && !llmData.questions().isEmpty()) {
            // 创建题库
            KnowledgeSet knowledgeSet = createKnowledgeSet(userId, request.sessionId());
            knowledgeSet = knowledgeSetRepository.save(knowledgeSet);

            // 保存题目
            List<Question> questions = createQuestions(knowledgeSet.getId(), llmData.questions());
            questions = questionRepository.saveAll(questions);

            // 更新题库的题目数量
            knowledgeSet.setQuestionCount(questions.size());
            knowledgeSetRepository.save(knowledgeSet);

            // 构建响应
            knowledgeSetResponse = toKnowledgeSetResponse(knowledgeSet, questions.size());
            questionResponses = questions.stream()
                .map(this::toQuestionResponse)
                .toList();

            log.info("Generated and saved {} questions for knowledge set {}",
                questions.size(), knowledgeSet.getId());
        } else {
            // 不保存，仅返回生成的题目信息
            questionResponses = llmData.questions().stream()
                .map(this::toQuestionResponseFromDto)
                .toList();
        }

        // 构建批次信息
        BatchInfo batchInfo = new BatchInfo(
            llmData.batch().current(),
            llmData.batch().total(),
            llmData.batch().hasMore()
        );

        return new GenerateResponse(knowledgeSetResponse, questionResponses, batchInfo);
    }

    /**
     * 获取后续批次题目.
     *
     * @param userId         用户 ID
     * @param knowledgeSetId 题库 ID
     * @param page           页码
     * @return 批次响应
     */
    @Transactional
    public BatchResponse getBatch(UUID userId, UUID knowledgeSetId, int page) {
        // 验证题库存在且属于用户
        KnowledgeSet knowledgeSet = knowledgeSetRepository.findByIdAndUserId(knowledgeSetId, userId)
            .orElseThrow(() -> new NotFoundException("KnowledgeSet", knowledgeSetId));

        // 调用 LLM 服务获取后续批次
        io.github.suj1e.llm.api.dto.GenerateRequest llmRequest =
            new io.github.suj1e.llm.api.dto.GenerateRequest(
                null, // sessionId not needed for batch
                DEFAULT_BATCH_SIZE,
                page
            );

        ApiResponse<io.github.suj1e.llm.api.dto.GenerateResponse> llmResponse =
            llmClient.generateQuestions(llmRequest);

        io.github.suj1e.llm.api.dto.GenerateResponse llmData = llmResponse.data();

        // 保存题目
        List<Question> questions = createQuestions(knowledgeSetId, llmData.questions());
        questions = questionRepository.saveAll(questions);

        // 更新题库的题目数量
        int currentCount = knowledgeSet.getQuestionCount() != null ? knowledgeSet.getQuestionCount() : 0;
        knowledgeSet.setQuestionCount(currentCount + questions.size());
        knowledgeSetRepository.save(knowledgeSet);

        // 构建响应
        List<QuestionResponse> questionResponses = questions.stream()
            .map(this::toQuestionResponse)
            .toList();

        BatchInfo batchInfo = new BatchInfo(
            llmData.batch().current(),
            llmData.batch().total(),
            llmData.batch().hasMore()
        );

        log.info("Generated and saved batch {} with {} questions for knowledge set {}",
            page, questions.size(), knowledgeSetId);

        return new BatchResponse(questionResponses, batchInfo);
    }

    /**
     * 创建题库实体.
     */
    private KnowledgeSet createKnowledgeSet(UUID userId, UUID sessionId) {
        KnowledgeSet knowledgeSet = new KnowledgeSet();
        knowledgeSet.setUserId(userId);
        knowledgeSet.setTitle("Generated Questions");
        knowledgeSet.setDifficulty(KnowledgeSet.Difficulty.medium);
        knowledgeSet.setQuestionCount(0);
        return knowledgeSet;
    }

    /**
     * 创建题目实体列表.
     */
    private List<Question> createQuestions(UUID knowledgeSetId,
                                            List<io.github.suj1e.llm.api.dto.GenerateResponse.QuestionDto> questionDtos) {
        List<Question> questions = new ArrayList<>();
        for (int i = 0; i < questionDtos.size(); i++) {
            io.github.suj1e.llm.api.dto.GenerateResponse.QuestionDto dto = questionDtos.get(i);
            Question question = new Question();
            question.setKnowledgeSetId(knowledgeSetId);
            question.setType(Question.Type.valueOf(dto.type()));
            question.setContent(dto.content());
            question.setOptions(dto.options());
            question.setAnswer(dto.answer());
            question.setExplanation(dto.explanation());
            question.setRubric(dto.rubric());
            question.setSortOrder(i + 1);
            questions.add(question);
        }
        return questions;
    }

    /**
     * 转换为 KnowledgeSetResponse.
     */
    private KnowledgeSetResponse toKnowledgeSetResponse(KnowledgeSet ks, int questionCount) {
        return new KnowledgeSetResponse(
            ks.getId(),
            ks.getTitle(),
            null, // category - not set during generation
            null, // tags - not set during generation
            ks.getDifficulty() != null ? ks.getDifficulty().name().toLowerCase() : null,
            questionCount
        );
    }

    /**
     * 转换为 QuestionResponse.
     */
    private QuestionResponse toQuestionResponse(Question q) {
        return new QuestionResponse(
            q.getId(),
            q.getType().name().toLowerCase(),
            q.getContent(),
            q.getOptions(),
            q.getAnswer(),
            q.getExplanation(),
            q.getRubric()
        );
    }

    /**
     * 从 DTO 转换为 QuestionResponse (不保存).
     */
    private QuestionResponse toQuestionResponseFromDto(
            io.github.suj1e.llm.api.dto.GenerateResponse.QuestionDto dto) {
        return new QuestionResponse(
            null, // id - not saved
            dto.type(),
            dto.content(),
            dto.options(),
            dto.answer(),
            dto.explanation(),
            dto.rubric()
        );
    }
}
