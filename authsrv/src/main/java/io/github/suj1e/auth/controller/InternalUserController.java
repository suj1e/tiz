package io.github.suj1e.auth.controller;

import io.github.suj1e.auth.dto.UserResponse;
import io.github.suj1e.auth.entity.User;
import io.github.suj1e.auth.service.UserService;
import io.github.suj1e.common.response.ApiResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

/**
 * 内部用户控制器.
 * 供其他微服务调用.
 */
@RestController
@RequestMapping("/internal/auth/v1")
@RequiredArgsConstructor
public class InternalUserController {

    private final UserService userService;

    /**
     * 根据ID获取用户信息.
     */
    @GetMapping("/users/{id}")
    public ResponseEntity<ApiResponse<UserResponse>> getUserById(@PathVariable UUID id) {
        User user = userService.getUserById(id);
        return ResponseEntity.ok(ApiResponse.of(UserResponse.from(user)));
    }

    /**
     * 根据邮箱获取用户信息.
     */
    @GetMapping("/users/by-email")
    public ResponseEntity<ApiResponse<UserResponse>> getUserByEmail(@RequestParam String email) {
        User user = userService.getUserByEmail(email);
        return ResponseEntity.ok(ApiResponse.of(UserResponse.from(user)));
    }

    /**
     * 检查用户是否存在.
     */
    @GetMapping("/users/exists")
    public ResponseEntity<ApiResponse<Boolean>> checkUserExists(@RequestParam String email) {
        boolean exists = userService.existsByEmail(email);
        return ResponseEntity.ok(ApiResponse.of(exists));
    }
}
