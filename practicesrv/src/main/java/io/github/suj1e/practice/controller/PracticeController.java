package io.github.suj1e.practice.controller;

import io.github.suj1e.common.annotation.CurrentUserId;
import io.github.suj1e.common.response.ApiResponse;
import io.github.suj1e.practice.dto.*;
import io.github.suj1e.practice.service.PracticeService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

/**
 * 练习控制器.
 * 提供练习相关的 API 端点.
 */
@RestController
@RequestMapping("/api/practice/v1")
@RequiredArgsConstructor
public class PracticeController {

    private final PracticeService practiceService;

    /**
     * 开始练习.
     * POST /api/practice/v1/start
     */
    @PostMapping("/start")
    public ApiResponse<StartPracticeResponse> startPractice(
        @CurrentUserId UUID userId,
        @Valid @RequestBody StartPracticeRequest request
    ) {
        StartPracticeResponse response = practiceService.startPractice(userId, request.knowledgeSetId());
        return ApiResponse.of(response);
    }

    /**
     * 提交答案.
     * POST /api/practice/v1/{id}/answer
     */
    @PostMapping("/{id}/answer")
    public ApiResponse<SubmitAnswerResponse> submitAnswer(
        @CurrentUserId UUID userId,
        @PathVariable UUID id,
        @Valid @RequestBody SubmitAnswerRequest request
    ) {
        SubmitAnswerResponse response = practiceService.submitAnswer(userId, id, request);
        return ApiResponse.of(response);
    }

    /**
     * 完成练习.
     * POST /api/practice/v1/{id}/complete
     */
    @PostMapping("/{id}/complete")
    public ApiResponse<CompletePracticeResponse> completePractice(
        @CurrentUserId UUID userId,
        @PathVariable UUID id
    ) {
        CompletePracticeResponse response = practiceService.completePractice(userId, id);
        return ApiResponse.of(response);
    }

    /**
     * 获取练习详情.
     * GET /api/practice/v1/{id}
     */
    @GetMapping("/{id}")
    public ApiResponse<SessionResponse> getSession(
        @CurrentUserId UUID userId,
        @PathVariable UUID id
    ) {
        SessionResponse response = practiceService.getSession(userId, id);
        return ApiResponse.of(response);
    }
}
