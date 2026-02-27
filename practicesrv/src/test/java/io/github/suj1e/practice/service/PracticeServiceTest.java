package io.github.suj1e.practice.service;

import io.github.suj1e.common.client.ContentClient;
import io.github.suj1e.common.client.LlmClient;
import io.github.suj1e.common.response.ApiResponse;
import io.github.suj1e.practice.dto.StartPracticeRequest;
import io.github.suj1e.practice.dto.StartPracticeResponse;
import io.github.suj1e.practice.dto.SubmitAnswerRequest;
import io.github.suj1e.practice.dto.SubmitAnswerResponse;
import io.github.suj1e.practice.entity.PracticeSession;
import io.github.suj1e.practice.entity.SessionStatus;
import io.github.suj1e.practice.error.PracticeErrorCode;
import io.github.suj1e.practice.exception.PracticeException;
import io.github.suj1e.practice.repository.PracticeAnswerRepository;
import io.github.suj1e.practice.repository.PracticeSessionRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

/**
 * PracticeService 测试类.
 */
@ExtendWith(MockitoExtension.class)
class PracticeServiceTest {

    @Mock
    private PracticeSessionRepository sessionRepository;

    @Mock
    private PracticeAnswerRepository answerRepository;

    @Mock
    private ContentClient contentClient;

    @Mock
    private LlmClient llmClient;

    @Mock
    private GradingService gradingService;

    @InjectMocks
    private PracticeService practiceService;

    private UUID userId;
    private UUID knowledgeSetId;
    private UUID sessionId;
    private UUID questionId;

    @BeforeEach
    void setUp() {
        userId = UUID.randomUUID();
        knowledgeSetId = UUID.randomUUID();
        sessionId = UUID.randomUUID();
        questionId = UUID.randomUUID();
    }

    @Nested
    @DisplayName("Start Practice Tests")
    class StartPracticeTests {

        @Test
        @DisplayName("Should create session successfully when no in-progress session exists")
        void shouldCreateSessionSuccessfully() {
            // Given
            when(sessionRepository.existsByUserIdAndKnowledgeSetIdAndStatus(
                userId, knowledgeSetId, SessionStatus.IN_PROGRESS))
                .thenReturn(false);

            ContentClient.KnowledgeSetResponse ksResponse = new ContentClient.KnowledgeSetResponse(
                knowledgeSetId, "Test Knowledge Set", "Category", List.of("tag1"), "medium", 2
            );
            when(contentClient.getKnowledgeSet(knowledgeSetId))
                .thenReturn(ApiResponse.of(ksResponse));

            List<ContentClient.QuestionResponse> questions = List.of(
                new ContentClient.QuestionResponse(
                    questionId, "choice", "What is 1+1?", List.of("1", "2", "3", "4"),
                    "2", "Basic math", null
                )
            );
            when(contentClient.getQuestions(knowledgeSetId, null))
                .thenReturn(ApiResponse.of(questions));

            PracticeSession savedSession = new PracticeSession();
            savedSession.setId(sessionId);
            savedSession.setUserId(userId);
            savedSession.setKnowledgeSetId(knowledgeSetId);
            savedSession.setStatus(SessionStatus.IN_PROGRESS);
            savedSession.setTotalQuestions(1);
            when(sessionRepository.save(any(PracticeSession.class)))
                .thenReturn(savedSession);

            // When
            StartPracticeResponse response = practiceService.startPractice(userId, knowledgeSetId);

            // Then
            assertNotNull(response);
            assertEquals(sessionId, response.sessionId());
            assertEquals(knowledgeSetId, response.knowledgeSetId());
            assertEquals("Test Knowledge Set", response.knowledgeSetTitle());
            assertEquals(1, response.totalQuestions());
            assertEquals(1, response.questions().size());

            verify(sessionRepository).save(any(PracticeSession.class));
        }

        @Test
        @DisplayName("Should throw exception when in-progress session already exists")
        void shouldThrowExceptionWhenSessionExists() {
            // Given
            when(sessionRepository.existsByUserIdAndKnowledgeSetIdAndStatus(
                userId, knowledgeSetId, SessionStatus.IN_PROGRESS))
                .thenReturn(true);

            // When & Then
            PracticeException exception = assertThrows(PracticeException.class,
                () -> practiceService.startPractice(userId, knowledgeSetId));

            assertEquals(PracticeErrorCode.SESSION_IN_PROGRESS_EXISTS, exception.getErrorCode());
            verify(sessionRepository, never()).save(any());
        }

        @Test
        @DisplayName("Should throw exception when knowledge set not found")
        void shouldThrowExceptionWhenKnowledgeSetNotFound() {
            // Given
            when(sessionRepository.existsByUserIdAndKnowledgeSetIdAndStatus(
                userId, knowledgeSetId, SessionStatus.IN_PROGRESS))
                .thenReturn(false);
            when(contentClient.getKnowledgeSet(knowledgeSetId))
                .thenReturn(new ApiResponse<>(null));

            // When & Then
            PracticeException exception = assertThrows(PracticeException.class,
                () -> practiceService.startPractice(userId, knowledgeSetId));

            assertEquals(PracticeErrorCode.SESSION_NOT_FOUND, exception.getErrorCode());
        }

