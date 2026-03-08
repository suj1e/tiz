package io.github.suj1e.chat.repository;

import io.github.suj1e.chat.entity.ChatSession;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

/**
 * 对话会话仓库接口.
 */
@Repository
public interface ChatSessionRepository extends JpaRepository<ChatSession, UUID> {

    /**
     * 根据用户 ID 查找所有会话.
     */
    List<ChatSession> findByUserIdOrderByCreatedAtDesc(UUID userId);

    /**
     * 根据用户 ID 和状态查找会话.
     */
    List<ChatSession> findByUserIdAndStatusOrderByCreatedAtDesc(UUID userId, ChatSession.SessionStatus status);

    /**
     * 根据用户 ID 查找活跃会话.
     */
    Optional<ChatSession> findByUserIdAndStatus(UUID userId, ChatSession.SessionStatus status);

    /**
     * 检查会话是否属于指定用户.
     */
    boolean existsByIdAndUserId(UUID id, UUID userId);
}
