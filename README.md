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
   │     └─ data/{screen-name}.json     # (X) Example data and scenarios
   ├─ architecture/                     # (X) Architectural design and requirements
   │  ├─ tech-stack.md                  # (X) Single-subproject shape: artifact kind + stack
   │  ├─ integration.md                 # (X) Integration with other systems, APIs
   │  ├─ test-strategy.md               # (X) Test levels and required coverage
   │  ├─ decomposition.md               # (X) Module map (multi) or package map (single)
   │  ├─ coding-guidelines.md           # (X) Additional coding guidelines
   │  ├─ quality-aspects.md             # (X) Non-functional requirements
   │  ├─ prototype-builder.md           # (X) Prototype-builder contract (tooling, not a requirement)
   │  └─ ...                            # (X) Additional guidelines
   ├─ references/                       # (X) Bundled normative references (refreshed by the installer)
   │  ├─ gui-spec.md                    # (X) Normative gui-v2 screen format
   │  └─ screen-workflow.md             # (X) Screen authoring/review workflow
   ├─ modules/                          # (X) Only when the project has >1 subproject
   │  └─ {module}/
   │     ├─ module.md                   # (X) Artifact kind, purpose, boundaries, dependencies, status
   │     └─ tech-stack.md               # (X) Language/version, frameworks, runtime, tooling
   ├─ tickets/{id}-{type}-{name}.md     # (X) A ticket with id, type and name
   └─ agent/                            # (A) Folder managed by the agent
      ├─ input-ledger.md                # (A) Append-only seed: accepted input + clarifications
      ├─ ticket-index.md                # (A) Tickets <-> requirements/architecture links
      ├─ planning-log.md                # (A) Last-seen revision/hash of spec/
      ├─ source-ledger.md               # (A) Hash ledger of scanned sources
      ├─ reverse-engineering-report.md  # (A) Open questions from /excavate & /survey
      ├─ lessons-learned-{role}.md      # (A) Reusable lessons for one role
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
arguments and relays the result — it never does the role's work itself.

| Command        | Role / skill          | Type     | Precondition                                |
|----------------|-----------------------|----------|---------------------------------------------|
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
that has it installed understands the whole process.

## Installation

