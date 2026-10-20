# idx AGENTIC PROCESS

THIS DOCUMENT MUST NOT BE ALTERED BY AGENTS, ONLY BY HUMANS.

The idx Agentic Process (short: IAP) is a development process primarily for building software projects at first.
In later stages, it may evolve into a more generic development process, where building software is only one possible flavor.

It drives the development of a project in an iterative process:

- Requirements: define and detail the requirements, define constraints for building it (Human and Agent).
- UI Design: define and detail screens as screen documents, with data, actions, navigation, interactions and states, and review them through a generated prototype (Human and Agent).
- Planning: create actionable tasks expressed as tickets. (Agent).
- Implementation: pick a ticket, and work on it, creating and refining the project incrementally (Agent).
- Review: review implemented tickets on feature branches, and either accept the tickets or add comments on what needs to be adjusted (Agent or Human).

Participants in this process are:
- Human, or in larger projects, multiple human collaborators.
- Agents for specialized tasks. They can have a defined role/skill suitable for the task at hand.

The process enables the human-in-the-loop, but does not enforce it.

## Typical human workflow

The human drives the loop; the agent does the ticket work.

Before the first loop, copy the `commands/` and `skills/` folders into the project's agent
folder and run `/bootstrap` once. It creates `spec/` and an empty `spec/input.md`; every other
spec file is generated on first use by the role that writes it.

1. **Capture input**: add facts to `spec/input.md`, then run `/facilitate`. It folds the input into the
   requirement and architecture documents, appends it to the input ledger, and clears `input.md`.
2. **Review (optional)**: read the updated `requirements/` and `architecture/` documents; repeat step 1
   until the picture is stable.
3. **Settle the project shape (before planning)**: run `/facilitate` for the artifact and
   tech-stack interview — what the project delivers, and the language, language version and
   stack. A single-subproject project records this in `architecture/tech-stack.md`; a project
   with more than one subproject uses `spec/modules/{module}/`. `/plan` refuses until the shape
   is `agreed`. Existing projects can start from `/survey`'s inferred shape.
4. **Design UI (projects with a UI)**: run `/design` to create or update the affected screen
   documents and the review prototype. Review the prototype and the screen documents, answer open
   questions, and repeat until the screen documents are `approved`. Skip this step for projects
   without a UI. UI design is iterative with step 1; rerun `/design` when requirements or
   architecture change.
5. **Plan**: run `/plan`, then inspect the created/updated tickets with `/tickets`. UI tickets are
   created only from `approved` screen documents.
6. **Refine**: run `/refine` to promote sufficiently defined tickets to READY. UI tickets stay DRAFT
   until their screen documents are approved and the documented data, actions, navigation,
   interactions and states are covered.
7. **Mark acceptance (optional)**: set `acceptance-type: HUMAN` on the tickets you want to accept
   yourself; leave the rest on the default AUTOMATIC. UI tickets that change user-visible screens
   default to HUMAN. This is a metadata edit — it does not change the ticket's status.
8. **Implement**: run `/implement` once. It drives the implement → review → accept loop: the agent
   works through the READY, unblocked tickets one at a time, AUTOMATIC tickets are reviewed and
   accepted (merged) automatically, and HUMAN tickets are implemented and left for you. The loop
   runs until no workable ticket remains or it gets stuck (an impediment, or a decision that needs
   you), then reports what remains and why. Each ticket runs in a fresh context and the loop
   compacts after accepted tickets; if the session is cleared, run `/implement` again and it
   resumes from the tickets and branches.
9. **Accept manually**: inspect the tickets awaiting your acceptance (status DONE with
   `acceptance-type: HUMAN`) and run `/accept` to merge them, or comment on a ticket to send it
   back to DRAFT.
10. **Recover / re-orient**: after any interruption, or when unsure, run `/reconcile` to restore a
    consistent state and `/guide` to see what to do next. Start a new session at a phase change —
    requirements or design settled, a new work batch — instead of carrying the old context.

## Definitions

- main branch: the repository's default branch (commonly `main` or `master`); referred to as `main` below. Where a remote exists, its default branch is authoritative.
- project shape: the artifact kind(s) and tech stack(s) of the project. A single-subproject project records it in `spec/architecture/tech-stack.md`; a multi-subproject project records one module per subproject under `spec/modules/{module}/`.
- module: a subproject with its own build/package unit and tech stack, used only when the project has more than one subproject.
- agreed shape: a single-subproject `tech-stack.md` with `status: agreed`, or every module with `status: agreed`, in both cases naming the artifact kind, language and version; only an agreed shape may be planned.
- screen document: a co-owned Markdown file under `spec/requirements/user-interface/screens/` containing one primary `gui-v2` screen definition plus purpose, data, actions, navigation, interactions, states, accessibility notes and open questions. Its status is `draft`, `review`, `approved`, `implemented` or `deprecated`.
- approved screen: a screen document with status `approved`; the only state from which UI implementation tickets may be planned.
- prototype: a generated HTML review artifact under `prototypes/`, built by the project's prototype builder from a screen document and example data. The builder is project tooling — created or maintained by UI-DESIGNER on first use and committed with the project — not a predefined IAP component. It is not production code and is never hand-edited.
- UI ticket: a ticket that changes a user-visible screen. It references one or more `ui-screens`, and defaults to `acceptance-type: HUMAN` unless the change is mechanical and covered by screenshot/visual regression tests.

## Artifacts and folder structure

A clear definition of which files are owned by the human (H), agent (A) or both (X).
```
project-root/
├─ spec/                                # Root folder of the process
│  ├─ input.md                          # (X) Human writes input; Agent only clears it after `/facilitate`, never edits content.
│  ├─ release-notes.md                  # (X) Release notes of the current version (optional).
│  ├─ requirements/                     # (X) Requirements of this project
│  │  ├─ domain-models/                 # (X) Domain models
│  │  │  └─ {model-name}.md             # (X) Domain model, with name, attributes and descriptions
│  │  ├─ features/                      # (X) Features of the domain
│  │  │  └─ {feature-name}.md           # (X) Document per feature, describing the feature and the functionalities
│  │  └─ user-interface/                # (X) UI requirements; never implementation or bundled references
│  │     ├─ screens/{screen-name}.md    # (X) Screen definition + data, actions, navigation, interactions, states
│  │     ├─ flows/{flow-name}.md        # (X) Entry/exit, ordered screens, shared state, back/cancel behavior
│  │     ├─ theme.gui                   # (X) Project theme and token overrides
│  │     ├─ components/components.gui   # (X) Project-defined extended components
│  │     ├─ assets/{file}               # (X) Design assets referenced by screens (images, review photos)
│  │     └─ data/{screen-name}.json     # (X) Named scenarios and reserved `_state`
│  ├─ architecture/                     # (X) Architectural design and requirements
│  │  ├─ tech-stack.md                  # (X) Single-subproject shape (created by shape refinement)
│  │  ├─ integration.md                 # (X) Integration with other systems, APIs (ports and adapters).
│  │  ├─ decomposition.md               # (X) Project-level module map (multi) or package map (single)
│  │  ├─ coding-guidelines.md           # (X) Additional coding guidelines
│  │  ├─ quality-aspects.md             # (X) Quality Aspects (= non-functional requirements)
│  │  ├─ prototype-builder.md           # (X) Prototype-builder contract: command, inputs, outputs (tooling, not a requirement)
│  │  └─ ...                            # (X) Additional guidelines
│  ├─ modules/                          # (X) Only when the project has more than one subproject
│  │  └─ {module}/                      # (X) One folder per module
│  │     ├─ module.md                    # (X) Artifact kind, purpose, boundaries, dependencies, status
│  │     └─ tech-stack.md                # (X) Language/version, frameworks, runtime, libraries, tooling
│  ├─ tickets/                          # (X) Tickets for the implementation
│  │  └─ {id}-{type}-{name}.md          # (X) A ticket, with a distinct id, type and name
│  └─ agent/                            # (A) Agent-managed folder; bundled refs are read-only, test-strategy is co-owned
│     ├─ input-ledger.md                # (A) append-only seed: accepted input and resolved clarifications
│     ├─ ticket-index.md                # (A) tickets ↔ requirements/architecture links
│     ├─ planning-log.md                # (A) last-seen revision/hash of spec/
│     ├─ source-ledger.md               # (A) hash ledger of scanned sources
│     ├─ reverse-engineering-report.md  # (A) open questions from `/excavate` & `/survey`
│     ├─ lessons-learned-{role}.md      # (A) reusable lessons for one role (see Reflection)
│     ├─ gui-spec.md                    # (A) Bundled UI design guide and normative gui-v2 specification (never edit)
│     ├─ screen-workflow.md             # (A) Bundled screen authoring, review and prototype workflow (never edit)
│     ├─ test-strategy.md               # (X) Project-owned test levels and required coverage (created by `/bootstrap`)
│     ├─ process-version.md             # (A) IAP version used
│     └─ idx-agentic-process.md         # (A) copy of this process
└─ prototypes/                          # (A) Generated review HTML; do not edit by hand
   ├─ index.html                        # (A) Screen index, status, route, scenarios, build time
   ├─ screens/{screen-name}.html        # (A) Generated screen page
   └─ assets/                           # (A) Generated theme, component and runtime assets
```

`/bootstrap` creates only the folder skeleton, `input.md`, the bundled documents under
`spec/agent/` and `test-strategy.md`. Everything else is generated on first use by the role
that owns it: a role creates the file and parent directory when it first writes, and treats a
missing file it only reads as "not defined yet". A missing spec file is not an error.
`test-strategy.md` is the exception among the seeded documents: it is project-owned, created
once by `/bootstrap` and refined by the project.

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

