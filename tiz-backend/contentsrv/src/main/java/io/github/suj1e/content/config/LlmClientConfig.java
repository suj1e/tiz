package io.github.suj1e.content.config;

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
public class LlmClientConfig {

    @Value("${llm.service.url}")
    private String llmServiceUrl;

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
}
