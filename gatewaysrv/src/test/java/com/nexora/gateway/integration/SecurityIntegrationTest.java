package com.nexora.gateway.integration;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.context.SpringBootTest.WebEnvironment;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.reactive.server.WebTestClient;

@SpringBootTest(webEnvironment = WebEnvironment.RANDOM_PORT)
@ActiveProfiles("test")
class SecurityIntegrationTest {

    @Autowired
    private WebTestClient client;

    @Test
    void 应该允许访问公开端点() {
        client.get()
            .uri("/actuator/health")
            .exchange()
            .expectStatus().isOk();
    }

    // 注释：以下测试需要配置完整的路由和后端服务
    // 在测试环境中，我们只验证基本的 Spring 上下文加载
}
