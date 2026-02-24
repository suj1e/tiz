package io.github.suj1e.tiz.core.domainservice;

import io.github.suj1e.tiz.core.domain.Notification;
import java.util.List;

/**
 * Notification domain service interface.
 *
 * @author sujie
 */
public interface NotificationDomainService {

    /**
     * Get notifications for a user.
     */
    List<Notification> getNotifications(Long userId, int page, int size);

    /**
     * Get unread notification count for a user.
     */
    long getUnreadCount(Long userId);

    /**
     * Mark a notification as read.
     */
    void markAsRead(Long notificationId, Long userId);

    /**
     * Mark all notifications as read for a user.
     */
    void markAllAsRead(Long userId);

    /**
     * Create a notification.
     */
    Notification createNotification(Long userId, String title, String content, Notification.Type type);
}
