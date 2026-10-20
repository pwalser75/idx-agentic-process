#!/usr/bin/env bash
#
# bootstrap.sh — create the IAP spec/ skeleton and install the bundled process documents.
#
# Idempotent and non-destructive:
#   - creates only missing files and directories;
#   - never clears spec/input.md or existing project content;
#   - refreshes the bundled references and the process copy;
#   - creates spec/agent/test-strategy.md only when it is missing (it is project-owned).
#
# Run from the project root (or any directory inside the project). The script finds the
# assets next to itself or in a project/global OpenCode or Claude Code skills folder.

set -euo pipefail

die() { echo "bootstrap: $*" >&2; exit 1; }

SCRIPT_DIR="$(cd -P -- "$(dirname -- "$0")" && pwd)"
SKILL_DIR="$(cd -P "$SCRIPT_DIR/.." && pwd)"
PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
SPEC="$PROJECT_ROOT/spec"

# --- Locate the bundled assets ----------------------------------------------------------

ASSETS=""
candidates=()
[ -n "${IAP_HOME:-}" ] && candidates+=("$IAP_HOME/skills/iap-bootstrap/assets")
candidates+=(
  "$SKILL_DIR/assets"
  "$PROJECT_ROOT/.opencode/skills/iap-bootstrap/assets"
  "$PROJECT_ROOT/.claude/skills/iap-bootstrap/assets"
  "$HOME/.opencode/skills/iap-bootstrap/assets"
  "$HOME/.claude/skills/iap-bootstrap/assets"
  "$HOME/.config/opencode/skills/iap-bootstrap/assets"
  "$PROJECT_ROOT/skills/iap-bootstrap/assets"
)
for c in "${candidates[@]}"; do
  if [ -f "$c/idx-agentic-process.md" ] && [ -f "$c/gui-spec.md" ] \
     && [ -f "$c/screen-workflow.md" ] && [ -f "$c/test-strategy.md" ]; then
    ASSETS="$(cd -P "$c" && pwd)"
    break
  fi
done
[ -n "$ASSETS" ] || die "could not find skills/iap-bootstrap/assets; copy the complete skills/ folder"

# --- Create the spec/ skeleton ----------------------------------------------------------

DIRS=(
  "$SPEC/requirements/features"
  "$SPEC/requirements/domain-models"
  "$SPEC/requirements/user-interface/screens"
  "$SPEC/requirements/user-interface/flows"
  "$SPEC/requirements/user-interface/components"
  "$SPEC/requirements/user-interface/data"
  "$SPEC/requirements/user-interface/assets"
  "$SPEC/architecture"
  "$SPEC/tickets"
  "$SPEC/agent"
)
for d in "${DIRS[@]}"; do
  mkdir -p "$d"
done

# Keep the documented empty folders in Git without seeding any spec content. spec/agent is
# populated below, so it gets no placeholder.
for d in "${DIRS[@]}"; do
  [ "$d" = "$SPEC/agent" ] && continue
  if [ -z "$(find "$d" -mindepth 1 -maxdepth 1 -print -quit)" ]; then
    : > "$d/.gitkeep"
  fi
done

INPUT_STATE="preserved"
if [ ! -e "$SPEC/input.md" ]; then
  : > "$SPEC/input.md"
  INPUT_STATE="created (empty)"
fi

GITIGNORE="$SPEC/.gitignore"
GITIGNORE_STATE="preserved"
if [ ! -e "$GITIGNORE" ]; then
  cat > "$GITIGNORE" <<'EOF'
# The human's input file is local-only. Each human keeps their own copy.
# Only the shared, append-only input ledger is committed.
input.md
EOF
  GITIGNORE_STATE="created"
elif ! grep -Eq '^/?input\.md$' "$GITIGNORE"; then
  printf '\n# The human input file is local-only.\ninput.md\n' >> "$GITIGNORE"
  GITIGNORE_STATE="updated"
fi

# --- Migrate old paths before seeding new ones -----------------------------------------

