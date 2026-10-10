---
name: iap-bootstrap
description: >-
  BOOTSTRAP role of the idx Agentic Process, started by the `/bootstrap` command. Installs
  the IAP skills and their command wrappers into the project for the active tool (`.opencode/` or
  `.claude/`) and creates the `spec/` skeleton from the packaged templates, writing
  `spec/agent/process-version.md`. Never overwrites existing spec content and never
  invents requirements or tickets. Use when the user runs /bootstrap, or asks to
  "bootstrap", "set up the process", "initialize the spec folder", or adopt IAP in a new
  or existing project.
---

# BOOTSTRAP

Initialise the idx Agentic Process in a project: install the skills and their command
wrappers, create the `spec/` skeleton, and record the process version. It is also the upgrade
path — re-running bootstrap refreshes the process machinery **without touching project
content**.

**Command:** `/bootstrap` · **Invoked by:** HUMAN · **Precondition:** a project root;
`spec/` may or may not exist.

## Rules

- **Never overwrite existing content.** When creating `spec/`, create only files that are
  absent. `spec/requirements`, `spec/architecture`, `spec/tickets` and
  `spec/agent/input-ledger.md` are never touched, including on a refresh.
- On a refresh, only the skill and command definitions, the helper script, `spec/agent/process-version.md`
  and the `spec/agent/idx-agentic-process.md` copy are replaced.
- **Never create tickets, requirements or architecture** — those come from the human.
- Target the active tool: `.opencode/` for OpenCode, `.claude/` for Claude Code.

## 1. Locate the IAP bundle

The bundle is the `skills/` folder together with `idx-agentic-process.md` and `VERSION`.
Everything the process needs — every role skill, its command wrapper, its templates and
scripts — lives inside `skills/`. Find the first candidate that contains a real bundle and
set `IAP_HOME` (resolve symlinks physically, so a globally symlinked skill leads back to the
clone root):

```bash
PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
IAP_HOME=""
for c in \
  "${IAP_HOME:-}" \
  "$PROJECT_ROOT/.opencode/iap" \
  "$PROJECT_ROOT/.claude/iap" \
  "$HOME/.opencode/iap" \
  "$HOME/.claude/iap" \
  "$PROJECT_ROOT" ; do
  if [ -n "$c" ] && [ -f "$c/idx-agentic-process.md" ] && [ -d "$c/skills/iap-bootstrap" ]; then
    IAP_HOME="$(cd -P "$c" && pwd)"; break
  fi
done
echo "IAP_HOME=${IAP_HOME:-<not found>}"
```

If `IAP_HOME` is empty, create the minimal skeleton yourself (step 3 fallback), record the
marker with version `unknown`, and tell the human to install the skills and run `/bootstrap`
again.

## 2. Install commands, skills and the helper

Detect the active tool (an explicit `claude`/`opencode` argument wins; default OpenCode):

```bash
TOOL="opencode"
case "${ARGUMENTS:-}" in *claude*) TOOL="claude" ;; *opencode*) TOOL="opencode" ;; esac
if [ "$TOOL" = "opencode" ] \
   && [ ! -d "$PROJECT_ROOT/.opencode/skills/iap-bootstrap" ] \
   && [ ! -d "$HOME/.opencode/skills/iap-bootstrap" ] \
   && { [ -d "$HOME/.claude/skills/iap-bootstrap" ] || [ -d "$PROJECT_ROOT/.claude/skills/iap-bootstrap" ]; }; then
  TOOL="claude"
fi
if [ "$TOOL" = "claude" ]; then TOOL_DIR="$PROJECT_ROOT/.claude"; else TOOL_DIR="$PROJECT_ROOT/.opencode"; fi
```

Copy the whole `skills/` tree, then lift each skill's command wrapper out of its folder into
the tool's `commands/` folder (the wrapper is the top-level `*.md` next to `SKILL.md`):

