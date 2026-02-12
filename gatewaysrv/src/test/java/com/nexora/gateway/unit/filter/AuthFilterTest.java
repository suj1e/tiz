package com.nexora.gateway.unit.filter;

import com.nexora.gateway.filter.AuthFilter;
import com.nexora.security.jwt.ReactiveJwtTokenProvider;
import io.jsonwebtoken.Claims;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.cloud.gateway.filter.GatewayFilterChain;
import org.springframework.http.HttpStatusCode;
import org.springframework.mock.http.server.reactive.MockServerHttpRequest;
import org.springframework.mock.web.server.MockServerWebExchange;
import reactor.core.publisher.Mono;
import reactor.test.StepVerifier;

import java.util.List;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class AuthFilterTest {

    @Mock
    private ReactiveJwtTokenProvider jwtProvider;

    private AuthFilter authFilter;

    @BeforeEach
    void setUp() {
        authFilter = new AuthFilter(jwtProvider);
    }

    @Test
    void 应该允许公开路径() {
        var exchange = MockServerWebExchange.from(
            MockServerHttpRequest.get("/api/v1/auth/login").build()
        );

        var chain = mock(GatewayFilterChain.class);
        when(chain.filter(any())).thenReturn(Mono.empty());

        StepVerifier.create(authFilter.apply(new AuthFilter.Config()).filter(exchange, chain))
            .verifyComplete();

        verify(jwtProvider, never()).validateToken(any());
    }

    @Test
    void 应该拒绝缺少令牌的请求() {
        var exchange = MockServerWebExchange.from(
            MockServerHttpRequest.get("/api/v1/mix/data").build()
        );

        var chain = mock(GatewayFilterChain.class);

        StepVerifier.create(authFilter.apply(new AuthFilter.Config()).filter(exchange, chain))
            .expectComplete()
            .verify();

        var response = exchange.getResponse();
        assert response.getStatusCode() == HttpStatusCode.valueOf(401);
    }

    @Test
    void 应该验证有效令牌() {
        var exchange = MockServerWebExchange.from(
            MockServerHttpRequest.get("/api/v1/mix/data")
                .header("Authorization", "Bearer valid-token")
                .build()
        );

        var chain = mock(GatewayFilterChain.class);
        when(chain.filter(any())).thenReturn(Mono.empty());

        var claims = mock(Claims.class);
        when(claims.getSubject()).thenReturn("user123");
        when(claims.get("roles", List.class)).thenReturn(List.of("USER"));
        when(claims.get("username", String.class)).thenReturn("testuser");
        when(jwtProvider.validateToken("valid-token")).thenReturn(Mono.just(claims));

        StepVerifier.create(authFilter.apply(new AuthFilter.Config()).filter(exchange, chain))
            .verifyComplete();

        verify(jwtProvider).validateToken("valid-token");
    }
}