LEGACY=()
TEST_STRATEGY_MIGRATED=0
if [ -f "$SPEC/architecture/test-strategy.md" ] && [ ! -e "$SPEC/agent/test-strategy.md" ]; then
  mv "$SPEC/architecture/test-strategy.md" "$SPEC/agent/test-strategy.md"
  TEST_STRATEGY_MIGRATED=1
  LEGACY+=("moved architecture/test-strategy.md -> agent/test-strategy.md")
elif [ -f "$SPEC/architecture/test-strategy.md" ]; then
  LEGACY+=("kept architecture/test-strategy.md (agent/test-strategy.md already exists)")
fi

if [ -f "$SPEC/design/prototype-builder.md" ] && [ ! -e "$SPEC/architecture/prototype-builder.md" ]; then
  mv "$SPEC/design/prototype-builder.md" "$SPEC/architecture/prototype-builder.md"
  rmdir "$SPEC/design" 2>/dev/null || true
  LEGACY+=("moved design/prototype-builder.md -> architecture/prototype-builder.md")
fi

for f in gui-spec.md screen-workflow.md; do
  if [ -f "$SPEC/references/$f" ]; then
    LEGACY+=("legacy spec/references/$f found; the current copy is spec/agent/$f")
  fi
done
for f in gui-spec.md screen-workflow.md; do
  if [ -f "$SPEC/architecture/$f" ]; then
    LEGACY+=("legacy spec/architecture/$f found; the current copy is spec/agent/$f")
  fi
done

# --- Install the bundled documents -----------------------------------------------------

mkdir -p "$SPEC/agent"
cp -p "$ASSETS/gui-spec.md"          "$SPEC/agent/gui-spec.md"
cp -p "$ASSETS/screen-workflow.md"   "$SPEC/agent/screen-workflow.md"
cp -p "$ASSETS/idx-agentic-process.md" "$SPEC/agent/idx-agentic-process.md"

TEST_STRATEGY_STATE="preserved"
if [ "$TEST_STRATEGY_MIGRATED" = "1" ]; then
  TEST_STRATEGY_STATE="migrated from architecture/test-strategy.md"
fi
if [ ! -e "$SPEC/agent/test-strategy.md" ]; then
  cp -p "$ASSETS/test-strategy.md" "$SPEC/agent/test-strategy.md"
  TEST_STRATEGY_STATE="created"
fi

IAP_VERSION="$(cat "$ASSETS/VERSION" 2>/dev/null || echo unknown)"
NOW="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
cat > "$SPEC/agent/process-version.md" <<EOF
# Process Version

<!-- (A) Agent-owned. Records which version of the idx Agentic Process is installed. -->

- **IAP version:** \`$IAP_VERSION\`
- **Installed on:** $NOW
- **Source:** $ASSETS
- **Process definition:** \`spec/agent/idx-agentic-process.md\`

To update, replace the \`commands/\` and \`skills/\` folders and run \`/bootstrap\` again. It
refreshes the bundled references and the process copy, and creates \`test-strategy.md\` only
when it is missing. Existing requirements, architecture, tickets, screen documents and the
input ledger are never touched.
EOF

# --- Report ----------------------------------------------------------------------------

echo "IAP bootstrap complete."
echo "  Project:  $PROJECT_ROOT"
echo "  Assets:   $ASSETS"
echo "  Version:  $IAP_VERSION"
echo "  input.md: $INPUT_STATE"
echo "  .gitignore: $GITIGNORE_STATE"
echo "  test-strategy.md: $TEST_STRATEGY_STATE"
echo "  Refreshed: spec/agent/gui-spec.md, screen-workflow.md, idx-agentic-process.md"
echo "  Created:   spec/agent/process-version.md and the spec/ folder skeleton"
if [ "${#LEGACY[@]}" -gt 0 ]; then
  echo "  Legacy:"
  for item in "${LEGACY[@]}"; do
    echo "    - $item"
  done
fi
echo
echo "Next: write statements into spec/input.md, then run /facilitate."
