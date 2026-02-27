package io.github.suj1e.user.repository;

import io.github.suj1e.user.entity.UserSettings;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

/**
 * 用户设置仓库接口.
 */
@Repository
public interface UserSettingsRepository extends JpaRepository<UserSettings, UUID> {

    /**
     * 根据用户ID查找设置.
     */
    Optional<UserSettings> findByUserId(UUID userId);

    /**
     * 检查用户设置是否存在.
     */
    boolean existsByUserId(UUID userId);
}
