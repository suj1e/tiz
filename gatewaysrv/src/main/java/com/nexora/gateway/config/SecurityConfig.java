package com.nexora.gateway.config;

import com.nexora.gateway.constants.GatewayConstants;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.reactive.EnableWebFluxSecurity;
import org.springframework.security.config.web.server.ServerHttpSecurity;
import org.springframework.security.web.server.SecurityWebFilterChain;
import org.springframework.security.web.server.header.XFrameOptionsServerHttpHeadersWriter;

/**
 * Security configuration.
 *
 * <p>Configures Spring Security for the reactive gateway with:
 * <ul>
 *   <li>Security headers (CSP, X-Frame-Options, X-XSS-Protection)</li>
 *   <li>CSRF disabled for stateless API</li>
 *   <li>Public path whitelisting</li>
 * </ul>
 *
 * @author sujie
 */
@Configuration
@EnableWebFluxSecurity
public class SecurityConfig {

    @Bean
    public SecurityWebFilterChain securityWebFilterChain(ServerHttpSecurity http) {
        http
            .csrf(ServerHttpSecurity.CsrfSpec::disable)
            .headers(headers -> headers
                .frameOptions(frame -> frame.mode(XFrameOptionsServerHttpHeadersWriter.Mode.DENY))
                .contentSecurityPolicy(csp -> csp.policyDirectives(
                    "default-src 'self'; " +
                    "script-src 'self' 'unsafe-inline'; " +
                    "style-src 'self' 'unsafe-inline'; " +
                    "img-src 'self' data: https:; " +
                    "font-src 'self' data:; " +
                    "connect-src 'self' https:; " +
                    "frame-ancestors 'none';"
                ))
                .xssProtection(xss -> {})
            )
            .cors(ServerHttpSecurity.CorsSpec::disable)
            .authorizeExchange(exchanges -> exchanges
                .pathMatchers("/actuator/health/**", "/actuator/info/**", "/actuator/prometheus").permitAll()
                .pathMatchers("/api/v1/auth/**").permitAll()
                .pathMatchers(GatewayConstants.PUBLIC_PATHS.toArray(new String[0])).permitAll()
                .anyExchange().authenticated()
            );
        return http.build();
    }
}
