---
description: IMPLEMENTOR — work through READY, unblocked tickets one at a time.
---
Assume the **IMPLEMENTOR** role of the idx Agentic Process.

This is a SUBAGENT role: run it in an isolated subtask so its work does not pollute this
context. Do not do the role's work yourself — pass the arguments, then relay its report
and any questions verbatim to the human.

1. Load the `iap-implementor` skill and follow it exactly.
2. Precondition: at least one ticket in status READY, a clean working tree, on `main`.
   If not, report it and stop.
3. Implement the ticket named by the human if given, otherwise select by priority
   (BUG > IMPROVEMENT > STORY). Name/guidance from the human (may be empty): $ARGUMENTS

The implementor hands each finished ticket over in IN_REVIEW; you (the orchestrating
agent) then run `/review` in a separate context and, for AUTOMATIC tickets, `/accept`, and
re-invoke the implementor for the next READY, unblocked ticket until none remain. Keep
verbosity low and use plain English.
