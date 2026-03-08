package io.github.suj1e.auth.dto;

import jakarta.validation.constraints.NotBlank;

/**
 * 飞书登录请求 DTO.
 */
public record LarkLoginRequest(
    @NotBlank(message = "授权码不能为空")
    String code
) {}
