package com.nexora.auth.adapter.config;

import lombok.RequiredArgsConstructor;
import com.nexora.auth.adapter.infra.security.CustomUserDetailsService;
import com.nexora.auth.infra.security.JwtAuthenticationFilter;
import com.nexora.auth.adapter.infra.security.OAuth2FailureHandler;
import com.nexora.auth.adapter.infra.security.OAuth2SuccessHandler;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.dao.DaoAuthenticationProvider;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.List;

/**
 * Spring Security configuration.
 *
 * <p>Optimized with:
 * - Environment-aware CORS configuration
 * - Rate limiting preparation
 * - Security headers
 *
 * @author sujie
 */
@Configuration
@EnableWebSecurity
@EnableMethodSecurity
@RequiredArgsConstructor
public class SecurityConfig {

    private final CustomUserDetailsService userDetailsService;
    private final JwtAuthenticationFilter jwtAuthenticationFilter;
    private final OAuth2SuccessHandler oAuth2SuccessHandler;
    private final OAuth2FailureHandler oAuth2FailureHandler;

    @Value("${auth.cors.allowed-origins:http://localhost:3000,http://localhost:8080}")
    private List<String> allowedOrigins;

    @Value("${auth.cors.allowed-methods:GET,POST,PUT,DELETE,OPTIONS}")
    private List<String> allowedMethods;

    @Value("${auth.cors.allow-credentials:true}")
    private boolean allowCredentials;

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
            .csrf(AbstractHttpConfigurer::disable)
            .cors(cors -> cors.configurationSource(corsConfigurationSource()))
            .sessionManagement(session ->
                session.sessionCreationPolicy(SessionCreationPolicy.STATELESS)
            )
            .authorizeHttpRequests(auth -> auth
                // Public endpoints - authentication
                .requestMatchers(
                    "/v1/login",
                    "/v1/register",
                    "/v1/refresh",
                    "/oauth2/**",
                    // Health checks (no auth required)
                    "/actuator/health/**",
                    "/actuator/info/**"
                ).permitAll()

                // Admin endpoints - require ADMIN role
                .requestMatchers("/v1/admin/**").hasRole("ADMIN")

                // All other endpoints require authentication
                .anyRequest().authenticated()
            )
            // OAuth2 login configuration
            .oauth2Login(oauth2 -> oauth2
                .loginPage("/oauth2/authorization")
                .successHandler(oAuth2SuccessHandler)
                .failureHandler(oAuth2FailureHandler)
            )
            // Add JWT filter before UsernamePasswordAuthenticationFilter
            .addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder(12);
    }

    @Bean
    public DaoAuthenticationProvider authenticationProvider() {
        var authProvider = new DaoAuthenticationProvider(userDetailsService);
        authProvider.setPasswordEncoder(passwordEncoder());
        return authProvider;
    }

    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration config) throws Exception {
        return config.getAuthenticationManager();
    }

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();

        // Configure allowed origins from environment
        configuration.setAllowedOrigins(allowedOrigins);

        // Configure allowed methods
        configuration.setAllowedMethods(allowedMethods);

        // Configure allowed headers
        configuration.setAllowedHeaders(List.of("*"));

        // Configure credentials support
        configuration.setAllowCredentials(allowCredentials);

        // Configure max age for preflight requests
        configuration.setMaxAge(3600L);

        // Configure exposed headers (if needed)
        configuration.setExposedHeaders(List.of("Authorization", "X-Total-Count"));

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);
        return source;
    }
}
