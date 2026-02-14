package io.github.suj1e.auth.core.domainservice;

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
     * Authenticate user and return access token.
     */
    String login(String username, String password);

    /**
     * Logout user.
     */
    void logout(String username);
}
