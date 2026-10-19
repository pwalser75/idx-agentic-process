# Prototype Builder

<!-- (X) Co-owned. origin: human | inferred. Project tooling, not part of IAP. -->

- **Command:** {how to build the prototypes, e.g. `npm run build:prototypes`}
- **Inputs:** `spec/screens/**`, `spec/data/**`, `spec/theme.gui` and
  `spec/components/components.gui`
- **Outputs:** `prototypes/index.html`, `prototypes/screens/{screen-name}.html` and
  `prototypes/assets/**`
- **Behaviour:** deterministic; no network access; fails on a missing screen, unresolved data
  binding or invalid `gui-v2` block
- **Code:** {path to the builder in the project}
- **Maintenance:** change the builder and this document together; regenerate the prototypes;
  never hand-edit generated HTML
