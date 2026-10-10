# idx AGENTIC PROCESS

THIS DOCUMENT MUST NOT BE ALTERED BY AGENTS, ONLY BY HUMANS.

The idx Agentic Process (short: IAP) is a development process primarily for building software projects at first.
In later stages, it may evolve into a more generic development process, where building software is only one possible flavor.

It drives the development of a project in an iterative process:

- Requirements: define and detail the requirements, define constraints for building it (Human and Agent).
- Planning: create actionable tasks expressed as tickets. (Agent).
- Implementation: pick a ticket, and work on it, creating and refining the project incrementally (Agent).
- Review: review implemented tickets on feature branches, and either accept the tickets or add comments on what needs to be adjusted (Agent or Human).

Participants in this process are:
- Human, or in larger projects, multiple human collaborators.
- Agents for specialized tasks. They can have a defined role/skill suitable for the task at hand.

The process enables the human-in-the-loop, but does not enforce it.

## Typical human workflow

The human drives the loop; the agent does the ticket work.

1. **Capture input**: add facts to `spec/input.md`, then run `/facilitate`. It folds the input into the
   requirement and architecture documents, appends it to the input ledger, and clears `input.md`.
2. **Review (optional)**: read the updated `requirements/` and `architecture/` documents; repeat step 1
   until the picture is stable.
3. **Plan**: run `/plan`, then inspect the created/updated tickets with `/tickets`.
4. **Refine**: run `/refine` to promote sufficiently defined tickets to READY.
5. **Mark acceptance (optional)**: set `acceptance-type: HUMAN` on the tickets you want to accept
   yourself; leave the rest on the default AUTOMATIC. This is a metadata edit — it does not change
   the ticket's status.
6. **Implement**: run `/implement` once. It drives the implement → review → accept loop: the agent
   works through the READY, unblocked tickets one at a time, AUTOMATIC tickets are reviewed and
   accepted (merged) automatically, and HUMAN tickets are implemented and left for you. The loop
   runs until no workable ticket remains or it gets stuck (an impediment, or a decision that needs
   you), then reports what remains and why.
7. **Accept manually**: inspect the tickets awaiting your acceptance (status DONE with
   `acceptance-type: HUMAN`) and run `/accept` to merge them, or comment on a ticket to send it
   back to DRAFT.
8. **Recover / re-orient**: after any interruption, or when unsure, run `/reconcile` to restore a
   consistent state and `/guide` to see what to do next.

## Definitions

- main branch: the repository's default branch (commonly `main` or `master`); referred to as `main` below. Where a remote exists, its default branch is authoritative.

## Artifacts and folder structure

A clear definition of which files are owned by the human (H), agent (A) or both (X).
```
project-root/
└─ spec/                                # Root folder of the process
   ├─ input.md                          # (X) Human writes input; Agent only clears it after `/facilitate`, never edits content.
   ├─ release-notes.md                  # (X) Release notes of the current version (optional).
   ├─ requirements/                     # (X) Requirements of this project
   │  ├─ domain-models/                 # (X) Domain models
   │  │  └─ {model-name}.md             # (X) Domain model, with name, attributes and descriptions
   │  ├─ features/                      # (X) Features of the domain
   │  │  └─ {feature-name}.md           # (X) Document per feature, describing the feature and the functionalities
   ├─ architecture/                     # (X) Architectural design and requirements
   │  ├─ tech-stack.md                  # (X) Tech stack, programming languages, frameworks and libraries
   │  ├─ design-system.md               # (X) UI design system
   │  ├─ decomposition.md               # (X) Decomposition into modules and packages
   │  ├─ coding-guidelines.md           # (X) Additional coding guidelines
   │  ├─ quality-aspects.md             # (X) Quality Aspects (= non-functional requirements)
   │  └─ ...                            # (X) Additional guidelines
   ├─ tickets/                          # (X) Tickets for the implementation
   │  └─ {id}-{type}-{name}.md          # (X) A ticket, with a distinct id, type and name
   └─ agent/                            # (A) Folder managed by the agent, it can document anything here
       ├─ input-ledger.md               # (A) append-only seed: accepted input and resolved clarifications
       ├─ ticket-index.md               # (A) tickets ↔ requirements/architecture links
       ├─ planning-log.md               # (A) last-seen revision/hash of spec/
       ├─ source-ledger.md              # (A) hash ledger of scanned sources
       ├─ reverse-engineering-report.md # (A) open questions from `/excavate` & `/survey`
       ├─ process-version.md            # (A) IAP version used
       └─ idx-agentic-process.md        # (A) copy of this process

```

