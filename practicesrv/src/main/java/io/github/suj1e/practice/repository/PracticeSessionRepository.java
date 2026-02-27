package io.github.suj1e.practice.repository;

import io.github.suj1e.practice.entity.PracticeSession;
import io.github.suj1e.practice.entity.SessionStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.querydsl.QuerydslPredicateExecutor;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

/**
 * 练习会话 Repository.
 */
public interface PracticeSessionRepository extends JpaRepository<PracticeSession, UUID>,
        QuerydslPredicateExecutor<PracticeSession> {

    /**
     * 根据用户ID查询练习会话列表.
     */
    List<PracticeSession> findByUserIdOrderByCreatedAtDesc(UUID userId);

    /**
     * 根据用户ID和状态查询练习会话列表.
     */
    List<PracticeSession> findByUserIdAndStatusOrderByCreatedAtDesc(UUID userId, SessionStatus status);

    /**
     * 根据ID和用户ID查询练习会话.
     */
    Optional<PracticeSession> findByIdAndUserId(UUID id, UUID userId);

    /**
     * 检查用户是否有进行中的练习会话.
     */
    boolean existsByUserIdAndKnowledgeSetIdAndStatus(UUID userId, UUID knowledgeSetId, SessionStatus status);
}
