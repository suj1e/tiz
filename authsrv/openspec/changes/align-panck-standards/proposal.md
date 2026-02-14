# Proposal: Align authsrv with Panck Skill Standards

## Why

authsrv was created before the panck skill was finalized. To maintain consistency across all Tiz platform microservices and ensure alignment with the established scaffold generation patterns, authsrv needs to be updated to match the panck skill standards.

## What Changes

- **Package migration**: `com.nexora` → `io.github.suj1e`
- **Gradle simplification**: Remove redundant plugins (java where java-library exists, jib, spring-dependency-management)
- **Dependency updates**: Update nexora starters to use `io.github.suj1e` group, add testcontainers
- **Build optimization**: Simplify repositories configuration
- **Tooling**: Add z.sh for zellij session management

## Capabilities

### Modified Capabilities

- `build-system`: Gradle configuration aligned with panck standards
- `package-structure`: Java packages use `io.github.suj1e` base

## Impact

- `build.gradle.kts` (root): Remove java-library, simplify repos
- `gradle/libs.versions.toml`: Update nexora modules, add testcontainers, remove jib
- `authsrv-boot/build.gradle.kts`: Remove java-library and jib, add testcontainers
- `authsrv-core/build.gradle.kts`: Remove redundant java plugin
- `authsrv-adapter/build.gradle.kts`: Remove redundant java plugin
- `authsrv-api/build.gradle.kts`: Remove redundant java plugin
- All Java files: Package rename from `com.nexora.auth` to `io.github.suj1e.auth`
- Add `z.sh`: Zellij session management script
