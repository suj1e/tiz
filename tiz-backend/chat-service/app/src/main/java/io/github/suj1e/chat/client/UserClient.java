package io.github.suj1e.chat.client;

import io.github.suj1e.user.api.dto.AiConfigResponse;
import org.springframework.web.service.annotation.GetExchange;
import org.springframework.web.service.annotation.HttpExchange;
import io.github.suj1e.common.response.ApiResponse;

import java.util.UUID;

/**
 * User 服务客户端.
 * 用于获取用户的 AI 配置.
 */
@HttpExchange
public interface UserClient {

    /**
     * 获取用户的 AI 配置.
     *
     * @param userId 用户 ID
     * @return AI 配置响应（包裹在 ApiResponse 中）
     */
    @GetExchange("/internal/user/v1/ai-config?user_id={userId}")
    ApiResponse<AiConfigResponse> getAiConfig(UUID userId);
}
