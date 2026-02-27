package io.github.suj1e.common.entity;

import jakarta.persistence.Column;
import jakarta.persistence.MappedSuperclass;
import lombok.Getter;
import lombok.Setter;
import org.hibernate.annotations.SQLDelete;
import org.hibernate.annotations.SQLRestriction;
import org.springframework.data.annotation.DeletedDate;

import java.time.Instant;

/**
 * 支持软删除的实体类.
 */
@Getter
@Setter
@MappedSuperclass
@SQLDelete(sql = "UPDATE ${table} SET deleted_at = NOW() WHERE id = ?")
@SQLRestriction("deleted_at IS NULL")
public abstract class SoftDeletableEntity extends BaseEntity {

    @DeletedDate
    @Column(name = "deleted_at")
    private Instant deletedAt;
}
