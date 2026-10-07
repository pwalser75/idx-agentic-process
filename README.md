# idx Agentic Process (IAP)

A human + agent development process for building software with AI agents, driven by a set
of slash commands and role-based agent skills.

The process keeps the **why** (requirements, constraints), the **what** (tickets) and the
**how** (architecture, code) in a single, reviewable `spec/` folder, and lets agents move
work forward in small, gated loops without ever silently overwriting what a human wrote.

> The canonical process definition lives in [idx-agentic-process.md](idx-agentic-process.md).
> It is **read-only for agents** and only ever changed by humans. Everything in this
> repository (skills, commands, templates) is derived from it.

---

## The idea in one picture

IAP drives development iteratively:

1. **Requirements** — the human states facts, expectations and constraints in
   `spec/input.md`; the agent (`/facilitate`) digests them into implementation-agnostic
   requirements and architecture documents.
2. **Planning** — agents (`/plan`, `/refine`) turn requirement and architecture changes
   into refined, actionable tickets.
3. **Implementation** — agents (`/implement`) claim tickets, build and test them; the
   reviewer (`/review`) verifies and accepts them (DONE).
4. **Review / acceptance** — `/accept` updates the release notes, squashes, rebases and
   merges the feature branch, closing the ticket (CLOSED).

## Highlights & principles

- **One source of truth per concern** — requirements are implementation-agnostic;
  architecture describes the non-functional reality; tickets log the work.
- **Explicit edit rights** — every artifact is marked **(H)** human-only, **(A)**
  agent-only or **(X)** co-owned. An agent editing an (H) file is a process violation.
- **Unstructured in, structured out** — the human writes free-form statements to
  `input.md`; the agent restructures them, and only then clears the input.
- **Append-only input ledger** — every accepted input and every resolved clarification is
  recorded with date, time and author in `spec/agent/input-ledger.md`, and never rewritten.
- **Self-committing planning** — `/facilitate`, `/plan` and `/refine` commit their work on
  `main` automatically, one commit per run: `facilitate:`/`plan:`/`refine:` plus a short
  summary (single line, at most 200 characters).
- **Tickets are the unit of work** — each has an id, type, status, `acceptance-type`,
  optional `blocked-by`, a task breakdown and acceptance criteria.
- **Human gates, not agent gates** — commands are invoked by humans; agents never invent
  requirements, and implementation reaches `main` only through `/accept`.
- **Subagent roles** — specialised roles run in isolated contexts, so their work never
  pollutes the orchestrator; they return one concise report and never block on input.
- **Incremental & idempotent reverse-engineering** — existing codebases can be adopted via
  `/excavate` and `/survey`, writing *provisional* (`origin: inferred`) content with
  evidence rather than overwriting human knowledge.
- **Portable artifacts** — plain Markdown files in `spec/`, committed together with the
  code, readable by any agent or human.

## Artifacts and folder structure

Each entry is tagged with who may edit it: **(H)** human, **(A)** agent, **(X)** both.

```
project-root/
└─ spec/
   ├─ input.md                          # (X) Human writes input; agent only clears it
   ├─ release-notes.md                  # (X) Release notes (optional; created by /accept)
   ├─ requirements/                     # (X) Requirements of this project
   │  ├─ domain-models/{model-name}.md  # (X) Domain model: name, attributes, descriptions
   │  ├─ features/{feature-name}.md     # (X) Feature: description and functionalities
   ├─ architecture/                     # (X) Architectural design and requirements
   │  ├─ tech-stack.md                  # (X) Languages, frameworks and libraries
   │  ├─ decomposition.md               # (X) Modules and packages
   │  ├─ coding-guidelines.md           # (X) Additional coding guidelines
   │  ├─ quality-aspects.md             # (X) Non-functional requirements
   │  └─ ...                            # (X) Additional guidelines
   ├─ tickets/{id}-{type}-{name}.md     # (X) A ticket with id, type and name
   └─ agent/                            # (A) Folder managed by the agent
      ├─ input-ledger.md                # (A) Append-only seed: accepted input + clarifications
      ├─ ticket-index.md                # (A) Tickets <-> requirements/architecture links
      ├─ planning-log.md                # (A) Last-seen revision/hash of spec/
      ├─ source-ledger.md               # (A) Hash ledger of scanned sources
      ├─ reverse-engineering-report.md  # (A) Open questions from /excavate & /survey
      ├─ process-version.md             # (A) IAP version used
      └─ idx-agentic-process.md         # (A) Copy of the process definition
```

