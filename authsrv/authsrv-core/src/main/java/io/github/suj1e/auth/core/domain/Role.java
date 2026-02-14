package io.github.suj1e.auth.core.domain;

import jakarta.persistence.*;
import java.time.Instant;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;
import com.nexora.datajp.support.BaseEntity;

/**
 * Role entity representing a user role/permission.
 *
 * @author sujie
 */
@Entity
@Table(name = "roles", indexes = {
    @Index(name = "idx_roles_name", columnList = "name", unique = true)
})
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Role extends BaseEntity {

    @Column(nullable = false, unique = true, length = 50)
    private String name;

    @Column(length = 200)
    private String description;

    /**
     * Factory method - Create a new role.
     */
    public static Role create(String name, String description) {
        validateName(name);

        Role role = new Role();
        role.name = name.startsWith("ROLE_") ? name : "ROLE_" + name.toUpperCase();
        role.description = description;
        return role;
    }

    /**
     * Factory method - Create standard user role.
     */
    public static Role createUserRole() {
        return create("ROLE_USER", "Standard user role");
    }

    /**
     * Factory method - Create admin role.
     */
    public static Role createAdminRole() {
        return create("ROLE_ADMIN", "Administrator role");
    }

    /**
     * Factory method - Create super admin role.
     */
    public static Role createSuperAdminRole() {
        return create("ROLE_SUPER_ADMIN", "Super administrator role");
    }

    private static void validateName(String name) {
        if (name == null || name.isBlank()) {
            throw new IllegalArgumentException("Role name cannot be blank");
        }
        if (name.length() > 50) {
            throw new IllegalArgumentException("Role name must not exceed 50 characters");
        }
    }
}
