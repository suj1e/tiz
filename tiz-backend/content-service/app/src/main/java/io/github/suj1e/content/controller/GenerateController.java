package io.github.suj1e.content.controller;

import io.github.suj1e.common.annotation.CurrentUserId;
import io.github.suj1e.common.response.ApiResponse;
import io.github.suj1e.content.api.dto.BatchResponse;
import io.github.suj1e.content.api.dto.GenerateRequest;
import io.github.suj1e.content.api.dto.GenerateResponse;
import io.github.suj1e.content.service.GenerateService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

/**
 * 生成题目控制器.
 */
@RestController
@RequestMapping("/api/content/v1/generate")
@RequiredArgsConstructor
public class GenerateController {

    private final GenerateService generateService;

    /**
     * 生成题目.
     *
     * @param userId  用户 ID (从 JWT 获取)
     * @param request 生成请求
     * @return 生成响应
     */
    @PostMapping
    public ApiResponse<GenerateResponse> generate(
        @CurrentUserId UUID userId,
        @Valid @RequestBody GenerateRequest request
    ) {
        GenerateResponse response = generateService.generate(userId, request);
        return ApiResponse.of(response);
    }

    /**
     * 获取后续批次题目.
     *
     * @param userId         用户 ID (从 JWT 获取)
     * @param knowledgeSetId 题库 ID
     * @param page           页码
     * @return 批次响应
     */
    @GetMapping("/{id}/batch")
    public ApiResponse<BatchResponse> getBatch(
        @CurrentUserId UUID userId,
        @PathVariable("id") UUID knowledgeSetId,
        @RequestParam(defaultValue = "1") int page
    ) {
        BatchResponse response = generateService.getBatch(userId, knowledgeSetId, page);
        return ApiResponse.of(response);
    }
}
