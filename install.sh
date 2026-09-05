#!/usr/bin/env bash
set -euo pipefail

TARGET="$HOME/.claude/skills"
DRY_RUN=0

usage() {
  cat <<'EOF'
install.sh — symlink ProductFlow skills into an agent harness skills directory.

Usage:
  ./install.sh [--target DIR] [--dry-run]

Options:
  --target DIR   Skills directory to link into (default: $HOME/.claude/skills)
  --dry-run      Print what would be linked, change nothing
  -h, --help     Show this help
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    --target)
      [ $# -ge 2 ] || { echo "error: --target requires a directory" >&2; exit 2; }
      TARGET="$2"; shift 2 ;;
    --target=*)
      TARGET="${1#--target=}"; shift ;;
    --dry-run) DRY_RUN=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "error: unknown argument: $1" >&2; usage >&2; exit 2 ;;
  esac
done

ROOT="$(cd "$(dirname "$0")" && pwd)"
SRC="$ROOT/skills"

[ -d "$SRC" ] || { echo "error: no skills directory at $SRC" >&2; exit 1; }

if [ "$DRY_RUN" -eq 0 ]; then
  mkdir -p "$TARGET"
fi

SKIPPED=0
for dir in "$SRC"/*/; do
  [ -d "$dir" ] || continue
  name="$(basename "$dir")"
  src="$SRC/$name"
  dest="$TARGET/$name"
  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    echo "warn: $dest exists and is not a symlink — skipped"
    SKIPPED=1
    continue
  fi
  if [ "$DRY_RUN" -eq 1 ]; then
    echo "would link $dest -> $src"
  else
    ln -sfn "$src" "$dest"
    echo "linked $dest -> $src"
  fi
done

if [ "$SKIPPED" -eq 1 ]; then
  echo "one or more skills were skipped" >&2
  exit 1
fi
