package io.github.suj1e.content.repository;

import io.github.suj1e.content.entity.Question;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

/**
 * 题目仓库.
 */
public interface QuestionRepository extends JpaRepository<Question, UUID> {

    /**
     * 根据题库ID查询所有题目并按排序字段排序.
     */
    List<Question> findByKnowledgeSetIdOrderBySortOrderAsc(UUID knowledgeSetId);

    /**
     * 根据题库ID查询前N个题目.
     */
    List<Question> findTopByKnowledgeSetIdOrderBySortOrderAsc(UUID knowledgeSetId, org.springframework.data.domain.Pageable pageable);

    /**
     * 统计题库中的题目数量.
     */
    long countByKnowledgeSetId(UUID knowledgeSetId);

    /**
     * 根据题库ID删除所有题目.
     */
    void deleteByKnowledgeSetId(UUID knowledgeSetId);

    /**
     * 根据ID和题库ID查询题目.
     */
    Optional<Question> findByIdAndKnowledgeSetId(UUID id, UUID knowledgeSetId);
}
