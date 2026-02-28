package io.github.suj1e.content.service;

import io.github.suj1e.content.dto.TagResponse;
import io.github.suj1e.content.entity.Tag;
import io.github.suj1e.content.repository.TagRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

/**
 * TagService 单元测试.
 */
@ExtendWith(MockitoExtension.class)
class TagServiceTest {

    @Mock
    private TagRepository tagRepository;

    @InjectMocks
    private TagService tagService;

    private Tag testTag;

    @BeforeEach
    void setUp() {
        testTag = new Tag();
        testTag.setId(java.util.UUID.randomUUID());
        testTag.setName("Java");
    }

    @Nested
    @DisplayName("getAllTags")
    class GetAllTags {

        @Test
        @DisplayName("should return all tags sorted by name")
        void shouldReturnAllTagsSorted() {
            // Arrange
            Tag tag2 = new Tag();
            tag2.setId(java.util.UUID.randomUUID());
            tag2.setName("Python");

            when(tagRepository.findAllByOrderByNameAsc())
                .thenReturn(List.of(testTag, tag2));

            // Act
            List<TagResponse> result = tagService.getAllTags();

            // Assert
            assertThat(result).hasSize(2);
            assertThat(result.get(0).name()).isEqualTo("Java");
            assertThat(result.get(1).name()).isEqualTo("Python");
        }

        @Test
        @DisplayName("should return empty list when no tags")
        void shouldReturnEmptyList() {
            // Arrange
            when(tagRepository.findAllByOrderByNameAsc())
                .thenReturn(List.of());

            // Act
            List<TagResponse> result = tagService.getAllTags();

            // Assert
            assertThat(result).isEmpty();
        }
    }

    @Nested
    @DisplayName("getAllTagsWithCount")
    class GetAllTagsWithCount {

        @Test
        @DisplayName("should return all tags with count")
        void shouldReturnAllTagsWithCount() {
            // Arrange
            Tag tag2 = new Tag();
            tag2.setId(java.util.UUID.randomUUID());
            tag2.setName("Python");

            when(tagRepository.findAllByOrderByNameAsc())
                .thenReturn(List.of(testTag, tag2));
            when(tagRepository.countKnowledgeSetsByTagId(testTag.getId()))
                .thenReturn(10L);
            when(tagRepository.countKnowledgeSetsByTagId(tag2.getId()))
                .thenReturn(5L);

            // Act
            List<TagResponse> result = tagService.getAllTagsWithCount();

            // Assert
            assertThat(result).hasSize(2);
            assertThat(result.get(0).name()).isEqualTo("Java");
            assertThat(result.get(0).count()).isEqualTo(10L);
            assertThat(result.get(1).name()).isEqualTo("Python");
            assertThat(result.get(1).count()).isEqualTo(5L);
        }
    }

    @Nested
    @DisplayName("getOrCreateTags")
    class GetOrCreateTags {

        @Test
        @DisplayName("should return existing tags")
        void shouldReturnExistingTags() {
            // Arrange
            when(tagRepository.findByName("Java")).thenReturn(Optional.of(testTag));

            // Act
            List<Tag> result = tagService.getOrCreateTags(List.of("Java"));

            // Assert
            assertThat(result).hasSize(1);
            assertThat(result.get(0).getName()).isEqualTo("Java");
            verify(tagRepository, never()).save(any());
        }

        @Test
        @DisplayName("should create new tags when not exists")
        void shouldCreateNewTags() {
            // Arrange
            when(tagRepository.findByName("React")).thenReturn(Optional.empty());
            when(tagRepository.save(any(Tag.class))).thenAnswer(inv -> {
                Tag tag = inv.getArgument(0);
                tag.setId(java.util.UUID.randomUUID());
                return tag;
            });

            // Act
            List<Tag> result = tagService.getOrCreateTags(List.of("React"));

            // Assert
            assertThat(result).hasSize(1);
            verify(tagRepository).save(any(Tag.class));
        }

        @Test
        @DisplayName("should return empty list for null input")
        void shouldReturnEmptyListForNull() {
            // Act
            List<Tag> result = tagService.getOrCreateTags(null);

            // Assert
            assertThat(result).isEmpty();
        }
    }
}
