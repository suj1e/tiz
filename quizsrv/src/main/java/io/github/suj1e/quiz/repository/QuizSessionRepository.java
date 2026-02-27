package io.github.suj1e.quiz.repository;

import io.github.suj1e.quiz.entity.QuizSession;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

/**
 * 测验会话仓库.
 */
@Repository
public interface QuizSessionRepository extends JpaRepository<QuizSession, UUID> {

    /**
     * 根据 ID 和用户 ID 查找会话.
     */
    Optional<QuizSession> findByIdAndUserId(UUID id, UUID userId);

    /**
     * 查找用户的所有会话.
     */
    List<QuizSession> findByUserIdOrderByCreatedAtDesc(UUID userId);

    /**
     * 查找用户的进行中会话.
     */
    List<QuizSession> findByUserIdAndStatus(UUID userId, QuizSession.Status status);
}
