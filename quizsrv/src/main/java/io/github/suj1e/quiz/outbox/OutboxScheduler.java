package io.github.suj1e.quiz.outbox;

import io.github.suj1e.quiz.entity.OutboxEvent;
import io.github.suj1e.quiz.repository.OutboxEventRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.domain.PageRequest;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * Outbox 事件扫描和发布任务.
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class OutboxScheduler {

    private final OutboxEventRepository outboxEventRepository;
    private final OutboxPublisher outboxPublisher;

    @Value("${outbox.batch-size:100}")
    private int batchSize;

    @Value("${outbox.max-retries:3}")
    private int maxRetries;

    /**
     * 定时扫描待发送的事件并发布.
     * 默认每 5 秒执行一次.
     */
    @Scheduled(fixedDelayString = "${outbox.scan-interval:5000}")
    public void scanAndPublish() {
        // 查找待发送的事件
        List<OutboxEvent> pendingEvents = outboxEventRepository.findPendingEvents(
            PageRequest.of(0, batchSize)
        );

        if (!pendingEvents.isEmpty()) {
            log.info("Found {} pending outbox events to publish", pendingEvents.size());
        }

        for (OutboxEvent event : pendingEvents) {
            publishEvent(event);
        }

        // 查找失败但可重试的事件
        List<OutboxEvent> retryEvents = outboxEventRepository.findFailedEventsForRetry(
            maxRetries, PageRequest.of(0, batchSize)
        );

        if (!retryEvents.isEmpty()) {
            log.info("Found {} failed outbox events to retry", retryEvents.size());
        }

        for (OutboxEvent event : retryEvents) {
            publishEvent(event);
        }
    }

    /**
     * 发布单个事件.
     */
    @Transactional
    public void publishEvent(OutboxEvent event) {
        try {
            boolean success = outboxPublisher.publish(event);

            if (success) {
                outboxEventRepository.markAsSent(event.getId());
                log.info("Outbox event sent successfully: id={}", event.getId());
            } else {
                markAsFailed(event, "Failed to publish to Kafka");
            }
        } catch (Exception e) {
            log.error("Error publishing outbox event: id={}", event.getId(), e);
            markAsFailed(event, e.getMessage());
        }
    }

    /**
     * 标记事件为失败.
     */
    private void markAsFailed(OutboxEvent event, String errorMessage) {
        if (event.getRetryCount() >= maxRetries - 1) {
            log.error("Outbox event reached max retries: id={}, retries={}",
                event.getId(), event.getRetryCount());
        }

        outboxEventRepository.markAsFailed(event.getId(),
            truncateErrorMessage(errorMessage));
    }

    /**
     * 截断错误消息.
     */
    private String truncateErrorMessage(String message) {
        if (message == null) {
            return null;
        }
        return message.length() > 500 ? message.substring(0, 500) : message;
    }
}
