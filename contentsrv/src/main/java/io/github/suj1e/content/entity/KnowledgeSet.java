package io.github.suj1e.content.entity;

import io.github.suj1e.common.entity.SoftDeletableEntity;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

/**
 * 题库实体 (支持软删除).
 */
@Getter
@Setter
@Entity
@Table(name = "knowledge_sets")
public class KnowledgeSet extends SoftDeletableEntity {

    @Column(name = "user_id", nullable = false)
    private UUID userId;

    @Column(name = "title", nullable = false)
    private String title;

    @Column(name = "category_id")
    private UUID categoryId;

    @Enumerated(EnumType.STRING)
    @Column(name = "difficulty", nullable = false)
    private Difficulty difficulty = Difficulty.medium;

    @Column(name = "question_count", nullable = false)
    private Integer questionCount = 0;

    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(
        name = "knowledge_set_tags",
        joinColumns = @JoinColumn(name = "knowledge_set_id"),
        inverseJoinColumns = @JoinColumn(name = "tag_id")
    )
    private List<Tag> tags = new ArrayList<>();

    /**
     * 难度枚举.
     */
    public enum Difficulty {
        easy, medium, hard
    }
}
