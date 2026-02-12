package com.nexora.auth.adapter.infra.repository;

import com.nexora.auth.core.domain.OutboxEvent;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;

/**
 * Outbox event repository interface.
 *
 * @author sujie
 */
public interface OutboxEventRepository extends JpaRepository<OutboxEvent, Long> {

    /**
     * Find pending events ordered by creation time.
     *
     * @param status the event status
     * @param limit  maximum number of events to return
     * @return list of pending events
     */
    @Query("SELECT e FROM OutboxEvent e WHERE e.status = :status ORDER BY e.createdAt ASC")
    List<OutboxEvent> findByStatusOrderByCreatedAtAsc(@Param("status") OutboxEvent.OutboxStatus status,
                                                      @Param("limit") int limit);

    /**
     * Find pending events with a limit.
     *
     * @param status the event status
     * @param limit  maximum number of events to return
     * @return list of pending events
     */
    List<OutboxEvent> findTop100ByStatusOrderByCreatedAtAsc(OutboxEvent.OutboxStatus status);

    /**
     * Find events that have exceeded maximum retries.
     *
     * @param maxRetries maximum retry count
     * @return list of failed events
     */
    @Query("SELECT e FROM OutboxEvent e WHERE e.status = 'FAILED' AND e.retryCount >= :maxRetries")
    List<OutboxEvent> findFailedEvents(@Param("maxRetries") int maxRetries);

    /**
     * Delete successfully sent events older than the given timestamp.
     *
     * @param before the timestamp threshold
     * @return number of deleted events
     */
    @Modifying
    @Transactional
    @Query("DELETE FROM OutboxEvent e WHERE e.status = 'SENT' AND e.sentAt < :before")
    int deleteSentEventsBefore(@Param("before") Instant before);

    /**
     * Count pending events.
     *
     * @param status the event status
     * @return count of events
     */
    long countByStatus(OutboxEvent.OutboxStatus status);
}