## Tickets

A ticket is a Markdown file named `{id}-{type}-{name}.md` under `spec/tickets/`, with YAML
front matter:

```markdown
---
id: 0007
created: 2026-10-07T12:00:00Z
type: STORY
status: DRAFT
acceptance-type: AUTOMATIC
blocked-by: 0005, 0006
---
# Title

## Description
{what and why; link the requirement(s)}

## Tasks
- [ ] {task}

## Acceptance criteria
- {verifiable outcome}

---

## Comments
```

**Metadata:** `id` (zero-padded, monotonic, never reused), `created` (ISO-8601), `type`,
`status`, `acceptance-type` (`AUTOMATIC` default | `HUMAN`), `blocked-by` (ids of blocking
tickets). The filename's `id`/`type` must match the front matter.

**Types:** `STORY` (functional increment) · `IMPROVEMENT` (non-functional change) · `BUG`.

**Statuses:** `DRAFT` → `READY` → `IN_PROGRESS` → `IN_REVIEW` → `DONE` → `CLOSED`.

```
DRAFT ──/refine──▶ READY ──/implement──▶ IN_PROGRESS ──(work done)──▶ IN_REVIEW
  ▲                  ▲                                                    │
  └── content edit ──┴──────────── /review (rework) ───────────────────── │
                                            /review (accept) ──▶ DONE ──/accept──▶ CLOSED
```

A non-metadata edit (Description, Tasks, Acceptance criteria, Comments) of a ticket in
DRAFT/READY/IN_REVIEW/DONE resets it to DRAFT. Setting `acceptance-type` or `blocked-by` is
a metadata edit and does not change the status.

Priorities when picking work: **BUG > IMPROVEMENT > STORY**.

## Commands & roles

Commands are invoked by humans. Each role is a skill; a command starts the matching skill.
A SUBAGENT role runs in an isolated context; the orchestrator selects the role, passes the
arguments and relays the result — it never does the role's work itself.

| Command        | Role / skill          | Type     | Precondition                                |
|----------------|-----------------------|----------|---------------------------------------------|
| `/bootstrap`   | `iap-bootstrap`       | —        | project root (no `spec/`, else refresh)     |
| `/facilitate`  | `iap-facilitator`     | PRIMARY  | `input.md` exists and is not empty          |
| `/plan`        | `iap-planner`         | SUBAGENT | none                                        |
| `/refine`      | `iap-analyst`         | SUBAGENT | none                                        |
| `/implement`   | `iap-implementor`     | SUBAGENT | ≥1 READY ticket, clean tree, on main        |
| `/review`      | `iap-reviewer`        | SUBAGENT | ≥1 IN_REVIEW ticket                         |
| `/accept`      | `iap-accept`          | —        | ≥1 DONE ticket (AUTOMATIC or HUMAN)         |
| `/tickets`     | `iap-tickets`         | —        | `spec/` bootstrapped                        |
| `/excavate`    | `iap-archaeologist`   | SUBAGENT | `spec/` bootstrapped, source present        |
| `/survey`      | `iap-system-architect`| SUBAGENT | `spec/` bootstrapped, source present        |
| `/guide`       | `iap-guide`           | SUBAGENT | none (read-only)                            |
| `/reconcile`   | `iap-reconciler`      | SUBAGENT | none (audit + safe repairs)                 |

The process definition itself is packaged as the `idx-agentic-process` skill, so an agent
that has it installed understands the whole process.

## Installation

IAP has two installable parts:

