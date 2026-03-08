package io.github.suj1e.practice.service;

import io.github.suj1e.content.api.client.ContentClient;
import io.github.suj1e.content.api.dto.QuestionResponse;
import io.github.suj1e.llm.api.client.LlmClient;
import io.github.suj1e.llm.api.dto.GradeResponse;
import io.github.suj1e.llm.api.dto.GradeRequest;
import io.github.suj1e.common.response.ApiResponse;
import io.github.suj1e.practice.exception.GradingException;
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
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

/**
 * GradingService 测试类.
 */
@ExtendWith(MockitoExtension.class)
class GradingServiceTest {

    @Mock
    private LlmClient llmClient;

    @InjectMocks
    private GradingService gradingService;

    private UUID questionId;

    @BeforeEach
    void setUp() {
        questionId = UUID.randomUUID();
    }

    @Nested
    @DisplayName("Choice Question Grading Tests")
    class ChoiceGradingTests {

        @Test
        @DisplayName("Should return correct when answer matches exactly")
        void shouldReturnCorrectWhenExactMatch() {
            // Given
            QuestionResponse question = new QuestionResponse(
                questionId, "choice", "What is 2+2?", List.of("3", "4", "5", "6"),
                "4", "Basic addition", null
            );

            // When
            GradingService.GradingResult result = gradingService.grade(question, "4");

            // Then
            assertTrue(result.correct());
            assertEquals(BigDecimal.TEN, result.score());
            assertEquals(BigDecimal.TEN, result.maxScore());
            assertNull(result.feedback());
        }

        @Test
        @DisplayName("Should return correct when answer matches with different case")
        void shouldReturnCorrectWhenCaseInsensitive() {
            // Given
            QuestionResponse question = new QuestionResponse(
                questionId, "choice", "Capital of France?", List.of("London", "Paris", "Berlin"),
                "PARIS", "Geography", null
            );

            // When
            GradingService.GradingResult result = gradingService.grade(question, "paris");

            // Then
            assertTrue(result.correct());
            assertEquals(BigDecimal.TEN, result.score());
        }

        @Test
        @DisplayName("Should return correct when answer matches with whitespace")
        void shouldReturnCorrectWithWhitespace() {
            // Given
            QuestionResponse question = new QuestionResponse(
                questionId, "choice", "Select option A", List.of("A", "B", "C"),
                "A", "Test", null
            );

            // When
            GradingService.GradingResult result = gradingService.grade(question, "  A  ");

            // Then
            assertTrue(result.correct());
            assertEquals(BigDecimal.TEN, result.score());
        }

        @Test
        @DisplayName("Should return incorrect when answer does not match")
        void shouldReturnIncorrectWhenNoMatch() {
            // Given
            QuestionResponse question = new QuestionResponse(
                questionId, "choice", "What is 2+2?", List.of("3", "4", "5", "6"),
                "4", "Basic addition", null
            );

            // When
            GradingService.GradingResult result = gradingService.grade(question, "3");

            // Then
            assertFalse(result.correct());
            assertEquals(BigDecimal.ZERO, result.score());
            assertEquals(BigDecimal.TEN, result.maxScore());
        }
    }

    @Nested
    @DisplayName("Essay Question Grading Tests")
    class EssayGradingTests {

        @Test
        @DisplayName("Should call LLM service and return graded result")
        void shouldCallLlmServiceForEssayGrading() {
            // Given
            QuestionResponse question = new QuestionResponse(
                questionId, "essay", "Explain dependency injection", null,
                "Dependency injection is...", "Key concepts: IoC, DI types", "Rubric content"
            );

            GradeResponse llmResponse = new GradeResponse(
                8, 10, true, "Good explanation but could be more detailed"
            );
            when(llmClient.gradeAnswer(any(GradeRequest.class)))
                .thenReturn(ApiResponse.of(llmResponse));

            // When
            GradingService.GradingResult result = gradingService.grade(
                question, "DI is a design pattern..."
            );

            // Then
            assertTrue(result.correct());
            assertEquals(new BigDecimal("8"), result.score());
            assertEquals(new BigDecimal("10"), result.maxScore());
            assertEquals("Good explanation but could be more detailed", result.feedback());

            verify(llmClient).gradeAnswer(any(GradeRequest.class));
        }

        @Test
        @DisplayName("Should return incorrect when LLM returns null")
        void shouldReturnIncorrectWhenLlmReturnsNull() {
            // Given
            QuestionResponse question = new QuestionResponse(
                questionId, "essay", "Explain Spring Boot", null,
                "Spring Boot is...", "Auto-configuration", "Rubric"
            );

            when(llmClient.gradeAnswer(any(GradeRequest.class)))
                .thenReturn(new ApiResponse<>(null));

            // When
            GradingService.GradingResult result = gradingService.grade(
                question, "Spring Boot is..."
            );

            // Then
            assertFalse(result.correct());
            assertEquals(BigDecimal.ZERO, result.score());
        }

        @Test
        @DisplayName("Should throw GradingException when LLM service fails")
        void shouldThrowExceptionWhenLlmFails() {
            // Given
            QuestionResponse question = new QuestionResponse(
                questionId, "essay", "Explain microservices", null,
                "Microservices are...", "Key points", "Rubric"
            );

            when(llmClient.gradeAnswer(any(GradeRequest.class)))
                .thenThrow(new RuntimeException("LLM service unavailable"));

            // When & Then
            assertThrows(GradingException.class,
                () -> gradingService.grade(question, "Microservices are small services..."));
        }
    }

    @Nested
    @DisplayName("Invalid Question Type Tests")
    class InvalidTypeTests {

        @Test
        @DisplayName("Should throw exception for unknown question type")
        void shouldThrowExceptionForUnknownType() {
            // Given
            QuestionResponse question = new QuestionResponse(
                questionId, "unknown", "Invalid question", null,
                "Answer", "Explanation", null
            );

            // When & Then
            assertThrows(GradingException.class,
                () -> gradingService.grade(question, "answer"));
        }
    }
}
