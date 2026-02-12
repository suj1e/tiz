package com.nexora.gateway.handler;

import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.reactive.function.server.RouterFunction;
import org.springframework.web.reactive.function.server.ServerResponse;

import static org.springframework.web.reactive.function.server.RouterFunctions.route;

@Configuration
@RequiredArgsConstructor
public class RouterConfig {

    private final GatewayFallbackHandler fallbackHandler;

    @Bean
    public RouterFunction<ServerResponse> fallbackRoutes() {
        return route()
            .path("/fallback", builder -> builder
                .GET("/mix/**", fallbackHandler::mixFallback)
                .GET("/recommend/**", fallbackHandler::recommendFallback)
            )
            .build();
    }
}
