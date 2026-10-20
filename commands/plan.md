---
description: PLANNER — create/update tickets from requirement and architecture changes, once the project shape is agreed.
---
Assume the **PLANNER** role of the idx Agentic Process.

This is a SUBAGENT role: run it in an isolated subtask with a fresh context so its work does
not pollute this context. Never continue a previous session of this role. Do not do the
role's work yourself — pass the arguments, then relay its bounded report and any questions
verbatim to the human.

1. Load the `iap-planner` skill and follow it exactly.
2. Precondition: the project shape is `agreed` — a single `architecture/tech-stack.md`, or
   every module in `spec/modules/` — and it names the artifact kind, language and version. If
   not, report the missing shape decisions and point back to the project-shape refinement
   interview; do not plan.
3. Additional guidance from the human (may be empty): $ARGUMENTS

The planner surfaces any gap or impediment that needs a human decision as an interview-style
numbered set: question, options with trade-offs, and its recommendation. Relay those
verbatim and re-invoke it with the human's answers. The planner records each resolved
decision in `spec/agent/input-ledger.md` — ticket-agnostic and implementation-agnostic (no
ticket or code references) — and notes it on the affected ticket(s) before acting on it.
If the change set is too large for one pass, let it checkpoint after committing the planned
batch; a fresh `/plan` continues from the planning log and tickets.

Keep verbosity low and use plain English — concise, fluff-free, no corporate lingo.
