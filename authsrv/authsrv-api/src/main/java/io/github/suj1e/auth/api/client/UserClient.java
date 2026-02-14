package io.github.suj1e.auth.api.client;

import io.github.suj1e.auth.api.dto.response.MessageResponse;
import io.github.suj1e.auth.api.dto.response.UserResponse;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.service.annotation.DeleteExchange;
import org.springframework.web.service.annotation.GetExchange;
import org.springframework.web.service.annotation.HttpExchange;
import org.springframework.web.service.annotation.PostExchange;
import org.springframework.web.service.annotation.PutExchange;

import java.util.List;

/**
 * HTTP Client interface for User service.
 * Uses @HttpExchange for type-safe service-to-service communication.
 *
 * <p>Usage in other microservices:
 * <pre>
 * &#64;Bean
 * public UserClient userClient() {
 *     return HttpServiceProxyFactory.builder()
 *         .clientAdapter RestClient.create())
 *         .build()
 *         .createClient(UserClient.class, "http://authsrv");
 * }
 * </pre>
 *
 * @author sujie
 */
@HttpExchange(url = "/v1/users", accept = "application/json", contentType = "application/json")
public interface UserClient {

    /**
     * Get user by ID.
     */
    @GetExchange("/{id}")
    UserResponse getById(@PathVariable("id") Long id);

    /**
     * Get user by username.
     */
    @GetExchange("/username/{username}")
    UserResponse getByUsername(@PathVariable("username") String username);

    /**
     * Get multiple users by IDs.
     */
    @GetExchange("/batch")
    List<UserResponse> getByIds(@RequestParam("ids") List<Long> ids);

    /**
     * Check if user exists by ID.
     */
    @GetExchange("/{id}/exists")
    Boolean existsById(@PathVariable("id") Long id);

    /**
     * Enable/disable user account (admin operation).
     */
    @PutExchange("/{id}/status")
    MessageResponse setEnabled(
        @PathVariable("id") Long id,
        @RequestParam("enabled") Boolean enabled
    );

    /**
     * Lock user account (admin operation).
     */
    @PostExchange("/{id}/lock")
    MessageResponse lockAccount(
        @PathVariable("id") Long id,
        @RequestParam(value = "durationMinutes", defaultValue = "15") int durationMinutes
    );

    /**
     * Unlock user account (admin operation).
     */
    @PostExchange("/{id}/unlock")
    MessageResponse unlockAccount(@PathVariable("id") Long id);

    /**
     * Assign role to user (admin operation).
     */
    @PostExchange("/{id}/roles")
    MessageResponse assignRole(
        @PathVariable("id") Long id,
        @RequestParam("roleName") String roleName
    );

    /**
     * Revoke role from user (admin operation).
     */
    @DeleteExchange("/{id}/roles")
    MessageResponse revokeRole(
        @PathVariable("id") Long id,
        @RequestParam("roleName") String roleName
    );
}
