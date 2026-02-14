package io.github.suj1e.auth.config;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import lombok.extern.slf4j.Slf4j;
import org.springframework.cache.CacheManager;
import org.springframework.cache.annotation.EnableCaching;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.redis.cache.RedisCacheConfiguration;
import org.springframework.data.redis.cache.RedisCacheManager;
import org.springframework.data.redis.connection.RedisConnectionFactory;
import org.springframework.data.redis.serializer.GenericJackson2JsonRedisSerializer;
import org.springframework.data.redis.serializer.RedisSerializationContext;
import org.springframework.data.redis.serializer.StringRedisSerializer;

import java.time.Duration;
import java.util.HashMap;
import java.util.Map;

/**
 * Redis cache configuration.
 *
 * <p>Optimized with:
 * - JSON serialization instead of XML (faster, more secure)
 * - Per-cache TTL configuration
 * - Cache key prefixing for multi-tenancy support
 * - Null value caching disabled to prevent cache pollution
 *
 * @author sujie
 */
@Slf4j
@Configuration
@EnableCaching
public class RedisConfig {

    /**
     * Default cache TTL - 30 minutes.
     */
    private static final Duration DEFAULT_TTL = Duration.ofMinutes(30);

    /**
     * User cache TTL - 10 minutes (users change frequently).
     */
    private static final Duration USER_CACHE_TTL = Duration.ofMinutes(10);

    /**
     * Role cache TTL - 1 hour (roles rarely change).
     */
    private static final Duration ROLE_CACHE_TTL = Duration.ofHours(1);

    /**
     * Token blacklist TTL - 1 hour (matches access token expiry).
     */
    private static final Duration TOKEN_BLACKLIST_TTL = Duration.ofHours(1);

    /**
     * Cache key prefix.
     */
    private static final String CACHE_KEY_PREFIX = "authsrv:";

    @Bean
    public CacheManager cacheManager(RedisConnectionFactory connectionFactory) {
        // Configure ObjectMapper for JSON serialization
        ObjectMapper objectMapper = new ObjectMapper();
        objectMapper.registerModules(new JavaTimeModule());

        // Create serializer configuration
        RedisSerializationContext.SerializationPair<Object> jsonSerializer =
            RedisSerializationContext.SerializationPair.fromSerializer(
                new GenericJackson2JsonRedisSerializer(objectMapper)
            );

        // Default cache configuration
        RedisCacheConfiguration defaultConfig = RedisCacheConfiguration.defaultCacheConfig()
            .entryTtl(DEFAULT_TTL)
            .disableCachingNullValues()
            .prefixCacheNameWith(CACHE_KEY_PREFIX)
            .serializeKeysWith(
                RedisSerializationContext.SerializationPair.fromSerializer(
                    new StringRedisSerializer()
                )
            )
            .serializeValuesWith(jsonSerializer);

        // Per-cache specific configurations
        Map<String, RedisCacheConfiguration> cacheConfigurations = new HashMap<>();

        // User cache - shorter TTL due to frequent changes
        cacheConfigurations.put(CacheConfig.CACHE_USER,
            defaultConfig.entryTtl(USER_CACHE_TTL));

        // Role cache - longer TTL as roles rarely change
        cacheConfigurations.put(CacheConfig.CACHE_ROLE,
            defaultConfig.entryTtl(ROLE_CACHE_TTL));

        // Token blacklist - matches access token expiry
        cacheConfigurations.put(CacheConfig.CACHE_TOKEN_BLACKLIST,
            defaultConfig.entryTtl(TOKEN_BLACKLIST_TTL));

        log.info("Configured RedisCacheManager with {} custom caches", cacheConfigurations.size());

        return RedisCacheManager.builder(connectionFactory)
            .cacheDefaults(defaultConfig)
            .withInitialCacheConfigurations(cacheConfigurations)
            .transactionAware()
            .build();
    }
}
