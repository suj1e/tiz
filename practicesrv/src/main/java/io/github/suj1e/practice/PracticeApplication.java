package io.github.suj1e.practice;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * 练习服务启动类.
 */
@SpringBootApplication(scanBasePackages = "io.github.suj1e")
public class PracticeApplication {

    public static void main(String[] args) {
        SpringApplication.run(PracticeApplication.class, args);
    }
}
