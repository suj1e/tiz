package com.nexora.auth.exception;

import lombok.AllArgsConstructor;
import lombok.Getter;

/**
 * Error codes for authsrv business exceptions.
 */
@Getter
@AllArgsConstructor
public enum ErrorCode {

    // Authentication errors (10xx)
    INVALID_CREDENTIALS("AUTH_1001", "Invalid username or password", 401),
    ACCOUNT_LOCKED("AUTH_1002", "Account is locked", 403),
    ACCOUNT_DISABLED("AUTH_1003", "Account is disabled", 403),
    TOKEN_EXPIRED("AUTH_1004", "Token has expired", 401),
    TOKEN_INVALID("AUTH_1005", "Invalid token", 401),
    TOKEN_REVOKED("AUTH_1006", "Token has been revoked", 401),
    REFRESH_TOKEN_INVALID("AUTH_1007", "Invalid refresh token", 401),
    TOO_MANY_LOGIN_ATTEMPTS("AUTH_1008", "Too many failed login attempts, account temporarily locked", 429),

    // Registration errors (11xx)
    USERNAME_EXISTS("AUTH_1101", "Username already exists", 409),
    EMAIL_EXISTS("AUTH_1102", "Email already exists", 409),
    WEAK_PASSWORD("AUTH_1103", "Password does not meet security requirements", 400),
    VERIFICATION_CODE_INVALID("AUTH_1104", "Invalid or expired verification code", 400),

    // User errors (12xx)
    USER_NOT_FOUND("AUTH_1201", "User not found", 404),
    USER_ALREADY_EXISTS("AUTH_1202", "User already exists", 409),
    INVALID_PASSWORD("AUTH_1203", "Invalid current password", 400),

    // Role errors (13xx)
    ROLE_NOT_FOUND("AUTH_1301", "Role not found", 404),
    ROLE_ALREADY_ASSIGNED("AUTH_1302", "Role already assigned to user", 409),
    ROLE_NOT_ASSIGNED("AUTH_1303", "Role not assigned to user", 409),

    // OAuth2 errors (14xx)
    OAUTH2_AUTHENTICATION_FAILED("AUTH_1401", "OAuth2 authentication failed", 401),
    OAUTH2_PROVIDER_NOT_SUPPORTED("AUTH_1402", "OAuth2 provider not supported", 400),
    OAUTH2_EMAIL_NOT_VERIFIED("AUTH_1403", "Email from OAuth2 provider not verified", 400),

    // Session errors (15xx)
    MAX_SESSIONS_EXCEEDED("AUTH_1501", "Maximum concurrent sessions exceeded", 403),
    SESSION_NOT_FOUND("AUTH_1502", "Session not found", 404),

    // File upload errors (16xx)
    FILE_UPLOAD_FAILED("AUTH_1601", "File upload failed", 400),
    INVALID_FILE_TYPE("AUTH_1602", "Invalid file type", 400),
    FILE_TOO_LARGE("AUTH_1603", "File size exceeds maximum allowed", 400),

    // Validation errors (17xx)
    VALIDATION_ERROR("AUTH_1701", "Validation failed", 400),
    INVALID_REQUEST("AUTH_1702", "Invalid request", 400),

    // System errors (50xx)
    INTERNAL_ERROR("AUTH_5001", "Internal server error", 500),
    SERVICE_UNAVAILABLE("AUTH_5002", "Service temporarily unavailable", 503);

    private final String code;
    private final String message;
    private final int httpStatus;
}
