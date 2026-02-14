package io.github.suj1e.auth.rest;

import io.github.suj1e.auth.api.dto.request.LoginRequest;
import io.github.suj1e.auth.api.dto.request.RegisterRequest;
import io.github.suj1e.auth.api.dto.response.TokenResponse;
import io.github.suj1e.auth.core.domainservice.AuthDomainService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

/**
 * Authentication REST controller.
 *
 * @author sujie
 */
@RestController
@RequestMapping("/v1/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthDomainService authDomainService;

    @PostMapping("/register")
    public void register(@Valid @RequestBody RegisterRequest request) {
        authDomainService.register(request.username(), request.email(), request.password());
    }

    @PostMapping("/login")
    public TokenResponse login(@Valid @RequestBody LoginRequest request) {
        String accessToken = authDomainService.login(request.username(), request.password());
        // TODO: Return full TokenResponse with refresh token
        return new TokenResponse(accessToken, null, 900L);
    }

    @PostMapping("/logout")
    public void logout(@RequestHeader("Authorization") String authorization) {
        // TODO: Extract token and logout
    }
}
