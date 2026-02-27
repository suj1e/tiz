package io.github.suj1e.auth.repository;

import io.github.suj1e.auth.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

/**
 * 用户仓库接口.
 */
@Repository
public interface UserRepository extends JpaRepository<User, UUID> {

    /**
     * 根据邮箱查找用户.
     */
    Optional<User> findByEmail(String email);

    /**
     * 检查邮箱是否存在.
     */
    boolean existsByEmail(String email);
}