- **Skills** — one folder per role under [`skills/`](skills/), each with a `SKILL.md` (the
  open [Agent Skills](https://agentskills.io) standard), defining the roles and the
  process itself.
- **Commands** — one Markdown file per slash command under [`commands/`](commands/); each
  is a thin wrapper that starts the matching skill.

One helper is derived from the process and installed alongside: the read-only
[`scripts/iap.sh`](scripts/iap.sh), which the commands use to scan `spec/` in a single pass
instead of opening every file. `/bootstrap` installs it inside the project at `.iap/iap.sh`
(e.g. `bash .iap/iap.sh open`, `bash .iap/iap.sh list READY`, `bash .iap/iap.sh next`).
Commit it so all collaborators and cloud agents have it.

The `/bootstrap` command needs the bundle (this repository: `templates/`,
`idx-agentic-process.md`, `VERSION`) so it can create `spec/` and record the version. Point
`IAP_HOME` at your clone:

```bash
git clone git@github.com:pwalser75/idx-agentic-process.git ~/idx-agentic-process
export IAP_HOME="$HOME/idx-agentic-process"    # add to your shell profile
```

### Where each tool loads skills and commands

| Tool        | Project            | Global             |
|-------------|--------------------|--------------------|
| OpenCode    | `.opencode/`       | `~/.opencode/`     |
| Claude Code | `.claude/`         | `~/.claude/`       |

### Global install

```bash
# OpenCode
git clone git@github.com:pwalser75/idx-agentic-process.git ~/.opencode/iap
mkdir -p ~/.opencode/skills ~/.opencode/commands
ln -s ~/.opencode/iap/skills/*   ~/.opencode/skills/
ln -s ~/.opencode/iap/commands/* ~/.opencode/commands/

# Claude Code
git clone git@github.com:pwalser75/idx-agentic-process.git ~/.claude/iap
mkdir -p ~/.claude/skills ~/.claude/commands
ln -s ~/.claude/iap/skills/*   ~/.claude/skills/
ln -s ~/.claude/iap/commands/* ~/.claude/commands/
```

### Project-local install

Commit these into the repository and every collaborator (and cloud agent) gets IAP:

```bash
REPO=~/idx-agentic-process
mkdir -p .opencode/skills && cp -R "$REPO"/skills/*   .opencode/skills/    # OpenCode
mkdir -p .opencode/commands && cp -R "$REPO"/commands/* .opencode/commands/
# Claude Code: use .claude/skills/ and .claude/commands/ instead.
```

On Windows, replace the symlinks/copies with `mklink /D` or plain copies.

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
   /implement # work through READY, unblocked tickets
   /review    # verify and accept a ticket to DONE
   /accept    # update release notes, merge and close DONE tickets
   /tickets   # always see where you are
   /guide     # ask what to do next
   ```

4. Commit `spec/` together with the code.

### Adopting an existing codebase

1. `/bootstrap` the process in the existing repository.
2. `/survey` and `/excavate` to reconstruct the architecture and requirements (repeat as
   the code changes).
3. Review the inferred documents, correct and accept them (requirements loop).
4. `/plan`, `/refine`, `/implement`, `/review` and `/accept` as usual.

If anything gets inconsistent, run `/reconcile` to audit and safely repair it.

## Repository layout

```
idx-agentic-process/
├─ README.md                    # this file
├─ .gitignore
├─ idx-agentic-process.md       # canonical process definition (read-only for agents)
├─ VERSION                      # IAP version
├─ LICENSE                      # Apache License 2.0
├─ NOTICE                       # copyright notice
├─ skills/                      # agent skills (one folder per skill)
│  ├─ idx-agentic-process/      # the process overview skill
│  ├─ iap-bootstrap/  iap-facilitator/  iap-planner/  iap-analyst/
│  ├─ iap-implementor/  iap-reviewer/  iap-archaeologist/
│  ├─ iap-system-architect/  iap-guide/  iap-reconciler/
│  └─ iap-accept/  iap-tickets/
├─ commands/                    # slash commands
│  ├─ bootstrap.md  facilitate.md  plan.md  refine.md
│  ├─ implement.md  review.md  accept.md  tickets.md
│  └─ excavate.md  survey.md  guide.md  reconcile.md
├─ scripts/
│  └─ iap.sh                    # read-only helper for fast spec/ scans
└─ templates/
   ├─ spec/                     # spec/ skeleton written by /bootstrap
   └─ input.md                  # template for spec/input.md (kept out of spec/)
```

## License

Licensed under the **Apache License, Version 2.0** — see [LICENSE](LICENSE).
Copyright 2026 Peter Walser.