UI input follows the same path: FACILITATOR records the human decision in the input-ledger and
the requirements/architecture documents. UI-DESIGNER (`/design`) then turns it into screen
documents, project theme/components and a review prototype. FACILITATOR does not edit
`spec/requirements/user-interface/screens/`,
`spec/requirements/user-interface/theme.gui` or
`spec/requirements/user-interface/components/components.gui` directly.

Clarifications are input too: questions raised by FACILITATOR, UI-DESIGNER, PLANNER, ANALYST
or REVIEWER (technology choices, implementation variants, ambiguous requirements, UI
data/actions/behavior) and the human's answers are recorded before the role acts on them —
the durable, project-level part in `input-ledger.md`, ticket-local details on the affected
ticket. Like facilitated input, these entries are append-only and carry date/time, human user
and the resolution. FACILITATOR records the `input.md` it accepts and any
clarification it resolves; DESIGN, PLAN, REFINE and REVIEW record the clarifications they
resolve, so they are not lost and are not re-recorded if the same fact later arrives via
`input.md`.

Recorded input is ticket-agnostic and implementation-agnostic. Every ledger entry states a
fact, requirement, constraint or decision in plain terms, without referencing tickets (no
ids, titles, branches) and without referencing existing code (no files, symbols or
implementation details). The ledger drives the tickets and the implementation, which happen
downstream; the tickets and the code never flow back into the ledger.

No role guesses past ambiguity. When a role finds a gap or an impediment that needs a human
decision (missing or ambiguous requirements, a technology or implementation choice,
conflicting constraints, a blocker, a ticket that cannot be made READY), it asks
interview-style: one compact numbered set; for each question, the gap, two or three viable
options with trade-offs, a recommendation and why, and what the answer changes. It records
the open questions where the work resumes — the ticket's comments for PLANNER, ANALYST and
REVIEWER, or the screen document's open questions for UI-DESIGNER — returns them in its
report and stops. It never blocks and never improvises. Only once the human has decided does
it record the decision (gap, advice, decision, date/time, human user) in `input-ledger.md`,
phrased as ticket-agnostic, implementation-agnostic input; note a ticket-local clarification
on the affected ticket; and continue.

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
It's the design of the system, with choices of the technology, decomposition, quality aspects
and, for projects with a user interface, the UI design artifacts.

### Project shape: artifacts and tech stack

Before planning, settle what the project delivers and how it is built. A project has one or
more artifacts: a backend service, a library, a web app, a mobile app, a desktop app, a CLI
tool, and so on.

**A project with one subproject does not need modules.** Record its shape in
`spec/architecture/tech-stack.md`:

```markdown
---
artifact-kind: {backend | library | web-app | mobile-app | desktop-app | cli | ...}
status: draft | agreed
---
# Tech Stack

- **Language:** {language}
- **Language version:** {exact version}
- **Framework / runtime:** {framework and version, or not applicable}
- **Key libraries:** {libraries and versions, or not applicable}
- **Build / package tooling:** {tool, or not applicable}
- **Test tooling:** {tool, or not applicable}
- **Infrastructure / deployment:** {platform, or not applicable}
```

If one package combines kinds (for example a library and its CLI), list them in
`artifact-kind` and explain the packaging. There is no `spec/modules/` folder for a
single-subproject project.

**A project with more than one subproject uses modules.** Each subproject is a module under
`spec/modules/{module}/`:

```
spec/modules/{module}/
├─ module.md      # (X) artifact kind, purpose, responsibilities, boundaries, dependencies, status
└─ tech-stack.md  # (X) language and version, frameworks, runtime, libraries, build/test tooling
```

`{module}` is a lower-kebab-case name, unique in the project.

`module.md` has front matter:

```markdown
---
module: {module}
artifact-kind: {backend | library | web-app | mobile-app | desktop-app | cli | ...}
status: draft | agreed
---
# {Module}

## Purpose
## Responsibilities
## Boundaries
## Dependencies
## Open questions
```

A module normally has one artifact kind. If a module combines kinds, list them all and explain
the packaging in `module.md`.

`tech-stack.md` (project-level or per module) must name the language and its exact version. Add
the framework and version, runtime/platform, key libraries, build/package tooling, test tooling
and infrastructure/deployment where they apply. Write "not applicable" instead of leaving a
field empty.

`status: agreed` is a human decision: the agent writes or proposes the shape, the human accepts
it. A shape is settled when it is `agreed`, its `tech-stack.md` names the artifact kind,
language and version, and it has no blocking open question.

`spec/architecture/decomposition.md` is the project-level map. For multiple subprojects it lists
the modules, their responsibilities and dependency direction, and links to each module folder.
For a single subproject it describes the internal packages/layers. It does not repeat the stack
details.

### Project-shape refinement

Before the first `/plan`, the project shape is settled in an interview. This is the
pre-planning refinement stage, run by the FACILITATOR as part of the requirements loop. The
agent asks, proposes concrete options with trade-offs and a recommendation, and the human
chooses. The agent never chooses a stack silently.

1. **Artifact kinds.** Ask what the project delivers: backend, library, web app, mobile app,
   desktop app, CLI tool, and so on. If it is one subproject, settle it as a single project
   shape. If it is more than one, propose one module per subproject, with a name and a one-line
   responsibility.
2. **Settle the shape.** For a single subproject: artifact kind, language and exact version,
   framework/runtime, key libraries, build/package and test tooling, and
   infrastructure/deployment where relevant. For each module: the same, plus purpose,
   responsibilities, boundaries and dependencies on other modules.
3. **One decision at a time.** Ask in dependency order and wait for the human's choice. If the
   project already has code, the SYSTEM-ARCHITECT may infer a draft shape first; present it for
   confirmation instead of asking from scratch.
4. **Record the decisions.** Append each resolved decision — question, options,
   recommendation, chosen answer, date/time and human user — to
   `spec/agent/input-ledger.md` before writing the documents.
5. **Write the documents.** For a single subproject, write
   `spec/architecture/tech-stack.md` and remove `spec/modules/` if it exists. For multiple
   subprojects, create `spec/modules/{module}/module.md` and `tech-stack.md` for each, update
   `architecture/decomposition.md`, and remove `architecture/tech-stack.md`. Set
   `status: agreed` only after the human accepts the shape.
6. **Keep it current.** When the artifact kind, boundaries or stack changes later, set the
   affected shape back to `draft`, update the documents, return affected tickets to DRAFT and
   replan. If a project grows from one subproject to several (or shrinks), migrate between the
   single `tech-stack.md` and the module folders, update `decomposition.md`, and return affected
   tickets to DRAFT. Never change the stack under an in-progress ticket without reopening the
   shape.

`/plan` refuses to create tickets when the shape is not settled: for a single subproject,
`architecture/tech-stack.md` is missing, not `agreed`, or lacks the artifact kind, language or
version; for multiple subprojects, `spec/modules/` is missing, any module is not `agreed`, or a
module's `tech-stack.md` lacks the language or version. It also refuses an ambiguous shape (a
project-level `tech-stack.md` together with modules, or multiple subprojects without modules).
It reports the missing decisions and points back to the refinement interview.

UI work uses two bundled references under `spec/agent/`:

- `gui-spec.md` is the UI design guide and the normative, versioned `gui-v2` specification:
  syntax, tokens, layout, components, patterns, accessibility, platform mapping, validation
  and conformance tests. It is a reference, not a per-project design decision.
- `screen-workflow.md` is the screen authoring, review and prototype workflow: roles,
  screen-document structure, data, actions, navigation, interactions, states, review and
  prototype generation.

Project-specific UI requirements live under `spec/requirements/user-interface/`:

- `screens/{screen-name}.md` — screen documents. One primary screen per file, with a
  `gui-v2` block, data/bindings, actions, navigation, interactions, states, accessibility
  notes and open questions. Owned by UI-DESIGNER and the human; status is `draft`, `review`,
  `approved`, `implemented` or `deprecated`.
- `flows/{flow-name}.md` — multi-screen journeys.
- `components/components.gui` — shared project-defined extended components.
- `theme.gui` — project theme and token overrides.
- `data/{screen-name}.json` — example data and scenarios.

The prototype-builder contract is tooling, not a requirement: `spec/architecture/prototype-builder.md`.
The builder itself is project code, not part of IAP. Generated review HTML stays in `prototypes/`
and is never hand-edited.

UI design is a stage between architecture and planning:

1. UI-DESIGNER (`/design`) drafts or updates screen documents and generates the prototype.
2. The human reviews the prototype and the screen documents, resolves open questions and
   moves the documents to `approved`.
3. PLANNER creates UI tickets only from approved screen documents.

UI design is iterative with requirements and architecture. When they change, rerun
`/design`; affected screen documents return to `review`, and affected tickets return to
`DRAFT`.

Which agents use the UI artifacts:

- **UI-DESIGNER** creates and updates screen documents, flows, project theme/components,
  example data and the review prototype. It does not create implementation tickets.
- **FACILITATOR** records UI decisions in the input-ledger and requirements/architecture.
  It does not edit screen documents directly.
- **PLANNER** uses approved screen documents to create UI tickets, and links the screen
  document, `gui-spec.md` sections and prototype in each ticket.
- **ANALYST** verifies that UI tickets reference approved screen documents and do not invent
  tokens, components, layout, data, actions or behavior.
