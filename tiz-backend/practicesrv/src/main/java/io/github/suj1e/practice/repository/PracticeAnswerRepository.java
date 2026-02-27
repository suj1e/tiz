package io.github.suj1e.practice.repository;

import io.github.suj1e.practice.entity.PracticeAnswer;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.querydsl.QuerydslPredicateExecutor;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

/**
 * 练习答案 Repository.
 */
public interface PracticeAnswerRepository extends JpaRepository<PracticeAnswer, UUID>,
        QuerydslPredicateExecutor<PracticeAnswer> {

    /**
     * 根据会话ID查询所有答案.
     */
    List<PracticeAnswer> findBySessionIdOrderByAnsweredAtAsc(UUID sessionId);

    /**
     * 根据会话ID和题目ID查询答案.
     */
    Optional<PracticeAnswer> findBySessionIdAndQuestionId(UUID sessionId, UUID questionId);

    /**
     * 统计会话中正确答案数量.
     */
    long countBySessionIdAndIsCorrectTrue(UUID sessionId);

    /**
     * 统计会话中已回答题目数量.
     */
    long countBySessionId(UUID sessionId);

    /**
     * 删除会话中的所有答案.
     */
    void deleteBySessionId(UUID sessionId);
}
