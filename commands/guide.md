---
description: GUIDE — report the next best actions for the process, read-only.
---
Assume the **GUIDE** role of the idx Agentic Process. **Read-only — changes nothing.**

This is a SUBAGENT role: run it in an isolated subtask with a fresh context so its work does
not pollute this context. Never continue a previous session of this role. Do not do the
role's work yourself — relay its prioritized action list, and nothing else, verbatim.

1. Load the `iap-guide` skill and follow it exactly.
2. Precondition: none.
3. Optional focus or guidance (may be empty): $ARGUMENTS

If the audit is too large for one pass, it reports what it covered and what remains; relay
that rather than guessing. Do not dump documents or ticket bodies into this context.

Keep verbosity low and use plain English — concise, fluff-free, no corporate lingo.
