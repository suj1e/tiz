package io.github.suj1e.tiz.infra.repository;

import io.github.suj1e.tiz.core.domain.Notification;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

/**
 * Notification repository.
 *
 * @author sujie
 */
@Repository
public interface NotificationRepository extends JpaRepository<Notification, Long> {

    /**
     * Find notifications by user ID with pagination.
     */
    Page<Notification> findByUserIdOrderByCreatedAtDesc(Long userId, Pageable pageable);

    /**
     * Count unread notifications for a user.
     */
    long countByUserIdAndIsReadFalse(Long userId);
}
