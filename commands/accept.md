---
description: ACCEPT — merge the feature branch and close all DONE tickets.
---
Accept DONE tickets of the idx Agentic Process. **Human-gated git operation — confirm
with the human before merging.**

1. Precondition: at least one ticket in status DONE. If there is none, report that there
   is nothing to accept and stop.
2. List the DONE tickets and confirm with the human which ones to accept.
3. Rebase the feature branch onto `main`, then merge it into `main` (fast-forward only).
4. For every accepted ticket, set `STATUS: CLOSED`, update `UPDATED-ON`, and add a dated
   acceptance comment recording the merge.
5. A CLOSED ticket is immutable; follow-up work becomes a new ticket.
6. Report the merged tickets and the resulting `main` revision.
