package io.github.suj1e.quiz.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import io.github.suj1e.common.client.ContentClient;
import io.github.suj1e.common.exception.BusinessException;
import io.github.suj1e.common.exception.NotFoundException;
import io.github.suj1e.common.response.ApiResponse;
import io.github.suj1e.quiz.dto.QuizResultResponse;
import io.github.suj1e.quiz.dto.StartQuizResponse;
import io.github.suj1e.quiz.dto.SubmitQuizRequest;
import io.github.suj1e.quiz.entity.QuizResult;
import io.github.suj1e.quiz.entity.QuizResultDetail;
import io.github.suj1e.quiz.entity.QuizSession;
import io.github.suj1e.quiz.error.QuizErrorCode;
import io.github.suj1e.quiz.repository.QuizResultDetailRepository;
import io.github.suj1e.quiz.repository.QuizResultRepository;
import io.github.suj1e.quiz.repository.QuizSessionRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

/**
 * 测验服务测试.
 */
@ExtendWith(MockitoExtension.class)
class QuizServiceTest {

    @Mock
    private QuizSessionRepository quizSessionRepository;

    @Mock
    private QuizResultRepository quizResultRepository;

    @Mock
    private QuizResultDetailRepository quizResultDetailRepository;

    @Mock
    private ContentClient contentClient;

    @Mock
    private GradingService gradingService;

    @Mock
    private OutboxService outboxService;

    @Mock
    private ObjectMapper objectMapper;

    @InjectMocks
    private QuizService quizService;

    private UUID userId;
    private UUID knowledgeSetId;
    private ContentClient.KnowledgeSetResponse knowledgeSet;
    private List<ContentClient.QuestionResponse> questions;

    @BeforeEach
    void setUp() {
        userId = UUID.randomUUID();
        knowledgeSetId = UUID.randomUUID();

        knowledgeSet = new ContentClient.KnowledgeSetResponse(
            knowledgeSetId,
            "Test Knowledge Set",
            null,
            null,
            null,
            null,
            null,
            null
        );

        questions = List.of(
            new ContentClient.QuestionResponse(
                UUID.randomUUID(),
                "choice",
                "What is 1+1?",
                List.of("1", "2", "3", "4"),
                "2",
                "Basic math",
                null
            ),
            new ContentClient.QuestionResponse(
                UUID.randomUUID(),
                "choice",
                "What is 2+2?",
                List.of("2", "3", "4", "5"),
                "4",
                "Basic math",
                null
            )
        );
    }

    @Nested
    @DisplayName("开始测验测试")
    class StartQuizTests {

        @Test
        @DisplayName("应该成功开始测验")
        void shouldStartQuizSuccessfully() {
            // Given
            when(contentClient.getKnowledgeSet(knowledgeSetId))
                .thenReturn(ApiResponse.of(knowledgeSet));
            when(contentClient.getQuestions(eq(knowledgeSetId), isNull()))
                .thenReturn(ApiResponse.of(questions));
            when(quizSessionRepository.save(any(QuizSession.class)))
                .thenAnswer(invocation -> {
                    QuizSession session = invocation.getArgument(0);
                    session.setId(UUID.randomUUID());
                    return session;
                });

            // When
            StartQuizResponse response = quizService.startQuiz(userId, knowledgeSetId, 30);

            // Then
            assertNotNull(response);
            assertNotNull(response.sessionId());
            assertEquals(knowledgeSetId, response.knowledgeSetId());
            assertEquals("Test Knowledge Set", response.title());
            assertEquals(30, response.timeLimit());
            assertEquals(2, response.totalQuestions());
            assertNotNull(response.startedAt());
            assertEquals(2, response.questions().size());

            verify(quizSessionRepository).save(any(QuizSession.class));
        }

        @Test
        @DisplayName("应该支持无限时测验")
        void shouldStartQuizWithoutTimeLimit() {
            // Given
            when(contentClient.getKnowledgeSet(knowledgeSetId))
                .thenReturn(ApiResponse.of(knowledgeSet));
            when(contentClient.getQuestions(eq(knowledgeSetId), isNull()))
                .thenReturn(ApiResponse.of(questions));
            when(quizSessionRepository.save(any(QuizSession.class)))
                .thenAnswer(invocation -> {
                    QuizSession session = invocation.getArgument(0);
                    session.setId(UUID.randomUUID());
                    return session;
                });

            // When
            StartQuizResponse response = quizService.startQuiz(userId, knowledgeSetId, null);

            // Then
            assertNull(response.timeLimit());
        }

