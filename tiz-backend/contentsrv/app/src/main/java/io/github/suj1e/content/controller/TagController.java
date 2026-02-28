package io.github.suj1e.content.controller;

import io.github.suj1e.common.response.ApiResponse;
import io.github.suj1e.content.dto.TagResponse;
import io.github.suj1e.content.service.TagService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

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
    public ApiResponse<Map<String, List<TagResponse>>> getAllTags() {
        List<TagResponse> tags = tagService.getAllTagsWithCount();
        return ApiResponse.of(Map.of("tags", tags));
    }
}
