# GUI Guide and Specification — `gui-v2`

- **Format revision:** 2.0
- **Directive version:** `gui-v2`
- **Status:** Stable, conformance-oriented
- **Audience:** humans, planning agents, implementation agents, renderer implementers
- **Companion:** [`screen-workflow.md`](screen-workflow.md) for screen documents, review and
  prototypes

**Part I** explains what to build and why. **Part II** is the implementer reference:
validation, AST, testing, versioning and a cheat sheet.

The format is finite. Renderers MUST NOT invent padding, fonts, colors, spacing, borders or
alignment. Every default is specified here.

> **Read this first**
> - The first line is `gui-v2`; indentation is two spaces per level.
> - Containers are `row`, `column`, `grid` and `stack`.
> - Primitives are the only nodes with built-in visual styling.
> - Extended and project components expand to primitives and containers.
> - Spacing is `none`, `xs`, `s`, `m`, `l` or `xl`, derived from one master unit.
> - Color modes are `light` and `dark`; each has three neutral shades.
> - Same document + theme + measurement mode + renderer version = same AST, layout boxes,
>   accessibility tree and paint order.

---

## Quick start

```text
gui-v2

screen dashboard "Dashboard" layout=column gap=m pad=l
  page-header "Dashboard" description="Monday, 19 October"
    button "Export" variant=secondary icon=download action=export
    button "New report" variant=primary icon=plus action=new-report
  card "Recent activity"
    list
      list-item "Report ready" description="Q3 summary" icon=download
      list-item "New comment" description="Orbit mentioned you" icon=mail badge="3"
```

The rules that cover most work:

1. **Screen:** `screen <id> "<title>" [kind=...] [layout=row|column|grid]`.
2. **Containers:** `row` (horizontal), `column` (vertical), `grid`, `stack` (overlay).
3. **Primitives:** `text`, `icon`, `image`, `divider`, `spacer`, `button`, `textfield`,
   `textarea`, `select`, `checkbox`, `radio`, `switch`, `slider`, `progress`, `avatar`,
   `badge`, `tag`, `spinner`, `skeleton`, `kbd`.
4. **Extended components:** `field`, `card`, `page-header`, `list`, `table`, `tabs`,
   `banner`, `toast`, `menu`, `breadcrumbs`, `pagination`, `action-bar`, `empty-state`,
   `metric`, `radio-group`, `tree`, `tooltip`, `popover`.
5. **Project components:** declare `component <name>` before screens with `param`/`slot`
   lines and one body root.
6. **Spacing:** only `none`, `xs`, `s`, `m`, `l`, `xl`. No numeric padding or gaps.
7. **Color:** tokens only (`bg`, `surface`, `fg`, `muted`, `brand`, `info`, `error`,
   `badge-blue`, …). No raw hex in component styling.
8. **Text:** positional and quoted: `text "Welcome back"`. Attributes are `key=value`.
9. **Actions:** `action=<id>` names behavior; `screen-workflow.md` defines it.
10. **States:** use documented `disabled`, `invalid`, `selected`, `open`, `expanded`; do not
    fake states with one-off colors.

### Reading paths

| You are… | Read |
| --- | --- |
| **Human defining a screen** | Quick start, §3, §6, §7, then `screen-workflow.md`. |
| **Planning agent** | Quick start, §3, §6, §7, then `screen-workflow.md`. |
| **Implementation agent** | §2–§10 and §11–§13. |
| **Renderer implementer** | §2–§10 and §11–§13. |
| **Prototype agent** | `screen-workflow.md`, §3 and §6. |

---

## Contents

**Part I — Guide**

