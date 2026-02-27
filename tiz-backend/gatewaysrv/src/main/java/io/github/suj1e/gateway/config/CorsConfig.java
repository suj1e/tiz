package io.github.suj1e.gateway.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.reactive.CorsWebFilter;
import org.springframework.web.cors.reactive.UrlBasedCorsConfigurationSource;

import java.util.Arrays;
import java.util.List;

/**
 * CORS Configuration for Gateway.
 */
@Data
@Configuration
@ConfigurationProperties(prefix = "cors")
public class CorsConfig {

    private String allowedOrigins;
    private String allowedMethods;
    private String allowedHeaders;
    private boolean allowCredentials = true;
    private long maxAge = 3600;

    @Bean
    public CorsWebFilter corsWebFilter() {
        CorsConfiguration corsConfig = new CorsConfiguration();

        // Allowed origins
        List<String> origins = Arrays.asList(allowedOrigins.split(","));
        corsConfig.setAllowedOrigins(origins);

        // Allowed methods
        List<String> methods = Arrays.asList(allowedMethods.split(","));
        corsConfig.setAllowedMethods(methods);

        // Allowed headers
        List<String> headers = Arrays.asList(allowedHeaders.split(","));
        corsConfig.setAllowedHeaders(headers);

        // Allow credentials
        corsConfig.setAllowCredentials(allowCredentials);

        // Max age
        corsConfig.setMaxAge(maxAge);

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", corsConfig);

        return new CorsWebFilter(source);
    }
}
