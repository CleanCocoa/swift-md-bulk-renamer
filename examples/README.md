# Example

Try mvmd on these demo files.

## Quick Start

```bash
# From repo root
swift build
cd examples

# Preview renames (dry-run)
../.build/debug/mvmd README.md

# Execute renames
../.build/debug/mvmd README.md --apply

# Reset demo files
git checkout .
```

## Rename Table

| From | To |
|------|-----|
| report_draft.txt | 2024-annual-report.txt |
| IMG_001.jpg | vacation/beach.jpg |
| notes.md | docs/meeting-notes.md |

This demonstrates:
- Simple rename (`report_draft.txt` → `2024-annual-report.txt`)
- Move into new subdirectory (`IMG_001.jpg` → `vacation/beach.jpg`)
- Move with path (`notes.md` → `docs/meeting-notes.md`)

Subdirectories are created automatically when needed.
