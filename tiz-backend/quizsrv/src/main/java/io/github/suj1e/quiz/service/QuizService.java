package io.github.suj1e.quiz.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import io.github.suj1e.content.api.client.ContentClient;
import io.github.suj1e.content.api.dto.KnowledgeSetResponse;
import io.github.suj1e.content.api.dto.QuestionResponse;
import io.github.suj1e.common.exception.NotFoundException;
import io.github.suj1e.common.response.ApiResponse;
import io.github.suj1e.quiz.dto.QuizCompletedEvent;
import io.github.suj1e.quiz.dto.QuizResultResponse;
import io.github.suj1e.quiz.dto.StartQuizResponse;
import io.github.suj1e.quiz.dto.SubmitQuizRequest;
import io.github.suj1e.quiz.entity.QuizResult;
import io.github.suj1e.quiz.entity.QuizResultDetail;
import io.github.suj1e.quiz.entity.QuizSession;
import io.github.suj1e.common.exception.BusinessException;
import io.github.suj1e.quiz.error.QuizErrorCode;
import io.github.suj1e.quiz.repository.QuizAnswerRepository;
import io.github.suj1e.quiz.repository.QuizResultDetailRepository;
import io.github.suj1e.quiz.repository.QuizResultRepository;
import io.github.suj1e.quiz.repository.QuizSessionRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.Duration;
import java.time.Instant;
import java.util.List;
import java.util.UUID;

