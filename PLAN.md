# Swift Markdown Bulk Renamer – Plan

## Goal
Build a reusable Swift library (`swift-md-bulk-renamer`) that parses Markdown tables describing rename operations (original → new) and executes safe batch renames. Ship a proof-of-concept CLI executable `mvmd` that uses the library to apply a table from stdin or a file.

## Scope & Behavior (initial thoughts)
- Input: Markdown table with two columns: `original`, `new`. All rows after header are rename instructions.
- The library should expose parsing + validation + execution APIs so GUI or other apps can orchestrate renames.
- The CLI should:
  - Accept an instruction source (stdin by default; optionally `--file <path>`).
  - Dry-run by default or behind a flag to show planned changes before applying.
  - Apply renames atomically per file (fail fast, report partial failures).

## Constraints / Safety
- Do **not** allow moving outside the working directory tree; reject absolute paths, leading `/`, Windows drive prefixes, UNC paths, or any path with `..` that escapes the root.
- Reject instructions that overwrite existing files unless explicitly allowed by a flag (`--force`).
- Detect duplicate `original` entries or conflicting `new` targets (two sources to same destination) and fail before mutating.
- Normalize/validate paths to avoid casing/Unicode normalization bugs on macOS.
- Consider symlink handling: either forbid renaming symlinks or make policy explicit; avoid following symlinks when resolving paths.
- Keep operations idempotent-friendly: no partial execution if parsing/validation fails.
- Handle whitespace trimming around Markdown cell content; reject empty names.
- Guard against CSV/Markdown injection when echoing content (avoid interpreting formulas if exported to spreadsheets).

## Testing Approach
- Unit tests:
  - Parse valid/invalid Markdown tables (missing headers, extra columns, malformed rows).
  - Path validation (absolute, `..`, duplicates, conflicting destinations, overwrite rules).
  - Execution logic: simulate file system in temp directories; ensure dry-run produces expected plan; ensure failures leave original state unchanged.
- CLI tests (integration-ish):
  - Feed stdin/file Markdown and assert outputs and filesystem changes in a temp directory.
  - Flags: dry-run vs apply, force overwrite behavior.

## MVP Implementation Notes
- Library modules:
  - `Instruction`: represents one rename pair.
  - `Parser`: parse Markdown table into `[Instruction]` with validation.
  - `Planner`: detects conflicts, computes operations, and dry-run output.
  - `Executor`: performs renames, reporting per-file results.
- CLI:
  - Simple argument parsing (could start with `ArgumentParser` if we add dependency later).
  - By default, read stdin; allow `--file` to read from a path; optional `--apply` to actually rename, otherwise dry-run.
  - Clear error messages and exit codes for parse/validation/IO errors.

## Open Questions
- Should we support Git-friendly output (e.g., generate `git mv` commands) or purely use `FileManager.moveItem`?
- Do we need to support Windows paths now, or macOS/Linux only?
- Should we handle case-only renames specially on case-insensitive filesystems?

## Next Steps
- Decide dependency policy (pure stdlib vs `swift-argument-parser`).
- Sketch data structures and validation rules.
- Implement parser + validator with fixtures.
- Build CLI wrapper and add integration tests. 
