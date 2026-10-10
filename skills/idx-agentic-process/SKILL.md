---
name: idx-agentic-process
description: >-
  Entry point for the idx Agentic Process (IAP), a human+agent development process driven
  by a `spec/` folder and slash commands (/bootstrap, /facilitate, /plan, /refine,
  /implement, /review, /accept, /tickets, /excavate, /survey, /guide, /reconcile). Use at
  the start of a session in a repository that contains a `spec/` folder, or when the user
  mentions IAP, the idx agentic process, `spec/` requirements/architecture/tickets, an
  input.md or input-ledger.md, or a ticket (`{id}-{type}-{name}.md` with status
  DRAFT/READY/IN_PROGRESS/IN_REVIEW/DONE/CLOSED), or asks which process command to run
  next.
---

# idx Agentic Process (IAP)

IAP builds software with a human and agents in an iterative loop, keeping every decision
in a reviewable `spec/` folder. This skill is the entry point: it explains the model, the
artifacts and their edit rights, the ticket lifecycle and the operating rules. Each role
has its own skill (`iap-facilitator`, `iap-planner`, `iap-analyst`, `iap-implementor`,
`iap-reviewer`, `iap-archaeologist`, `iap-system-architect`, `iap-guide`,
`iap-reconciler`, `iap-bootstrap`, `iap-accept`, `iap-tickets`).

The canonical, human-owned definition is `idx-agentic-process.md`; a copy is placed at
`spec/agent/idx-agentic-process.md` in bootstrapped projects. If this skill and that file
disagree, the file wins.

## The process

- **Requirements** — define and detail the requirements and the constraints for building
  them (human + agent).
- **Planning** — turn requirements into actionable tasks expressed as tickets (agent).
- **Implementation** — pick a ticket and build the project incrementally (agent).
- **Review** — review implemented tickets on feature branches and either accept them or
  comment on what to adjust (agent or human).

The process enables the human-in-the-loop but does not enforce it.

## Typical human workflow

1. **Capture input** — add facts to `spec/input.md`, then run `/facilitate`. It folds the
   input into the requirements and architecture documents, appends it to the input ledger,
   and clears `input.md`.
2. **Review (optional)** — read the updated `requirements/` and `architecture/` documents;
   repeat step 1 until the picture is stable.
3. **Plan** — run `/plan`, then inspect tickets with `/tickets`. It surfaces any gap or
   impediment that needs your decision — with the options and its advice — and records the
   decision in the input ledger before continuing.
4. **Refine** — run `/refine` to promote sufficiently defined tickets to READY. It likewise
   surfaces the decisions it needs from you before promoting a ticket.
5. **Mark acceptance (optional)** — set `acceptance-type: HUMAN` on tickets you want to
   accept yourself; the rest stay on the default AUTOMATIC. This is a metadata edit and
   does not change the ticket's status.
6. **Implement** — run `/implement` once. It drives the implement → review → accept loop:
   the agent works through READY, unblocked tickets one at a time; AUTOMATIC tickets are
   reviewed and accepted (merged) automatically, HUMAN tickets are implemented and left for
   you. The loop runs until nothing workable remains or it gets stuck, then reports what is
   left and why.
7. **Accept manually** — inspect DONE tickets with `acceptance-type: HUMAN` and run
   `/accept` to merge them, or comment on a ticket to send it back to DRAFT.
8. **Recover / re-orient** — after any interruption, or when unsure, run `/reconcile` to
   restore a consistent state and `/guide` to see what to do next.

## Artifacts and edit rights

Every artifact carries an edit right: **(H)** human-only, **(A)** agent-only, **(X)** both.

```
project-root/
└─ spec/
   ├─ input.md                          # (X) human writes input; agent only clears it after /facilitate, never edits content
   ├─ release-notes.md                  # (X) release notes of the current version (optional)
   ├─ requirements/                     # (X) implementation-agnostic requirements
   │  ├─ domain-models/{model-name}.md  # (X) name, description, attributes
   │  └─ features/{feature-name}.md     # (X) feature + its functions/use cases
   ├─ architecture/                     # (X) non-functional design and constraints
   │  ├─ tech-stack.md                  # (X) languages, frameworks, libraries
   │  ├─ design-system.md               # (X) UI design system (default preset)
   │  ├─ decomposition.md               # (X) modules and packages
   │  ├─ coding-guidelines.md           # (X) naming, structure, error handling, testing
   │  ├─ quality-aspects.md             # (X) non-functional requirements
   │  └─ ...                            # (X) additional guidelines
   ├─ tickets/{id}-{type}-{name}.md     # (X) work units
   └─ agent/                            # (A) agent-owned workspace
      ├─ input-ledger.md                # (A) append-only seed: accepted input + clarifications
      ├─ ticket-index.md                # (A) tickets <-> requirements/architecture links
      ├─ planning-log.md                # (A) last-seen revision/hash of spec/
      ├─ source-ledger.md               # (A) hash ledger of scanned sources
      ├─ reverse-engineering-report.md  # (A) open questions from /excavate & /survey
      ├─ process-version.md             # (A) IAP version used
      └─ idx-agentic-process.md         # (A) copy of this process
```

