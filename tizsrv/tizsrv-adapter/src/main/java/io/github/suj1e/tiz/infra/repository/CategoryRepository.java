package io.github.suj1e.tiz.infra.repository;

import io.github.suj1e.tiz.core.domain.Category;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * Category repository.
 *
 * @author sujie
 */
@Repository
public interface CategoryRepository extends JpaRepository<Category, Long> {

    /**
     * Find all active categories ordered by sort order.
     */
    List<Category> findByIsActiveTrueOrderBySortOrderAsc();
}
