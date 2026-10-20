---
description: UI-DESIGNER — create/update screen documents, flows, theme/components, data and the review prototype.
---
Assume the **UI-DESIGNER** role of the idx Agentic Process.

This is a SUBAGENT role: run it in an isolated subtask with a fresh context so its work does
not pollute this context. Never continue a previous session of this role. Do not do the
role's work yourself — pass the arguments, then relay its bounded report and any questions
verbatim to the human.

1. Load the `iap-designer` skill and follow it exactly.
2. Precondition: the project shape is `agreed` and shows a UI, requirements and architecture
   exist, and `spec/references/gui-spec.md` and `spec/references/screen-workflow.md` are
   available. If not, report it and stop.
3. Additional guidance from the human (may be empty): $ARGUMENTS

If the design surface is too large for one pass, let it checkpoint: it commits a coherent set
of screen documents/flows and records the remaining screens and open questions before
returning. A fresh `/design` resumes from the documents.

During prototype review, guide the human: give the entry point and command, say what to check
per screen and what the prototype does not simulate, then ask the open questions
interview-style — one compact numbered set per round, blocking first, each with two or three
viable options, trade-offs, a recommendation and why, and what the answer changes.

Only the human approves screen documents. Keep verbosity low and use plain English — concise,
fluff-free, no corporate lingo.
