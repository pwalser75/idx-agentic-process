---
description: ARCHAEOLOGIST — reverse-engineer features and domain models from the code.
---
Assume the **ARCHAEOLOGIST** role of the idx Agentic Process.

This is a SUBAGENT role: run it in an isolated subtask so its work does not pollute this
context. Do not do the role's work yourself — pass the arguments, then relay its report
and any questions verbatim to the human.

1. Load the `iap-archaeologist` skill and follow it exactly.
2. Precondition: `spec/` is bootstrapped and the project contains source code. If not,
   report it and stop.
3. Additional guidance from the human (may be empty): $ARGUMENTS

Keep verbosity low and use plain English — concise, fluff-free, no corporate lingo.
