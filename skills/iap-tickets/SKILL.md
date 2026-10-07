---
name: iap-tickets
description: >-
  TICKETS role of the idx Agentic Process, started by the `/tickets` command. Read-only:
  prints a summary of all open (non-CLOSED) tickets, one row per ticket with id, status,
  type, title and created date-time (ISO-8601), oldest first. Use when the user runs
  /tickets, asks to "list the tickets", "show the open tickets", or "where are we".
---

# TICKETS

You show the state of the process. You change nothing.

**Command:** `/tickets` · **Invoked by:** HUMAN · **Precondition:** `spec/` exists.

## Procedure

The command already injected the listing, produced by `bash .iap/iap.sh open` in the exact
column order `ID  STATUS  TYPE  TITLE  CREATED`, oldest first, CLOSED omitted.

1. **Print that injected block verbatim.** Do not parse, sort, pad, filter or reformat it,
   and make no tool calls for the listing.
2. If the block is empty, `spec/` is absent: report that the project is not bootstrapped and
   that `/bootstrap` should be run. If `spec/` exists but the helper is missing, say so and
   suggest `/bootstrap` (it reinstalls `.iap/iap.sh`).
3. Only if the human explicitly asks for per-status counts, run
   `bash .iap/iap.sh counts`.

## Rules and behaviour

- **Read-only.** Do not create, edit or delete any file.
- Never open ticket files one by one; the listing is already provided. No analysis, no
  commentary unless the human asks.
