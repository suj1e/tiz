package io.github.suj1e.quiz.entity;

import io.github.suj1e.common.entity.BaseEntity;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

/**
 * 测验结果实体.
 */
@Getter
@Setter
@Entity
@Table(name = "quiz_results", uniqueConstraints = {
    @UniqueConstraint(name = "uk_quiz_results_session_id", columnNames = {"session_id"})
})
public class QuizResult extends BaseEntity {

    @Column(name = "session_id", nullable = false)
    private UUID sessionId;

    @Column(name = "user_id", nullable = false)
    private UUID userId;

    @Column(name = "knowledge_set_id", nullable = false)
    private UUID knowledgeSetId;

    @Column(name = "score", nullable = false, precision = 5, scale = 2)
    private BigDecimal score = BigDecimal.ZERO;

    @Column(name = "total", nullable = false, precision = 5, scale = 2)
    private BigDecimal total = new BigDecimal("100.00");

    @Column(name = "correct_count", nullable = false)
    private Integer correctCount = 0;

    @Column(name = "time_spent", nullable = false)
    private Integer timeSpent = 0;

    @Column(name = "completed_at", nullable = false)
    private Instant completedAt;
}
