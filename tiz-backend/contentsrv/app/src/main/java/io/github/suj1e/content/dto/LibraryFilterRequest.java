package io.github.suj1e.content.dto;

import io.github.suj1e.common.dto.PageRequest;
import io.github.suj1e.content.entity.KnowledgeSet;
import lombok.Getter;
import lombok.Setter;

import java.util.List;
import java.util.UUID;

/**
 * 题库查询参数.
 */
@Getter
@Setter
public class LibraryFilterRequest extends PageRequest {

    private UUID categoryId;

    private KnowledgeSet.Difficulty difficulty;

    private List<String> tags;

    public LibraryFilterRequest() {
        setSortBy("createdAt");
        setSortOrder(org.springframework.data.domain.Sort.Direction.DESC);
    }
}
