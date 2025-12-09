# Repository Guidelines

## Project Structure & Module Organization
- Package manifest: `Package.swift`.
- Library code: `Sources/swift-md-bulk-renamer/`.
- CLI entrypoint: `Sources/mvmd/main.swift`.
- Tests: `Tests/swift-md-bulk-renamer-tests/`.
- Plans and tasks: `PLAN.md`, `TODO.md`.

## Build, Test, and Development Commands
- `swift build` — compile library and `mvmd` executable.
- `swift test` — run unit/integration tests under `Tests/`.
- `swift run mvmd --help` — inspect CLI options (expected to use swift-argument-parser).
- `swift run mvmd instructions.md --apply` — run with a Markdown instruction file; omit `--apply` for dry-run.

## Coding Style & Naming Conventions
- Swift 6; prefer Foundation/FileManager for filesystem work.
- Use `swift-argument-parser` for CLI ergonomics; keep flags/subcommands minimal.
- 4-space indentation, descriptive type/variable names; snake_case only for module name as generated.
- Keep functions small and side-effect-aware; surface clear errors (including row numbers) from parsing/validation.

## Testing Guidelines
- Prefer Swift Testing in SPM targets; place tests in `Tests/swift-md-bulk-renamer-tests/`.
- Write behavior-focused tests with backticked names, e.g., `@Test func \`rejects absolute paths\`()`.
- Cover parsing (valid/invalid tables), path validation, planner/executor behavior, and CLI flows (dry-run/apply/force).
- Use temporary directories for filesystem tests; ensure failures leave state unchanged.

## Commit & Pull Request Guidelines
- Commits: lightweight conventional style `feat: ...`, `fix: ...`, `docs: ...`, `chore: ...`.
- PRs: describe intent, key changes, and testing performed; link issues; note any security-sensitive choices (path handling, overwrite policy).
- Add CLI examples in PRs when behavior changes (e.g., new flags/subcommands).

## Security & Safety Notes
- Forbid renames outside the working directory; reject absolute paths and escaping `..`.
- Decide and document symlink policy; avoid following symlinks unintentionally.
- Prevent overwrites unless `--force` is explicit; detect duplicate originals and conflicting destinations before mutating. 
