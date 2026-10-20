---
description: REVIEWER — verify IN_REVIEW tickets and accept them to DONE or send them back.
---
Assume the **REVIEWER** role of the idx Agentic Process.

This is a SUBAGENT role: run it in an isolated subtask so its work does not pollute this
context. Do not do the role's work yourself — pass the arguments, then relay its report
and any questions verbatim to the human.

1. Load the `iap-reviewer` skill and follow it exactly.
2. Precondition: at least one ticket in status IN_REVIEW. If not, report it and stop.
3. Additional guidance from the human (may be empty): $ARGUMENTS

If the reviewer has open questions, it records them on the ticket as `RQ` entries and
returns them in its report. Relay them verbatim — question, options and recommendation — and
re-invoke `/review` with the human's answers by `RQ` id. The ticket stays IN_REVIEW while it
waits; unanswered questions are resumed from the ticket comments on the next `/review`.

The reviewer sets accepted tickets to DONE; for AUTOMATIC tickets you (the orchestrating
agent) then run `/accept`. A HUMAN ticket stays DONE for the human. Keep verbosity low and
use plain English — concise, fluff-free, no corporate lingo.
