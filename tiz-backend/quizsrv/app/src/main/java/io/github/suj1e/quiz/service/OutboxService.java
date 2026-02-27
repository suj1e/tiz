package io.github.suj1e.quiz.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import io.github.suj1e.quiz.dto.QuizCompletedEvent;
import io.github.suj1e.quiz.entity.OutboxEvent;
import io.github.suj1e.quiz.repository.OutboxEventRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

/**
 * Outbox 服务.
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class OutboxService {

    private final OutboxEventRepository outboxEventRepository;
    private final ObjectMapper objectMapper;

    /**
     * 创建测验完成事件.
     *
     * @param event 测验完成事件
     * @return 创建的事件 ID
     */
    @Transactional
    public UUID createQuizCompletedEvent(QuizCompletedEvent event) {
        OutboxEvent outboxEvent = new OutboxEvent();
        outboxEvent.setAggregateType("quiz_result");
        outboxEvent.setAggregateId(event.quizId());
        outboxEvent.setEventType("quiz.completed");
        outboxEvent.setPayload(toJson(event));

        outboxEvent = outboxEventRepository.save(outboxEvent);
        log.info("Created outbox event: id={}, type={}, aggregateId={}",
            outboxEvent.getId(), outboxEvent.getEventType(), outboxEvent.getAggregateId());

        return outboxEvent.getId();
    }

    /**
     * 对象转 JSON.
     */
    private String toJson(Object obj) {
        try {
            return objectMapper.writeValueAsString(obj);
        } catch (JsonProcessingException e) {
            log.error("Failed to serialize object", e);
            throw new RuntimeException("Failed to serialize event payload", e);
        }
    }
}
