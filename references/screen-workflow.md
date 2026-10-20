# Screen Workflow — Authoring, Review and Prototypes

- **Status:** Default preset; adapt to the project
- **Audience:** human product owners, planning agents, implementation agents, reviewers
- **Companion:** [`gui-spec.md`](gui-spec.md) for syntax, tokens, components, layout,
  accessibility and validation

The screen document is the source of truth. A prototype is a generated review artifact, not
a second specification.

---

## Quick start

1. **Draft.** The planning agent writes `spec/screens/<id>.md` with front matter and one
   primary `gui-v2` block.
2. **Document.** Add purpose, data, actions, navigation, states and open questions. Add
   interactions and accessibility notes only when they apply.
3. **Review.** Build an HTML prototype when visual/behavioral review helps; the human
   reviews the document and prototype.
4. **Approve.** The human moves the status to `approved`.
5. **Implement.** The implementation agent builds, tests and updates the document.

Minimal skeleton:

````markdown
---
screen: dashboard
title: Dashboard
status: draft
provenance: mixed
owner: planning-agent
updated: 2026-10-19
route: /dashboard
data: ../data/dashboard.json
scenarios: [default, empty, loading, error]
---
# Dashboard

## Purpose
Give the operations team a quick view of open work.

## Screen definition
```gui-v2
screen dashboard "Dashboard" layout=column gap=m pad=l
  page-header "Dashboard"
    button "New report" variant=primary action=new-report
```

## Data, Actions, Navigation, States, Open questions
Add the tables from §5–§9 that apply. Use §11 for the copyable template.
````

Use §11 for the full document. Add §12 sections only for complex screens.

### Reading paths

| You are… | Read |
| --- | --- |
| **Human reviewing a screen** | Quick start, §1, §10, the screen document. |
| **Planning agent** | Quick start, §2–§10, `gui-spec.md` §3 and §6. |
| **Implementation agent** | §1, §3–§10, `gui-spec.md` §2–§10 and §11. |
| **Prototype agent** | Quick start, §5, §13, `gui-spec.md` §3 and §6. |

---

## Contents

