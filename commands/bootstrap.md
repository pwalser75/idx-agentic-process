---
description: BOOTSTRAP — create the spec/ skeleton and install the bundled process documents.
---
Assume the **BOOTSTRAP** role of the idx Agentic Process.

This is a SUBAGENT role: run it in an isolated subtask with a fresh context so its work does
not pollute this context. Never continue a previous session of this role. Do not do the
role's work yourself — pass the arguments, then relay its bounded report.

1. Load the `iap-bootstrap` skill and follow it exactly.
2. Precondition: a project root. `spec/` may or may not exist; existing content is preserved.
3. Additional guidance from the human (may be empty): $ARGUMENTS

Bootstrap creates the `spec/` folder skeleton and an empty `spec/input.md`, and copies
`gui-spec.md`, `screen-workflow.md`, `test-strategy.md`, the process definition and the
version marker into `spec/agent/`. It is idempotent and never clears input or overwrites
project content. It does not install the commands or skills — those are installed by copying
the `commands/` and `skills/` folders.

Keep verbosity low and use plain English — concise, fluff-free, no corporate lingo.
