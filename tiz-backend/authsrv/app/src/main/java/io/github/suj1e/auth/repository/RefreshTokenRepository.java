package io.github.suj1e.auth.repository;

import io.github.suj1e.auth.entity.RefreshToken;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.time.Instant;
import java.util.Optional;
import java.util.UUID;

/**
 * 刷新令牌仓库接口.
 */
@Repository
public interface RefreshTokenRepository extends JpaRepository<RefreshToken, UUID> {

    /**
     * 根据令牌哈希查找刷新令牌.
     */
    Optional<RefreshToken> findByTokenHash(String tokenHash);

    /**
     * 撤销用户的所有刷新令牌.
     */
    @Modifying
    @Query("UPDATE RefreshToken rt SET rt.revoked = true WHERE rt.userId = :userId AND rt.revoked = false")
    void revokeAllByUserId(UUID userId);

    /**
     * 删除过期的刷新令牌.
     */
    @Modifying
    @Query("DELETE FROM RefreshToken rt WHERE rt.expiresAt < :now")
    void deleteExpiredTokens(Instant now);

    /**
     * 检查令牌哈希是否存在.
     */
    boolean existsByTokenHash(String tokenHash);
}
