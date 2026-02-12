package com.nexora.auth.api.event;

/**
 * User event types.
 *
 * @author sujie
 */
public enum UserEventType {
    // User lifecycle events
    USER_CREATED,
    USER_LOGIN,
    USER_LOGOUT,

    // Security events
    PASSWORD_CHANGED,
    ACCOUNT_LOCKED,
    ACCOUNT_UNLOCKED,

    // Role management events
    ROLE_ASSIGNED,
    ROLE_REVOKED,

    // Session events
    SESSION_CREATED,
    SESSION_EXPIRED,
    SESSION_REVOKED
}
