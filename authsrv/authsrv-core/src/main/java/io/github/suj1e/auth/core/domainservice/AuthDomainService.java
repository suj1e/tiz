package io.github.suj1e.auth.core.domainservice;

import io.github.suj1e.auth.core.domain.TokenInfo;

/**
 * Authentication domain service interface.
 *
 * @author sujie
 */
public interface AuthDomainService {

    /**
     * Register a new user.
     */
    void register(String username, String email, String password);

    /**
     * Authenticate user and return token response.
     */
    TokenInfo login(String username, String password);

    /**
     * Logout user.
     */
    void logout(String username);
}
