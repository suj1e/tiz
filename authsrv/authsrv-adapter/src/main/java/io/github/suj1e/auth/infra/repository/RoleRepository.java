package io.github.suj1e.auth.adapter.infra.repository;

import io.github.suj1e.auth.core.domain.Role;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.querydsl.QuerydslPredicateExecutor;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

/**
 * Role repository interface.
 *
 * @author sujie
 */
public interface RoleRepository extends JpaRepository<Role, Long>, QuerydslPredicateExecutor<Role> {

    /**
     * Find role by name (case-insensitive).
     */
    Optional<Role> findByNameIgnoreCase(String name);

    /**
     * Check if role exists by name (case-insensitive).
     */
    @Query("SELECT CASE WHEN COUNT(r) > 0 THEN true ELSE false END FROM Role r WHERE LOWER(r.name) = LOWER(:name)")
    boolean existsByNameIgnoreCase(@Param("name") String name);
}