## Input

The idea to build the software comes from the human, who describes the project with a rough outline and expresses expectations about the domain of the project (models, functionality)
and how it should be built. This information comes in an unstructured form, where the human states facts, expectations, behaviour etc. as a stream of statements.
These statements are entered into an `input.md` file.

In an input session, the human writes down statements into the input file.
At some point, when enough new input has been collected, the human instructs the agent to facilitate the information.

The agent then:
- reviews the input
- can prompt the user for clarification, with suggestions
- and then appends the input (verbatim, or a corrected version thereof) to the input-ledger (with the date, time and user), and then clears the input file.

It then decides what to make out of this information (new input, in the context of existing input):

- create/update the requirement documents (models, features, functions)
- create/update the architecture documents
- do nothing yet (unresolved input which we review periodically)

Clarifications are input too: questions raised by FACILITATOR, PLANNER or ANALYST (technology
choices, implementation variants, ambiguous requirements) and the human's answers are
recorded in `input-ledger.md` before the role acts on them. Like facilitated input, these
entries are append-only and carry date/time, human user and the resolution. FACILITATOR
records the `input.md` it accepts and any clarification it resolves; PLAN and REFINE record
the clarifications they resolve, so they are not lost and are not re-recorded if the same
fact later arrives via `input.md`.

PLANNER and ANALYST do not guess past ambiguity. When they find a gap or an impediment that
needs a human decision (missing or ambiguous requirements, a technology or implementation
choice, conflicting constraints, a blocker, a ticket that cannot be made READY), they state
the gap, advise on the options — with a recommendation and the trade-offs — and ask the
human for clearance. They never block and never improvise around it: they return the open
questions in their report and stop. Only once the human has decided do they record the
decision (gap, advice, decision, date/time, human user) in `input-ledger.md` and continue.

## Requirements

The requirements describe the features of the project. They are kept in an implementation-agnostic format, which is very important (the requirements do not make assumptions about the tech stack, frameworks or implementation).

### Feature

A feature is an isolated aspect of the project to be realized. It is the overall story arc over the functions in the feature.
Each feature has a set of functions describing atomic functionality as use cases, whose functionality usually revolves around the domain models
(e.g. list, find, view, edit, delete, ...).

Features drive the functional decomposition (modules, packages), whereas functions are usually manifested in external and internal APIs (e.g. REST endpoints, services, adapters).

### Domain models

A catalogue of conceptual domain models, with name, description and attributes.
Each attribute also has a name, description and type (use programming-language agnostic types such as 'decimal', 'integer', 'string', 'date', 'date-time', 'currency').
Domain models are the main drivers for downstream implementation decisions (e.g. which parts of them to use in APIs, which parts of them are persisted).

## Architecture

