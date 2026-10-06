---
description: ACCEPT — update the release notes, merge the feature branch and close all DONE tickets.
---
Accept DONE tickets of the idx Agentic Process. **Human-gated git operation — confirm
with the human before merging.**

1. Precondition: at least one ticket in status DONE. If there is none, report that there
   is nothing to accept and stop.
2. Find the DONE tickets in one pass — `bash .iap/iap.sh list DONE` — and confirm with the
   human which ones to accept.
3. Update the release notes in `spec/release-notes.md`, creating the file on the fly if it
   is missing. Add each accepted ticket to the heading matching its type — STORY → "New
   Features", IMPROVEMENT → "Improvements", BUG → "Bugfixes" — as a bold title with a
   short, client-facing description, and verify the version in the `# Version {major.minor}
   | Release Notes` heading is correct.
4. Squash the commits of each accepted ticket into one, named
   `{ticket-number}-{ticket-type}: {ticket-title}`.
5. Rebase the feature branch onto `main`, then merge it into `main` (fast-forward only).
6. For every accepted ticket, set `STATUS: CLOSED`, update `UPDATED-ON`, and add a dated
   acceptance comment recording the merge.
7. A CLOSED ticket is immutable; follow-up work becomes a new ticket.
8. Report the merged tickets and the resulting `main` revision.

Keep verbosity low and use plain English — concise, fluff-free, no corporate lingo.
