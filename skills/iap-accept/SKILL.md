---
name: iap-accept
description: >-
  ACCEPT role of the idx Agentic Process, started by the `/accept` command. Lands DONE
  tickets on `main`: for each eligible ticket it switches to the feature branch, updates the
  release notes, sets the ticket CLOSED, commits, squashes the branch's commits into one,
  rebases onto `main`, merges (fast-forward only) and deletes the branch. Called by the
  orchestrating agent for AUTOMATIC tickets after `/review`, or by the HUMAN for HUMAN
  tickets. Use when the user runs /accept, asks to "accept", "merge", or "close the done
  tickets".
---

# ACCEPT

You close DONE tickets and land their work on `main`. AUTOMATIC merges need no human
involvement.

**Command:** `/accept` · **Invoked by:** the orchestrating agent (in the implement → review
→ accept loop, for each AUTOMATIC ticket `/review` just accepted) or HUMAN (for HUMAN tickets).
**Precondition:** at least one AUTOMATIC ticket in DONE (reviewer), or one HUMAN ticket in
DONE (human). It may accept every eligible DONE ticket in one run.

After it merges, the orchestrating agent syncs `main` and re-invokes the IMPLEMENTOR for the
next READY ticket, and so on until no READY, unblocked ticket remains or the loop gets stuck.

## Procedure

Find the eligible DONE tickets in one pass — `bash .iap/iap.sh list DONE`. For each:

1. **Switch to the feature branch** `{id}-{type}-{name}`.
2. **Update the release notes** in `spec/release-notes.md`, creating the file on the fly if
   missing. Add the ticket under the heading matching its type — STORY → "New Features",
   IMPROVEMENT → "Improvements", BUG → "Bugfixes" — as a bold title with a short,
   client-facing description. Verify the version in the `# Version {major.minor} | Release
   Notes` heading against the build file (e.g. `pom.xml`).
3. **Set the ticket to `status: CLOSED`.**
4. **Commit** the release notes and ticket update on the feature branch.
5. **Squash** the branch's commits into one, named
   `{ticket-number}-{ticket-type}: {ticket-title}`.
6. **Rebase** the feature branch onto up-to-date `main` and resolve conflicts.
7. **Switch back to `main`.**
8. **Merge** the feature branch (**fast-forward only**).
9. **Delete** the feature branch.
10. **Report** the merged tickets, the resulting `main` revision, and anything needing a
    human.

## If a rebase cannot be resolved

Abort the rebase — the ticket is still DONE, unmodified, on its branch — and report it.
Never leave a half-rebased tree; `/reconcile` cleans up.

## Rules and behaviour

- **Only `/accept` merges** into `main`; only `/reconcile` cleans up branches. An unmerged
  branch is never deleted without confirmation.
- **A CLOSED ticket is immutable**; follow-up work becomes a new ticket.
- **Never discard work.** If anything is unexpected, stop and report.
- Review the branch, not the working tree; a ticket is set to CLOSED before the branch is
  merged.
