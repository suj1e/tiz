package com.nexora.gateway.filter;

import lombok.extern.slf4j.Slf4j;
import org.springframework.cloud.gateway.filter.GatewayFilter;
import org.springframework.cloud.gateway.filter.factory.AbstractGatewayFilterFactory;
import org.springframework.stereotype.Component;
import reactor.core.publisher.Mono;

@Slf4j
@Component
public class CircuitBreakerFilter extends AbstractGatewayFilterFactory<CircuitBreakerFilter.Config> {

    public CircuitBreakerFilter() {
        super(Config.class);
    }

    @Override
    public GatewayFilter apply(Config config) {
        return (exchange, chain) -> {
            var path = exchange.getRequest().getPath().value();

            log.debug("熔断器过滤器: name={} path={}", config.getName(), path);

            // 熔断逻辑由 Spring Cloud Gateway 的 CircuitBreaker 处理
            // 这里只是示例，实际熔断在 YAML 中配置
            return chain.filter(exchange)
                .doOnError(e -> log.error("服务调用失败: path={} error={}", path, e.getMessage()));
        };
    }

    public static class Config {
        private String name;
        private String fallbackUri;

        public String getName() {
            return name;
        }

        public void setName(String name) {
            this.name = name;
        }

        public String getFallbackUri() {
            return fallbackUri;
        }

        public void setFallbackUri(String fallbackUri) {
            this.fallbackUri = fallbackUri;
        }
    }
}