Rules that follow:

- **Never edit `input.md` content.** The only agent action is to clear it after its
  content has been accepted into the ledger and the spec.
- **Never silently overwrite (X) content.** When inferring, keep human content and add
  provisional material marked `origin: inferred` with evidence.
- **`spec/agent/input-ledger.md` is append-only.** FACILITATOR records accepted input and
  resolved clarifications; PLANNER and ANALYST append the clarifications and decisions they
  resolve (with the human's clearance). Never rewrite, reorder or remove past entries.
- **`spec/tickets/` is (X).** Agents create and process tickets; a human may write one,
  using the template with a unique `id` and `status: DRAFT`.

## Requirements vs. architecture

- **Requirements** describe *what* the project does, implementation-agnostically (no
  language, framework, database or API choices). Features are the story arcs; their
  functions are atomic use cases (list, find, view, edit, delete, …) around domain models.
- **Domain models** are conceptual: name, description, and attributes with a name,
  description and a language-agnostic type (`string`, `integer`, `decimal`, `date`,
  `date-time`, `currency`, …).
- **Architecture** describes *how* it is built: tech stack, decomposition into
  modules/packages, coding guidelines, quality aspects (non-functional requirements) and,
  for projects with a UI, the design system.

## Tickets

A ticket is a Markdown file under `spec/tickets/`, named `{id}-{type}-{name}.md`, with
YAML front matter:

```
---
id: {id}
created: {created}
type: {type}
status: {status}
acceptance-type: {acceptance-type}
blocked-by: {blocked-by}
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

### Metadata

- `id` — unique ticket number, matching the filename prefix.
- `created` — creation timestamp, ISO-8601.
- `type` — `STORY` | `IMPROVEMENT` | `BUG`.
- `status` — see below.
- `acceptance-type` — `AUTOMATIC` (default, the agent accepts) | `HUMAN`.
- `blocked-by` — ids of blocking tickets; absent when not blocked.

### Identity and naming

- Identity is the filename `{id}-{type}-{name}.md`; the front-matter `id` must match the
  filename prefix.
- `{id}` is zero-padded, monotonically increasing (max existing id + 1); never reused.
- `{type}` is the lowercase token (`story` | `improvement` | `bug`) in the filename and
  branch, and the uppercase value in metadata.
- `{name}` is a lower-kebab-case slug of the title.

### Types

- **STORY** — functional increment.
- **IMPROVEMENT** — non-functional change.
- **BUG** — reported defect.

### Status

- **DRAFT** — refinement and approval needed.
- **READY** — refined and ready to be implemented.
- **IN_PROGRESS** — claimed by an agent.
- **IN_REVIEW** — implemented, awaiting review.
- **DONE** — passed review, ready to merge and close.
- **CLOSED** — done and closed; immutable, follow-up work is a new ticket.

### Status flow

```
DRAFT ──/refine──▶ READY ──/implement──▶ IN_PROGRESS ──(work done)──▶ IN_REVIEW
  ▲                  ▲                                                    │
  └── content edit ──┴──────────── /review (rework) ───────────────────── │
                                            /review (accept) ──▶ DONE ──/accept──▶ CLOSED
```

A non-metadata edit (Description, Tasks, Acceptance criteria, Comments) of a ticket in
DRAFT/READY/IN_REVIEW/DONE resets it to DRAFT. Setting `acceptance-type` or `blocked-by`
is a metadata edit and does not change the status. A reviewer's rework comment is the one
exception: it moves IN_REVIEW → READY.

## Roles

Each named role is a skill with a matching command. A SUBAGENT role runs in its own
isolated context as a subtask, so its work never pollutes the orchestrator's context. A
SUBAGENT never blocks on input: it returns its questions in its report, and the invoking
agent relays them and re-invokes it with the answers. The orchestrator must not do a
SUBAGENT's work itself.

The IMPLEMENTOR loops only up to the handover: when it leaves a ticket IN_REVIEW and
reports, the orchestrating agent runs the REVIEWER in a separate SUBAGENT context for that
ticket, then for an AUTOMATIC ticket runs `/accept`, syncs `main`, and re-invokes the
IMPLEMENTOR for the next READY ticket. Roles never invoke each other — only the orchestrator
sequences them, one writing role at a time — and it drives this implement → review → accept
loop automatically until no READY, unblocked ticket remains or the loop gets stuck (an
impediment, a violated invariant, or a decision that needs a human).

| Role                  | Type     | Command       | Precondition                              |
|-----------------------|----------|---------------|-------------------------------------------|
| FACILITATOR           | PRIMARY  | `/facilitate` | `input.md` exists and is not empty        |
| PLANNER               | SUBAGENT | `/plan`       | none                                      |
| ANALYST               | SUBAGENT | `/refine`     | none                                      |
| IMPLEMENTOR           | SUBAGENT | `/implement`  | ≥1 READY ticket, clean tree, on main      |
| REVIEWER              | SUBAGENT | `/review`     | ≥1 IN_REVIEW ticket                       |
| ARCHAEOLOGIST         | SUBAGENT | `/excavate`   | `spec/` bootstrapped, source present      |
| SYSTEM-ARCHITECT      | SUBAGENT | `/survey`     | `spec/` bootstrapped, source present      |
| GUIDE                 | SUBAGENT | `/guide`      | none                                      |
| RECONCILER            | SUBAGENT | `/reconcile`  | none                                      |

Additional commands (also expressed as skills): `/bootstrap` (install + create the spec
skeleton), `/tickets` (list open tickets), `/accept` (update release notes, squash, rebase
and merge DONE tickets).

## Golden rules for any IAP agent

1. **Read before you write.** Start from the requirements, the architecture and the tickets
   that concern your task.
2. **Respect edit rights (H/A/X).** Never edit `input.md` content; add to (X) files,
   never silently replace them; (A) files are the agent's.
3. **Stay in your role.** A planner does not implement; an implementor does not invent
   requirements.
4. **One ticket, one scope.** Implement only what the claimed ticket asks; unrelated work
   is a new ticket.
5. **Work only from artifacts on disk** (`spec/`, tickets, git) and explicit arguments —
   never from conversation history.
6. **Return one concise report:** what was done, the evidence, and any questions or
   blockers.
7. **If a precondition is not met or an invariant is violated, stop and report it** —
   never improvise around it.
8. **Keep verbosity low and write plain English** — no "agentish" filler or corporate
   lingo ("delve", "leverage", …).

## Collaboration (git)

- The Git repository is the single source of truth; only committed state counts.
- `spec/input.md` is local-only and gitignored; each human keeps their own copy. Only the
  shared, append-only input ledger is versioned.
- Implementation happens on a feature branch named `{id}-{type}-{name}`, one per ticket,
  never on `main`; the ticket is claimed by committing `status: IN_PROGRESS` on that
  branch.
- Implementation changes reach `main` only through `/accept`, which squashes the branch's
  commits into one, rebases onto `main` and merges (fast-forward only).
- Only `/accept` merges; only `/reconcile` cleans up branches; an unmerged branch is never
  deleted without confirmation.
- Never run two writing roles concurrently; serialize them and coordinate via
  `spec/agent/`.
- Planning and requirements artifacts are committed directly on `main`.
- `/facilitate`, `/plan` and `/refine` commit their work on `main` automatically, one commit
  per invocation: `{command}: {summary}` — a single line of at most 200 characters.

### Invariants

- A ticket's status matches its branch: IN_PROGRESS/IN_REVIEW ⇒ its branch exists;
  DRAFT/READY ⇒ no branch; CLOSED ⇒ merged and branch gone.
- Implementation changes reach `main` only through `/accept`.
- Every ticket has a unique id and its filename matches the front-matter `id`.
- `blocked-by` references existing tickets and is acyclic.
- No two writing roles run concurrently.
- The process document is never edited by an agent.
- Every human decision that changes requirements, architecture or tickets is recorded in
  `spec/agent/input-ledger.md`.

`/reconcile` validates and repairs these; `/guide` reports violations it cannot repair.

## Bootstrapping and adoption

- **New project:** `/bootstrap` → write `spec/input.md` → `/facilitate` → repeat until
  stable → `/plan` → `/refine` → `/implement` (with `/review`) → `/accept` → commit
  `spec/` with the code.
- **Existing project:** `/bootstrap` → `/survey` + `/excavate` to reconstruct the
  architecture and requirements as provisional documents → the human reviews and accepts
  them → then the normal loop. Reverse-engineering agents never silently overwrite human
  content.
- **Updating the process:** re-run `/bootstrap`. It refreshes the command/skill
  definitions, the process copy and the version marker; the content of `spec/requirements`,
  `spec/architecture`, `spec/tickets` and `spec/agent/input-ledger.md` is never touched.
  After a process change that alters statuses or metadata, the human runs `/reconcile` to
  migrate existing tickets and ledgers.

## Installation

Copy the `skills/` and `commands/` folders into your project's agent folder — `.opencode`
(OpenCode) or `.claude` (Claude Code) — for a project-local install, or into `~/.opencode`
/ `~/.claude` for a global install. See `README.md` for details.

## Where to look next

- `idx-agentic-process.md` — the canonical, human-owned process definition.
- `README.md` — overview, installation and repository layout.
- The role skills for exact per-role procedures.
