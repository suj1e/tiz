package com.nexora.auth.adapter.infra.security;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import com.nexora.auth.adapter.service.AuditService;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.authentication.AuthenticationFailureHandler;
import org.springframework.stereotype.Component;

import java.io.IOException;

/**
 * OAuth2 authentication failure handler.
 *
 * @author sujie
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class OAuth2FailureHandler implements AuthenticationFailureHandler {

    private final AuditService auditService;

    @Override
    public void onAuthenticationFailure(HttpServletRequest request,
                                        HttpServletResponse response,
                                        AuthenticationException exception) throws IOException, ServletException {
        String provider = extractProvider(request);
        String errorMessage = exception.getMessage();

        log.warn("OAuth2 authentication failed via provider: {}, error: {}", provider, errorMessage);

        auditService.logOAuth2Failure(provider, errorMessage);

        response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
        response.setContentType("application/json");
        response.getWriter().write("{\"error\":\"OAuth2 authentication failed\",\"message\":\"" + errorMessage + "\"}");
    }

    private String extractProvider(HttpServletRequest request) {
        String uri = request.getRequestURI();
        if (uri.contains("/oauth2/callback/")) {
            return uri.substring(uri.lastIndexOf("/") + 1);
        }
        return "unknown";
    }
}
