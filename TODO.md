# TODO
- Use `swift-argument-parser` for CLI ergonomics.
- Define data structures: `Instruction`, `InstructionTable`, `Parser`, `Validator`, `Planner`, `Executor`, `Discoverer` (for `--create`/`create` scaffolding).
- Implement Markdown parser enforcing `original`/`new` headers, trimming cells, and surfacing row numbers for errors.
- Validate paths: forbid absolute paths and escaping `..`, reject symlinks per policy, detect duplicate originals and conflicting destinations, optional overwrite via `--force`.
- Plan/execute renames with dry-run support; handle case-only swaps safely on case-insensitive filesystems (temp names if needed).
- Design CLI UX: keep `mvmd file.md` as primary path; consider subcommands (`mv`, `create`) vs `--create` flag; support stdin fallback.
- Add unit/integration tests: parsing, validation, planner/executor with temp dirs; CLI flows for dry-run/apply/force and create scaffolding. 
