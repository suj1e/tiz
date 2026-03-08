package io.github.suj1e.content.controller;

import io.github.suj1e.common.annotation.CurrentUserId;
import io.github.suj1e.common.response.ApiResponse;
import io.github.suj1e.common.response.CursorResponse;
import io.github.suj1e.content.dto.*;
import io.github.suj1e.content.service.LibraryService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

/**
 * 题库控制器 (对外 API).
 */
@RestController
@RequestMapping("/api/content/v1/library")
@RequiredArgsConstructor
public class LibraryController {

    private final LibraryService libraryService;

    /**
     * 获取题库列表.
     */
    @GetMapping
    public CursorResponse<LibrarySummaryResponse> getLibraries(
        @CurrentUserId UUID userId,
        @Valid LibraryFilterRequest filter
    ) {
        return libraryService.getLibraries(userId, filter);
    }

    /**
     * 获取题库详情.
     */
    @GetMapping("/{id}")
    public ApiResponse<LibraryResponse> getLibraryById(
        @CurrentUserId UUID userId,
        @PathVariable UUID id
    ) {
        return ApiResponse.of(libraryService.getLibraryById(id, userId));
    }

    /**
     * 更新题库.
     */
    @PatchMapping("/{id}")
    public ApiResponse<LibraryResponse> updateLibrary(
        @CurrentUserId UUID userId,
        @PathVariable UUID id,
        @Valid @RequestBody LibraryRequest request
    ) {
        return ApiResponse.of(libraryService.updateLibrary(id, userId, request));
    }

    /**
     * 删除题库.
     */
    @DeleteMapping("/{id}")
    public ApiResponse<Void> deleteLibrary(
        @CurrentUserId UUID userId,
        @PathVariable UUID id
    ) {
        libraryService.deleteLibrary(id, userId);
        return ApiResponse.empty();
    }
}
