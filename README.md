# idx Agentic Process (IAP)

A human + agent development process for building software with AI agents, driven by a set
of slash commands and role-based agent skills.

The process keeps the **why** (requirements, constraints), the **what** (tickets) and the
**how** (architecture, code) in a single, reviewable `spec/` folder, and lets agents move
work forward in small, gated loops without ever silently overwriting what a human wrote.

> The canonical process definition lives in [idx-agentic-process.md](idx-agentic-process.md).
> It is **read-only for agents** and only ever changed by humans. Everything in this
> repository (skills, commands, templates, references) is derived from it.

---

## The idea in one picture

IAP drives development iteratively:

1. **Requirements** — the human states facts, expectations and constraints in
   `spec/input.md`; the agent (`/facilitate`) digests them into implementation-agnostic
   requirements and architecture documents.
2. **Planning** — agents (`/plan`, `/refine`) turn requirement and architecture changes
   into refined, actionable tickets. Where a gap or an impediment needs a human decision
   (a missing requirement, a technology or implementation choice, a blocker), they state it,
   advise on the options and ask for clearance before continuing.
3. **Implementation** — agents (`/implement`) claim tickets, build and test them; the
   reviewer (`/review`) verifies and accepts them (DONE). The orchestrator drives
   implement → review → accept as one loop, closing AUTOMATIC tickets — including the merge
   (`/accept`) — until no workable ticket remains or it gets stuck.
4. **Review / acceptance** — `/accept` updates the release notes, squashes, rebases and
   merges the feature branch, closing the ticket (CLOSED).

## Highlights & principles

- **Project shape before planning** — a single-subproject project records its artifact kind and
  tech stack in `architecture/tech-stack.md`; a project with more than one subproject gets a
  module per artifact. The agent interviews the human and proposes options; `/plan` waits until
  the shape is `agreed`.
- **One source of truth per concern** — requirements are implementation-agnostic;
  architecture describes the non-functional reality; tickets log the work.
- **Explicit edit rights** — every artifact is marked **(H)** human-only, **(A)**
  agent-only or **(X)** co-owned. An agent editing an (H) file is a process violation.
- **Unstructured in, structured out** — the human writes free-form statements to
  `input.md`; the agent restructures them, and only then clears the input.
- **Append-only input ledger** — every accepted input and every resolved clarification is
  recorded with date, time and author in `spec/agent/input-ledger.md`, and never rewritten.
  Entries are ticket-agnostic and implementation-agnostic — plain facts/requirements/decisions
  that drive the tickets and code downstream, never referencing them.
- **Self-committing planning** — `/facilitate`, `/plan` and `/refine` commit their work on
  `main` automatically, one commit per run: `facilitate:`/`plan:`/`refine:` plus a short
  summary (single line, at most 200 characters).
- **Tickets are the unit of work** — each has an id, type, status, `acceptance-type`,
  optional `blocked-by`, a task breakdown and acceptance criteria.
- **Human gates, not agent gates** — commands are invoked by humans; agents never invent
  requirements, and implementation reaches `main` only through `/accept`.
- **Ask before you assume** — no agent guesses past a gap or impediment. `/plan`, `/refine`
  and `/review` ask interview-style: numbered questions, options with trade-offs, and a
  recommendation. The durable decision is recorded in the input ledger and noted on the
  affected ticket before the agent continues; open review questions stay on the ticket until
  answered.
- **Implement until stuck** — the orchestrator runs `implement → review → accept` as a single
  loop, fully closing AUTOMATIC tickets (merge included) and pausing only for HUMAN
  acceptance or a decision that needs a human.
- **Subagent roles** — specialised roles run in isolated contexts, so their work never
  pollutes the orchestrator; they return one concise report and never block on input.
