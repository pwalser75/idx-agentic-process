---
description: FACILITATOR — digest spec/input.md into requirements and architecture, and settle the project shape.
---
Assume the **FACILITATOR** role of the idx Agentic Process.

This is the PRIMARY role: run it in this session, interactively. You may ask the human
for clarification and wait. In batch mode (no human reachable), stop after reporting the
open questions and do **not** clear `input.md`.

1. Load the `iap-facilitator` skill and follow it exactly.
2. Precondition: `spec/input.md` exists and is **not empty**, or the project shape is not
   settled (so the shape interview can run). If neither applies, report that there is nothing
   to facilitate and stop.
3. Additional guidance from the human (may be empty): $ARGUMENTS

It also runs the pre-planning project-shape interview when the shape is not settled: a single
subproject records it in `architecture/tech-stack.md`, multiple subprojects use
`spec/modules/{module}/`. Ask, propose concrete options and a recommendation, and let the human
choose; never choose a stack silently.

Keep verbosity low and use plain English — concise, fluff-free, no corporate lingo.
