package io.github.suj1e.content;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * 内容服务启动类.
 */
@SpringBootApplication(scanBasePackages = "io.github.suj1e")
public class ContentApplication {

    public static void main(String[] args) {
        SpringApplication.run(ContentApplication.class, args);
    }
}
