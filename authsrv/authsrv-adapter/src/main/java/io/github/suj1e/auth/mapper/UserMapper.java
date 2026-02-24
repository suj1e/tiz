package io.github.suj1e.auth.mapper;

import io.github.suj1e.auth.api.dto.response.UserResponse;
import io.github.suj1e.auth.core.domain.User;
import org.springframework.stereotype.Component;

/**
 * User mapper.
 *
 * @author sujie
 */
@Component
public class UserMapper {

    public UserResponse toResponse(User user) {
        if (user == null) {
            return null;
        }
        return new UserResponse(
                user.getId(),
                user.getUsername(),
                user.getEmail(),
                user.getNickname(),
                user.getAvatar(),
                user.getStatus().name(),
                user.getCreatedAt()
        );
    }
}
