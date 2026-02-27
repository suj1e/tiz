package io.github.suj1e.chat;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * 对话服务启动类.
 */
@SpringBootApplication(scanBasePackages = "io.github.suj1e")
public class ChatApplication {

    public static void main(String[] args) {
        SpringApplication.run(ChatApplication.class, args);
    }
}
