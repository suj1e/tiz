package io.github.suj1e.gateway.handler;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;

/**
 * Gateway error response body.
 */
public record GatewayErrorResponse(
    String type,
    String code,
    String message
) {
    private static final ObjectMapper OBJECT_MAPPER = new ObjectMapper();

    /**
     * Convert to JSON string.
     */
    public String toJson() {
        try {
            return OBJECT_MAPPER.writeValueAsString(new Wrapper(this));
        } catch (JsonProcessingException e) {
            return "{\"error\":{\"type\":\"api_error\",\"code\":\"internal_error\",\"message\":\"Failed to serialize error response\"}}";
        }
    }

    /**
     * Wrapper to match API response format: { "error": {...} }
     */
    private record Wrapper(GatewayErrorResponse error) {}
}
