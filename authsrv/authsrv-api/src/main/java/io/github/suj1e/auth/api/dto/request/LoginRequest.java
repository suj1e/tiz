package io.github.suj1e.auth.api.dto.request;

import jakarta.validation.constraints.NotBlank;

/**
 * Login request.
 *
 * @author sujie
 */
public record LoginRequest(
        @NotBlank(message = "Username is required")
        String username,

        @NotBlank(message = "Password is required")
        String password
) {}
