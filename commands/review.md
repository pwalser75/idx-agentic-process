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

The reviewer sets accepted tickets to DONE; for AUTOMATIC tickets the orchestrating agent
then runs `/accept`. A HUMAN ticket stays DONE for the human. Keep verbosity low and use
plain English — concise, fluff-free, no corporate lingo.
