package io.github.suj1e.quiz.outbox;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import io.github.suj1e.quiz.entity.OutboxEvent;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Component;

/**
 * Outbox 事件发布器.
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class OutboxPublisher {

    private static final String TOPIC_QUIZ_EVENTS = "quiz.events";

    private final KafkaTemplate<String, String> kafkaTemplate;
    private final ObjectMapper objectMapper;

    /**
     * 发布事件到 Kafka.
     *
     * @param event Outbox 事件
     * @return 是否成功
     */
    public boolean publish(OutboxEvent event) {
        try {
            String key = event.getAggregateId().toString();
            String value = buildMessage(event);

            kafkaTemplate.send(TOPIC_QUIZ_EVENTS, key, value).get();

            log.info("Published event to Kafka: topic={}, key={}, eventType={}",
                TOPIC_QUIZ_EVENTS, key, event.getEventType());

            return true;
        } catch (Exception e) {
            log.error("Failed to publish event to Kafka: id={}, eventType={}",
                event.getId(), event.getEventType(), e);
            return false;
        }
    }

    /**
     * 构建 Kafka 消息.
     */
    private String buildMessage(OutboxEvent event) {
        try {
            // 构建消息结构
            KafkaMessage message = new KafkaMessage(
                event.getEventType(),
                event.getAggregateType(),
                event.getAggregateId().toString(),
                objectMapper.readTree(event.getPayload())
            );

            return objectMapper.writeValueAsString(message);
        } catch (Exception e) {
            log.error("Failed to build Kafka message", e);
            return event.getPayload(); // fallback to raw payload
        }
    }

    /**
     * Kafka 消息结构.
     */
    public record KafkaMessage(
        String eventType,
        String aggregateType,
        String aggregateId,
        JsonNode payload
    ) {}
}
