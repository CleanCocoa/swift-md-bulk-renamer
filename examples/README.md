# Example

Try mvmd on these demo files.

## Quick Start

```bash
# From repo root
swift build

# Preview renames (dry-run)
swift run mvmd examples/README.md

# Execute renames
swift run mvmd examples/README.md --apply

# Reset demo files
git checkout examples/
```

## Rename Table

| From | To |
|------|-----|
| report_draft.txt | 2024-annual-report.txt |
| IMG_001.jpg | vacation/beach.jpg |
| notes.md | docs/meeting-notes.md |
| my notes (draft).txt | My Docs/Final Notes.txt |

This demonstrates:
- Simple rename (`report_draft.txt` → `2024-annual-report.txt`)
- Move into new subdirectory (`IMG_001.jpg` → `vacation/beach.jpg`)
- Move with path (`notes.md` → `docs/meeting-notes.md`)
- Spaces and special characters (`my notes (draft).txt` → `My Docs/Final Notes.txt`)

Subdirectories are created automatically when needed.
