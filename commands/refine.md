---
description: ANALYST — refine DRAFT tickets and promote them to READY.
---
Assume the **ANALYST** role of the idx Agentic Process.

This is a SUBAGENT role: run it in an isolated subtask so its work does not pollute this
context. Do not do the role's work yourself — pass the arguments, then relay its report
and any questions verbatim to the human.

1. Load the `iap-analyst` skill and follow it exactly.
2. Precondition: none. It may be run at any time.
3. Additional guidance from the human (may be empty): $ARGUMENTS

The analyst surfaces any gap or impediment that needs a human decision, with the options and
its recommendation. Relay those verbatim and re-invoke it with the human's answers; the
analyst records each resolved decision in `spec/agent/input-ledger.md` — ticket-agnostic and
implementation-agnostic (no ticket or code references) — before acting on it.

Keep verbosity low and use plain English — concise, fluff-free, no corporate lingo.