The architecture describes the non-functional aspects of the project (how it's built).
It's the design of the system, with choices of the technology, decomposition, quality aspects and,
for projects with a user interface, the design system.

## Tickets

Tickets are created and processed mostly automatically by the agent.
Humans may occasionally write tickets themselves, using the template with a unique `id` and `status: DRAFT`.

The human acts as:
- an orchestrator (using `/facilitate`, `/plan`, `/refine` and `/implement`).
- an optional reviewer for selected tickets (where acceptance-type is not AUTOMATIC).

The history of tickets later tells which changes were made to the project in which order (ticket number reflected in commits).

### Metadata

Ticket metadata:
- `id`: unique ticket number, matching the filename prefix.
- `created`: creation timestamp of the ticket, in ISO-8601 format.
- `type`: ticket type, see "Types" below.
- `status`: ticket status, see "Status" values below.
- `acceptance-type`: `AUTOMATIC` (default) | `HUMAN`, see "Acceptance Type" below.
- `blocked-by`: list of ids of the tickets that block this ticket. Can be absent when not blocked.

### Identity and naming

- A ticket's identity is its filename `{id}-{type}-{name}.md`; the front-matter `id` must match the filename prefix.
- `{id}` is a zero-padded, monotonically increasing integer (max existing id + 1); ids are never reused. A human-written ticket takes the next free id.
- `{type}` is the lowercase token `story` | `improvement` | `bug` in the filename and branch, and the uppercase value in metadata.
- `{name}` is a lower-kebab-case slug of the title, unique within the id.
- On a collision, keep the existing ticket and allocate the next free id.

#### Types

- STORY (functional increment)
- IMPROVEMENT (non-functional change)
- BUG (reported bug)

#### Status

- DRAFT (refinement and approval needed)
- READY (ticket refined and ready to be implemented)
- IN_PROGRESS (claimed by an agent for implementation)
- IN_REVIEW (ticket successfully implemented, but needs to be reviewed before it can be closed)
- DONE (ticket passed review, ready to be merged and closed)
- CLOSED (ticket done and closed, protected from changes)

#### Acceptance Type
- AUTOMATIC (default, Agent reviews and accepts the ticket)
- HUMAN (set by Human, Agent reviews, Human reviews again and accepts the ticket)

### Template

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

### Status diagram

```
    │ /plan (new requirement)
    │
    ▼
╭───────╮  /refine   ╭───────╮  /implement   ╭─────────────╮   (agent)     ╭───────────╮
│ DRAFT │───────────▶│ READY │──────────────▶│ IN_PROGRESS │──────────────▶│ IN_REVIEW │
╰───────╯            ╰───────╯               ╰─────────────╯               ╰───────────╯
    ▲                    ▲                          │                            │
    │                    ├◀─────/plan (reclaim)─────┘                            │
    │                    └◀────────────────────────────────/review (rework)──────┤
    │                                                                            │ /review (accepted)
    │                                                                            ▼
    │                                                                        ╭──────╮
    └◀─────────────────────── non-metadata edit of a ticket──────────────────│ DONE │
                                                                             ╰──────╯
                                                                                 │ /accept (human or agent)
                                                                                 ▼
                                                                            ╭────────╮
                                                                            │ CLOSED │
                                                                            ╰────────╯
                                                                            (terminal)
```

#### State transitions:

| FROM                       | TO          | TRIGGER                       | ACTOR                                     | GUARD                                        |
|----------------------------|-------------|-------------------------------|-------------------------------------------|----------------------------------------------|
| —                          | DRAFT       | `/plan`                       | Planner                                   | new or changed requirement                   |
| DRAFT                      | READY       | `/refine`                     | Analyst                                   | sufficiently defined and realizable          |
| READY                      | IN_PROGRESS | `/implement`                  | Implementor                               | claimed by setting status                    |
| IN_PROGRESS                | IN_REVIEW   | work complete                 | Implementor                               | tasks done, acceptance criteria fulfilled    |
| IN_PROGRESS                | READY       | `/plan` (reclaim)             | Planner                                   | claim abandoned (not active, no open branch) |
| IN_REVIEW                  | READY       | `/review` (rework)            | Reviewer                                  | comments state what remains                  |
| IN_REVIEW                  | DONE        | `/review` (accept)            | Reviewer                                  | accepted                                     |
| DONE                       | CLOSED      | `/accept` (accept)            | Orchestrator (AUTOMATIC) or Human (HUMAN) | accepted, feature branch can be merged       |
| DRAFT/READY/IN_REVIEW/DONE | DRAFT       | non-metadata edit of a ticket | (anyone)                                  | forces re-refinement                         |
| CLOSED                     | —           | (none, terminal)              | —                                         | immutable; follow-up work is a new ticket    |

## Release Notes

The release notes are stored in `release-notes.md` and updated when a ticket is accepted.
The release notes file will be cleared by the human when bumping the major/minor version.
The tickets will be added under the appropriate heading:
- STORY -> "New Features"
- IMPROVEMENT -> "Improvements"
- BUG -> "Bugfixes"

The entries under these headings are bullet lists, with the title in bold, and a short, concise description.
Entries for multiple similar tickets can be merged to keep the release notes short and concise (don't go into details, and omit technical details unless absolutely relevant for understanding).
Target audience: clients of the project. Don't add too many details, the actual details can still be looked up in the tickets afterwards.

Format of the release notes:
```
# Version {major.minor} | Release Notes

## New Features
- **{title}**: {description}

## Improvements
- **{title}**: {description}

## Bugfixes
- **{title}**: {description}
```

Release notes are not bootstrapped; they are created on-the-fly by `/accept` when missing.

## Roles

Each named role is expressed as a skill, with a matching command that invokes the skill.

Depending on the role, it can be:
- the primary agent (Type: PRIMARY)
- or a subagent (Type: SUBAGENT) running in its own isolated context as a subtask, so role work never pollutes the orchestrator's context.

A SUBAGENT role never blocks on input: it returns its questions/blockers in the final report, and the invoking agent relays them to the human and re-invokes the role with the answers.

For SUBAGENT skills, the invoking (orchestrating) agent must not perform the role's work itself — it selects the role, passes the arguments, and relays the result.

### Role loop (handover)

The IMPLEMENTOR loops only up to the handover. When it sets a ticket to IN_REVIEW and
reports, the *orchestrating agent* (the one that invoked `/implement`) runs the REVIEWER in
a separate SUBAGENT context for that ticket. Roles never invoke each other — only the
orchestrator sequences them, one writing role at a time.

The orchestrator then drives implement → review → accept as a single loop, without returning
to the human after each ticket:

1. run the REVIEWER on the IN_REVIEW ticket;
2. if the reviewer rejected it (READY), re-invoke the IMPLEMENTOR to rework that ticket;
3. if the reviewer accepted an AUTOMATIC ticket (DONE), run `/accept` to merge and close it,
   then sync `main` and re-invoke the IMPLEMENTOR for the next READY ticket;
4. a HUMAN ticket accepted by the reviewer stays DONE — leave it for the human and continue
   with the other workable tickets;
5. repeat until no READY, unblocked ticket remains, or it is stuck — an impediment, a
   violated invariant, or a decision that needs a human. On a stuck loop it stops and reports
   what remains and why.

This is the "implement as much as possible until stuck" loop: it closes AUTOMATIC tickets end
to end (implement, review, accept) in one run, and only pauses for HUMAN acceptance or a
human decision.

Design guidelines for the agents:
- keep verbosity low, use more concise responses with minimal explanation.
- use plain English, not 'Agentish'. Fluff-free, no corporate lingo ("delve", "leverage", ...)
- Work only from artifacts on disk (spec/, tickets, git) and explicit arguments — never from the orchestrator's conversation history.
- Return exactly one concise report: what was done, the evidence, and any questions/blockers.
- If an invariant is violated, or a precondition is not met, stop and report it; never improvise around it.
- Editing a ticket's Description, Tasks, Acceptance criteria or Comments is a non-metadata edit: set the ticket back to DRAFT.
- Optimize the skills to work as efficiently as possible.

### FACILITATOR

Type: PRIMARY
Command: `/facilitate`.
Invoked by: HUMAN.
Precondition: `input.md` exists and is not empty.

Digests the human input (collected in `input.md`) and compares it to the existing requirements and architecture documents.
The input may be fresh input, or may be a copy of a previously existing input-ledger, in which case the original authoring information (author, date and time) should be retained.
It carefully analyzes how to fit the input into the requirements and architecture documents (it may also create additional architecture documents if none of the existing ones are a good fit).
It can prompt the human for clarification (online in the session) and suggest improvements on the input before accepting the input.
When it accepts the input, it appends it — and any clarification it resolved — to the
`input-ledger.md` (date/time, and bullet points for each input line), and creates/updates the
requirements and architecture documents.
Afterwards it clears the `input.md`, making it ready for the next round of input by the user.
It commits the updated requirements/architecture and the appended ledger on the main branch as `facilitate: {summary}`.
Interactive (default): it may ask the human for clarification and wait for the answer.
Batch (no human available): it returns the open questions in its report and stops without clearing `input.md`, so the human can answer and re-invoke it.

### PLANNER

Type: SUBAGENT
Command: `/plan`.
Invoked by: HUMAN.
Precondition: none, can be invoked anytime.

Find out which changes have been made to the requirements and architecture documents since it was last invoked.
It then creates or updates tickets that define which changes are to be done in the project, and links them to the requirements (internally, in the `agent` folder).
It gives the ticket a number (sequence number, if possible) and a name, a description, a short task breakdown (checkbox list) and acceptance criteria (bullet list).
It also checks if any ticket in status IN_PROGRESS exists which is not claimed by an active subagent and whose branch does not exist, and sets it back to status READY.
A ticket whose branch still exists is left for the RECONCILER (see Branches).
It verifies the blocked-by attribute of existing tickets and checks if these tickets actually exist, and that no cyclic dependencies in the blockings exist.
When it needs a decision, it surfaces the gap or impediment explicitly — the open question,
the viable options, and which it recommends — and returns them in its report; it never
guesses and never blocks. On re-invocation with the human's answers (the human's clearance)
it records each resolved decision (gap, advice, decision, date/time, human user) in
`spec/agent/input-ledger.md` before creating or updating tickets.
It commits the created/updated tickets on the main branch as `plan: {summary}`.

### ANALYST

Type: SUBAGENT
Command: `/refine`.
Invoked by: HUMAN.
Precondition: none, can be invoked anytime.

Reviews the tickets in status DRAFT and compares them against the requirements and architecture documents.
It can also create or update tickets (in status DRAFT, READY) to bring the tickets in line with the requirements and architecture.
It checks and updates the blocked-by against other tickets, and makes sure no cyclic dependencies exist.
When it considers a ticket to be sufficiently defined and ready for implementation, it promotes the ticket's status to READY.
When it needs a decision, it surfaces the gap or impediment explicitly — the open question,
the viable options, and which it recommends — and returns them in its report; it never
guesses and never blocks. On re-invocation with the human's answers (the human's clearance)
it records each resolved decision (gap, advice, decision, date/time, human user) in
`spec/agent/input-ledger.md` before changing ticket status.
It commits the created/updated tickets on the main branch as `refine: {summary}`.