```bash
mkdir -p "$TOOL_DIR/skills" "$TOOL_DIR/commands" "$TOOL_DIR/iap"
[ -d "$IAP_HOME/skills" ] && cp -R "$IAP_HOME/skills/." "$TOOL_DIR/skills/"

for d in "$TOOL_DIR"/skills/*/; do
  for f in "$d"*.md; do
    [ -f "$f" ] || continue
    [ "$(basename "$f")" = "SKILL.md" ] && continue
    cp "$f" "$TOOL_DIR/commands/$(basename "$f")"
  done
done

cp "$IAP_HOME/idx-agentic-process.md" "$TOOL_DIR/iap/idx-agentic-process.md"
cp "$IAP_HOME/VERSION"                "$TOOL_DIR/iap/VERSION"

# Read-only helper, installed at a tool-independent path: `bash .iap/iap.sh <subcommand>`.
if [ -n "$IAP_HOME" ] && [ -f "$IAP_HOME/skills/iap-tickets/scripts/iap.sh" ]; then
  mkdir -p "$PROJECT_ROOT/.iap"
  cp "$IAP_HOME/skills/iap-tickets/scripts/iap.sh" "$PROJECT_ROOT/.iap/iap.sh"
  chmod +x "$PROJECT_ROOT/.iap/iap.sh"
fi
```

Commit `.iap/iap.sh` so collaborators and cloud agents have it. The project `iap/` folder
keeps the process definition and version record next to the installed skills, so the bundle
stays discoverable for future `/bootstrap` runs.

## 3. Create the `spec/` skeleton

The spec skeleton is bundled in this skill (`templates/spec/`); the input template in the
facilitator skill (`iap-facilitator/templates/input.md`). Copy them without clobbering, then
create the empty input file:

```bash
if [ -n "$IAP_HOME" ]; then
  mkdir -p "$PROJECT_ROOT/spec"
  cp -Rn "$IAP_HOME/skills/iap-bootstrap/templates/spec/." "$PROJECT_ROOT/spec/"
  [ -f "$PROJECT_ROOT/spec/input.md" ] || \
    cp "$IAP_HOME/skills/iap-facilitator/templates/input.md" "$PROJECT_ROOT/spec/input.md"
fi
```

This creates an empty `spec/input.md`, `spec/.gitignore` (keeping `input.md` local-only),
`spec/requirements/{features,domain-models}/`, the architecture stubs (`tech-stack.md`,
`decomposition.md`, `coding-guidelines.md`, `quality-aspects.md`) plus the filled
`design-system.md` preset, `spec/tickets/` and `spec/agent/input-ledger.md`.
**Release notes are not created** — `/accept` creates them on the fly.

**Fallback** (only when `IAP_HOME` was not found): create those same files yourself.

## 4. Process copy and version marker

```bash
if [ -n "$IAP_HOME" ]; then
  cp "$IAP_HOME/idx-agentic-process.md" "$PROJECT_ROOT/spec/agent/idx-agentic-process.md"
  IAP_VERSION="$(cat "$IAP_HOME/VERSION" 2>/dev/null || echo unknown)"
else
  IAP_VERSION="unknown"
fi
NOW="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
cat > "$PROJECT_ROOT/spec/agent/process-version.md" <<EOF
# Process Version

- **IAP version:** \`$IAP_VERSION\`
- **Installed on:** $NOW
- **Source:** ${IAP_HOME:-unknown}
- **Process definition:** \`spec/agent/idx-agentic-process.md\`

To update: re-run \`/bootstrap\`. It refreshes only the skill and command definitions, the
\`.iap/iap.sh\` helper, this marker and the process-definition copy. The content of
\`spec/requirements\`, \`spec/architecture\`, \`spec/tickets\` and
\`spec/agent/input-ledger.md\` is never touched.
EOF
```

## 5. Report

Summarise: first bootstrap or refresh; the `IAP_HOME` and IAP version; the skills and their
command wrappers installed and the target tool folder; whether `.iap/iap.sh` was installed; the `spec/`
files created (and, on a refresh, what was left untouched); and the next step — write
statements into `spec/input.md`, then run `/facilitate`.
