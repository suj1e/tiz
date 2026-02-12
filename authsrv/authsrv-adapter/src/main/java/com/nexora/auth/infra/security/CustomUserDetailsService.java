package com.nexora.auth.adapter.infra.security;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import com.nexora.auth.core.domain.User;
import com.nexora.auth.adapter.infra.repository.UserRepository;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * Custom user details service for Spring Security.
 *
 * @author sujie
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class CustomUserDetailsService implements UserDetailsService {

    private final UserRepository userRepository;

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        log.debug("Loading user details for username: {}", username);

        User user = userRepository.findByUsernameIgnoreCase(username)
            .or(() -> userRepository.findByEmailIgnoreCase(username))
            .orElseThrow(() -> new UsernameNotFoundException("User not found: " + username));

        var authorities = user.getRoles().stream()
            .map(role -> new SimpleGrantedAuthority(role.getName()))
            .toList();

        return org.springframework.security.core.userdetails.User.builder()
            .username(user.getUsername())
            .password(user.getPasswordHash())
            .authorities(authorities)
            .accountLocked(user.isAccountLocked())
            .disabled(!user.getEnabled())
            .accountExpired(user.getExpired())
            .credentialsExpired(user.getCredentialsExpired())
            .build();
    }

    /**
     * Load user by ID.
     */
    public UserDetails loadUserById(Long userId) throws UsernameNotFoundException {
        log.debug("Loading user details for user ID: {}", userId);

        User user = userRepository.findById(userId)
            .orElseThrow(() -> new UsernameNotFoundException("User not found with ID: " + userId));

        // Reuse loadUserByUsername by username
        return loadUserByUsername(user.getUsername());
    }
}