- **IMPLEMENTOR** implements from the screen document and `gui-spec.md`, using the prototype
  as a visual reference.
- **REVIEWER** checks implemented UI against the screen document, `gui-spec.md`,
  accessibility and the documented states/interactions.
- **SYSTEM-ARCHITECT** reconstructs project theme/components and inferred screen documents
  from the observed UI. It does not rewrite the bundled `gui-spec.md` or
  `screen-workflow.md`.
- **GUIDE** and **RECONCILER** include UI artifacts in their checks.

Projects without a UI skip `/design` and do not use `gui-spec.md`, `screen-workflow.md`,
`spec/requirements/user-interface/screens/`, `spec/requirements/user-interface/flows/` or
`prototypes/`.

## Tickets

Tickets are created and processed mostly automatically by the agent.
Humans may occasionally write tickets themselves, using the template with a unique `id` and `status: DRAFT`.

The human acts as:
- an orchestrator (using `/facilitate`, `/design`, `/plan`, `/refine`, `/implement` and `/accept`).
- the approver of screen documents and prototypes.
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
- `ui-screens`: list of screen ids affected by a UI ticket. Required for UI tickets; absent for non-UI tickets.
- `prototype`: path to the generated review prototype (optional; usually one per screen).

Setting `acceptance-type`, `blocked-by`, `ui-screens` or `prototype` is a metadata edit and does
not change a ticket's status. UI tickets that change user-visible screens default to
`acceptance-type: HUMAN`; AUTOMATIC is acceptable only for mechanical UI changes covered by
screenshot or visual-regression tests.

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

UI is a dimension, not a ticket type. A UI ticket is any ticket with `ui-screens`; its type
remains STORY, IMPROVEMENT or BUG so release notes and branch naming stay unchanged.

#### Status

- DRAFT (refinement and approval needed)
- READY (ticket refined and ready to be implemented)
- IN_PROGRESS (claimed by an agent for implementation)
- IN_REVIEW (ticket successfully implemented, but needs to be reviewed before it can be closed)
- DONE (ticket passed review, ready to be merged and closed)
- CLOSED (ticket done and closed, protected from changes)

#### Acceptance Type
- AUTOMATIC (default, Agent reviews and accepts the ticket)
- HUMAN (set by Human, Agent reviews, Human reviews again and accepts the ticket). UI tickets
  that change user-visible screens default to HUMAN; planning sets this automatically unless
  the human overrides it.

### Template

```
---
id: {id}
created: {created}
type: {type}
status: {status}
acceptance-type: {acceptance-type}
blocked-by: {blocked-by}
ui-screens: {ui-screens}
prototype: {prototype}
---
# Title
## Description
{what and why; link the requirement(s) and, for UI tickets, the approved screen document(s)}
## UI
{omit for non-UI tickets}
- Screens: {spec/requirements/user-interface/screens/...}
- Prototype: {prototypes/screens/...}
- States: {default, loading, empty, error, ...}
- Interactions: {refresh, filter, sort, ...}
- Design status: {approved}
## Tasks
- [ ] {task}
## Acceptance criteria
- {verifiable outcome}
{UI tickets only:}
- The implementation matches the approved screen document and `gui-spec.md`.
- Tokens, components and patterns come from the guide; no one-off styling.
- Documented data, actions, navigation, interactions and states are covered.
- Accessibility and responsive/platform behavior are verified.
- The prototype or screenshot comparison is reviewed.
---
## Comments
```

### Comments

During work, `## Comments` is an append-only running log: dated notes from `/plan`, `/refine`,
`/implement`, `/review`, planning clarifications, review questions/answers and human
decisions. Never rewrite or remove them while the ticket is open.

When `/accept` closes a ticket, it replaces the running log with one concise, dated
post-merge summary. This is the only permitted rewrite of a ticket's comments. Keep only
information that still has value after the merge — decisions and their rationale, caveats or
known limitations, operational notes, verification evidence, and follow-up work. Drop process
chatter, resolved rework, duplicates and anything superseded by the final code, requirements,
architecture or release notes. A useful test: would this help someone reading the closed
ticket or the code later? If not, do not keep it.

If a durable fact belongs in the requirements, architecture or release notes rather than the
ticket, put it there and leave at most a short reference in the summary.

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
    └◀────────────────────── scope-changing edit of a ticket─────────────────│ DONE │
                                                                             ╰──────╯
                                                                                 | /accept (human or agent)
                                                                                 ▼
                                                                            ╭────────╮
                                                                            │ CLOSED │
                                                                            ╰────────╯
                                                                            (terminal)
```

Screen documents have their own lifecycle (`draft → review → approved → implemented →
deprecated`) and do not use the ticket status diagram. A UI ticket may only be planned from an
`approved` screen document.

#### State transitions:

| FROM                       | TO          | TRIGGER                       | ACTOR                                     | GUARD                                        |
|----------------------------|-------------|-------------------------------|-------------------------------------------|----------------------------------------------|
| —                          | DRAFT       | `/plan`                       | Planner                                   | new or changed requirement                   |
| DRAFT                      | READY       | `/refine`                     | Analyst                                   | sufficiently defined and realizable; for UI tickets, referenced screen docs approved |
| READY                      | IN_PROGRESS | `/implement`                  | Implementor                               | claimed by setting status                    |
| IN_PROGRESS                | IN_REVIEW   | work complete                 | Implementor                               | tasks done, acceptance criteria fulfilled    |
| IN_PROGRESS                | READY       | `/plan` (reclaim)             | Planner                                   | claim abandoned (not active, no open branch) |
| IN_REVIEW                  | READY       | `/review` (rework)            | Reviewer                                  | comments state what remains                  |
| IN_REVIEW                  | DONE        | `/review` (accept)            | Reviewer                                  | accepted                                     |
| DONE                       | CLOSED      | `/accept` (accept)            | Orchestrator (AUTOMATIC) or Human (HUMAN) | accepted, feature branch can be merged       |
| DRAFT/READY/IN_REVIEW/DONE | DRAFT       | scope-changing edit of a ticket | (anyone)                                | forces re-refinement                         |
| CLOSED                     | —           | (none, terminal)              | —                                         | immutable; follow-up work is a new ticket    |

`/review` may append review questions and answers to a ticket's comments without changing its
status; the ticket stays `IN_REVIEW` until the review concludes. Questions and answers use
stable `RQ` ids so a later `/review` resumes them instead of re-asking.

## Release Notes

The release notes are stored in `release-notes.md` and updated when a ticket is accepted.
The release notes file will be cleared by the human when bumping the major/minor version.
The tickets will be added under the appropriate heading:
- STORY -> "New Features"
- IMPROVEMENT -> "Improvements"
- BUG -> "Bugfixes"

UI tickets use their normal type; there is no separate UI release-notes heading.

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

Release notes are not created by `/bootstrap`; they are created on-the-fly by `/accept` when missing.

## Roles

Each named role is expressed as a skill, with a matching command that invokes the skill.

Depending on the role, it can be:
- the primary agent (Type: PRIMARY)
- or a subagent (Type: SUBAGENT) running in its own isolated context as a subtask, so role work never pollutes the orchestrator's context.

A SUBAGENT role never blocks on input: it returns its questions/blockers in the final report, and the invoking agent relays them to the human and re-invokes the role with the answers.

For SUBAGENT skills, the invoking (orchestrating) agent must not perform the role's work itself — it selects the role, passes the arguments, and relays the result.

Each SUBAGENT command invocation starts its role in a clean context (to prevent context
pollution); a previous role session is never resumed. The PRIMARY role runs interactively in
the current session. The conversation is a cache — tickets, `spec/`, the input ledger and git
are the only durable handover state.

Each role section lists the spec documents it reads (`Works with`) and the spec files it may
create, edit or delete (`May modify`). Anything not listed under "May modify" is read-only for
that role; the (H)/(A)/(X) edit rights still apply. No role edits the process definition or the
bundled references (`spec/agent/gui-spec.md`,
`spec/agent/screen-workflow.md`). In addition, every writing role may maintain its own
`spec/agent/lessons-learned-{role}.md`.

### Role loop (handover)

The IMPLEMENTOR loops only up to the handover. When it sets a ticket to IN_REVIEW and
reports, the *orchestrating agent* (the one that invoked `/implement`) runs the REVIEWER in
a separate SUBAGENT context for that ticket. Roles never invoke each other — only the
orchestrator sequences them, one writing role at a time.

The orchestrator then drives implement → review → accept as a single loop, without returning
to the human after each ticket. Every role step below runs in a fresh SUBAGENT context; never
continue a previous role session:

1. run the REVIEWER on the IN_REVIEW ticket;
2. if the reviewer rejected it (READY), re-invoke the IMPLEMENTOR in a fresh context to
   rework that ticket;
3. if the reviewer accepted an AUTOMATIC ticket (DONE), run `/accept` in a fresh context to
   merge and close it, then sync `main` and re-invoke the IMPLEMENTOR in a fresh context for
   the next READY ticket;
4. a HUMAN ticket accepted by the reviewer stays DONE — leave it for the human and continue
   with the other workable tickets;
5. after every few `/accept` runs (for example every five closed tickets), compact the
   orchestrating session and re-orient from `/tickets` and git. If the host cannot compact
   from inside the session, continue to the next safe barrier and ask the human to compact or
   start a fresh session at the end of the batch;
6. repeat until no READY, unblocked ticket remains, or it is stuck — an impediment, a
   violated invariant, or a decision that needs a human. On a stuck loop it stops and reports
   what remains and why.

This is the "implement as much as possible until stuck" loop: it closes AUTOMATIC tickets end
to end (implement, review, accept) in one run, and only pauses for HUMAN acceptance or a
human decision.

UI-DESIGNER is a design-stage role. It runs before planning, not inside the implement → review
→ accept loop; its output is the approved screen document that UI tickets implement.

### Context hygiene and checkpoints

Implementation is the most context-heavy stage: source files, diffs, build and test output,
ticket comments and review rounds all accumulate. The conversation is a cache, not the
record. Tickets, `spec/`, the input ledger and git are the durable state, so any role can be
replaced by a fresh context at a checkpoint.

- **Fresh context per invocation.** Every SUBAGENT command starts its role in a new context.
  Never continue or reuse a previous role session, and never pass a previous session id.
  Rework and resume are new invocations that read the ticket, branch and git state.
- **Thin orchestrator.** The orchestrating session only selects the role, passes the
  arguments and relays the report. It does not read source files, diffs, build logs,
  requirements/architecture or whole tickets. It uses `/tickets` and short git status
  commands, and gets detail from the role's report or the files the report names.
- **Bounded handover.** A role report is at most about 200 words: status (`done`,
  `checkpoint` or `blocked`), ticket id, branch and commit, verification evidence as command
  and result, and blockers. No code, diffs, logs, file dumps or restating the task. Durable
  detail goes to the ticket's `## Comments`, the screen document, the ledger or the commit.
