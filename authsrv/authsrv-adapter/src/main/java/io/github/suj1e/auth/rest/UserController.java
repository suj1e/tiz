package io.github.suj1e.auth.rest;

import io.github.suj1e.auth.api.dto.response.UserResponse;
import io.github.suj1e.auth.core.domainservice.UserDomainService;
import lombok.RequiredArgsConstructor;
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

    @GetMapping("/me")
    public UserResponse getCurrentUser(@RequestAttribute("username") String username) {
        // TODO: Return user response
        return null;
    }

    @PutMapping("/me")
    public void updateProfile(
            @RequestAttribute("username") String username,
            @RequestBody UpdateProfileRequest request) {
        userDomainService.updateProfile(username, request.nickname(), request.email());
    }

    @PutMapping("/me/password")
    public void changePassword(
            @RequestAttribute("username") String username,
            @RequestBody ChangePasswordRequest request) {
        userDomainService.changePassword(username, request.oldPassword(), request.newPassword());
    }

    public record UpdateProfileRequest(String nickname, String email) {}

    public record ChangePasswordRequest(String oldPassword, String newPassword) {}
}
