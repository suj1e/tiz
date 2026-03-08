package io.github.suj1e.chat.entity;

import jakarta.persistence.*;
import lombok.*;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.Instant;
import java.util.UUID;

/**
 * 对话消息实体.
 */
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Entity
@Table(name = "chat_messages")
@EntityListeners(AuditingEntityListener.class)
public class ChatMessage {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "id", updatable = false, nullable = false)
    private UUID id;

    /**
     * 所属会话 ID.
     */
    @Column(name = "session_id", nullable = false)
    private UUID sessionId;

    /**
     * 消息角色: user, assistant.
     */
    @Enumerated(EnumType.STRING)
    @Column(name = "role", nullable = false)
    private MessageRole role;

    /**
     * 消息内容.
     */
    @Column(name = "content", nullable = false, columnDefinition = "text")
    private String content;

    /**
     * 创建时间.
     */
    @CreatedDate
    @Column(name = "created_at", updatable = false, nullable = false)
    private Instant createdAt;

    /**
     * 消息角色枚举.
     */
    public enum MessageRole {
        USER,       // 用户消息
        ASSISTANT   // AI 助手消息
    }
}
