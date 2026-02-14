package io.github.suj1e.auth.adapter.infra.repository;

import io.github.suj1e.auth.core.domain.AuditLog;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.querydsl.QuerydslPredicateExecutor;
import org.springframework.data.repository.query.Param;

import java.time.Instant;
import java.util.List;

/**
 * Audit log repository interface.
 *
 * @author sujie
 */
public interface AuditLogRepository extends JpaRepository<AuditLog, Long>, QuerydslPredicateExecutor<AuditLog> {

    /**
     * Find audit logs by user ID.
     */
    List<AuditLog> findByUserIdOrderByCreatedAtDesc(Long userId);

    /**
     * Find audit logs by action.
     */
    List<AuditLog> findByActionOrderByCreatedAtDesc(String action);

    /**
     * Find audit logs by user ID and action.
     */
    List<AuditLog> findByUserIdAndActionOrderByCreatedAtDesc(Long userId, String action);

    /**
     * Find failed login attempts for a user.
     */
    @Query("SELECT al FROM AuditLog al WHERE al.userId = :userId AND al.action IN ('LOGIN_FAILURE', 'OAUTH2_FAILURE') AND al.success = false ORDER BY al.createdAt DESC")
    List<AuditLog> findFailedLoginAttemptsByUserId(@Param("userId") Long userId);

    /**
     * Count failed login attempts since a given time.
     */
    @Query("SELECT COUNT(al) FROM AuditLog al WHERE al.userId = :userId AND al.action IN ('LOGIN_FAILURE', 'OAUTH2_FAILURE') AND al.success = false AND al.createdAt > :since")
    long countFailedLoginAttemptsSince(@Param("userId") Long userId, @Param("since") Instant since);

    /**
     * Find recent audit logs.
     */
    @Query("SELECT al FROM AuditLog al WHERE al.createdAt > :since ORDER BY al.createdAt DESC")
    List<AuditLog> findRecentLogs(@Param("since") Instant since);

    /**
     * Find audit logs by IP address.
     */
    List<AuditLog> findByIpAddressOrderByCreatedAtDesc(String ipAddress);

    /**
     * Delete old audit logs.
     */
    @Query("DELETE FROM AuditLog al WHERE al.createdAt < :before")
    void deleteOldLogs(@Param("before") Instant before);
}
