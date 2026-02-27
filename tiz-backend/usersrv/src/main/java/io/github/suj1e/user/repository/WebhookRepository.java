package io.github.suj1e.user.repository;

import io.github.suj1e.user.entity.Webhook;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

/**
 * Webhook 仓库接口.
 */
@Repository
public interface WebhookRepository extends JpaRepository<Webhook, UUID> {

    /**
     * 根据用户ID查找 Webhook.
     */
    Optional<Webhook> findByUserId(UUID userId);

    /**
     * 根据用户ID和启用状态查找 Webhook.
     */
    Optional<Webhook> findByUserIdAndEnabled(UUID userId, Boolean enabled);

    /**
     * 根据启用状态查找所有 Webhook.
     */
    List<Webhook> findByEnabled(Boolean enabled);

    /**
     * 检查用户是否已有 Webhook.
     */
    boolean existsByUserId(UUID userId);
}
