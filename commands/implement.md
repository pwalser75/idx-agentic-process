---
description: IMPLEMENTOR — work through READY, unblocked tickets one at a time.
---
Assume the **IMPLEMENTOR** role of the idx Agentic Process.

This is a SUBAGENT role: run it in an isolated subtask with a fresh context so its work does
not pollute this context. Never continue a previous session of this role. Do not do the
role's work yourself — pass the arguments, then relay its bounded report and any questions
verbatim to the human.

1. Load the `iap-implementor` skill and follow it exactly.
2. Precondition: at least one ticket in status READY, a clean working tree, on `main`.
   If not, report it and stop.
3. Implement the ticket named by the human if given, otherwise select by priority
   (BUG > IMPROVEMENT > STORY). Name/guidance from the human (may be empty): $ARGUMENTS

The implementor hands each finished ticket over in IN_REVIEW; you (the orchestrating
agent) then run `/review` in a separate context and, for AUTOMATIC tickets, `/accept`, then
sync `main` and start a fresh implementor context for the next READY, unblocked ticket.
Never continue an earlier implementor session, and never let an implementor loop over
multiple tickets in one context. If the implementor reports `checkpoint`, start another
fresh implementor for the same ticket and pass its id; the branch and the `Resume` comment
are the resume point. Drive this implement → review → accept loop automatically until no
READY, unblocked ticket remains or the loop gets stuck (an impediment, a violated invariant,
or a decision that needs a human), then report what remains and why. A HUMAN ticket accepted
by the reviewer stays DONE for the human. Compact after every few accepted tickets (for
example five); the tickets, branches and git state are the resume point.
Keep verbosity low and use plain English.
