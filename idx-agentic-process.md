# idx AGENTIC PROCESS

THIS DOCUMENT MUST NOT BE ALTERED BY AGENTS, ONLY BY HUMANS.

The idx Agentic Process (short: IAP) is a development process primarily for building software projects at first. 
In later stages, it may evolve into a more generic development process, where building software is only one possible flavor.

It drives the development of a project in three loops:

- Requirements loop: define and detail the requirements, define constraints for building it (Human and Agent)
- Planning loop: create actionable tasks expressed as tickets. (Agent)
- Implementation loop: pick a ticket, and work on it, creating and refining the project incrementally. (Agent)

Participants in this process are:
- Human, or in larger projects, multiple human collaborators.
- Agent, employing subagents for specialized tasks. They can have a defined role/skill suitable for the task at hand.

## Artifacts and folder structure

Clear definition which files can be edited by the human (H), agent (A) or both (X).
```
project-root/
└─ spec/                        # Root folder of the process
   ├─ index.md                  # (X) Index file, describing the project
   ├─ input.md                  # (H) Human user input file, (A) clear the file.
   ├─ release-notes.md          # (X) Release notes of the current version (optional).
   ├─ requirements/             # (X) Requirements of this project
   │  ├─ domain-models/         # (X) Domain models
   │  │  └─ {model-name}.md     # (X) Domain model, with name, attributes and descriptions
   │  ├─ features/              # (X) Features of the domain
   │  │  └─ {feature-name}.md   # (X) Document per feature, describing the feature and the functionalities
   ├─ architecture/             # (X) Architectural design and requirements
   │  ├─ tech-stack.md          # (X) Tech stack, programming languages, frameworks and libraries
   │  ├─ decomposition.md       # (X) Decomposition into modules and packages
   │  ├─ coding-guidelines.md   # (X) Additional coding guidelines
   │  ├─ quality-aspects.md     # (X) Quality Aspects (= non-functional requirements)
   │  └─ ...                    # (X) Additional guidelines
   ├─ tickets/                  # (A) Tickets for the implementation
   │  └─ {id}-{type}-{name}.md  # (A) A ticket, with a distinct id, type and name
   └─ agent/                    # (A) Folder managed by the agent, it can document anything here
      ├─ input-ledger.md        # (A) Input ledger, append-only, new content from input.md
      └─ ...                    # (A) Any documents created by the agent, for the agent (or subagents)
```

## Index

The index file describes the project.

## Input

The idea to build the software comes from the human, which describes the project with a rough outline and expresses expectations about the domain of the project (models, functionality)
and how it should be built. This information comes in an unstructured form, where the human states facts, expectation, behaviour etc. as a stream of statements.
These statements are entered into an `input.md` file.

In an input session, the human writes down statements into the input file.
At some point, when enough new input has been collected, the human instructs the agent to facilitate the information. 

The agent then 
- reviews the input
- can prompt the user for clarification, with suggestions
- and then appends the input (verbatim, or a corrected version thereof) to the input-ledger (with the date, time and user), and then clears the input file.

It then decides what to make out of this information (new input, in the context of existing input):

- create/update the requirement documents (models, features, functions)
- create/update the architecture documents
- do nothing yet (unresolved input which we will periodically reviewed)

## Requirements

The requirements describe the features of the project. They are kept in an implementation-agnostic format, which is very important (the requirements do not make assumptions about the tech stack, frameworks or implementation).

### Feature

A feature is an isolated aspect of the project to be realized. It is the overall story arch over the functions in the feature.
Each feature has a set of functions describing atomic functionality as use cases, whose functionality usually revolves around the domain models
(e.g. list, find, view, edit, delete, ...).

Features drive the functional decomposition (modules, packages), whileas functions are usually manifested in external and internal APIs (e.g. REST endpoints, services, adapters).

### Domain models

A catalogue of conceptual domain models, with name, description and attributes. 
Each attribute also has a name, description and type (use programming-language agnostic types such as 'decimal', 'integer', 'string', 'date', 'date-time', 'currency').
Domain models are the main drivers for downstream implementation decisions (e.g. which parts of them to use in APIs, which parts of them are persisted).

## Architecture

