package io.github.suj1e.quiz.repository;

import io.github.suj1e.quiz.entity.QuizAnswer;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

/**
 * 测验答案仓库.
 */
@Repository
public interface QuizAnswerRepository extends JpaRepository<QuizAnswer, UUID> {

    /**
     * 查找会话的所有答案.
     */
    List<QuizAnswer> findBySessionId(UUID sessionId);

    /**
     * 查找会话中特定问题的答案.
     */
    Optional<QuizAnswer> findBySessionIdAndQuestionId(UUID sessionId, UUID questionId);

    /**
     * 删除会话的所有答案.
     */
    void deleteBySessionId(UUID sessionId);

    /**
     * 统计会话的答案数量.
     */
    long countBySessionId(UUID sessionId);
}
