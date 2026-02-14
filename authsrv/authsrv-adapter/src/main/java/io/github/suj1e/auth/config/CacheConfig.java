package io.github.suj1e.auth.config;

/**
 * Cache configuration constants.
 *
 * <p>Defines cache names and TTL configurations for different cache types.
 *
 * @author sujie
 */
public class CacheConfig {

    /**
     * User cache - stores user data by ID, username, or email.
     * TTL: 10 minutes (configured in application.yml)
     */
    public static final String CACHE_USER = "user";

    /**
     * Role cache - stores role data.
     * TTL: 30 minutes (configured in application.yml)
     */
    public static final String CACHE_ROLE = "role";

    /**
     * Token blacklist cache - stores revoked JWT tokens.
     * TTL: 1 hour (configured in application.yml)
     */
    public static final String CACHE_TOKEN_BLACKLIST = "token-blacklist";

    private CacheConfig() {
        // Prevent instantiation
    }
}
