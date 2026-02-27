package io.github.suj1e.practice.service;

import io.github.suj1e.common.client.ContentClient;
import io.github.suj1e.common.response.ApiResponse;
import io.github.suj1e.practice.dto.CompletePracticeResponse;
import io.github.suj1e.practice.entity.PracticeAnswer;
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
import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

/**
 * Complete Practice Tests.
 */
@ExtendWith(MockitoExtension.class)
class CompletePracticeTest {

    @Mock
    private PracticeSessionRepository sessionRepository;

    @Mock
    private PracticeAnswerRepository answerRepository;

    @Mock
    private ContentClient contentClient;

    @Mock
    private GradingService gradingService;

    @InjectMocks
    private PracticeService practiceService;

    private UUID userId;
    private UUID sessionId;
    private UUID knowledgeSetId;

    @BeforeEach
    void setUp() {
        userId = UUID.randomUUID();
        sessionId = UUID.randomUUID();
        knowledgeSetId = UUID.randomUUID();
    }

    @Nested
    @DisplayName("Complete Practice Tests")
    class CompletePracticeTests {

        @Test
        @DisplayName("Should complete session and calculate statistics correctly")
        void shouldCompleteSessionSuccessfully() {
            // Given
            PracticeSession session = createInProgressSession();
            when(sessionRepository.findById(sessionId)).thenReturn(Optional.of(session));

            List<PracticeAnswer> answers = createSampleAnswers();
            when(answerRepository.findBySessionIdOrderByAnsweredAtAsc(sessionId))
                .thenReturn(answers);

            when(sessionRepository.save(any(PracticeSession.class)))
                .thenAnswer(invocation -> invocation.getArgument(0));

            // When
            CompletePracticeResponse response = practiceService.completePractice(userId, sessionId);

            // Then
            assertNotNull(response);
            assertEquals(sessionId, response.sessionId());
            assertEquals("COMPLETED", response.status());
            assertEquals(5, response.totalQuestions());
            assertEquals(3, response.correctCount());
            assertEquals(new BigDecimal("30.00"), response.score());
            assertNotNull(response.completedAt());

            // Verify accuracy calculation (3/5 = 60%)
            assertEquals(new BigDecimal("60.0000"), response.accuracy());

            verify(sessionRepository).save(any(PracticeSession.class));
        }

        @Test
        @DisplayName("Should handle session with no answers")
        void shouldHandleNoAnswers() {
            // Given
            PracticeSession session = createInProgressSession();
            when(sessionRepository.findById(sessionId)).thenReturn(Optional.of(session));
            when(answerRepository.findBySessionIdOrderByAnsweredAtAsc(sessionId))
                .thenReturn(List.of());
            when(sessionRepository.save(any(PracticeSession.class)))
                .thenAnswer(invocation -> invocation.getArgument(0));

            // When
            CompletePracticeResponse response = practiceService.completePractice(userId, sessionId);

            // Then
            assertNotNull(response);
            assertEquals(0, response.correctCount());
            assertEquals(BigDecimal.ZERO, response.score());
            assertEquals(BigDecimal.ZERO, response.accuracy());
        }

        @Test
        @DisplayName("Should throw exception when session not found")
        void shouldThrowExceptionWhenSessionNotFound() {
            // Given
            when(sessionRepository.findById(sessionId)).thenReturn(Optional.empty());

            // When & Then
            PracticeException exception = assertThrows(PracticeException.class,
                () -> practiceService.completePractice(userId, sessionId));

            assertEquals(PracticeErrorCode.SESSION_NOT_FOUND, exception.getErrorCode());
        }

        @Test
        @DisplayName("Should throw exception when access denied")
        void shouldThrowExceptionWhenAccessDenied() {
            // Given
            UUID otherUserId = UUID.randomUUID();
            PracticeSession session = createInProgressSession();
            session.setUserId(otherUserId);
            when(sessionRepository.findById(sessionId)).thenReturn(Optional.of(session));

            // When & Then
            PracticeException exception = assertThrows(PracticeException.class,
                () -> practiceService.completePractice(userId, sessionId));

            assertEquals(PracticeErrorCode.SESSION_ACCESS_DENIED, exception.getErrorCode());
        }

        @Test
        @DisplayName("Should throw exception when session already completed")
        void shouldThrowExceptionWhenAlreadyCompleted() {
            // Given
            PracticeSession session = createInProgressSession();
            session.setStatus(SessionStatus.COMPLETED);
            when(sessionRepository.findById(sessionId)).thenReturn(Optional.of(session));

            // When & Then
            PracticeException exception = assertThrows(PracticeException.class,
                () -> practiceService.completePractice(userId, sessionId));

            assertEquals(PracticeErrorCode.SESSION_ALREADY_COMPLETED, exception.getErrorCode());
        }

        @Test
        @DisplayName("Should throw exception when session abandoned")
        void shouldThrowExceptionWhenAbandoned() {
            // Given
            PracticeSession session = createInProgressSession();
            session.setStatus(SessionStatus.ABANDONED);
            when(sessionRepository.findById(sessionId)).thenReturn(Optional.of(session));

            // When & Then
            PracticeException exception = assertThrows(PracticeException.class,
                () -> practiceService.completePractice(userId, sessionId));

            assertEquals(PracticeErrorCode.SESSION_ALREADY_ABANDONED, exception.getErrorCode());
        }

        @Test
        @DisplayName("Should calculate 100% accuracy when all answers correct")
        void shouldCalculate100PercentAccuracy() {
            // Given
            PracticeSession session = createInProgressSession();
            session.setTotalQuestions(3);
            when(sessionRepository.findById(sessionId)).thenReturn(Optional.of(session));

            List<PracticeAnswer> answers = List.of(
                createAnswer(true, BigDecimal.TEN),
                createAnswer(true, BigDecimal.TEN),
                createAnswer(true, BigDecimal.TEN)
            );
            when(answerRepository.findBySessionIdOrderByAnsweredAtAsc(sessionId))
                .thenReturn(answers);
            when(sessionRepository.save(any(PracticeSession.class)))
                .thenAnswer(invocation -> invocation.getArgument(0));

            // When
            CompletePracticeResponse response = practiceService.completePractice(userId, sessionId);

            // Then
            assertEquals(new BigDecimal("100.0000"), response.accuracy());
            assertEquals(3, response.correctCount());
        }
    }

    private PracticeSession createInProgressSession() {
        PracticeSession session = new PracticeSession();
        session.setId(sessionId);
        session.setUserId(userId);
        session.setKnowledgeSetId(knowledgeSetId);
        session.setStatus(SessionStatus.IN_PROGRESS);
        session.setTotalQuestions(5);
        session.setCorrectCount(0);
        session.setScore(BigDecimal.ZERO);
        return session;
    }

    private List<PracticeAnswer> createSampleAnswers() {
        return List.of(
            createAnswer(true, BigDecimal.TEN),
            createAnswer(false, BigDecimal.ZERO),
            createAnswer(true, BigDecimal.TEN),
            createAnswer(false, BigDecimal.ZERO),
            createAnswer(true, BigDecimal.TEN)
        );
    }

    private PracticeAnswer createAnswer(boolean correct, BigDecimal score) {
        PracticeAnswer answer = new PracticeAnswer();
        answer.setIsCorrect(correct);
        answer.setScore(score);
        answer.setAnsweredAt(Instant.now());
        return answer;
    }
}
