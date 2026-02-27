package io.github.suj1e.practice.service;

import io.github.suj1e.content.api.client.ContentClient;
import io.github.suj1e.content.api.dto.QuestionResponse;
import io.github.suj1e.llm.api.client.LlmClient;
import io.github.suj1e.llm.api.dto.GradeResponse;
import io.github.suj1e.llm.api.dto.GradeRequest;
import io.github.suj1e.common.response.ApiResponse;
import io.github.suj1e.practice.error.PracticeErrorCode;
import io.github.suj1e.practice.exception.GradingException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;

/**
 * 评分服务.
 * 负责对选择题和简答题进行评分.
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class GradingService {

    private static final BigDecimal MAX_SCORE = BigDecimal.TEN;
    private static final String CHOICE_TYPE = "choice";
    private static final String ESSAY_TYPE = "essay";

    private final LlmClient llmClient;

    /**
     * 评分结果.
     */
    public record GradingResult(
        boolean correct,
        BigDecimal score,
        BigDecimal maxScore,
        String feedback
    ) {
        public static GradingResult correct(BigDecimal score, BigDecimal maxScore) {
            return new GradingResult(true, score, maxScore, null);
        }

        public static GradingResult incorrect(BigDecimal maxScore) {
            return new GradingResult(false, BigDecimal.ZERO, maxScore, null);
        }

        public static GradingResult withFeedback(boolean correct, BigDecimal score,
                                                  BigDecimal maxScore, String feedback) {
            return new GradingResult(correct, score, maxScore, feedback);
        }
    }

    /**
     * 对答案进行评分.
     *
     * @param question       题目信息
     * @param userAnswer     用户答案
     * @return 评分结果
     */
    public GradingResult grade(QuestionResponse question, String userAnswer) {
        return switch (question.type().toLowerCase()) {
            case CHOICE_TYPE -> gradeChoice(question.answer(), userAnswer);
            case ESSAY_TYPE -> gradeEssay(question, userAnswer);
            default -> throw new GradingException(PracticeErrorCode.INVALID_QUESTION_TYPE,
                "Unknown question type: " + question.type());
        };
    }

    /**
     * 评分选择题.
     * 直接比较用户答案与正确答案.
     */
    private GradingResult gradeChoice(String correctAnswer, String userAnswer) {
        String normalizedCorrect = normalizeAnswer(correctAnswer);
        String normalizedUser = normalizeAnswer(userAnswer);

        if (normalizedCorrect.equals(normalizedUser)) {
            return GradingResult.correct(MAX_SCORE, MAX_SCORE);
        }
        return GradingResult.incorrect(MAX_SCORE);
    }

    /**
     * 评分简答题.
     * 调用 LLM 服务进行 AI 评分.
     */
    private GradingResult gradeEssay(QuestionResponse question, String userAnswer) {
        try {
            GradeRequest request = new GradeRequest(
                question.id(),
                question.content(),
                question.answer(),
                question.rubric(),
                userAnswer
            );

            ApiResponse<GradeResponse> response = llmClient.gradeAnswer(request);
            GradeResponse data = response.data();

            if (data == null) {
                log.error("LLM grading returned null data for question {}", question.id());
                return GradingResult.incorrect(MAX_SCORE);
            }

            BigDecimal score = data.score() != null
                ? new BigDecimal(data.score().toString())
                : BigDecimal.ZERO;
            BigDecimal maxScore = data.maxScore() != null
                ? new BigDecimal(data.maxScore().toString())
                : MAX_SCORE;
            boolean correct = Boolean.TRUE.equals(data.correct());

            return GradingResult.withFeedback(correct, score, maxScore, data.feedback());

        } catch (Exception e) {
            log.error("Failed to grade essay question {}: {}", question.id(), e.getMessage(), e);
            throw new GradingException(PracticeErrorCode.GRADING_FAILED,
                "Failed to grade essay answer", e);
        }
    }

    /**
     * 标准化答案字符串.
     * 去除前后空格并转为小写.
     */
    private String normalizeAnswer(String answer) {
        if (answer == null) {
            return "";
        }
        return answer.trim().toLowerCase();
    }
}