1. [Purpose and principles](#1-purpose-and-principles)
2. [Core model](#2-core-model)
3. [Syntax](#3-syntax)
4. [Tokens and themes](#4-tokens-and-themes)
5. [Layout](#5-layout)
6. [Components](#6-components)
7. [Patterns](#7-patterns)
8. [Content](#8-content)
9. [Accessibility](#9-accessibility)
10. [Platforms](#10-platforms)

**Part II — Reference**

11. [Validation and error codes](#11-validation-and-error-codes)
12. [AST, normalization and testing](#12-ast-normalization-and-testing)
13. [Versioning and conformance](#13-versioning-and-conformance)
14. [Cheat sheet](#14-cheat-sheet)

---

# Part I — Guide

## 1. Purpose and principles

### 1.1 Purpose

Give humans, planning agents and implementation agents one shared vocabulary for UI
decisions. The same intent should produce the same components, tokens and behavior on web,
Java Swing, Android and iOS. The target is data-heavy business applications, not marketing
sites.

### 1.2 Principles

1. **Clarity before density.** Never trade affordance, legibility or accessibility for
   compactness.
2. **Compose before inventing.** Prefer the catalog and patterns over one-off widgets.
3. **Accessible by default.** Contrast, focus, keyboard and touch targets are part of the
   component.
4. **Token-driven and deterministic.** Color, type, spacing, shape, motion and elevation
   come from tokens.
5. **Responsive by structure.** Reflow and relocate before hiding.
6. **Progressive and honest feedback.** Show loading, empty and error states explicitly.
7. **Motion with purpose.** Explain state changes; never animate layout in a way that
   changes the result.
8. **One primary action.** Each view has a clear next step.

### 1.3 Visual signature

Modern, flat, minimal and pristine. Generous but disciplined spacing, a restrained neutral
palette, one brand accent, soft surfaces, modest radii and light elevation. Typography
carries hierarchy; borders and shadows add structure only where needed.

### 1.4 Non-goals

- Not a brand book or marketing style guide.
- Not a component implementation or a replacement for accessible platform conventions.
- RTL mirroring, data visualization and motion beyond §4 are project extensions.
- The HTML prototype is a review tool, not a production renderer.

---

## 2. Core model

### 2.1 Screens

A screen has an `id`, quoted `title`, `kind`, color `mode`, root `layout` and layout/styling
attributes.

| `kind` | Defaults |
| --- | --- |
| `screen` | Fills viewport; `bg=bg`, `layout=column`, `gap=m`, `pad=l`, `safe=true`. |
| `dialog` | Width 480; content height; `bg=surface`, `pad=l`, `gap=m`, `radius=lg`, `shadow=lg`, centered in `scrim`; `safe=false`. |
| `sheet` | Full width, up to 85% height, bottom; `bg=surface`, `pad=l`, `gap=m`, top `radius=lg`, `shadow=lg`; `safe=false`. |
| `drawer` | Width 360, full height, right; `bg=surface`, `pad=l`, `gap=m`, `shadow=lg`; `safe=true`. |
| `frame` | Content size; `bg=surface`, `border=true`, `radius=lg`, `pad=l`, `gap=m`. |
| `region` | Content size; transparent; `pad=none`, `gap=m`. |

The title is metadata: accessible name and window title where supported. It is not painted.

Screen attributes: `kind`, `layout`, `mode`, `safe`, `placement`, `width`, `height`,
`min-*`, `max-*`, `pad`, `pad-x`, `pad-y`, `gap`, `align`, `justify`, `bg`, `border`,
`border-color`, `radius`, `shadow`, `scroll`, `visible-at`, `hide-at`, `cols`, `rows`,
`col-gap`, `row-gap`, `flow`.

Defaults: `layout=column`, `mode=light`; `safe=true` for `screen`/`drawer`. `placement` is
`left|right` for `drawer`, `top|bottom` for `sheet`.

### 2.2 Node classes

**Containers:** `row`, `column`, `grid`, `stack`.

**Primitives:** `text`, `icon`, `image`, `divider`, `spacer`, `button`, `textfield`,
`textarea`, `select`, `checkbox`, `radio`, `switch`, `slider`, `progress`, `avatar`,
`badge`, `tag`, `spinner`, `skeleton`, `kbd`.

**Built-in extended:** `field`, `card`, `page-header`, `list`/`list-item`, `table`/
`table-head`/`table-row`/`table-cell`, `tabs`/`tab`, `banner`, `toast`, `menu`/`menu-item`,
`breadcrumbs`, `pagination`, `action-bar`, `empty-state`, `metric`, `radio-group`, `tree`/
`tree-item`, `tooltip`, `popover`.

**Project components:** any component registered with a top-level `component` declaration.

Primitives are leaves. Extended/project components are leaves or containers as specified.
Containers with no children are valid.

### 2.3 IDs, paths and actions

- `id` is optional and unique after expansion.
- Every node has a stable structural path: `root`, `root/0`, `root/0/2`, counting document
  order.
- Actions use the node’s `action` name; payloads include path and `id` when present.
- Renderers must not derive behavior from component type alone.
- Auto-generated paths are for tests and event routing only.

### 2.4 Modes and units

A mode is `light` or `dark`; the screen’s mode is inherited and can be overridden per
container. A mode changes tokens, not layout. If a node changes mode without `bg`, it keeps
the painted background and uses the new mode’s foreground.

All dimensions are logical pixels (CSS px, dp, iOS points, Swing logical pixels).
Percentages refer to the parent content box. The document is LTR; RTL is a project
extension. Text is measured by the renderer; tests use §12.4. Images use preferred size and
`aspect` unless `aspect=free`.

### 2.5 Determinism

Parse, validate, normalize, resolve tokens, expand components, measure, lay out, build the
accessibility tree and paint. Layout uses fixed-point 1/64 px. The same inputs produce
identical stages 1–8. Full rules are in §12.

---

## 3. Syntax

### 3.1 Document structure

```text
gui-v2

theme
  key=value

component <name> ["<description>"]
  param <name> [=<default>]
  slot [<name>]
  <body root>

screen <id> "<title>" [attribute ...]
  <node>
    <node>
```

- UTF-8, LF. Two spaces per level; tabs forbidden.
- One optional theme, then component definitions, then screens. Definitions must precede
  screens.
- Blank lines ignored; `#` starts a whole-line comment.
- Strings use JSON escaping. In component bodies `${name}` is a parameter placeholder;
  `\${` writes a literal `${`.
- Positional text is quoted and comes before attributes. Bare booleans are allowed.

### 3.2 Grammar

```ebnf
document   = "gui-v2" NL [ theme ] { component } { screen } ;
theme      = "theme" NL { INDENT2 key "=" value NL } ;
component  = "component" SP name [ SP string ] NL { param | slot } { node } ;
param      = INDENT2 "param" SP name [ "=" value ] NL ;
slot       = INDENT2 "slot" [ SP name ] NL ;
screen     = "screen" SP id SP string { SP attr } NL { node } ;
node       = INDENT type [ SP string ] { SP attr } NL { node } ;
type       = name ;
name       = ( letter | digit | "-" | "." )+ ;
attr       = key [ "=" value ] ;
key        = ( letter | digit | "-" | "." )+ ;
value      = string | bare ;
```

A component body has exactly one root node; `param`/`slot` declarations come first.

### 3.3 Values

| Type | Examples | Notes |
| --- | --- | --- |
| Spacing | `none`, `xs`, `s`, `m`, `l`, `xl` | Only valid padding/gap/inset values. |
| Dimension | `16`, `50%` | Logical px or percent of parent content box. |
| Color | `surface`, `info-soft`, `#2563EB`, `#2563EB66` | Token or hex. |
| Boolean | `true`, `false`, `checked` | Bare form allowed. |
| Enum | `left`, `stretch`, `bottom-start` | Lowercase, exact. |
| Track list | `auto 1fr 1fr`, `240 1fr` | Quote when it contains spaces. |
| String | `"Re: Q3 planning"` | Required for spaces/reserved characters. |
| Placeholder | `${label}`, `${tone}` | Component parameter; `\${` is literal. |

Booleans default to false; optional strings are absent; numerics without a default are
required. `tone` defaults to `fg` for text/icons, `neutral` for tags/badges, `brand` for
accents.

### 3.4 Screen header and positional text

```text
screen login "Sign in" kind=dialog width=400 pad=xl gap=l
```

Positional values are `screen`, `id`, quoted `title`. Everything else is an attribute.

| Type | Positional text |
| --- | --- |
| `text`, `button`, `checkbox`, `radio`, `switch`, `badge`, `tag`, `kbd` | Visible label. |
| `icon` | Icon name. |
| `field` | Visible label. |
| `card`, `page-header`, `list-item`, `tab`, `tree-item`, `menu-item`, `banner`, `toast`, `tooltip`, `empty-state` | Title or label. |
| `table-cell` | Optional cell text; prefer children. |
| Project component | Supplies `param text` if declared; otherwise invalid. |
| Other containers/components | None. |

Missing required text is `E012`.

### 3.5 Canonical form

Two-space indent, LF, lowercase keys/enums, bare booleans only for boolean attributes,
attributes ordered positional text → `id` → alphabetical keys, one blank line between
theme/component/screens and between screens.

### 3.6 Examples

**Sign-in**

```text
gui-v2

screen sign-in "Sign in" kind=dialog width=400 pad=xl gap=l
  text "Welcome back" size=lg weight=semibold level=1
  text "Sign in to continue." size=sm tone=muted
  field "Email"
    textfield input=email placeholder="you@example.com" required
  field "Password"
    textfield input=password required
  button "Sign in" variant=primary action=sign-in
  text "Forgot password?" size=sm tone=brand action=forgot-password
```

**Project component and list-detail**

```text
gui-v2

component status-line
  param label
  param tone=muted
  row gap=s align=center
    icon "check-circle" size=sm tone=${tone}
    text "${label}" size=sm tone=${tone}

screen tickets "Tickets" layout=grid cols="280 1fr" gap=m pad=l
  list navigation=true
    list-item "Atlas" icon=palette selected action=open-atlas
    list-item "Orbit" icon=smartphone action=open-orbit
  card "Atlas"
    status-line label="All systems operational" tone=success
    field "Name"
      textfield value="Northstar"
```

### 3.7 Screen documents and shared libraries

A **screen document** is a Markdown file with one primary fenced `gui-v2` block plus prose.
The block format is unchanged; the surrounding document is defined in
[`screen-workflow.md`](screen-workflow.md).

- One primary block with one primary `screen`; dialogs, drawers, sheets and variants get
  their own document.
- The block must validate after composition with shared theme/components.
- Shared theme file: only a `theme` block. Shared component file: only `component`
  declarations and comments.
- Composition order: `gui-v2`, shared theme, shared components, inline components, screen.
  The composer emits `gui-v2` once and strips it from the screen block.
- Front matter/prose do not affect rendering. Data bindings are a workflow/prototype
  convention and do not change the block.

---

## 4. Tokens and themes

### 4.1 Theme block and resolution

```text
theme
  font-family="Inter, system-ui, sans-serif"
  font-size=16
  space=8
  light.bg="#FFFFFF"
  light.surface="#F6F7F9"
  light.fg="#111827"
  light.brand="#2563EB"
  dark.bg="#0B0F14"
  dark.surface="#151A21"
  dark.fg="#F3F4F6"
  dark.brand="#60A5FA"
```

Unspecified tokens keep defaults. Colors are `light.<token>`/`dark.<token>`; nodes use them
without prefix. Unknown keys are `E003`. Any base token can be overridden.

Resolution: explicit attribute → resolved mode → component default → global default.

A **mode** is `light`/`dark`. A **theme** is a named set of overrides, normally colors. The
standard theme is the baseline; project themes override semantic tokens unless a documented
reason changes core scales. Themes are selected at application level; a document `theme`
block is an override. Theme names are stable and versioned.

**Density:** comfortable is the baseline. Compact is a project theme override for dense
desktop screens; do not mix densities in one view. Touch platforms keep 44×44 targets.

### 4.2 Typography

| Token | Default | Notes |
| --- | --- | --- |
| `font-family` | `Inter, system-ui, sans-serif` | UI text. |
| `font-mono` | `ui-monospace, SFMono-Regular, Menlo, monospace` | Code, keys. |
| `font-size` | `16` | Base. |
| `font-size-sm` | `13` | `0.8125 × font-size`. |
| `font-size-lg` | `20` | `1.25 × font-size`. |
| `line-sm` | `18` | Small line height. |
| `line-md` | `24` | Normal line height. |
| `line-lg` | `28` | Large line height. |
| `weight-regular` | `400` | Body. |
| `weight-medium` | `500` | Labels, buttons. |
| `weight-semibold` | `600` | Headings. |
| `weight-bold` | `700` | Emphasis, metrics. |

If `font-size` changes, re-derive small/large unless overridden.

### 4.3 Spacing

| Token | Formula | At `space=8` | Use |
| --- | --- | --- | --- |
| `none` | `0` | `0` | None. |
| `xs` | `0.5 × space` | `4` | Tight label/value, icon gaps. |
| `s` | `1 × space` | `8` | Inline gaps, control padding. |
| `m` | `2 × space` | `16` | Stack gaps, card padding. |
| `l` | `3 × space` | `24` | Section gaps, screen padding. |
| `xl` | `4 × space` | `32` | Page gutters, large sections. |

`space` defaults to `8`; `space=10` yields `5/10/20/30/40`.

- Only these tokens for `pad`, `gap`, `col-gap`, `row-gap`, `inset`, `item-gap`; numeric
  spacing is `E010`.
- No `margin`. Siblings use `gap`; inside a box use `pad`; flexible space uses `spacer`.
- Width, height, control heights, border widths, icon sizes and radii are numeric.
- Group with spacing before adding borders/dividers; do not mix gaps in one repeated group.

### 4.4 Color

Three base neutrals per mode:

| Token | Light | Dark | Use |
| --- | --- | --- | --- |
| `bg` | `#FFFFFF` | `#0B0F14` | Canvas. |
| `surface` | `#F6F7F9` | `#151A21` | Cards, inputs, panels. |
| `fg` | `#111827` | `#F3F4F6` | Primary text/icons. |

Derived neutrals:

| Token | Recipe | Use |
| --- | --- | --- |
| `muted` | `fg` 64% | Secondary text; never essential. |
| `border` | `fg` 12% | 1 px borders/dividers. |
| `hover` | `fg` 6% light / 8% dark | Pointer hover. |
| `pressed` | `fg` 10% light / 12% dark | Pressed. |
| `scrim` | `#000000` 60% | Modal backdrop. |
| `focus` | `brand` | Focus ring. |

Brand:

| Token | Light | Dark | Use |
| --- | --- | --- | --- |
| `brand` | `#2563EB` | `#60A5FA` | Primary actions, links, selection. |
| `brand-on` | `#FFFFFF` | `#0B1220` | Text/icons on brand. |
| `brand-soft` | brand 12% over surface | Same | Selected rows, soft brand. |

Semantic tones: `info` (blue), `success` (green), `warning` (orange), `alert` (yellow),
`error` (red). Each has base, `-soft`, `-on`, `-contrast`.

**Light**

| Base | Soft | On | Contrast |
| --- | --- | --- | --- |
| `info` `#2563EB` | `#EFF8FF` | `#175CD3` | `#FFFFFF` |
| `success` `#15803D` | `#ECFDF3` | `#067647` | `#FFFFFF` |
| `warning` `#C2410C` | `#FFF4ED` | `#B93815` | `#FFFFFF` |
| `alert` `#CA8A04` | `#FEFCE8` | `#854D0E` | `#422006` |
| `error` `#DC2626` | `#FEF3F2` | `#B42318` | `#FFFFFF` |

**Dark**

| Base | Soft | On | Contrast |
| --- | --- | --- | --- |
| `info` `#60A5FA` | `#102A43` | `#84CAFF` | `#0B1220` |
| `success` `#32D583` | `#0C2E22` | `#6CE9A6` | `#0B1220` |
| `warning` `#F79009` | `#2E1A0B` | `#FDB022` | `#0B1220` |
| `alert` `#FDB022` | `#2E2408` | `#FEC84B` | `#0B1220` |
| `error` `#F97066` | `#3A1414` | `#FDA29B` | `#0B1220` |

Badge fills:

| Token | Light | Dark |
| --- | --- | --- |
| `badge-blue` | `#2563EB` | `#84CAFF` |
| `badge-purple` | `#6941C6` | `#B692F6` |
| `badge-pink` | `#C11574` | `#F670C7` |
| `badge-teal` | `#0F766E` | `#5FE9D0` |
| `badge-indigo` | `#444CE7` | `#A4BCFD` |
| `badge-cyan` | `#0E7090` | `#67E3F9` |
| `badge-lime` | `#4D7C0F` | `#B3F26B` |
| `badge-gray` | `#475467` | `#98A2B3` |
| `badge-on` | `#FFFFFF` | `#0B1220` |

`tone` accepts `bg`, `surface`, `fg`, `muted`, `brand`, `neutral`, the five semantic tones
and `badge-*`. Resolution:

| `tone` | Text/icons | Soft fill | Solid fill | On solid |
| --- | --- | --- | --- | --- |
| `bg` | `bg` | `bg` | `bg` | `fg` |
| `surface` | `surface` | `surface` | `surface` | `fg` |
| `fg` | `fg` | `surface` | `fg` | `bg` |
| `muted` | `muted` | `surface` | `muted` | `bg` |
| `brand` | `brand` | `brand-soft` | `brand` | `brand-on` |
| `neutral` | `fg` | `surface` | `badge-gray` | `badge-on` |
| semantic | `<tone>-on` | `<tone>-soft` | `<tone>` | `<tone>-contrast` |
| `badge-*` | `badge-*` | `badge-*` 12% | `badge-*` | `badge-on` |

Color rules:

- Never rely on color alone; pair with text, icon or shape.
- Use `-on` on soft backgrounds and `-contrast` on solid tones; `badge-on` on badges.
- Alpha blends are limited to these recipes.
- A mode change without `bg` inherits the painted background.
- Project brand colors replace `brand`, not individual component colors.
- Hex is allowed for one-off data; component styling uses tokens.

### 4.5 Radii, controls, elevation and motion

| Token | Default | Use |
| --- | --- | --- |
| `radius-sm` | `space-xs` (`4`) | Keycaps, checkboxes, dense inputs. |
| `radius-md` | `space-s` (`8`) | Buttons, inputs, menus. |
| `radius-lg` | `space-m` (`16`) | Cards, dialogs, sheets, frames. |
| `radius-pill` | `999` | Tags, badges, switches. |
| `control-height-sm` | `32` | Small control. |
| `control-height` | `40` | Normal control. |
| `control-height-lg` | `48` | Large control. |
| `border-width` | `1` | Default border. |
| `focus-width` | `2` | Focus ring width. |
| `focus-offset` | `2` | Focus ring offset. |
| `touch-min` | `44` | Minimum touch target. |
| `disabled-opacity` | `0.5` | Disabled subtree. |
| `icon-size-sm` | `16` | Small icon. |
| `icon-size` | `20` | Default icon. |
| `icon-size-lg` | `24` | Large icon. |
| `motion-fast` | `120ms` | Hover, press, focus. |
| `motion-normal` | `200ms` | Menus, popovers, dialogs. |
| `motion-slow` | `320ms` | Sheets, larger transitions. |
| `motion-easing` | `cubic-bezier(0.2, 0, 0, 1)` | Standard easing. |
| `shadow-sm` | `0 1px 2px rgba(16,24,40,0.08)` | Raised cards. |
| `shadow-md` | `0 4px 8px -2px rgba(16,24,40,0.10), 0 2px 4px -2px rgba(16,24,40,0.06)` | Menus, popovers, tooltips. |
| `shadow-lg` | `0 12px 24px -4px rgba(16,24,40,0.14), 0 4px 8px -2px rgba(16,24,40,0.08)` | Dialogs, sheets, toasts. |
| `breakpoint-sm` | `640` | Mobile/tablet boundary. |
| `breakpoint-md` | `900` | Tablet/desktop boundary. |
| `breakpoint-lg` | `1200` | Desktop boundary. |
| `breakpoint-xl` | `1440` | Large desktop boundary. |

Shadows paint outside the box; scrollbars are overlays and never reduce the content box.

### 4.6 State precedence

`disabled` → `pressed` → `focused` → `hover` → `selected`/`checked` → default. `invalid` is
a semantic overlay combined with focus/hover.

- Disabled: `disabled-opacity`; no pointer/focus.
- Hover: `hover` overlay; pointer only.
- Pressed: `pressed` overlay.
- Focus: 2 px `focus` ring with 2 px offset; keyboard focus only unless no keyboard.
- Selected: `brand-soft` background, `brand` text/indicator.
- Reduced motion: static state instead of shimmer/rotation.

---

## 5. Layout

### 5.1 Box model and size

Each node has an outer box, content box (outer minus padding) and children placed with
`gap`. No implicit margins.

1. Explicit `width`/`height` (clamped by min/max).
2. `h=fill`/`v=fill` when size is `auto`.
3. Preferred size from content or component defaults.

Explicit size wins over fill. Percentage sizes require a definite parent; otherwise `auto`
and `W001`.

### 5.2 Intrinsic sizes

| Node | Preferred |
| --- | --- |
| `text` | Measured text × line height; wrapped uses longest word. |
| `icon` | 16/20/24 square. |
| `image` | 120×80 unless width/height/aspect decides. |
| `button` | Content + padding; min width 80; height 32/40/48. |
| `textfield`, `select` | 200×40. |
| `textarea` | 240 × (`rows × 24 + 2 × pad-y`). |
| `checkbox`, `radio` | `20 + s + label`. |
| `switch` | `44 × 24 + s + label`. |
| `slider` | 200×24. |
| `progress` | 200×8 plus value text. |
| `avatar` | `size` square (default 40). |
| `badge` | Content + padding; 24 high, min 24 wide. |
| `tag` | Content + padding; 26 high. |
| `spinner` | `size` square. |
| `skeleton` | Line fill×12; circle `size`; rect 120×80. |
| `kbd` | Content + padding; 22 high. |
| Containers | Content + padding + gaps. |
| Extended/project | Intrinsic size of expansion. |

### 5.3 Row and column

`row` is horizontal; `column` is vertical.

1. Compute content box and base main sizes.
2. `total = sum(base) + gap × (n − 1)`.
3. If free > 0, distribute by `grow`, else by `justify`.
4. If free < 0, shrink auto children to minimum; explicit sizes stay. Overflow clips or
   scrolls.
5. Place tracks from the content-box start.
6. Cross axis: apply `h`/`v`; main axis: apply `v` for rows and `h` for columns when a track
   grew.

### 5.4 Alignment and wrapping

| Attribute | Applies to | Default | Description |
| --- | --- | --- | --- |
| `gap` | row, column, grid | `m` | Space between children/tracks. |
| `justify` | row, column | `start` | `start`, `center`, `end`, `between`, `around`, `evenly`. |
| `align` | row, column | `stretch` | `start`, `center`, `end`, `stretch`. |
| `wrap` | row | `false` | Flow onto new lines. |
| `col-gap` | row, column | `gap` | Horizontal override. |
| `row-gap` | row, column | `gap` | Vertical override. |

Per-child `h` (`left/center/right/fill`) and `v` (`top/center/bottom/fill`) override
`align`. `between`: first at start, last at end. `around`: equal space both sides; single
child centered. `evenly`: equal space between and around. With `wrap=true`, children keep
preferred/explicit width, `grow` is ignored, and `justify` applies per line.

### 5.5 Grid and stack

Grid attributes: `cols` (`1fr`), `rows` (`auto`), `gap` (`m`), `col-gap`, `row-gap`,
`flow` (`row`). Tracks: `auto`, `<n>fr`, `<n>` px, `<n>%`. Size auto tracks from preferred
sizes, distribute remaining space across `fr`, place explicit items, auto-place the rest,
align, clip/scroll.

`stack` places all children in the same content box; they overlap and align with `h`/`v`
(default `fill`). Use for status dots, badges over images and indicators. Preferred size is
the largest child.

### 5.6 Overflow, text and rounding

- `scroll=none` clips; `y`/`x`/`both` scroll. `list`/`tree` scroll vertically when
  constrained.
- Scrollbars are overlays. Safe-area insets are outside the content box when `safe=true`;
  tests use zero.
- Single-line text truncates with `…`; `wrap=true` wraps at spaces; `max-lines=n` truncates
  the last line.
- `align=left|center|right`; single-line is vertically centered, multi-line top-aligned.
- List item titles/descriptions are single-line with ellipsis.
- All layout math quantizes to 1/64 px; paint-time snapping never feeds back into layout.

### 5.7 Responsive

| Range | Columns | Gutter | Margin | Behavior |
| --- | --- | --- | --- | --- |
| `sm` (<640) | 4 | `l` | `l` | One column, drawer nav, stacked actions, cards over wide tables. |
| `md` (640–899) | 8 | `l` | `l` | Two-column forms or list-detail when space allows. |
| `lg` (900–1199) | 12 | `l` | `xl` | Persistent nav, multi-column grids. |
| `xl` (1200+) | 12 | `l` | `xl` | Constrained reading width, full layouts. |

Reflow/relocate before hiding. Use `visible-at`/`hide-at` only for secondary content. No
nested scroll areas. Tables scroll horizontally only when necessary; prefer column priority
or cards. Numbers right-aligned, text left-aligned.

---

## 6. Components

### 6.1 Common attributes

| Attribute | Type | Default | Notes |
| --- | --- | --- | --- |
| `id` | identifier | — | Unique after expansion. |
| `mode` | `light`/`dark` | inherited | Subtree mode. |
| `width`, `height` | `auto`/number/percent | `auto` | Explicit size. |
| `min-*`, `max-*` | number/percent | `0`/none | Clamps. |
| `grow` | number ≥ 0 | `0` | Main-axis weight. |
| `h` | `left/center/right/fill` | class default | Horizontal placement. |
| `v` | `top/center/bottom/fill` | class default | Vertical placement. |
| `pad`, `pad-x`, `pad-y` | spacing token | `none` | Inner padding. |
| `bg` | color | component default | Background. |
| `border` | bool/number | `false` | 1 when true. |
| `border-color` | color | `border` | |
| `radius` | number/`sm`/`md`/`lg`/`pill`/`none` | component default | |
| `shadow` | `none`/`sm`/`md`/`lg` | `none` | |
| `opacity` | 0–1 | `1` | Subtree opacity. |
| `visible` | bool | `true` | Not laid out when false. |
| `visible-at`, `hide-at` | breakpoint list | all/none | Responsive visibility. |
| `action` | identifier | — | Emitted on activation. |
| `tooltip` | string | — | Hover/focus help. |
| `tooltip-placement` | `top/right/bottom/left` | `top` | |
| `scroll` | `none/y/x/both` | `none` | Containers. |
| `col`, `row`, `col-span`, `row-span` | integer | auto/1 | Grid children. |

No `margin`. `slot` is only for direct children of a project component instance. `x-`
attributes are preserved and ignored.

### 6.2 Primitives

Primitives are the only nodes with built-in visual styling. They are leaves.

| Primitive | Content and key attributes | Typography | Colors | Insets/border | Size |
| --- | --- | --- | --- | --- | --- |
| `text` | Text; `size=sm/md/lg` (`md`), `weight`, `tone` (`fg`), `align`, `wrap=false`, `max-lines`, `level=1…6`, `action` | `font-size-*`, line, weight | `tone`; action is `brand` link | None | Content |
| `icon` | Name; `size=sm/md/lg` (`md`), `tone`, `label`, `action` | — | `tone` | None | 16/20/24 |
| `image` | `src`, `alt`; `fit=cover/contain`, `aspect=free/1:1/4:3/3:2/16:9/21:9`, `radius` | — | `surface` placeholder + `muted` icon | `radius` only | 120×80 or aspect |
| `divider` | `orientation`, `thickness=1`, `color=border`, `inset` | — | `color` | Inset spacing | 1 px |
| `spacer` | `grow=1`, optional width/height | — | Transparent | None | 0×0 |
| `button` | Text or `icon`; `variant=primary/secondary/ghost/danger`, `size=sm/md/lg`, `tone`, `icon`, `icon-right`, `disabled`, `action`, `label` | sm: sm/medium; md/lg: md/medium | Variant table | Height 32/40/48; pad-x `s/m/l`; radius `md` | Min 80 |
| `textfield` | `value`, `placeholder`, `input=text/email/password/number/search/url/tel/date/time`, `label`, `icon`, `icon-right`, `required`, `invalid`, `disabled`, `readonly`, `max-length` | md/regular | `bg`, `fg`, placeholder `muted`, border `border`, invalid `error` | 40 high; pad-x `m`; radius `md`; 1 px | 200×40 |
| `textarea` | `value`, `placeholder`, `rows=3`, `label`, `icon`, `icon-right`, `required`, `invalid`, `disabled`, `max-length` | md/regular | Same as textfield | `rows×24+2×pad-y`; pad-x `m`, pad-y `s`; radius `md` | 240 wide |
| `select` | `value`, `options` (pipe-separated `Label=value`), `placeholder`, `label`, `icon-right=chevron-down`, `required`, `invalid`, `disabled` | md/regular | Same as textfield | Same as textfield | 200×40 |
| `checkbox` | Label; `checked`, `disabled`, `tone=brand` | md/regular | `tone` checked; `border` unchecked | 20 box; radius `sm`; 1 px; gap `s` | Content |
| `radio` | Label; `value`, `checked`, `disabled`, `tone=brand` | md/regular | `tone` dot; `border` | 20 circle; 1 px; gap `s` | Content |
| `switch` | Label; `checked`, `disabled`, `tone=brand` | md/regular | `tone` on; `surface`/`border` off | 44×24 track; pill; 20 thumb; gap `s` | Content |
| `slider` | `value`, `min=0`, `max=100`, `step=1/any`, `label`, `show-value`, `disabled`, `tone=brand` | sm/regular | `tone` fill; `surface` track | 4 px track; 20 thumb; 24 high | 200×24 |
| `progress` | `value=0…100`, `tone=brand`, `indeterminate`, `show-value`, `label` | sm/regular | `tone` fill; `surface` track | 8 px track; pill | 200×8 |
| `avatar` | `src`, `initials`, `alt`, `size=40`, `shape=circle/rounded`, `status=online/away/busy/offline`, `tone=brand` | md/medium | `tone-soft`; `tone` initials | Circle/`md`; 10 px status dot with 2 px ring | 40×40 |
| `badge` | Text; `tone=neutral` | sm/semibold | Solid tone; contrast text | 24 high; pad-x `s`; pill | Min 24 |
| `tag` | Text; `tone=neutral`, `icon` | sm/medium | Soft tone; tone-on text; tone 30% border | 26 high; pad-x `s`; pill; 1 px | Content |
| `spinner` | `size=20`, `tone=brand`, `label="Loading"` | — | `tone` arc | None | 20×20 |
| `skeleton` | `shape=line/circle/rect`, `lines`, `animated`, `label` | — | `surface` | `radius-sm` | Line 12; circle size; rect 120×80 |
| `kbd` | Text; `size=sm/md` | sm/regular mono | `surface`; `fg`; `border` | 22 high; pad-x `xs`; radius `sm`; 1 px | Content |

Primitive rules:

- `text level=1…6` adds heading semantics; default sizes/weights: 1–2 lg/bold, 3–4
  md/semibold, 5–6 sm/semibold. `action` makes it a link.
- Button default `primary`/`md`; icon-only requires `label`; `tone` overrides primary/ghost
  accent; `danger` always `error`.
- Inputs: invalid uses `error` border/`aria-invalid`; required exposes semantics; icons are
  20 px `muted` with `s` gap; leading/trailing icon adds `s+20+s` inset. Password includes
  reveal; date/time include picker action.
- Select options are `Label=value` pipe-separated; no `|` or `=` inside labels/values.
- Checkbox/radio/switch use `tone`; labels are in the hit area; touch targets expand to 44.
- Badge: neutral→`badge-gray`/`badge-on`; semantic→`tone`/`tone-contrast`; palette→
  `badge-*`/`badge-on`; brand→`brand`/`brand-on`.
- Tag: neutral→`surface`/`fg`/`border`; brand→`brand-soft`/`brand`/30% border; semantic→
  `tone-soft`/`tone-on`/30% border; palette→badge 12%/badge text/30% border.
- Images require `alt`; failure shows `surface` + `muted` image icon. Avatars fall back to
  initials then `alt`; status dots use success/alert/error/muted. Skeletons are hidden from
  assistive technology unless labelled.

Button variants:

| Variant | Background | Text | Border |
| --- | --- | --- | --- |
| `primary` | `brand` | `brand-on` | none |
| `secondary` | `surface` | `fg` | 1 px `border` |
| `ghost` | transparent | `brand` | none |
| `danger` | `error` | `error-contrast` | none |

### 6.3 Built-in extended components

Extended components are macros over primitives/containers. Structure and styling are
normative; native implementations must match boxes, roles, states and paint order. Common
attributes may override the outer box; internal structure is fixed. If a screen needs a
different internal structure, compose primitives directly.

| Component | Use when | Key attributes | Structure and styling |
| --- | --- | --- | --- |
| `field` | Label + control + hint/error | `for`, `hint`, `error`, `required` | column gap `xs`: label (sm/medium), one control, hint (sm/`muted`) or error (sm/`error`). Error replaces hint and marks invalid. No bg/border/pad. |
| `card` | Group related content | `description`, `raised` | column: optional title/description, children. `surface`, 1 px border, `radius-lg`, pad `l`, gap `m`; `raised` uses `shadow-sm` instead of border. |
| `page-header` | Page title + actions | `description` | row `between`/`center` gap `m`: title/description column + action row gap `s`. |
| `list` / `list-item` | Homogeneous collection | list `navigation`, `divider`, `empty`; item `description`, `icon`, `icon-tone`, `avatar`, `badge`, `badge-tone`, `selected`, `disabled`, `action` | list: column, scroll `y`, dividers. Item: row min 56, pad-x `m`, pad-y `s`, gap `m`; leading icon/avatar, title/description, trailing badge/icon. Selected `brand-soft`; hover overlay; single-line ellipsis. |
| `table` / `table-head` / `table-row` / `table-cell` | Comparison | `cols`, `caption`, `empty`, `selectable`, `sortable`, `sort`, `dense`, `striped`; row `selected`, `disabled`; cell `align` | column: header + rows. 1 px border, `radius-lg`, scroll `x`; header `surface`, sm/medium `muted`; rows 48 (40 dense), pad-x `m`, pad-y `s`, bottom border; numbers right; selected `brand-soft`. |
| `tabs` / `tab` | Peer views | `active`, `variant=underline/pills`, `equal`, `scrollable`; tab `id`, `icon`, `badge`, `disabled` | column gap `m`: tab bar (48 underline/40 pills) + active panel. Active `brand`/indicator or `brand-soft`; inactive `muted`; only active painted. |
| `banner` | Persistent page status | `tone`, `title`, `icon`, `variant=soft/solid`, `dismissible` | row: icon + content column + optional close. Soft: `tone-soft`, 1 px tone border, `radius-lg`, pad `l`, gap `s`; solid: tone/`tone-contrast`, no border. |
| `toast` | Transient status | `tone`, `title`, `placement`, `duration=4000`, `dismissible` | Same as banner, `shadow-lg`, max 420. Stacks, pauses on hover/focus, never steals focus. |
| `menu` / `menu-item` | Contextual actions | menu `open`, `anchor`, `placement`; item `icon`, `shortcut`, `tone`, `selected`, `disabled` | menu: `surface`, border, `radius-lg`, `shadow-md`, pad `xs`, min 180. Item: row 40, pad-x `m`, pad-y `s`, gap `s`, `radius-sm`; selected `brand-soft`; danger `error-on`. |
| `breadcrumbs` | Location | `separator="/"` | row gap `xs`: sm `brand` links + sm `muted` separators; last current `muted`; navigation landmark. |
| `pagination` | Large collection | `page`, `pages`, `siblings`, `disabled`, `label` | row gap `xs`: 32 px buttons, `radius-sm`; active `brand-soft`/`brand`; prev/next. |
| `action-bar` | View actions | `placement`, `equal`, `align`, `separator`, `safe` | row `surface`, top border, pad-x `l`, pad-y `m`, gap `s`; `equal` shares width; children buttons. |
| `empty-state` | No content | `description`, `icon` | column centered gap `m`, pad `xl`: icon lg `muted`, title md/semibold, description sm/`muted`, action. |
| `metric` | Single KPI | `label`, `value`, `change`, `tone` | `card` + column gap `xs`: label sm/`muted`, value lg/`bold`, change sm/tone. |
| `radio-group` | One of a small set | `label`, `value`, `orientation`, `disabled` | column/row gap `s`: optional label + `radio` children; group `value` selects. |
| `tree` / `tree-item` | Hierarchy | tree `selection`, `label`; item `expanded`, `selected`, `disabled`, `icon`, `badge` | tree: column, scroll `y`. Item: row 40, pad-x `m`, pad-y `s`, gap `s`, indent `l`; chevron/icon/label/badge; selected `brand-soft`. |
| `tooltip` | Short description | `for`/`anchor`, `placement`, `open`, `delay=300` | text box: `fg` bg, `bg` text, `radius-sm`, pad-x `s`, pad-y `xs`, `shadow-md`, max 240; not focusable. |
| `popover` | Contextual content | `anchor`, `placement`, `open`, `dismissible`, `modal` | column: `surface`, border, `radius-lg`, `shadow-md`, pad `m`, gap `s`, min 180; modal adds scrim/focus trap. |

Key rules:

- `field` has exactly one control child. `list-item` uses `icon` or `avatar`, not both.
- `table selectable` prepends a 40 px checkbox column; `sortable` headers expose `aria-sort`;
  sorting is runtime state.
- `tabs` active defaults to the first enabled tab; only active is measured/painted.
- Banner/toast icons: info/neutral `info`, success `check-circle`, warning/alert
  `alert-triangle`, error `x-circle`.
- Menu keys: Up/Down, Enter, Escape. Tree keys: Up/Down, Right/Left, Home/End,
  Enter/Space; multiple uses Ctrl/Cmd+Space.
- `dialog`, `sheet` and `drawer` are screen kinds, not components.

### 6.4 Project components

A project can define additional extended components in the document. A definition is a
named macro with parameters, optional slots and exactly one body root.

```text
component stat-card "Stat card"
  param label
  param value
  param change
  param tone=brand
  column gap=xs
    text "${label}" size=sm tone=muted
    text "${value}" size=lg weight=bold
    text "${change}" size=sm tone=${tone}
```

Declaration:

- `component <name> ["<description>"]` starts a definition.
- `param <name>[=<default>]`; without a default it is required.
- `slot [<name>]`; `slot` alone is the default slot.
- Body is exactly one root node after declarations.
- Definitions are document-global, after the theme and before the first screen; order
  among definitions does not matter.
- Names are lowercase kebab-case and must not collide with a container, primitive,
  built-in extended component or another definition.
- Parameter/slot names are lowercase kebab-case and unique.
- Body may contain any container, primitive, built-in or project component; not `screen`,
  `theme` or `component`.

Parameters:

- Instance attributes matching a parameter supply it.
- `${name}` may appear in positional text and attribute values (`id`, `for`, `anchor`,
  `src`, `alt`, `label`, `tone`, spacing). It is not recognized in types or attribute
  names.
- Quote placeholders that may contain spaces.
- Substitution is single-pass on parsed text/values; parameter values are opaque and not
  parsed again.
- If `param text` is declared, instance positional text supplies it; otherwise positional
  text is `E041`.
- Missing parameter `E034`; unresolved placeholder `E037`; extra attribute `E007`.
- Parameters shadow common attributes of the same name; remaining instance attributes apply
  to the expanded root.

Slots:

- `slot` is default; `slot <name>` is named. At most one default; names unique.
- Direct instance children with `slot=<name>` go there; unmarked children go to the default
  slot.
- A slot placeholder appears at most once; empty slots render nothing.
- Children without a default slot, or an undeclared slot, is `E036`.
- `slot` is only valid on direct children of an instance.
- Slot content may contain any nodes, including project components.

Expansion:

1. Resolve definition and check required parameters.
2. Substitute placeholders.
3. Replace slots in document order.
4. Apply common instance attributes to the expanded root; they override the body root.
5. Expand nested components recursively.
6. Reject cycles (`E035`); assign paths and reject duplicate IDs (`E023`).

The instance `id` becomes the root id. Do not declare `id` on the body root when instances
set `id` (`E023`). Parameterize internal IDs when a component can be reused:

```text
component labeled-field
  param name
  param label
  field "${label}" for="${name}-input"
    textfield id="${name}-input"

screen profile "Profile"
  labeled-field name=email label="Email"
```

Project components create no new accessibility roles; they expose the expansion’s roles and
states. They expand before platform mapping.

Example with slots:

```text
component panel
  param title
  slot header
  slot body
  column bg=surface border radius=lg pad=l gap=m
    text "${title}" size=md weight=semibold
    slot header
    slot body

screen settings "Settings" kind=dialog width=600
  panel title="Workspace"
    text "Actions" slot=header
    column slot=body
      field "Name"
        textfield id=name
```

### 6.5 Icons and imagery

One vector icon set, consistent style, 24 px grid, kebab-case names, sizes 16/20/24. Icons
inherit text color; icon-only controls need an accessible name. Common names:
`chevron-*`, `arrow-*`, `home`, `menu`, `close`, `search`, `filter`, `plus`, `minus`, `check`,
`edit`, `trash`, `download`, `upload`, `more-horizontal`, `info`, `check-circle`,
`alert-triangle`, `x-circle`, `mail`, `settings`, `palette`, `smartphone`, `calendar`,
`image`, `user`, `eye`, `eye-off`, `sort-asc`, `sort-desc`, `expand`, `collapse`.

Images require `alt`; use `""` for decorative. Prefer `fit=cover` with a declared aspect;
use `contain` for diagrams/logos. On failure show the neutral placeholder. Prefer real
content or simple geometric illustrations over stock imagery.

---

## 7. Patterns

| Pattern | Use | Key rules |
| --- | --- | --- |
| App shell | Persistent navigation + content | Stable labels; active state uses `brand`; desktop sidebar/rail, mobile drawer/menu. |
| List-detail | Navigation list + detail | `grid cols="280 1fr"`; on `sm`, list hides and detail opens as a screen with back; no nested scroll. |
| Forms | Data entry | Single column; `field` per input; one primary action; validate on blur/submit; keep input on error; focus first invalid. |
| Search/filter/sort | Large collections | Search above; filters in row/panel; sort in headers; active filters as removable tags; show count and recoverable empty state. |
| Tables | Comparison | Header/caption/empty state; numbers right; row actions trailing; explicit selection/sort; cards or column priority on small screens. |
| Dashboard | Metrics + activity | Metric cards, activity list, action bar; every metric has label/value/comparison; do not mix unrelated chart types. |
| Auth | Sign-in/up/recovery | Narrow form; one primary action; recovery/create links; errors do not reveal account existence; support password managers/paste. |
| Settings | Preferences | Group by task; fields/sections; sticky/footer save; distinguish immediate switches from save-required forms; warn on unsaved changes. |
| Onboarding | First value | Short sequence/checklist, not marketing carousel; progress; skip; do not block the product. |
| Empty/loading/error | Every view | Empty: why + next action; loading: skeleton/spinner; error: banner + recovery; keep partial content. |
| Destructive confirmation | Irreversible actions | State object/consequence; danger; safe cancel; dialog for decisions, toast for completion. |
| Notifications | Feedback | Toast for non-blocking; banner for persistent; dialog for decisions; inline field errors; no duplicate messages. |
| Responsive | All screens | Reflow/relocate before hiding; keep essential actions; 44×44 touch; no nested scroll. |

One primary action per view. Use `action-bar` for view-level actions, not duplicates. Never
put essential information only in a tooltip, popover or hover state.

---

## 8. Content

- **Voice:** clear, calm, direct, human. Plain verbs, short sentences, specific next steps.
  No blame, jargon, humor in errors or exclamation marks.
- **Terminology:** one term per concept across navigation, labels, help and errors.
- **Capitalization:** sentence case for labels, headings, buttons, menu items and tabs. No
  terminal punctuation in short labels. Full sentences for help/empty/error text. Use `…`
  for truncation and “More…” actions, not `...`.
- **Labels/help:** every input has a visible label; placeholders are examples, not labels.
  Help explains format/constraints before errors. Mark required, not optional. Start actions
  with a verb.
- **Errors:** what went wrong + why (if useful) + what to do next. “Enter a date in the
  future.” not “Invalid input.” Keep the message at the field; use a summary for multiple
  errors. No stack traces or internal codes.
- **Dates/numbers:** `YYYY-MM-DD` and `HH:MM` in values; display in locale. Locale grouping
  and decimal separators. Right-align numeric columns. Currency uses ISO code or locale
  symbol consistently.
- **Internationalization:** no concatenated sentences or text baked into images; allow
  30–40% expansion. `gui-v2` is LTR-only; RTL is a documented project extension.

---

## 9. Accessibility

Target **WCAG 2.2 AA**; accessibility is a release gate.

### 9.1 Contrast and focus

- Normal text 4.5:1; large text and UI graphics 3:1.
- Focus indicators 3:1 against adjacent colors and visible in both modes.
- Meaningful borders (inputs, selection) meet 3:1.
- Recompute contrast when tokens/themes change; baseline tokens are chosen to pass.

### 9.2 Keyboard

Every interactive element is reachable in tree order with a visible focus ring. Keyboard
focus only unless the platform has no keyboard. Overlays trap focus while modal and return
focus to the opener. No positive tabindex.

Keys: buttons/links Enter/Space; tabs arrows/Home/End; menus Up/Down/Enter/Escape; radios
arrows/Space; dialogs Escape + trap; popovers Escape/outside click; tooltips Escape; trees
Up/Down/Left/Right/Home/End/Enter/Space; sortable headers Enter/Space.

### 9.3 Semantics

| Component | Role | States |
| --- | --- | --- |
| `text level` | heading | level |
| inputs | textbox/combobox/checkbox/radio/switch/slider | name, value, required, invalid, disabled |
| `button` | button | name, disabled |
| `tag`, `badge` | status/text | text; never color alone |
| `tabs`/`tab` | tablist/tab/tabpanel | selected, controls |
| `menu`/`menu-item` | menu/menuitem | expanded, disabled, selected |
| `table` | table/row/columnheader/cell | caption, selection, sort |
| `radio-group` | radiogroup/radio | name, checked, disabled |
| `dialog`/`drawer`/`sheet` | dialog | name, modal, focus trap |
| `banner`/`toast` | status/alert | live region |
| `pagination`/`breadcrumbs` | navigation | current page/item |
| `spinner` | status | label |
| `skeleton` | hidden unless labelled | — |
| `tooltip` | tooltip via `aria-describedby` | text |
| `popover` | dialog when modal, else region | name, expanded, focus |
| `tree`/`tree-item` | tree/treeitem | expanded, selected, level |
| `list`/`list-item` | list/listitem | selected, disabled |
| `card`/`field`/`page-header` | group/region | label when titled |

Expose required, invalid, disabled, expanded, selected and sort states. Dynamic messages use
`role=status` or `role=alert`. Decorative images/icons/skeletons are hidden. Extended and
project components expose the expansion’s roles/states; they are not roles themselves.

### 9.4 Motion, touch and zoom

Honor reduced motion; replace shimmer/rotation/large movement with static states. Touch
targets at least 44×44; small controls get an invisible hit area. Support 200% zoom and
320 CSS px reflow. Do not disable selection/paste. Do not rely on hover for essential
information.

### 9.5 Testing

Automated: contrast, names, roles, focus order, tokens. Manual: keyboard-only,
screen-reader per platform, reduced motion, 200% zoom. Component tests cover default, hover,
focus, pressed, selected, disabled and error. Accessibility regressions block release;
exceptions need an owner.

---

## 10. Platforms

Use tokens for all painting. Do not rely on platform default padding, fonts or chrome.
Custom drawing is allowed. Project components expand before mapping; they do not imply a
native widget.

| Component | Web | Swing | Android | iOS |
| --- | --- | --- | --- | --- |
| `text` | `span`/heading | `JLabel`/custom | `TextView` | `UILabel` |
| `icon`/`image` | inline SVG/`img` | `Icon`/custom | `ImageView` | `UIImageView` |
| `button` | `button` | `JButton`/custom | `Button` | `UIButton` |
| `textfield`/`textarea` | `input`/`textarea` | `JTextField`/`JTextArea` | `EditText` | `UITextField`/`UITextView` |
| `select` | `select`/custom | `JComboBox` | `Spinner`/menu | `UIButton` + menu |
| `checkbox`/`radio`/`switch` | inputs/styled | `JCheckBox`/`JRadioButton`/`JToggleButton` | `CheckBox`/`RadioButton`/`Switch` | custom/`UISwitch` |
| `slider`/`progress` | range/progress | `JSlider`/`JProgressBar` | `Slider`/`ProgressBar` | `UISlider`/`UIProgressView` |
| `avatar`/`badge`/`tag` | styled spans | custom `JLabel` | `TextView`/`ImageView` | `UILabel`/`UIImageView` |
| `list`/`table` | `ul`/`table`/custom | `JList`/`JTable` | `RecyclerView` | `UITableView` |
| `tabs`/`menu`/`tree` | ARIA + custom | `JTabbedPane`/`JPopupMenu`/`JTree` | `TabLayout`/`PopupMenu`/custom | custom/`UIMenu`/`UICollectionView` |
| `banner`/`toast`/`tooltip`/`popover` | live region/popover API | `JWindow`/`JToolTip`/`JPopupMenu` | `Snackbar`/`PopupWindow` | custom/`UIPopoverPresentationController` |
| `card`/`field`/`page-header` | `div`/`section` | `JPanel` | custom `View` | `UIView` |
| `spinner`/`skeleton`/`kbd`/`divider`/`spacer` | CSS/SVG/`kbd`/`hr`/flex | custom paint/`JLabel`/`JSeparator`/`Box` | `ProgressBar`/custom/`TextView`/`Divider`/`Space` | `UIActivityIndicatorView`/custom/`UILabel`/`UIView`/`UIView` |

Platform requirements:

- **Web:** semantic elements/ARIA; CSS variables; `:focus-visible`; reduced motion; overlay
  scrollbars; URL/query state.
- **Swing:** custom painting for tags/badges/cards; `UIManager`/tokens; `AccessibleContext`;
  key bindings; overlay scrollbars; logical pixels; host window/menu behavior.
- **Android:** `contentDescription`/roles; 44 dp touch; window insets; `RecyclerView`; theme
  attributes.
- **iOS:** `accessibilityLabel`/traits; safe-area guides; `UITableView`/
  `UICollectionView`; explicit `size` for dynamic type; reduced-motion APIs.

Text measurement: Web Canvas 2D; Swing `FontMetrics` with fractional metrics off; Android
`Paint.measureText`/`StaticLayout`; iOS TextKit/`NSString`. Production metrics may differ per
platform but must be stable for a platform/font/locale. Tests use reference measurement
(§12.4).

**Prototype note:** the HTML prototype in `screen-workflow.md` is the shared web/behavior
review artifact. Native desktop/mobile fidelity needs a native renderer or screenshots; do
not treat HTML pixels as native acceptance.

---

# Part II — Reference

## 11. Validation and error codes

Errors are ordered by line/column/path, then code:

```json
{ "code": "E012", "severity": "error", "line": 42, "path": "root/1/0", "message": "text is required" }
```

| Code | Condition |
| --- | --- |
| `E001` | Missing/invalid `gui-v2` |
| `E002` | Tabs or indentation not a multiple of two spaces |
| `E003` | Unknown theme key |
| `E004` | Duplicate screen id |
| `E005` | Unknown node type |
| `E006` | Leaf component has children |
| `E007` | Unknown attribute (unless `x-`) |
| `E008` | Invalid enum |
| `E009` | Invalid numeric range |
| `E010` | Non-token spacing value |
| `E011` | Invalid color token/hex |
| `E012` | Required text missing |
| `E013` | Button has neither text nor icon |
| `E014` | `list-item` has both `icon` and `avatar` |
| `E015` | `tabs` has no `tab`, or a non-`tab` child |
| `E016` | Duplicate tab id or `active` not enabled |
| `E017` | `action-bar` child is not a button |
| `E018` | Table structure/cell count invalid |
| `E019` | Table `sort` column/direction invalid |
| `E020` | `field` has no control child, or more than one |
| `E021` | `radio-group` child not radio, or `value` unresolved |
| `E022` | Menu child not `menu-item`/`divider` |
| `E023` | Duplicate id after expansion |
| `E024` | `for`/`anchor` target unresolved |
| `E025` | Tree structure invalid |
| `E026` | Toast duration negative/placement invalid |
| `E027` | Invalid `visible-at`/`hide-at` |
| `E028` | `wrap=true` outside `row` |
| `E029` | `text.level` outside 1–6 |
| `E030` | `image` missing `src`/`alt`, or `avatar` missing all of `src`, `initials`, `alt` |
| `E031` | `list` child not `list-item`/`divider` |
| `E032` | Duplicate/reserved component name |
| `E033` | Unknown project component |
| `E034` | Missing required component parameter |
| `E035` | Component reference cycle |
| `E036` | Invalid slot usage |
| `E037` | Unresolved `${...}` placeholder |
| `E038` | Duplicate/invalid parameter or slot name |
| `E039` | Component body not exactly one root |
| `E040` | Component declaration after first screen or not top-level |
| `E041` | Positional text on project component without `param text` |
| `W001` | Percentage resolved as `auto` (indefinite parent) |
| `W002` | Unsupported component on target platform |
| `W003` | Text truncated/clipped |
| `W004` | Non-default font fallback |

Unknown `x-` attributes are preserved. Renderers must not silently repair errors.

---

## 12. AST, normalization and testing

### 12.1 Canonical AST

```json
{
  "version": 2,
  "theme": {},
  "components": [],
  "screens": [
    {
      "id": "login",
      "title": "Sign in",
      "kind": "dialog",
      "layout": "column",
      "attrs": { "width": "400", "pad": "xl", "gap": "l" },
      "path": "login",
      "children": [
        {
          "type": "text",
          "text": "Welcome back",
          "attrs": { "size": "lg", "weight": "semibold", "level": "1" },
          "path": "login/0",
          "children": []
        }
      ]
    }
  ]
}
```

`text` is `null` when absent. Raw `attrs` are explicit; normalized AST applies defaults and
resolves booleans/aliases. Raw AST has a `components` array with name/title/params/slots/body.
After expansion, project nodes disappear from screen trees; definitions may remain for
tooling. Paths are structural, not `id`-based. Canonical JSON: sorted keys, two-space
indent, UTF-8, trailing newline.

### 12.2 Normalization

1. Register definitions; reject duplicate/reserved/cyclic names.
2. Apply defaults; convert bare booleans.
3. Resolve spacing, radius and color tokens.
4. Expand built-in and project components, substituting params/slots.
5. Reject duplicate IDs; assign paths.
6. Clamp min/max; resolve percentages (`W001`); determine breakpoint visibility.

### 12.3 Layout output

```json
{
  "path": "login/0/1",
  "type": "textfield",
  "x": 0, "y": 38400, "w": 12800, "h": 2560,
  "content": { "x": 768, "y": 512, "w": 11264, "h": 1536 },
  "children": []
}
```

Numbers are 1/64 px; `content` is padding-adjusted.

### 12.4 Reference measurement

- Each grapheme advances `0.5 × font size`: small 6.5, normal 8, large 10.
- Line heights 18/24/28; weight does not change advance.
- `…` is one cluster; greedy wrap at spaces; long words break at grapheme boundaries.
- Images use width/height/aspect; failure uses placeholder size.
- Pin the Unicode version for byte-exact non-ASCII tests.

Production uses platform metrics; layout is identical. Tests stub or use reference mode.

### 12.5 Tests and determinism

| Test | Expected |
| --- | --- |
| Parser | AST or error codes |
| Normalizer | canonical normalized AST |
| Theme | resolved light/dark values |
| Layout | exact 1/64 boxes for row/column/grid/wrap/stack |
| Text | exact line boxes/ellipsis |
| Primitives | preferred size, roles, states |
| Extended/project | identical boxes/roles to expansion |
| Component errors | missing params, cycles, bad slots, names |
| Accessibility | role/name/state tree |
| Overlays | placement, roles, dismissal |
| Tree/table | expansion, selection, sorting |
| Platform | correct native/custom widget |
| Visual | screenshot tolerance per platform |

Determinism checklist: no implicit padding/margin/font/color/chrome; all sizes 1/64;
overlay scrollbars; explicit safe areas; reference measurement; stable paths; deterministic
component expansion; ordered validation errors; no animation affecting layout; no platform
theme leaks.

---

## 13. Versioning and conformance

### 13.1 Conformance levels

| Level | Covers |
| --- | --- |
| **P** Parser | Syntax, structural validation, normalized AST, stable paths. |
| **L** Layout | Tokens/sizes, layout algorithm, 1/64 px boxes. |
| **C** Primitives | Every primitive with §6.2 defaults. |
| **X** Extended | Built-in and project components by expansion or equivalent. |
| **A** Accessibility | Accessibility tree and platform semantics (§9). |
| **R** Renderer | Paint and interaction states on a target platform. |

A renderer may claim a subset but must declare unsupported primitives/components/features.

### 13.2 Versioning and change process

- First non-comment line is `gui-v2`.
- `x-` attributes are extensions; preserve and ignore.
- Unknown types, attributes, enums or theme keys are errors; reject rather than guess.
- Breaking syntax/token changes require a new directive. Additive revisions keep `gui-v2`
  and update the revision.
- Change process: propose with user problem; check contrast/accessibility/platform/patterns;
  update docs and revision; update examples/tests/changelog; review with the design owner.
- Deprecation: mark replacement/removal version; keep working for at least one minor release
  unless security/accessibility forces a break; provide migration note.
- Quality: tokens only; correct component; all states; keyboard/focus/roles; contrast/touch;
  content rules; responsive; documented deviations; automated token/contrast/catalog/visual/
  accessibility/link checks.

### 13.3 Changelog

| Version | Change |
| --- | --- |
| 2.0 | Combined guide and spec; introduced primitive/extended/project layers, master spacing, three-neutral color model, screen-document composition and guide/workflow split. |

---

## 14. Cheat sheet

### 14.1 Syntax

```text
gui-v2

theme
  key=value

component <name> ["<description>"]
  param <name> [=<default>]
  slot [<name>]
  <body root>

screen <id> "<title>" [attributes]
  <type> ["<text>"] [attributes]
    <type> ["<text>"] [attributes]
```

Two spaces per level; `#` whole-line comment; JSON-quoted strings; bare booleans;
`${name}` parameter; `slot`/`slot name` insertion points.

### 14.2 Common attributes

```text
Placement:  h=left|center|right|fill   v=top|center|bottom|fill
Sizing:     width/height=auto|<n>|<n>%  min-/max-  grow=<n>
Box:        bg=<color>  border=<bool|n>  border-color=<color>
            radius=<n|sm|md|lg|pill|none>  shadow=<none|sm|md|lg>
            pad=<none|xs|s|m|l|xl>  pad-x=<same>  pad-y=<same>
Color:      mode=light|dark  tone=<tone>
Behavior:   id=<id>  action=<name>  visible=<bool>  scroll=<none|y|x|both>
            tooltip="..."  tooltip-placement=<top|right|bottom|left>
            visible-at="sm md lg xl"  hide-at="sm md lg xl"
Layout:     justify=<start|center|end|between|around|evenly>
            align=<start|center|end|stretch>  wrap=<bool>
            gap=<spacing>  col-gap=<spacing>  row-gap=<spacing>
Grid:       cols="<tracks>"  rows="<tracks>"  col=<n>  row=<n>
            col-span=<n>  row-span=<n>  flow=row|column
```

### 14.3 Component names

```text
Containers: row, column, grid, stack
Primitives: text, icon, image, divider, spacer, button, textfield, textarea, select,
            checkbox, radio, switch, slider, progress, avatar, badge, tag, spinner,
            skeleton, kbd
Extended:   field, card, page-header, list, list-item, table, table-head, table-row,
            table-cell, tabs, tab, banner, toast, menu, menu-item, breadcrumbs,
            pagination, action-bar, empty-state, metric, radio-group, tree, tree-item,
            tooltip, popover
Project:    component <name> with param/slot lines and one body root
```

Use the component tables in §6 for attributes, structure and styling.

### 14.4 Defaults

```text
Font:        Inter/system-ui, 16px base, 13px small, 20px large
Weights:     400 / 500 / 600 / 700
Spacing:     space=8 -> none 0, xs 4, s 8, m 16, l 24, xl 32
             (space=10 -> 0, 5, 10, 20, 30, 40)
Radii:       sm 4 / md 8 / lg 16 / pill 999
Controls:    32 small / 40 normal / 48 large; 44 touch target
Borders:     1px; focus ring 2px + 2px offset
Modes:       light/dark
Neutrals:    bg / surface / fg, plus muted, border, hover, pressed, scrim
Brand:       light #2563EB / dark #60A5FA
Semantic:    info, success, warning, alert, error
Badges:      blue, purple, pink, teal, indigo, cyan, lime, gray
Icons:       16 / 20 / 24
Motion:      fast 120ms / normal 200ms / slow 320ms
Easing:      cubic-bezier(0.2, 0, 0, 1)
Shadows:     sm 1px/2px; md 4px/8px; lg 12px/24px
Breakpoints: sm 640 / md 900 / lg 1200 / xl 1440
Layout:      1/64px units; overlay scrollbars; no implicit margins
```
