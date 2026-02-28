package io.github.suj1e.content.service;

import io.github.suj1e.common.exception.NotFoundException;
import io.github.suj1e.content.dto.CategoryResponse;
import io.github.suj1e.content.entity.Category;
import io.github.suj1e.content.repository.CategoryRepository;
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
import java.util.UUID;

import static org.assertj.core.api.Assertions.*;
import static org.mockito.Mockito.*;

/**
 * CategoryService 单元测试.
 */
@ExtendWith(MockitoExtension.class)
class CategoryServiceTest {

    @Mock
    private CategoryRepository categoryRepository;

    @InjectMocks
    private CategoryService categoryService;

    private Category testCategory;
    private UUID categoryId;

    @BeforeEach
    void setUp() {
        categoryId = UUID.randomUUID();
        testCategory = new Category();
        testCategory.setId(categoryId);
        testCategory.setName("Frontend");
        testCategory.setDescription("Frontend Development");
        testCategory.setSortOrder(1);
    }

    @Nested
    @DisplayName("getAllCategories")
    class GetAllCategories {

        @Test
        @DisplayName("should return all categories sorted by sortOrder")
        void shouldReturnAllCategoriesSorted() {
            // Arrange
            Category category2 = new Category();
            category2.setId(UUID.randomUUID());
            category2.setName("Backend");
            category2.setSortOrder(2);

            when(categoryRepository.findAllByOrderBySortOrderAsc())
                .thenReturn(List.of(testCategory, category2));

            // Act
            List<CategoryResponse> result = categoryService.getAllCategories();

            // Assert
            assertThat(result).hasSize(2);
            assertThat(result.get(0).name()).isEqualTo("Frontend");
            assertThat(result.get(1).name()).isEqualTo("Backend");
        }

        @Test
        @DisplayName("should return empty list when no categories")
        void shouldReturnEmptyList() {
            // Arrange
            when(categoryRepository.findAllByOrderBySortOrderAsc())
                .thenReturn(List.of());

            // Act
            List<CategoryResponse> result = categoryService.getAllCategories();

            // Assert
            assertThat(result).isEmpty();
        }
    }

    @Nested
    @DisplayName("getAllCategoriesWithCount")
    class GetAllCategoriesWithCount {

        @Test
        @DisplayName("should return all categories with count")
        void shouldReturnAllCategoriesWithCount() {
            // Arrange
            Category category2 = new Category();
            category2.setId(UUID.randomUUID());
            category2.setName("Backend");
            category2.setSortOrder(2);

            when(categoryRepository.findAllByOrderBySortOrderAsc())
                .thenReturn(List.of(testCategory, category2));
            when(categoryRepository.countKnowledgeSetsById(testCategory.getId()))
                .thenReturn(5L);
            when(categoryRepository.countKnowledgeSetsById(category2.getId()))
                .thenReturn(3L);

            // Act
            List<CategoryResponse> result = categoryService.getAllCategoriesWithCount();

            // Assert
            assertThat(result).hasSize(2);
            assertThat(result.get(0).name()).isEqualTo("Frontend");
            assertThat(result.get(0).count()).isEqualTo(5L);
            assertThat(result.get(1).name()).isEqualTo("Backend");
            assertThat(result.get(1).count()).isEqualTo(3L);
        }
    }

    @Nested
    @DisplayName("getCategoryById")
    class GetCategoryById {

        @Test
        @DisplayName("should return category when found")
        void shouldReturnCategoryWhenFound() {
            // Arrange
            when(categoryRepository.findById(categoryId))
                .thenReturn(Optional.of(testCategory));

            // Act
            CategoryResponse result = categoryService.getCategoryById(categoryId);

            // Assert
            assertThat(result.name()).isEqualTo("Frontend");
            assertThat(result.description()).isEqualTo("Frontend Development");
        }

        @Test
        @DisplayName("should throw NotFoundException when not found")
        void shouldThrowNotFoundException() {
            // Arrange
            when(categoryRepository.findById(categoryId))
                .thenReturn(Optional.empty());

            // Act & Assert
            assertThatThrownBy(() -> categoryService.getCategoryById(categoryId))
                .isInstanceOf(NotFoundException.class);
        }
    }
}