- **Context-aware** — every role starts fresh and reports are bounded. Long work checkpoints
  to disk (ticket comments, branches, screen documents) and resumes in a new context; the
  orchestrator compacts at durability barriers such as after `/accept`.
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
   │  └─ user-interface/                # (X) UI requirements: no implementation, no bundled refs
   │     ├─ screens/{screen-name}.md    # (X) Screen document (gui-v2) + data, actions, states
   │     ├─ flows/{flow-name}.md        # (X) Multi-screen journeys
   │     ├─ theme.gui                   # (X) Project theme and token overrides
   │     ├─ components/components.gui   # (X) Project-defined extended components
   │     ├─ assets/{file}               # (X) design assets referenced by screens (images, review photos)
   │     └─ data/{screen-name}.json     # (X) Example data and scenarios
   ├─ architecture/                     # (X) Architectural design and requirements
   │  ├─ tech-stack.md                  # (X) Single-subproject shape: artifact kind + stack
   │  ├─ integration.md                 # (X) Integration with other systems, APIs
   │  ├─ decomposition.md               # (X) Module map (multi) or package map (single)
   │  ├─ coding-guidelines.md           # (X) Additional coding guidelines
   │  ├─ quality-aspects.md             # (X) Non-functional requirements
   │  ├─ prototype-builder.md           # (X) Prototype-builder contract (tooling, not a requirement)
   │  └─ ...                            # (X) Additional guidelines
   ├─ modules/                          # (X) Only when the project has >1 subproject
   │  └─ {module}/
   │     ├─ module.md                   # (X) Artifact kind, purpose, boundaries, dependencies, status
   │     └─ tech-stack.md               # (X) Language/version, frameworks, runtime, tooling
   ├─ tickets/{id}-{type}-{name}.md     # (X) A ticket with id, type and name
   └─ agent/                            # (A) Agent-managed folder; test-strategy is (X)
      ├─ input-ledger.md                # (A) Append-only seed: accepted input + clarifications
      ├─ ticket-index.md                # (A) Tickets <-> requirements/architecture links
      ├─ planning-log.md                # (A) Last-seen revision/hash of spec/
      ├─ source-ledger.md               # (A) Hash ledger of scanned sources
      ├─ reverse-engineering-report.md  # (A) Open questions from /excavate & /survey
      ├─ lessons-learned-{role}.md      # (A) Reusable lessons for one role
      ├─ gui-spec.md                    # (A) Bundled gui-v2 format and UI design guide (never edit)
      ├─ screen-workflow.md             # (A) Bundled screen authoring/review workflow (never edit)
      ├─ test-strategy.md               # (X) Project-owned test levels and coverage (from /bootstrap)
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

`## Comments` is an append-only running log while the ticket is open; it carries dated
clarifications from `/plan`, `/refine`, `/implement` and `/review`, plus human answers. Review
questions and answers use stable `RQ` ids, so a later `/review` resumes them instead of
re-asking. When `/accept` closes the ticket, it replaces the log with a concise post-merge
summary that keeps only information still useful after the merge.

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

A scope-changing edit (Description, Tasks or Acceptance criteria) of a ticket in
DRAFT/READY/IN_REVIEW/DONE resets it to DRAFT. Dated workflow notes and human answers in
`## Comments` do not reset the status; a comment that changes scope or requirements does.
Setting `acceptance-type` or `blocked-by` is a metadata edit and does not change the status.

`/review` may append review questions and answers to a ticket's comments while leaving it
`IN_REVIEW`; the review resumes from those questions on the next invocation.

Priorities when picking work: **BUG > IMPROVEMENT > STORY**.

## Commands & roles

Commands are invoked by humans. Each role is a skill; a command starts the matching skill.
A SUBAGENT role runs in an isolated context; the orchestrator selects the role, passes the
arguments and relays the result — it never does the role's work itself. Each role invocation
starts in a fresh context, and an implementor handles one ticket per invocation. The
orchestrator keeps its own context thin, long roles checkpoint to disk, and the session is
compacted at durability barriers (after `/accept`, or after a planning/design commit).

| Command        | Role / skill          | Type     | Precondition                                |
|----------------|-----------------------|----------|---------------------------------------------|
| `/bootstrap`   | `iap-bootstrap`       | SUBAGENT | project root; may be run on an existing spec |
| `/facilitate`  | `iap-facilitator`     | PRIMARY  | input non-empty or shape unsettled          |
| `/design`      | `iap-designer`        | SUBAGENT | shape `agreed`, UI project                  |
| `/plan`        | `iap-planner`         | SUBAGENT | project shape `agreed`                      |
| `/refine`      | `iap-analyst`         | SUBAGENT | none                                        |
| `/implement`   | `iap-implementor`     | SUBAGENT | ≥1 READY ticket, clean tree, on main        |
| `/review`      | `iap-reviewer`        | SUBAGENT | ≥1 IN_REVIEW ticket                         |
| `/accept`      | `iap-accept`          | —        | ≥1 DONE ticket (AUTOMATIC or HUMAN)         |
| `/tickets`     | `iap-tickets`         | —        | `spec/` installed                           |
| `/excavate`    | `iap-archaeologist`   | SUBAGENT | `spec/` installed, source present           |
| `/survey`      | `iap-system-architect`| SUBAGENT | `spec/` installed, source present           |
| `/guide`       | `iap-guide`           | SUBAGENT | none (read-only)                            |
| `/reconcile`   | `iap-reconciler`      | SUBAGENT | none (audit + safe repairs)                 |

