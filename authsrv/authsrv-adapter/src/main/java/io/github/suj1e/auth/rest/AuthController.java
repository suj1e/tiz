package io.github.suj1e.auth.rest;

import io.github.suj1e.auth.api.dto.request.LoginRequest;
import io.github.suj1e.auth.api.dto.request.RegisterRequest;
import io.github.suj1e.auth.api.dto.response.TokenResponse;
import io.github.suj1e.auth.core.domain.TokenInfo;
import io.github.suj1e.auth.core.domainservice.AuthDomainService;
import io.github.suj1e.auth.core.domainservice.TokenDomainService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

/**
 * Authentication REST controller.
 *
 * @author sujie
 */
@Slf4j
@RestController
@RequestMapping("/v1/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthDomainService authDomainService;
    private final TokenDomainService tokenDomainService;

    @PostMapping("/register")
    public ResponseEntity<Void> register(@Valid @RequestBody RegisterRequest request) {
        authDomainService.register(request.username(), request.email(), request.password());
        return ResponseEntity.ok().build();
    }

    @PostMapping("/login")
    public ResponseEntity<TokenResponse> login(@Valid @RequestBody LoginRequest request) {
        TokenInfo tokenInfo = authDomainService.login(request.username(), request.password());
        return ResponseEntity.ok(new TokenResponse(
                tokenInfo.accessToken(),
                tokenInfo.refreshToken(),
                tokenInfo.expiresIn()
        ));
    }

    @PostMapping("/logout")
    public ResponseEntity<Void> logout(Authentication authentication) {
        String username = authentication.getName();
        authDomainService.logout(username);

        // Add current access token to blacklist
        // Note: In production, you would get the token from the request
        log.info("User logged out: {}", username);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/refresh")
    public ResponseEntity<TokenResponse> refresh(@RequestParam String refreshToken) {
        String accessToken = tokenDomainService.refreshAccessToken(refreshToken);
        if (accessToken == null) {
            return ResponseEntity.status(401).build();
        }

        return ResponseEntity.ok(new TokenResponse(
                accessToken,
                refreshToken,
                900L
        ));
    }
}
