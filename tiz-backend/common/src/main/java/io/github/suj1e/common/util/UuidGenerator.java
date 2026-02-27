package io.github.suj1e.common.util;

import java.security.SecureRandom;
import java.util.UUID;

/**
 * UUID 生成器.
 * 支持 UUID v7 (时间排序).
 */
public final class UuidGenerator {

    private static final SecureRandom RANDOM = new SecureRandom();

    private UuidGenerator() {
    }

    /**
     * 生成 UUID v7 (时间排序).
     * 格式: 时间戳(48bit) + 版本号(4bit) + 随机数(12bit) + 变体(2bit) + 随机数(62bit)
     */
    public static UUID v7() {
        long timestamp = System.currentTimeMillis();

        // 随机数
        long randomHi = RANDOM.nextInt() & 0xFFFFFFFFL;
        long randomLo = RANDOM.nextLong();

        // 时间戳部分 (48 bits) 放在 MSB 的高位
        long msb = (timestamp << 16) | (randomHi & 0x0FFFL);

        // 设置版本号为 7 (0111)
        msb = (msb & 0xFFFFFFFFFFFF0FFFL) | 0x0000000000007000L;

        // 设置变体为 10xx
        long lsb = (randomLo & 0x3FFFFFFFFFFFFFFFL) | 0x8000000000000000L;

        return new UUID(msb, lsb);
    }

    /**
     * 生成随机 UUID (v4).
     */
    public static UUID random() {
        return UUID.randomUUID();
    }
}