### IMPLEMENTOR

Type: SUBAGENT
Command: `/implement`.
Invoked by: HUMAN.

Precondition: at least one ticket READY, clean working tree, on main.

Repeat while a READY, unblocked ticket exists:
- finds the best one (BUG > IMPROVEMENT > STORY) and claims it.
- if a branch named `{id}-{type}-{name}` already exists, resume it when it holds this ticket's claim; otherwise stop and defer to `/reconcile`.
- create a feature branch from up-to-date main, named `{id}-{type}-{name}`.
- set the ticket STATUS: IN_PROGRESS and commit the claim on that branch.
- implement code, tests, configuration and documentation on the branch.

Tests covering the code changes are required.

When done, set the ticket STATUS: IN_REVIEW, commit, and hand it over in the report — the
orchestrating agent runs `/review` next. Never review your own ticket. The orchestrating
agent drives the implement → review → accept loop and re-invokes the IMPLEMENTOR for the
next READY ticket after the reviewer finishes; sync main first when a ticket was accepted
(merged). The loop runs until no READY, unblocked ticket remains or it gets stuck. Tickets
are processed sequentially, one branch at a time.

### REVIEWER

Type: SUBAGENT
Command: `/review`.
Precondition: at least one ticket in status IN_REVIEW.
Invoked by: the orchestrating agent, after the IMPLEMENTOR hands a ticket over in IN_REVIEW.

