package com.nexora.auth.adapter.infra.job;

import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import com.nexora.auth.adapter.infra.repository.OutboxEventRepository;
import com.nexora.auth.core.domain.OutboxEvent;
import org.quartz.*;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * Outbox event publisher job.
 *
 * <p>Scans for pending outbox events and publishes them to Kafka.
 * This job ensures at-least-once delivery of events.
 *
 * <p>Job settings:
 * - Runs every 10 seconds (configurable)
 * - Processes up to 100 events per run
 * - Retries failed events up to 3 times
 * - Marks events as FAILED after max retries
 *
 * @author sujie
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class OutboxPublisherJob implements Job {

    public static final String JOB_NAME = "OUTBOX_PUBLISHER_JOB";

    private final OutboxEventRepository outboxEventRepository;
    private final KafkaTemplate<String, String> kafkaTemplate;
    private final ObjectMapper objectMapper;

    @Override
    @Transactional
    public void execute(JobExecutionContext context) {
        log.debug("Starting outbox event publisher job");

        // Find pending events (limit to prevent long-running transactions)
        List<OutboxEvent> pendingEvents = outboxEventRepository.findTop100ByStatusOrderByCreatedAtAsc(OutboxEvent.OutboxStatus.NEW);

        if (pendingEvents.isEmpty()) {
            log.debug("No pending outbox events to publish");
            return;
        }

        log.info("Found {} pending outbox events to publish", pendingEvents.size());

        int successCount = 0;
        int failureCount = 0;

        for (OutboxEvent event : pendingEvents) {
            try {
                // Send to Kafka (key = bizId for partitioning)
                kafkaTemplate.send(event.getTopic(), event.getBizId(), event.getPayload())
                    .get(); // Wait for acknowledgment

                // Mark as sent
                event.markSent();
                outboxEventRepository.save(event);
                successCount++;

            } catch (Exception e) {
                log.error("Failed to publish outbox event {} to topic {}: {}",
                    event.getId(), event.getTopic(), e.getMessage());

                // Increment retry count
                boolean maxRetriesExceeded = event.incrementRetry(3);

                if (maxRetriesExceeded) {
                    event.markFailed(e.getMessage());
                    log.warn("Outbox event {} marked as FAILED after {} retries",
                        event.getId(), event.getRetryCount());
                }

                outboxEventRepository.save(event);
                failureCount++;
            }
        }

        log.info("Outbox publisher job completed: {} published, {} failed", successCount, failureCount);
    }
}