1. [Roles and status](#1-roles-and-status)
2. [Screen documents](#2-screen-documents)
3. [Front matter](#3-front-matter)
4. [Screen definition](#4-screen-definition)
5. [Data and bindings](#5-data-and-bindings)
6. [Actions](#6-actions)
7. [Navigation](#7-navigation)
8. [Interactions](#8-interactions)
9. [States, accessibility and acceptance](#9-states-accessibility-and-acceptance)
10. [Review and handoff](#10-review-and-handoff)
11. [Minimal template](#11-minimal-template)
12. [Full template additions](#12-full-template-additions)
13. [Prototype workflow](#13-prototype-workflow)
14. [Checklists](#14-checklists)

---

## 1. Roles and status

| Role | Owns | Must not |
| --- | --- | --- |
| **Human product owner** | Intent, scope, priorities, approvals, open questions | Delegate product decisions silently to an agent |
| **Planning agent** | Screen document, definition, data/actions/navigation/interactions, prototype build | Invent data sources, permissions, business rules or behavior |
| **Implementation agent** | Implementation, tests, platform behavior, document sync | Invent missing behavior; copy prototype code into production |
| **Design owner** | Tokens, component usage, visual-system changes | Approve product behavior |
| **Reviewer** | Review comments, prototype feedback, acceptance | Treat a comment as resolved without a decision |

```text
draft -> review -> approved -> implemented
  ^        |          |
  +--------+----------+   changes/rejection return to draft/review
```

- `draft`: being written; no implementation.
- `review`: ready for human/prototype review.
- `approved`: decisions closed; implementation may start.
- `implemented`: production matches the document and tests.
- `deprecated`: history only.

Rules: one named owner; the human approves `review → approved`; mark inferred content
`[inferred]` and summarize in `provenance`; conflicts become open questions; the
implementation agent raises gaps instead of inventing behavior.

---

## 2. Screen documents

```text
spec/
  screens/<id>.md
  flows/<flow>.md
  components/components.gui
  theme.gui
  data/<id>.json
prototypes/              # generated; do not edit
```

- One primary screen per file; file name equals screen id.
- Dialogs, drawers, sheets and meaningful variants get their own document.
- Reusable project components live in the shared file; one-off inline definitions are
  allowed.
- Flow documents link screens for a journey and contain no `gui-v2` block.
- Generated prototypes are disposable.

### Required sections by complexity

| Section | Simple screen | Complex screen |
| --- | --- | --- |
| Front matter, purpose, definition | Required | Required |
| Data/bindings, actions | If used | Required |
| Navigation, states | Required | Required |
| Interactions | If applicable | Required |
| Accessibility notes | If non-obvious | Required |
| Acceptance criteria | Optional | Required |
| Open questions/decisions | When open | Required |
| Review notes | During review | During review |

---

## 3. Front matter

```yaml
---
screen: dashboard
title: Dashboard
status: draft
provenance: mixed
owner: planning-agent
updated: 2026-10-19
route: /dashboard
data: ../data/dashboard.json
scenarios: [default, empty, loading, error]
related: [ticket-detail]
theme: ../theme.gui
components: ../components/components.gui
prototype: ../../prototypes/screens/dashboard.html
tags: [operations]
---
```

| Field | Required | Values |
| --- | --- | --- |
| `screen` | yes | Screen id; matches the definition. |
| `title` | yes | Human title. |
| `status` | yes | `draft`, `review`, `approved`, `implemented`, `deprecated`. |
| `provenance` | yes | `human`, `inferred`, `mixed`. |
| `owner` | yes | Person, team or agent. |
| `updated` | yes | `YYYY-MM-DD`. |
| `route` | yes | Route/path. |
| `data` | yes | Relative path or `none`. |
| `scenarios` | yes | List including `default`. |
| `related` | no | Screen ids. |
| `theme`, `components` | no | Shared files. |
| `prototype` | no | Generated output. |
| `tags` | no | Grouping. |

---

## 4. Screen definition

Use one fenced `gui-v2` block under `## Screen definition`.

````markdown
## Screen definition

```gui-v2
screen dashboard "Dashboard" layout=column gap=m pad=l
  page-header "Dashboard" description="Monday, 19 October"
    button "New report" variant=primary icon=plus action=new-report
```
````

Rules:

- Exactly one primary `screen`; the block validates after shared theme/components are
  composed.
- Use components instead of repeating subtrees; keep one-off definitions local.
- No product data in the block. Use approved sample values or neutral placeholders; bind
  real values through §5.
- Behavior lives in `action=` and §6, not layout.
- `id` every binding/action target.
- Keep block and prose in sync. A prototype-only change is not a decision.
- Separate documents for overlays/variants.
- Effective order: `gui-v2`, shared theme, shared components, inline components, screen.

---

## 5. Data and bindings

### 5.1 Data

| Key | Type | Source | Example | Sensitivity | Notes |
| --- | --- | --- | --- | --- | --- |
| `metrics.open_tickets` | number | `GET /api/metrics` | `18` | internal | Open ticket count. |
| `activity[].title` | string | `GET /api/activity` | `Report ready` | internal | Single line. |

Types: `string`, `number`, `boolean`, `date`, `date-time`, `enum`, `array`, `object`.
Sensitivity: `public`, `internal`, `pii`, `secret`; no real secrets in fixtures. Notes cover
nullability, units, formatting and empty values. Static screens write `None` and list copy.

### 5.2 Example data

One JSON file per screen, keyed by scenario:

```json
{
  "default": {
    "metrics": { "open_tickets": 18 },
    "activity": [{ "title": "Report ready", "description": "Q3 summary" }]
  },
  "empty": { "metrics": { "open_tickets": 0 }, "activity": [] },
  "loading": { "_state": { "loading": true } },
  "error": { "_state": { "error": "We couldn't load activity. Try again." } }
}
```

`default` is required; all front-matter scenarios must exist. `_state` supports `loading`,
`error`, `warning`, `disabled`, `permission-denied`. Scenario names are kebab-case. Fixtures
are fictional; add long-text/partial scenarios when layout is affected.

### 5.3 Bindings

| Node id | Property | Data path | Mode |
| --- | --- | --- | --- |
| `open-tickets` | `value` | `metrics.open_tickets` | scalar |
| `activity-item` | `item` | `activity` | repeat |
| `activity-item` | `title` | `title` | scalar |

- Every bound node has an `id`.
- `Property`: `text`, `value`, `src`, `alt`, `options`, `visible` or a component parameter
  (`value` on `metric`, `title` on `list-item`). `text` sets positional text.
- `scalar` sets one value; `repeat` clones the raw subtree per array item. Extra rows for
  the same node set properties on each clone.
- Inside a repeat, relative paths use the item; `/` reads the scenario root.
- Repeated ids are template anchors; clones get `-<index>` and references are rewritten.
  Nested repeats are not supported initially.
- Bindings apply before component expansion. Bind instance parameters, not internal nodes.
- Validate against `default`; loading/error scenarios may omit fields.
- Missing node/property/path is a build error.

Example targets:

```text
metric id=open-tickets label="Open tickets" value="18"
list
  list-item "Sample activity" id=activity-item description="Sample description"
```

---

## 6. Actions

| Action | Label | Trigger | Effect | Target | Confirmation | Permission | Prototype |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `new-report` | New report | Primary button | Open dialog | `report-create` | none | `reports:write` | Open dialog |
| `delete-report` | Delete | Row menu | Delete + refresh | current list | Required | `reports:delete` | Confirm dialog |

Every `action=` has a row. Ids are kebab-case and unique. Effects: `navigate`, `open`,
`close`, `submit`, `refresh`, `mutate`, `download`, `copy`, `dismiss` or a documented project
effect. Target is a screen/route/object. Destructive actions require confirmation. Permission
is a role/scope or `none` with an open question. No actions → `None` and why.

---

## 7. Navigation

| Direction | From / To | Trigger | Route | Notes |
| --- | --- | --- | --- | --- |
| Incoming | `ticket-list` | Row selection | `/tickets/:id` | Deep link. |
| Outgoing | `ticket-detail` | Back | `/tickets` | Preserve filters. |

Document active nav, query parameters, deep links, refresh, unsaved changes and whether the
screen is a page/dialog/drawer/sheet. Every target exists or is an open question. No
navigation → `None` and why.

**Flow documents** list entry/exit, ordered screens, shared state, back/cancel and unsaved
changes. They do not replace screen documents.

---

## 8. Interactions

| Interaction | Trigger | State | Data | Feedback | URL | Prototype |
| --- | --- | --- | --- | --- | --- | --- |
| Refresh | Toolbar | Reload query | Re-fetch | Spinner; skeleton on first load | unchanged | Simulated delay |
| Search | Input, 300 ms | Query | Filter | Count; empty state | `?q=` | Client filter |
| Filter | Chips | Multi-select | Server filter | Chips; count | `?status=` | Client filter |
| Sort | Header | Column/direction | Server sort | `aria-sort` | `?sort=amount:desc` | Client sort |
| Pagination | Controls | Page | Slice/re-fetch | Keep scroll | `?page=` | Client slice |
| Selection | Checkbox | Selected set | None until action | Count/bulk actions | unchanged | In-memory |
| Inline edit | Field blur | Validate/save | Patch | Inline error/toast | unchanged | Simulated save |

State whether client/server, define loading/empty/error/partial, debounce/cancellation,
URL state and keyboard/focus. Do not invent behavior; open a question.

---

## 9. States, accessibility and acceptance

### 9.1 States

| State | What the user sees | Recovery |
| --- | --- | --- |
| Default | Normal content. | — |
| Loading | Skeleton/spinner. | Automatic. |
| Empty | `empty-state` with next action. | Primary action. |
| Error | `banner tone=error` + retry; keep partial content. | Retry/change filters. |
| Partial | Content + warning banner. | Retry/inspect. |
| Disabled | Explain why and how to enable. | Permission/prerequisite. |
| Permission denied | Explain access; no data leak. | Request access. |
| Offline | Explain unavailable data; queue if supported. | Reconnect. |
| Success | Toast. | — |

Cover `default`, `empty`, `loading`, `error` in fixtures when the screen shows data.

### 9.2 Accessibility and acceptance

Record screen-specific accessible names, heading/landmarks, keyboard/shortcuts, focus
order/return, live regions, sort/selection/invalid states, touch exceptions, reduced motion
and zoom. Normative requirements are in `gui-spec.md` §9.

Acceptance:

- [ ] `gui-v2` validates.
- [ ] Every action has a row.
- [ ] Every binding resolves in `default`.
- [ ] Every navigation target exists.
- [ ] Interactions/states defined or marked not applicable.
- [ ] Prototype matches definition/data.
- [ ] Keyboard/focus verified.
- [ ] No blocking open question.
- [ ] Implementation matches; deviations recorded.

### 9.3 Open questions and decisions

```markdown
## Open questions
| ID | Question | Owner | Blocking | Status |
| --- | --- | --- | --- | --- |
| Q1 | Does export use filtered or all rows? | human | yes | open |

## Decisions
| ID | Decision | Date | Rationale |
| --- | --- | --- | --- |
| D1 | Export uses the filtered set. | 2026-10-19 | Matches user expectation. |
```

Blocking questions prevent `approved`; inferred answers are not decisions until recorded.

---

## 10. Review and handoff

1. Planning agent writes/updates the document.
2. Build a prototype when visual/behavioral review helps.
3. Human reviews definition, prototype and open questions.
4. Feedback goes into `## Review notes` or the issue tracker, not generated HTML.
5. Planning agent resolves and regenerates.
6. Human moves to `approved`.
7. Implementation agent implements, tests and records deviations.
8. Move to `implemented` when document, behavior, states and tests agree.

**Ready:** front matter complete; block valid; data/bindings/actions/navigation/interactions/
states documented; no blocking question; accessibility notes; prototype reviewed when risk
warrants; acceptance criteria testable.

**Done:** production matches; all actions/interactions/states implemented or out of scope;
tests cover behavior; document updated; prototype regenerated; human accepts.

---

## 11. Minimal template

````markdown
---
screen: screen-id
title: Screen title
status: draft
provenance: mixed
owner: planning-agent
updated: 2026-10-19
route: /route
data: ../data/screen-id.json
scenarios: [default, empty, loading, error]
related: []
theme: ../theme.gui
components: ../components/components.gui
tags: []
---

# Screen title

## Purpose
What user problem does this screen solve? What is the one job?

## Screen definition
```gui-v2
screen screen-id "Screen title" layout=column gap=m pad=l
  text "Replace with the screen definition." size=md
```

## Data
| Key | Type | Source | Example | Sensitivity | Notes |
| --- | --- | --- | --- | --- | --- |
|  |  |  |  |  |  |

### Data bindings
| Node id | Property | Data path | Mode |
| --- | --- | --- | --- |
|  |  |  |  |

## Actions
| Action | Label | Trigger | Effect | Target | Confirmation | Permission | Prototype |
| --- | --- | --- | --- | --- | --- | --- | --- |
|  |  |  |  |  |  |  |  |

## Navigation
| Direction | From / To | Trigger | Route | Notes |
| --- | --- | --- | --- | --- |
|  |  |  |  |  |

## States
| State | What the user sees | Recovery |
| --- | --- | --- |
| Default |  |  |
| Loading |  |  |
| Empty |  |  |
| Error |  |  |

## Open questions
| ID | Question | Owner | Blocking | Status |
| --- | --- | --- | --- | --- |
|  |  |  |  |  |
````

---

## 12. Full template additions

Add only when relevant:

- **Users and jobs** — who, in what context, trying to finish what.
- **Interactions** — table from §8.
- **Accessibility notes** — names, keyboard, focus, live regions, exceptions.
- **Acceptance criteria** — testable checklist from §9.2.
- **Decisions** — id, decision, date, rationale.
- **Review notes** — date, reviewer, note, resolution.

---

## 13. Prototype workflow

### 13.1 Principles

The screen document is the source of truth. Do not hand-edit generated HTML; change the
document or fixture and rebuild. Use the same tokens/components; do not invent styles.
Fixtures are fictional. Undocumented actions show “Not specified” and build a warning.
Review the definition, not the HTML; comments go in the document or issue tracker.

### 13.2 Inputs and composition

Inputs: screen document, `spec/theme.gui`, `spec/components/components.gui`,
`spec/data/<id>.json`, and `gui-spec.md`.

```text
gui-v2
theme block (shared)
component definitions (shared)
component definitions (inline, if any)
screens from the screen block
```

The composer emits `gui-v2` once and strips it from the screen block.

### 13.3 Output and build

```text
prototypes/
  index.html           # screens, status, route, scenarios, build time
  screens/<id>.html
  assets/theme.css
  assets/components.css
  assets/runtime.js
  data/<id>.json
```

Pipeline:

1. Read front matter and block.
2. Compose theme/components/screen.
3. Parse and validate.
4. Load scenario.
5. Apply bindings; expand `repeat` clones.
6. Expand built-in/project components.
7. Resolve tokens.
8. Render semantic HTML with `data-screen`, `data-node-path`, `data-action`, `data-field`.
9. Attach runtime.
10. Emit pages, assets, index, `.build/<id>.json`.
11. Warn on undocumented actions, unsupported interactions, inferred content and open
    questions.

A small Node script (`tools/prototype/build.mjs`) reusing the parser/expansion is recommended.
Do not hand-write per-screen HTML.

### 13.4 Runtime and review page

| Interaction | Prototype behavior |
| --- | --- |
| `navigate` | Change location to route/page. |
| `open`/`close` | Show/hide dialog, drawer, sheet, menu, popover. |
| `submit` | Validate; success/error toast. |
| `refresh` | Re-render after simulated delay. |
| `search`/`filter` | Filter fixture; update count/chips. |
| `sort` | Sort rows by field/direction. |
| `paginate` | Slice fixture; update page. |
| `select` | In-memory selection; bulk actions. |
| `download`/`copy` | Toast; no real file. |
| `dismiss` | Hide banner/toast/overlay. |

State is in memory and resets on reload; no real auth/mutation. The prototype must remain
keyboard accessible.

Review bar: screen id/title/status, scenario selector, viewport preset, link to document,
definition/data panels, open-question count. Do not build a full commenting system first; a
“Copy review context” button is enough.

### 13.5 Review loop and CI

```text
planning agent          build                 human                     implementation
     |                    |                     |                              |
 write/update doc  --->  build prototype  --->  review in browser  --->  approve
     ^                    |                     |                              |
     +--------------------+<---- feedback ------+                              |
                                                                               v
                                                                    implement + tests
                                                                               |
                                                                    update doc + rebuild
```

A prototype that disagrees with the document is a build defect. The human approves the
document, not just the prototype. Implementation uses the document and real platform;
prototype is a visual reference.

Build fails on: invalid `gui-v2`; missing params/placeholders; cycles; `action=` without a
row; missing screen target; missing scenario fixture; binding with missing node/property/
path; unknown slot/component. Warn on inferred content, blocking questions, unsupported
interactions and truncation.

Commands: `prototype:build`, `prototype:serve`, `prototype:check`.

### 13.6 MVP, later and native note

**MVP:** static HTML, tokens/components, scenarios `default/empty/loading/error`, scenario
selector, review bar, generic runtime, index, CI validation.

**Later:** flow playback, real API adapters behind a flag, screenshot regression,
annotations, role simulation, device presets.

**Non-goals:** production auth/persistence/business logic, pixel-perfect native rendering,
replacing platform conformance tests, hand-authored pages that drift.

**Native note:** HTML is the shared web/behavior review artifact. For Swing, Android and iOS,
use a native renderer or screenshots from the same document; do not treat HTML pixels as
native acceptance.

**Decisions:** ignore generated prototypes by default; HTML first, native later; parse fixed
interaction tables (one source); fixtures first, real APIs later behind a flag.

---

## 14. Checklists

**Agent:** front matter matches; block validates; every `action=` has a row; bindings resolve
in `default`; navigation targets exist; interactions/states covered; fixtures cover
scenarios; no blocking question; inferred content marked; prototype regenerates.

**Human:** job solved; data/actions correct; navigation/back correct; interactions/states
behave; prototype matches; no blocking question; approve.

**Implementation:** behavior matches; actions/interactions/states covered or out of scope;
tests; accessibility verified per platform; deviations recorded; prototype regenerated;
move to `implemented`.
