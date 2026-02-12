package com.nexora.auth.api.dto.response;

/**
 * Generic message response DTO.
 *
 * @author sujie
 */
public record MessageResponse(
    String message
) {
    public static MessageResponse of(String message) {
        return new MessageResponse(message);
    }
}
