package io.github.suj1e.auth.adapter.service;

import io.github.suj1e.auth.core.domain.AuditLog;
import io.github.suj1e.auth.core.domain.User;

import java.time.Instant;
import java.util.List;

/**
 * Audit service interface.
 *
 * @author sujie
 */
public interface AuditService {

    /**
     * Log successful login.
     *
     * @param user the user
     */
    void logLoginSuccess(User user);

    /**
     * Log failed login attempt.
     *
     * @param user the user
     * @param errorMessage error message
     */
    void logLoginFailure(User user, String errorMessage);

    /**
     * Log user logout.
     *
     * @param user the user
     */
    void logLogout(User user);

    /**
     * Log user registration.
     *
     * @param user the user
     */
    void logRegister(User user);

    /**
     * Log OAuth2 login.
     *
     * @param user the user
     * @param provider OAuth2 provider
     */
    void logOAuth2Login(User user, String provider);

    /**
     * Log OAuth2 failure.
     *
     * @param provider OAuth2 provider
     * @param errorMessage error message
     */
    void logOAuth2Failure(String provider, String errorMessage);

    /**
     * Log token refresh.
     *
     * @param userId user ID
     */
    void logTokenRefresh(Long userId);

    /**
     * Get recent audit logs for user.
     *
     * @param userId user ID
     * @param limit max number of logs
     * @return audit log list
     */
    List<AuditLog> getRecentLogsForUser(Long userId, int limit);

    /**
     * Clean up old audit logs.
     *
     * @param retentionDays days to retain logs
     */
    void cleanupOldLogs(int retentionDays);
}
