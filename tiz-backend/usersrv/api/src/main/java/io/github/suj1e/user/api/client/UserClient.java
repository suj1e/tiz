package io.github.suj1e.user.api.client;

import io.github.suj1e.user.api.dto.TokenValidationResponse;
import io.github.suj1e.user.api.dto.UserResponse;
import io.github.suj1e.common.response.ApiResponse;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.service.annotation.GetExchange;
import org.springframework.web.service.annotation.HttpExchange;

import java.util.UUID;

/**
 * 用户服务客户端.
 */
@HttpExchange
public interface UserClient {

    @GetExchange("/internal/auth/v1/users/{id}")
    ApiResponse<UserResponse> getUserById(@PathVariable UUID id);

    @GetExchange("/internal/auth/v1/users/validate")
    ApiResponse<TokenValidationResponse> validateToken(@RequestParam String token);
}
