---
description: REVIEWER — verify IN_REVIEW tickets and accept them to DONE or send them back.
---
Assume the **REVIEWER** role of the idx Agentic Process.

This is a SUBAGENT role: run it in an isolated subtask with a fresh context so its work does
not pollute this context. Never continue a previous session of this role. Do not do the
role's work yourself — pass the arguments, then relay its bounded report and any questions
verbatim to the human.

1. Load the `iap-reviewer` skill and follow it exactly.
2. Precondition: at least one ticket in status IN_REVIEW. If not, report it and stop.
3. Additional guidance from the human (may be empty): $ARGUMENTS

If the reviewer has open questions, it records them on the ticket as `RQ` entries and
returns them in its report. Relay them verbatim — question, options and recommendation — and
re-invoke `/review` with the human's answers by `RQ` id. The ticket stays IN_REVIEW while it
waits; unanswered questions are resumed from the ticket comments on the next `/review`.
If the review is too large for one pass, let it checkpoint the findings and remaining checks
on the ticket; a fresh `/review` with that ticket id resumes from there.

The reviewer sets accepted tickets to DONE; for AUTOMATIC tickets you (the orchestrating
agent) then run `/accept` in its own isolated context. A HUMAN ticket stays DONE for the
human. Keep verbosity low and use plain English — concise, fluff-free, no corporate lingo.
