package io.github.suj1e.quiz.repository;

import io.github.suj1e.quiz.entity.OutboxEvent;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

/**
 * Outbox 事件仓库.
 */
@Repository
public interface OutboxEventRepository extends JpaRepository<OutboxEvent, UUID> {

    /**
     * 查找待发送的事件 (分页).
     */
    @Query("SELECT e FROM OutboxEvent e WHERE e.status = io.github.suj1e.quiz.entity.OutboxEvent$Status.PENDING ORDER BY e.createdAt ASC")
    List<OutboxEvent> findPendingEvents(Pageable pageable);

    /**
     * 查找失败但可重试的事件.
     */
    @Query("SELECT e FROM OutboxEvent e WHERE e.status = io.github.suj1e.quiz.entity.OutboxEvent$Status.FAILED AND e.retryCount < :maxRetries ORDER BY e.createdAt ASC")
    List<OutboxEvent> findFailedEventsForRetry(int maxRetries, Pageable pageable);

    /**
     * 更新事件状态为已发送.
     */
    @Modifying
    @Query("UPDATE OutboxEvent e SET e.status = io.github.suj1e.quiz.entity.OutboxEvent$Status.SENT, e.sentAt = CURRENT_TIMESTAMP WHERE e.id = :id")
    void markAsSent(UUID id);

    /**
     * 更新事件状态为失败并增加重试次数.
     */
    @Modifying
    @Query("UPDATE OutboxEvent e SET e.status = io.github.suj1e.quiz.entity.OutboxEvent$Status.FAILED, e.retryCount = e.retryCount + 1, e.errorMessage = :errorMessage WHERE e.id = :id")
    void markAsFailed(UUID id, String errorMessage);
}
