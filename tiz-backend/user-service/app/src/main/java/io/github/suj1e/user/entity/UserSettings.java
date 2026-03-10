package io.github.suj1e.user.entity;

import jakarta.persistence.*;
import lombok.*;
import org.springframework.data.annotation.CreatedBy;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedBy;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.Instant;
import java.util.UUID;

/**
 * 用户设置实体.
 * 以 user_id 为主键，不自动生成.
 */
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Entity
@Table(name = "user_settings")
@EntityListeners(AuditingEntityListener.class)
public class UserSettings {

    @Id
    @Column(name = "user_id", nullable = false)
    private UUID userId;

    @Column(name = "theme", nullable = false)
    @Builder.Default
    private String theme = "system";

    @Column(name = "preferred_model", nullable = false)
    @Builder.Default
    private String preferredModel = "";

    @Column(name = "temperature", nullable = false)
    @Builder.Default
    private Double temperature = 0.7;

    @Column(name = "max_tokens", nullable = false)
    @Builder.Default
    private Integer maxTokens = 2048;

    @Column(name = "system_prompt", nullable = false, columnDefinition = "TEXT")
    @Builder.Default
    private String systemPrompt = "";

    @Column(name = "response_language", nullable = false)
    @Builder.Default
    private String responseLanguage = "";

    @Column(name = "custom_api_url", nullable = false)
    @Builder.Default
    private String customApiUrl = "";

    @Column(name = "custom_api_key", nullable = false)
    @Builder.Default
    private String customApiKey = "";

    @CreatedDate
    @Column(name = "created_at", updatable = false, nullable = false)
    private Instant createdAt;

    @LastModifiedDate
    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt;

    @CreatedBy
    @Column(name = "created_by", updatable = false)
    private UUID createdBy;

    @LastModifiedBy
    @Column(name = "updated_by")
    private UUID updatedBy;
}
