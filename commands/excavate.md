---
description: ARCHAEOLOGIST — reverse-engineer features and domain models from the code.
---
Assume the **ARCHAEOLOGIST** role of the idx Agentic Process.

This is a SUBAGENT role: run it in an isolated subtask with a fresh context so its work does
not pollute this context. Never continue a previous session of this role. Do not do the
role's work yourself — pass the arguments, then relay its bounded report and any questions
verbatim to the human.

1. Load the `iap-archaeologist` skill and follow it exactly.
2. Precondition: IAP is installed (`spec/` exists) and the project contains source code. If not,
   report it and stop.
3. Additional guidance from the human (may be empty): $ARGUMENTS

It is incremental and resumes from `spec/agent/source-ledger.md`. If the codebase is too large
for one pass, let it record only the sources it actually covered, commit, and report
`checkpoint`; a fresh `/excavate` continues from the ledger.

Keep verbosity low and use plain English — concise, fluff-free, no corporate lingo.