- **Checkpoint before the context gets large.** Do not wait for automatic compaction: as a
  rule of thumb, a role checkpoints by the time about half the model's context window is
  used, or sooner if the conversation is already dominated by old tool output. When a role
  cannot finish in one focused pass, it writes a checkpoint and returns instead of pushing
  on:
  - IMPLEMENTOR: commit the work, append a dated `Resume` comment (done, remaining, next
    concrete step, blockers), leave the ticket `IN_PROGRESS`, and report `checkpoint`. The
    orchestrator re-invokes a fresh IMPLEMENTOR with that ticket id; the existing branch and
    the ticket's claim are the resume point. A ticket that needs repeated checkpoints is too
    big: report it for splitting instead of grinding.
  - REVIEWER: append the findings or `RQ` questions and a resume note to the ticket, leave
    it `IN_REVIEW`, and report `checkpoint`. A fresh `/review` resumes from the ticket.
  - PLANNER, ANALYST, UI-DESIGNER: commit the artifacts written so far, record the open
    items on the ticket or screen document, and report `checkpoint`.
  - ARCHAEOLOGIST, SYSTEM-ARCHITECT: record only the sources actually covered in the source
    ledger, commit the reconstructed documents and report `checkpoint`; a fresh invocation
    continues from the ledger. Never mark an unscanned source as scanned.
  - ACCEPT: finish the ticket it is closing, merge it, and report `checkpoint`; a fresh
    `/accept` continues with the remaining DONE tickets.
  - RECONCILER: apply only the safe repairs it has audited so far, report `checkpoint`, and
    leave the rest for a fresh `/reconcile`.
- **Compact at durability barriers, not mid-ticket.** Compact or clear the orchestrating
  session only when the work is durable on disk:
  - after `/accept` closes a ticket (merged, branch deleted);
  - after `/facilitate`, `/design`, `/plan` or `/refine` has committed;
  - when the loop stops for a human decision (start fresh after the answer);
  - after `/reconcile` or `/guide`, once their findings are recorded or acted on (their
    reports are not durable state).
  Do not clear between `/implement`, `/review` and `/accept` for the same ticket: they are
  separate contexts already, and the ticket and branch hold the state.
- **Prefer a new session at a phase change.** Planning to implementation, a new design round,
  or a new work batch: start a new session (or clear) and re-orient from `/tickets`,
  `git status` and `/guide`. Compaction is the fallback while a long implement → review →
  accept loop continues; compact after every few accepted tickets (for example five), when
  the host exposes it. If it does not, ask the human to compact or start a fresh session at
  the next checkpoint; the loop resumes from disk.
- **Re-orient after any compaction or clear.** Read the current ticket, `git status`, the
  last commits and the next loop step from disk. Never rely on a compaction summary for
  ticket state, acceptance evidence or decisions. Assume the host may compact at any time, so
  keep the ticket comments and commits current enough that a lost transcript does not matter.
- **Keep tool output small.** Read targeted ranges and search instead of whole files; use
  `git diff --stat` or per-file diffs, not the whole branch diff; quiet or tail build and
  test output; never dump lockfiles, generated files, prototypes or logs into the
  conversation.

### Reflection, learning and self-optimization

Each role gets better with use by reflecting on its work and keeping a small, curated record
of what it learned.

- **File per role.** Each role maintains `spec/agent/lessons-learned-{role}.md`, where `{role}`
  is its skill name without the `iap-` prefix (e.g. `lessons-learned-implementor.md`,
  `lessons-learned-system-architect.md`). Create it on first use if missing. The file is (A)
  agent-owned and versioned with the project.
- **Read first.** At the start of a run, read the role's lessons file and apply the lessons
  that fit the current work. They inform how the role works; they never override this process,
  the requirements, the architecture or the tickets.
- **Reflect last.** Before the final report, reflect on the work: what worked, what failed or
  caused rework, surprising repository or tool behavior, review feedback and shortcuts that
  saved time. Then update the lessons file.
- **Keep it useful.** Record reusable, actionable lessons, not a transcript or a task log.
  Date each entry and give it enough context to be understood later (context, lesson, when to
  apply it). Merge duplicates, correct wrong lessons and remove obsolete ones so the file stays
  short enough to read at the start of every run.
- **Scripts are local.** A role may keep small, read-only scripts in its skill definition or
  record a useful one in its lessons file, with purpose, inputs and whether it writes. Scripts
  must never bypass a precondition or invariant, and there is no shared external helper.
- **Do not duplicate other artifacts.** Requirements, decisions and clarifications belong in
  `spec/` and `input-ledger.md`; ticket state belongs in the tickets. Never record secrets,
  credentials or personal data.
- **Only your own file.** A role writes only its own lessons file, so concurrent roles never
  overwrite each other. Include the update in the role's normal commit; if the role does not
  commit, leave it in the working tree and mention it in the report.
- **Read-only roles** (`/tickets`, `/guide`) do not write files; they return any lesson in
  their report for the human to record.
- **Process changes stay human-owned.** A lesson that suggests changing the process, a role
  contract or a skill is reported to the human as a proposal. Agents never edit
  `idx-agentic-process.md` or their skill definitions.

Design guidelines for the agents:
- keep verbosity low, use more concise responses with minimal explanation.
- use plain English, not 'Agentish'. Fluff-free, no corporate lingo ("delve", "leverage", ...)
- Work only from artifacts on disk (spec/, tickets, git) and explicit arguments — never from the orchestrator's conversation history.
- Read your role's `lessons-learned-{role}.md` before working and update it before reporting.
- Use the small read-only scripts in your skill where they help; adapt them in place or record a better one in your lessons file.
- Return exactly one concise report: what was done, the evidence, and any questions/blockers.
- If an invariant is violated, or a precondition is not met, stop and report it; never improvise around it.
- **Ask, don't assume.** When a fact, requirement, behavior or implementation choice is unclear, ask interview-style with viable options, trade-offs and a recommendation, and wait for the human. Never encode an assumption as fact.
- Editing a ticket's Description, Tasks or Acceptance criteria is a non-metadata edit: set the ticket back to DRAFT. Dated workflow notes by `/plan`, `/refine`, `/implement`, `/review` and human answers in `## Comments` are not content edits and do not change the status; a comment that changes scope or requirements does.
- Optimize the skills to work as efficiently as possible.

### FACILITATOR

Type: PRIMARY
Command: `/facilitate`.
Invoked by: HUMAN.
Precondition: `input.md` exists and is not empty, or the project shape is not settled (so the
project-shape interview can run).

Documents:
- Works with: `spec/input.md`; `spec/requirements/**`; `spec/architecture/**`;
  `spec/modules/**`; `spec/agent/input-ledger.md`.
- May modify: `spec/requirements/**`; `spec/architecture/**` (including new architecture
  documents); `spec/modules/**`; `spec/agent/input-ledger.md`; `spec/input.md` (clear only,
  after accepting its content).

Digests the human input (collected in `input.md`) and compares it to the existing requirements and architecture documents.
The input may be fresh input, or may be a copy of a previously existing input-ledger, in which case the original authoring information (author, date and time) should be retained.
It carefully analyzes how to fit the input into the requirements and architecture documents (it may also create additional architecture documents if none of the existing ones are a good fit).
It can prompt the human for clarification (online in the session) and suggest improvements on the input before accepting the input.
When it accepts the input, it appends it — and any clarification it resolved — to the
`input-ledger.md` (date/time, and bullet points for each input line), and creates/updates the
requirements and architecture documents. For UI input it records the high-level decision in the
requirements/architecture documents and the input-ledger; screen documents, project theme/components
and the review prototype are updated by UI-DESIGNER through `/design`. FACILITATOR does not edit
`spec/requirements/user-interface/screens/`, `spec/requirements/user-interface/theme.gui` or `spec/requirements/user-interface/components/components.gui`.
Afterwards it clears the `input.md`, making it ready for the next round of input by the user.
It commits the updated requirements/architecture and the appended ledger on the main branch as `facilitate: {summary}`.
It also runs the pre-planning project-shape interview when the shape is not settled: a
single-subproject project records it in `architecture/tech-stack.md`; a project with more than
one subproject records one module per subproject under `spec/modules/`. It records the choices
in the input-ledger and never marks a shape `agreed` without the human's acceptance.
Interactive (default): it may ask the human for clarification and wait for the answer.
Batch (no human available): it returns the open questions in its report and stops without clearing `input.md`, so the human can answer and re-invoke it.

