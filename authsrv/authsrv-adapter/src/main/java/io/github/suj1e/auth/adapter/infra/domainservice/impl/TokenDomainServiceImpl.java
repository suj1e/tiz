package io.github.suj1e.auth.adapter.infra.domainservice.impl;

import io.github.suj1e.auth.core.domainservice.TokenDomainService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

/**
 * Token domain service implementation.
 * Uses nexora-starter-security for JWT handling.
 *
 * @author sujie
 */
@Slf4j
@Service
public class TokenDomainServiceImpl implements TokenDomainService {

    @Override
    public String generateAccessToken(String username) {
        // TODO: Use nexora-starter-security JWT provider
        return null;
    }

    @Override
    public String generateRefreshToken(String username) {
        // TODO: Implement refresh token
        return null;
    }

    @Override
    public boolean validateAccessToken(String token) {
        // TODO: Use nexora-starter-security JWT provider
        return false;
    }

    @Override
    public String getUsernameFromToken(String token) {
        // TODO: Use nexora-starter-security JWT provider
        return null;
    }

    @Override
    public String refreshAccessToken(String refreshToken) {
        // TODO: Implement token refresh
        return null;
    }
}
