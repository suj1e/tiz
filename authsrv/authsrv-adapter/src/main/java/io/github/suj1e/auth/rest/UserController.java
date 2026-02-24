package io.github.suj1e.auth.rest;

import io.github.suj1e.auth.api.dto.response.UserResponse;
import io.github.suj1e.auth.core.domain.User;
import io.github.suj1e.auth.core.domainservice.UserDomainService;
import io.github.suj1e.auth.mapper.UserMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

/**
 * User REST controller.
 *
 * @author sujie
 */
@RestController
@RequestMapping("/v1/users")
@RequiredArgsConstructor
public class UserController {

    private final UserDomainService userDomainService;
    private final UserMapper userMapper;

    @GetMapping("/me")
    public ResponseEntity<UserResponse> getCurrentUser(Authentication authentication) {
        String username = authentication.getName();
        User user = userDomainService.getUserByUsername(username);
        return ResponseEntity.ok(userMapper.toResponse(user));
    }

    @PutMapping("/me")
    public ResponseEntity<Void> updateProfile(
            Authentication authentication,
            @RequestBody UpdateProfileRequest request) {
        String username = authentication.getName();
        userDomainService.updateProfile(username, request.nickname(), request.email());
        return ResponseEntity.ok().build();
    }

    @PutMapping("/me/password")
    public ResponseEntity<Void> changePassword(
            Authentication authentication,
            @RequestBody ChangePasswordRequest request) {
        String username = authentication.getName();
        userDomainService.changePassword(username, request.oldPassword(), request.newPassword());
        return ResponseEntity.ok().build();
    }

    public record UpdateProfileRequest(String nickname, String email) {}

    public record ChangePasswordRequest(String oldPassword, String newPassword) {}
}