The process definition itself is packaged as the `idx-agentic-process` skill, so an agent
that has it installed understands the whole process. `/accept` is mechanical and
context-heavy: when the orchestrator invokes it, run it in a fresh isolated context; the
human may run it directly.

## Installation

IAP ships as two self-contained folders: [`skills/`](skills/) (one folder per role, each with
a `SKILL.md` per the open [Agent Skills](https://agentskills.io) standard) and
[`commands/`](commands/) (one thin wrapper per slash command). Everything the process needs at
runtime is inside them — role logic, templates, scripts and the [`/bootstrap`](commands/bootstrap.md)
assets under `skills/iap-bootstrap/assets/`. There is no installer and no repository-root
`templates/` or `references/` folder to copy.

### Requirements

- **Git** — IAP tracks requirements, tickets and code in one repository.
- **Bash** — the `/bootstrap` script and the read-only scripts embedded in the agent skills
  are bash.
- **An agent tool** with skills and slash commands: **OpenCode** or **Claude Code**.

### Download the process

Clone the repository once and keep it; pulling it is how you upgrade:

```bash
git clone https://github.com/pwalser75/idx-agentic-process.git ~/idx-agentic-process
```

You can also download a ZIP from GitHub; the commands below assume the folder
`~/idx-agentic-process`.

### Install into a new or existing project

Copy the two folders into the project's agent folder, then run `/bootstrap` once from the
project. This example is a **project-local install** for OpenCode; use `.claude` for Claude
Code:

```bash
cd ~/code/my-project
mkdir -p .opencode/commands .opencode/skills
cp -R ~/idx-agentic-process/commands/. .opencode/commands/
cp -R ~/idx-agentic-process/skills/. .opencode/skills/
```

Then, in the project, run:

```text
/bootstrap
```

Commit `.opencode/` or `.claude/` and `spec/` (except the local-only `spec/input.md`), so
collaborators and cloud agents have the same commands, skills and process documents.

`/bootstrap`:

- creates the `spec/` folder skeleton, with `.gitkeep` files in empty folders;
- creates an empty `spec/input.md` when missing and never clears an existing one;
- creates `spec/.gitignore` with `input.md` when missing;
- copies `gui-spec.md`, `screen-workflow.md`, `test-strategy.md`,
  `idx-agentic-process.md` and `process-version.md` into `spec/agent/`.

It creates `test-strategy.md` only when missing; the bundled `gui-spec.md`,
`screen-workflow.md`, process copy and version marker are refreshed. It does not create
`architecture/tech-stack.md`, `spec/modules/`, requirements, tickets or the input ledger:
those are generated on first use by the role that owns them.

### Global install

Copy the same two folders into the global agent folder once. For OpenCode:

```bash
mkdir -p ~/.opencode/commands ~/.opencode/skills
cp -R ~/idx-agentic-process/commands/. ~/.opencode/commands/
cp -R ~/idx-agentic-process/skills/. ~/.opencode/skills/
```

Use `~/.claude` for Claude Code. `/bootstrap` still runs in each project and creates that
project's `spec/`; it finds its assets in the global skills folder. Keep the
`~/idx-agentic-process` clone for upgrades.

### Upgrading

```bash
cd ~/idx-agentic-process
git pull

# copy commands/ and skills/ into the project again (or into ~/.opencode / ~/.claude)
cd ~/code/my-project
mkdir -p .opencode/commands .opencode/skills
cp -R ~/idx-agentic-process/commands/. .opencode/commands/
cp -R ~/idx-agentic-process/skills/. .opencode/skills/
```

Then run `/bootstrap` in the project. It refreshes the bundled references
(`spec/agent/gui-spec.md`, `spec/agent/screen-workflow.md`), the process copy
(`spec/agent/idx-agentic-process.md`) and the version marker. It creates
`spec/agent/test-strategy.md` only when it is missing, and never touches your requirements,
project architecture content, tickets, screen documents or input ledger. If a process change
alters ticket metadata or statuses, run `/reconcile` afterwards.

`/bootstrap` reports legacy paths such as `spec/references/` and old bundled reference copies;
it does not delete them. Remove them after verifying the `spec/agent/` copies.

### Removing IAP

Delete the IAP `skills/` and `commands/` from the project's tool folder (`.opencode/` or
`.claude/`), then delete `spec/` if you no longer want the process. For a global install,
remove the IAP skill and command folders from `~/.opencode` (or `~/.claude`).

## Quick start: a new project

1. Create the project, copy the commands and skills, and bootstrap `spec/`:

   ```bash
   mkdir my-project
   cd my-project
   git init
   mkdir -p .opencode/commands .opencode/skills
   cp -R ~/idx-agentic-process/commands/. .opencode/commands/
   cp -R ~/idx-agentic-process/skills/. .opencode/skills/
   ```

   Then run `/bootstrap` in the project. It creates `spec/` and an empty `spec/input.md`.

2. Describe your project in `spec/input.md`, then digest it into requirements and
   architecture:

   ```
   /facilitate
   ```

3. Settle the project shape with the agent. `/facilitate` asks, proposes options and a
   recommendation, and you choose what the project delivers and the language, version and stack.
   A single subproject records this in `architecture/tech-stack.md`; more than one subproject
   uses `spec/modules/{module}/`. The shape must be `agreed` before `/plan` can run.

4. For a project with a UI, run `/design` to create the screen documents, flows,
   theme/components and data, and to build the review prototype. The project's prototype
   builder is created on first use if it does not exist. Review the result and move the screens
   to `approved`.

5. Repeat the requirements and project-shape loop until the picture is stable. Then:

   ```
   /plan      # derive tickets; surfaces decisions it needs from you
   /refine    # promote well-defined tickets to READY; surfaces open decisions
   /implement # loop: implement, review and accept (merge) workable tickets until stuck
   /review    # (run automatically in the loop) verify and accept a ticket to DONE
   /accept    # (run automatically in the loop) release notes, merge, close
   /tickets   # always see where you are
   /guide     # ask what to do next
   ```

6. Commit `spec/` and the tool folder together with the code.

## Adopting an existing codebase

1. Copy the `commands/` and `skills/` folders into the existing repository and run `/bootstrap`
   (see [Installation](#installation)).
2. `/survey` and `/excavate` to reconstruct the project shape, architecture and requirements
   from the code (repeat as the code changes).
3. Review the inferred documents, and accept the project shape in the refinement interview — a
   single `architecture/tech-stack.md`, or each module and its tech stack — until it is
   `agreed`. Planning waits for that.
4. For UI projects, `/survey` reconstructs the observed theme/components and inferred screen
   documents; review and complete them with `/design`, then approve the screens.
5. `/plan`, `/refine`, `/implement`, `/review` and `/accept` as usual.

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
├─ commands/                    # slash commands (one thin wrapper per skill)
│  ├─ bootstrap.md  facilitate.md  design.md  plan.md  refine.md
│  ├─ implement.md  review.md  accept.md  tickets.md
│  └─ excavate.md  survey.md  guide.md  reconcile.md
└─ skills/                      # one folder per skill; the only runtime bundle
   ├─ idx-agentic-process/      # process overview skill
   ├─ iap-bootstrap/            # SKILL.md + assets/ + scripts/bootstrap.sh
   │  ├─ assets/                # gui-spec, screen-workflow, test-strategy, process copy, VERSION
   │  └─ scripts/bootstrap.sh   # creates spec/ and installs the assets   ├─ iap-facilitator/          # SKILL.md + input and project-shape templates
   ├─ iap-designer/             # SKILL.md + prototype-builder template
   ├─ iap-planner/              # SKILL.md + templates/ticket-template.md
   ├─ iap-tickets/              # SKILL.md (read-only listing scripts)
   └─ iap-analyst/  iap-implementor/  iap-reviewer/  iap-accept/
      iap-archaeologist/  iap-system-architect/  iap-guide/  iap-reconciler/
```

The `commands/` folder holds the slash-command wrappers; each `skills/<skill>/` folder holds
its `SKILL.md` plus any templates, assets or scripts it needs. Copying these two folders is
the complete installation. `skills/iap-bootstrap/assets/idx-agentic-process.md` is the copy of
the canonical process definition that `/bootstrap` installs; keep it in sync with the root
file when releasing.

## License

Licensed under the **Apache License, Version 2.0** — see [LICENSE](LICENSE).
Copyright 2026 Peter Walser.