        @Test
        @DisplayName("Should throw exception when no questions in knowledge set")
        void shouldThrowExceptionWhenNoQuestions() {
            // Given
            when(sessionRepository.existsByUserIdAndKnowledgeSetIdAndStatus(
                userId, knowledgeSetId, SessionStatus.IN_PROGRESS))
                .thenReturn(false);

            ContentClient.KnowledgeSetResponse ksResponse = new ContentClient.KnowledgeSetResponse(
                knowledgeSetId, "Test Knowledge Set", "Category", List.of("tag1"), "medium", 0
            );
            when(contentClient.getKnowledgeSet(knowledgeSetId))
                .thenReturn(ApiResponse.of(ksResponse));
            when(contentClient.getQuestions(knowledgeSetId, null))
                .thenReturn(ApiResponse.of(List.of()));

            // When & Then
            PracticeException exception = assertThrows(PracticeException.class,
                () -> practiceService.startPractice(userId, knowledgeSetId));

            assertEquals(PracticeErrorCode.SESSION_NOT_FOUND, exception.getErrorCode());
        }
    }

    @Nested
    @DisplayName("Submit Answer Tests")
    class SubmitAnswerTests {

        @Test
        @DisplayName("Should submit choice answer and return correct result")
        void shouldSubmitChoiceAnswerCorrectly() {
            // Given
            PracticeSession session = createInProgressSession();
            when(sessionRepository.findById(sessionId)).thenReturn(Optional.of(session));

            ContentClient.QuestionResponse question = new ContentClient.QuestionResponse(
                questionId, "choice", "What is 1+1?", List.of("1", "2", "3", "4"),
                "2", "Basic math", null
            );
            when(contentClient.getQuestion(questionId)).thenReturn(ApiResponse.of(question));

            GradingService.GradingResult gradingResult = GradingService.GradingResult.correct(
                BigDecimal.TEN, BigDecimal.TEN
            );
            when(gradingService.grade(question, "2")).thenReturn(gradingResult);
            when(answerRepository.findBySessionIdAndQuestionId(sessionId, questionId))
                .thenReturn(Optional.empty());
            when(answerRepository.save(any())).thenReturn(null);

            // When
            SubmitAnswerResponse response = practiceService.submitAnswer(
                userId, sessionId, new SubmitAnswerRequest(questionId, "2")
            );

            // Then
            assertNotNull(response);
            assertTrue(response.correct());
            assertEquals(BigDecimal.TEN, response.score());
            assertEquals("2", response.correctAnswer());
            assertEquals("Basic math", response.explanation());
        }

        @Test
        @DisplayName("Should submit essay answer with AI feedback")
        void shouldSubmitEssayAnswerWithAiFeedback() {
            // Given
            PracticeSession session = createInProgressSession();
            when(sessionRepository.findById(sessionId)).thenReturn(Optional.of(session));

            ContentClient.QuestionResponse question = new ContentClient.QuestionResponse(
                questionId, "essay", "Explain Spring Boot", null,
                "Spring Boot is...", "It provides auto-configuration", "Key points: 1, 2, 3"
            );
            when(contentClient.getQuestion(questionId)).thenReturn(ApiResponse.of(question));

            GradingService.GradingResult gradingResult = GradingService.GradingResult.withFeedback(
                true, new BigDecimal("8"), BigDecimal.TEN, "Good explanation but missing some details"
            );
            when(gradingService.grade(question, "Spring Boot is a framework"))
                .thenReturn(gradingResult);
            when(answerRepository.findBySessionIdAndQuestionId(sessionId, questionId))
                .thenReturn(Optional.empty());
            when(answerRepository.save(any())).thenReturn(null);

            // When
            SubmitAnswerResponse response = practiceService.submitAnswer(
                userId, sessionId, new SubmitAnswerRequest(questionId, "Spring Boot is a framework")
            );

            // Then
            assertNotNull(response);
            assertTrue(response.correct());
            assertEquals(new BigDecimal("8"), response.score());
            assertEquals("Good explanation but missing some details", response.aiFeedback());
        }

        @Test
        @DisplayName("Should throw exception when session not found")
        void shouldThrowExceptionWhenSessionNotFound() {
            // Given
            when(sessionRepository.findById(sessionId)).thenReturn(Optional.empty());

            // When & Then
            PracticeException exception = assertThrows(PracticeException.class,
                () -> practiceService.submitAnswer(
                    userId, sessionId, new SubmitAnswerRequest(questionId, "answer")
                ));

            assertEquals(PracticeErrorCode.SESSION_NOT_FOUND, exception.getErrorCode());
        }

        @Test
        @DisplayName("Should throw exception when session belongs to different user")
        void shouldThrowExceptionWhenAccessDenied() {
            // Given
            UUID otherUserId = UUID.randomUUID();
            PracticeSession session = createInProgressSession();
            session.setUserId(otherUserId);
            when(sessionRepository.findById(sessionId)).thenReturn(Optional.of(session));

            // When & Then
            PracticeException exception = assertThrows(PracticeException.class,
                () -> practiceService.submitAnswer(
                    userId, sessionId, new SubmitAnswerRequest(questionId, "answer")
                ));

            assertEquals(PracticeErrorCode.SESSION_ACCESS_DENIED, exception.getErrorCode());
        }

        @Test
        @DisplayName("Should throw exception when session already completed")
        void shouldThrowExceptionWhenSessionCompleted() {
            // Given
            PracticeSession session = createInProgressSession();
            session.setStatus(SessionStatus.COMPLETED);
            when(sessionRepository.findById(sessionId)).thenReturn(Optional.of(session));

            // When & Then
            PracticeException exception = assertThrows(PracticeException.class,
                () -> practiceService.submitAnswer(
                    userId, sessionId, new SubmitAnswerRequest(questionId, "answer")
                ));

            assertEquals(PracticeErrorCode.SESSION_ALREADY_COMPLETED, exception.getErrorCode());
        }

        private PracticeSession createInProgressSession() {
            PracticeSession session = new PracticeSession();
            session.setId(sessionId);
            session.setUserId(userId);
            session.setKnowledgeSetId(knowledgeSetId);
            session.setStatus(SessionStatus.IN_PROGRESS);
            session.setTotalQuestions(5);
            return session;
        }
    }
}
