package io.github.suj1e.quiz.repository;

import io.github.suj1e.quiz.entity.QuizResultDetail;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

/**
 * 测验结果详情仓库.
 */
@Repository
public interface QuizResultDetailRepository extends JpaRepository<QuizResultDetail, UUID> {

    /**
     * 查找结果的所有详情.
     */
    List<QuizResultDetail> findByResultId(UUID resultId);

    /**
     * 删除结果的所有详情.
     */
    void deleteByResultId(UUID resultId);
}
