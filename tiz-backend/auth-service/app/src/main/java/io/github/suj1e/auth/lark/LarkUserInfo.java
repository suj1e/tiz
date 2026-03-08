package io.github.suj1e.auth.lark;

/**
 * 飞书用户信息.
 */
public record LarkUserInfo(
    String openId,
    String name,
    String email
) {}
