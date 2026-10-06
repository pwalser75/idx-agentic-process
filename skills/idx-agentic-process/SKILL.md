---
name: idx-agentic-process
description: >-
  Run or work inside the idx Agentic Process (IAP) — a human+agent development
  process driven by a `spec/` folder and slash commands (/bootstrap, /facilitate,
  /plan, /refine, /implement, /review, /accept, /tickets, /excavate, /survey). Use when
  the user mentions IAP, the idx agentic process, a `spec/` folder with
  requirements/architecture/tickets, an input.md or input-ledger.md, a process ticket
  (STORY/IMPROVEMENT/BUG with status
  DRAFT/READY/IN_PROGRESS/IN_REVIEW/DONE/CLOSED), or asks which process command to run
  next. Use at the start of a session in a repository that contains `spec/index.md` to
  learn what to do.
---

# idx Agentic Process (IAP)

IAP builds software with a human and agents in three loops, keeping every decision in a
reviewable `spec/` folder. This skill is the entry point: it explains the model, the
artifacts, the edit rights, the ticket lifecycle and the operating rules. The individual
roles are described in their own skills (`iap-bootstrap`, `iap-facilitator`,
`iap-planner`, `iap-analyst`, `iap-implementor`, `iap-reviewer`, `iap-archaeologist`,
`iap-system-architect`).

## The three loops

```
 ┌──────────────┐   /facilitate   ┌──────────┐   /plan   ┌──────────────┐
 │ REQUIREMENTS │◀────────────────│  INPUT   │──────────▶│  SPEC docs   │
 │    LOOP      │   (human → agent)│ (human) │           │ req + arch   │
 └──────────────┘                 └──────────┘           └──────┬───────┘
        ▲                                                       │ /plan
        │                                                       ▼
        │                                             ┌──────────────────┐
        │            PLANNING LOOP   /plan · /refine  │     TICKETS      │
        │                                             └────────┬─────────┘
        │                                                      │ /implement
        │                                                      ▼
        │                                           ┌────────────────────┐
        └───────────────────────────────────────────│  IMPLEMENTATION    │
             /implement · /review                   │       LOOP         │
                                                    └────────────────────┘
```

- **Requirements loop** — the human writes free-form statements into `spec/input.md`.
  `/facilitate` digests them into implementation-agnostic requirements and architecture,
  records them in the append-only input ledger, then clears `input.md`.
- **Planning loop** — `/plan` turns requirement/architecture changes into tickets;
  `/refine` makes DRAFT tickets precise and promotes them to READY.
- **Implementation loop** — `/implement` claims the best READY ticket and builds it;
  `/review` verifies and either accepts it (DONE) or sends it back; `/accept` updates the
  release notes, merges the feature branch and closes the DONE tickets.

## Artifacts and edit rights

Every artifact carries an edit right: **(H)** human-only, **(A)** agent-only, **(X)** both.

```
project-root/
└─ spec/
   ├─ index.md                  # (X) index describing the project
   ├─ input.md                  # (H) human writes; (A) only clears it
   ├─ release-notes.md          # (X) release notes of the current version (optional)
   ├─ requirements/             # (X) implementation-agnostic requirements
   │  ├─ domain-models/{model}.md   # (X) name, description, attributes
   │  └─ features/{feature}.md      # (X) feature + its functions/use cases
   ├─ architecture/             # (X) non-functional design
   │  ├─ tech-stack.md  decomposition.md
   │  ├─ coding-guidelines.md  quality-aspects.md
   │  └─ ...
   ├─ tickets/{id}-{type}-{name}.md # (A) work units, agent-owned
   └─ agent/                    # (A) agent's own workspace
      ├─ input-ledger.md        # (A) append-only record of accepted input
      ├─ idx-agentic-process.md # (A) copy of the process definition used
      ├─ process-version.md     # (A) IAP version + install provenance
      └─ ...
```

Rules that follow from this:

- **Never edit an (H) file.** The only agent action on `input.md` is to clear it after
  its content has been accepted and recorded.
- **Never silently overwrite (X) content.** When reproducing or inferring, keep existing
  human content and add provisional material marked `origin: inferred` with evidence.
- **`spec/agent/input-ledger.md` is append-only.** Never rewrite or delete past entries.
- **A ticket's content is owned by agents**; a human editing it counts as new input and
  resets it to DRAFT.

## Requirements vs. architecture

- **Requirements** describe *what* the project does, implementation-agnostically (no
  language, framework or API choices). Features are the story arches; their functions
  are atomic use cases (list, find, view, edit, delete, …) around domain models.
- **Domain models** are conceptual: name, description, attributes with a name,
  description and a language-agnostic type (`string`, `integer`, `decimal`, `date`,
  `date-time`, `currency`, …).
- **Architecture** describes *how* it is built: tech stack, decomposition into
  modules/packages, coding guidelines and quality aspects (non-functional requirements).

## Tickets

A ticket is a Markdown file under `spec/tickets/`, named `{id}-{type}-{name}.md`:

```
# Title
TYPE:   {STORY | IMPROVEMENT | BUG}
STATUS: {DRAFT | READY | IN_PROGRESS | IN_REVIEW | DONE | CLOSED}
CREATED-ON: {ISO date-time}
UPDATED-ON: {ISO date-time}
---
{description + task breakdown (checkbox list) + acceptance criteria}
---
{comments}
```

Statuses:

- **DRAFT** — needs refinement and acceptance.
- **READY** — refined and ready to be implemented.
- **IN_PROGRESS** — claimed by an agent.
- **IN_REVIEW** — implemented, awaiting review.
- **DONE** — review-accepted, awaiting merge and closure.
- **CLOSED** — merged and closed; immutable, follow-up work becomes a new ticket.

