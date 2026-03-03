#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

echo "ai-dev-flow installer"
echo "repo:   $REPO_DIR"
echo "target: $CLAUDE_DIR"
echo ""

mkdir -p "$CLAUDE_DIR/agents" "$CLAUDE_DIR/commands"

link_file() {
  local src="$1"
  local dst="$2"
  local name
  name="$(basename "$src")"

  if [ -L "$dst" ]; then
    local current
    current="$(readlink "$dst")"
    if [ "$current" = "$src" ]; then
      echo "  skip  $name (already linked)"
      return
    fi
    echo "  update $name (relink)"
    rm "$dst"
  elif [ -f "$dst" ]; then
    echo "  backup $name -> ${dst}.bak"
    mv "$dst" "${dst}.bak"
  else
    echo "  link  $name"
  fi

  ln -s "$src" "$dst"
}

# CLAUDE.md — replace template path placeholder before linking
CLAUDE_MD_SRC="$REPO_DIR/CLAUDE.md"
CLAUDE_MD_RENDERED="$REPO_DIR/.CLAUDE.md.rendered"

sed "s|~/gandarfh/ai-dev-flow|$REPO_DIR|g" "$CLAUDE_MD_SRC" > "$CLAUDE_MD_RENDERED"

echo "agents:"
for f in "$REPO_DIR"/agents/*.md; do
  [ -f "$f" ] || continue
  link_file "$f" "$CLAUDE_DIR/agents/$(basename "$f")"
done

echo ""
echo "commands:"
for f in "$REPO_DIR"/commands/*.md; do
  [ -f "$f" ] || continue
  link_file "$f" "$CLAUDE_DIR/commands/$(basename "$f")"
done

echo ""
echo "CLAUDE.md:"
link_file "$CLAUDE_MD_RENDERED" "$CLAUDE_DIR/CLAUDE.md"

echo ""
echo "done. restart claude code to pick up changes."
