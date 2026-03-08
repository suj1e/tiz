package io.github.suj1e.chat.security;

import org.springframework.boot.context.properties.ConfigurationProperties;

/**
 * JWT 配置属性.
 */
@ConfigurationProperties(prefix = "jwt")
public record JwtProperties(
    String secret,
    long accessTokenExpiration,
    long refreshTokenExpiration
) {}
