package io.github.suj1e.auth.mapper;

import io.github.suj1e.auth.api.dto.response.UserResponse;
import io.github.suj1e.auth.core.domain.User;

import java.util.Set;
import java.util.stream.Collectors;

/**
 * Mapper for converting User entities to DTOs.
 *
 * @author sujie
 */
public class UserMapper {

    /**
     * Convert User entity to UserResponse DTO.
     */
    public static UserResponse toResponse(User user) {
        return new UserResponse(
            user.getId(),
            user.getUsername(),
            user.getEmail(),
            user.getName(),
            user.getAvatarUrl(),
            user.getAuthProvider(),
            user.getRoles().stream()
                .map(r -> r.getName())
                .collect(Collectors.toSet()),
            user.getEnabled(),
            user.getLastLoginAt()
        );
    }
}
