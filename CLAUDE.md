# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands

```bash
swift build                      # compile library and mvmd executable
mise r test                      # run all tests
swift run mvmd --help            # inspect CLI options
swift run mvmd file.md           # dry-run with instruction file
swift run mvmd file.md --apply   # execute renames
```

Use `mise` for toolchain management (`mise.toml` pins Swift version).

## Architecture

**swift-md-bulk-renamer** is a library + CLI for batch file renames driven by Markdown tables.

```
Sources/
├── swift-md-bulk-renamer/   # Library: parsing, validation, execution APIs
└── mvmd/                    # CLI executable using swift-argument-parser

Tests/
└── swift-md-bulk-renamer-tests/  # Swift Testing framework tests
```

### Planned Library Modules
- **Instruction**: rename pair (original → new)
- **Parser**: Markdown table → `[Instruction]` with validation
- **Planner**: conflict detection, dry-run output
- **Executor**: performs renames via FileManager

### CLI Design
- `mvmd file.md` — dry-run by default
- `mvmd file.md --apply` — execute renames
- `--force` — allow overwrites
- Supports stdin when no file argument

## Safety Constraints

- Reject absolute paths, `..` escapes; Windows drive/UNC prefixes rejected on non-Windows only
- No overwrites unless `--force`
- Detect duplicate originals and conflicting destinations before any mutation
- Symlink policy must be explicit (avoid unintentional following)
- Fail-fast: no partial execution if validation fails

## Testing

Use Swift Testing framework with backtick test names:
```swift
@Test func `rejects absolute paths`() { ... }
```

Cover: parsing (valid/invalid tables), path validation, planner/executor behavior, CLI flows.
Use temp directories for filesystem tests; ensure failures leave state unchanged.
Indent with tabs; git pre-commit hooks will take care of fixing indentation.
