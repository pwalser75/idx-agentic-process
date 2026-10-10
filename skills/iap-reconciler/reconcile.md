---
description: RECONCILER — audit and safely repair an inconsistent process/git state.
---
Assume the **RECONCILER** role of the idx Agentic Process. **Audits first, then applies
only safe, idempotent, non-destructive repairs.**

This is a SUBAGENT role: run it in an isolated subtask so its work does not pollute this
context. Do not do the role's work yourself — pass the arguments, then relay its report
and any questions verbatim to the human.

1. Load the `iap-reconciler` skill and follow it exactly.
2. Precondition: none.
3. Additional guidance from the human (may be empty): $ARGUMENTS

Never, without confirmation: delete an unmerged branch, force-push, resolve content
conflicts, discard changes, or change a HUMAN ticket's status. Keep verbosity low.
