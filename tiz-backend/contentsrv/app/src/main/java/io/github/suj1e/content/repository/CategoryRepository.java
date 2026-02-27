package io.github.suj1e.content.repository;

import io.github.suj1e.content.entity.Category;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

/**
 * 分类仓库.
 */
public interface CategoryRepository extends JpaRepository<Category, UUID> {

    /**
     * 查找所有分类并按排序字段排序.
     */
    List<Category> findAllByOrderBySortOrderAsc();

    /**
     * 根据名称查找分类.
     */
    Optional<Category> findByName(String name);

    /**
     * 检查名称是否存在.
     */
    boolean existsByName(String name);
}
