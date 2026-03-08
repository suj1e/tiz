package io.github.suj1e.chat.api.client;

import io.github.suj1e.chat.api.dto.ChatRequest;
import io.github.suj1e.chat.api.dto.ChatEvent;
import reactor.core.publisher.Flux;

/**
 * Chat 服务客户端接口.
 * 用于其他服务调用 Chat 服务.
 */
public interface ChatClient {

    /**
     * 流式对话.
     *
     * @param request 对话请求
     * @return SSE 事件流
     */
    Flux<ChatEvent> chatStream(ChatRequest request);
}
