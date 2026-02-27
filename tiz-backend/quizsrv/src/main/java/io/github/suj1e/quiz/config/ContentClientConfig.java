package io.github.suj1e.quiz.config;

import io.github.suj1e.content.api.client.ContentClient;
import org.springframework.beans.factory.annotation.Value;
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

    @Value("${content.service.url}")
    private String contentServiceUrl;

    @Bean
    public ContentClient contentClient() {
        WebClient webClient = WebClient.builder()
            .baseUrl(contentServiceUrl)
            .build();

        HttpServiceProxyFactory factory = HttpServiceProxyFactory
            .builderFor(WebClientAdapter.create(webClient))
            .build();

        return factory.createClient(ContentClient.class);
    }
}
