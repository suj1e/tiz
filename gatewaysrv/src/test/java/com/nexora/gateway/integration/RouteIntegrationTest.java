package com.nexora.gateway.integration;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.context.SpringBootTest.WebEnvironment;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.reactive.server.WebTestClient;

@SpringBootTest(webEnvironment = WebEnvironment.RANDOM_PORT)
@ActiveProfiles("test")
class RouteIntegrationTest {

    @Autowired
    private WebTestClient client;

    @Test
    void 应该路由到健康检查端点() {
        client.get()
            .uri("/actuator/health")
            .exchange()
            .expectStatus().isOk();
    }

    // 注释：Actuator 端点直接由 Spring Boot 处理，不经过 Gateway 路由，所以全局过滤器不应用
    // 这些测试需要配置一个实际经过 Gateway 的测试路由
}
