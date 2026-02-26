package io.github.suj1e.common.annotation;

import java.lang.annotation.*;

/**
 * 跳过认证注解.
 * 用于标记不需要认证的接口.
 */
@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
@Documented
public @interface NoAuth {
}
