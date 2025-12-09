# Contributing

## Prerequisites

- [mise](https://mise.jdx.dev/) for toolchain management
- macOS (uses Foundation/FileManager)

## Setup

```bash
git clone https://github.com/your-org/swift-md-bulk-renamer.git
cd swift-md-bulk-renamer
mise install
```

This installs the pinned Swift version from `mise.toml`.

## Commands

```bash
swift build          # compile library and CLI
swift test           # run all tests
swift run mvmd       # run CLI
mise r test          # run tests (mise task)
```

## Project Structure

```
Sources/
├── swift-md-bulk-renamer/   # Library
│   ├── Instruction.swift    # Rename pair with NonemptyString fields
│   ├── NonemptyString.swift # Non-empty string wrapper type
│   ├── Parser.swift         # Markdown table → [Instruction]
│   ├── Generator.swift      # [Instruction] → Markdown table
│   ├── PathValidation.swift # Path safety checks
│   ├── Planner.swift        # Conflict detection, dry-run
│   └── Executor.swift       # FileManager operations
└── mvmd/                    # CLI executable
    └── main.swift           # ArgumentParser command

Tests/
└── swift-md-bulk-renamer-tests/
    ├── NonemptyStringTests.swift
    ├── ParserTests.swift
    ├── PathValidationTests.swift
    ├── PlannerTests.swift
    ├── ExecutorTests.swift
    └── CLITests.swift
```

## Dependencies

| Package | Purpose |
|---------|---------|
| [swift-markdown](https://github.com/swiftlang/swift-markdown) | Parse Markdown tables |
| [swift-argument-parser](https://github.com/apple/swift-argument-parser) | CLI arguments |

## Code Style

- Indent with tabs
- Use Swift Testing framework
- Backtick test names:

```swift
@Test func `rejects absolute paths`() throws {
    #expect(throws: PathValidationError.absolutePath("/etc")) {
        try validatePath("/etc")
    }
}
```

## Architecture

**Data flow:**

1. **Parser** reads Markdown, extracts first 2-column table → `[Instruction]`
2. **PathValidation** checks each instruction for unsafe paths
3. **Planner** validates no conflicts, checks sources exist → `Plan`
4. **Executor** performs renames via FileManager

**Key types:**

- `NonemptyString` — wrapper ensuring non-empty, trimmed strings
- `Instruction` — rename pair (from: NonemptyString, to: NonemptyString)
- `Plan` — validated instructions ready to execute

## Testing

Tests use temp directories for filesystem operations. Each test cleans up after itself.

```bash
swift test                              # all tests
swift test --filter ParserTests         # specific suite
swift test --filter "rejects absolute"  # by name pattern
```
