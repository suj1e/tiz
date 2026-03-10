package io.github.suj1e.gateway.config;

import org.springframework.cloud.gateway.route.RouteLocator;
import org.springframework.cloud.gateway.route.builder.RouteLocatorBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * Gateway 路由配置.
 * 以编程方式定义路由，确保路由被正确加载.
 */
@Configuration
public class GatewayRouteConfig {

    @Bean
    public RouteLocator customRouteLocator(RouteLocatorBuilder builder) {
        return builder.routes()
            // Auth Service
            .route("auth-service", r -> r
                .path("/api/auth/v1/**")
                .filters(f -> f.stripPrefix(0))
                .uri("lb://auth-service"))

            // User Service
            .route("user-service", r -> r
                .path("/api/user/v1/**")
                .uri("lb://user-service"))

            // Chat Service
            .route("chat-service", r -> r
                .path("/api/chat/v1/**")
                .uri("lb://chat-service"))

            // Content Service
            .route("content-service", r -> r
                .path("/api/content/v1/**")
                .uri("lb://content-service"))

            // Practice Service
            .route("practice-service", r -> r
                .path("/api/practice/v1/**")
                .uri("lb://practice-service"))

            // Quiz Service
            .route("quiz-service", r -> r
                .path("/api/quiz/v1/**")
                .uri("lb://quiz-service"))

            .build();
    }
}
