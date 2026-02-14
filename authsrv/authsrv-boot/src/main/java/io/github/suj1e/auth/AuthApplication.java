package io.github.suj1e.auth;

import io.github.suj1e.auth.config.AuthProperties;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;

/**
 * Authentication service application entry point.
 *
 * @author sujie
 */
@SpringBootApplication(scanBasePackages = "io.github.suj1e.auth")
@EnableJpaAuditing
@EnableConfigurationProperties(AuthProperties.class)
public class AuthApplication {

    public static void main(String[] args) {
        SpringApplication.run(AuthApplication.class, args);
    }
}
