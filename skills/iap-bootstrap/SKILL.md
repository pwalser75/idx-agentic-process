---
name: iap-bootstrap
description: >-
  BOOTSTRAP role of the idx Agentic Process, started by the `/bootstrap` command.
  Installs the IAP commands/agent skills into the project for the active tool
  (`.opencode/`, `.claude/`, …) and creates the `spec/` skeleton from the packaged
  templates, writing `spec/agent/process-version.md`. Never overwrites existing spec
  content and never invents requirements or tickets. Use when the user runs
  /bootstrap, asks to "bootstrap", "set up the process", "initialize the spec folder",
  or adopts IAP in a new or existing project.
---

# BOOTSTRAP

You initialise the idx Agentic Process in a project: install the commands and skills
locally, create the `spec/` skeleton, and record the process version. You are also the
upgrade path — re-running bootstrap refreshes the process machinery **without touching
the project's content**.

**Command:** `/bootstrap` · **Precondition:** a project root; a `spec/` folder may or
may not already exist.

## Communication style

- Keep verbosity low: concise responses, minimal explanation.
- Plain English, no "agentish" filler or corporate lingo ("delve", "leverage", …).

## Rules

- **Never overwrite existing content.** When creating `spec/`, only create files that are
  absent. `spec/requirements`, `spec/architecture`, `spec/tickets` and
  `spec/agent/input-ledger.md` are never touched, including on a refresh.
- On a refresh, only the command/skill definitions, `spec/agent/process-version.md` and
  the `spec/agent/idx-agentic-process.md` copy are replaced.
- **Never create tickets, requirements or architecture** — those come from the human.
- Target the active tool: `.opencode/` for opencode (default), `.claude/` for Claude Code
  (when the human says so), otherwise the tool's documented skills/commands folder.

## 1. Locate the IAP bundle

The bundle is a directory containing `templates/spec/index.md`, `idx-agentic-process.md`
and `VERSION`. Find the first match and set `IAP_HOME` (resolve symlinks physically, so a
globally symlinked skill leads back to the clone root):

```bash
PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
ENV_IAP_HOME="${IAP_HOME:-}"
IAP_HOME=""
for c in \
  "$ENV_IAP_HOME" \
  "$PROJECT_ROOT/.opencode/iap" \
  "$PROJECT_ROOT/.claude/iap" \
  "${XDG_CONFIG_HOME:-$HOME/.config}/opencode/iap" \
  "$HOME/.claude/iap" \
  "$HOME/.config/opencode/skills/idx-agentic-process/../.." \
  "$HOME/.claude/skills/idx-agentic-process/../.." \
  "$PROJECT_ROOT" ; do
  if [ -n "$c" ] && [ -f "$c/templates/spec/index.md" ]; then
    IAP_HOME="$(cd -P "$c" && pwd)"; break
  fi
done
echo "IAP_HOME=${IAP_HOME:-<not found>}"
```

A candidate that also contains `skills/` and `commands/` (the clone root, or a
`iap/` symlink to it) is a **full source** and lets bootstrap refresh the command/skill
definitions. A project-local `iap/` folder that only carries `templates/`,
`idx-agentic-process.md` and `VERSION` supports creating the skeleton but not refreshing
the definitions — those are refreshed by re-running the install from the clone.

If `IAP_HOME` is empty: create the minimal skeleton yourself (step 3 fallback), record the
marker with an `unknown` version (step 4), and tell the human to install the
skills/commands (see `README.md`) and run `/bootstrap` again.

## 2. Install commands and skills into the project

