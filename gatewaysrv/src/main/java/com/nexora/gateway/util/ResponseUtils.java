package com.nexora.gateway.util;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import com.nexora.gateway.constants.ErrorCode;
import com.nexora.gateway.exception.GatewayException;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.web.reactive.function.server.ServerResponse;
import org.springframework.web.server.ServerWebExchange;
import reactor.core.publisher.Mono;

import java.time.Instant;
import java.util.HashMap;
import java.util.Map;

/**
 * 响应工具类.
 */
public final class ResponseUtils {

    private static final ObjectMapper OBJECT_MAPPER = new ObjectMapper()
            .registerModule(new JavaTimeModule());

    private ResponseUtils() {
        // 工具类私有构造
    }

    /**
     * 写入错误响应.
     */
    public static Mono<Void> writeErrorResponse(
        ServerWebExchange exchange,
        HttpStatus status,
        String message
    ) {
        var response = exchange.getResponse();
        response.setStatusCode(status);
        response.getHeaders().setContentType(MediaType.APPLICATION_JSON);

        var errorResponse = Map.of(
            "timestamp", Instant.now(),
            "path", exchange.getRequest().getPath().value(),
            "status", status.value(),
            "error", status.getReasonPhrase(),
            "message", message
        );

        return writeResponse(response, errorResponse);
    }

    /**
     * 写入错误响应（带错误码）.
     */
    public static Mono<Void> writeErrorResponse(
        ServerWebExchange exchange,
        GatewayException ex
    ) {
        var response = exchange.getResponse();
        response.setStatusCode(ex.getHttpStatus());
        response.getHeaders().setContentType(MediaType.APPLICATION_JSON);

        var errorResponse = Map.of(
            "timestamp", Instant.now(),
            "path", exchange.getRequest().getPath().value(),
            "status", ex.getHttpStatus().value(),
            "error", ex.getHttpStatus().getReasonPhrase(),
            "errorCode", ex.getErrorCode().getCode(),
            "message", ex.getMessage()
        );

        return writeResponse(response, errorResponse);
    }

    /**
     * 写入错误响应（基于ErrorCode）.
     */
    public static Mono<Void> writeErrorResponse(
        ServerWebExchange exchange,
        ErrorCode errorCode
    ) {
        return writeErrorResponse(exchange, errorCode.getHttpStatus(), errorCode.getMessage());
    }

    /**
     * 写入成功响应.
     */
    public static Mono<ServerResponse> writeSuccessResponse(Object data) {
        return ServerResponse
            .ok()
            .contentType(MediaType.APPLICATION_JSON)
            .bodyValue(Map.of(
                "timestamp", Instant.now(),
                "success", true,
                "data", data
            ));
    }

    /**
     * 写入 JSON 响应.
     */
    public static Mono<Void> writeResponse(
        org.springframework.http.server.reactive.ServerHttpResponse response,
        Object body
    ) {
        try {
            var data = OBJECT_MAPPER.writeValueAsBytes(body);
            var buffer = response.bufferFactory().wrap(data);
            return response.writeWith(Mono.just(buffer));
        } catch (JsonProcessingException e) {
            return Mono.error(e);
        }
    }

    /**
     * 创建未授权响应.
     */
    public static Mono<Void> unauthorized(
        ServerWebExchange exchange,
        String message
    ) {
        return writeErrorResponse(exchange, HttpStatus.UNAUTHORIZED, message);
    }

    /**
     * 创建服务不可用响应.
     */
    public static Mono<Void> serviceUnavailable(
        ServerWebExchange exchange,
        String serviceName
    ) {
        return writeErrorResponse(exchange, HttpStatus.SERVICE_UNAVAILABLE,
            serviceName + " service is temporarily unavailable");
    }
}
