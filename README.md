# idx Agentic Process (IAP)

A human + agent development process for building software with AI agents, driven by a
set of slash commands and role-based agent skills.

The process keeps the **why** (requirements, constraints), the **what** (tickets) and the
**how** (architecture, code) in a single, reviewable `spec/` folder, and lets agents move
work forward in small, gated loops without ever silently overwriting what a human wrote.

> The canonical process definition lives in [idx-agentic-process.md](idx-agentic-process.md).
> It is **read-only for agents** and only ever changed by humans. Everything in this
> repository (skills, commands, templates) is derived from it.

---

## The idea in one picture

IAP runs development in **three loops**:

1. **Requirements loop** — the human states facts, expectations and constraints in
   `spec/input.md`; the agent (`/facilitate`) digests them into implementation-agnostic
   requirements and architecture documents.
2. **Planning loop** — agents (`/plan`, `/refine`) turn requirement and architecture
   changes into refined, actionable tickets.
3. **Implementation loop** — agents (`/implement`, `/review`) pick tickets, build, test
   and verify them; the human then merges and closes the review-accepted tickets
   (`/accept`).

## Highlights & principles

- **One source of truth per concern** — requirements are implementation-agnostic;
  architecture describes the non-functional reality; tickets log the work.
- **Explicit edit rights** — every artifact is marked **(H)** human-only, **(A)**
  agent-only or **(X)** co-owned. An agent editing an (H) file is a process violation.
- **Unstructured in, structured out** — the human writes free-form statements to
  `input.md`; the agent restructures them, and only then clears the input.
- **Append-only input ledger** — every accepted input is recorded with date, time and
  author in `spec/agent/input-ledger.md`, and never rewritten.
- **Tickets are the unit of work** — created and processed without human intervention,
  each with a type, status, task breakdown and acceptance criteria.
- **Human gates, not agent gates** — commands are invoked by humans; agents never
  invent requirements or push to `main` on their own.
- **Incremental & idempotent reverse-engineering** — existing codebases can be adopted
  via `/excavate` and `/survey`, writing *provisional* (`origin: inferred`) content with
  evidence rather than overwriting human knowledge.
- **Portable artifacts** — plain Markdown files in `spec/`, committed together with the
  code, readable by any agent or human.

## Artifacts and folder structure

Each entry is tagged with who may edit it: **(H)** human, **(A)** agent, **(X)** both.

```
project-root/
└─ spec/                        # Root folder of the process
   ├─ index.md                  # (X) Index file, describing the project
   ├─ input.md                  # (H) Human user input file, (A) clear the file
   ├─ requirements/             # (X) Requirements of this project
   │  ├─ domain-models/         # (X) Domain models
   │  │  └─ {model-name}.md     # (X) Domain model: name, attributes, descriptions
   │  ├─ features/              # (X) Features of the domain
   │  │  └─ {feature-name}.md   # (X) Feature: description and functionalities
   ├─ architecture/             # (X) Architectural design and requirements
   │  ├─ tech-stack.md          # (X) Languages, frameworks and libraries
   │  ├─ decomposition.md       # (X) Modules and packages
   │  ├─ coding-guidelines.md   # (X) Additional coding guidelines
   │  ├─ quality-aspects.md     # (X) Non-functional requirements
   │  └─ ...                    # (X) Additional guidelines
   ├─ tickets/                  # (A) Tickets for the implementation
   │  └─ {id}-{type}-{name}.md  # (A) A ticket with id, type and name
   └─ agent/                    # (A) Folder managed by the agent
      ├─ input-ledger.md        # (A) Append-only ledger of accepted input
      └─ ...                    # (A) Any documents created by the agent
```

## Tickets

A ticket is a Markdown file managed entirely by agents. It carries a type, a status,
a task breakdown and acceptance criteria, and it eventually logs the development of
the project.

```
# Title
TYPE:   {STORY | IMPROVEMENT | BUG}
STATUS: {DRAFT | READY | IN_PROGRESS | IN_REVIEW | DONE | CLOSED}
CREATED-ON: {ISO date-time}
UPDATED-ON: {ISO date-time}
---
{description, task breakdown (checkbox list), acceptance criteria}
---
{comments}
```

Statuses (see the source document for the full transition table): DRAFT (needs
refinement) → READY → IN_PROGRESS → IN_REVIEW → DONE (review-accepted) → CLOSED
(merged). A content change to a DRAFT/READY/IN_REVIEW/DONE ticket resets it to DRAFT.

