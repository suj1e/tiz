package io.github.suj1e.auth.adapter.infra.domainservice.impl;

import io.github.suj1e.auth.core.domain.User;
import io.github.suj1e.auth.core.domainservice.AuthDomainService;
import io.github.suj1e.auth.infra.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

/**
 * Authentication domain service implementation.
 *
 * @author sujie
 */
@Service
@RequiredArgsConstructor
public class AuthDomainServiceImpl implements AuthDomainService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    @Override
    public void register(String username, String email, String password) {
        if (userRepository.existsByUsername(username)) {
            throw new IllegalArgumentException("Username already exists");
        }
        if (userRepository.existsByEmail(email)) {
            throw new IllegalArgumentException("Email already exists");
        }

        User user = User.builder()
                .username(username)
                .email(email)
                .password(passwordEncoder.encode(password))
                .status(User.Status.ACTIVE)
                .build();

        userRepository.save(user);
    }

    @Override
    public String login(String username, String password) {
        // TODO: Implement with JWT from nexora-starter-security
        return null;
    }

    @Override
    public void logout(String username) {
        // TODO: Implement logout
    }
}