### UI-DESIGNER

Type: SUBAGENT
Command: `/design`.
Invoked by: HUMAN.
Precondition: the project shape is `agreed` and shows a UI; requirements and architecture
exist; `spec/agent/gui-spec.md` and `spec/agent/screen-workflow.md` are
available. Projects without a UI skip this role.

Documents:
- Works with: `spec/requirements/**`; `spec/architecture/**`; `spec/modules/**`;
  `spec/agent/input-ledger.md`; `spec/requirements/user-interface/screens/**`;
  `spec/requirements/user-interface/flows/**`;
  `spec/requirements/user-interface/theme.gui`;
  `spec/requirements/user-interface/components/components.gui`;
  `spec/requirements/user-interface/data/**`; `prototypes/**`.
- May modify: `spec/requirements/user-interface/screens/**` (status `draft`/`review` only;
  only the human sets `approved`); `spec/requirements/user-interface/flows/**`;
  `spec/requirements/user-interface/theme.gui`;
  `spec/requirements/user-interface/components/components.gui`;
  `spec/requirements/user-interface/data/**`; `spec/agent/input-ledger.md`; `prototypes/**`
  (generated via the project builder only, never by hand);
  `spec/architecture/prototype-builder.md` and the project's prototype-builder code.

Owns the UI design stage. It reads the requirements, architecture, input-ledger, existing
screen documents, flows, project theme/components, example data and prototypes. It identifies
the screens and flows affected by new or changed requirements, then:

- creates or updates `spec/requirements/user-interface/screens/{screen-name}.md` with front
  matter, one primary `gui-v2` block, data and bindings, actions, navigation, interactions,
  states, accessibility notes and open questions;
- creates or updates `spec/requirements/user-interface/flows/`,
  `spec/requirements/user-interface/theme.gui`,
  `spec/requirements/user-interface/components/components.gui` and
  `spec/requirements/user-interface/data/` when the design requires it;
- builds or regenerates the review prototype under `prototypes/` using the project’s
  prototype builder. If no builder exists yet, it creates a small one in the project's agreed
  stack, documents its command and contract in `spec/architecture/prototype-builder.md`, and
  commits it with the project. The builder is project tooling, not a predefined IAP component;
- marks inferred content and records unresolved questions with options and a recommendation;
- records resolved human decisions in `spec/agent/input-ledger.md` before acting on them.

It never invents data sources, permissions, business rules, interactions or navigation. It
never creates implementation tickets, never edits `spec/agent/gui-spec.md` or
`spec/agent/screen-workflow.md`, and never hand-edits generated prototypes. It moves
screen documents between `draft` and `review`; only the human moves them to `approved`.

Batch (no human available): it may write draft screen documents and a prototype marked
inferred, but returns all open questions and stops; the human answers and re-invokes `/design`.
It commits screen documents, flows, theme/components, data and the project's prototype builder on
the main branch as `design: {summary}`. Generated prototypes may be committed or ignored by
Git; the screen documents and data are committed.

**Prototype review.** When the human reviews the prototype, guide them rather than only
reporting status: give the entry point and the command to open it, say what to check on each
screen (definition, data, actions, navigation, interactions, states), and say what the
prototype does not simulate. Ask the screen documents' open questions interview-style: one
compact numbered set per round, blocking questions first; for each question give the gap, two
or three viable options with trade-offs, a recommendation and why, and what the answer
changes. Record the answers in the screen documents and the input ledger, apply them, then
hand the screens back for approval.

### PLANNER

Type: SUBAGENT
Command: `/plan`.
Invoked by: HUMAN.
Precondition: the project shape is settled — a single `architecture/tech-stack.md` with
`status: agreed`, or every module `agreed` — and it names the artifact kind, language and
version. Otherwise run the project-shape refinement first.

Documents:
- Works with: `spec/requirements/**`; `spec/architecture/**`; `spec/modules/**`;
  `spec/requirements/user-interface/screens/**`; `spec/tickets/**`; `spec/agent/ticket-index.md`;
  `spec/agent/planning-log.md`; `spec/agent/input-ledger.md`.
- May modify: `spec/tickets/**` (create and update tickets, including status changes for new,
  updated and reclaimed tickets); `spec/agent/ticket-index.md`;
  `spec/agent/planning-log.md`; `spec/agent/input-ledger.md`.

Find out which changes have been made to the requirements and architecture documents since it was last invoked.
If the project shape is missing, not `agreed`, ambiguous, or lacks its language/version, it
does not plan: it reports the missing decisions and points back to the project-shape refinement
interview.
It then creates or updates tickets that define which changes are to be done in the project, and links them to the requirements (internally, in the `agent` folder).
It gives the ticket a number (sequence number, if possible) and a name, a description, a short task breakdown (checkbox list) and acceptance criteria (bullet list).
It sizes each ticket so one implementor can finish it in one focused context; a requirement
that is too large is split into tickets that can be implemented and reviewed independently.
Each ticket links the project shape it changes: `architecture/tech-stack.md` for a
single-subproject project, or the module(s) and their `tech-stack.md` for a multi-subproject
project. If a ticket spans modules, list all of them.
For UI tickets, it links the applicable `spec/requirements/user-interface/screens/{screen-name}.md` documents,
`spec/agent/gui-spec.md` sections and the generated prototype so the implementor does not
have to infer the intended data, actions, states, tokens, components or patterns. It adds
`ui-screens` and, where useful, `prototype` metadata to the ticket. UI tickets that change
user-visible screens default to `acceptance-type: HUMAN`.

The planner creates UI tickets only from `approved` screen documents. If the affected screen
documents are missing, `draft` or `review`, or have blocking open questions, it does not create
the UI ticket: it returns the blocker in its report and recommends `/design`.
It also checks if any ticket in status IN_PROGRESS exists which is not claimed by an active subagent and whose branch does not exist, and sets it back to status READY.
A ticket whose branch still exists is left for the RECONCILER (see Branches).
It verifies the blocked-by attribute of existing tickets and checks if these tickets actually exist, and that no cyclic dependencies in the blockings exist.
When it needs a decision, it asks interview-style — a numbered set of open questions, each
with the viable options, trade-offs and its recommendation — and returns them in its report;
it never guesses and never blocks. On re-invocation with the human's answers (the human's
clearance) it records each resolved decision (gap, advice, decision, date/time, human user) in
`spec/agent/input-ledger.md` — phrased as ticket-agnostic, implementation-agnostic input —
and notes the clarification on every affected ticket as a dated comment before creating or
updating tickets. A clarification that changes a ticket's Description, Tasks or Acceptance
criteria is applied as a normal DRAFT edit.
It commits the created/updated tickets on the main branch as `plan: {summary}`.

### ANALYST

Type: SUBAGENT
Command: `/refine`.
Invoked by: HUMAN.
Precondition: none, can be invoked anytime.

Documents:
- Works with: `spec/tickets/**`; `spec/requirements/**`; `spec/architecture/**`;
  `spec/modules/**`; `spec/requirements/user-interface/screens/**`; `spec/agent/ticket-index.md`;
  `spec/agent/input-ledger.md`.
- May modify: `spec/tickets/**` (create and update tickets and their status in DRAFT/READY,
  including `blocked-by`); `spec/agent/input-ledger.md`.

Reviews the tickets in status DRAFT and compares them against the requirements and architecture documents.
It also checks that every ticket references an `agreed` project shape — the single
`architecture/tech-stack.md` or the relevant module's `module.md` and `tech-stack.md` — and that
the ticket does not assume a different language, version or stack. If the shape is missing or not
agreed, the ticket stays DRAFT and the analyst reports that project-shape refinement is needed.
For UI tickets it also checks that:

- `ui-screens` names existing screen documents, and every referenced screen document is
  `approved`;
- the ticket links the relevant screen document sections, `gui-spec.md` sections and prototype;
- the ticket covers the documented data/bindings, actions, navigation, interactions, states
  and accessibility notes;
- the ticket does not invent tokens, components, layout rules, data, actions or behavior;
- the ticket has no blocking open question in its screen documents.

If any of these fail, the ticket stays DRAFT and the analyst reports whether `/design` or a
ticket update is needed.
It can also create or update tickets (in status DRAFT, READY) to bring the tickets in line with the requirements and architecture.
It checks and updates the blocked-by against other tickets, and makes sure no cyclic dependencies exist.
When it considers a ticket to be sufficiently defined and ready for implementation, it promotes the ticket's status to READY.
When it needs a decision, it surfaces the gap or impediment explicitly — the open question,
the viable options, and which it recommends — and returns them in its report; it never
guesses and never blocks. On re-invocation with the human's answers (the human's clearance)
it records each resolved decision (gap, advice, decision, date/time, human user) in
`spec/agent/input-ledger.md` — phrased as ticket-agnostic, implementation-agnostic input —
before changing ticket status.
It commits the created/updated tickets on the main branch as `refine: {summary}`.

### IMPLEMENTOR

Type: SUBAGENT
Command: `/implement`.
Invoked by: HUMAN.

Precondition: at least one ticket READY, clean working tree, on main.

