package com.nexora.auth.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.cloud.context.config.annotation.RefreshScope;
import org.springframework.stereotype.Component;

import java.time.Duration;
import java.util.List;

/**
 * Authentication configuration properties.
 *
 * <p>This class holds all authentication-related configuration that can be
 * dynamically refreshed from Nacos without requiring application restart.
 *
 * @author sujie
 */
@Data
@RefreshScope
@Component
@ConfigurationProperties(prefix = "auth")
public class AuthProperties {

    /**
     * Local authentication configuration.
     */
    private Local local = new Local();

    /**
     * JWT configuration.
     */
    private Jwt jwt = new Jwt();

    /**
     * Session configuration.
     */
    private Session session = new Session();

    /**
     * OAuth2 configuration.
     */
    private OAuth2 oauth2 = new OAuth2();

    /**
     * CORS configuration.
     */
    private Cors cors = new Cors();

    @Data
    public static class Local {
        /**
         * Whether local authentication is enabled.
         */
        private boolean enabled = true;

        /**
         * Password policy configuration.
         */
        private PasswordPolicy passwordPolicy = new PasswordPolicy();

        /**
         * Brute force protection configuration.
         */
        private BruteForceProtection bruteForceProtection = new BruteForceProtection();
    }

    @Data
    public static class PasswordPolicy {
        private int minLength = 8;
        private boolean requireUppercase = true;
        private boolean requireLowercase = true;
        private boolean requireDigit = true;
        private boolean requireSpecialChar = true;
    }

    @Data
    public static class BruteForceProtection {
        private boolean enabled = true;
        private int maxAttempts = 5;
        private Duration lockoutDuration = Duration.ofMinutes(15);
    }

    @Data
    public static class Jwt {
        /**
         * JWT secret key (at least 256 bits for security).
         */
        private String secret;

        /**
         * Access token expiry duration.
         */
        private Duration accessTokenExpiry = Duration.ofMinutes(15);

        /**
         * Refresh token expiry duration.
         */
        private Duration refreshTokenExpiry = Duration.ofDays(7);

        /**
         * JWT issuer claim.
         */
        private String issuer = "authsrv";
    }

    @Data
    public static class Session {
        private int maxConcurrent = 5;
        private String store = "redis";
    }

    @Data
    public static class OAuth2 {
        private boolean enabled = true;
        private List<String> allowedProviders = List.of("google", "github", "enterprise");
    }

    @Data
    public static class Cors {
        private List<String> allowedOrigins = List.of("http://localhost:3000", "http://localhost:8080");
        private List<String> allowedMethods = List.of("GET", "POST", "PUT", "DELETE", "OPTIONS", "PATCH");
        private boolean allowCredentials = true;
    }
}
