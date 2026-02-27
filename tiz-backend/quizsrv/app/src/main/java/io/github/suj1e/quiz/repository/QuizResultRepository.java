package io.github.suj1e.quiz.repository;

import io.github.suj1e.quiz.entity.QuizResult;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

/**
 * 测验结果仓库.
 */
@Repository
public interface QuizResultRepository extends JpaRepository<QuizResult, UUID> {

    /**
     * 根据会话 ID 查找结果.
     */
    Optional<QuizResult> findBySessionId(UUID sessionId);

    /**
     * 查找用户的所有结果.
     */
    List<QuizResult> findByUserIdOrderByCompletedAtDesc(UUID userId);

    /**
     * 查找用户在特定题库的结果.
     */
    List<QuizResult> findByUserIdAndKnowledgeSetIdOrderByCompletedAtDesc(UUID userId, UUID knowledgeSetId);

    /**
     * 检查会话是否已有结果.
     */
    boolean existsBySessionId(UUID sessionId);
}
