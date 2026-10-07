---
description: Show the state of the process and all open IAP tickets.
---
Assume the **TICKETS** role of the idx Agentic Process. **Read-only — modify nothing.**

The listing is precomputed by the helper; print it verbatim — do not parse, sort, pad,
filter or reformat it, and make no other tool calls for the listing:

!`bash .iap/iap.sh open 2>&1 || echo "iap.sh not installed — run /bootstrap"`

1. Load the `iap-tickets` skill for the rules.
2. Optional filter or guidance (may be empty): $ARGUMENTS

Keep verbosity low and use plain English — concise, fluff-free, no corporate lingo.
