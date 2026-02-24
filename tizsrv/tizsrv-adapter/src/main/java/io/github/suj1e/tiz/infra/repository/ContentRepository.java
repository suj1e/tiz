package io.github.suj1e.tiz.infra.repository;

import io.github.suj1e.tiz.core.domain.Content;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

/**
 * Content repository.
 *
 * @author sujie
 */
@Repository
public interface ContentRepository extends JpaRepository<Content, Long> {

    /**
     * Find featured content.
     */
    @Query("SELECT c FROM Content c WHERE c.isFeatured = true AND c.status = 'PUBLISHED' ORDER BY c.publishedAt DESC")
    Page<Content> findFeatured(Pageable pageable);

    /**
     * Find trending content.
     */
    @Query("SELECT c FROM Content c WHERE c.isTrending = true AND c.status = 'PUBLISHED' ORDER BY c.viewCount DESC")
    Page<Content> findTrending(Pageable pageable);

    /**
     * Find published content with pagination.
     */
    Page<Content> findByStatusOrderByPublishedAtDesc(Content.Status status, Pageable pageable);

    /**
     * Find content by category.
     */
    Page<Content> findByCategoryIdAndStatusOrderByPublishedAtDesc(Long categoryId, Content.Status status, Pageable pageable);

    /**
     * Search content by title or description.
     */
    @Query("SELECT c FROM Content c WHERE c.status = 'PUBLISHED' AND " +
           "(LOWER(c.title) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
           "LOWER(c.description) LIKE LOWER(CONCAT('%', :keyword, '%'))) " +
           "ORDER BY c.publishedAt DESC")
    Page<Content> searchByKeyword(@Param("keyword") String keyword, Pageable pageable);

    /**
     * Count content by category.
     */
    long countByCategoryIdAndStatus(Long categoryId, Content.Status status);
}