Transitions (the full guarded table is in the process definition):

```
DRAFT ──/refine──▶ READY ──/implement──▶ IN_PROGRESS ──(work done)──▶ IN_REVIEW
  ▲                  ▲                                                    │
  └── content edit ──┴──────────── /review (rework) ───────────────────── │
                                            /review (accept) ──▶ DONE ──/accept──▶ CLOSED
```

Work priorities when picking a READY ticket: **BUG > IMPROVEMENT > STORY**.

## Release notes

`spec/release-notes.md` records what changed in the current version, for the project's
clients. It is optional and **not created by `/bootstrap`**; `/accept` creates it on the
fly when missing and adds each accepted ticket under the heading matching its type —
STORY → "New Features", IMPROVEMENT → "Improvements", BUG → "Bugfixes". Entries are bold
titles with a short, client-facing description; similar tickets may be merged into one
entry to keep it brief. The human clears the file when bumping the major/minor version.

```
# Version {major.minor} | Release Notes

## New Features
- **{title}**: {description}

## Improvements
- **{title}**: {description}

## Bugfixes
- **{title}**: {description}
```

## Commands

Commands are invoked by humans only. Each starts a role implemented as a skill.

| Command       | Role                  | Precondition                              |
|---------------|-----------------------|-------------------------------------------|
| `/bootstrap`  | `iap-bootstrap`       | project root (no `spec/` yet, else refresh)|
| `/facilitate` | `iap-facilitator`     | `input.md` exists and is not empty        |
| `/plan`       | `iap-planner`         | none                                      |
| `/refine`     | `iap-analyst`         | none                                      |
| `/implement`  | `iap-implementor`     | at least one READY ticket                 |
| `/review`     | `iap-reviewer`        | at least one IN_REVIEW ticket             |
| `/accept`     | —                     | at least one DONE ticket                  |
| `/tickets`    | —                     | `spec/` bootstrapped                      |
| `/excavate`   | `iap-archaeologist`   | `spec/` bootstrapped, source code present |
| `/survey`     | `iap-system-architect`| `spec/` bootstrapped, source code present |

Always check the precondition before acting; if it is not met, say so and stop.

Commands use the shared, read-only helper `.iap/iap.sh` (installed by `/bootstrap`) for
fast, single-pass scans of `spec/` — e.g. `bash .iap/iap.sh open`, `bash .iap/iap.sh list
READY`, `bash .iap/iap.sh next`. Prefer it over opening ticket files one by one; run
`/bootstrap` if it is missing.

## Golden rules for any IAP agent

1. **Read before you write.** Start by reading `spec/index.md`, the requirements,
   architecture, the input ledger and the tickets that concern your task.
2. **Respect edit rights (H/A/X).** An (H) file is untouchable except clearing
   `input.md`; (X) files are added to, never silently replaced; (A) files are yours.
3. **Stay in your role.** Only the role's command does its job. A planner does not
   implement; an implementor does not invent requirements.
4. **A content change to a DRAFT, READY, IN_REVIEW or DONE ticket resets it to DRAFT**
   to force re-refinement. Tickets in IN_PROGRESS are exempt while being implemented.
5. **One ticket, one scope.** Implement only what the claimed ticket asks. Unrelated
   work becomes a new ticket.
6. **Record provenance.** Inferred content is marked `origin: inferred` with evidence;
   accepted human input is appended to the ledger with date, time and author.
7. **Humans gate the work.** Commands, feature branches and merges are human decisions.
8. **Commit `spec/` with the code**, and follow the git rules below.
9. **Keep verbosity low.** Answer concisely with minimal explanation.
10. **Write plain English.** No "agentish" filler or corporate lingo ("delve",
    "leverage", …).

## Collaboration (git)

- The Git repository is the single source of truth; only committed state counts.
- `spec/input.md` is local-only and gitignored — each human keeps their own copy. Only
  the input ledger is shared and versioned.
- Implementation happens on a **feature branch**, never on `main`, with a commit per
  ticket. The human creates the branch and decides which tickets may be implemented.
- Claiming a ticket means committing its status as IN_PROGRESS on the feature branch;
  no other agent picks up a claimed ticket. The planner resets it to READY only when the
  claim is neither active nor reachable as an open branch.
- Rebase before claiming; commit after each acceptance criterion; push before handover.
  Never force-push a branch another agent depends on.
- The reviewer reviews the feature branch, not the working tree, and accepts a ticket to
  DONE; the human then runs `/accept` to update the release notes, squash each ticket's
  commits into one, merge the branch into `main` (fast-forward only) and set it to CLOSED.
  A ticket reaches CLOSED only once its branch is merged.

## Bootstrapping and adoption

- `/bootstrap` installs the commands/skills and creates the `spec/` skeleton. It never
  invents requirements or tickets.
- **New project:** `/bootstrap` → write `spec/input.md` → `/facilitate` → repeat until
  stable → `/plan` → `/refine` → `/implement` → `/review` → `/accept` → commit `spec/`
  with code.
- **Existing project:** `/bootstrap` → `/survey` + `/excavate` to reconstruct the
  reality as provisional documents → the human reviews and accepts them → then the
  normal loop. Reverse-engineering agents never silently overwrite human content.
- **Updating the process:** re-run `/bootstrap`. It refreshes the command/skill
  definitions and process marker only; `spec/requirements`, `spec/architecture`,
  `spec/tickets` and `spec/agent/input-ledger.md` are never touched.

## Where to look next

- The canonical, human-owned process definition: `idx-agentic-process.md` in this
  repository (a copy is placed at `spec/agent/idx-agentic-process.md` in bootstrapped
  projects). It is authoritative if anything here disagrees.
- `README.md` for installation, repository layout and quick-start.
- The role skills listed above for exact per-role procedures.
