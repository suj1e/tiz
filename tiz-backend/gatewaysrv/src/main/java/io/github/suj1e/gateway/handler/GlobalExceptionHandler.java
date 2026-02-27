package io.github.suj1e.gateway.handler;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.core.annotation.Order;
import org.springframework.core.io.buffer.DataBuffer;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.server.reactive.ServerHttpResponse;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.web.server.ServerWebExchange;
import org.springframework.web.server.WebExceptionHandler;
import reactor.core.publisher.Mono;

import java.nio.charset.StandardCharsets;

/**
 * Global exception handler for Gateway.
 */
@Slf4j
@Component
@Order(-1)
public class GlobalExceptionHandler implements WebExceptionHandler {

    private static final ObjectMapper OBJECT_MAPPER = new ObjectMapper();

    @Override
    public Mono<Void> handle(ServerWebExchange exchange, Throwable ex) {
        ServerHttpResponse response = exchange.getResponse();

        if (response.isCommitted()) {
            return Mono.error(ex);
        }

        log.error("Gateway error: {}", ex.getMessage(), ex);

        HttpStatus status;
        String type;
        String code;
        String message;

        if (ex instanceof ResponseStatusException rse) {
            status = HttpStatus.valueOf(rse.getStatusCode().value());
            type = "api_error";
            code = "gateway_error";
            message = rse.getReason() != null ? rse.getReason() : status.getReasonPhrase();
        } else {
            status = HttpStatus.INTERNAL_SERVER_ERROR;
            type = "api_error";
            code = "internal_error";
            message = "Internal server error";
        }

        response.setStatusCode(status);
        response.getHeaders().setContentType(MediaType.APPLICATION_JSON);

        GatewayErrorResponse errorResponse = new GatewayErrorResponse(type, code, message);
        String body = errorResponse.toJson();
        DataBuffer buffer = response.bufferFactory().wrap(body.getBytes(StandardCharsets.UTF_8));

        return response.writeWith(Mono.just(buffer));
    }
}
