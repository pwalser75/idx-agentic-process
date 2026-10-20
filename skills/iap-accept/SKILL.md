---
name: iap-accept
description: >-
  ACCEPT role of the idx Agentic Process, started by the `/accept` command. Lands DONE
  tickets on `main`: for each eligible ticket it switches to the feature branch, rebases onto
  `main`, updates the release notes, condenses the ticket's comment log into a durable
  post-merge summary, sets the ticket CLOSED, commits, squashes the branch's commits into one,
  merges (fast-forward only) and deletes the branch. Called by the orchestrating agent for
  AUTOMATIC tickets after `/review`, or by the HUMAN for HUMAN tickets. Use when the user runs
  /accept, asks to "accept", "merge", or "close the done tickets".
---

# ACCEPT

You close DONE tickets and land their work on `main`. AUTOMATIC merges need no human
involvement.

**Command:** `/accept` · **Invoked by:** the orchestrating agent (in the implement → review
→ accept loop, for each AUTOMATIC ticket `/review` just accepted) or HUMAN (for HUMAN tickets).
**Precondition:** at least one AUTOMATIC ticket in DONE (reviewer), or one HUMAN ticket in
DONE (human). It may accept every eligible DONE ticket in one run.

After it merges, the orchestrating agent syncs `main` and starts a fresh IMPLEMENTOR context
for the next READY ticket, and so on until no READY, unblocked ticket remains or the loop
gets stuck.

## Procedure

Find the eligible DONE tickets in one pass — run the DONE ticket script below. For each:

1. **Switch to the feature branch** `{id}-{type}-{name}`.
2. **Rebase** the feature branch onto up-to-date `main` and resolve conflicts. If the rebase
   cannot be resolved, abort it, leave the ticket DONE and unmodified on its branch, and
   report; never leave a half-rebased tree. `/reconcile` cleans up.
3. **Update the release notes** in `spec/release-notes.md`, creating the file on the fly if
   missing. Add the ticket under the heading matching its type — STORY → "New Features",
   IMPROVEMENT → "Improvements", BUG → "Bugfixes" — as a bold title with a short,
   client-facing description. Verify the version in the `# Version {major.minor} | Release
   Notes` heading against the build file (e.g. `pom.xml`).
4. **Summarize the comments.** Read the ticket's `## Comments` running log and replace it with
   one concise, dated post-merge summary. Keep only information that still has value after the
   merge: decisions and their rationale, caveats or known limitations, operational notes,
   verification evidence, and follow-up work. Drop process chatter, resolved rework,
   duplicates and anything superseded by the final code, requirements, architecture or release
   notes. A useful test: would this help someone reading the closed ticket or the code later?
   If not, do not keep it. This is the only permitted rewrite of a ticket's comments.
5. **Set the ticket to `status: CLOSED`.**
6. **Commit** the release notes and the ticket (summary and CLOSED status) on the feature
   branch.
7. **Squash** the branch's commits into one, named
   `{ticket-number}-{ticket-type}: {ticket-title}`.
8. **Switch back to `main`.**
9. **Merge** the feature branch (**fast-forward only**).
10. **Delete** the feature branch.
11. **Report** the merged tickets, the resulting `main` revision, and anything needing a
    human.

## Rules and behaviour

- **Only `/accept` merges** into `main`; only `/reconcile` cleans up branches. An unmerged
  branch is never deleted without confirmation.
- **A CLOSED ticket is immutable**; follow-up work becomes a new ticket.
- **Comments are append-only while the ticket is open.** `/accept` is the one exception: it
  replaces the running log with a concise post-merge summary before setting CLOSED. Keep only
  facts that still matter after the merge, and move durable project facts to the requirements,
  architecture or release notes instead of the ticket.
- **Never discard work.** If anything is unexpected, stop and report.
- Review the branch, not the working tree; a ticket is set to CLOSED before the branch is
  merged.

## Context and reporting

- **Run in its own context.** This role is mechanical and context-heavy (rebase, merge,
  release notes, comment condensation). When the orchestrator invokes it, use a fresh
  isolated context; never accept from the orchestrator's conversation.
- **One ticket at a time.** After each merge the state is durable. If the context grows,
  finish the current ticket, report `checkpoint`, and let the orchestrator call `/accept`
  again.
- **Report at most about 200 words**: merged tickets, the resulting `main` revision, and
  anything needing a human. Details belong in the release notes and ticket summaries.
- **Keep tool output small.** Use `git diff --stat`, `git log --oneline` and quiet rebase/merge
  output; do not dump diffs or logs.

## Script: DONE tickets

Read-only. Prints `FILE TYPE TITLE`, oldest first.

```bash
for f in spec/tickets/*.md; do
  [ -e "$f" ] || continue
  status=$(sed -n 's/^status:[[:space:]]*//p' "$f" | head -1)
  [ "$status" = "DONE" ] || continue
  type=$(sed -n 's/^type:[[:space:]]*//p' "$f" | head -1)
  title=$(sed -n 's/^#[[:space:]]*//p' "$f" | head -1)
  printf '%s\t%s\t%s\n' "$f" "$type" "$title"
done | sort -t"$(printf '\t')" -k1,1
```

## Lessons learned

Read `spec/agent/lessons-learned-accept.md` before working and update it before reporting.
Keep entries short, dated and reusable; apply what fits, and never let a lesson override the
process, requirements, architecture or tickets. You may record a useful script in a lesson,
with its purpose and whether it writes anything.
