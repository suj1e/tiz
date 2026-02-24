package io.github.suj1e.tiz.adapter.rest;

import io.github.suj1e.tiz.api.dto.response.NotificationResponse;
import io.github.suj1e.tiz.core.domain.Notification;
import io.github.suj1e.tiz.core.domainservice.NotificationDomainService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * Notification controller.
 *
 * @author sujie
 */
@RestController
@RequestMapping("/v1/notifications")
@RequiredArgsConstructor
public class NotificationController {

    private final NotificationDomainService notificationDomainService;

    /**
     * Get notifications for the authenticated user.
     */
    @GetMapping
    public ResponseEntity<Map<String, Object>> getNotifications(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestHeader("X-User-Id") Long userId) {

        List<Notification> notifications = notificationDomainService.getNotifications(userId, page, size);
        long unreadCount = notificationDomainService.getUnreadCount(userId);

        List<NotificationResponse> notificationResponses = notifications.stream()
                .map(this::toResponse)
                .collect(Collectors.toList());

        Map<String, Object> response = new HashMap<>();
        response.put("notifications", notificationResponses);
        response.put("unreadCount", unreadCount);

        return ResponseEntity.ok(response);
    }

    /**
     * Mark a notification as read.
     */
    @PutMapping("/{id}/read")
    public ResponseEntity<Void> markAsRead(
            @PathVariable Long id,
            @RequestHeader("X-User-Id") Long userId) {

        notificationDomainService.markAsRead(id, userId);
        return ResponseEntity.ok().build();
    }

    /**
     * Mark all notifications as read.
     */
    @PutMapping("/read-all")
    public ResponseEntity<Void> markAllAsRead(@RequestHeader("X-User-Id") Long userId) {
        notificationDomainService.markAllAsRead(userId);
        return ResponseEntity.ok().build();
    }

    /**
     * Get unread notification count.
     */
    @GetMapping("/unread-count")
    public ResponseEntity<Map<String, Long>> getUnreadCount(@RequestHeader("X-User-Id") Long userId) {
        long count = notificationDomainService.getUnreadCount(userId);
        return ResponseEntity.ok(Map.of("count", count));
    }

    private NotificationResponse toResponse(Notification notification) {
        return NotificationResponse.builder()
                .id(notification.getId())
                .title(notification.getTitle())
                .content(notification.getContent())
                .type(notification.getType().name())
                .isRead(notification.getIsRead())
                .relatedId(notification.getRelatedId())
                .relatedType(notification.getRelatedType())
                .createdAt(notification.getCreatedAt())
                .readAt(notification.getReadAt())
                .build();
    }
}
