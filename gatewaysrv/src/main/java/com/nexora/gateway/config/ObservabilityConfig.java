package com.nexora.gateway.config;

import io.micrometer.core.instrument.config.MeterRegistryConfig;
import org.springframework.boot.actuate.autoconfigure.metrics.MeterRegistryCustomizer;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * Observability configuration.
 *
 * @author sujie
 */
@Configuration
public class ObservabilityConfig {

    @Bean
    public MeterRegistryCustomizer<?> metricsCommonTags() {
        return registry -> {
            var env = System.getenv().getOrDefault("SPRING_PROFILES_ACTIVE", "dev");
            registry.config()
                    .commonTags(
                            "application", "gatewaysrv",
                            "environment", env,
                            "region", System.getenv().getOrDefault("REGION", "default")
                    );
        };
    }
}
