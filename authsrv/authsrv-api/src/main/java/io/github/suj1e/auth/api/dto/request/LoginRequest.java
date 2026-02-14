package io.github.suj1e.auth.api.dto.request;

import jakarta.validation.constraints.NotBlank;

/**
 * Login request DTO.
 *
 * @author sujie
 */
public record LoginRequest(
    @NotBlank(message = "Username cannot be blank")
    String username,

    @NotBlank(message = "Password cannot be blank")
    String password
) {
}
