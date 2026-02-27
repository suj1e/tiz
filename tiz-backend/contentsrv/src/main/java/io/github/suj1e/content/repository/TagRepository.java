package io.github.suj1e.content.repository;

import io.github.suj1e.content.entity.Tag;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

/**
 * 标签仓库.
 */
public interface TagRepository extends JpaRepository<Tag, UUID> {

    /**
     * 查找所有标签并按名称排序.
     */
    List<Tag> findAllByOrderByNameAsc();

    /**
     * 根据名称查找标签.
     */
    Optional<Tag> findByName(String name);

    /**
     * 检查名称是否存在.
     */
    boolean existsByName(String name);

    /**
     * 根据名称列表查找标签.
     */
    List<Tag> findByNameIn(List<String> names);
}
