package com.nexora.gateway.unit.filter;

import com.nexora.gateway.filter.RateLimitFilter;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.cloud.gateway.filter.GatewayFilterChain;
import org.springframework.mock.http.server.reactive.MockServerHttpRequest;
import org.springframework.mock.web.server.MockServerWebExchange;
import reactor.core.publisher.Mono;
import reactor.test.StepVerifier;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

class RateLimitFilterTest {

    private RateLimitFilter rateLimitFilter;

    @BeforeEach
    void setUp() {
        rateLimitFilter = new RateLimitFilter();
    }

    @Test
    void 应该记录请求信息() {
        var exchange = MockServerWebExchange.from(
            MockServerHttpRequest.get("/api/v1/test").build()
        );

        var chain = mock(GatewayFilterChain.class);
        when(chain.filter(any())).thenReturn(Mono.empty());

        var config = new RateLimitFilter.Config();
        config.setReplenishRate(10);
        config.setBurstCapacity(20);

        StepVerifier.create(rateLimitFilter.apply(config).filter(exchange, chain))
            .verifyComplete();

        verify(chain).filter(any());
    }
}