Documents:
- Works with: the claimed ticket in `spec/tickets/**`; `spec/requirements/**`;
  `spec/architecture/**`; `spec/agent/test-strategy.md`; `spec/modules/**`; for UI work, `spec/requirements/user-interface/screens/**` and
  `spec/requirements/user-interface/data/**`; `prototypes/**` as a visual reference.
- May modify: the claimed ticket in `spec/tickets/**` (status, task checkboxes, comments);
  `prototypes/**` (regenerate only, never hand-edit); project code, tests, configuration and
  documentation outside `spec/`.

Handle exactly one ticket per invocation, then report. The orchestrating agent starts a
fresh IMPLEMENTOR context for the next ticket; never loop over several tickets in one
context:
- find the best READY, unblocked ticket (BUG > IMPROVEMENT > STORY) and claim it.
- read the project shape from the ticket: `architecture/tech-stack.md` for a single-subproject
  project, or the relevant `spec/modules/{module}/module.md` and `tech-stack.md`. If the shape
  is missing or not `agreed`, stop and report it. Follow the agreed artifacts, language,
  language version and stack.
- if a branch named `{id}-{type}-{name}` already exists, resume it when it holds this ticket's claim; otherwise stop and defer to `/reconcile`.
- create a feature branch from up-to-date main, named `{id}-{type}-{name}`.
- set the ticket STATUS: IN_PROGRESS and commit the claim on that branch.
- implement code, tests, configuration and documentation on the branch.
- for UI work, follow the approved `spec/requirements/user-interface/screens/{screen-name}.md` documents and
  `spec/agent/gui-spec.md` for tokens, components, patterns, content, syntax, layout,
  behavior, accessibility and platform mapping. Use existing tokens and components instead of
  inventing new styles; use the generated prototype as a visual reference.
- if implementation reveals that the approved screen document is wrong or incomplete, stop and
  report the gap. Do not silently change the screen document, invent behavior, or hand-edit the
  prototype. The orchestrator routes the design change through `/design`, re-approval, and
  re-planning.
- regenerate the prototype or screenshots for review evidence when the project’s prototype
  builder is available.
- if the ticket is too large for one focused pass or the context is getting large, checkpoint
  instead of pushing on: commit the work, append a dated `Resume` comment (done, remaining,
  next concrete step, blockers), leave the ticket IN_PROGRESS, and report `checkpoint`. The
  orchestrator re-invokes a fresh IMPLEMENTOR for that ticket id; the branch and the ticket's
  claim are the resume point. Report a ticket that needs repeated checkpoints so it can be split.

Tests covering the code changes are required.

When done, set the ticket STATUS: IN_REVIEW, commit, and hand it over in the report — the
orchestrating agent runs `/review` next. Never review your own ticket. The orchestrating
agent drives the implement → review → accept loop and re-invokes the IMPLEMENTOR in a fresh
context for the next READY ticket after the reviewer finishes; sync main first when a ticket
was accepted (merged). The loop runs until no READY, unblocked ticket remains or it gets
stuck. Tickets are processed sequentially, one branch at a time.

### REVIEWER

Type: SUBAGENT
Command: `/review`.
Precondition: at least one ticket in status IN_REVIEW.
Invoked by: the orchestrating agent, after the IMPLEMENTOR hands a ticket over in IN_REVIEW.

Documents:
- Works with: `spec/tickets/**` (IN_REVIEW tickets); `spec/requirements/**`;
  `spec/architecture/**`; `spec/agent/test-strategy.md`; `spec/modules/**`; for UI work, `spec/requirements/user-interface/screens/**` and
  `spec/requirements/user-interface/data/**`; `prototypes/**`; `spec/agent/input-ledger.md`; the feature branch.
- May modify: the reviewed ticket in `spec/tickets/**` (status DONE or READY, comments);
  `spec/agent/input-ledger.md` (append resolved, durable clarifications only).

Looks at tickets in status IN_REVIEW and checks:
- all tasks are done and every acceptance criterion is fulfilled.
- the change follows the ticket's agreed project shape and the language, language version and
  stack in the single `architecture/tech-stack.md` or the module's `tech-stack.md`.
- the change is complete (code, tests, configuration, documentation) and includes tests for all new or changed behaviour.
- the build and tests are green; no test is skipped or flaky.
- the branch contains only changes within the ticket's scope; unrelated changes are a separate ticket.
- the branch is clean (all work committed) and rebased on the current main.
- for UI work, the change follows the approved `spec/requirements/user-interface/screens/{screen-name}.md` documents and
  `spec/agent/gui-spec.md` (tokens, components, patterns, content, syntax, defaults, layout,
  behavior, accessibility, validation, platform mapping);
- for UI work, the documented data/bindings, actions, navigation, interactions and states are
  implemented; the prototype or screenshot comparison matches the approved screen document;
  keyboard, focus, responsive and platform behavior are verified;
- the screen document was not changed during implementation. If the implementation needs a
  design change, the reviewer rejects the ticket and reports that `/design` and re-approval are
  required; it does not approve an undocumented design change.

Test/coverage standards are not set here; they live in `agent/test-strategy.md` (test levels
and required coverage), supported by `architecture/quality-aspects.md` (non-functional
constraints) and `architecture/coding-guidelines.md` (project tooling and conventions).

If the review is too large for one focused pass, it writes the findings and remaining checks
to the ticket (or the `RQ` set), leaves it `IN_REVIEW`, and reports `checkpoint`; a fresh
`/review` resumes from the ticket.

When the evidence is ambiguous or the expected behavior is unclear — an acceptance criterion
is contradictory, the requirements or screen document are silent, or the evidence supports
more than one reading — the reviewer does not guess and does not reject the implementor for
its own uncertainty. It asks interview-style: a numbered set of `RQ` questions, each with the
options, trade-offs and a recommendation, and what the answer changes. It appends them to the
ticket's `## Comments`, leaves the ticket `IN_REVIEW` and stops. On re-invocation with the
human's answers it appends the answers and a dated clarification note, records a durable
project-level decision in `spec/agent/input-ledger.md` (ticket-agnostic,
implementation-agnostic), and continues. Unanswered questions stay on the ticket, so a later
`/review` resumes them by `RQ` id.

When it is satisfied with the result, it sets the ticket status to DONE and commits that change.
Otherwise, it comments on the ticket what else needs to be done before the ticket can be closed, and sets the ticket back to READY.
For an AUTOMATIC ticket the reviewer returns DONE so the orchestrating agent runs `/accept`; a HUMAN ticket stays DONE for the human.

### ARCHAEOLOGIST

Type: SUBAGENT
Command: `/excavate`.
Invoked by: HUMAN.
Precondition: IAP is installed, `spec/` exists and the project contains source code.

Documents:
- Works with: source code, tests, schemas/migrations, API specifications, configuration, UI
  code and documentation; `spec/requirements/**`; `spec/agent/source-ledger.md`;
  `spec/agent/reverse-engineering-report.md`.
- May modify: `spec/requirements/features/**`; `spec/requirements/domain-models/**`;
  `spec/agent/source-ledger.md`; `spec/agent/reverse-engineering-report.md`.

Reconstructs the functional reality: features, functions and domain models. It reads source code,
tests, database schemas/migrations, API specifications (e.g. OpenAPI), configuration, UI code and
existing documentation, then clusters what it finds into features with their functions and the
domain models involved.
Writes/updates `requirements/features/*.md` and `requirements/domain-models/*.md`, marking each
reconstructed item as inferred and citing its source (file, commit).
Open questions and low-confidence areas go into `spec/agent/reverse-engineering-report.md`.
It is incremental and idempotent: it keeps a hash ledger of the scanned sources and only revisits
what changed since the last run. It reports UI/screen inventory observations to
SYSTEM-ARCHITECT; it does not create screen documents.

### SYSTEM-ARCHITECT

Type: SUBAGENT
Command: `/survey`.
Invoked by: HUMAN.
Precondition: IAP is installed, `spec/` exists and the project contains source code.

Documents:
- Works with: build and dependency manifests, module/folder structure, formatter/linter
  configuration, CI/CD and deployment definitions, UI/theming/style sources and existing
  documentation; `spec/architecture/**`; `spec/agent/**`;
  `spec/modules/**`; `spec/agent/source-ledger.md`;
  `spec/agent/reverse-engineering-report.md`.
- May modify: `spec/architecture/**`; `spec/modules/**` (inferred modules and stacks, `status: draft`);
  `spec/requirements/user-interface/theme.gui`; `spec/requirements/user-interface/components/components.gui`; `spec/requirements/user-interface/screens/**` (inferred stubs only);
  `spec/requirements/user-interface/data/**` (observed example data); `spec/agent/source-ledger.md`;
  `spec/agent/reverse-engineering-report.md`.

Reconstructs the non-functional reality: the project shape (artifact kinds and tech stacks),
decomposition, coding guidelines, quality aspects and — where a UI exists — the UI design
artifacts. It reads build and dependency manifests (e.g. `pom.xml`, `build.gradle`,
`package.json`), the module/folder structure, formatter and linter configuration, CI/CD pipelines
and deployment definitions, UI/theming/style sources, and documents the conventions the code
actually follows.
It determines whether the project has one subproject or several. For a single subproject it
reconstructs the artifact kind and tech stack into `spec/architecture/tech-stack.md` with
`status: draft`. For several subprojects it reconstructs each as a module under
`spec/modules/{module}/`: `module.md` with artifact kind, purpose, responsibilities, boundaries,
dependencies and `status: draft`, and `tech-stack.md` with the observed language, version,
frameworks, runtime, libraries, build/test tooling and infrastructure. Only the human moves a
shape to `agreed`.
Writes/updates the files under `architecture/`, again marked as inferred and with evidence.
For UI projects it also reconstructs the project-specific UI artifacts:

