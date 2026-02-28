package io.github.suj1e.content.controller;

import io.github.suj1e.content.api.dto.BatchInfo;
import io.github.suj1e.content.api.dto.BatchResponse;
import io.github.suj1e.content.api.dto.GenerateRequest;
import io.github.suj1e.content.api.dto.GenerateResponse;
import io.github.suj1e.content.api.dto.KnowledgeSetResponse;
import io.github.suj1e.content.api.dto.QuestionResponse;
import io.github.suj1e.content.service.GenerateService;
import io.github.suj1e.common.response.ApiResponse;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;

/**
 * GenerateController 单元测试.
 */
@ExtendWith(MockitoExtension.class)
class GenerateControllerTest {

    @Mock
    private GenerateService generateService;

    @InjectMocks
    private GenerateController generateController;

    @Test
    @DisplayName("生成题目 - 成功保存")
    void generate_Save_Success() {
        // Arrange
        UUID userId = UUID.randomUUID();
        UUID sessionId = UUID.randomUUID();
        UUID knowledgeSetId = UUID.randomUUID();
        GenerateRequest request = new GenerateRequest(sessionId, true);

        KnowledgeSetResponse knowledgeSet = new KnowledgeSetResponse(
            knowledgeSetId,
            "Test Knowledge Set",
            null,
            null,
            "medium",
            2
        );

        List<QuestionResponse> questions = List.of(
            new QuestionResponse(
                UUID.randomUUID(),
                "choice",
                "What is 1+1?",
                List.of("1", "2", "3", "4"),
                "2",
                "Basic math",
                null
            )
        );

        BatchInfo batchInfo = new BatchInfo(1, 2, true);
        GenerateResponse response = new GenerateResponse(knowledgeSet, questions, batchInfo);

        when(generateService.generate(any(), any())).thenReturn(response);

        // Act
        ApiResponse<GenerateResponse> result = generateController.generate(userId, request);

        // Assert
        assertNotNull(result);
        assertNotNull(result.data());
        assertEquals(knowledgeSetId, result.data().knowledgeSet().id());
        assertEquals("Test Knowledge Set", result.data().knowledgeSet().title());
        assertEquals(1, result.data().questions().size());
        assertEquals(1, result.data().batch().current());
        assertTrue(result.data().batch().hasMore());
    }

    @Test
    @DisplayName("生成题目 - 不保存")
    void generate_NoSave_Success() {
        // Arrange
        UUID userId = UUID.randomUUID();
        UUID sessionId = UUID.randomUUID();
        GenerateRequest request = new GenerateRequest(sessionId, false);

        List<QuestionResponse> questions = List.of(
            new QuestionResponse(
                null,
                "choice",
                "What is 1+1?",
                List.of("1", "2", "3", "4"),
                "2",
                "Basic math",
                null
            )
        );

        BatchInfo batchInfo = new BatchInfo(1, 2, true);
        GenerateResponse response = new GenerateResponse(null, questions, batchInfo);

        when(generateService.generate(any(), any())).thenReturn(response);

        // Act
        ApiResponse<GenerateResponse> result = generateController.generate(userId, request);

        // Assert
        assertNotNull(result);
        assertNull(result.data().knowledgeSet());
        assertEquals(1, result.data().questions().size());
    }

    @Test
    @DisplayName("获取后续批次 - 成功")
    void getBatch_Success() {
        // Arrange
        UUID userId = UUID.randomUUID();
        UUID knowledgeSetId = UUID.randomUUID();

        List<QuestionResponse> questions = List.of(
            new QuestionResponse(
                UUID.randomUUID(),
                "essay",
                "Explain the difference between A and B",
                null,
                "Sample answer",
                null,
                "Rubric content"
            )
        );

        BatchInfo batchInfo = new BatchInfo(2, 2, false);
        BatchResponse response = new BatchResponse(questions, batchInfo);

        when(generateService.getBatch(any(), eq(knowledgeSetId), eq(2)))
            .thenReturn(response);

        // Act
        ApiResponse<BatchResponse> result = generateController.getBatch(userId, knowledgeSetId, 2);

        // Assert
        assertNotNull(result);
        assertEquals(1, result.data().questions().size());
        assertEquals("essay", result.data().questions().get(0).type());
        assertEquals(2, result.data().batch().current());
        assertFalse(result.data().batch().hasMore());
    }

    @Test
    @DisplayName("获取后续批次 - 默认页码")
    void getBatch_DefaultPage_Success() {
        // Arrange
        UUID userId = UUID.randomUUID();
        UUID knowledgeSetId = UUID.randomUUID();

        List<QuestionResponse> questions = List.of();
        BatchInfo batchInfo = new BatchInfo(1, 1, false);
        BatchResponse response = new BatchResponse(questions, batchInfo);

        when(generateService.getBatch(any(), eq(knowledgeSetId), eq(1)))
            .thenReturn(response);

        // Act
        ApiResponse<BatchResponse> result = generateController.getBatch(userId, knowledgeSetId, 1);

        // Assert
        assertNotNull(result);
        assertEquals(1, result.data().batch().current());
    }
}
