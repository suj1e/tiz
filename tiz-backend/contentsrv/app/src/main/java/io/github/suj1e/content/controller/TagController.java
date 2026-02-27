package io.github.suj1e.content.controller;

import io.github.suj1e.common.response.ApiResponse;
import io.github.suj1e.content.dto.TagResponse;
import io.github.suj1e.content.service.TagService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 标签控制器 (对外 API).
 */
@RestController
@RequestMapping("/api/content/v1/tags")
@RequiredArgsConstructor
public class TagController {

    private final TagService tagService;

    /**
     * 获取所有标签.
     */
    @GetMapping
    public ApiResponse<List<TagResponse>> getAllTags() {
        return ApiResponse.of(tagService.getAllTags());
    }
}
