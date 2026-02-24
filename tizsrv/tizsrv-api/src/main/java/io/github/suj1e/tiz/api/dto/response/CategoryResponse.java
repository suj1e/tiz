package io.github.suj1e.tiz.api.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Category response DTO.
 *
 * @author sujie
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CategoryResponse {

    private Long id;
    private String name;
    private String description;
    private String iconUrl;
    private Long parentId;
    private Integer sortOrder;
    private Long contentCount;
}
