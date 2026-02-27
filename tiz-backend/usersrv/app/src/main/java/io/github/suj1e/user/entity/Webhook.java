package io.github.suj1e.user.entity;

import io.github.suj1e.common.entity.BaseEntity;
import io.github.suj1e.user.converter.StringListConverter;
import jakarta.persistence.*;
import lombok.*;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

/**
 * Webhook 配置实体.
 */
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Entity
@Table(name = "webhooks")
public class Webhook extends BaseEntity {

    @Column(name = "user_id", nullable = false)
    private UUID userId;

    @Column(name = "url", nullable = false, length = 500)
    private String url;

    @Column(name = "enabled", nullable = false)
    @Builder.Default
    private Boolean enabled = true;

    @Convert(converter = StringListConverter.class)
    @Column(name = "events", nullable = false, columnDefinition = "JSON")
    @Builder.Default
    private List<String> events = new ArrayList<>();

    @Column(name = "secret", length = 255)
    private String secret;
}
