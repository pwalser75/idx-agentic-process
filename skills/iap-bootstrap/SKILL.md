---
name: iap-bootstrap
description: >-
  BOOTSTRAP role of the idx Agentic Process, started by the `/bootstrap` command. Creates
  the `spec/` skeleton and empty `spec/input.md`, and installs the bundled UI references,
  screen workflow, test strategy and process copy under `spec/agent/`. Idempotent: it never
  clears input or overwrites project content. Use when the user runs /bootstrap, asks to
  "bootstrap", "set up the process", "initialize spec/", or starts using IAP in a new or
  existing project.
---

# BOOTSTRAP

You initialise the idx Agentic Process in a project. The commands and skills are already
installed by copying them into the project's agent folder; bootstrap owns only the `spec/`
setup and the bundled documents.

**Command:** `/bootstrap` · **Type:** SUBAGENT · **Invoked by:** HUMAN
**Precondition:** a project root. `spec/` may or may not exist; existing content is preserved.

## What bootstrap creates

- The `spec/` folder skeleton, with `.gitkeep` files in empty folders:
  `requirements/features/`, `requirements/domain-models/`,
  `requirements/user-interface/{screens,flows,components,data,assets}/`,
  `architecture/`, `tickets/` and `agent/`.
  It does **not** create `spec/modules/`; the project-shape interview creates that only for a
  multi-subproject project.
- An empty `spec/input.md` when missing. It never clears an existing input file.
- `spec/.gitignore` with `input.md` when missing; if the file exists, the entry is appended
  only when absent.
- `spec/agent/gui-spec.md` and `spec/agent/screen-workflow.md` — bundled normative references,
  refreshed on every run.
- `spec/agent/idx-agentic-process.md` — copy of the process definition, refreshed on every run.
- `spec/agent/process-version.md` — version and install marker, rewritten on every run.
- `spec/agent/test-strategy.md` — project-owned seed, created only when missing.

Everything else in `spec/` is generated on first use by the role that writes it: the input
ledger, ticket index, planning log, source ledger, reverse-engineering report, architecture
documents, requirements, screen documents, tickets and release notes.

## Procedure

1. **Run the bootstrap script from this skill.** Use the skill's `scripts/bootstrap.sh`. It
   locates `assets/` next to the skill or in the project/global agent folder, creates the
   skeleton and copies the documents. Run it from the project root:

   ```bash
   bash <skill-dir>/scripts/bootstrap.sh
   ```

2. **If the script cannot be found**, locate it in the installed skills folder:

   ```bash
   for d in \
     "$PWD/.opencode/skills/iap-bootstrap" \
     "$PWD/.claude/skills/iap-bootstrap" \
     "$HOME/.opencode/skills/iap-bootstrap" \
     "$HOME/.claude/skills/iap-bootstrap" \
     "$HOME/.config/opencode/skills/iap-bootstrap" \
     "$PWD/skills/iap-bootstrap"; do
     if [ -f "$d/scripts/bootstrap.sh" ]; then
       bash "$d/scripts/bootstrap.sh"
       exit 0
     fi
   done
   ```

3. **Report** the project root, the assets source, the version, whether `input.md` and
   `.gitignore` were created or preserved, the refreshed documents, whether
   `test-strategy.md` was created or preserved, and any legacy paths found or migrated.
   Finish with the next step: write statements into `spec/input.md`, then run `/facilitate`.

## Rules

- **Never overwrite project content.** Create missing files only. The bundled `gui-spec.md`,
  `screen-workflow.md`, `idx-agentic-process.md` and `process-version.md` are process-owned
  and are refreshed; `test-strategy.md` is project-owned and is never overwritten.
- **Never clear `input.md`.** If it exists, preserve it.
- **Never create requirements, architecture stubs, tickets or the input ledger.** Those are
  generated on first use by the role that owns them.
- **Do not create `spec/modules/`.** It exists only for a multi-subproject project and is
  created by the project-shape interview.
- **Report legacy paths, do not delete them** except the safe migrations the script performs
  (`architecture/test-strategy.md` -> `agent/test-strategy.md` when the new file is missing,
  and `design/prototype-builder.md` -> `architecture/prototype-builder.md`).

## Assets

The self-contained bundle lives in `skills/iap-bootstrap/assets/` and is copied with the
skills folder: `gui-spec.md`, `screen-workflow.md`, `test-strategy.md`,
`idx-agentic-process.md` and `VERSION`. No repository-root `references/` or `templates/`
folder is needed.

## Lessons learned

Read `spec/agent/lessons-learned-bootstrap.md` before working (create it if missing) and update
it before reporting. Keep entries short, dated and reusable; apply what fits, and never let a
lesson override the process or the project content. You may record a useful script in a
lesson, with its purpose and whether it writes anything.
