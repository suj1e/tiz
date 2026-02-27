package io.github.suj1e.quiz.entity;

import io.github.suj1e.common.entity.BaseEntity;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.Instant;
import java.util.UUID;

/**
 * 测验会话实体.
 */
@Getter
@Setter
@Entity
@Table(name = "quiz_sessions")
public class QuizSession extends BaseEntity {

    @Column(name = "user_id", nullable = false)
    private UUID userId;

    @Column(name = "knowledge_set_id", nullable = false)
    private UUID knowledgeSetId;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false)
    private Status status = Status.in_progress;

    @Column(name = "time_limit")
    private Integer timeLimit;

    @Column(name = "total_questions", nullable = false)
    private Integer totalQuestions = 0;

    @Column(name = "started_at", nullable = false)
    private Instant startedAt;

    @Column(name = "completed_at")
    private Instant completedAt;

    /**
     * 测验会话状态枚举.
     */
    public enum Status {
        in_progress, completed, expired
    }
}
