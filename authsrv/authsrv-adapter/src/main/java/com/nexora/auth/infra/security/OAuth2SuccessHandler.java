package com.nexora.auth.adapter.infra.security;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import com.nexora.auth.adapter.service.AuditService;
import com.nexora.auth.adapter.service.TokenService;
import com.nexora.auth.adapter.service.UserService;
import com.nexora.auth.core.domain.Role;
import com.nexora.auth.core.domain.User;
import com.nexora.auth.adapter.infra.repository.RoleRepository;
import com.nexora.auth.adapter.infra.repository.UserRepository;
import org.springframework.security.core.Authentication;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.security.web.authentication.AuthenticationSuccessHandler;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.util.Optional;

/**
 * OAuth2 authentication success handler.
 *
 * @author sujie
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class OAuth2SuccessHandler implements AuthenticationSuccessHandler {

    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final TokenService tokenService;
    private final UserService userService;
    private final AuditService auditService;

    @Override
    public void onAuthenticationSuccess(HttpServletRequest request,
                                        HttpServletResponse response,
                                        Authentication authentication) throws IOException, ServletException {
        OAuth2User oAuth2User = (OAuth2User) authentication.getPrincipal();

        String provider = extractProvider(authentication);
        String providerUserId = oAuth2User.getName();

        log.info("OAuth2 login success via provider: {}, providerUserId: {}", provider, providerUserId);

        // Find or create user
        User user = userRepository.findByAuthProviderAndProviderUserId(provider, providerUserId)
            .orElseGet(() -> createOAuth2User(oAuth2User, provider));

        // Update last login
        user.updateLastLoginAt();
        userRepository.save(user);

        // Log success
        auditService.logOAuth2Login(user, provider);

        // Generate tokens
        String accessToken = tokenService.generateAccessToken(user);
        String refreshToken = tokenService.generateRefreshToken(user).getToken();

        // Redirect to frontend with tokens
        String redirectUrl = buildRedirectUrl(accessToken, refreshToken);
        response.sendRedirect(redirectUrl);
    }

    private String extractProvider(Authentication authentication) {
        // Extract provider from the authorities or registration ID
        return authentication.getAuthorities().stream()
            .filter(a -> a.getAuthority().startsWith("OAUTH2_"))
            .map(a -> a.getAuthority().substring(7))
            .findFirst()
            .orElse("unknown");
    }

    private User createOAuth2User(OAuth2User oAuth2User, String provider) {
        String email = oAuth2User.getAttribute("email");
        String name = oAuth2User.getAttribute("name");
        String picture = oAuth2User.getAttribute("picture");

        String username = email != null ? email.substring(0, email.indexOf("@")) : "oauth2_" + oAuth2User.getName();

        User user = User.createOAuth2User(
            provider,
            oAuth2User.getName(),
            username,
            email,
            name,
            picture
        );

        // Assign default role
        Role userRole = roleRepository.findByNameIgnoreCase("ROLE_USER")
            .orElseGet(() -> roleRepository.save(Role.createUserRole()));
        user.addRole(userRole);

        return userRepository.save(user);
    }

    private String buildRedirectUrl(String accessToken, String refreshToken) {
        // In production, this should redirect to frontend with tokens
        // For now, return a simple response
        return "/v1/oauth2/success?token=" + accessToken;
    }
}
