package io.github.suj1e.auth.security;

import io.github.suj1e.auth.error.AuthException;
import io.github.suj1e.common.annotation.NoAuth;
import com.fasterxml.jackson.databind.ObjectMapper;
import io.github.suj1e.common.response.ApiResponse;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;
import org.springframework.web.method.HandlerMethod;
import org.springframework.web.servlet.HandlerExecutionChain;
import org.springframework.web.servlet.mvc.method.annotation.RequestMappingHandlerMapping;

import java.io.IOException;
import java.util.List;
import java.util.UUID;

/**
 * JWT 认证过滤器.
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private final JwtTokenProvider jwtTokenProvider;
    private final RequestMappingHandlerMapping handlerMapping;
    private final ObjectMapper objectMapper;

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response,
                                    FilterChain filterChain) throws ServletException, IOException {

        // 检查是否需要跳过认证
        if (shouldSkipAuth(request)) {
            filterChain.doFilter(request, response);
            return;
        }

        String token = jwtTokenProvider.resolveToken(request);

        if (token == null) {
            sendUnauthorizedResponse(response, "AUTH_1010", "未授权访问");
            return;
        }

        try {
            UUID userId = jwtTokenProvider.validateTokenAndGetUserId(token);

            // 设置认证信息
            UsernamePasswordAuthenticationToken authentication =
                new UsernamePasswordAuthenticationToken(
                    userId,
                    null,
                    List.of(new SimpleGrantedAuthority("ROLE_USER"))
                );

            SecurityContextHolder.getContext().setAuthentication(authentication);

            filterChain.doFilter(request, response);
        } catch (AuthException e) {
            log.warn("JWT authentication failed: {}", e.getMessage());
            sendUnauthorizedResponse(response, e.getErrorCode().getCode(), e.getMessage());
        } catch (Exception e) {
            log.error("JWT authentication error", e);
            sendUnauthorizedResponse(response, "AUTH_1006", "无效的访问令牌");
        }
    }

    /**
     * 检查是否需要跳过认证.
     */
    private boolean shouldSkipAuth(HttpServletRequest request) {
        try {
            HandlerExecutionChain chain = handlerMapping.getHandler(request);
            if (chain == null) {
                return true; // 无法处理的请求，交给后续处理
            }

            if (chain.getHandler() instanceof HandlerMethod handlerMethod) {
                // 检查方法上的 @NoAuth 注解
                if (handlerMethod.getMethodAnnotation(NoAuth.class) != null) {
                    return true;
                }
                // 检查类上的 @NoAuth 注解
                if (handlerMethod.getBeanType().getAnnotation(NoAuth.class) != null) {
                    return true;
                }
            }
        } catch (Exception e) {
            log.debug("Error checking NoAuth annotation: {}", e.getMessage());
        }

        // 内部 API 不需要 JWT 认证（由网关控制访问）
        String path = request.getRequestURI();
        if (path.startsWith("/internal/")) {
            return true;
        }

        return false;
    }

    /**
     * 发送未授权响应.
     */
    private void sendUnauthorizedResponse(HttpServletResponse response, String code, String message)
        throws IOException {
        response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
        response.setContentType("application/json;charset=UTF-8");

        ErrorResponse error = new ErrorResponse(
            "authentication_error",
            code,
            message
        );

        response.getWriter().write(objectMapper.writeValueAsString(new ApiErrorResponse(error)));
    }

    /**
     * 错误响应.
     */
    record ErrorResponse(String type, String code, String message) {}

    /**
     * API 错误响应.
     */
    record ApiErrorResponse(ErrorResponse error) {}
}
