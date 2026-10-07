---
description: ACCEPT — update release notes, squash, rebase and merge DONE tickets.
---
Assume the **ACCEPT** role of the idx Agentic Process.

1. Load the `iap-accept` skill and follow it exactly.
2. Precondition: at least one AUTOMATIC ticket in DONE (orchestrator after `/review`) or one
   HUMAN ticket in DONE (human). If not, report that there is nothing to accept and stop.
3. Which tickets to accept, if not all eligible (may be empty): $ARGUMENTS

AUTOMATIC merges need no human involvement. Keep verbosity low and use plain English —
concise, fluff-free, no corporate lingo.
