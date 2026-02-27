package io.github.suj1e.quiz.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.Instant;
import java.util.UUID;

/**
 * 测验答案实体 (批量提交前暂存).
 */
@Getter
@Setter
@Entity
@Table(name = "quiz_answers", uniqueConstraints = {
    @UniqueConstraint(name = "uk_quiz_answers_session_question", columnNames = {"session_id", "question_id"})
})
@EntityListeners(AuditingEntityListener.class)
public class QuizAnswer {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "id", updatable = false, nullable = false)
    private UUID id;

    @Column(name = "session_id", nullable = false)
    private UUID sessionId;

    @Column(name = "question_id", nullable = false)
    private UUID questionId;

    @Column(name = "user_answer", nullable = false, columnDefinition = "TEXT")
    private String userAnswer;

    @Column(name = "answered_at", nullable = false)
    private Instant answeredAt;

    @CreatedDate
    @Column(name = "created_at", updatable = false, nullable = false)
    private Instant createdAt;
}
