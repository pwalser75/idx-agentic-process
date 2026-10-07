# Process Version

<!-- (A) Agent-owned. Records which version of the idx Agentic Process is installed. -->

- **IAP version:** `{version}`
- **Installed on:** {ISO date-time}
- **Source:** {source}
- **Process definition:** `spec/agent/idx-agentic-process.md`

To update: re-run `/bootstrap` (or re-install the skills/commands). It refreshes only
the command/skill definitions, the `.iap/iap.sh` helper, this marker and the
process-definition copy. The content of `spec/requirements`, `spec/architecture`,
`spec/tickets` and `spec/agent/input-ledger.md` is never touched.