Looks at tickets in status IN_REVIEW and checks:
- all tasks are done and every acceptance criterion is fulfilled.
- the change is complete (code, tests, configuration, documentation) and includes tests for all new or changed behaviour.
- the build and tests are green; no test is skipped or flaky.
- the branch contains only changes within the ticket's scope; unrelated changes are a separate ticket.
- the branch is clean (all work committed) and rebased on the current main.

Test/coverage standards are not set here; they live in `architecture/quality-aspects.md` and `architecture/coding-guidelines.md`.

When it is satisfied with the result, it sets the ticket status to DONE and commits that change.
Otherwise, it comments on the ticket what else needs to be done before the ticket can be closed, and sets the ticket back to READY.
For an AUTOMATIC ticket the reviewer returns DONE so the orchestrating agent runs `/accept`; a HUMAN ticket stays DONE for the human.

### ARCHAEOLOGIST

Type: SUBAGENT
Command: `/excavate`.
Invoked by: HUMAN.
Precondition: `spec/` is bootstrapped and the project contains source code.

Reconstructs the functional reality: features, functions and domain models. It reads source code,
tests, database schemas/migrations, API specifications (e.g. OpenAPI), configuration, UI code and
existing documentation, then clusters what it finds into features with their functions and the
domain models involved.
Writes/updates `requirements/features/*.md` and `requirements/domain-models/*.md`, marking each
reconstructed item as inferred and citing its source (file, commit).
Open questions and low-confidence areas go into `spec/agent/reverse-engineering-report.md`.
It is incremental and idempotent: it keeps a hash ledger of the scanned sources and only revisits
what changed since the last run.

### SYSTEM-ARCHITECT

Type: SUBAGENT
Command: `/survey`.
Invoked by: HUMAN.
Precondition: `spec/` is bootstrapped and the project contains source code.

