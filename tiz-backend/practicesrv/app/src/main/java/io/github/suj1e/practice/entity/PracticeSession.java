package io.github.suj1e.practice.entity;

import io.github.suj1e.common.entity.BaseEntity;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

/**
 * 练习会话实体.
 */
@Getter
@Setter
@Entity
@Table(name = "practice_sessions", indexes = {
    @Index(name = "idx_practice_sessions_user_id", columnList = "user_id"),
    @Index(name = "idx_practice_sessions_knowledge_set_id", columnList = "knowledge_set_id"),
    @Index(name = "idx_practice_sessions_status", columnList = "status"),
    @Index(name = "idx_practice_sessions_created_at", columnList = "created_at")
})
public class PracticeSession extends BaseEntity {

    @Column(name = "user_id", nullable = false)
    private UUID userId;

    @Column(name = "knowledge_set_id", nullable = false)
    private UUID knowledgeSetId;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false)
    private SessionStatus status = SessionStatus.IN_PROGRESS;

    @Column(name = "total_questions", nullable = false)
    private Integer totalQuestions = 0;

    @Column(name = "correct_count", nullable = false)
    private Integer correctCount = 0;

    @Column(name = "score", nullable = false, precision = 5, scale = 2)
    private BigDecimal score = BigDecimal.ZERO;

    @Column(name = "completed_at")
    private Instant completedAt;
}
