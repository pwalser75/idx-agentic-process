---
description: Show the state of the process and all open IAP tickets.
---
Assume the **TICKETS** role of the idx Agentic Process. **Read-only — modify nothing.**

Read-only and stateless: run it in this session, or in an isolated context when the
orchestrator calls it. Only the table should enter the conversation.

1. Load the `iap-tickets` skill and follow it exactly.
2. Run the skill's read-only ticket listing script from the project root and print its output
   verbatim. Do not parse, sort, pad, filter or reformat it, and make no other tool calls for
   the listing.
3. Optional filter or guidance (may be empty): $ARGUMENTS

Never open ticket bodies or dump directory listings, logs or file contents for this command.
Keep verbosity low and use plain English — concise, fluff-free, no corporate lingo.
