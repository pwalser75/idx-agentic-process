#!/usr/bin/env bash
#
# install.sh — install the idx Agentic Process (IAP) into a project.
#
# The installer copies the skills and commands into the project's agent folder (or links
# them into a global folder) and creates the missing parts of spec/ from the bundled
# templates. It never overwrites project content.
#
set -euo pipefail

SOURCE_DIR="$(cd -P -- "$(dirname -- "$0")" && pwd)"
TOOL=""
GLOBAL=0
PROJECT_DIR="."
WITH_SPEC=1

usage() {
  cat <<'EOF'
Install the idx Agentic Process (IAP) into a project.

Usage:
  ./install.sh [options] [PROJECT_DIR]

Options:
  --project DIR    Project to install into (default: current directory).
  --global         Install the skills and commands in ~/.opencode or ~/.claude instead of
                   in the project. spec/ still goes into the project.
  --tool TOOL      Agent tool: opencode (default) or claude. Detected when omitted.
  --no-spec        Do not create or refresh spec/.
  -h, --help       Show this help.

The installer never overwrites existing requirements, architecture, tickets or ledger
content. On an existing project it only adds missing files and refreshes the process
machinery (skills, commands, bundled references, process copy and version marker).
EOF
}

die() { echo "install.sh: $*" >&2; exit 1; }

while [ "$#" -gt 0 ]; do
  case "$1" in
    --project)
      [ "$#" -ge 2 ] || die "--project needs a directory"
      PROJECT_DIR="$2"; shift 2 ;;
    --global)
      GLOBAL=1; shift ;;
    --tool)
      [ "$#" -ge 2 ] || die "--tool needs a value (opencode or claude)"
      TOOL="$2"; shift 2 ;;
    --no-spec)
      WITH_SPEC=0; shift ;;
    -h|--help)
      usage; exit 0 ;;
    -*)
      die "unknown option '$1' (try --help)" ;;
    *)
      PROJECT_DIR="$1"; shift ;;
  esac
done

# --- Locate the bundle ------------------------------------------------------------------

for entry in idx-agentic-process.md VERSION skills commands templates/spec references; do
  [ -e "$SOURCE_DIR/$entry" ] || die "not an IAP bundle: missing '$entry' in $SOURCE_DIR"
done

[ -d "$PROJECT_DIR" ] || die "project directory not found: $PROJECT_DIR"
PROJECT_DIR="$(cd -P -- "$PROJECT_DIR" && pwd)"

# --- Detect the agent tool --------------------------------------------------------------

if [ -z "$TOOL" ]; then
  if [ "$GLOBAL" -eq 1 ]; then
    if [ -d "$HOME/.claude" ] && [ ! -d "$HOME/.opencode" ]; then
      TOOL="claude"
    else
      TOOL="opencode"
    fi
  elif [ -d "$PROJECT_DIR/.claude" ] && [ ! -d "$PROJECT_DIR/.opencode" ]; then
    TOOL="claude"
  elif [ -d "$PROJECT_DIR/.opencode" ]; then
    TOOL="opencode"
  elif [ -d "$HOME/.claude" ] && [ ! -d "$HOME/.opencode" ]; then
    TOOL="claude"
  else
    TOOL="opencode"
  fi
fi

case "$TOOL" in
  opencode|claude) ;;
  *) die "unknown tool '$TOOL' (use opencode or claude)" ;;
esac

if [ "$GLOBAL" -eq 1 ]; then
  TOOL_DIR="$HOME/.$TOOL"
  SCOPE="global"
else
  TOOL_DIR="$PROJECT_DIR/.$TOOL"
  SCOPE="project"
fi

# --- Helpers ----------------------------------------------------------------------------

# copy_missing SRC DEST — recursively copy files that do not exist in DEST yet.
copy_missing() {
  local src="$1" dest="$2" rel
  while IFS= read -r -d '' rel; do
    if [ -d "$src/$rel" ]; then
      mkdir -p "$dest/$rel"
    elif [ ! -e "$dest/$rel" ]; then
      mkdir -p "$dest/$(dirname "$rel")"
      cp -p "$src/$rel" "$dest/$rel"
    fi
  done < <(cd "$src" && find . -mindepth 1 -print0)
}