        @Test
        @DisplayName("应该返回正确的题目信息（不含答案）")
        void shouldReturnQuestionsWithoutAnswers() {
            // Given
            when(contentClient.getKnowledgeSet(knowledgeSetId))
                .thenReturn(ApiResponse.of(knowledgeSet));
            when(contentClient.getQuestions(eq(knowledgeSetId), isNull()))
                .thenReturn(ApiResponse.of(questions));
            when(quizSessionRepository.save(any(QuizSession.class)))
                .thenAnswer(invocation -> {
                    QuizSession session = invocation.getArgument(0);
                    session.setId(UUID.randomUUID());
                    return session;
                });

            // When
            StartQuizResponse response = quizService.startQuiz(userId, knowledgeSetId, 30);

            // Then
            response.questions().forEach(q -> {
                assertNotNull(q.id());
                assertNotNull(q.type());
                assertNotNull(q.content());
                // 选项应该返回
                assertNotNull(q.options());
            });
        }
    }

    @Nested
    @DisplayName("批量提交测试")
    class SubmitQuizTests {

        private UUID sessionId;
        private QuizSession session;

        @BeforeEach
        void setUpSession() {
            sessionId = UUID.randomUUID();
            session = new QuizSession();
            session.setId(sessionId);
            session.setUserId(userId);
            session.setKnowledgeSetId(knowledgeSetId);
            session.setTotalQuestions(2);
            session.setStartedAt(Instant.now().minusSeconds(300));
            session.setStatus(QuizSession.Status.in_progress);
        }

        @Test
        @DisplayName("应该成功提交测验")
        void shouldSubmitQuizSuccessfully() {
            // Given
            List<SubmitQuizRequest.AnswerItem> answers = List.of(
                new SubmitQuizRequest.AnswerItem(questions.get(0).id(), "2"),
                new SubmitQuizRequest.AnswerItem(questions.get(1).id(), "4")
            );
            SubmitQuizRequest request = new SubmitQuizRequest(answers);

            when(quizSessionRepository.findByIdAndUserId(sessionId, userId))
                .thenReturn(Optional.of(session));
            when(quizResultRepository.existsBySessionId(sessionId))
                .thenReturn(false);

            // Mock grading service
            QuizResultDetail detail1 = new QuizResultDetail();
            detail1.setQuestionId(questions.get(0).id());
            detail1.setIsCorrect(true);
            detail1.setScore(BigDecimal.ONE);

            QuizResultDetail detail2 = new QuizResultDetail();
            detail2.setQuestionId(questions.get(1).id());
            detail2.setIsCorrect(true);
            detail2.setScore(BigDecimal.ONE);

            when(gradingService.gradeAnswers(isNull(), eq(sessionId), eq(knowledgeSetId), any()))
                .thenReturn(List.of(detail1, detail2));

            when(quizResultRepository.save(any(QuizResult.class)))
                .thenAnswer(invocation -> {
                    QuizResult result = invocation.getArgument(0);
                    result.setId(UUID.randomUUID());
                    return result;
                });

            when(quizResultDetailRepository.saveAll(any()))
                .thenReturn(List.of(detail1, detail2));

            // When
            UUID resultId = quizService.submitQuiz(sessionId, userId, request);

            // Then
            assertNotNull(resultId);
            verify(quizResultRepository).save(any(QuizResult.class));
            verify(quizResultDetailRepository).saveAll(any());
            verify(quizSessionRepository).save(any(QuizSession.class));
            verify(outboxService).createQuizCompletedEvent(any());
        }

        @Test
        @DisplayName("会话不存在时应抛出异常")
        void shouldThrowWhenSessionNotFound() {
            // Given
            SubmitQuizRequest request = new SubmitQuizRequest(List.of());
            when(quizSessionRepository.findByIdAndUserId(sessionId, userId))
                .thenReturn(Optional.empty());

            // When & Then
            assertThrows(NotFoundException.class,
                () -> quizService.submitQuiz(sessionId, userId, request));
        }

        @Test
        @DisplayName("会话已完成时应抛出异常")
        void shouldThrowWhenSessionAlreadyCompleted() {
            // Given
            session.setStatus(QuizSession.Status.completed);
            SubmitQuizRequest request = new SubmitQuizRequest(List.of());
            when(quizSessionRepository.findByIdAndUserId(sessionId, userId))
                .thenReturn(Optional.of(session));

            // When & Then
            BusinessException exception = assertThrows(BusinessException.class,
                () -> quizService.submitQuiz(sessionId, userId, request));
            assertEquals(QuizErrorCode.SESSION_ALREADY_COMPLETED, exception.getErrorCode());
        }

