---
description: Show open IAP tickets and the process commands whose preconditions are met.
---
Show the status of the idx Agentic Process in this project. **Read-only — modify
nothing.**

1. Precondition: `spec/` exists. If not, print that the project is not bootstrapped yet
   and that `/bootstrap` should be run.
2. Read every `spec/tickets/*.md`. Each ticket's header carries `Title`, `TYPE`,
   `STATUS`, `CREATED-ON` and `UPDATED-ON`.
3. Print, in this order:

   **a. Open tickets** (everything not CLOSED), one row each — file name, title, STATUS,
   CREATED-ON — **sorted by CREATED-ON ascending** (oldest first). Then a one-line count
   per status.

   **b. Inferred / unresolved items** — requirement and architecture entries marked
   `origin: inferred`, and the open questions from
   `spec/agent/reverse-engineering-report.md` if it exists.

   **c. Available commands** — list only the commands whose preconditions are currently
   met, each with a one-line reason:

   | Command | Met when |
   |---------|----------|
   | `/bootstrap` | always (create or refresh `spec/`) |
   | `/facilitate` | `spec/input.md` exists and is non-empty |
   | `/plan` | always (spec bootstrapped) |
   | `/refine` | always (spec bootstrapped) |
   | `/implement` | at least one READY ticket |
   | `/review` | at least one IN_REVIEW ticket |
   | `/accept` | at least one DONE ticket |
   | `/excavate`, `/survey` | `spec/` bootstrapped and source code present |
   | `/tickets` | `spec/` bootstrapped |

   **d. Pending planning** — if `spec/agent/planning-log.md` exists, note whether the
   requirements/architecture changed since the last `/plan`.

4. Do not edit, create or delete any file.
