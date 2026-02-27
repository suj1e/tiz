package io.github.suj1e.content.service;

import io.github.suj1e.content.dto.TagResponse;
import io.github.suj1e.content.entity.Tag;
import io.github.suj1e.content.repository.TagRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * 标签服务.
 */
@Service
@RequiredArgsConstructor
public class TagService {

    private final TagRepository tagRepository;

    /**
     * 获取所有标签.
     */
    @Transactional(readOnly = true)
    public List<TagResponse> getAllTags() {
        return tagRepository.findAllByOrderByNameAsc()
            .stream()
            .map(this::toResponse)
            .toList();
    }

    /**
     * 根据名称列表获取或创建标签.
     */
    @Transactional
    public List<Tag> getOrCreateTags(List<String> tagNames) {
        if (tagNames == null || tagNames.isEmpty()) {
            return List.of();
        }

        return tagNames.stream()
            .map(name -> tagRepository.findByName(name)
                .orElseGet(() -> {
                    Tag tag = new Tag();
                    tag.setName(name);
                    return tagRepository.save(tag);
                }))
            .toList();
    }

    /**
     * 根据名称列表查找标签.
     */
    @Transactional(readOnly = true)
    public List<Tag> findTagsByNames(List<String> tagNames) {
        if (tagNames == null || tagNames.isEmpty()) {
            return List.of();
        }
        return tagRepository.findByNameIn(tagNames);
    }

    private TagResponse toResponse(Tag tag) {
        return new TagResponse(tag.getId(), tag.getName());
    }
}
