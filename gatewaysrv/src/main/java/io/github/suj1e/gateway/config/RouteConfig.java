package io.github.suj1e.gateway.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

import java.util.List;

/**
 * Gateway configuration properties.
 */
@Data
@Configuration
@ConfigurationProperties(prefix = "gateway")
public class RouteConfig {

    /**
     * Whitelist paths that don't require authentication.
     */
    private List<String> whitelist = List.of(
        "/api/auth/v1/login",
        "/api/auth/v1/register",
        "/api/auth/v1/refresh",
        "/actuator/**"
    );
}
