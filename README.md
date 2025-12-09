# mvmd

Batch file renamer driven by Markdown tables.

## Installation

```bash
git clone https://github.com/your-org/swift-md-bulk-renamer.git
cd swift-md-bulk-renamer
swift build -c release
```

The binary will be at `.build/release/mvmd`.

## Usage

Create a Markdown file with a rename table:

```markdown
| From | To |
|------|-----|
| old-name.txt | new-name.txt |
| report.pdf | 2024-report.pdf |
| src/utils.swift | src/helpers.swift |
```

Preview what would happen (dry-run):

```bash
mvmd renames.md
```

Execute the renames:

```bash
mvmd renames.md --apply
```

### Options

| Option | Description |
|--------|-------------|
| `--apply` | Execute renames (default is dry-run) |
| `--force` | Allow overwriting existing files |
| `-h, --help` | Show help |

### Reading from stdin

```bash
cat renames.md | mvmd
echo '| From | To |
|---|---|
| a.txt | b.txt |' | mvmd --apply
```

Or use `-` explicitly:

```bash
mvmd - < renames.md
```

## Table Format

- First 2-column table in the file is used
- Header row is required (any names work)
- Rows with empty "To" column are skipped
- Paths are relative to current directory

## Safety

mvmd validates all paths before any rename:

- Rejects absolute paths (`/etc/hosts`)
- Rejects parent escapes (`../secret.txt`)
- Rejects Windows paths (`C:\file.txt`, `\\server\share`)
- Rejects symlinks as sources
- Prevents overwrites unless `--force`
- Detects duplicate sources
- Detects conflicting destinations

If validation fails, no files are modified.

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | Error (parsing, validation, or execution failure) |
