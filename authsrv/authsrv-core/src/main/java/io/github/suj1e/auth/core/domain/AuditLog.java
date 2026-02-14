package io.github.suj1e.auth.core.domain;

import jakarta.persistence.*;
import java.time.Instant;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;
import com.nexora.datajp.support.BaseEntity;

/**
 * Audit log entity for tracking authentication events.
 *
 * @author sujie
 */
@Entity
@Table(name = "audit_logs", indexes = {
    @Index(name = "idx_audit_logs_user", columnList = "user_id"),
    @Index(name = "idx_audit_logs_action", columnList = "action"),
    @Index(name = "idx_audit_logs_created", columnList = "created_at")
})
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class AuditLog extends BaseEntity {

    @Column(name = "user_id")
    private Long userId;

    @Column(nullable = false, length = 50)
    private String action;

    @Column(name = "ip_address", length = 45)
    private String ipAddress;

    @Column(name = "user_agent", columnDefinition = "TEXT")
    private String userAgent;

    @Column(nullable = false)
    private Boolean success;

    @Column(name = "error_message", columnDefinition = "TEXT")
    private String errorMessage;

    /**
     * Factory method - Create audit log entry.
     */
    public static AuditLog create(String action, Long userId, boolean success) {
        validateAction(action);

        AuditLog auditLog = new AuditLog();
        auditLog.action = action;
        auditLog.userId = userId;
        auditLog.success = success;
        return auditLog;
    }

    /**
     * Factory method - Create failed audit log entry with error message.
     */
    public static AuditLog createFailure(String action, Long userId, String errorMessage) {
        AuditLog auditLog = create(action, userId, false);
        auditLog.errorMessage = errorMessage;
        return auditLog;
    }

    /**
     * Factory method - Create audit log with request metadata.
     */
    public static AuditLog createWithMetadata(String action, Long userId, boolean success,
            String ipAddress, String userAgent) {
        AuditLog auditLog = create(action, userId, success);
        auditLog.ipAddress = ipAddress;
        auditLog.userAgent = userAgent;
        return auditLog;
    }

    /**
     * Set IP address.
     */
    public void setIpAddress(String ipAddress) {
        this.ipAddress = ipAddress;
    }

    /**
     * Set user agent.
     */
    public void setUserAgent(String userAgent) {
        this.userAgent = userAgent;
    }

    /**
     * Set error message.
     */
    public void setErrorMessage(String errorMessage) {
        this.errorMessage = errorMessage;
    }

    /**
     * Action constants.
     */
    public static final class Actions {
        public static final String LOGIN = "LOGIN";
        public static final String LOGIN_FAILURE = "LOGIN_FAILURE";
        public static final String LOGOUT = "LOGOUT";
        public static final String REGISTER = "REGISTER";
        public static final String PASSWORD_CHANGE = "PASSWORD_CHANGE";
        public static final String PASSWORD_RESET = "PASSWORD_RESET";
        public static final String TOKEN_REFRESH = "TOKEN_REFRESH";
        public static final String ACCOUNT_LOCKED = "ACCOUNT_LOCKED";
        public static final String ACCOUNT_UNLOCKED = "ACCOUNT_UNLOCKED";
        public static final String OAUTH2_LOGIN = "OAUTH2_LOGIN";
        public static final String OAUTH2_FAILURE = "OAUTH2_FAILURE";

        private Actions() {
        }
    }

    private static void validateAction(String action) {
        if (action == null || action.isBlank()) {
            throw new IllegalArgumentException("Action cannot be blank");
        }
        if (action.length() > 50) {
            throw new IllegalArgumentException("Action must not exceed 50 characters");
        }
    }
}
