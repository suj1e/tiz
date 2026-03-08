package io.github.suj1e.common.exception;

import io.github.suj1e.common.error.CommonErrorCode;
import io.github.suj1e.common.error.ErrorCode;
import io.github.suj1e.common.response.ApiResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

/**
 * 全局异常处理器.
 */
@Slf4j
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(BusinessException.class)
    public ResponseEntity<ApiResponse<ErrorBody>> handleBusinessException(BusinessException ex) {
        log.warn("Business exception: {} - {}", ex.getErrorCode().getCode(), ex.getMessage());

        ErrorCode errorCode = ex.getErrorCode();
        ErrorBody errorBody = new ErrorBody(
            errorCode.getType(),
            errorCode.getCode(),
            ex.getMessage()
        );

        return ResponseEntity
            .status(ex.getHttpStatus())
            .body(ApiResponse.of(errorBody));
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ApiResponse<ErrorBody>> handleValidationException(MethodArgumentNotValidException ex) {
        FieldError fieldError = ex.getBindingResult().getFieldError();
        String message = fieldError != null
            ? String.format("%s: %s", fieldError.getField(), fieldError.getDefaultMessage())
            : "Validation failed";

        log.warn("Validation exception: {}", message);

        ErrorCode errorCode = CommonErrorCode.INVALID_INPUT;
        ErrorBody errorBody = new ErrorBody(
            errorCode.getType(),
            errorCode.getCode(),
            message
        );

        return ResponseEntity
            .status(errorCode.getHttpStatus())
            .body(ApiResponse.of(errorBody));
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ApiResponse<ErrorBody>> handleException(Exception ex) {
        log.error("Unexpected exception", ex);

        ErrorCode errorCode = CommonErrorCode.INTERNAL_ERROR;
        ErrorBody errorBody = new ErrorBody(
            errorCode.getType(),
            errorCode.getCode(),
            errorCode.getMessage()
        );

        return ResponseEntity
            .status(errorCode.getHttpStatus())
            .body(ApiResponse.of(errorBody));
    }

    /**
     * 错误响应体.
     */
    public record ErrorBody(
        String type,
        String code,
        String message
    ) {}
}