Reconstructs the non-functional reality: tech stack, decomposition, coding guidelines, quality
aspects and — where a UI exists — the design system. It reads build and dependency manifests
(e.g. `pom.xml`, `build.gradle`, `package.json`), the module/folder structure, formatter and linter
configuration, CI/CD pipelines and deployment definitions, UI/theming/style sources, and documents
the conventions the code actually follows.
Writes/updates the files under `architecture/`, again marked as inferred and with evidence.
Open questions and low-confidence areas go into `spec/agent/reverse-engineering-report.md`.

### GUIDE

Type: SUBAGENT
Command: `/guide`.
Invoked by: HUMAN.
Precondition: none.

Read-only: it changes nothing. It inspects the tickets, the requirements and architecture documents,
the git state and `spec/agent/`, and reports a single prioritized list of the next best actions, each
with a reason and the concrete tickets/branches it applies to.

It orders actions to unblock the process:
1. fix a broken repo state (interrupted rebase/merge, dirty tree, wrong branch).
2. `/facilitate` when `input.md` has unfacilitated lines.
3. `/plan` when requirements or architecture changed since the last plan.
4. `/refine` for tickets in DRAFT.
5. `/review` for tickets in IN_REVIEW (re-run the reviewer).
6. `/implement` when unblocked READY tickets exist.
7. `/accept` for DONE tickets awaiting human acceptance.
8. `/reconcile` when inconsistencies are detected.

It names any item that needs a human decision before the corresponding action can run.

### RECONCILER

Type: SUBAGENT
Command: `/reconcile`.
Invoked by: HUMAN.
Precondition: none.

Restores a consistent state across tickets, branches and main after an interrupted or failed run.
It audits first, then applies only safe, idempotent, non-destructive repairs, and reports what it
changed and what needs a human.

Audit:
- git: current branch, dirty tree, in-progress rebase/merge, stash; feature branches matching `{id}-{type}-{name}`.
- tickets: status and metadata; `blocked-by` targets exist and are acyclic; ids are unique.
- cross-checks: ticket status vs branch (missing, orphaned, already merged); a CLOSED ticket implies a
  merged branch and no leftover branch.
- release notes: every CLOSED ticket is covered; the version matches the build file.

Safe repairs (idempotent, never discard work):
- return to main and clean the working tree (never drop uncommitted work; stash it and report it).
- reset an abandoned IN_PROGRESS or IN_REVIEW ticket to READY; keep its branch and report it.
- delete branches already merged into main.
- remove dangling `blocked-by` references; report cycles.
- commit uncommitted planning artifacts (tickets, requirements) on main.
- flag items it must not touch (HUMAN tickets, missing release-note entries).

Never without confirmation: delete an unmerged branch, force-push, resolve content conflicts,
discard changes, or change a ticket whose acceptance-type is HUMAN.

Report: each finding with evidence and whether it was fixed or needs a human.

## Additional Commands

Additional commands have no named role, but are also expressed as a skill, with a matching command that invokes the skill.

### List open tickets

Command: `/tickets`.
Invoked by: HUMAN.

Shows all open (non-CLOSED) tickets, one row each, oldest first. It is mechanical and
precomputed: the read-only helper (`iap.sh open`, installed by `/bootstrap` at a
tool-independent path) emits the table and the agent prints it verbatim. The agent does not
open ticket files, parse front-matter, sort, pad, filter or reformat — and computes nothing
else. Per-status counts come from `iap.sh counts` when requested.

The helper emits one row per open ticket, space-aligned in exactly this column order:

| Column  | Value                                                    |
|---------|----------------------------------------------------------|
| ID      | zero-padded ticket number from `{id}-{type}-{name}.md`   |
| STATUS  | DRAFT, READY, IN_PROGRESS, IN_REVIEW, DONE               |
| TYPE    | STORY, IMPROVEMENT or BUG                                |
| TITLE   | the ticket's `#` heading                                 |
| CREATED | creation date-time, ISO-8601 format                      |

Columns are separated by two spaces, each padded to the widest value in its column, rows are
sorted oldest first, and CLOSED tickets are omitted.

### Accept

