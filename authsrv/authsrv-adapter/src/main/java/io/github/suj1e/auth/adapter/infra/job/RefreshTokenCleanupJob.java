package io.github.suj1e.auth.adapter.infra.job;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import io.github.suj1e.auth.adapter.infra.repository.RefreshTokenRepository;
import io.github.suj1e.auth.core.domain.RefreshToken;
import org.quartz.*;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.List;

/**
 * Refresh token cleanup job.
 *
 * <p>Cleans up expired refresh tokens from the database.
 * This job runs daily (default at 2 AM) to maintain database hygiene.
 *
 * @author sujie
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class RefreshTokenCleanupJob implements Job {

    public static final String REFRESH_TOKEN_CLEANUP_JOB = "REFRESH_TOKEN_CLEANUP_JOB";
    private static final int EXPIRY_DAYS = 30; // Delete tokens older than 30 days

    private final RefreshTokenRepository refreshTokenRepository;

    @Override
    @Transactional
    public void execute(JobExecutionContext context) {
        log.info("Starting refresh token cleanup job");

        // Convert LocalDateTime to Instant
        LocalDateTime cutoffLocal = LocalDateTime.now().minusDays(EXPIRY_DAYS);
        Instant cutoff = cutoffLocal.atZone(ZoneId.systemDefault()).toInstant();

        // Find expired tokens
        List<RefreshToken> expiredTokens = refreshTokenRepository.findExpiredTokens(cutoff);

        if (expiredTokens.isEmpty()) {
            log.info("No expired refresh tokens to clean up");
            return;
        }

        // Delete expired tokens
        refreshTokenRepository.deleteAll(expiredTokens);

        log.info("Refresh token cleanup job completed: deleted {} tokens", expiredTokens.size());
    }
}
