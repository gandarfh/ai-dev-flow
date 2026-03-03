#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

echo "ai-dev-flow uninstaller"
echo ""

unlink_file() {
  local src="$1"
  local dst="$2"
  local name
  name="$(basename "$dst")"

  if [ -L "$dst" ]; then
    local current
    current="$(readlink "$dst")"
    if [ "$current" = "$src" ]; then
      rm "$dst"
      echo "  removed $name"
      # restore backup if exists
      if [ -f "${dst}.bak" ]; then
        mv "${dst}.bak" "$dst"
        echo "  restored $name from backup"
      fi
      return
    fi
  fi
  echo "  skip   $name (not managed by ai-dev-flow)"
}

echo "agents:"
for f in "$REPO_DIR"/agents/*.md; do
  [ -f "$f" ] || continue
  unlink_file "$f" "$CLAUDE_DIR/agents/$(basename "$f")"
done

echo ""
echo "commands:"
for f in "$REPO_DIR"/commands/*.md; do
  [ -f "$f" ] || continue
  unlink_file "$f" "$CLAUDE_DIR/commands/$(basename "$f")"
done

echo ""
echo "CLAUDE.md:"
unlink_file "$REPO_DIR/.CLAUDE.md.rendered" "$CLAUDE_DIR/CLAUDE.md"

echo ""
echo "done."
