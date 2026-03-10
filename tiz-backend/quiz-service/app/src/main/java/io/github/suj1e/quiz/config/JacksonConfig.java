package io.github.suj1e.quiz.config;

import org.springframework.context.annotation.Configuration;

/**
 * Jackson 配置.
 * Spring Boot 4.x 自动配置 ObjectMapper，无需手动定义 Bean。
 */
@Configuration
public class JacksonConfig {
    // Spring Boot 自动配置 ObjectMapper，支持 Java 8 时间类型
}
