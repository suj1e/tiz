package io.github.suj1e.tiz.adapter.infra.domainservice.impl;

import io.github.suj1e.tiz.core.domain.Notification;
import io.github.suj1e.tiz.core.domainservice.NotificationDomainService;
import io.github.suj1e.tiz.infra.repository.NotificationRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

/**
 * Notification domain service implementation.
 *
 * @author sujie
 */
@Service
@RequiredArgsConstructor
public class NotificationDomainServiceImpl implements NotificationDomainService {

    private final NotificationRepository notificationRepository;

    @Override
    public List<Notification> getNotifications(Long userId, int page, int size) {
        Page<Notification> notificationPage = notificationRepository
                .findByUserIdOrderByCreatedAtDesc(userId, PageRequest.of(page, size));
        return notificationPage.getContent();
    }

    @Override
    public long getUnreadCount(Long userId) {
        return notificationRepository.countByUserIdAndIsReadFalse(userId);
    }

    @Override
    @Transactional
    public void markAsRead(Long notificationId, Long userId) {
        Notification notification = notificationRepository.findById(notificationId)
                .orElseThrow(() -> new IllegalArgumentException("Notification not found"));

        if (!notification.getUserId().equals(userId)) {
            throw new IllegalArgumentException("Notification does not belong to user");
        }

        if (!notification.getIsRead()) {
            notification.setIsRead(true);
            notification.setReadAt(LocalDateTime.now());
            notificationRepository.save(notification);
        }
    }

    @Override
    @Transactional
    public void markAllAsRead(Long userId) {
        Page<Notification> unreadNotifications = notificationRepository
                .findByUserIdOrderByCreatedAtDesc(userId, PageRequest.of(0, Integer.MAX_VALUE));

        unreadNotifications.getContent().stream()
                .filter(n -> !n.getIsRead())
                .forEach(n -> {
                    n.setIsRead(true);
                    n.setReadAt(LocalDateTime.now());
                });

        notificationRepository.saveAll(unreadNotifications.getContent());
    }

    @Override
    @Transactional
    public Notification createNotification(Long userId, String title, String content, Notification.Type type) {
        Notification notification = Notification.builder()
                .userId(userId)
                .title(title)
                .content(content)
                .type(type)
                .isRead(false)
                .build();

        return notificationRepository.save(notification);
    }
}
