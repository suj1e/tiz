package io.github.suj1e.common.util;

import java.util.UUID;

/**
 * UUID 生成器.
 */
public final class UuidGenerator {

    private UuidGenerator() {
    }

    /**
     * 生成随机 UUID (v4).
     */
    public static UUID random() {
        return UUID.randomUUID();
    }
}
