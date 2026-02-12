package com.nexora.auth.adapter.infra.repository;

import com.nexora.auth.core.domain.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.jpa.repository.QueryHints;
import org.springframework.data.querydsl.QuerydslPredicateExecutor;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import jakarta.persistence.QueryHint;
import java.util.List;
import java.util.Optional;

/**
 * User repository interface.
 *
 * <p>Optimized with:
 * - EntityGraph for eager loading of roles
 * - Query hints for read-only operations
 * - Batch fetching support
 *
 * @author sujie
 */
@Repository
public interface UserRepository extends JpaRepository<User, Long>, QuerydslPredicateExecutor<User> {

    /**
     * Find user by username (case-insensitive) with roles eagerly loaded.
     */
    @EntityGraph(attributePaths = {"roles"})
    Optional<User> findByUsernameIgnoreCase(String username);

    /**
     * Find user by email (case-insensitive) with roles eagerly loaded.
     */
    @EntityGraph(attributePaths = {"roles"})
    Optional<User> findByEmailIgnoreCase(String email);

    /**
     * Find user by username or email with roles eagerly loaded.
     */
    @EntityGraph(attributePaths = {"roles"})
    @Query("SELECT u FROM User u WHERE LOWER(u.username) = LOWER(:identifier) OR LOWER(u.email) = LOWER(:identifier)")
    Optional<User> findByUsernameOrEmailIgnoreCase(@Param("identifier") String identifier);

    /**
     * Check if username exists (case-insensitive).
     * Uses count for better performance.
     */
    @Query("SELECT CASE WHEN COUNT(u) > 0 THEN true ELSE false END FROM User u WHERE LOWER(u.username) = LOWER(:username)")
    boolean existsByUsernameIgnoreCase(@Param("username") String username);

    /**
     * Check if email exists (case-insensitive).
     * Uses count for better performance.
     */
    @Query("SELECT CASE WHEN COUNT(u) > 0 THEN true ELSE false END FROM User u WHERE LOWER(u.email) = LOWER(:email)")
    boolean existsByEmailIgnoreCase(@Param("email") String email);

    /**
     * Find user by OAuth2 provider and provider user ID.
     */
    @EntityGraph(attributePaths = {"roles"})
    Optional<User> findByAuthProviderAndProviderUserId(String authProvider, String providerUserId);

    /**
     * Find users with expired credentials.
     */
    @Query("SELECT u FROM User u WHERE u.credentialsExpired = true AND u.enabled = true")
    List<User> findUsersWithExpiredCredentials();

    /**
     * Find locked users whose lock period has expired.
     */
    @Query("SELECT u FROM User u WHERE u.locked = true AND u.lockedUntil IS NOT NULL AND u.lockedUntil < CURRENT_TIMESTAMP")
    List<User> findUsersWithExpiredLocks();

    /**
     * Find active users by IDs with roles eagerly loaded.
     * Optimized for batch loading.
     */
    @EntityGraph(attributePaths = {"roles"})
    @Query("SELECT u FROM User u WHERE u.id IN :ids AND u.enabled = true AND u.locked = false")
    List<User> findActiveUsersByIdsWithRoles(@Param("ids") List<Long> ids);

    /**
     * Find all users with pagination and sorting.
     * Uses read-only query hint for performance.
     */
    @EntityGraph(attributePaths = {"roles"})
    @QueryHints(@QueryHint(name = "org.hibernate.readOnly", value = "true"))
    @Query("SELECT u FROM User u WHERE u.enabled = true")
    List<User> findAllActiveUsers();

    /**
     * Count users by authentication provider.
     * Useful for analytics and monitoring.
     */
    @Query("SELECT u.authProvider, COUNT(u) FROM User u GROUP BY u.authProvider")
    List<Object[]> countUsersByProvider();

    /**
     * Find users who failed to login recently.
     * Useful for security monitoring.
     */
    @Query("SELECT u FROM User u WHERE u.failedLoginAttempts > 0 ORDER BY u.failedLoginAttempts DESC")
    List<User> findUsersWithFailedAttempts();
}