- `spec/requirements/user-interface/theme.gui` from observed tokens, colors, typography,
  spacing and themes;
- `spec/requirements/user-interface/components/components.gui` from recurring project UI
  components;
- inferred `spec/requirements/user-interface/screens/{screen-name}.md` stubs from observed
  routes/screens, with the
  `gui-v2` block, data/actions/navigation/interactions/states where they can be evidenced, and
  open questions where they cannot;
- observations for `spec/requirements/user-interface/data/` where example data is evident.

It does not rewrite the bundled `spec/agent/gui-spec.md` or
`spec/agent/screen-workflow.md`; those are references, not reconstructed project state.
Open questions and low-confidence areas go into `spec/agent/reverse-engineering-report.md`.

### GUIDE

Type: SUBAGENT
Command: `/guide`.
Invoked by: HUMAN.
Precondition: none.

Documents:
- Works with: all of `spec/**` (requirements, architecture, screens, flows,
  theme/components, data, tickets and agent notes), `prototypes/**` and the git state.
- May modify: none. It reports findings and lessons; it does not write files.

Read-only: it changes nothing. It inspects the tickets, requirements, architecture, screen
documents, flows, theme/components, data, prototypes, the git state and `spec/agent/`, and reports
a single prioritized list of the next best actions, each with a reason and the concrete
tickets/branches it applies to.

It orders actions to unblock the process:
1. fix a broken repo state (interrupted rebase/merge, dirty tree, wrong branch).
2. `/facilitate` when `input.md` has unfacilitated lines.
3. project-shape refinement (`/facilitate`) when the shape is not settled: a single
   `architecture/tech-stack.md` missing or not `agreed`, or a multi-subproject project with
   missing/non-agreed modules or incomplete stacks. Planning stays blocked until this is settled.
4. `/design` when UI requirements or architecture changed, when affected screen documents are
   missing or not `approved`, when screen documents have blocking open questions, or when the
   prototype is stale. Skip for projects without a UI.
5. `/plan` when requirements or architecture changed since the last plan, or when approved
   screen documents have no UI tickets.
6. `/refine` for tickets in DRAFT.
7. `/review` for tickets in IN_REVIEW (re-run the reviewer).
8. `/implement` when unblocked READY tickets exist.
9. `/accept` for DONE tickets awaiting human acceptance.
10. `/reconcile` when inconsistencies are detected.

It names any UI ticket that is blocked because its screen document is missing, not approved, or
has an unresolved design question, and recommends `/design`.

It names any item that needs a human decision before the corresponding action can run.

### RECONCILER

Type: SUBAGENT
Command: `/reconcile`.
Invoked by: HUMAN.
Precondition: none.

Documents:
- Works with: all of `spec/**`, `prototypes/**` and the git state (branches, working tree,
  release notes).
- May modify: `spec/tickets/**` (status and metadata repairs only; never a HUMAN ticket);
  `prototypes/**` (regenerate only); git state (branches, commits, stash). It may commit
  existing uncommitted spec artifacts but does not change their content.

Restores a consistent state across tickets, branches and main after an interrupted or failed run.
It audits first, then applies only safe, idempotent, non-destructive repairs, and reports what it
changed and what needs a human.

Audit:
- git: current branch, dirty tree, in-progress rebase/merge, stash; feature branches matching `{id}-{type}-{name}`.
- tickets: status and metadata; `blocked-by` targets exist and are acyclic; ids are unique; UI
  tickets have `ui-screens` and every referenced screen document exists. READY, IN_PROGRESS,
  IN_REVIEW and DONE UI tickets require their screen documents to be `approved`; DRAFT UI
  tickets may reference screens that are back in `review`.
- shape: for a single subproject, `architecture/tech-stack.md` exists with a valid artifact
  kind, `status` and language/version; for multiple subprojects, every
  `spec/modules/{module}/module.md` has a valid artifact kind and status, every module has a
  `tech-stack.md` naming the language and version, and `agreed` shapes have no blocking open
  question. Flag an ambiguous shape (project tech-stack plus modules) or a legacy
  `architecture/tech-stack.md` that should be migrated into modules.
- screens: screen ids are unique; front matter matches the definition; status is valid; flows
  reference existing screens; data fixtures and front-matter scenarios exist; data bindings
  resolve in `default`; prototypes build or are stale.
- cross-checks: ticket status vs branch (missing, orphaned, already merged); a CLOSED ticket implies a
  merged branch and no leftover branch.
- release notes: every CLOSED ticket is covered; the version matches the build file.

Safe repairs (idempotent, never discard work):
- return to main and clean the working tree (never drop uncommitted work; stash it and report it).
- reset an abandoned IN_PROGRESS or IN_REVIEW ticket to READY; keep its branch and report it.
  An IN_REVIEW ticket with open review questions and a branch is waiting for a human, not
  abandoned — leave it.
- delete branches already merged into main.
- remove dangling `blocked-by` references; report cycles.
- commit uncommitted design/planning artifacts (module documents, screen documents, flows,
  theme/components, data, tickets, requirements) on main.
- regenerate stale prototypes; never hand-edit generated HTML.
- return a ticket to DRAFT when the project shape it references is missing or not `agreed`, or
  when a UI ticket's screen document is missing, not approved or has a blocking open question;
  keep its branch and report it.
- flag items it must not touch (HUMAN tickets, missing release-note entries, unapproved screen
  design changes, missing data fixtures or bindings).

Never without confirmation: delete an unmerged branch, force-push, resolve content conflicts,
discard changes, change a ticket whose acceptance-type is HUMAN, redesign or approve a screen
document, or invent missing data or behavior.

Report: each finding with evidence and whether it was fixed or needs a human.

## Additional Commands

Additional commands have no named role, but are also expressed as a skill, with a matching command that invokes the skill.

### List open tickets

Command: `/tickets`.
Invoked by: HUMAN.

Documents:
- Works with: `spec/tickets/**` (through the read-only listing script in the TICKETS skill).
- May modify: none.

Shows all open (non-CLOSED) tickets, one row each, oldest first. It is mechanical: the
TICKETS skill contains a read-only script that emits the table, and the agent prints it
verbatim. The agent does not open ticket files one by one, parse front-matter, sort, pad,
filter or reformat the output — and computes nothing else. Per-status counts come from the
same skill's count script when requested.

The script emits one row per open ticket, space-aligned in exactly this column order:

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
one run. Run it in its own isolated context when the orchestrator invokes it: it is mechanical
and context-heavy. It handles one ticket at a time and may report `checkpoint`; a fresh
`/accept` continues with the remaining DONE tickets.

Documents:
- Works with: `spec/tickets/**` (DONE tickets); `spec/release-notes.md`; for UI tickets,
  `spec/requirements/user-interface/screens/**` (to verify the screen documents are approved); the build file.
- May modify: `spec/tickets/**` (replace the comments with the post-merge summary and set
  the ticket CLOSED); `spec/release-notes.md`.

Accept the eligible DONE tickets, and for each:
- for a UI ticket, verify the referenced screen documents are `approved`; do not merge a UI
  ticket whose screen document is missing or not approved.
- switch to the feature branch.
- rebase the feature branch onto up-to-date `main` and resolve conflicts. If the rebase cannot
  be resolved, abort it, leave the ticket DONE and unmodified on its branch, and report; never
  leave a half-rebased tree. `/reconcile` cleans up.
- update the release notes (create on-the-fly if missing), and verify the version is correct, using the build file's `{major}.{minor}` version (e.g. from `pom.xml`).
- summarize the ticket's `## Comments`: replace the running log with a concise, dated
  post-merge summary and keep only information that still has value after the merge — see
  "Comments". Drop process chatter, resolved rework, duplicates and superseded notes.
- set the accepted ticket to CLOSED.
- commit the release notes and the ticket (summary and CLOSED status) on the feature branch.
- squash the commits into one, named as `{ticket-number}-{ticket-type}: {ticket-title}`.
- switch back to the main branch.
- merge the feature branch (fast-forward only).
- delete the feature branch afterward, and the remote of the feature branch as well, if it exists.

## Collaboration

The project has to be a Git repository, with either `master` (default) or `main` as the _main branch_.
Create it with `git init` if needed.
A remote is optional, `git push` and `git pull` are executed by the human only.

### Commits

Each planning or design role makes one commit per invocation on the main branch, a single-line
message `{command}: {summary}` — lowercase command (`facilitate`, `design`, `plan`, `refine`), a
short imperative summary of at most 200 characters (keep it terse), no body. If nothing changed,
no commit is made. `input.md` is local-only and is never committed. Screen documents, flows,
theme/components and example data are committed; generated prototypes may be ignored by Git.

- facilitate: payments feature, card model, retry policy
- design: dashboard and report-create screens, empty/error states
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
- conversation history is never state: every handover, decision and resume point is on disk (ticket, spec, ledger, git), so a role can be replaced by a fresh context at any checkpoint.
- every human decision that changes requirements, architecture, screen documents or tickets is recorded in `input-ledger.md`.
- no ticket is planned until the project shape is `agreed`: the single `tech-stack.md` or every module, with artifact kind, language and version.
- implementation follows the ticket's agreed project shape; changing an artifact kind, boundary or stack reopens the shape and returns affected tickets to DRAFT.
- a UI ticket is planned only from an `approved` screen document.
- every UI ticket has `ui-screens`; every referenced screen document exists.
- an approved screen document is not silently changed during implementation; design changes go through `/design` and re-approval, and affected tickets return to DRAFT.
- prototypes are generated artifacts; they are never hand-edited.
- UI tickets that change user-visible screens default to `acceptance-type: HUMAN`.
- screen ids are unique; flows, data fixtures, scenarios and data bindings resolve.
- `spec/agent/gui-spec.md` and `spec/agent/screen-workflow.md` are bundled references; agents do not edit them as project design.

