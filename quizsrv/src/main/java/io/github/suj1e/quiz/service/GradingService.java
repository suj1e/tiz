package io.github.suj1e.quiz.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import io.github.suj1e.common.client.ContentClient;
import io.github.suj1e.common.client.LlmClient;
import io.github.suj1e.common.response.ApiResponse;
import io.github.suj1e.quiz.dto.SubmitQuizRequest;
import io.github.suj1e.quiz.entity.QuizAnswer;
import io.github.suj1e.quiz.entity.QuizResultDetail;
import io.github.suj1e.quiz.repository.QuizAnswerRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.function.Function;
import java.util.stream.Collectors;

/**
 * 评分服务.
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class GradingService {

    private final ContentClient contentClient;
    private final LlmClient llmClient;
    private final QuizAnswerRepository quizAnswerRepository;
    private final ObjectMapper objectMapper;

    /**
     * 评分并生成结果详情.
     *
     * @param resultId     结果 ID
     * @param sessionId    会话 ID
     * @param knowledgeSetId 题库 ID
     * @param answers      提交的答案
     * @return 结果详情列表
     */
    public List<QuizResultDetail> gradeAnswers(UUID resultId, UUID sessionId, UUID knowledgeSetId,
                                                List<SubmitQuizRequest.AnswerItem> answers) {
        // 获取题目列表
        ApiResponse<List<ContentClient.QuestionResponse>> response =
            contentClient.getQuestions(knowledgeSetId, null);
        List<ContentClient.QuestionResponse> questions = response.data();

        // 构建题目映射
        Map<UUID, ContentClient.QuestionResponse> questionMap = questions.stream()
            .collect(Collectors.toMap(ContentClient.QuestionResponse::id, Function.identity()));

        // 保存答案
        saveAnswers(sessionId, answers);

        // 评分
        List<QuizResultDetail> details = new ArrayList<>();
        for (SubmitQuizRequest.AnswerItem answerItem : answers) {
            ContentClient.QuestionResponse question = questionMap.get(answerItem.questionId());
            if (question == null) {
                log.warn("Question not found: {}", answerItem.questionId());
                continue;
            }

            QuizResultDetail detail = gradeQuestion(resultId, question, answerItem.answer());
            details.add(detail);
        }

        return details;
    }

    /**
     * 评分单个题目.
     */
    private QuizResultDetail gradeQuestion(UUID resultId, ContentClient.QuestionResponse question,
                                           String userAnswer) {
        QuizResultDetail detail = new QuizResultDetail();
        detail.setResultId(resultId);
        detail.setQuestionId(question.id());
        detail.setUserAnswer(userAnswer);
        detail.setQuestionSnapshot(toJson(question));

        boolean isChoice = "choice".equals(question.type());

        if (isChoice) {
            // 选择题：直接判断
            boolean correct = question.answer().equalsIgnoreCase(userAnswer.trim());
            detail.setIsCorrect(correct);
            detail.setScore(correct ? BigDecimal.ONE : BigDecimal.ZERO);
        } else {
            // 简答题：调用 LLM 评分
            try {
                LlmClient.GradeRequest gradeRequest = new LlmClient.GradeRequest(
                    question.id(),
                    question.content(),
                    question.answer(),
                    question.rubric(),
                    userAnswer
                );

                ApiResponse<LlmClient.GradeResponse> gradeResponse = llmClient.gradeAnswer(gradeRequest);
                LlmClient.GradeResponse grade = gradeResponse.data();

                detail.setIsCorrect(grade.correct());
                detail.setScore(BigDecimal.valueOf(grade.score()));
                detail.setAiFeedback(grade.feedback());
            } catch (Exception e) {
                log.error("Failed to grade essay question: {}", question.id(), e);
                detail.setIsCorrect(false);
                detail.setScore(BigDecimal.ZERO);
                detail.setAiFeedback("AI grading failed: " + e.getMessage());
            }
        }

        return detail;
    }

    /**
     * 保存答案.
     */
    private void saveAnswers(UUID sessionId, List<SubmitQuizRequest.AnswerItem> answers) {
        List<QuizAnswer> quizAnswers = answers.stream()
            .map(item -> {
                QuizAnswer answer = new QuizAnswer();
                answer.setSessionId(sessionId);
                answer.setQuestionId(item.questionId());
                answer.setUserAnswer(item.answer());
                answer.setAnsweredAt(java.time.Instant.now());
                return answer;
            })
            .toList();

        quizAnswerRepository.saveAll(quizAnswers);
    }

    /**
     * 对象转 JSON.
     */
    private String toJson(Object obj) {
        try {
            return objectMapper.writeValueAsString(obj);
        } catch (JsonProcessingException e) {
            log.error("Failed to serialize object", e);
            return "{}";
        }
    }
}
