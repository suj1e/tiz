package io.github.suj1e.content.config;

import io.github.suj1e.user.api.client.UserClient;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.reactive.function.client.WebClient;
import org.springframework.web.reactive.function.client.support.WebClientAdapter;
import org.springframework.web.service.invoker.HttpServiceProxyFactory;

/**
 * User 服务 HTTP 客户端配置.
 */
@Configuration
public class UserClientConfig {

    @Value("${user.service.url}")
    private String userServiceUrl;

    @Bean
    public UserClient userClient() {
        WebClient webClient = WebClient.builder()
            .baseUrl(userServiceUrl)
            .build();

        HttpServiceProxyFactory factory = HttpServiceProxyFactory
            .builderFor(WebClientAdapter.create(webClient))
            .build();

        return factory.createClient(UserClient.class);
    }
}
