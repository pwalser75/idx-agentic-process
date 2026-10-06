---
description: Show open IAP tickets and the state of the process.
---
Show the status of the idx Agentic Process in this project. **Read-only — modify
nothing.** Use the shared helper `.iap/iap.sh` for fast, single-pass scans instead of
opening ticket files one by one. If the helper is missing, run `/bootstrap` to install it
(or fall back to `find`/`grep` inline).

1. Precondition: `spec/` exists. If not, print that the project is not bootstrapped yet
   and that `/bootstrap` should be run, then stop.
2. Print, in this order:

   **a. Open tickets** — every ticket whose STATUS is not CLOSED, one space-aligned row
   per ticket with ID, STATUS, TYPE, TITLE and CREATED (oldest first), then a per-status
   count:

   ```bash
   bash .iap/iap.sh open
   bash .iap/iap.sh counts
   ```

   **b. Inferred / unresolved items** — requirement and architecture entries marked
   `origin: inferred`, plus the open questions in
   `spec/agent/reverse-engineering-report.md` if it exists:

   ```bash
   bash .iap/iap.sh inferred
   ```

   **c. Pending planning** — if `spec/agent/planning-log.md` exists, note whether the
   requirements/architecture changed since the last `/plan`.

3. Do not edit, create or delete any file.

Keep verbosity low and use plain English — concise, fluff-free, no corporate lingo.
