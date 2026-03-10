package io.github.suj1e.practice.config;

import io.github.suj1e.user.api.client.UserClient;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.cloud.client.loadbalancer.LoadBalanced;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.reactive.function.client.WebClient;
import org.springframework.web.reactive.function.client.support.WebClientAdapter;
import org.springframework.web.service.invoker.HttpServiceProxyFactory;

/**
 * User Client HTTP Exchange 配置.
 */
@Configuration
public class UserClientConfig {

    @Value("${user.service.url:http://user-service:8107}")
    private String userServiceUrl;

    /**
     * User 服务客户端 (使用服务发现).
     */
    @Bean
    public UserClient userClient(WebClient.Builder loadBalancedWebClientBuilder) {
        WebClient webClient = loadBalancedWebClientBuilder
            .baseUrl(userServiceUrl)
            .build();

        HttpServiceProxyFactory factory = HttpServiceProxyFactory
            .builderFor(WebClientAdapter.create(webClient))
            .build();

        return factory.createClient(UserClient.class);
    }
}