IAP ships as a bundle: the [`skills/`](skills/) folder (one folder per role, each with a
`SKILL.md` per the open [Agent Skills](https://agentskills.io) standard), the
[`commands/`](commands/) folder (one thin wrapper per slash command), the
[`templates/`](templates/) folder used to seed `spec/`, the
[`references/`](references/) folder with the bundled normative documents, the process
definition [`idx-agentic-process.md`](idx-agentic-process.md) and `VERSION`. Templates and
scripts live inside the skill that uses them where possible:

- **templates** — the copy-once `spec/` skeleton in `templates/spec/`, including the
  project-owned `architecture/test-strategy.md`;
- **references** — the installer-refreshed `gui-spec.md` and `screen-workflow.md` in
  `references/` (installed to `spec/references/`);
- the input, project-shape and ticket templates in `iap-facilitator` and `iap-planner`;
- small read-only scripts inside the agent skills that need them, instead of one shared
  external helper.

### Requirements

- **Git** — IAP tracks requirements, tickets and code in one repository.
- **Bash** — the installer and the read-only scripts embedded in the agent skills are bash.
- **An agent tool** with skills and slash commands: **OpenCode** or **Claude Code**.

### Download the process

Clone the repository once and keep it — the installer copies from it, and pulling it is how
you upgrade:

```bash
git clone https://github.com/pwalser75/idx-agentic-process.git ~/idx-agentic-process
```

You can also download a ZIP from GitHub; the commands below assume the folder
`~/idx-agentic-process`.

### Install into a new or existing project

Run the installer from the IAP download and point it at your project:

```bash
cd ~/code/my-project
~/idx-agentic-process/install.sh
```

The default is a **project-local install**: the skills and commands are copied into
`.opencode/` (OpenCode) or `.claude/` (Claude Code), so they can be committed and shared
with collaborators and cloud agents. Commit `.opencode/` or `.claude/` and `spec/` (except the
local-only `spec/input.md`).

The installer:
- copies `skills/` and `commands/` into the project's tool folder;
- creates the missing parts of `spec/` from `templates/spec/` — an empty `spec/input.md`,
  the requirement and architecture folders (including the project-owned
  `architecture/test-strategy.md`), the ticket folder and the agent ledger;
- refreshes the bundled references `gui-spec.md` and `screen-workflow.md` in
  `spec/references/`;
- records the IAP version in `spec/agent/process-version.md`.

The installer does not create `architecture/tech-stack.md` or `spec/modules/`; the
`/facilitate` project-shape interview creates the right one for the project.

If `spec/` already exists, it only adds missing files and refreshes the process machinery.
Existing requirements, project architecture content, tickets and the input ledger are never
overwritten (the bundled `gui-spec.md` and `screen-workflow.md` references are refreshed).

`--tool` is optional. The installer uses Claude Code when `.claude/` (or `~/.claude/`) is
present and OpenCode otherwise. To choose explicitly:

```bash
~/idx-agentic-process/install.sh --project ~/code/my-project --tool claude
```

Run `~/idx-agentic-process/install.sh --help` for all options.

### Global install

Install the skills and commands once for all projects:

```bash
cd ~/code/my-project
~/idx-agentic-process/install.sh --global
```

This symlinks `skills/` and `commands/` into `~/.opencode/` or `~/.claude/`. `spec/` is still
installed into the current project, so run the installer in each project that uses IAP. Keep
the `~/idx-agentic-process` clone; the symlinks point into it.

### Upgrading

```bash
cd ~/idx-agentic-process
git pull

cd ~/code/my-project
~/idx-agentic-process/install.sh          # add --global if that is how you installed it
```

An upgrade refreshes the command/skill definitions, the bundled references
(`gui-spec.md`, `screen-workflow.md`) in `spec/references/`, the process copy in
`spec/agent/idx-agentic-process.md` and the version marker. It never touches your
requirements, project architecture content, tickets or input ledger. On upgrade from a
release that kept the prototype-builder contract under `spec/design/`, the installer moves
it back to `spec/architecture/prototype-builder.md` and removes the old bundled reference
copies. If a process change alters ticket metadata or statuses, run
`/reconcile` afterwards.

### Removing IAP

Delete the IAP skills and commands from the project's tool folder (`.opencode/` or
`.claude/`), then delete `spec/` if you no longer want the process. For a global install, also
remove the IAP links from `~/.opencode/skills`, `~/.opencode/commands` (or the `~/.claude/`
equivalents).

## Quick start: a new project

1. Create the project and install IAP:

   ```bash
   mkdir my-project
   cd my-project
   git init
   ~/idx-agentic-process/install.sh
   ```

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

1. Install IAP in the existing repository (see [Installation](#installation)).
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
├─ install.sh                   # installs IAP into a project
├─ .gitignore
├─ idx-agentic-process.md       # canonical process definition (read-only for agents)
├─ VERSION                      # IAP version
├─ LICENSE                      # Apache License 2.0
├─ NOTICE                       # copyright notice
├─ commands/                    # slash commands (one thin wrapper per skill)
│  ├─ facilitate.md  design.md  plan.md  refine.md
│  ├─ implement.md  review.md  accept.md  tickets.md
│  └─ excavate.md  survey.md  guide.md  reconcile.md
├─ references/                  # bundled normative references (refreshed by the installer)
│  ├─ gui-spec.md               # gui-v2 format and UI design guide
│  └─ screen-workflow.md        # screen authoring, review and prototype workflow
├─ templates/                   # files the installer seeds into spec/ (never overwrites)
│  └─ spec/                     # spec/ skeleton (folders, stubs, ledger, test strategy)
└─ skills/                      # one folder per skill
   ├─ idx-agentic-process/      # process overview skill
   ├─ iap-facilitator/          # SKILL.md + input and project-shape templates
   ├─ iap-designer/             # SKILL.md + prototype-builder template
   ├─ iap-planner/              # SKILL.md + templates/ticket-template.md
   ├─ iap-tickets/              # SKILL.md (read-only listing scripts)
   ├─ iap-analyst/  iap-implementor/  iap-reviewer/  iap-accept/
   └─ iap-archaeologist/  iap-system-architect/  iap-guide/  iap-reconciler/
```

The `commands/` folder holds the slash-command wrappers; each `skills/<skill>/` folder holds
its `SKILL.md` plus any templates or scripts it needs.

## License

Licensed under the **Apache License, Version 2.0** — see [LICENSE](LICENSE).
Copyright 2026 Peter Walser.
