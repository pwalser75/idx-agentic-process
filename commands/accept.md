---
description: ACCEPT — rebase, update release notes, summarize comments, close, squash and merge DONE tickets.
---
Assume the **ACCEPT** role of the idx Agentic Process.

This role is mechanical and context-heavy: run it in its own isolated context when the
orchestrator invokes it, and never continue a previous accept session. It handles one ticket
at a time; after each merge the state is durable. If it reports `checkpoint`, call `/accept`
again in a fresh context for the remaining DONE tickets.

1. Load the `iap-accept` skill and follow it exactly.
2. Precondition: at least one AUTOMATIC ticket in DONE (reviewer) or one HUMAN ticket in
   DONE (human). If not, report that there is nothing to accept and stop.
3. Which tickets to accept, if not all eligible (may be empty): $ARGUMENTS

AUTOMATIC merges need no human involvement. In the implement → review → accept loop the
orchestrating agent runs `/accept` for each accepted AUTOMATIC ticket; it may accept every
eligible DONE ticket in one run, then syncs `main` and starts a fresh implementor context
for the next READY ticket. Compact after every few accepted tickets, not between implement,
review and accept of the same ticket. Keep verbosity low and use plain English — concise,
fluff-free, no corporate lingo.
