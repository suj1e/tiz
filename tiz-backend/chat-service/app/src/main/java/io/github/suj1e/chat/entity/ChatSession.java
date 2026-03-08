package io.github.suj1e.chat.entity;

import io.github.suj1e.common.entity.BaseEntity;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.util.UUID;

/**
 * 对话会话实体.
 */
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Entity
@Table(name = "chat_sessions")
public class ChatSession extends BaseEntity {

    /**
     * 用户 ID.
     */
    @Column(name = "user_id", nullable = false)
    private UUID userId;

    /**
     * 会话状态: active, confirmed, expired.
     */
    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false)
    @Builder.Default
    private SessionStatus status = SessionStatus.ACTIVE;

    /**
     * 生成的摘要 (JSON).
     */
    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "generated_summary", columnDefinition = "json")
    private String generatedSummary;

    /**
     * 确认后创建的题库 ID.
     */
    @Column(name = "confirmed_knowledge_set_id")
    private UUID confirmedKnowledgeSetId;

    /**
     * 会话状态枚举.
     */
    public enum SessionStatus {
        ACTIVE,     // 活跃中，可以继续对话
        CONFIRMED,  // 已确认生成题库
        EXPIRED     // 已过期
    }
}
