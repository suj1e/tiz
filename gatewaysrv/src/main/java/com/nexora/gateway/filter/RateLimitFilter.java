package com.nexora.gateway.filter;

import lombok.extern.slf4j.Slf4j;
import org.springframework.cloud.gateway.filter.GatewayFilter;
import org.springframework.cloud.gateway.filter.factory.AbstractGatewayFilterFactory;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import reactor.core.publisher.Mono;

@Slf4j
@Component
public class RateLimitFilter extends AbstractGatewayFilterFactory<RateLimitFilter.Config> {

    public RateLimitFilter() {
        super(Config.class);
    }

    @Override
    public GatewayFilter apply(Config config) {
        return (exchange, chain) -> {
            var request = exchange.getRequest();
            var path = request.getPath().value();
            var ip = request.getRemoteAddress() != null ? request.getRemoteAddress().getAddress().getHostAddress() : "unknown";

            log.debug("限流过滤器: ip={} path={}", ip, path);

            // 限流逻辑由 Spring Cloud Gateway 的 RequestRateLimiter 处理
            // 这里只是示例，实际限流在 YAML 中配置
            return chain.filter(exchange)
                .doOnError(e -> {
                    if (e instanceof org.springframework.cloud.gateway.support.NotFoundException
                        || e.getMessage() != null && e.getMessage().contains("429")) {
                        log.warn("限流触发: ip={} path={}", ip, path);
                    }
                });
        };
    }

    public static class Config {
        private int replenishRate = 10;
        private int burstCapacity = 20;

        public int getReplenishRate() {
            return replenishRate;
        }

        public void setReplenishRate(int replenishRate) {
            this.replenishRate = replenishRate;
        }

        public int getBurstCapacity() {
            return burstCapacity;
        }

        public void setBurstCapacity(int burstCapacity) {
            this.burstCapacity = burstCapacity;
        }
    }
}
