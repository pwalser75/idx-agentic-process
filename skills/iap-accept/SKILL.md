---
name: iap-accept
description: >-
  ACCEPT role of the idx Agentic Process, started by the `/accept` command. Lands DONE
  tickets on `main`: for each eligible ticket it verifies the reviewed revision, squashes
  the branch's commits into one, rebases onto `main`, updates the release notes, sets the
  ticket CLOSED and merges (fast-forward only). Called by the orchestrating agent for
  AUTOMATIC tickets after `/review`, or by the HUMAN for HUMAN tickets. Use when the user
  runs /accept, asks to "accept", "merge", or "close the done tickets".
---

# ACCEPT

You close DONE tickets and land their work on `main`. You never accept a branch that has
changed since it was reviewed.

**Command:** `/accept` · **Invoked by:** the orchestrating agent (in the `/implement` run)
for AUTOMATIC tickets after `/review` returns DONE, or HUMAN for HUMAN tickets.
**Precondition:** at least one AUTOMATIC ticket in DONE (orchestrator) or one HUMAN ticket
in DONE (human). AUTOMATIC merges need no human involvement.

## Procedure

Find the eligible DONE tickets in one pass — `bash .iap/iap.sh list DONE`. For each:

1. **Switch to the feature branch** `{id}-{type}-{name}`.
2. **Verify the reviewed revision.** The branch tip must be exactly the commit the reviewer
   marked DONE. If it moved, abort, return the ticket to `IN_REVIEW` for a fresh review,
   and report it.
3. **Squash** the branch's commits into one, named
   `{ticket-number}-{ticket-type}: {ticket-title}`.
4. **Rebase** the feature branch onto up-to-date `main` and resolve conflicts.
5. **Update the release notes** in `spec/release-notes.md`, creating the file on the fly if
   missing. Add the ticket under the heading matching its type — STORY → "New Features",
   IMPROVEMENT → "Improvements", BUG → "Bugfixes" — as a bold title with a short,
   client-facing description. Verify the version in the `# Version {major.minor} | Release
   Notes` heading against the build file (e.g. `pom.xml`).
6. **Set the ticket to `status: CLOSED`** and **amend** the squashed commit with the
   release notes and ticket update.
7. **Switch back to `main`.**
8. **Merge** the feature branch (**fast-forward only**).
9. **Delete** the feature branch.
10. **Report** the merged tickets, the resulting `main` revision, and anything needing a
    human.

## If a rebase cannot be resolved

Abort the rebase — the ticket is still DONE, unmodified, on its branch — and report it.
Never leave a half-rebased tree; `/reconcile` cleans up. Fast-forward-only also detects
stacked branches; on a non-fast-forward, abort and report.

## Rules and behaviour

- **Only `/accept` merges** into `main`; only `/reconcile` cleans up branches. An unmerged
  branch is never deleted without confirmation.
- **A CLOSED ticket is immutable**; follow-up work becomes a new ticket.
- **Never discard work.** If anything is unexpected, stop and report.
- A branch that is not fast-forwardable (e.g. stacked on another ticket's work) is aborted
  and reported, never merged.
- Review the branch, not the working tree; the CLOSED commit is created on the branch
  immediately before the fast-forward merge.