```
DRAFT ──/refine──▶ READY ──/implement──▶ IN_PROGRESS ──(work done)──▶ IN_REVIEW
  ▲                  ▲                                                    │
  └── content edit ──┴──────────── /review (rework) ───────────────────── │
                                            /review (accept) ──▶ DONE ──/accept──▶ CLOSED
```

Priorities when picking work: **BUG > IMPROVEMENT > STORY**.

## Commands & roles

Commands are invoked by the human. Each role is implemented as an agent skill with its
own modus operandi; a command starts the matching role and hands it the work.

| Command        | Role / skill          | Precondition                                   | Purpose |
|----------------|-----------------------|------------------------------------------------|---------|
| `/bootstrap`   | `iap-bootstrap`       | project root (no `spec/` yet, else refresh)    | Install commands/skills and create the `spec/` skeleton |
| `/facilitate`  | `iap-facilitator`     | `input.md` exists and is not empty             | Digest human input into requirements & architecture |
| `/plan`        | `iap-planner`         | none                                           | Create/update tickets from requirement changes |
| `/refine`      | `iap-analyst`         | none                                           | Refine DRAFT tickets and promote them to READY |
| `/implement`   | `iap-implementor`     | at least one READY ticket                      | Claim the best READY ticket and implement it |
| `/review`      | `iap-reviewer`        | at least one IN_REVIEW ticket                  | Verify and accept (DONE) or send back tickets |
| `/accept`      | —                     | at least one DONE ticket                       | Merge the feature branch and close DONE tickets |
| `/excavate`    | `iap-archaeologist`   | `spec/` bootstrapped, project has source       | Reverse-engineer features & domain models |
| `/survey`      | `iap-system-architect`| `spec/` bootstrapped, project has source       | Reverse-engineer tech stack & architecture |
| `/tickets`     | —                     | `spec/` bootstrapped                           | Summary of open tickets and available commands |

The process definition itself is packaged as the `idx-agentic-process` skill, so an
agent that has it installed understands the whole process.

## Installation

IAP is used through your agent tool. It has two installable parts:

