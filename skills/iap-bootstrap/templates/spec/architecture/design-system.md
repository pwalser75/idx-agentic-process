# UI Design System

<!-- (X) Co-owned. origin: human | inferred -->

- **Design system version:** 1.0
- **Applies to:** `gui-v1` (format revision 1.2)
- **Status:** Default preset; adapt to the project

This is a default preset: a starting design system to adapt to the project, not a blank
stub. Projects without a UI may leave it as-is; projects with one refine it during the
requirements loop.

This document is the entry point. It defines the shared design language: principles,
foundations, themes, component usage, patterns, content rules, accessibility policy,
assets, governance and quality gates. The normative syntax, defaults, layout algorithms,
validation codes and platform mapping live in the companion
[`gui-spec.md`](gui-spec.md). The design system owns *what and why*; the specification
owns *how*.

## Contents

- [A1 Purpose and principles](#a1-purpose-and-principles)
- [A2 Foundations](#a2-foundations)
- [A3 Themes](#a3-themes)
- [A4 Components](#a4-components)
- [A5 Patterns](#a5-patterns)
- [A6 Content design](#a6-content-design)
- [A7 Accessibility](#a7-accessibility)
- [A8 Assets and implementation](#a8-assets-and-implementation)
- [A9 Governance](#a9-governance)
- [A10 Quality and conformance](#a10-quality-and-conformance)
- [Appendix A — Token source format](#appendix-a--token-source-format)
- [Appendix B — Token index](#appendix-b--token-index)
- [Appendix C — Icon inventory](#appendix-c--icon-inventory)
- [Appendix D — Changelog and decisions](#appendix-d--changelog-and-decisions)

## How to use this document

| Reader | Start here | Then |
| --- | --- | --- |
| Agent specifying a GUI | A1 principles, A4 components, A5 patterns, A6 content | `gui-spec.md` §3 syntax, §6 components, §9 errors, §11 quick reference |
| Agent implementing a GUI | A2 foundations, A3 themes, A7 accessibility | `gui-spec.md` §1 determinism, §4 tokens, §5 layout, §7 platform mapping, §10 tests |
| Human viewing or editing definitions | A4 component gallery, A5 patterns | `gui-spec.md` §3 syntax, §6 component reference, §11 quick reference |

**Adaptation rules**

- This preset describes a baseline. Replace or extend its decisions with project
  decisions where the product needs them; do not silently ignore a rule.
- Mark provenance: keep `origin: human` content, and mark reconstructed content
  `origin: inferred`. Conflicts become open questions, not silent edits.
- Rendering is **closed by default**: a renderer must not invent spacing, color, type or
  behavior. Product decisions are **open by default**: anything the project has not
  decided is an explicit open question, not implementer judgment.
- Record project token overrides and deviations in A2/A3 and in the decision log
  (Appendix D). A deviation is a decision, not an exception hidden in a screen.
- The baseline token values and component defaults are normative in `gui-spec.md` §4–§6.
  This document links to them instead of restating them.
- `gui-spec.md` is a versioned normative reference, not a project-specific design
  artifact. Projects adapt this design system and their theme overrides; they do not fork
  the format.

---

## A1 Purpose and principles

### A1.1 Purpose

The design system gives humans, specifying agents and implementing agents one shared
vocabulary for UI decisions. It makes screens predictable: the same intent produces the
same components, tokens and behavior on web, Java Swing, Android and iOS.

### A1.2 Audience and platforms

The system targets application UIs on web, desktop (Java Swing) and mobile (Android,
iOS). It covers data-heavy business applications, not marketing sites. Each platform
implements the same tokens and semantics with native controls or custom drawing where a
native control cannot express the specified appearance.

### A1.3 Design principles

1. **Clarity before density.** Reduce lines and chrome, but never at the cost of
   affordance, legibility or accessibility.
2. **Compose before inventing.** Prefer the catalog and patterns in this system over new
   components or one-off styles.
3. **Accessible by default.** Contrast, focus, keyboard operation and touch targets are
   part of the component, not an afterthought.
4. **Token-driven and deterministic.** Color, type, spacing, shape, motion and elevation
   come from tokens. No implicit values.
5. **Responsive by structure.** Reflow and relocate before hiding. Essential content and
   actions remain reachable at every breakpoint.
6. **Progressive and honest feedback.** Show loading, empty and error states explicitly;
   never leave a blank or stale screen.
7. **Motion with purpose.** Animate state changes and overlays to explain them; never
   animate layout in a way that changes the result.
8. **One primary action.** Each view has a clear next step; secondary actions recede.

### A1.4 Visual signature

Modern, flat, minimal and pristine. Generous but disciplined spacing, a restrained
neutral palette, one primary accent, soft surfaces, modest radii, and light elevation.
Typography carries hierarchy; borders and shadows are used only where they add
structure.

### A1.5 Non-goals

- This is not a brand book or marketing style guide.
- This is not a component implementation or a replacement for platform conventions where
  they are accessible and visually compatible.
- RTL mirroring, data visualization primitives and motion choreography beyond the
  durations in `gui-spec.md` §4 are not part of `gui-v1`; they are project extensions.

---

## A2 Foundations

### A2.1 Token model

Tokens are the single source of truth for visual values. They have two required tiers and
one optional tier:

| Tier | Purpose | Examples |
| --- | --- | --- |
| **Core** | Scales and primitives | `font.size`, `space.m`, `radius.md`, `motion.fast`, `breakpoint.md`, `shadow.md` |
| **Semantic** | Roles with meaning, resolved per mode/theme | `color.bg`, `color.fg`, `color.primary`, `color.error-on` |
| **Component** (optional) | Component-specific aliases or overrides | `button.primary.background`, `table.row.height` |

Rules:

- Use semantic tokens in screens, not raw hex values or per-screen numbers.
- Add a component token only when a component needs a value that is not expressible by a
  semantic token, or when a project needs a documented override. Do not add aliases for
  their own sake.
- The baseline core and semantic values are defined in `gui-spec.md` §4. This design
  system owns the project's overrides and the rationale; the format owns the baseline so
  a document renders deterministically without a project theme.
- The machine-readable serialization is DTCG JSON (Appendix A). Markdown-only templates
  describe the format; they do not ship generated token files.
- Token resolution order is: explicit attribute, node mode, component default, global
  default (`gui-spec.md` §4.1). Project theme overrides are applied before alias
  resolution.

### A2.2 Color

Color has two modes, `light` and `dark`. A mode selects semantic color tokens; it never
changes layout. Every color used in a component must be a token or a documented
alpha blend of a token.

| Role group | Tokens | Use |
| --- | --- | --- |
| Canvas and surfaces | `bg`, `surface`, `raised` | Page, panels and cards. Move one step up for nesting; do not invent new surface colors. |
| Text and icons | `fg`, `muted`, `neutral-on` | Primary and secondary text. `muted` is not for essential text. |
| Lines | `border` | Borders, dividers, separators. |
| Accent | `primary`, `on-primary`, `primary-soft` | Selection, primary actions, active navigation. Use sparingly. |
| Focus | `focus-ring` | Keyboard focus only. |
| Neutral support | `neutral-soft`, `neutral-on`, `scrim` | Secondary buttons, neutral tags, modal backdrops. |
| Semantic | `info`, `success`, `alert`, `warning`, `error` and their `-soft`, `-on`, `-contrast` variants | Status and meaning only, never decoration. |
| Badge palette | `badge-blue`, `badge-purple`, `badge-pink`, `badge-teal`, `badge-indigo`, `badge-cyan`, `badge-lime`, `badge-gray`, `badge-contrast` | Content-driven categorization. |

Rules:

- Meaning is never carried by color alone: pair tone with text, icon or shape.
- Use `*-on` on soft backgrounds and `*-contrast` on solid tone backgrounds.
- Alpha blends are deterministic and limited to the documented tag/border/overlay
  recipes in `gui-spec.md` §4.6 and §4.8.
- A node that changes `mode` but not `bg` inherits the painted background while using the
  new mode's foregrounds; set `bg` explicitly when the surface should change.
- Project brand colors replace semantic values through theme overrides, not through
  per-screen hex values.

### A2.3 Typography

The baseline is a system UI family with an optional Inter first choice, a 16 px base,
13 px small and 20 px large. The full scale, line heights and weights are normative in
`gui-spec.md` §4.2.

| Style | Size / weight | Use |
| --- | --- | --- |
| Display | large / bold | Rare hero or empty-state emphasis. |
| Title | large / semibold | Document, dialog and screen titles. |
| Heading | normal / semibold | Section headings (`label level=3–4`). |
| Body | normal / regular | Default text. |
| Label | small / medium | Field labels, metadata, captions. |
| Caption | small / regular | Hints, descriptions, secondary metadata. |
| Mono | mono / regular | Code, identifiers, keyboard keys. |

Rules:

- Sentence case for labels, headings, buttons and menu items. No all-caps except
  established acronyms.
- Line length SHOULD stay near 70–90 characters for prose; constrain content width.
- Single-line text truncates with `…`; multi-line text wraps or clamps with `…`. Never
  clip text without an ellipsis.
- Project fonts must include the full weight set used, load deterministically, and
  document a fallback. Dynamic type is explicit through `size` attributes, not implicit
  platform scaling (`gui-spec.md` §7).

### A2.4 Spacing, density and sizing

Spacing uses the 4 px scale `none 0`, `xs 4`, `s 8`, `m 12`, `l 16`, `xl 24`. These are the
only spacing values for padding, gaps and insets (`gui-spec.md` §4.3).

- Use spacing to group before adding borders or dividers.
- One consistent gap between siblings; do not mix gaps within a repeated group.
- Controls use the documented heights (`40` normal, `32` small, `48` large); touch
  targets are at least `44×44`.
- Density is a project theme decision: `comfortable` (baseline) or `compact` (via token
  overrides such as smaller control heights and gaps). Compact mode must keep the 44 px
  touch floor on touch platforms. Record the override in A3.
- Widths, heights and icon sizes are numeric; spacing is always a token.

### A2.5 Shape, borders, elevation and layering

- Radii: `sm 6`, `md 10`, `lg 14`, `xl 20`, `pill 999` (`gui-spec.md` §4.4). Use the
  smallest radius that fits the element; do not mix arbitrary radii.
- Borders are 1 px `border` unless a component specifies otherwise. Use borders for
  structure; use elevation for overlays and raised surfaces.
- Shadows: `sm`, `md`, `lg` (`gui-spec.md` §4.4). Shadows never affect layout.
- Layering is explicit: base 0, sticky 10, overlay 20, dialog 30, toast 40, tooltip 50.
  An overlay always paints above the content it covers. Do not invent z-index values.
- Cards are surfaces with optional border or `sm` elevation, not both by default. Dialogs
  and sheets use `lg`.

### A2.6 Motion

- Durations: `fast 120ms`, `normal 200ms`, `slow 320ms`; easing
  `cubic-bezier(0.2, 0, 0, 1)` (`gui-spec.md` §4.4).
- Use `fast` for hover, press and focus; `normal` for menus, popovers and dialogs;
  `slow` only for larger transitions such as sheets.
- Animate opacity and transform, not layout. No animation may change the layout result.
- Honor reduced motion: replace rotation, shimmer and large movement with a static state.
- Do not animate essential information or delay access to content.

### A2.7 Iconography

- Use one vector icon set with a consistent visual style, nominal 24 px grid and stroke
  weight. Do not mix icon families.
- Sizes are `16`, `20` and `24` (`icon.size-sm`, `icon.size`, `icon.size-lg`). Match the
  size to the surrounding text and align optically.
- Icons inherit the current text color, so they adapt to mode and theme.
- An icon that acts as a control needs an accessible name; the action description serves
  as it. Decorative icons are hidden from assistive technology.
- Names are kebab-case and size-independent (`chevron-down`, not `chevron-down-20`).
  Appendix C lists the names used by the specification; the project supplies the assets.
- Do not use icons as the only signal for status; pair with text where meaning matters.

### A2.8 Imagery and illustration

- Images use a declared aspect (`1:1`, `4:3`, `3:2`, `16:9`, `21:9`) and `fit=cover` by
  default; use `contain` for diagrams and logos.
- Always provide `alt`; use `""` only for decorative images. On load failure show the
  neutral placeholder, never an empty hole.
- Prefer real content or simple geometric illustrations over generic stock imagery.
- Media may go full-bleed; text and controls keep the page grid and margins.

### A2.9 Layout grid and breakpoints

Breakpoints are `sm < 640`, `md 640–899`, `lg 900–1199`, `xl 1200+`
(`gui-spec.md` §4.4).

| Range | Columns | Gutter | Page margin |
| --- | --- | --- | --- |
| `sm` | 4 | `l` (16) | `l` (16) |
| `md` | 8 | `l` (16) | `l` (16) |
| `lg` | 12 | `l` (16) | `xl` (24) |
| `xl` | 12 | `l` (16) | `xl` (24) |

Rules:

- Constrain prose and forms; go full-bleed only for media, tables and data grids.
- Responsive behavior reflows and relocates before hiding. Use `visible-at`/`hide-at`
  only for genuinely secondary content.
- Collapse side navigation into a drawer or menu on `sm`; do not shrink it to unusable
  icons.
- Never nest scrollable areas; each view has one primary scroll direction.
- Tables may scroll horizontally only when necessary; prefer column priority or a card
  layout on small screens.
- Safe-area insets are explicit inputs and stay outside the content box.

Alignment is intentional, not incidental: repeated rows share fixed leading and trailing
slots; text that repeats shares one leading edge; numbers are right-aligned; single-line
rows are vertically centered and wrapping rows are top-aligned. Align through shared
columns and the spacing scale, never through per-item offsets.

### A2.10 Data visualization

Data visualization is a project extension in `gui-v1` (charts are not a catalog
component). When added:

- Use the semantic colors for meaning and the badge palette for categories; never use
  more than the documented category set.
- Label axes and values; do not rely on color alone; provide a text summary or table.
- Match chart typography to A2.3 and keep gridlines at `border`.
- Provide empty, loading and error states like any other data view.

### A2.11 Density modes

`comfortable` is the baseline. `compact` is a documented theme override for
information-dense desktop screens: reduce `control.height` to 32, row heights to the
dense variants, and spacing one step where it does not hurt grouping. Do not mix density
modes in one view. Touch platforms keep 44 px targets even in compact mode.

---

## A3 Themes

A **mode** is `light` or `dark`. A **theme** is a named set of token overrides on top of
the baseline, typically colors.

- The standard theme is the baseline in `gui-spec.md` §4. It is always available.
- A project theme extends the standard theme and overrides semantic tokens only, unless
  it has a documented reason to change core scales.
- Themes are bundled resources; a theme is selected at the application level, not
  inferred per screen. `gui-v1` documents see the resolved values; selecting a named theme
  is an application-layer concern. If the host cannot select a theme, apply its overrides
  through the document's `theme` block.
- Theme names are stable and versioned. Renaming a theme is a breaking change.
- Every theme must preserve the contrast guarantees in A7 for text, icons and focus.
- Theme overrides are recorded here (or in a linked theme file) with owner and rationale.

Project theme record:

| Theme | Extends | Overrides | Owner | Status |
| --- | --- | --- | --- | --- |
| Standard | — | Baseline | — | Default |
| _project theme_ | Standard | _tokens_ | _owner_ | _proposed / active / deprecated_ |

Reserved `gui-v1` theme-block keys are documented in `gui-spec.md` §4.1. Unknown keys are
errors (`E003`).

---

## A4 Components

The normative catalog, attributes and defaults are in `gui-spec.md` §6 and §4.7. This
section explains when to use each component and the rules that are not obvious from the
syntax.

### A4.1 Component documentation template

When adding a component to the project catalog, document:

1. **Purpose** — the user problem it solves.
2. **Anatomy** — parts, slots and required content.
3. **Use when** — the situations it is designed for.
4. **Avoid** — the nearest wrong use and the better alternative.
5. **Variants and states** — supported variants plus default, hover, focus, pressed,
   selected, disabled, loading and error behavior.
6. **Content rules** — labels, capitalization, length and empty text.
7. **Accessibility** — role, name, states, keyboard and focus behavior.
8. **Platform notes** — native control, custom drawing or unsupported.
9. **Spec link** — the normative section in `gui-spec.md`.

### A4.2 Layout and structure

| Component | Use when | Avoid or note |
| --- | --- | --- |
| `rows`, `columns` | Stacking related content in one direction. | Do not nest deeply to fake a grid; use `grid`. |
| `grid` | Two-dimensional layout or collections of similar cards. | Do not use for a single row or column. |
| `list`, `list-item` | Homogeneous vertical collections with optional leading and trailing accessories. | Do not use for tabular comparison; use `table`. |
| `tabs` | Switching between peer views at the same level. | Do not use for sequential steps or more than 5–7 tabs. |
| `action-bar` | A view's primary and secondary actions. | Do not duplicate actions already in the content. |
| `carousel` | Browsing a small set of media or featured items. | Do not hide essential content or rely on swipe alone. |
| `document` | Page or dialog content with title, content and footer. | One primary scroll area; do not nest documents. |
| `document-header`, `document-footer` | Title/description block and footer actions inside a document. | Keep one `default` action; do not duplicate page actions. |
| `screen-ref` | Reusing a screen inside another screen. | No cycles; IDs must remain unique after expansion. |
| `field` | Pairing a label, control, hint and error. | Never use a placeholder as the only label. |
| `banner` | Persistent, page-level status or guidance. | Transient feedback belongs in a toast. |
| `table` | Comparing structured, tabular records. | Do not use for simple navigation lists. |
| `tree` | Navigating a hierarchy with expand/collapse. | Avoid deep trees; provide search for large hierarchies. |
| `popover` | Contextual content or a small set of actions anchored to a control. | Do not put essential information only in a popover. |
| `toast` | Brief, non-blocking confirmation or status. | Do not use for errors that require a decision; use a banner or dialog. |

### A4.3 Text and display

| Component | Use when | Avoid or note |
| --- | --- | --- |
| `label` | Any text, including headings and links. | Set `level` for real headings; do not fake hierarchy with size alone. |
| `kbd` | Showing a keyboard shortcut. | Do not use for non-keyboard text. |
| `icon` | Compact visual meaning or an icon-only action. | Icon-only actions need a `label` and an accessible name. |
| `tag` | Soft, neutral or semantic categorization. | Do not use tags for actions. |
| `badge` | Small, solid counts or status labels. | Keep text short; do not use color alone. |
| `image` | Content imagery. | Always provide `alt`; use `""` only when decorative. |
| `avatar` | A person or entity identity. | Provide `alt` or initials; do not rely on the image alone. |
| `progress` | Determinate progress. | Use `spinner` or `skeleton` when progress is unknown. |
| `spinner` | Short, indeterminate waits. | Provide a label; do not spin forever without recovery. |
| `skeleton` | Loading placeholders that preserve layout. | Do not use for actions or as a permanent empty state. |
| `divider` | Separating content that spacing alone cannot group. | Do not over-divide; whitespace is preferred. |
| `spacer` | Absorbing space in a flex layout. | Do not use fixed spacers to fake alignment. |
| `tooltip` | A short description on hover or focus. | Never the only source of essential information; never interactive. |

### A4.4 Inputs

All inputs use a visible label, reflect the states in `gui-spec.md` §4.8, and expose
required, invalid and disabled semantics.

| Component | Use when | Avoid or note |
| --- | --- | --- |
| `textfield` | Single-line text, numbers, email, phone, URL or search. | Use the narrowest `input` type that fits. |
| `textarea` | Multi-line free text. | Set `rows`; do not use for rich text. |
| `date`, `time`, `date-range` | Choosing dates or times. | Provide format hints and valid bounds. |
| `password` | Secret entry. | Always provide a reveal control; never log the value. |
| `dropdown` | Choosing one option from a known, short list. | Do not use for more than a few dozen options; use search/combobox. |
| `checkbox` | Independent on/off choices. | Do not use for mutually exclusive choices; use radios. |
| `radio`, `radio-group` | Exactly one choice from a small set. | Do not use for more than about 7 options; use a dropdown. |
| `switch` | Immediate on/off settings. | Do not use when the change requires a Save action; use a checkbox. |
| `slider` | Approximate value in a range. | Always show the current value; do not use for precise entry. |
| `field` | Wrapping any input with label, hint and error. | Error text replaces hint and marks the control invalid. |

Validation rules:

- Validate on blur and on submit; do not show errors while the user is still typing a
  valid value.
- Messages state what is wrong and how to fix it; place them at the field, not only in a
  summary.
- Required fields are marked; optional fields are not.
- Keep the user's input on error; never clear a form on failure.

### A4.5 Actions and navigation

| Component | Use when | Avoid or note |
| --- | --- | --- |
| `button` | Triggering an action. | One primary action per view; use the variant hierarchy below. |
| `menu`, `menu-item` | A compact set of contextual actions. | Do not hide primary actions in a menu; keyboard navigable. |
| `pagination` | Moving through a large, ordered collection. | Do not paginate tiny collections. |
| `breadcrumbs` | Showing location in a hierarchy. | Not a substitute for primary navigation. |
| `tabs` | Peer views (see A4.2). | Do not use tabs as a wizard. |

Button hierarchy:

- **Primary** — the single most likely next action.
- **Secondary** — a supporting action.
- **Outline** — an action that needs separation without primary weight.
- **Ghost** — a low-emphasis action, often in dense surfaces.
- **Danger** — destructive actions; pair with confirmation when irreversible.

### A4.6 Tables and trees

**Tables** are for comparison. Use `table-head` for column labels, right-align numbers,
and keep row actions at the trailing edge. Define selection, sorting and density
explicitly (`sortable`, `sort`, `selectable`, `dense`). Provide:
empty state, loading skeleton, error banner and a caption or accessible name. On small
screens, prioritize columns or switch to a card list; do not simply shrink the table.

**Trees** are for hierarchy. Use `tree` with `tree-item` children; expand the first two
levels by default unless the content suggests otherwise. Non-leaf items show a chevron.
Selection is `single`, `multiple` or `none`; do not mix. Provide a label and keyboard
navigation. For very large hierarchies, add search rather than deep nesting.

### A4.7 Overlays and feedback

| Need | Use | Not |
| --- | --- | --- |
| Short description on hover/focus | `tooltip` | Essential instructions, interactive content |
| Contextual content or actions | `popover` | A full task flow |
| Brief, non-blocking status | `toast` | Errors that need a decision |
| Persistent page-level status | `banner` | Transient confirmation |
| A focused task or confirmation | `dialog` (screen kind) | A page navigation |
| A side task or detail panel | `drawer` (screen kind) | A modal task on desktop |
| A bottom action sheet on mobile | `sheet` (screen kind) | A persistent page section |

Rules:

- One modal at a time. Dialogs and modal popovers trap focus and return it to the opener.
- Toasts never steal focus; pause their timer on hover or focus; limit to three visible.
- Errors that block progress use a banner or dialog, not a disappearing toast.
- Tooltips are descriptions, not names; they never replace the accessible name.
- Destructive actions state the consequence and offer a safe cancel.

---

## A5 Patterns

Patterns compose components into recurring screens. The `gui-v1` snippets are examples,
not a second specification; exact attributes are in `gui-spec.md`.

### A5.1 App shell and navigation

Use a persistent shell with a clear product identity, primary navigation and a content
region. Desktop may use a sidebar or navigation rail; mobile uses a drawer or a
bottom-level menu. The active location uses the selected state and the primary color.
Keep navigation labels stable; do not rename the same destination between screens.

### A5.2 List-detail and split view

Use `grid` with a navigation `list` and a `document` detail. On `sm`, hide the list and
open the detail as a screen; provide a back affordance. Do not nest scroll areas: the
list and the detail scroll independently only when both are visible side by side.

```text
grid cols="280 1fr" gap=m
  list navigation=true
    list-item "Atlas" icon=palette selected action=open-atlas
    list-item "Orbit" icon=smartphone action=open-orbit
  document
    document-header "Atlas" description="Design system" icon=palette
    rows gap=l
      ...
```

### A5.3 Forms and validation

Group related fields, use a single column by default, and place the primary action at the
end of the form (or in the document footer). Use `field` for every input. Required
markers, hints and errors follow A4.4. On submit, keep the user's input and move focus to
the first invalid field.

### A5.4 Search, filter and sort

Place search above the collection, filters in a row or a collapsible panel, and sort
controls in the table header. Show active filters as removable tags. Always provide a
result count and an empty state that explains how to recover. Do not apply filters
silently without a visible summary.

### A5.5 Tables and data grids

Tables support selection, sorting and optional column resizing as explicit features.
Show a header, a caption or accessible name, and a clear empty state. Numbers are
right-aligned; text is left-aligned. Row actions align to the trailing edge. On smaller
screens, reduce columns by priority or switch to cards.

### A5.6 Dashboard

Use a `grid` of metric cards (`rows` with `label`, `tag`/`badge` and `progress`), a
recent-activity `list`, and an `action-bar` for the main action. Keep metrics scannable;
do not mix unrelated chart types. Every metric needs a label, value and, where relevant,
a comparison or timestamp.

### A5.7 Authentication

Keep the form narrow and focused, with one primary action. Offer password recovery and
account creation as secondary links. Errors are specific but do not reveal whether an
account exists. Never prefill secrets. Support password managers and paste.

### A5.8 Settings

Group settings by task, not by data model. Use `document` with sections, `field` for
each input, and a sticky or footer action bar for Save/Cancel. Distinguish immediate
settings (switch) from settings that require Save (checkbox/form). Show which changes are
unsaved and confirm when leaving with unsaved changes.

### A5.9 Onboarding

Use a short sequence of focused screens or a single checklist, not a carousel of
marketing copy. State progress, allow skipping, and make the first valuable action
obvious. Do not block the product behind a tour.

### A5.10 Empty, loading and error states

Every view and collection defines all three:

- **Empty** — say why it is empty and the next action (`icon` + `label` + `button`).
- **Loading** — use `skeleton` to preserve layout for content, `spinner` for short waits;
  never leave a blank screen.
- **Error** — use `banner tone=error` with a recovery action; keep partial content when
  possible.

### A5.11 Destructive confirmation

State the object and consequence, use `danger` for the destructive action, and make
Cancel the safe default. For irreversible actions, require an explicit choice; do not
rely on an undo toast alone. Use a dialog for a decision, a toast for a completed action.

### A5.12 Notifications and feedback

Use a toast for brief success or status that does not need a decision; a banner for
persistent, page-level messages; a dialog for decisions; inline field errors for form
problems. Do not stack multiple messages about the same event. Announce dynamic messages
with the correct live-region role.

### A5.13 Responsive adaptation

- `sm`: one column, drawer navigation, stacked action bars, cards instead of wide tables.
- `md`: two-column forms or list-detail where space allows.
- `lg`/`xl`: persistent navigation, multi-column grids, constrained reading width.
- Never hide essential content or actions; relocate them.
- Keep touch targets at 44×44 on touch platforms even in compact density.

---

## A6 Content design

### A6.1 Voice and tone

Clear, calm, direct and human. Prefer plain verbs and short sentences. Be specific about
what happened and what to do next. Avoid blame, jargon, humor in errors, and exclamation
marks.

### A6.2 Terminology

Keep one term per concept across navigation, labels, help and errors. Record project
terms in a glossary and link it here. Do not alternate synonyms for the same object.

### A6.3 Capitalization and punctuation

- Sentence case for labels, headings, buttons, menu items and tabs.
- No terminal punctuation in labels, buttons or short headings.
- Full sentences for help text, empty states and errors.
- Use the serial comma consistently.
- Use `…` for truncation and for actions that open a further step (for example “More…”),
  not `...` in UI copy.

### A6.4 Labels, placeholders and help

- Every input has a visible label. A placeholder is an example or hint, never the label.
- Help text explains format, constraints or consequences before the error occurs.
- Required fields are marked; optional fields are not.
- Keep labels short and noun-based; start actions with a verb.

### A6.5 Error messages

Use: **what went wrong + why (if useful) + what to do next**.

- “Enter a date in the future.” not “Invalid input.”
- “We couldn’t save your changes. Check your connection and try again.”
- Do not expose stack traces, codes without explanation, or internal identifiers.
- Place the message at the field when possible; use a summary for multiple errors.

### A6.6 Dates, numbers and currency

- Dates follow `YYYY-MM-DD` in `gui-v1` values; display them in the user’s locale.
- Times follow `HH:MM` in values; display with the locale’s separator and time zone when
  relevant.
- Numbers use locale grouping and decimal separators. Right-align numeric table columns.
- Currency includes an ISO code or a locale symbol consistently; do not mix.
- Use a non-breaking space between a number and its unit where the platform supports it.

### A6.7 Internationalization and RTL

- Keep copy translatable: no concatenated sentences, no text baked into images.
- Allow 30–40% text expansion; do not fix widths to English strings.
- `gui-v1` is LTR-only. If the product needs RTL, treat it as a project extension and
  document mirroring, icon direction and layout behavior before implementation.
- Use locale-aware date, number and currency formatting at the platform layer.

---

## A7 Accessibility

### A7.1 Commitment

The target is **WCAG 2.2 AA**. Accessibility is a release gate, not a later enhancement.
The normative per-component roles and platform semantics are in `gui-spec.md` §8.

### A7.2 Contrast

The baseline theme was checked with the WCAG relative-luminance formula. Key pairs:

| Pair | Ratio | Result |
| --- | --- | --- |
| `fg` on `bg` (light) | 17.75:1 | Pass AAA |
| `muted` on `bg` (light) | 4.97:1 | Pass AA |
| `primary` on `bg` (light) | 5.17:1 | Pass AA |
| `on-primary` on `primary` (light) | 5.17:1 | Pass AA |
| `info-on` on `info-soft` (light) | 5.57:1 | Pass AA |
| `success-on` on `success-soft` (light) | 5.40:1 | Pass AA |
| `alert-on` on `alert-soft` (light) | 6.62:1 | Pass AA |
| `warning-on` on `warning-soft` (light) | 5.33:1 | Pass AA |
| `error-on` on `error-soft` (light) | 6.05:1 | Pass AA |
| `neutral-on` on `neutral-soft` (light) | 9.49:1 | Pass AAA |
| `fg` on `bg` (dark) | 17.43:1 | Pass AAA |
| `muted` on `bg` (dark) | 6.38:1 | Pass AA |
| `primary` on `bg` (dark) | 7.42:1 | Pass AAA |
| `on-primary` on `primary` (dark) | 7.36:1 | Pass AAA |
| `info-on` on `info-soft` (dark) | 8.28:1 | Pass AAA |
| `error-on` on `error-soft` (dark) | 8.39:1 | Pass AAA |
| Badge palette (light, white text) | 4.99–7.69:1 | Pass AA |
| Badge palette (dark, `badge-contrast` text) | 7.19–14.11:1 | Pass AA |

All baseline semantic text/soft pairs pass AA; the table lists representative pairs. Solid
semantic badges use `<tone>-contrast` and follow the same rule.

Requirements:

- Normal text 4.5:1; large text (18 pt / 14 pt bold) and UI graphics 3:1.
- Focus indicators 3:1 against adjacent colors and clearly visible in both modes.
- Borders that carry meaning (input, selection) meet 3:1.
- Recompute contrast whenever a theme or token changes; contrast is part of token review.

### A7.3 Keyboard and focus

- Every interactive element is keyboard reachable in tree order.
- Visible focus ring on every focusable element; never remove it without a replacement.
- Focus rings appear for keyboard navigation, not pointer/touch.
- Overlays trap focus while modal and return focus to the opener on close.
- Provide a logical focus order; do not use positive tabindex.
- Support the component-specific keys in `gui-spec.md` §8.

### A7.4 Screen readers and semantics

- Every interactive component has an accessible name from text, `label` or `for`.
- Expose role, value, required, invalid, disabled, expanded, selected and sort states as
  specified in `gui-spec.md` §8.
- Dynamic messages use `role=status` or `role=alert` appropriately.
- Decorative images, icons and skeletons are hidden; meaningful ones have text.
- Table captions, tree levels and tab relationships are exposed.

### A7.5 Motion, touch and zoom

- Honor reduced motion; replace shimmer, rotation and large movement with static states.
- Touch targets are at least 44×44; small visual controls get an invisible hit area.
- Support 200% zoom and 320 CSS px reflow without loss of content or function.
- Do not disable text selection or paste in inputs.
- Do not rely on hover for essential information.

### A7.6 Testing

- Automated: contrast, accessible names, roles, focus order and token validation.
- Manual: keyboard-only pass, screen-reader pass on each target platform, reduced-motion
  pass, 200% zoom pass.
- Every component test includes default, hover, focus, pressed, selected, disabled and
  error states where applicable.
- Accessibility regressions block release; exceptions require a documented decision and
  an owner.

---

## A8 Assets and implementation

This template ships documentation only. A project adopting it supplies or links the
following assets.

| Asset | Expectation |
| --- | --- |
| Fonts | The chosen UI and mono families with licenses, weights and a documented fallback. |
| Icons | One vector set matching A2.7 and the names in Appendix C. |
| Tokens | A DTCG source and generated outputs for the target platforms (Appendix A). |
| Component library | The implemented components, with a catalog or storybook for review. |
| Examples | Screen definitions or screenshots for the patterns in A5. |
| Platform notes | Native-vs-custom decisions and known differences per platform. |

Generated token outputs, when the project adds them: canonical resolved JSON, CSS custom
properties, Android resources/Compose theme, Swing `UIManager`/properties, and iOS
constants. The `gui-v1` renderer consumes the resolved token set; the theme block in a
document is an override, not a second source of truth.

---

## A9 Governance

### A9.1 Ownership

The design system is co-owned. A named owner (or small group) approves changes to
principles, tokens, component usage and patterns. Implementers own platform behavior;
specifying agents and humans own intent.

### A9.2 Versioning

- **Design system:** semantic version. Major for removed/renamed tokens or components;
  minor for additive decisions; patch for clarification.
- **`gui-v1`:** the directive version is independent. Breaking syntax changes require a
  new directive; additive format revisions are tracked in `gui-spec.md`.
- **Tokens:** a value change is at least a minor design-system change; a rename or removal
  is major. Every change records impact and migration.

### A9.3 Change process

1. Propose the change with the user problem and affected components/tokens.
2. Check contrast, accessibility, platform feasibility and existing patterns.
3. Update this document and, if normative, `gui-spec.md` and its revision.
4. Update examples, tests and the decision log.
5. Review with the owner; merge only when tokens, docs and tests agree.

### A9.4 Deprecation and migration

Mark deprecated tokens/components with the replacement and removal version. Keep them
working for at least one minor release unless a security or accessibility issue forces a
break. Provide a migration note and update the catalog.

### A9.5 Adoption

Track adoption by token usage, component usage and deviation count. A deviation is
acceptable only when documented; repeated deviations become a system change, not a local
habit.

---

## A10 Quality and conformance

### A10.1 Product conformance levels

| Level | Meaning |
| --- | --- |
| **Adopted** | Uses the baseline tokens and catalog without overrides. |
| **Adapted** | Uses documented theme/token overrides and the catalog; no new components. |
| **Extended** | Adds project components or patterns, documented in this system and the spec. |

A product must declare its level and list unsupported components. Silent substitution is
not allowed.

### A10.2 Review checklist

- Tokens only; no raw colors, spacing or type sizes.
- Correct component for the intent; no look-alike custom widgets.
- All states implemented, including disabled, invalid, loading and empty.
- Keyboard, focus, roles and names match `gui-spec.md` §8.
- Contrast and touch targets meet A7.
- Content follows A6; errors are actionable.
- Responsive behavior follows A2.9 and A5.13.
- Deviations are recorded with an owner and rationale.

### A10.3 Automated checks

- Token schema, alias cycles, mode parity and unknown keys.
- Contrast for every foreground/background pair used by components.
- Catalog coverage: every component used is declared supported.
- Visual regression for component states and key screens.
- Accessibility checks (roles, names, focus order) in the component test suite.
- Link and anchor checks for this document and `gui-spec.md`.

### A10.4 Baseline conformance

Renderer conformance levels, determinism, validation error codes and test fixtures are
defined in `gui-spec.md` §1, §9 and §10. A product's design-system review does not replace
renderer conformance.

---

## Appendix A — Token source format

Tokens are serialized as DTCG (Design Tokens Community Group) JSON. This template
specifies the format; it does not ship token files.

### A.1 File layout

```text
tokens/
  core.tokens.json
  semantic.tokens.json
  semantic.dark.tokens.json
  themes/<theme>.tokens.json
  resolved.tokens.json        # generated
```

- `core` holds scales and primitives.
- `semantic` holds the light/standard values; `semantic.dark` overrides them.
- A named theme overrides semantic tokens only and declares what it extends.
- `resolved` is generated, canonical and consumed by renderers and tests.

### A.2 Format rules

- Use `$value`, `$type` and `$description`; put `$type` at group level where possible.
- Aliases use `{group.token}` and must resolve without cycles.
- Types: `color`, `dimension`, `fontFamily`, `fontWeight`, `duration`, `number`,
  `cubicBezier`, `shadow`.
- Dimensions use `{ "value": 12, "unit": "px" }`; durations use
  `{ "value": 120, "unit": "ms" }`.
- Colors are uppercase hex strings; alpha is part of the hex (`#2563EB66`).
- No floating-point dimensions; no per-screen ad-hoc values.
- Canonical serialization: sorted keys, two-space indent, UTF-8, trailing newline.

### A.3 Example

```json
{
  "space": {
    "$type": "dimension",
    "unit": { "$value": { "value": 4, "unit": "px" } },
    "m":    { "$value": { "value": 12, "unit": "px" } }
  },
  "font": {
    "$type": "fontFamily",
    "family": { "$value": "Inter, system-ui, sans-serif" }
  },
  "color": {
    "$type": "color",
    "bg":      { "$value": "#FFFFFF" },
    "primary": { "$value": "#2563EB" }
  },
  "motion": {
    "fast": { "$type": "duration", "$value": { "value": 120, "unit": "ms" } }
  }
}
```

Dark mode override:

```json
{
  "color": {
    "bg":      { "$value": "#0C111D" },
    "primary": { "$value": "#60A5FA" }
  }
}
```

Optional component aliases:

```json
{
  "button": {
    "primary": {
      "background": { "$type": "color", "$value": "{color.primary}" },
      "text":       { "$type": "color", "$value": "{color.on-primary}" }
    }
  }
}
```

### A.4 Mapping to the `gui-v1` theme block

| Document key | Token | Mode |
| --- | --- | --- |
| `light.primary` | `color.primary` | light |
| `dark.primary` | `color.primary` | dark |
| `space.unit` | `space.unit` | both |
| `font.size` | `font.size` | both |
| `font.family` | `font.family` | both |

A document key is an override on top of the resolved theme. Unknown keys are `E003`.

### A.5 Token validation

- Schema and type conformance.
- Alias cycles and missing references.
- Mode parity: every semantic color has a light and a dark value.
- Contrast pairs from A7.
- Orphan tokens and unused component aliases.
- Name stability and changelog entry for renames.

---

## Appendix B — Token index

Names and types; baseline values are in `gui-spec.md` §4.

```text
Typography
  font.family (fontFamily), font.mono (fontFamily)
  font.size, font.size-small, font.size-large (dimension)
  font.line-small, font.line-normal, font.line-large (dimension)
  font.weight-regular, font.weight-medium, font.weight-semibold,
  font.weight-bold (fontWeight)

Spacing
  space.unit, space.none, space.xs, space.s, space.m, space.l, space.xl
  (dimension)

Shape
  radius.sm, radius.md, radius.lg, radius.xl, radius.pill (dimension)

Controls and sizing
  control.height, control.height-small, control.height-large,
  control.pad-x, control.pad-y, button.pad-x, list-item.min-height,
  menu.item-height, table.row-height, table.row-height-dense,
  radio.size, pagination.size, spinner.size, focus.width, focus.offset,
  touch.min, disabled.opacity (dimension / number)
  icon.size-sm, icon.size, icon.size-lg (dimension)
  tree.row-height, tree.indent (dimension)

Motion
  motion.fast, motion.normal, motion.slow (duration)
  motion.easing (cubicBezier)

Breakpoints
  breakpoint.sm, breakpoint.md, breakpoint.lg, breakpoint.xl (dimension)

Elevation and layering
  shadow.sm, shadow.md, shadow.lg (shadow)
  layer.base, layer.sticky, layer.overlay, layer.dialog, layer.toast,
  layer.tooltip (number)

Overlays
  tooltip.max-width, tooltip.delay, popover.min-width, toast.max-width,
  toast.duration (dimension / duration)

Color roles (light and dark)
  color.bg, color.surface, color.raised, color.fg, color.muted,
  color.border, color.primary, color.on-primary, color.primary-soft,
  color.focus-ring, color.neutral-soft, color.neutral-on, color.scrim
  (color)

Semantic tones (each with base, -soft, -on, -contrast)
  color.info, color.success, color.alert, color.warning, color.error
  (color)

Badge palette
  color.badge-blue, color.badge-purple, color.badge-pink,
  color.badge-teal, color.badge-indigo, color.badge-cyan,
  color.badge-lime, color.badge-gray, color.badge-contrast (color)
```

---

## Appendix C — Icon inventory

The specification references these names. The project supplies the matching vector
assets; names are provisional until the icon package is adopted.

```text
Navigation   chevron-up, chevron-down, chevron-left, chevron-right,
             arrow-left, arrow-right, home, menu, close
Actions      search, filter, plus, minus, check, edit, trash, download,
             upload, more-horizontal
Status       info, check-circle, alert-triangle, x-circle
Content      mail, settings, palette, smartphone, calendar, image, user
Visibility   eye, eye-off
Sorting      sort-asc, sort-desc
Expansion    expand, collapse
```

Rules: one set and stroke style; 24 px grid; sizes 16/20/24; kebab-case; icons inherit
the text color; icon-only controls need an accessible name.

---

## Appendix D — Changelog and decisions

### D.1 Changelog

| Version | Change |
| --- | --- |
| 1.0 | Split the former GUI specification into this design system and `gui-spec.md`; renamed the directive to `gui-v1`; added tooltip, popover, toast, tree and sortable/resizable table primitives; added shadow, easing, layering and icon-size tokens; added the token format and index. |

### D.2 Open decisions

| Decision | Status | Note |
| --- | --- | --- |
| Token files and generated platform outputs | Open | Markdown-only scope; format specified in Appendix A. |
| `gui-cookbook.md` | Open | Add when examples/recipes outgrow A5. |
| RTL support | Open | Not part of `gui-v1`; project extension. |
| Data visualization | Open | Project extension; palette and chart components not specified. |
| Density modes | Open | Documented as theme overrides; no `gui-v1` primitive. |
