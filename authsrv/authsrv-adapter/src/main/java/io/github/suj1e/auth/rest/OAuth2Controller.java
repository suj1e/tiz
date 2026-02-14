package io.github.suj1e.auth.adapter.rest;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;

/**
 * OAuth2 controller for provider information.
 *
 * @author sujie
 */
@Slf4j
@RestController
@RequestMapping("/oauth2")
@RequiredArgsConstructor
public class OAuth2Controller {

    /**
     * Get available OAuth2 providers.
     */
    @GetMapping("/providers")
    public Map<String, Object> getProviders() {
        return Map.of(
            "providers", List.of(
                Map.of(
                    "name", "google",
                    "displayName", "Google",
                    "url", "/oauth2/authorization/google"
                ),
                Map.of(
                    "name", "github",
                    "displayName", "GitHub",
                    "url", "/oauth2/authorization/github"
                ),
                Map.of(
                    "name", "enterprise",
                    "displayName", "Enterprise SSO",
                    "url", "/oauth2/authorization/enterprise"
                )
            )
        );
    }
}
