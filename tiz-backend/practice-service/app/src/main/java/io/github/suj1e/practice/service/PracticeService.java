package io.github.suj1e.practice.service;

import io.github.suj1e.content.api.client.ContentClient;
import io.github.suj1e.content.api.dto.KnowledgeSetResponse;
import io.github.suj1e.content.api.dto.QuestionResponse;
import io.github.suj1e.common.response.ApiResponse;
import io.github.suj1e.practice.dto.*;
import io.github.suj1e.practice.entity.PracticeAnswer;
import io.github.suj1e.practice.entity.PracticeSession;
import io.github.suj1e.practice.entity.SessionStatus;
import io.github.suj1e.practice.error.PracticeErrorCode;
import io.github.suj1e.practice.exception.PracticeException;
import io.github.suj1e.practice.repository.PracticeAnswerRepository;
import io.github.suj1e.practice.repository.PracticeSessionRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

/**
 * 练习服务.
 * 负责管理练习会话的创建、答题、完成等流程.
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class PracticeService {

    private final PracticeSessionRepository sessionRepository;
    private final PracticeAnswerRepository answerRepository;
    private final ContentClient contentClient;
    private final GradingService gradingService;

    /**
     * 开始练习.
     * 创建练习会话并获取题目列表.
     *
     * @param userId         用户ID
     * @param knowledgeSetId 题库ID
     * @return 开始练习响应
     */
    @Transactional
    public StartPracticeResponse startPractice(UUID userId, UUID knowledgeSetId) {
        // 检查是否已有进行中的会话
        if (sessionRepository.existsByUserIdAndKnowledgeSetIdAndStatus(
                userId, knowledgeSetId, SessionStatus.IN_PROGRESS)) {
            throw new PracticeException(PracticeErrorCode.SESSION_IN_PROGRESS_EXISTS);
        }

        // 获取题库信息
        ApiResponse<KnowledgeSetResponse> ksResponse =
            contentClient.getKnowledgeSet(knowledgeSetId);
        if (ksResponse.data() == null) {
            throw new PracticeException(PracticeErrorCode.SESSION_NOT_FOUND,
                "Knowledge set not found: " + knowledgeSetId);
        }
        KnowledgeSetResponse knowledgeSet = ksResponse.data();

        // 获取题目列表
        ApiResponse<List<QuestionResponse>> questionsResponse =
            contentClient.getQuestions(knowledgeSetId, null);
        List<QuestionResponse> questions = questionsResponse.data();
        if (questions == null || questions.isEmpty()) {
            throw new PracticeException(PracticeErrorCode.SESSION_NOT_FOUND,
                "No questions found in knowledge set: " + knowledgeSetId);
        }

        // 创建练习会话
        PracticeSession session = new PracticeSession();
        session.setUserId(userId);
        session.setKnowledgeSetId(knowledgeSetId);
        session.setStatus(SessionStatus.IN_PROGRESS);
        session.setTotalQuestions(questions.size());
        session.setCorrectCount(0);
        session.setScore(BigDecimal.ZERO);
        session.setCreatedBy(userId);
        session.setUpdatedBy(userId);

        session = sessionRepository.save(session);

        log.info("Practice session created: {} for user: {} with {} questions",
            session.getId(), userId, questions.size());

        // 构建响应 (不包含答案)
        List<StartPracticeResponse.QuestionResponse> questionResponses = new ArrayList<>();
        for (int i = 0; i < questions.size(); i++) {
            QuestionResponse q = questions.get(i);
            questionResponses.add(new StartPracticeResponse.QuestionResponse(
                q.id(),
                q.type(),
                q.content(),
                q.options(),
                i + 1
            ));
        }

        return new StartPracticeResponse(
            session.getId(),
            knowledgeSetId,
            knowledgeSet.title(),
            questions.size(),
            questionResponses
        );
    }

    /**
     * 提交答案.
     * 保存用户答案并进行评分.
     *
     * @param userId   用户ID
     * @param sessionId 会话ID
     * @param request  提交答案请求
     * @return 提交答案响应
     */
    @Transactional
    public SubmitAnswerResponse submitAnswer(UUID userId, UUID sessionId, SubmitAnswerRequest request) {
        // 获取并验证会话
        PracticeSession session = getSessionAndValidate(userId, sessionId);

        // 验证会话状态
        if (session.getStatus() != SessionStatus.IN_PROGRESS) {
            throw new PracticeException(PracticeErrorCode.SESSION_ALREADY_COMPLETED);
        }

        // 获取题目信息
        ApiResponse<QuestionResponse> questionResponse =
            contentClient.getQuestion(request.questionId());
        if (questionResponse.data() == null) {
            throw new PracticeException(PracticeErrorCode.ANSWER_NOT_FOUND,
                "Question not found: " + request.questionId());
        }
        QuestionResponse question = questionResponse.data();

        // 评分
        GradingService.GradingResult result = gradingService.grade(question, request.answer());

        // 保存或更新答案
        PracticeAnswer answer = answerRepository
            .findBySessionIdAndQuestionId(sessionId, request.questionId())
            .orElseGet(() -> {
                PracticeAnswer newAnswer = new PracticeAnswer();
                newAnswer.setSessionId(sessionId);
                newAnswer.setQuestionId(request.questionId());
                return newAnswer;
            });

        answer.setUserAnswer(request.answer());
        answer.setIsCorrect(result.correct());
        answer.setScore(result.score());
        answer.setAiFeedback(result.feedback());
        answer.setAnsweredAt(Instant.now());

        answerRepository.save(answer);

        log.info("Answer submitted for session: {}, question: {}, correct: {}",
            sessionId, request.questionId(), result.correct());

        // 返回响应 (包含正确答案和解析)
        return new SubmitAnswerResponse(
            result.correct(),
            result.score(),
            result.maxScore(),
            question.answer(),
            question.explanation(),
            result.feedback()
        );
    }

    /**
     * 完成练习.
     * 标记会话完成并计算最终成绩.
     *
     * @param userId    用户ID
     * @param sessionId 会话ID
     * @return 完成练习响应
     */
    @Transactional
    public CompletePracticeResponse completePractice(UUID userId, UUID sessionId) {
        // 获取并验证会话
        PracticeSession session = getSessionAndValidate(userId, sessionId);

        // 验证会话状态
        if (session.getStatus() == SessionStatus.COMPLETED) {
            throw new PracticeException(PracticeErrorCode.SESSION_ALREADY_COMPLETED);
        }
        if (session.getStatus() == SessionStatus.ABANDONED) {
            throw new PracticeException(PracticeErrorCode.SESSION_ALREADY_ABANDONED);
        }

        // 计算统计信息
        List<PracticeAnswer> answers = answerRepository.findBySessionIdOrderByAnsweredAtAsc(sessionId);
        long correctCount = answers.stream().filter(a -> Boolean.TRUE.equals(a.getIsCorrect())).count();

        BigDecimal totalScore = answers.stream()
            .map(PracticeAnswer::getScore)
            .filter(s -> s != null)
            .reduce(BigDecimal.ZERO, BigDecimal::add);

        // 更新会话
        session.setStatus(SessionStatus.COMPLETED);
        session.setCorrectCount((int) correctCount);
        session.setScore(totalScore);
        session.setCompletedAt(Instant.now());
        session.setUpdatedBy(userId);

        sessionRepository.save(session);

        // 计算正确率
        BigDecimal accuracy = session.getTotalQuestions() > 0
            ? BigDecimal.valueOf(correctCount)
                .divide(BigDecimal.valueOf(session.getTotalQuestions()), 4, RoundingMode.HALF_UP)
                .multiply(BigDecimal.valueOf(100))
            : BigDecimal.ZERO;

        log.info("Practice session completed: {}, score: {}, accuracy: {}%",
            sessionId, totalScore, accuracy);

        return new CompletePracticeResponse(
            sessionId,
            SessionStatus.COMPLETED.name(),
            session.getTotalQuestions(),
            (int) correctCount,
            totalScore,
            accuracy,
            session.getCompletedAt()
        );
    }

    /**
     * 获取练习会话详情.
     *
     * @param userId    用户ID
     * @param sessionId 会话ID
     * @return 会话详情
     */
    @Transactional(readOnly = true)
    public SessionResponse getSession(UUID userId, UUID sessionId) {
        // 获取并验证会话
        PracticeSession session = getSessionAndValidate(userId, sessionId);

        // 获取题库信息
        ApiResponse<KnowledgeSetResponse> ksResponse =
            contentClient.getKnowledgeSet(session.getKnowledgeSetId());
        String knowledgeSetTitle = ksResponse.data() != null
            ? ksResponse.data().title()
            : "Unknown";

        // 获取答案列表
        List<PracticeAnswer> answers = answerRepository.findBySessionIdOrderByAnsweredAtAsc(sessionId);

        // 获取题目详情用于构建响应
        List<SessionResponse.AnswerResponse> answerResponses = new ArrayList<>();
        for (PracticeAnswer answer : answers) {
            ApiResponse<QuestionResponse> qResponse =
                contentClient.getQuestion(answer.getQuestionId());
            QuestionResponse question = qResponse.data();

            answerResponses.add(new SessionResponse.AnswerResponse(
                answer.getQuestionId(),
                question != null ? question.content() : "",
                question != null ? question.type() : "unknown",
                answer.getUserAnswer(),
                Boolean.TRUE.equals(answer.getIsCorrect()),
                answer.getScore(),
                question != null ? question.answer() : "",
                question != null ? question.explanation() : "",
                answer.getAiFeedback(),
                answer.getAnsweredAt()
            ));
        }

        return new SessionResponse(
            session.getId(),
            session.getKnowledgeSetId(),
            knowledgeSetTitle,
            session.getStatus().name(),
            session.getTotalQuestions(),
            answers.size(),
            session.getCorrectCount(),
            session.getScore(),
            session.getCompletedAt(),
            session.getCreatedAt(),
            answerResponses
        );
    }

    /**
     * 获取会话并验证权限.
     */
    private PracticeSession getSessionAndValidate(UUID userId, UUID sessionId) {
        PracticeSession session = sessionRepository.findById(sessionId)
            .orElseThrow(() -> new PracticeException(PracticeErrorCode.SESSION_NOT_FOUND));

        if (!session.getUserId().equals(userId)) {
            throw new PracticeException(PracticeErrorCode.SESSION_ACCESS_DENIED);
        }

        return session;
    }
}
