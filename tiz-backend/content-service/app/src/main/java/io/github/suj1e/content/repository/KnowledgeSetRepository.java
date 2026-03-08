package io.github.suj1e.content.repository;

import io.github.suj1e.content.entity.KnowledgeSet;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

/**
 * 题库仓库.
 */
public interface KnowledgeSetRepository extends JpaRepository<KnowledgeSet, UUID> {

    /**
     * 根据用户ID分页查询题库.
     */
    Page<KnowledgeSet> findByUserId(UUID userId, Pageable pageable);

    /**
     * 根据用户ID和分类ID分页查询题库.
     */
    Page<KnowledgeSet> findByUserIdAndCategoryId(UUID userId, UUID categoryId, Pageable pageable);

    /**
     * 根据用户ID和难度分页查询题库.
     */
    Page<KnowledgeSet> findByUserIdAndDifficulty(UUID userId, KnowledgeSet.Difficulty difficulty, Pageable pageable);

    /**
     * 查询用户题库（带分类和标签过滤）.
     */
    @Query("""
        SELECT DISTINCT ks FROM KnowledgeSet ks
        LEFT JOIN ks.tags t
        WHERE ks.userId = :userId
        AND (:categoryId IS NULL OR ks.categoryId = :categoryId)
        AND (:difficulty IS NULL OR ks.difficulty = :difficulty)
        AND (:tagNames IS NULL OR t.name IN :tagNames)
        """)
    Page<KnowledgeSet> findByUserIdWithFilters(
        @Param("userId") UUID userId,
        @Param("categoryId") UUID categoryId,
        @Param("difficulty") KnowledgeSet.Difficulty difficulty,
        @Param("tagNames") List<String> tagNames,
        Pageable pageable
    );

    /**
     * 根据ID和用户ID查询题库.
     */
    Optional<KnowledgeSet> findByIdAndUserId(UUID id, UUID userId);

    /**
     * 统计用户的题库数量.
     */
    long countByUserId(UUID userId);
}