# refresh SRC DEST — copy a bundled file, replacing the previous version.
refresh() {
  local src="$1" dest="$2"
  mkdir -p "$(dirname "$dest")"
  cp -p "$src" "$dest"
}

# link_tree SRC DEST — replace each skill/command in DEST with a link to SRC.
link_tree() {
  local src="$1" dest="$2" item name
  mkdir -p "$dest"
  for item in "$src"/*; do
    [ -e "$item" ] || continue
    name="$(basename "$item")"
    rm -rf "$dest/$name"
    ln -s "$item" "$dest/$name"
  done
}

# --- Install the skills and commands ----------------------------------------------------

if [ "$GLOBAL" -eq 1 ]; then
  link_tree "$SOURCE_DIR/skills" "$TOOL_DIR/skills"
  link_tree "$SOURCE_DIR/commands" "$TOOL_DIR/commands"
else
  mkdir -p "$TOOL_DIR/skills" "$TOOL_DIR/commands"
  cp -R "$SOURCE_DIR/skills/." "$TOOL_DIR/skills/"
  cp -R "$SOURCE_DIR/commands/." "$TOOL_DIR/commands/"
fi

# Remove the retired bootstrap command/skill and the retired .iap/iap.sh helper from earlier
# installations.
rm -rf "$TOOL_DIR/skills/iap-bootstrap"
rm -f "$TOOL_DIR/commands/bootstrap.md"
rm -f "$PROJECT_DIR/.iap/iap.sh"
rmdir "$PROJECT_DIR/.iap" 2>/dev/null || true

# --- Create or refresh spec/ ------------------------------------------------------------

IAP_VERSION="$(cat "$SOURCE_DIR/VERSION" 2>/dev/null || echo unknown)"
SPEC_STATE="not touched (--no-spec)"
if [ "$WITH_SPEC" -eq 1 ]; then
  if [ -d "$PROJECT_DIR/spec" ]; then
    SPEC_STATE="refreshed at $PROJECT_DIR/spec"
  else
    SPEC_STATE="created at $PROJECT_DIR/spec"
  fi

  # The spec/ skeleton is created once and then owned by the project.
  mkdir -p "$PROJECT_DIR/spec"
  copy_missing "$SOURCE_DIR/templates/spec" "$PROJECT_DIR/spec"
  [ -f "$PROJECT_DIR/spec/input.md" ] || : > "$PROJECT_DIR/spec/input.md"

  # Bundled references are refreshed on upgrade.
  refresh "$SOURCE_DIR/references/gui-spec.md" \
    "$PROJECT_DIR/spec/architecture/gui-spec.md"
  refresh "$SOURCE_DIR/references/screen-workflow.md" \
    "$PROJECT_DIR/spec/architecture/screen-workflow.md"

  # Record the process version and keep a copy of the process definition.
  refresh "$SOURCE_DIR/idx-agentic-process.md" \
    "$PROJECT_DIR/spec/agent/idx-agentic-process.md"
  NOW="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  cat > "$PROJECT_DIR/spec/agent/process-version.md" <<EOF
# Process Version

<!-- (A) Agent-owned. Records which version of the idx Agentic Process is installed. -->

- **IAP version:** \`$IAP_VERSION\`
- **Installed on:** $NOW
- **Source:** $SOURCE_DIR
- **Process definition:** \`spec/agent/idx-agentic-process.md\`

To update, pull the distribution and re-run \`install.sh\`. It refreshes the command/skill
definitions, the bundled references, this marker and the process-definition copy. Existing
requirements, project architecture content, tickets and the input ledger are never touched.
EOF
fi

# --- Report -----------------------------------------------------------------------------

cat <<EOF
IAP $IAP_VERSION installed.
  Tool:      $TOOL ($SCOPE)
  Skills:    $TOOL_DIR/skills
  Commands:  $TOOL_DIR/commands
  Spec:      $SPEC_STATE
EOF

if [ "$WITH_SPEC" -eq 1 ]; then
  echo
  echo "Next: describe your project in spec/input.md, then run /facilitate."
fi

if ! git -C "$PROJECT_DIR" rev-parse --git-dir >/dev/null 2>&1; then
  echo
  echo "Note: $PROJECT_DIR is not a Git repository. IAP expects one; run 'git init' first."
fi
