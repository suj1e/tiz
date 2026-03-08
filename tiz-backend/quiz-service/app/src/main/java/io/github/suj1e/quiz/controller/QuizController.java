package io.github.suj1e.quiz.controller;

import io.github.suj1e.common.annotation.CurrentUserId;
import io.github.suj1e.common.response.ApiResponse;
import io.github.suj1e.quiz.dto.QuizResultResponse;
import io.github.suj1e.quiz.dto.StartQuizRequest;
import io.github.suj1e.quiz.dto.StartQuizResponse;
import io.github.suj1e.quiz.dto.SubmitQuizRequest;
import io.github.suj1e.quiz.service.QuizService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

/**
 * 测验控制器.
 */
@RestController
@RequestMapping("/api/quiz/v1")
@RequiredArgsConstructor
public class QuizController {

    private final QuizService quizService;

    /**
     * 开始测验.
     *
     * @param userId  用户 ID (从 JWT 获取)
     * @param request 开始测验请求
     * @return 开始测验响应
     */
    @PostMapping("/start")
    public ApiResponse<StartQuizResponse> startQuiz(
        @CurrentUserId UUID userId,
        @Valid @RequestBody StartQuizRequest request
    ) {
        return ApiResponse.of(quizService.startQuiz(userId, request.knowledgeSetId(), request.timeLimit()));
    }

    /**
     * 批量提交测验.
     *
     * @param userId    用户 ID (从 JWT 获取)
     * @param sessionId 会话 ID
     * @param request   提交请求
     * @return 结果 ID
     */
    @PostMapping("/{id}/submit")
    public ApiResponse<SubmitQuizResponse> submitQuiz(
        @CurrentUserId UUID userId,
        @PathVariable("id") UUID sessionId,
        @Valid @RequestBody SubmitQuizRequest request
    ) {
        UUID resultId = quizService.submitQuiz(sessionId, userId, request);
        return ApiResponse.of(new SubmitQuizResponse(resultId));
    }

    /**
     * 获取测验结果.
     *
     * @param userId   用户 ID (从 JWT 获取)
     * @param resultId 结果 ID
     * @return 测验结果响应
     */
    @GetMapping("/result/{id}")
    public ApiResponse<QuizResultResponse> getResult(
        @CurrentUserId UUID userId,
        @PathVariable("id") UUID resultId
    ) {
        return ApiResponse.of(quizService.getResult(resultId, userId));
    }

    /**
     * 提交测验响应.
     */
    public record SubmitQuizResponse(UUID resultId) {}
}
