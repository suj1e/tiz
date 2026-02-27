package io.github.suj1e.content.entity;

import io.github.suj1e.common.entity.BaseEntity;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

/**
 * 标签实体.
 */
@Getter
@Setter
@Entity
@Table(name = "tags")
public class Tag extends BaseEntity {

    @Column(name = "name", nullable = false, length = 50, unique = true)
    private String name;
}