- **Skills** — one folder per role under [`skills/`](skills/), each with a `SKILL.md`
  (the open [Agent Skills](https://agentskills.io) standard), defining the roles and the
  process itself.
- **Commands** — one Markdown file per slash command under [`commands/`](commands/); each
  is a thin wrapper that starts the matching role.

IAP also ships a small, read-only helper, [`scripts/iap.sh`](scripts/iap.sh), which the
commands use to scan `spec/` in a single pass instead of opening every file. `/bootstrap`
installs it inside the project at `.iap/iap.sh` (e.g. `bash .iap/iap.sh open`,
`bash .iap/iap.sh list READY`, `bash .iap/iap.sh next`). Commit it so all collaborators
and cloud agents have it.

The `/bootstrap` command additionally needs the bundle (this repository: `templates/`,
`idx-agentic-process.md`, `VERSION`) so it can create `spec/` and record the version.
Point `IAP_HOME` at your clone:

```bash
git clone git@github.com:pwalser75/idx-agentic-process.git ~/idx-agentic-process
export IAP_HOME="$HOME/idx-agentic-process"    # add to your shell profile
```

You can install **globally** (once per machine, in every project) or **project-local**
(committed to the repository, so every collaborator and cloud agent gets it).
Project-local wins when both are present.

### Where each tool loads skills and commands

| Tool | Skills (project) | Skills (global) | Commands (project) | Commands (global) |
|---|---|---|---|---|
| OpenCode | `.opencode/skills/` | `~/.config/opencode/skills/` | `.opencode/commands/` | `~/.config/opencode/commands/` |
| Claude Code | `.claude/skills/` | `~/.claude/skills/` | `.claude/commands/` | `~/.claude/commands/` |
| GitHub Copilot | `.github/skills/` (also `.agents/skills/`, `.claude/skills/`) | `~/.copilot/skills/` (also `~/.agents/skills/`) | `.github/prompts/` (`*.prompt.md`) | user prompts (editor) |
| OpenAI Codex | `.agents/skills/` | `~/.agents/skills/` | `$CODEX_HOME/prompts/` (`~/.codex/prompts/`) | same |
| Cursor | `.cursor/skills/` (also `.agents/skills/`) | `~/.cursor/skills/` (also `~/.agents/skills/`) | — (skills are `/skill-name`) | — |

Every tool except Claude Code also reads the cross-tool `.agents/skills/` location, so a
single install there covers OpenCode, Copilot, Codex and Cursor at once; add
`.claude/skills/` for Claude Code. In tools where slash commands *are* skills (Claude Code,
Codex, Cursor, Copilot) the roles are invokable directly (`/iap-facilitator`,
`$iap-implementor`, …); the `commands/` wrappers (`/facilitate`) are mainly needed for
OpenCode.

### Global install

**OpenCode**

```bash
git clone git@github.com:pwalser75/idx-agentic-process.git ~/.config/opencode/iap
mkdir -p ~/.config/opencode/skills ~/.config/opencode/commands
ln -s ~/.config/opencode/iap/skills/*   ~/.config/opencode/skills/
ln -s ~/.config/opencode/iap/commands/* ~/.config/opencode/commands/
```

**Claude Code**

```bash
git clone git@github.com:pwalser75/idx-agentic-process.git ~/.claude/iap
mkdir -p ~/.claude/skills ~/.claude/commands
ln -s ~/.claude/iap/skills/*   ~/.claude/skills/
ln -s ~/.claude/iap/commands/* ~/.claude/commands/
```

**GitHub Copilot, OpenAI Codex, Cursor** (shared `.agents/skills/`)

```bash
mkdir -p ~/.agents/skills
ln -s ~/idx-agentic-process/skills/* ~/.agents/skills/
```

- Copilot also accepts personal skills in `~/.copilot/skills/`.
- Codex custom prompts (`/prompts:<name>`) go in `~/.codex/prompts/`.
- Cursor also accepts personal skills in `~/.cursor/skills/`.

### Project-local install

Commit these into the repository and every collaborator (and cloud agent) gets IAP:

```bash
REPO=~/idx-agentic-process

mkdir -p .agents/skills && cp -R "$REPO"/skills/* .agents/skills/            # OpenCode/Copilot/Codex/Cursor
mkdir -p .claude/skills && cp -R "$REPO"/skills/* .claude/skills/            # Claude Code
mkdir -p .opencode/commands && cp -R "$REPO"/commands/* .opencode/commands/  # OpenCode slash commands
```

For Copilot you can use the canonical `.github/skills/` (and `.github/prompts/*.prompt.md`
for prompts) instead of `.agents/`. On Windows, replace the symlinks/copies with
`mklink /D` or plain copies.

## Quick start

1. In your project, run the bootstrap command — assuming IAP is installed (see
   [Installation](#installation)) — which creates `spec/` if missing and installs this
   process's commands/skills into the project:

   ```
   /bootstrap
   ```

2. Describe your project in `spec/input.md`, then run:

   ```
   /facilitate
   ```

3. Repeat the requirements loop until the picture is stable. Then:

   ```
   /plan      # derive tickets from the requirements
   /refine    # promote well-defined tickets to READY
   /implement # claim and build the best READY ticket
   /review    # verify, then accept it to DONE
   /accept    # merge the branch and close the DONE tickets
   /tickets   # always see where you are
   ```

4. Commit `spec/` together with the code.

### Adopting an existing codebase

1. `/bootstrap` the process in the existing repository.
2. `/survey` and `/excavate` to reconstruct the architecture and requirements
   (repeat as the code changes).
3. Review the inferred documents, correct and accept them (requirements loop).
4. `/plan`, `/refine`, `/implement`, `/review` as usual.

## Repository layout

```
idx-agentic-process/
├─ README.md                    # this file
├─ .gitignore
├─ idx-agentic-process.md       # canonical process definition (read-only for agents)
├─ VERSION                      # IAP version (1.0.0)
├─ LICENSE                      # Apache License 2.0
├─ NOTICE                       # copyright notice
├─ skills/                      # agent skills (one folder per skill)
│  ├─ idx-agentic-process/      # the process overview skill
│  ├─ iap-bootstrap/
│  ├─ iap-facilitator/
│  ├─ iap-planner/
│  ├─ iap-analyst/
│  ├─ iap-implementor/
│  ├─ iap-reviewer/
│  ├─ iap-archaeologist/
│  └─ iap-system-architect/
├─ commands/                    # slash commands (opencode / Claude Code)
│  ├─ bootstrap.md  tickets.md
│  ├─ facilitate.md plan.md refine.md
│  └─ implement.md  review.md accept.md excavate.md survey.md
├─ scripts/
│  └─ iap.sh                    # read-only helper for fast spec/ scans
└─ templates/
   ├─ spec/                     # spec/ skeleton written by /bootstrap
   └─ input.md                  # template for spec/input.md (kept out of spec/)
```

## License

Licensed under the **Apache License, Version 2.0** — see [LICENSE](LICENSE).
Copyright 2026 Peter Walser.
