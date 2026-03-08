package io.github.suj1e.chat.repository;

import io.github.suj1e.chat.entity.ChatMessage;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

/**
 * 对话消息仓库接口.
 */
@Repository
public interface ChatMessageRepository extends JpaRepository<ChatMessage, UUID> {

    /**
     * 根据会话 ID 查找所有消息，按创建时间排序.
     */
    List<ChatMessage> findBySessionIdOrderByCreatedAtAsc(UUID sessionId);

    /**
     * 根据会话 ID 查找最近的消息.
     */
    List<ChatMessage> findTop20BySessionIdOrderByCreatedAtDesc(UUID sessionId);

    /**
     * 统计会话的消息数量.
     */
    long countBySessionId(UUID sessionId);

    /**
     * 删除会话的所有消息.
     */
    void deleteBySessionId(UUID sessionId);
}
