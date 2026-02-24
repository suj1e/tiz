package io.github.suj1e.tiz.api.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * Notification response DTO.
 *
 * @author sujie
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class NotificationResponse {

    private Long id;
    private String title;
    private String content;
    private String type;
    private Boolean isRead;
    private Long relatedId;
    private String relatedType;
    private LocalDateTime createdAt;
    private LocalDateTime readAt;
}
