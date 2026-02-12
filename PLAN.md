# PLAN - Tiz Repository Cleanup

## Project Overview
Clean up the tiz repository by optimizing .gitignore, removing unnecessary files, and consolidating ignore rules from subdirectories.

## Tasks

### Task 1: Optimize Root .gitignore
- [ ] Consolidate authsrv, gatewaysrv, and tiz-mobile .gitignore rules into root .gitignore
- [ ] Remove temporary directories patterns
- [ ] Verify rules are properly formatted
  - **Acceptance**: Single .gitignore at root covers all subdirectory needs

### Task 2: Repository-Wide Cleanup Audit
- [ ] Scan entire repository for files that shouldn't be committed
- [ ] Check for:
  - gradle-wrapper.jar files (should use gitignore or wrapper validation)
  - .nexdeck.yml files
  - Build artifacts
  - IDE temporary files
  - Large binaries (>50MB GitHub limit)
  - **Acceptance**: git status shows only tracked source files

### Task 3: Clean authsrv
- [ ] Remove .nexdeck.yml if present
- [ ] Ensure gradle-wrapper.jar is not committed (or add to gitignore)
  - **Acceptance**: authsrv directory clean

### Task 4: Clean gatewaysrv
- [ ] Ensure gradle-wrapper.jar is not committed (or add to gitignore)
  - **Acceptance**: gatewaysrv directory clean

## Notes
- Use `git status` to verify what's staged
- Use `git rm --cached` to remove accidentally committed files
- Common patterns to ignore: `build/`, `.gradle/`, `*.log`, `.DS_Store`

