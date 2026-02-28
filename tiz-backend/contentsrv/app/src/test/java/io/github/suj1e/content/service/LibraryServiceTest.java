package io.github.suj1e.content.service;

import io.github.suj1e.common.exception.NotFoundException;
import io.github.suj1e.content.dto.LibraryFilterRequest;
import io.github.suj1e.content.dto.LibraryRequest;
import io.github.suj1e.content.dto.LibraryResponse;
import io.github.suj1e.content.dto.LibrarySummaryResponse;
import io.github.suj1e.content.entity.Category;
import io.github.suj1e.content.entity.KnowledgeSet;
import io.github.suj1e.content.entity.Tag;
import io.github.suj1e.content.repository.KnowledgeSetRepository;
import io.github.suj1e.common.response.CursorResponse;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;

/**
 * LibraryService 单元测试.
 */
@ExtendWith(MockitoExtension.class)
class LibraryServiceTest {

    @Mock
    private KnowledgeSetRepository knowledgeSetRepository;

    @Mock
    private CategoryService categoryService;

    @Mock
    private TagService tagService;

    @Mock
    private QuestionService questionService;

    @InjectMocks
    private LibraryService libraryService;

    private UUID userId;
    private UUID knowledgeSetId;
    private KnowledgeSet testKnowledgeSet;

    @BeforeEach
    void setUp() {
        userId = UUID.randomUUID();
        knowledgeSetId = UUID.randomUUID();

        testKnowledgeSet = new KnowledgeSet();
        testKnowledgeSet.setId(knowledgeSetId);
        testKnowledgeSet.setUserId(userId);
        testKnowledgeSet.setTitle("Test Knowledge Set");
        testKnowledgeSet.setDifficulty(KnowledgeSet.Difficulty.medium);
        testKnowledgeSet.setQuestionCount(10);
    }

    @Nested
    @DisplayName("getLibraries")
    class GetLibraries {

        @Test
        @DisplayName("should return paged libraries for user")
        void shouldReturnPagedLibraries() {
            // Arrange
            LibraryFilterRequest filter = new LibraryFilterRequest();
            filter.setPage(1);
            filter.setPageSize(10);

            Page<KnowledgeSet> page = new PageImpl<>(List.of(testKnowledgeSet));
            when(knowledgeSetRepository.findByUserIdWithFilters(
                eq(userId), any(), any(), any(), any(Pageable.class)
            )).thenReturn(page);

            // Act
            CursorResponse<LibrarySummaryResponse> result = libraryService.getLibraries(userId, filter);

            // Assert
            assertThat(result.data()).hasSize(1);
            assertThat(result.data().get(0).title()).isEqualTo("Test Knowledge Set");
            assertThat(result.hasMore()).isFalse();
        }

        @Test
        @DisplayName("should filter by category")
        void shouldFilterByCategory() {
            // Arrange
            UUID categoryId = UUID.randomUUID();
            LibraryFilterRequest filter = new LibraryFilterRequest();
            filter.setPage(1);
            filter.setPageSize(10);
            filter.setCategoryId(categoryId);

            Page<KnowledgeSet> page = new PageImpl<>(List.of(testKnowledgeSet));
            when(knowledgeSetRepository.findByUserIdWithFilters(
                eq(userId), eq(categoryId), any(), any(), any(Pageable.class)
            )).thenReturn(page);

            // Act
            CursorResponse<LibrarySummaryResponse> result = libraryService.getLibraries(userId, filter);

            // Assert
            assertThat(result.data()).hasSize(1);
            verify(knowledgeSetRepository).findByUserIdWithFilters(
                eq(userId), eq(categoryId), any(), any(), any(Pageable.class)
            );
        }
    }

    @Nested
    @DisplayName("getLibraryById")
    class GetLibraryById {