`/reconcile` validates and repairs these; `/guide` reports violations it cannot repair.

### Multiple humans

- `input.md` is local-only and listed in `.gitignore`: it is never committed; each human keeps
  their own copy.
- Only the input ledger is shared and versioned. It is append-only and records who made each
  change (human user name), date and time. Past entries are never rewritten or removed.
- Conflicts in co-owned (X) documents are resolved by the human who last edited the affected
  feature/domain model or screen document/theme/component; if unclear, escalate in the
  merge-request discussion.

### Multiple agents

- Implementation changes reach main only through `/accept`; planning/design/requirements artifacts
  (tickets, screen documents, flows, theme/components, data) are committed directly on main.
- Claiming a ticket happens through a commit setting its status to IN_PROGRESS on the feature
  branch; no other agent picks up a claimed ticket.
- The PLANNER resets IN_PROGRESS to READY only when the ticket's branch does not exist;
  a ticket with an existing branch is handled by the RECONCILER (see Branches).
- An agent edits only files within the scope of its claimed ticket; unrelated changes are a new
  ticket.
- Rebase before claiming, commit after each acceptance criterion, and if a remote repository exists: push before handover. Never
  force-push a branch another agent depends on.

### Branches

- Tickets are implemented on feature branches. Ticket branches are named `{id}-{type}-{name}`, one per ticket, created by the IMPLEMENTOR.
- Facilitation, UI design, planning and refinement can be done on non-ticket branches (by multiple humans), but usually are done on the main branch.
- Screen documents, flows, theme/components, data and prototypes are not ticket branches; they live on main. Generated prototypes may be ignored by Git.
- Only `/accept` can merge ticket branches.

### Handover and review

- The REVIEWER reviews the feature branch, not the working tree; a ticket is set to CLOSED before the branch is merged.
- A rejected ticket returns to READY; rebase onto main before rework. For a UI ticket whose design is wrong or incomplete, the reviewer reports that `/design` and re-approval are required instead of approving an undocumented change.
- A CLOSED ticket is protected; follow-up work becomes a new ticket.
- For acceptance-type other than AUTOMATIC, the human reviews DONE tickets and runs `/accept` to merge them. UI tickets that change user-visible screens default to HUMAN acceptance.
- UI design has its own handover: the human reviews the generated prototype and the screen documents, answers open questions, and moves the documents to `approved` before planning.
- When the last open UI ticket for a screen is accepted, the orchestrator (or the human) sets the screen document status to `implemented` (status only; do not change its design content). If the screen changes later, return it to `review` through `/design`.

## Setup

### Installation

The distribution bundle is the `skills/` and `commands/` folders. Role logic, templates,
scripts and the `/bootstrap` assets live inside `skills/`; `commands/` holds the thin
slash-command wrappers. No installer, repository-root `templates/` or `references/` folder is
needed.

Install by copying both folders into the project's agent folder — `.opencode` (OpenCode) or
`.claude` (Claude Code) — for a project-local installation, or into the equivalent global
folder for a global installation. Commit a project-local tool folder so collaborators and
cloud agents have it.

Then run `/bootstrap` once in the project. It creates the `spec/` skeleton and an empty
`spec/input.md`, and copies the bundled documents into `spec/agent/`:

- `gui-spec.md` and `screen-workflow.md` — bundled references, refreshed on every bootstrap;
- `test-strategy.md` — project-owned seed, created only when missing;
- `idx-agentic-process.md` and `process-version.md` — process copy and version marker.

`/bootstrap` never clears an existing `input.md` and never overwrites project content. It is
also the upgrade path: replace the `commands/` and `skills/` folders, then run `/bootstrap`
again. Generated `prototypes/` may be added to `.gitignore`; screen documents, flows,
theme/components and data are versioned.

### BOOTSTRAP

Type: SUBAGENT
Command: `/bootstrap`.
Invoked by: HUMAN.
Precondition: a project root. `spec/` may or may not exist.

Creates the `spec/` folder skeleton and an empty `spec/input.md`; creates `.gitkeep` files in
empty folders so the structure survives Git, and `spec/.gitignore` with `input.md`. Copies
`gui-spec.md`, `screen-workflow.md`, `test-strategy.md`, `idx-agentic-process.md` and
`process-version.md` into `spec/agent/`.
It is idempotent: it preserves an existing `input.md`, never overwrites project content, and
creates `test-strategy.md` only when missing. It does not create requirements, architecture
stubs, tickets or the input ledger; those are generated on first use by the role that owns
them. It reports the assets source, version, created/preserved files and any legacy paths.

### Agent host configuration

The process needs a host that runs roles in isolated subagent contexts and can compact or
clear a session. Configure it to compact well before the model window fills; automatic
compaction at the limit is too late and has already made the run slow and expensive.

- **OpenCode V2** — compaction is on by default. Set `compaction.buffer` so compaction starts
  around half the model's window (for example `buffer: 100000` on a 200k-token model) and keep
  `compaction.keep.tokens` around 10–15k so the recent ticket handover survives. The
  orchestrator can request compaction at a checkpoint with
  `opencode api post /api/session/$OPENCODE_SESSION_ID/compact --data '{}'`; `/new` starts a
  fresh session.
- **Claude Code** — use `/compact` inside a long loop and `/clear` at a phase boundary.

Compaction is lossy and costs a model call, so it is the fallback, not the primary control.
Fresh contexts per command and checkpoints at durability barriers are the primary control.

### Starting a project

1. Copy `commands/` and `skills/` into the project's agent folder and run `/bootstrap`; it
   creates the `spec/` skeleton and an empty `spec/input.md`.
2. The human describes the project in `spec/input.md`.
3. `/facilitate` turns that input into requirements and architecture documents.
4. `/facilitate` runs the project-shape interview: a single subproject is recorded in
   `architecture/tech-stack.md`; multiple subprojects are written under `spec/modules/{module}/`.
   The human accepts the shape until `status: agreed`.
5. Repeat the requirements and project-shape refinement loop until the picture is stable.
6. For UI projects, `/design` creates or updates screen documents and the review prototype; the
   human reviews and moves the screen documents to `approved`.
7. `/plan` creates tickets; `/refine` promotes them to READY.
8. `/implement` and `/review` drive the implementation loop.
9. `/accept` closes the implementation and merges the code.
10. Commit `spec/` together with the code.

Updating the process: replace the `commands/` and `skills/` folders and run `/bootstrap`
again. It refreshes the bundled `spec/agent/gui-spec.md` and
`spec/agent/screen-workflow.md`, the process copy (`spec/agent/idx-agentic-process.md`) and
the process marker. It creates `spec/agent/test-strategy.md` only when it is missing (a
project-owned seed). Apart from the refreshed references, process copy and marker, the content
of `spec/requirements`, `spec/requirements/user-interface`, `spec/modules`, `spec/tickets` and
the rest of `spec/agent/` — including `test-strategy.md`, the input ledger and lessons — is
never touched.
If the prototype builder changes, regenerate prototypes with `/design` or the project builder;
do not hand-edit them.
When a process change alters statuses, metadata fields or role contracts, replacing the
definitions and running `/bootstrap` updates the process copy; the human then runs
`/reconcile` to migrate existing tickets, screen documents and ledgers, and appends a short note
to `spec/agent/input-ledger.md`.

### How to use this process in existing projects

For an existing project the process is adopted in slices: copy the `commands/` and `skills/`
folders and run `/bootstrap`, then reverse-engineer the current reality into the requirement
and architecture documents over time. It can be used before reverse-engineering is complete —
the missing parts simply stay unresolved.

Reverse-engineering is itself agent work, provided by additional subagents (command + skill).
Because the requirement and architecture documents are co-owned (X), these agents never silently
overwrite human content: they write *provisional* content marked as inferred, together with the
evidence and a report in `spec/agent/`, and the human accepts or corrects it.

Order of adoption:
1. Copy the `commands/` and `skills/` folders into the existing repository and run
   `/bootstrap` (see `README.md`).
2. `/survey` and `/excavate` to reconstruct the project shape, architecture and requirements
   (repeat as code changes).
3. The human reviews the inferred documents, corrects them, and accepts the project shape
   through the refinement interview: a single `architecture/tech-stack.md`, or each module and
   its tech stack, until it is `agreed`.
4. For UI projects, `/survey` reconstructs the observed theme/components and inferred screen
   documents; the human reviews and completes them with `/design`, then approves the screens.
5. `/plan`, `/refine`, `/implement`, `/review` and `/accept` as usual.

Planning waits until the project shape is `agreed`; inferred shapes start as `draft`.

Provenance:
- Requirement and architecture items may carry a marker such as `origin: human | inferred` and,
  optionally, a confidence.
- Module documents and tech stacks may carry the same `origin: human | inferred` marker.
- Screen documents, theme and components may carry the same `origin: human | inferred` marker.
- The first entry in `spec/agent/input-ledger.md` records the reverse-engineering event: date,
  source revision/commit, and the commands that were run.