Detect the active tool (an explicit `claude`/`opencode` in the human's arguments wins);
default to opencode when unclear:

```bash
# $ARGUMENTS = the extra arguments passed to /bootstrap (may be empty)
TOOL="opencode"
case "$ARGUMENTS" in *claude*) TOOL="claude" ;; *opencode*) TOOL="opencode" ;; esac
if [ "$TOOL" = "opencode" ] \
   && [ ! -d "$PROJECT_ROOT/.opencode/skills/iap-bootstrap" ] \
   && [ ! -d "$HOME/.config/opencode/skills/iap-bootstrap" ] \
   && { [ -d "$HOME/.claude/skills/iap-bootstrap" ] || [ -d "$PROJECT_ROOT/.claude/skills/iap-bootstrap" ]; }; then
  TOOL="claude"
fi
if [ "$TOOL" = "claude" ]; then TOOL_DIR="$PROJECT_ROOT/.claude"; else TOOL_DIR="$PROJECT_ROOT/.opencode"; fi
echo "TOOL=$TOOL TOOL_DIR=$TOOL_DIR"
```

Then install the bundle:

```bash
mkdir -p "$TOOL_DIR/skills" "$TOOL_DIR/commands" "$TOOL_DIR/iap/templates"
[ -d "$IAP_HOME/skills" ]   && cp -R "$IAP_HOME/skills/."   "$TOOL_DIR/skills/"
[ -d "$IAP_HOME/commands" ] && cp -R "$IAP_HOME/commands/." "$TOOL_DIR/commands/"
if [ "$IAP_HOME" != "$TOOL_DIR/iap" ]; then
  cp -R "$IAP_HOME/templates/."        "$TOOL_DIR/iap/templates/"
  cp "$IAP_HOME/idx-agentic-process.md" "$TOOL_DIR/iap/idx-agentic-process.md"
  cp "$IAP_HOME/VERSION"                "$TOOL_DIR/iap/VERSION"
  mkdir -p "$TOOL_DIR/iap/scripts"
  [ -d "$IAP_HOME/scripts" ] && cp -R "$IAP_HOME/scripts/." "$TOOL_DIR/iap/scripts/"
fi

# Read-only helper, installed at a tool-independent project path so every command
# can invoke it the same way: `bash .iap/iap.sh <subcommand>`.
if [ -n "$IAP_HOME" ] && [ -f "$IAP_HOME/scripts/iap.sh" ]; then
  mkdir -p "$PROJECT_ROOT/.iap"
  cp "$IAP_HOME/scripts/iap.sh" "$PROJECT_ROOT/.iap/iap.sh"
  chmod +x "$PROJECT_ROOT/.iap/iap.sh"
fi
```

The `[ -d ... ]` guards make the copies optional: a project-local, templates-only bundle
skips them (its skills/commands are already installed next to it). The
`IAP_HOME != TOOL_DIR/iap` guard avoids copying a bundle into itself, and using
`"$IAP_HOME/templates/."` (not `"$IAP_HOME/templates"`) avoids nesting
`templates/templates` on a refresh.

`scripts/iap.sh` is the shared, read-only helper the commands use for fast, single-pass
scans of `spec/`. It is copied into the project bundle (`$TOOL_DIR/iap/scripts/`) and
installed at the fixed, tool-independent path `.iap/iap.sh`. Commit `.iap/iap.sh` so
collaborators and cloud agents have it; a templates-only bundle without `scripts/` skips
it, in which case tell the human to re-run the install from the clone.

The project `iap/` folder keeps the bundle discoverable for future `/bootstrap` runs, so
creating the skeleton works offline.

## 3. Create the `spec/` skeleton

Copy the templates without clobbering existing files, then create the empty human input
file (it lives outside `spec/` in the bundle so that the spec `.gitignore` does not hide
it in the source repository):

```bash
if [ -n "$IAP_HOME" ]; then
  mkdir -p "$PROJECT_ROOT/spec"
  cp -Rn "$IAP_HOME/templates/spec/." "$PROJECT_ROOT/spec/"
  [ -f "$PROJECT_ROOT/spec/input.md" ] || cp "$IAP_HOME/templates/input.md" "$PROJECT_ROOT/spec/input.md"
fi
```

This creates `spec/index.md`, an empty `spec/input.md`, a `spec/.gitignore` (keeping
`input.md` local-only), `spec/requirements/{features,domain-models}/`, the four
architecture stubs, `spec/tickets/`, and `spec/agent/input-ledger.md`.

**Fallback** (only when `IAP_HOME` was not found): create those files yourself with the
same structure — `spec/index.md`, an empty `spec/input.md`, `spec/.gitignore` containing
`input.md`, the four architecture stubs, `spec/tickets/`, and
`spec/agent/input-ledger.md` with an "append-only" header comment.

## 4. Write the process marker and process-definition copy

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

To update: re-run \`/bootstrap\`. It refreshes only the command/skill definitions, the
\`.iap/iap.sh\` helper, this marker and the process-definition copy. The content of
\`spec/requirements\`, \`spec/architecture\`, \`spec/tickets\` and
\`spec/agent/input-ledger.md\` is never touched.
EOF
```

## 5. Report

Summarise:

- whether this was a **first bootstrap** or a **refresh**;
- the `IAP_HOME` used, whether it was a full source or a templates-only bundle, and the
  IAP version;
- the commands/skills installed and the target tool folder;
- whether `.iap/iap.sh` was installed (or skipped because the bundle had no `scripts/`);
- the `spec/` files created (and, on a refresh, what was intentionally left untouched);
- the next step: write statements into `spec/input.md`, then run `/facilitate`.
