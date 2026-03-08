package io.github.suj1e.auth.entity;

import io.github.suj1e.common.entity.BaseEntity;
import jakarta.persistence.*;
import lombok.*;

/**
 * 用户实体.
 */
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Entity
@Table(name = "users")
public class User extends BaseEntity {

    @Column(name = "email", nullable = false, unique = true)
    private String email;

    @Column(name = "password_hash", nullable = false)
    private String passwordHash;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false)
    @Builder.Default
    private UserStatus status = UserStatus.ACTIVE;

    /**
     * 用户状态枚举.
     */
    public enum UserStatus {
        ACTIVE,
        INACTIVE,
        BANNED
    }
}
