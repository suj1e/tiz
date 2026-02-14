package io.github.suj1e.auth.adapter.config;

import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Configuration;

/**
 * OAuth2 configuration placeholder.
 *
 * <p>OAuth2 is auto-configured by Spring Boot based on
 * spring.security.oauth2.client properties in application.yml.
 *
 * @author sujie
 */
@Configuration
@ConditionalOnProperty(name = "auth.oauth2.enabled", havingValue = "true", matchIfMissing = true)
public class OAuth2Config {
    // OAuth2 client auto-configuration is enabled by Spring Boot
    // Additional customizations can be added here if needed
}
