package io.github.suj1e.chat.config;

import io.github.suj1e.common.client.ContentClient;
import io.github.suj1e.common.client.LlmClient;
import org.springframework.beans.factory.annotation.Value;
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

    @Value("${llm.service.url:http://localhost:8106}")
    private String llmServiceUrl;

    @Value("${content.service.url:http://localhost:8103}")
    private String contentServiceUrl;

    /**
     * LLM 服务客户端.
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
     * Content 服务客户端.
     */
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