The architecture describes the non-functional aspects of the project (how it's built).
It's the design of the system, with choices of the technology, decomposition and quality aspects.

## Tickets

Tickets define work units for implementing and changing the software. Tickets are created and processed without human intervention.
They eventually log the development process of the project.

### Template:

```
    # Title
    TYPE:   {ticket-type}
    STATUS: {ticket-status}
    CREATED-ON: {ISO date-time of creation}
    UPDATED-ON: {ISO date-time of last update}
    ---
    {ticket-description}
    ---
    {comments}
```

### Types:

- STORY (functional increment)
- IMPROVEMENT (non-functional change)
- BUG (reported bug)

### Status:

- DRAFT (refinement and acceptance needed)
- READY (ticket refined and ready to be implemented)
- IN_PROGRESS (claimed by an agent for implementation)
- IN_REVIEW (ticket successfully implemented, but needs to be reviewed before it can be closed)
- DONE (ticket passed review, ready to be merged and closed)
- CLOSED (ticket done and closed, protected from changes)

Status diagram:

```
    │ /plan (new requirement)
    │
    ▼
╭───────╮  /refine   ╭───────╮  /implement   ╭─────────────╮   (agent)     ╭───────────╮
│ DRAFT │───────────▶│ READY │──────────────▶│ IN_PROGRESS │──────────────▶│ IN_REVIEW │
╰───────╯            ╰───────╯               ╰─────────────╯               ╰───────────╯
    ▲                    ▲                          │                            │
    │                    ├◀────────/plan (reclaim)──┘                            │
    │                    └◀───────────────────/review (rework)───────────────────┤
    │                                                                            │ /review (accepted)
    │                                                                            ▼
    │                                                                        ╭──────╮
    └◀──────any edit (DRAFT / READY / DONE / IN_REVIEW)──────────────────────│ DONE │
                                                                             ╰──────╯
                                                                                 │ /accept (human)
                                                                                 ▼
                                                                            ╭────────╮
                                                                            │ CLOSED │
                                                                            ╰────────╯
                                                                            (terminal)
```

### State transitions

| FROM                       | TO          | TRIGGER                     | ACTOR      | GUARD                                         |
|----------------------------|-------------|-----------------------------|------------|-----------------------------------------------|
| —                          | DRAFT       | `/plan`                     | Planner    | new or changed requirement                    |
| DRAFT                      | READY       | `/refine`                   | Analyst    | sufficiently defined and realizable           |
| READY                      | IN_PROGRESS | `/implement`                | Implementor| claimed by setting status                     |
| IN_PROGRESS                | IN_REVIEW   | work complete               | Implementor| tasks done, acceptance criteria fulfilled     |
| IN_PROGRESS                | READY       | `/plan` (reclaim)           | Planner    | claim abandoned (not active, no open branch)  |
| IN_REVIEW                  | READY       | `/review` (rework)          | Reviewer   | comments state what remains                   |
| IN_REVIEW                  | DONE        | `/review` (accept)          | Reviewer   | accepted                                      |
| DONE                       | CLOSED      | `/accept` (accept)          | Human      | accepted, feature branch merged               |
| DRAFT/READY/IN_REVIEW/DONE | DRAFT       | content edit                | (anyone)   | forces re-refinement                          |
| CLOSED                     | —           | (none, terminal)            | —          | immutable; follow-up work is a new ticket     |

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

## Subagents

Subagents are started over commands. Each of them is manifested as an agentic skill which describes it and its modus operandi.

Commands are invoked by the human only.

Design guidelines for the agents:
- keep verbosity low, use more concise responses with minimal explanation.
- use plain english, not 'agentish'. Fluff-free, no corporate lingo ("delve", "leverage", ...)

### FACILITATOR
Command: `/facilitate`.
Precondition: `input.md` exists and is not empty.

Digests the human input (collected in `input.md`) and compares it to the existing requirements and architecture documents.
It carefully analyzes how to fit the input into the requirements and architecture.
It can prompt the human user for clarification and suggests improvements on the input before accepting the input.
When it accepts the input, it appends it to the `input-ledger.md` (date/time, and bullet points for each input line), 
and creates/updates the requirements and architecture documents.
Afterwards it clears the `input.md`, making it ready for the next round of input by the user.

### PLANNER
Command: `/plan`.
Precondition: none, can be invoked anytime.

Find out which changes were made to the requirements and architecture documents since it was last invoked.
It then creates or updates tickets that define which changes are to be done in the project, and links them to the requirements (internally, in the `agent` folder).
It gives the ticket a number (sequence number, if possible) and a name, a description, a short task breakdown (checkbox list) and acceptance criteria (bullet list).
Any change of a ticket will bring it back to status DRAFT.
It also checks if any ticket in status IN_PROGRESS exists which is not claimed by an active subagent, and sets them back to status READY.

### ANALYST
Command: `/refine`.
Precondition: none, can be invoked anytime.

Reviews the tickets in status DRAFT and compares them against the requirements and architecture documents.
It can also create or update tickets (in status DRAFT, READY) to bring the tickets in line with the requirements and architecture.
Also checks if a ticket is sufficiently defined, and can be realized, and if so, sets the ticket to status READY.

### IMPLEMENTOR
Command: `/implement`.
Precondition: at least one ticket in status READY.

Finds the next best ticket in status READY that can be worked on, and claims it by setting the status to IN_PROGRESS.
Ticket priorities: BUG > IMPROVEMENT > STORY.
Creates and updates code, tests, configuration and documentation.
When done with the ticket (all changes implemented, tasks done and acceptance criteria fulfilled), it sets the ticket to status IN_REVIEW.

### REVIEWER
Command: `/review`.
Precondition: at least one ticket in status IN_REVIEW.

Looks at tickets in status IN_REVIEW and checks if they are properly and completely implemented (code, tests, configuration, documentation),
if all tasks are done in the ticket, and verifies that the acceptance criteria is fulfilled.
When it is satisfied with the result, it sets the ticket status to DONE.
Otherwise, it comments on the ticket what else needs to be done before the ticket can be closed, and sets the ticket back to READY. 

### ARCHAEOLOGIST
Command: `/excavate`.
Precondition: `spec/` is bootstrapped and the project contains source code.

Reconstructs the functional reality: features, functions and domain models. It reads source code,
tests, database schemas/migrations, API specifications (e.g. OpenAPI), configuration, UI code and
existing documentation, then clusters what it finds into features with their functions and the
domain models involved.
Writes/updates `requirements/features/*.md` and `requirements/domain-models/*.md`, marking each
reconstructed item as inferred and citing its source (file, commit). Open questions and
low-confidence areas go into `spec/agent/reverse-engineering-report.md`.
It is incremental and idempotent: it keeps a hash ledger of the scanned sources and only revisits
what changed since the last run.

### SYSTEM-ARCHITECT
Command: `/survey`.
Precondition: `spec/` is bootstrapped and the project contains source code.

Reconstructs the non-functional reality: tech stack, decomposition, coding guidelines and quality
aspects. It reads build and dependency manifests (e.g. `pom.xml`, `build.gradle`, `package.json`),
the module/folder structure, formatter and linter configuration, CI/CD pipelines and deployment
definitions, and documents the conventions the code actually follows.
Writes/updates the files under `architecture/`, again marked as inferred and with evidence.

## Additional Commands

### Open tickets
Command: `/tickets`.
Shows a summary of all open (non-CLOSED) tickets, one row each with the ticket id, status, type, title and created-on (primary sort criteria, ascending).
Report tickets as one row per ticket, space-aligned, in exactly this column order:

| Column  | Value                                                    |
|---------|----------------------------------------------------------|
| ID      | zero-padded ticket number from `{id}-{type}-{name}.md`   |
| STATUS  | DRAFT, READY, IN_PROGRESS, IN_REVIEW, DONE               |
| TYPE    | STORY, IMPROVEMENT or BUG                                |
| TITLE   | the ticket's `#` heading                                 |
| CREATED | creation date as `MM-DD`                                 |

Separate columns with two spaces, pad each to the widest value in its column, and
sort rows oldest first. In the open-tickets view, omit CLOSED tickets.

### Accept
Command: `/accept`.

Accept all DONE tickets, and for each:
- update the release notes (create on-the-fly if missing, and verify the version is correct)
- squash the commits into one, named as `{ticket-number}-{ticket-type}: {ticket-title}`
- rebase the feature branch onto the main branch
- merge to the main branch.

### Bootstrap

Command: `/bootstrap`.
Precondition: a project root that does not yet contain a `spec/` folder — this may be an empty
directory, a freshly initialized repository, or an existing codebase.

What it does:
1. Installs the process commands and their subagent skills for the active agent tool (e.g.
   `.opencode/`): FACILITATOR, PLANNER, ANALYST, IMPLEMENTOR, REVIEWER, ARCHAEOLOGIST and
   SYSTEM-ARCHITECT, plus the additional commands `/tickets` and `/accept`.
2. Creates the missing parts of the `spec/` skeleton from the template: `index.md`, an empty
   `input.md` and the `requirements/`, `architecture/`, `tickets/` and `agent/` folders.
   Existing content is never overwritten; only absent files are created.
3. Writes `spec/agent/process-version.md`, recording the IAP version used, so the copy can later
   be updated or diffed.
4. It neither creates tickets nor invents requirements — those come from the human.

## Collaboration

Rules for collaboration when the project is a GIT repository.

### General

- The Git repository is the single source of truth for shared artifacts; only committed state counts.
- Edit rights (H/A/X) apply per file. An agent editing an (H) file is a process violation; a human
  editing an (A) file is allowed but counts as new input.
- Pull before starting work, push when a work unit is complete.

### Multiple humans

- `input.md` is local-only and listed in `.gitignore`: it is never committed; each human keeps
  their own copy.
- Only the input ledger is shared and versioned. It is append-only and records who made each
  change (human user name), date and time. Past entries are never rewritten or removed.
- Conflicts in co-owned (X) documents are resolved by the human who last owned the affected
  feature/domain model; if unclear, escalate in the merge-request discussion.

### Multiple agents

- Implementation happens on a feature branch, never on main, with separate commits per ticket.
- A human decides which tickets may be implemented, creates the feature branch, and issues the
  implementation commands for the selected tickets on that branch.
- Claiming a ticket happens through a commit setting its status to IN_PROGRESS on the feature
  branch; no other agent picks up a claimed ticket.
- The PLANNER resets a ticket to READY only when its claim is neither active nor reachable as an
  open branch.
- An agent edits only files within the scope of its claimed ticket; unrelated changes are a new
  ticket.
- Subagents of one agent share the branch and working tree and coordinate via `spec/agent/`.
- Rebase before claiming, commit after each acceptance criterion, push before handover. Never
  force-push a branch another agent depends on.

### Handover and review

- The REVIEWER reviews the feature branch, not the working tree; a ticket can only reach CLOSED
  once its branch is merged.
- When the branch's tickets are done, the human creates a merge request into main. The merge is
  fast-forward only, so rebase the branch onto main first.
- A rejected ticket returns to READY; rebase onto main before rework.
- A CLOSED ticket is protected; follow-up work becomes a new ticket.

## Setup

### Installation

For a project-local installation, copy the `skills` and `commands` folder to the following
folder in your project:

- `.agents` (unified installation for OpenCode, Copilot, Cursor, Codex, ...)
- `.claude` (for Claude Code)

For a global installation, copy the `skills` and `commands` folder to:

- `~/.agents` (unified installation for OpenCode, Copilot, Cursor, Codex, ...)
- `~/.claude` (for Claude Code)

### Bootstrapping projects

A project is bootstrapped with the `/bootstrap` command.

After bootstrap:
1. The human describes the project in `spec/input.md`.
2. `/facilitate` turns that input into requirements and architecture documents.
3. Repeat the requirements loop until the picture is stable.
4. `/plan` creates tickets; `/refine` promotes them to READY.
5. `/implement` and `/review` drive the implementation loop.
6. `/accept` closes the implementation and merges the code (Human-in-the-loop).
7. Commit `spec/` together with the code.

Updating the process: re-run `/bootstrap` (or copy the template again). It only refreshes the
command/skill definitions and the process marker; the content of `spec/requirements`,
`spec/architecture`, `spec/tickets` and `spec/agent/input-ledger.md` is never touched.

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
- Inferred content stays provisional until a human confirms it; a status/gap view (e.g. `/tickets`)
  lists what is still inferred or unresolved.
- The first entry in `spec/agent/input-ledger.md` records the reverse-engineering event: date,
  source revision/commit, and the commands that were run.
