package com.nexora.auth.adapter.infra.repository;

import com.nexora.auth.core.domain.RefreshToken;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.querydsl.QuerydslPredicateExecutor;
import org.springframework.data.repository.query.Param;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;
import java.util.Optional;

/**
 * Refresh token repository interface.
 *
 * <p>Optimized with batch operations and composite queries for better performance.
 *
 * @author sujie
 */
public interface RefreshTokenRepository extends JpaRepository<RefreshToken, Long>, QuerydslPredicateExecutor<RefreshToken> {

    /**
     * Find refresh token by token string.
     */
    Optional<RefreshToken> findByToken(String token);

    /**
     * Find all refresh tokens for a user.
     */
    List<RefreshToken> findByUserId(Long userId);

    /**
     * Find valid refresh tokens for a user (not revoked and not expired).
     */
    @Query("SELECT rt FROM RefreshToken rt WHERE rt.userId = :userId AND rt.revoked = false AND rt.expiresAt > :now")
    List<RefreshToken> findValidTokensByUserId(@Param("userId") Long userId, @Param("now") Instant now);

    /**
     * Count valid refresh tokens for a user.
     * Optimized query that only counts instead of loading entities.
     */
    @Query("SELECT COUNT(rt) FROM RefreshToken rt WHERE rt.userId = :userId AND rt.revoked = false AND rt.expiresAt > :now")
    long countValidTokensByUserId(@Param("userId") Long userId, @Param("now") Instant now);

    /**
     * Find oldest valid tokens for cleanup.
     * Returns tokens ordered by creation date for LRU eviction.
     */
    @Query("SELECT rt FROM RefreshToken rt WHERE rt.userId = :userId AND rt.revoked = false AND rt.expiresAt > :now ORDER BY rt.createdAt ASC")
    List<RefreshToken> findOldestValidTokensByUserId(@Param("userId") Long userId, @Param("now") Instant now);

    /**
     * Find all expired tokens older than specified date.
     */
    @Query("SELECT rt FROM RefreshToken rt WHERE rt.expiresAt < :cutoff")
    List<RefreshToken> findExpiredTokens(@Param("cutoff") Instant cutoff);

    /**
     * Find all revoked tokens.
     */
    List<RefreshToken> findByRevokedTrue();

    /**
     * Delete all expired tokens in batch.
     * Uses bulk delete for better performance.
     */
    @Modifying
    @Transactional
    @Query("DELETE FROM RefreshToken rt WHERE rt.expiresAt < :now")
    int deleteExpiredTokens(@Param("now") Instant now);

    /**
     * Delete all revoked tokens in batch.
     * Uses bulk delete for better performance.
     */
    @Modifying
    @Transactional
    @Query("DELETE FROM RefreshToken rt WHERE rt.revoked = true")
    int deleteRevokedTokens();

    /**
     * Revoke all tokens for a specific user.
     * Bulk operation for logout functionality.
     */
    @Modifying
    @Transactional
    @Query("UPDATE RefreshToken rt SET rt.revoked = true, rt.revokedAt = :revokedAt WHERE rt.userId = :userId AND rt.revoked = false")
    int revokeAllUserTokens(@Param("userId") Long userId, @Param("revokedAt") Instant revokedAt);

    /**
     * Find tokens that will expire soon (for proactive refresh).
     * Useful for notifying users to refresh before expiry.
     */
    @Query("SELECT rt FROM RefreshToken rt WHERE rt.expiresAt BETWEEN :now AND :soon AND rt.revoked = false")
    List<RefreshToken> findTokensExpiringSoon(@Param("now") Instant now, @Param("soon") Instant soon);
}
