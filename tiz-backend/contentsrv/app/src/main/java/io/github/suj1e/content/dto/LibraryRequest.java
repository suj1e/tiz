package io.github.suj1e.content.dto;

import io.github.suj1e.content.entity.KnowledgeSet;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;

import java.util.List;
import java.util.UUID;

/**
 * 题库请求 DTO.
 */
@Getter
@Setter
public class LibraryRequest {

    @NotBlank(message = "Title is required")
    @Size(max = 255, message = "Title must be less than 255 characters")
    private String title;

    private UUID categoryId;

    private KnowledgeSet.Difficulty difficulty = KnowledgeSet.Difficulty.medium;

    private List<String> tags;
}
