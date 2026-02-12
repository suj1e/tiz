# JMH 基准测试

Java Microbenchmark Harness 用于精确的 Java 代码性能测试。

## 添加基准测试

1. 在此目录下创建 JMH 测试类
2. 使用 `@Benchmark` 注解标记测试方法
3. 运行: `./gradlew jmh`

## 示例

\`\`\`java
@State(Scope.Thread)
@BenchmarkMode(Mode.Throughput)
@OutputTimeUnit(TimeUnit.SECONDS)
public class FilterBenchmark {
    @Benchmark
    public void benchmarkFilter() {
        // 测试代码
    }
}
\`\`\`