        @Test
        @DisplayName("should return library when found")
        void shouldReturnLibraryWhenFound() {
            // Arrange
            when(knowledgeSetRepository.findByIdAndUserId(knowledgeSetId, userId))
                .thenReturn(Optional.of(testKnowledgeSet));

            // Act
            LibraryResponse result = libraryService.getLibraryById(knowledgeSetId, userId);

            // Assert
            assertThat(result.title()).isEqualTo("Test Knowledge Set");
            assertThat(result.difficulty()).isEqualTo("medium");
        }

        @Test
        @DisplayName("should throw NotFoundException when not found")
        void shouldThrowNotFoundExceptionWhenNotFound() {
            // Arrange
            when(knowledgeSetRepository.findByIdAndUserId(knowledgeSetId, userId))
                .thenReturn(Optional.empty());

            // Act & Assert
            assertThatThrownBy(() -> libraryService.getLibraryById(knowledgeSetId, userId))
                .isInstanceOf(NotFoundException.class);
        }
    }

    @Nested
    @DisplayName("updateLibrary")
    class UpdateLibrary {

        @Test
        @DisplayName("should update library title")
        void shouldUpdateLibraryTitle() {
            // Arrange
            LibraryRequest request = new LibraryRequest();
            request.setTitle("Updated Title");

            when(knowledgeSetRepository.findByIdAndUserId(knowledgeSetId, userId))
                .thenReturn(Optional.of(testKnowledgeSet));
            when(knowledgeSetRepository.save(any(KnowledgeSet.class)))
                .thenReturn(testKnowledgeSet);

            // Act
            LibraryResponse result = libraryService.updateLibrary(knowledgeSetId, userId, request);

            // Assert
            assertThat(result.title()).isEqualTo("Updated Title");
            verify(knowledgeSetRepository).save(any(KnowledgeSet.class));
        }

        @Test
        @DisplayName("should update tags")
        void shouldUpdateTags() {
            // Arrange
            LibraryRequest request = new LibraryRequest();
            request.setTitle("Test");
            request.setTags(List.of("tag1", "tag2"));

            Tag tag1 = new Tag();
            tag1.setId(UUID.randomUUID());
            tag1.setName("tag1");
            Tag tag2 = new Tag();
            tag2.setId(UUID.randomUUID());
            tag2.setName("tag2");

            when(knowledgeSetRepository.findByIdAndUserId(knowledgeSetId, userId))
                .thenReturn(Optional.of(testKnowledgeSet));
            when(tagService.getOrCreateTags(List.of("tag1", "tag2")))
                .thenReturn(List.of(tag1, tag2));
            when(knowledgeSetRepository.save(any(KnowledgeSet.class)))
                .thenReturn(testKnowledgeSet);

            // Act
            libraryService.updateLibrary(knowledgeSetId, userId, request);

            // Assert
            verify(tagService).getOrCreateTags(List.of("tag1", "tag2"));
            verify(knowledgeSetRepository).save(any(KnowledgeSet.class));
        }
    }

    @Nested
    @DisplayName("deleteLibrary")
    class DeleteLibrary {

        @Test
        @DisplayName("should soft delete library")
        void shouldSoftDeleteLibrary() {
            // Arrange
            when(knowledgeSetRepository.findByIdAndUserId(knowledgeSetId, userId))
                .thenReturn(Optional.of(testKnowledgeSet));

            // Act
            libraryService.deleteLibrary(knowledgeSetId, userId);

            // Assert
            verify(knowledgeSetRepository).delete(testKnowledgeSet);
        }

        @Test
        @DisplayName("should throw NotFoundException when deleting non-existent library")
        void shouldThrowNotFoundExceptionWhenDeletingNonExistent() {
            // Arrange
            when(knowledgeSetRepository.findByIdAndUserId(knowledgeSetId, userId))
                .thenReturn(Optional.empty());

            // Act & Assert
            assertThatThrownBy(() -> libraryService.deleteLibrary(knowledgeSetId, userId))
                .isInstanceOf(NotFoundException.class);
        }
    }
}
