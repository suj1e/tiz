package io.github.suj1e.content.entity;

import io.github.suj1e.common.entity.BaseEntity;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.util.List;
import java.util.UUID;

/**
 * 题目实体.
 */
@Getter
@Setter
@Entity
@Table(name = "questions")
public class Question extends BaseEntity {

    @Column(name = "knowledge_set_id", nullable = false)
    private UUID knowledgeSetId;

    @Enumerated(EnumType.STRING)
    @Column(name = "type", nullable = false)
    private Type type;

    @Column(name = "content", nullable = false, columnDefinition = "TEXT")
    private String content;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "options", columnDefinition = "JSON")
    private List<String> options;

    @Column(name = "answer", nullable = false, columnDefinition = "TEXT")
    private String answer;

    @Column(name = "explanation", columnDefinition = "TEXT")
    private String explanation;

    @Column(name = "rubric", columnDefinition = "TEXT")
    private String rubric;

    @Column(name = "sort_order", nullable = false)
    private Integer sortOrder = 0;

    /**
     * 题目类型枚举.
     */
    public enum Type {
        choice, essay
    }
}
