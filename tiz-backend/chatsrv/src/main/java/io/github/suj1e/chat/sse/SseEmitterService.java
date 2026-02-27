package io.github.suj1e.chat.sse;

import com.fasterxml.jackson.databind.ObjectMapper;
import io.github.suj1e.common.client.LlmClient;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;
import reactor.core.publisher.Flux;

import java.io.IOException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

/**
 * SSE 发射器服务.
 * 负责将事件推送给客户端.
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class SseEmitterService {

    private final ObjectMapper objectMapper;

    @Value("${sse.timeout:300000}")
    private long sseTimeout;

    private final ExecutorService executor = Executors.newCachedThreadPool();

    /**
     * 创建 SSE 发射器.
     */
    public SseEmitter createEmitter() {
        SseEmitter emitter = new SseEmitter(sseTimeout);

        emitter.onCompletion(() -> log.debug("SSE connection completed"));
        emitter.onTimeout(() -> log.warn("SSE connection timed out"));
        emitter.onError(e -> log.error("SSE connection error", e));

        return emitter;
    }

    /**
     * 发送 LLM 事件.
     */
    public void sendLlmEvent(SseEmitter emitter, LlmClient.ChatEvent event) {
        try {
            emitter.send(SseEmitter.event()
                .name(event.type())
                .data(objectMapper.writeValueAsString(event.data()), MediaType.APPLICATION_JSON));
        } catch (IOException e) {
            log.error("Failed to send SSE event: {}", event.type(), e);
            emitter.completeWithError(e);
        }
    }

    /**
     * 发送事件流.
     */
    public SseEmitter sendFlux(Flux<LlmClient.ChatEvent> eventFlux) {
        SseEmitter emitter = createEmitter();

        executor.submit(() -> {
            try {
                eventFlux.doOnNext(event -> sendLlmEvent(emitter, event))
                    .doOnComplete(() -> {
                        // 发送 done 事件
                        sendDoneEvent(emitter);
                        emitter.complete();
                    })
                    .doOnError(error -> {
                        log.error("Error in event flux", error);
                        sendErrorEvent(emitter, "CHAT_4030", error.getMessage());
                        emitter.completeWithError(error);
                    })
                    .subscribe();
            } catch (Exception e) {
                log.error("Error processing event flux", e);
                emitter.completeWithError(e);
            }
        });

        return emitter;
    }

    /**
     * 发送 done 事件.
     */
    private void sendDoneEvent(SseEmitter emitter) {
        try {
            emitter.send(SseEmitter.event()
                .name("done")
                .data("{}", MediaType.APPLICATION_JSON));
        } catch (IOException e) {
            log.error("Failed to send done event", e);
        }
    }

    /**
     * 发送错误事件.
     */
    private void sendErrorEvent(SseEmitter emitter, String code, String message) {
        try {
            String errorData = objectMapper.writeValueAsString(new ErrorData(code, message));
            emitter.send(SseEmitter.event()
                .name("error")
                .data(errorData, MediaType.APPLICATION_JSON));
        } catch (IOException e) {
            log.error("Failed to send error event", e);
        }
    }

    /**
     * 发送错误事件并完成.
     */
    public void sendErrorAndComplete(SseEmitter emitter, String code, String message) {
        sendErrorEvent(emitter, code, message);
        emitter.complete();
    }

    /**
     * 错误数据.
     */
    record ErrorData(String code, String message) {}
}
