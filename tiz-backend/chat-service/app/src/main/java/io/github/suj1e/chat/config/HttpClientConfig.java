package io.github.suj1e.chat.config;

import io.github.suj1e.chat.client.UserClient;
import io.github.suj1e.content.api.client.ContentClient;
import io.github.suj1e.llm.api.client.LlmClient;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.cloud.client.loadbalancer.LoadBalanced;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.reactive.function.client.WebClient;
import org.springframework.web.reactive.function.client.support.WebClientAdapter;
import org.springframework.web.service.invoker.HttpServiceProxyFactory;

/**
 * HTTP Client 配置.
 */
@Configuration
public class HttpClientConfig {

    @Value("${llm.service.url:http://llm-service:8106}")
    private String llmServiceUrl;

    @Value("${content.service.url:http://content-service:8103}")
    private String contentServiceUrl;

    @Value("${user.service.url:http://user-service:8107}")
    private String userServiceUrl;

    /**
     * LoadBalanced WebClient.Builder for service discovery.
     */
    @Bean
    @LoadBalanced
    public WebClient.Builder loadBalancedWebClientBuilder() {
        return WebClient.builder();
    }

    /**
     * LLM 服务客户端 (不使用服务发现，直接 Docker DNS).
     */
    @Bean
    public LlmClient llmClient() {
        WebClient webClient = WebClient.builder()
            .baseUrl(llmServiceUrl)
            .build();

        HttpServiceProxyFactory factory = HttpServiceProxyFactory
            .builderFor(WebClientAdapter.create(webClient))
            .build();

        return factory.createClient(LlmClient.class);
    }

    /**
     * Content 服务客户端 (使用服务发现).
     */
    @Bean
    public ContentClient contentClient(WebClient.Builder loadBalancedWebClientBuilder) {
        WebClient webClient = loadBalancedWebClientBuilder
            .baseUrl(contentServiceUrl)
            .build();

        HttpServiceProxyFactory factory = HttpServiceProxyFactory
            .builderFor(WebClientAdapter.create(webClient))
            .build();

        return factory.createClient(ContentClient.class);
    }

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