Command: `/accept`.
Precondition: at least one AUTOMATIC ticket in DONE (reviewer) or one HUMAN ticket in DONE (human).
Invoked by: the orchestrating agent (for the AUTOMATIC ticket(s) `/review` just accepted) or
HUMAN (for HUMAN tickets). In the implement/review/accept loop the orchestrator runs it
automatically for each accepted AUTOMATIC ticket; it may accept every eligible DONE ticket in
one run.

Accept the eligible DONE tickets, and for each:
- switch to the feature branch.
- update the release notes (create on-the-fly if missing), and verify the version is correct, using the build file's `{major}.{minor}` version (e.g. from `pom.xml`).
- set the accepted ticket to CLOSED.
- commit the release notes and ticket update on the feature branch.
- squash the commits into one, named as `{ticket-number}-{ticket-type}: {ticket-title}`.
- rebase the feature branch onto the main branch, resolve conflicts.
- switch back to the main branch.
- merge the feature branch (fast-forward only).
- delete the feature branch afterwards.

If the rebase cannot be resolved automatically, abort the rebase, leave the ticket DONE on its branch,
and report; never leave a half-rebased tree. `/reconcile` cleans up.

### Bootstrap

Command: `/bootstrap`.
Invoked by: HUMAN.
Precondition: a project root (empty, freshly initialized, or existing codebase).
On an existing project it only adds missing files and refreshes the process artifacts.

What it does:
1. Installs the process commands and skills for the active agent tool:
   FACILITATOR, PLANNER, ANALYST, IMPLEMENTOR, REVIEWER, ARCHAEOLOGIST, SYSTEM-ARCHITECT, GUIDE
   and RECONCILER, plus the additional commands `/tickets` and `/accept`, and the read-only
   helper `iap.sh` at the tool-independent path `.iap/iap.sh`.
2. Creates the missing parts of the `spec/` skeleton from the template: an empty
   `input.md` and the `requirements/`, `architecture/`, `tickets/` and `agent/` folders.
   Existing content is never overwritten; only absent files are created.
3. Creates a copy of the process in `spec/agent/idx-agentic-process.md`.
4. Writes `spec/agent/process-version.md`, recording the IAP version used, so the copy can later
   be updated or diffed.
5. It neither creates tickets nor invents requirements — those come from the human.

## Collaboration

Rules for collaboration when the project is a GIT repository.

### General

- The Git repository is the single source of truth for shared artifacts; only committed state counts.
- If a remote Git repository exists: pull before starting work, push when a work unit is complete.
- Never run two writing roles concurrently; serialize them; coordinate via spec/agent/.
- Setting `acceptance-type` or `blocked-by` is a metadata edit and does not change a ticket's status.

### Commits

Each planning role makes one commit per invocation on the main branch, a single-line message
`{command}: {summary}` — lowercase command (`facilitate`, `plan`, `refine`), a short
imperative summary of at most 200 characters (keep it terse), no body. If nothing changed, no
commit is made. `input.md` is local-only and is never committed.

- facilitate: payments feature, card model, retry policy
- plan: 0007 payments, 0008 refunds, 0009 audit
- refine: promote 0007-0009, block 0009 on 0007

### Invariants

These must always hold. Any role that finds one violated must report it and stop, not improvise around it:

- a ticket's status matches its branch: IN_PROGRESS/IN_REVIEW ⇒ its branch exists; DRAFT/READY ⇒ no branch; CLOSED ⇒ merged and branch gone.
- implementation changes reach main only through `/accept`.
- every ticket has a unique id and its filename matches the front-matter `id`.
- `blocked-by` references existing tickets and is acyclic.
- no two writing roles run concurrently.
- the process document is never edited by an agent.
- every human decision that changes requirements, architecture or tickets is recorded in `input-ledger.md`.

`/reconcile` validates and repairs these; `/guide` reports violations it cannot repair.

### Multiple humans

- `input.md` is local-only and listed in `.gitignore`: it is never committed; each human keeps
  their own copy.
- Only the input ledger is shared and versioned. It is append-only and records who made each
  change (human user name), date and time. Past entries are never rewritten or removed.
- Conflicts in co-owned (X) documents are resolved by the human who last edited the affected
  feature/domain model; if unclear, escalate in the merge-request discussion.

### Multiple agents

- Implementation changes reach main only through `/accept`; planning/requirements artifacts are committed directly on main.
- Claiming a ticket happens through a commit setting its status to IN_PROGRESS on the feature
  branch; no other agent picks up a claimed ticket.
