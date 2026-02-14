# Tasks: Align authsrv with Panck Skill Standards

## 1. Gradle Build Files

- [x] 1.1 Update root `build.gradle.kts`: remove `java-library` plugin, simplify repositories
- [x] 1.2 Update `gradle/libs.versions.toml`: rename `flooc-nexora-starter` to `nexora`, update nexora modules to `io.github.suj1e`, add testcontainers, remove jib and spring-dependency-management plugins
- [x] 1.3 Update `authsrv-boot/build.gradle.kts`: remove `java-library` and jib plugin, add testcontainers dependencies
- [x] 1.4 Update `authsrv-core/build.gradle.kts`: remove redundant `java` plugin
- [x] 1.5 Update `authsrv-adapter/build.gradle.kts`: remove redundant `java` plugin
- [x] 1.6 Update `authsrv-api/build.gradle.kts`: remove redundant `java` plugin

## 2. Package Migration

- [x] 2.1 Update group in root `build.gradle.kts` from `com.nexora` to `io.github.suj1e`
- [x] 2.2 Migrate all Java packages from `com.nexora.auth` to `io.github.suj1e.auth`
- [x] 2.3 Update `logback-spring.xml` logger package references

## 3. Tooling

- [x] 3.1 Add `z.sh` script for zellij session management

## 4. Verification

- [ ] 4.1 Run `./gradlew clean build` to verify build succeeds
  - **Blocked**: Requires `io.github.suj1e:nexora-*` dependencies to be published
- [ ] 4.2 Run `./gradlew test` to verify tests pass
  - **Blocked**: Requires build to succeed first
