package io.github.suj1e.quiz.config;

import io.github.suj1e.content.api.client.ContentClient;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.cloud.client.loadbalancer.LoadBalanced;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.reactive.function.client.WebClient;
import org.springframework.web.reactive.function.client.support.WebClientAdapter;
import org.springframework.web.service.invoker.HttpServiceProxyFactory;

/**
 * Content HTTP Client 配置.
 */
@Configuration
public class ContentClientConfig {

    @Value("${content.service.url:http://contentsrv:8103}")
    private String contentServiceUrl;

    /**
     * LoadBalanced WebClient.Builder for service discovery.
     */
    @Bean
    @LoadBalanced
    public WebClient.Builder loadBalancedWebClientBuilder() {
        return WebClient.builder();
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
}