        @Test
        @DisplayName("会话已过期时应抛出异常")
        void shouldThrowWhenSessionExpired() {
            // Given
            session.setStatus(QuizSession.Status.expired);
            SubmitQuizRequest request = new SubmitQuizRequest(List.of());
            when(quizSessionRepository.findByIdAndUserId(sessionId, userId))
                .thenReturn(Optional.of(session));

            // When & Then
            BusinessException exception = assertThrows(BusinessException.class,
                () -> quizService.submitQuiz(sessionId, userId, request));
            assertEquals(QuizErrorCode.SESSION_EXPIRED, exception.getErrorCode());
        }
    }

    @Nested
    @DisplayName("结果查询测试")
    class GetResultTests {

        private UUID resultId;
        private QuizResult result;
        private UUID sessionId;

        @BeforeEach
        void setUpResult() {
            resultId = UUID.randomUUID();
            sessionId = UUID.randomUUID();

            result = new QuizResult();
            result.setId(resultId);
            result.setSessionId(sessionId);
            result.setUserId(userId);
            result.setKnowledgeSetId(knowledgeSetId);
            result.setScore(BigDecimal.valueOf(2));
            result.setTotal(BigDecimal.valueOf(2));
            result.setCorrectCount(2);
            result.setTimeSpent(300);
            result.setCompletedAt(Instant.now());
        }

        @Test
        @DisplayName("应该成功获取测验结果")
        void shouldGetResultSuccessfully() {
            // Given
            when(quizResultRepository.findById(resultId))
                .thenReturn(Optional.of(result));
            when(contentClient.getKnowledgeSet(knowledgeSetId))
                .thenReturn(ApiResponse.of(knowledgeSet));

            QuizResultDetail detail = new QuizResultDetail();
            detail.setQuestionId(questions.get(0).id());
            detail.setIsCorrect(true);
            detail.setScore(BigDecimal.ONE);
            detail.setUserAnswer("2");
            detail.setQuestionSnapshot("{\"id\":\"" + questions.get(0).id() + "\",\"type\":\"choice\",\"content\":\"Test\",\"answer\":\"2\"}");

            when(quizResultDetailRepository.findByResultId(resultId))
                .thenReturn(List.of(detail));

            // When
            QuizResultResponse response = quizService.getResult(resultId, userId);

            // Then
            assertNotNull(response);
            assertEquals(resultId, response.resultId());
            assertEquals(sessionId, response.sessionId());
            assertEquals(knowledgeSetId, response.knowledgeSetId());
            assertEquals(BigDecimal.valueOf(2), response.score());
            assertEquals(2, response.correctCount());
            assertEquals(2, response.totalCount());
        }

        @Test
        @DisplayName("结果不存在时应抛出异常")
        void shouldThrowWhenResultNotFound() {
            // Given
            when(quizResultRepository.findById(resultId))
                .thenReturn(Optional.empty());

            // When & Then
            assertThrows(NotFoundException.class,
                () -> quizService.getResult(resultId, userId));
        }

        @Test
        @DisplayName("非本人结果时应抛出异常")
        void shouldThrowWhenAccessDenied() {
            // Given
            UUID otherUserId = UUID.randomUUID();
            result.setUserId(otherUserId);
            when(quizResultRepository.findById(resultId))
                .thenReturn(Optional.of(result));

            // When & Then
            BusinessException exception = assertThrows(BusinessException.class,
                () -> quizService.getResult(resultId, userId));
            assertEquals(QuizErrorCode.SESSION_ACCESS_DENIED, exception.getErrorCode());
        }

        @Test
        @DisplayName("应该返回题目详情列表")
        void shouldReturnResultDetails() {
            // Given
            when(quizResultRepository.findById(resultId))
                .thenReturn(Optional.of(result));
            when(contentClient.getKnowledgeSet(knowledgeSetId))
                .thenReturn(ApiResponse.of(knowledgeSet));

            QuizResultDetail detail1 = new QuizResultDetail();
            detail1.setQuestionId(questions.get(0).id());
            detail1.setIsCorrect(true);
            detail1.setScore(BigDecimal.ONE);
            detail1.setUserAnswer("2");
            detail1.setQuestionSnapshot("{\"id\":\"" + questions.get(0).id() + "\",\"type\":\"choice\",\"content\":\"What is 1+1?\",\"options\":[\"1\",\"2\",\"3\",\"4\"],\"answer\":\"2\",\"explanation\":\"Basic math\"}");

            when(quizResultDetailRepository.findByResultId(resultId))
                .thenReturn(List.of(detail1));

            // When
            QuizResultResponse response = quizService.getResult(resultId, userId);

            // Then
            assertNotNull(response.details());
            assertEquals(1, response.details().size());
        }
    }
}
