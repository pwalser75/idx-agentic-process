# Test Strategy

The strategy is platform- and technology-agnostic: it defines test **levels** by the scope
of the system under test and by what is real versus faked, never by tooling. The concrete
tools for each level live in [`coding-guidelines.md`](coding-guidelines.md); the
presentation references for L4 live in [`design-system.md`](design-system.md) and
[`gui-spec.md`](gui-spec.md).

## Levels

A level is defined by its scope and by which boundary is real.

- **L1 — Unit.** A single unit in isolation; every collaborator is a test double.
- **L2 — Integration.** A real module/component assembled with its real immediate
  collaborators; only the *external boundaries* (network, external services, persistence,
  platform) are doubled or replaced by an in-process/embedded real instance.
- **L3 — Acceptance.** The product's **real entry point**, driven end to end against an
  ephemeral, seeded environment; asserts user-observable outcomes.
- **L4 — Experience.** The rendered or visible output compared against a reference, plus
  accessibility checks.

## Required levels per change

Required levels scale with the surface and the risk a change touches. A change is done only
when its **highest** required level passes; a lower level passing never offsets a higher one
failing.

| The change touches | Required levels |
| --- | --- |
| Pure logic / business rules | L1 + L2 |
| A boundary or adapter | L2, with a real or in-process/embedded boundary |
| A user-observable flow / feature increment | L2 + L3 |
| Cross-cutting wiring or state propagation | L2 + L3 |
| The presentation layer | L4 (+ HUMAN acceptance for aesthetics) |

## Environment and fixtures

- Every integration and acceptance run uses an ephemeral, isolated, deterministic
  environment, seeded with **representative fixtures**, and torn down afterwards.
- Prefer fixtures **recorded from the real system** over invented ones. Invented test data is
  allowed only where recording is impossible; it must be flagged and kept minimal, since it
  encodes assumptions the real system may not share.
- Boundary fidelity, highest first: real external boundary → in-process/embedded real
  instance → recorded replay → test double. Use the highest fidelity that is practical.

## Evidence and gates

- Every level yields a **runnable command** and an **observable result** (an assertion, a
  report, a log). L4 additionally yields the captured rendering and the accessibility
  result.
- **Implementor:** produce the evidence for the ticket's required levels and attach it to the
  ticket; a handover without it is incomplete.
- **Reviewer:** independently re-run the required levels and do not trust the handover; a
  missing or failing required level returns the ticket to READY. For L4, inspect the rendered
  evidence against the reference; aesthetics remain a HUMAN decision (`acceptance-type:
  HUMAN`).
