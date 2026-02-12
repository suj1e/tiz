package com.nexora.auth.adapter.service.impl;

import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import com.nexora.auth.adapter.infra.repository.AuditLogRepository;
import com.nexora.auth.core.domain.AuditLog;
import com.nexora.auth.core.domain.User;
import com.nexora.auth.adapter.service.AuditService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import java.time.Instant;
import java.util.List;

/**
 * Audit service implementation.
 *
 * @author sujie
 */
@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class AuditServiceImpl implements AuditService {

    private final AuditLogRepository auditLogRepository;

    @Override
    @Transactional
    public void logLoginSuccess(User user) {
        AuditLog auditLog = createLogWithRequest(AuditLog.Actions.LOGIN, user.getId(), true);
        auditLogRepository.save(auditLog);
        log.debug("Login success logged for user: {}", user.getUsername());
    }

    @Override
    @Transactional
    public void logLoginFailure(User user, String errorMessage) {
        AuditLog auditLog = AuditLog.createFailure(
            AuditLog.Actions.LOGIN_FAILURE,
            user.getId(),
            errorMessage
        );
        enrichWithRequestInfo(auditLog);
        auditLogRepository.save(auditLog);
        log.debug("Login failure logged for user: {}", user.getUsername());
    }

    @Override
    @Transactional
    public void logLogout(User user) {
        AuditLog auditLog = createLogWithRequest(AuditLog.Actions.LOGOUT, user.getId(), true);
        auditLogRepository.save(auditLog);
        log.debug("Logout logged for user: {}", user.getUsername());
    }

    @Override
    @Transactional
    public void logRegister(User user) {
        AuditLog auditLog = createLogWithRequest(AuditLog.Actions.REGISTER, user.getId(), true);
        auditLogRepository.save(auditLog);
        log.debug("Registration logged for user: {}", user.getUsername());
    }

    @Override
    @Transactional
    public void logOAuth2Login(User user, String provider) {
        AuditLog auditLog = createLogWithRequest(AuditLog.Actions.OAUTH2_LOGIN, user.getId(), true);
        auditLogRepository.save(auditLog);
        log.debug("OAuth2 login logged for user: {} via provider: {}", user.getUsername(), provider);
    }

    @Override
    @Transactional
    public void logOAuth2Failure(String provider, String errorMessage) {
        AuditLog auditLog = AuditLog.createFailure(
            AuditLog.Actions.OAUTH2_FAILURE,
            null,
            "OAuth2 failure via " + provider + ": " + errorMessage
        );
        enrichWithRequestInfo(auditLog);
        auditLogRepository.save(auditLog);
        log.debug("OAuth2 failure logged for provider: {}", provider);
    }

    @Override
    @Transactional
    public void logTokenRefresh(Long userId) {
        AuditLog auditLog = createLogWithRequest(AuditLog.Actions.TOKEN_REFRESH, userId, true);
        auditLogRepository.save(auditLog);
        log.debug("Token refresh logged for user: {}", userId);
    }

    @Override
    public List<AuditLog> getRecentLogsForUser(Long userId, int limit) {
        List<AuditLog> logs = auditLogRepository.findByUserIdOrderByCreatedAtDesc(userId);
        return logs.stream().limit(limit).toList();
    }

    @Override
    @Transactional
    public void cleanupOldLogs(int retentionDays) {
        Instant before = Instant.now().minusSeconds(retentionDays * 24L * 60 * 60);
        auditLogRepository.deleteOldLogs(before);
        log.info("Cleaned up old audit logs (older than {} days)", retentionDays);
    }

    private AuditLog createLogWithRequest(String action, Long userId, boolean success) {
        return AuditLog.createWithMetadata(
            action,
            userId,
            success,
            getClientIp(),
            getUserAgent()
        );
    }

    private void enrichWithRequestInfo(AuditLog auditLog) {
        auditLog.setIpAddress(getClientIp());
        auditLog.setUserAgent(getUserAgent());
    }

    private String getClientIp() {
        try {
            ServletRequestAttributes attributes =
                (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
            if (attributes != null) {
                HttpServletRequest request = attributes.getRequest();
                String xForwardedFor = request.getHeader("X-Forwarded-For");
                if (xForwardedFor != null && !xForwardedFor.isBlank()) {
                    return xForwardedFor.split(",")[0].trim();
                }
                return request.getRemoteAddr();
            }
        } catch (Exception e) {
            log.debug("Could not get client IP: {}", e.getMessage());
        }
        return null;
    }

    private String getUserAgent() {
        try {
            ServletRequestAttributes attributes =
                (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
            if (attributes != null) {
                return attributes.getRequest().getHeader("User-Agent");
            }
        } catch (Exception e) {
            log.debug("Could not get user agent: {}", e.getMessage());
        }
        return null;
    }
}