/**
 * 测验服务.
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class QuizService {

    private final QuizSessionRepository quizSessionRepository;
    private final QuizResultRepository quizResultRepository;
    private final QuizResultDetailRepository quizResultDetailRepository;
    private final QuizAnswerRepository quizAnswerRepository;
    private final ContentClient contentClient;
    private final GradingService gradingService;
    private final OutboxService outboxService;
    private final ObjectMapper objectMapper;

    /**
     * 开始测验.
     *
     * @param userId         用户 ID
     * @param knowledgeSetId 题库 ID
     * @param timeLimit      时间限制 (分钟)
     * @return 开始测验响应
     */
    @Transactional
    public StartQuizResponse startQuiz(UUID userId, UUID knowledgeSetId, Integer timeLimit) {
        // 获取题库信息
        ApiResponse<KnowledgeSetResponse> ksResponse =
            contentClient.getKnowledgeSet(knowledgeSetId);
        KnowledgeSetResponse knowledgeSet = ksResponse.data();

        // 获取题目列表
        ApiResponse<List<QuestionResponse>> questionsResponse =
            contentClient.getQuestions(knowledgeSetId, null);
        List<QuestionResponse> questions = questionsResponse.data();

        // 创建测验会话
        QuizSession session = new QuizSession();
        session.setUserId(userId);
        session.setKnowledgeSetId(knowledgeSetId);
        session.setTimeLimit(timeLimit);
        session.setTotalQuestions(questions.size());
        session.setStartedAt(Instant.now());

        session = quizSessionRepository.save(session);

        // 构建响应
        List<StartQuizResponse.QuestionItem> questionItems = questions.stream()
            .map(q -> new StartQuizResponse.QuestionItem(
                q.id(),
                q.type(),
                q.content(),
                q.options()
            ))
            .toList();

        return new StartQuizResponse(
            session.getId(),
            knowledgeSetId,
            knowledgeSet.title(),
            timeLimit,
            questions.size(),
            session.getStartedAt(),
            questionItems
        );
    }

    /**
     * 批量提交测验.
     *
     * @param sessionId 会话 ID
     * @param userId    用户 ID
     * @param request   提交请求
     * @return 结果 ID
     */
    @Transactional
    public UUID submitQuiz(UUID sessionId, UUID userId, SubmitQuizRequest request) {
        // 查找会话
        QuizSession session = quizSessionRepository.findByIdAndUserId(sessionId, userId)
            .orElseThrow(() -> new NotFoundException("QuizSession", sessionId));

        // 验证会话状态
        if (session.getStatus() == QuizSession.Status.completed) {
            throw new BusinessException(QuizErrorCode.SESSION_ALREADY_COMPLETED);
        }

        if (session.getStatus() == QuizSession.Status.expired) {
            throw new BusinessException(QuizErrorCode.SESSION_EXPIRED);
        }

        // 检查是否已有结果
        if (quizResultRepository.existsBySessionId(sessionId)) {
            throw new BusinessException(QuizErrorCode.SESSION_ALREADY_COMPLETED);
        }

        // 评分
        List<QuizResultDetail> details = gradingService.gradeAnswers(
            null, sessionId, session.getKnowledgeSetId(), request.answers()
        );

        // 计算总分
        BigDecimal totalScore = details.stream()
            .map(QuizResultDetail::getScore)
            .filter(s -> s != null)
            .reduce(BigDecimal.ZERO, BigDecimal::add);

        int correctCount = (int) details.stream()
            .filter(d -> Boolean.TRUE.equals(d.getIsCorrect()))
            .count();

        // 计算用时 (秒)
        int timeSpent = (int) Duration.between(session.getStartedAt(), Instant.now()).getSeconds();

        // 创建结果
        QuizResult result = new QuizResult();
        result.setSessionId(sessionId);
        result.setUserId(userId);
        result.setKnowledgeSetId(session.getKnowledgeSetId());
        result.setScore(totalScore);
        result.setTotal(BigDecimal.valueOf(details.size()));
        result.setCorrectCount(correctCount);
        result.setTimeSpent(timeSpent);
        result.setCompletedAt(Instant.now());

        result = quizResultRepository.save(result);

        // 保存结果详情
        final UUID resultId = result.getId();
        details.forEach(d -> d.setResultId(resultId));
        quizResultDetailRepository.saveAll(details);

        // 更新会话状态
        session.setStatus(QuizSession.Status.completed);
        session.setCompletedAt(Instant.now());
        quizSessionRepository.save(session);

        // 创建 Outbox 事件
        QuizCompletedEvent event = new QuizCompletedEvent(
            userId,
            result.getId(),
            sessionId,
            session.getKnowledgeSetId(),
            totalScore,
            result.getTotal(),
            correctCount,
            details.size()
        );
        outboxService.createQuizCompletedEvent(event);

        log.info("Quiz submitted: sessionId={}, resultId={}, score={}/{}",
            sessionId, resultId, totalScore, result.getTotal());

        return resultId;
    }

    /**
     * 获取测验结果.
     *
     * @param resultId 结果 ID
     * @param userId   用户 ID
     * @return 测验结果响应
     */
    @Transactional(readOnly = true)
    public QuizResultResponse getResult(UUID resultId, UUID userId) {
        QuizResult result = quizResultRepository.findById(resultId)
            .orElseThrow(() -> new NotFoundException("QuizResult", resultId));

        // 验证权限
        if (!result.getUserId().equals(userId)) {
            throw new BusinessException(QuizErrorCode.SESSION_ACCESS_DENIED);
        }

        // 获取题库信息
        String title = "";
        try {
            ApiResponse<KnowledgeSetResponse> ksResponse =
                contentClient.getKnowledgeSet(result.getKnowledgeSetId());
            title = ksResponse.data().title();
        } catch (Exception e) {
            log.warn("Failed to get knowledge set title: {}", result.getKnowledgeSetId());
        }

        // 获取详情
        List<QuizResultDetail> details = quizResultDetailRepository.findByResultId(resultId);

        List<QuizResultResponse.ResultDetailItem> detailItems = details.stream()
            .map(this::toDetailItem)
            .toList();

        return new QuizResultResponse(
            result.getId(),
            result.getSessionId(),
            result.getKnowledgeSetId(),
            title,
            result.getScore(),
            result.getTotal(),
            result.getCorrectCount(),
            result.getTotal().intValue(),
            result.getTimeSpent(),
            result.getCompletedAt(),
            detailItems
        );
    }

    /**
     * 转换为详情项.
     */
    private QuizResultResponse.ResultDetailItem toDetailItem(QuizResultDetail detail) {
        QuestionResponse question = parseQuestionSnapshot(detail.getQuestionSnapshot());

        return new QuizResultResponse.ResultDetailItem(
            detail.getQuestionId(),
            question != null ? question.type() : "unknown",
            question != null ? question.content() : "",
            question != null ? question.options() : null,
            question != null ? question.answer() : "",
            detail.getUserAnswer(),
            detail.getIsCorrect(),
            detail.getScore(),
            question != null ? question.explanation() : null,
            detail.getAiFeedback()
        );
    }

    /**
     * 解析题目快照.
     */
    private QuestionResponse parseQuestionSnapshot(String snapshot) {
        if (snapshot == null || snapshot.isEmpty()) {
            return null;
        }
        try {
            return objectMapper.readValue(snapshot, QuestionResponse.class);
        } catch (JsonProcessingException e) {
            log.error("Failed to parse question snapshot", e);
            return null;
        }
    }

}
