package io.github.suj1e.common.annotation;

import java.lang.annotation.*;

/**
 * 当前用户 ID 注解.
 * 用于 Controller 方法参数，自动注入当前登录用户的 ID.
 */
@Target(ElementType.PARAMETER)
@Retention(RetentionPolicy.RUNTIME)
@Documented
public @interface CurrentUserId {
}
