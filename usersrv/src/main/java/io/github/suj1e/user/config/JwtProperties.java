package io.github.suj1e.user.config;

import lombok.Getter;
import lombok.Setter;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

/**
 * JWT 配置属性.
 */
@Getter
@Setter
@Configuration
@ConfigurationProperties(prefix = "jwt")
public class JwtProperties {

    /**
     * JWT 签名密钥.
     */
    private String secret;

    /**
     * 访问令牌过期时间（秒）.
     */
    private long accessTokenExpiration;

    /**
     * 刷新令牌过期时间（秒）.
     */
    private long refreshTokenExpiration;
}