- The PLANNER resets IN_PROGRESS to READY only when the ticket's branch does not exist;
  a ticket with an existing branch is handled by the RECONCILER (see Branches).
- An agent edits only files within the scope of its claimed ticket; unrelated changes are a new
  ticket.
- Rebase before claiming, commit after each acceptance criterion, and if a remote repository exists: push before handover. Never
  force-push a branch another agent depends on.

### Branches

- A feature branch is named `{id}-{type}-{name}`, one per ticket, created by the IMPLEMENTOR.
- Active: the ticket is IN_PROGRESS or IN_REVIEW and the branch is open.
- Merged: the branch is an ancestor of main; it is safe to delete and is removed by `/accept` or `/reconcile`.
- Abandoned: an IN_PROGRESS or IN_REVIEW ticket with no active agent and no commits since the claim
  (older than the configured threshold, or confirmed by the human). The RECONCILER resets the ticket to
  READY and renames the branch to `abandoned/{id}-{type}-{name}`.
- Only `/accept` merges; only `/reconcile` cleans up branches; an unmerged branch is never deleted.
- Untracked files that belong to the process (tickets, requirements) are committed, never discarded; unrelated untracked files are left alone.
- Two humans never share a ticket branch; each works on their own branch and merges via `/accept`.
- Abandoned branches are renamed `abandoned/{id}-{type}-{name}` by `/reconcile`; a merged branch is deleted.

### Handover and review

- The REVIEWER reviews the feature branch, not the working tree; a ticket is set to CLOSED before the branch is merged.
- A rejected ticket returns to READY; rebase onto main before rework.
- A CLOSED ticket is protected; follow-up work becomes a new ticket.
- For acceptance-type other than AUTOMATIC, the human reviews DONE tickets and runs `/accept` to merge them.

## Setup

### Installation

For a project-local installation, copy the `skills` and `commands` folders to the following
folder in your project:

- `.opencode` (for OpenCode)
- `.claude` (for Claude Code)

For a global installation, copy the `skills` and `commands` folders to:

- `~/.opencode` (for OpenCode)
- `~/.claude` (for Claude Code)

`/bootstrap` also installs the read-only helper at `.iap/iap.sh` (tool-independent, outside
the tool folders). Commit it so collaborators and cloud agents have it.

### Bootstrapping projects

A project is bootstrapped with the `/bootstrap` command.

After bootstrap:
1. The human describes the project in `spec/input.md`.
2. `/facilitate` turns that input into requirements and architecture documents.
3. Repeat the requirements loop until the picture is stable.
4. `/plan` creates tickets; `/refine` promotes them to READY.
5. `/implement` and `/review` drive the implementation loop.
6. `/accept` closes the implementation and merges the code.
7. Commit `spec/` together with the code.

Updating the process: re-run `/bootstrap` (or copy the template again). It only refreshes the
command/skill definitions, the read-only helper (`.iap/iap.sh`), the process copy
(`spec/agent/idx-agentic-process.md`) and the process marker; the content of `spec/requirements`,
`spec/architecture`, `spec/tickets` and `spec/agent/input-ledger.md` is never touched.
When a process change alters statuses, metadata fields or role contracts, re-running `/bootstrap`
updates the definitions and the process copy; the human then runs `/reconcile` to migrate existing
tickets and ledgers, and appends a short note to `spec/agent/input-ledger.md`.

### How to use this process in existing projects

For an existing project the process is adopted in slices: bootstrap the process first, then
reverse-engineer the current reality into the requirement and architecture documents over time.
It can be used before reverse-engineering is complete — the missing parts simply stay unresolved.

Reverse-engineering is itself agent work, provided by additional subagents (command + skill).
Because the requirement and architecture documents are co-owned (X), these agents never silently
overwrite human content: they write *provisional* content marked as inferred, together with the
evidence and a report in `spec/agent/`, and the human accepts or corrects it.

Order of adoption:
1. `/bootstrap` the process in the existing repository.
2. `/survey` and `/excavate` to reconstruct architecture and requirements (repeat as code changes).
3. The human reviews the inferred documents, corrects and accepts them (the requirements loop).
4. `/plan`, `/refine`, `/implement`, `/review` and `/accept` as usual.

Provenance:
- Requirement and architecture items may carry a marker such as `origin: human | inferred` and,
  optionally, a confidence.
- The first entry in `spec/agent/input-ledger.md` records the reverse-engineering event: date,
  source revision/commit, and the commands that were run.
