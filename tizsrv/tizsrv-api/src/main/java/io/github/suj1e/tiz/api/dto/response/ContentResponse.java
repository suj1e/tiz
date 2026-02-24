package io.github.suj1e.tiz.api.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * Content response DTO.
 *
 * @author sujie
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ContentResponse {

    private Long id;
    private String title;
    private String description;
    private String imageUrl;
    private String contentUrl;
    private String type;
    private Long categoryId;
    private Long authorId;
    private String authorName;
    private Integer viewCount;
    private Integer likeCount;
    private Boolean isFeatured;
    private Boolean isTrending;
    private LocalDateTime publishedAt;
}
