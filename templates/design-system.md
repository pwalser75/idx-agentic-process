# GUI Specification

**Specification version:** 1.1  
**Directive version:** `gui 1`  
**Status:** Stable, conformance-oriented

A compact, deterministic, theme-driven format for describing application screens. It is designed for one agent to emit and another to parse, validate, lay out, and render on desktop, mobile, and web — including Java Swing, Android, iOS, and HTML/CSS.

The format is intentionally finite. Every visual default is specified here. Renderers MUST NOT invent padding, fonts, colors, shadows, spacing, or alignment.

> **Read this first**
> - Screens are trees. Every node is a component; layout containers are components too.
> - Layout is one of `rows`, `columns`, or `grid`, plus a small set of fixed-purpose containers.
> - Sizes are preferred-first. Explicit size wins; otherwise a node fills or hugs its content.
> - Spacing is expressed only as `none`, `xs`, `s`, `m`, `l`, or `xl`.
> - Color modes are `light` and `dark`; semantic tones are `info`, `success`, `alert`, `warning`, `error`.
> - The result must be deterministic: same document + theme + measurement mode + renderer version = same AST, layout boxes, accessibility tree, and paint order.
> - `example.md` is the reference example; `example/` is a visual reference prototype.

The keywords **MUST**, **MUST NOT**, **SHOULD**, and **MAY** are used as in RFC 2119.

## Contents

1. [Conformance and determinism](#1-conformance-and-determinism)
2. [Core model](#2-core-model)
3. [Syntax](#3-syntax)
4. [Theme and defaults](#4-theme-and-defaults)
5. [Layout](#5-layout)
6. [Components](#6-components)
7. [Platform mapping](#7-platform-mapping)
8. [Accessibility](#8-accessibility)
9. [Validation and error codes](#9-validation-and-error-codes)
10. [AST, normalization, and testing](#10-ast-normalization-and-testing)
11. [Quick reference](#11-quick-reference)

---

## 1. Conformance and determinism

### 1.1 Conformance levels

| Level | What it covers |
| --- | --- |
| **P** — Parser | Reads the syntax, validates structure, emits a normalized AST with stable paths. |
| **L** — Layout | Resolves theme tokens and sizes, applies the layout algorithm, emits boxes in 1/64 px. |
| **C** — Components | Implements the core component catalog with the defaults in this specification. |
| **X** — Extended | Implements the extended components: table, menu, document, carousel, date-range, pagination, skeleton, etc. |
| **A** — Accessibility | Emits the accessibility tree and platform semantics described in §8. |
| **R** — Renderer | Paints the boxes and handles the specified interaction states on a target platform. |

A renderer MAY claim a subset (for example, L + C + A on Android). It MUST declare which components are unsupported rather than silently substituting an unrelated widget.

**Core catalog (C):** `rows`, `columns`, `grid`, `list`, `list-item`, `label`, `icon`, `tag`, `badge`, `button`, `textfield`, `textarea`, `date`, `password`, `dropdown`, `checkbox`, `radio-group`/`radio`, `switch`, `slider`, `progress`, `field`, `banner`, `tabs`/`tab`, `action-bar`, `divider`, `spacer`, `image`, `avatar`, `document`/`document-header`/`document-footer`.

**Extended catalog (X):** `table`, `menu`/`menu-item`, `carousel`, `time`, `date-range`, `pagination`, `breadcrumbs`, `kbd`, `spinner`, `skeleton`, `screen-ref`, and the `drawer`/`sheet` screen kinds.

An implementation MUST declare exactly which extended components it supports. A missing extended component is a validation error at render time, not a silent fallback.

### 1.2 Determinism contract

A conforming implementation MUST process a document through these stages:

1. **Parse** into a raw tree.
2. **Validate** structure and value ranges.
3. **Normalize**: apply defaults, expand booleans, resolve aliases, assign stable paths.
4. **Resolve theme**: select light/dark tokens, apply overrides, resolve tokens to values.
5. **Expand references**: replace `screen-ref` nodes with the referenced screen content; reject cycles.
6. **Measure**: compute text/image/control intrinsic sizes.
7. **Lay out**: compute boxes in **1/64 logical-pixel units**.
8. **Build accessibility tree**.
9. **Paint** in tree order.

Given the same input, theme, measurement mode, viewport/safe-area inputs, and implementation version, stages 1–8 MUST be byte-for-byte identical when serialized canonically.

Determinism rules:

- Layout math uses **fixed-point integers in 1/64 px**. Floats MAY be used internally, but every intermediate size and final box MUST be quantized to 1/64 px. Round half away from zero.
- Final boxes are reported as 1/64-unit integers. A renderer that paints in whole pixels rounds at paint time only.
- Scrollbars are **overlay** and never change the content box.
- Safe-area insets are explicit inputs; they are not measured from a device inside the layout engine.
- No implicit padding, margins, focus offsets, or platform control insets are allowed.
- No animation affects layout.
- Text measurement is deterministic for a given measurement mode. Production mode may use platform font metrics; conformance tests use **reference measurement** (§10.4).
- Percentages require a definite parent size on that axis. If the parent is indefinite, the percentage resolves to `auto` and a warning is emitted.

### 1.3 Versioning and extensions

- The first non-comment line is `gui 1`.
- Attributes starting with `x-` are extensions. Conforming renderers MUST preserve but ignore them.
- Unknown types, attributes, enum values, or theme keys are errors.
- A renderer MUST reject a document it cannot fully interpret rather than guess.

---

## 2. Core model

### 2.1 Screens

A screen is the root of a document. It is a container with:

- an `id` and a quoted `title`,
- a root layout: `rows`, `columns`, or `grid`,
- a `kind`,
- a color mode,
- theme-driven styling.

| `kind` | Presentation defaults |
| --- | --- |
| `screen` | Fills the host viewport; `bg=bg`, `pad=xl`, `gap=m`, `safe=true`. |
| `dialog` | Preferred width 480; content height; `bg=raised`, `pad=xl`, `gap=l`, radius `xl`, `shadow=lg`, centered in a `scrim`; `safe=false`. |
| `drawer` | Preferred width 360; fills height; placement `right`; `bg=surface`, `pad=l`, `gap=m`, `shadow=lg`; `safe=true`. |
| `sheet` | Fills width; content height up to 85% viewport; placement `bottom`; `bg=raised`, `pad=l`, `gap=m`, radius top `xl`, `shadow=lg`; `safe=false`. |
| `frame` | Content size; `bg=surface`, `border=true`, radius `lg`, `pad=l`, `gap=m`; `safe=false`. |
| `region` | Content size; transparent; `pad=none`, `gap=m`; `safe=false`. |

The quoted title is metadata: accessible screen/dialog name, and window title where the host provides one. It is not rendered automatically.

The screen header also accepts: `kind`, `safe`, `placement`, `mode`, `width`, `height`, `min-*`, `max-*`, `pad`, `pad-x`, `pad-y`, `bg`, `border`, `border-color`, `radius`, `shadow`, `scroll`, plus the layout attributes of its layout type: `gap` for `rows`/`columns`; `gap`, `cols`, `rows`, `col-gap`, `row-gap`, and `flow` for `grid`; `justify` and `align-items` for `rows`/`columns`; `wrap` for `columns`.

`placement=left|right` is valid for `drawer`; `placement=top|bottom` is valid for `sheet`. `kind` defaults to `screen`; `safe` defaults to `true` for `screen`/`drawer`, otherwise `false`.

### 2.2 The component tree

Every node is a component. Containers are components and can be nested anywhere a component is allowed.

**Free layout containers**

`rows`, `columns`, `grid`, `list`

**Fixed-purpose containers**

`tabs` + `tab`, `action-bar`, `carousel`, `field`, `banner`, `menu`, `radio-group`, `table` + `table-head` + `table-row` + `table-cell`, `breadcrumbs`, `document` + `document-footer`, `screen-ref`

**Leaf components**

`label`, `textfield`, `textarea`, `icon`, `tag`, `badge`, `button`, `date`, `time`, `date-range`, `password`, `dropdown`, `checkbox`, `radio`, `switch`, `slider`, `progress`, `divider`, `spacer`, `image`, `avatar`, `spinner`, `skeleton`, `pagination`, `kbd`, `list-item`, `menu-item`, `document-header`

Leaf components MUST NOT have children. A container with no children is valid (useful as a spacer or empty region).

### 2.3 IDs, paths, and actions

- `id` is optional and unique within a screen after `screen-ref` expansion.
- Every node has a **stable structural path**, independent of `id`: `root`, `root/0`, `root/0/2`, etc., counting children in document order.
- Actions emitted by a node use its `action` name; payloads include the node path and, when present, the node `id`.
- Renderers MUST NOT derive behavior from a component type alone.
- Auto-generated paths are for testing and event routing only; they are not persisted.

### 2.4 Color modes

Every node has a mode: `light` or `dark`. The screen's mode is the default. A container sets the mode for its subtree; any descendant can override it.

A mode selects color tokens; it does not change layout. If a node overrides the mode but has no background, it inherits the parent's painted background while using the overridden mode's foreground colors. Set `bg` explicitly when the background should change.

### 2.5 Units, direction, and measurement

- All dimensions are **logical pixels**: CSS px, Android dp, iOS points, Swing logical pixels.
- Percentages refer to the parent's **content box** on the same axis.
- The document is LTR. `left`/`right` are physical. RTL mirroring is not part of version 1.
- Text is measured by the renderer. Tests use the reference measurement in §10.4.
- Images are measured from their preferred size and `aspect`; the intrinsic asset size is used only when `aspect=free`.

---

## 3. Syntax

### 3.1 Document structure

```text
gui 1

theme
  key=value

screen <id> "<title>" <layout> [attribute ...]
  <node>
    <node>
```

- UTF-8, LF line endings.
- One optional `theme` block, then one or more screens.
- Indentation is exactly two spaces per nesting level. Tabs are forbidden.
- Blank lines are ignored.
- A line whose first non-space character is `#` is a comment.
- Strings use JSON escaping (`\"`, `\\`, `\n`, `\t`, `\uXXXX`).
- Positional text is always quoted and comes before attributes.
- Booleans may be written bare: `checked` means `checked=true`.

### 3.2 Grammar

```ebnf
document    = "gui" SP "1" NL [ theme ] { screen } ;
theme       = "theme" NL { INDENT2 key "=" value NL } ;
screen      = "screen" SP id SP string SP layout { SP attr } NL { node } ;
node        = INDENT type [ SP string ] { SP attr } NL { node } ;
layout      = "rows" | "columns" | "grid" ;
type        = layout | container | component ;
attr        = key [ "=" value ] ;
key         = ( letter | digit | "-" | "." )+ ;
value       = string | bare ;
```

`INDENT` is context-sensitive: a node's children are the following lines with exactly two more leading spaces.

### 3.3 Values

| Type | Examples | Notes |
| --- | --- | --- |
| Dimension | `16`, `50%` | Logical pixels or percent of the parent content box. |
| Spacing | `none`, `xs`, `s`, `m`, `l`, `xl` | The only valid padding/gap values. |
| Color | `surface`, `info-soft`, `#2563EB`, `#2563EB66` | Theme token or hex. |
| Boolean | `true`, `false`, `checked` | Bare form allowed. |
| Enum | `left`, `fill`, `bottom-start` | Lowercase, exact. |
| Track list | `auto 1fr 1fr`, `240 1fr` | Space-separated; quoted when it contains spaces. |
| String | `"Re: Q3 planning"` | Required when the value contains spaces or reserved characters. |

Unless a component table states otherwise: booleans default to `false`, optional strings are absent, and numeric attributes listed without a default are required. Semantic `tone` defaults to `fg` for text/icons, `neutral` for tags, and `primary` for badges and accents.

### 3.4 Screen header

```text
screen login "Sign in" rows kind=dialog width=480 pad=xl gap=l mode=light
```

Positional: `screen`, id, quoted title, layout. All else are attributes. The screen header also accepts the layout attributes of its layout type.

### 3.5 Positional text

| Type | Text means |
| --- | --- |
| `label`, `tag`, `badge`, `button`, `checkbox`, `switch`, `radio`, `menu-item`, `tab`, `list-item`, `icon`, `kbd`, `document-header` | Visible label, icon name, or title. |
| `field` | Visible label. |
| `table-cell` | Optional cell text (prefer child components). |
| Containers | No positional text, except `tab`, `field`, `document-header`, and `list-item`. |

A required text missing is a validation error.

### 3.6 Documents and embedded screens

A `document` has exactly one content node between its optional header and footer:

```text
document
  document-header "Workspace settings" description="Manage..." icon=settings
  rows
    ...
  document-footer
    button "Cancel" variant=ghost
    button "Save" variant=primary default
```

The content node may be a container, a component, or `screen-ref`.

```text
screen-ref screen=project-summary
```

`screen-ref` embeds the referenced screen's root layout and children. The referenced screen's title, `kind`, and host sizing are ignored; its `mode` and theme apply. References MUST NOT form a cycle. IDs MUST remain unique after expansion.

### 3.7 Canonical form

For tests and diffing, normalize to:

- two-space indentation, LF,
- lowercase keys and enum values,
- bare booleans only for boolean attributes,
- attributes in a stable order: positional text, then `id`, then alphabetical keys,
- one blank line between theme and screens, and between screens.

---

## 4. Theme and defaults

### 4.1 Theme block and token resolution

```text
theme
  font.family="Inter, system-ui, sans-serif"
  space.unit=4
  light.primary="#7C3AED"
  dark.primary="#C4B5FD"
```

- Unspecified tokens keep the defaults in §4.2–§4.6.
- Color tokens are written `light.<token>` or `dark.<token>` in the theme block; screens refer to them without the prefix.
- Unknown theme keys are errors.
- Resolution order for a node:
  1. explicit attribute,
  2. the node's resolved mode (inherited unless overridden),
  3. component defaults in §4.7,
  4. global defaults in this section.

### 4.2 Typography

| Token | Default |
| --- | --- |
| `font.family` | `system-ui, sans-serif` |
| `font.mono` | `ui-monospace, SFMono-Regular, Menlo, monospace` |
| `font.size` | `16` |
| `font.size-small` | `13` (0.8125 × base) |
| `font.size-large` | `20` (1.25 × base) |
| `font.line-small` | `18` |
| `font.line-normal` | `24` |
| `font.line-large` | `28` |
| `font.weight-regular` | `400` |
| `font.weight-medium` | `500` |
| `font.weight-semibold` | `600` |
| `font.weight-bold` | `700` |

If `font.size` changes and `font.size-small`/`font.size-large` are not overridden, re-derive them with the ratios above.

`system-ui` maps to the platform UI font: `UIManager.getFont("Label.font")` or the platform default on Swing, `sans-serif`/Roboto on Android, `UIFont.systemFont` on iOS, and `system-ui` on web.

### 4.3 Spacing

| Token | Value | Factor of `space.unit` |
| --- | --- | --- |
| `space.unit` | `4` | — |
| `none` | `0` | 0 |
| `xs` | `4` | 1 |
| `s` | `8` | 2 |
| `m` | `12` | 3 |
| `l` | `16` | 4 |
| `xl` | `24` | 6 |

Spacing tokens are the only valid values for `pad`, `pad-x`, `pad-y`, `gap`, `col-gap`, `row-gap`, and `inset`. Numeric spacing is invalid. Width, height, icon sizes, control heights, and image sizes remain numeric.

### 4.4 Radii, controls, breakpoints

| Token | Default | Use |
| --- | --- | --- |
| `radius.sm` | `6` | Checkboxes, keycaps. |
| `radius.md` | `10` | Inputs, buttons, menus. |
| `radius.lg` | `14` | Cards, menus, frames. |
| `radius.xl` | `20` | Dialogs, sheets. |
| `radius.pill` | `999` | Tags, badges, switches. |
| `control.height` | `40` | Normal control. |
| `control.height-small` | `32` | Small control. |
| `control.height-large` | `48` | Large control. |
| `control.pad-x` | `m` (12) | Input horizontal inset. |
| `control.pad-y` | `s` (8) | Input vertical inset. |
| `button.pad-x` | `l` (16) | Button horizontal inset. |
| `list-item.min-height` | `56` | List item minimum. |
| `menu.item-height` | `40` | Menu item. |
| `table.row-height` | `48` | Table row. |
| `table.row-height-dense` | `40` | Dense table row. |
| `radio.size` | `20` | Radio diameter. |
| `pagination.size` | `32` | Pagination button. |
| `spinner.size` | `20` | Spinner diameter. |
| `focus.width` | `2` | Focus ring width. |
| `focus.offset` | `2` | Focus ring offset. |
| `touch.min` | `44` | Minimum hit area. |
| `disabled.opacity` | `0.5` | Disabled opacity. |
| `motion.fast` | `120ms` | Small state changes. |
| `motion.normal` | `200ms` | Menus, dialogs, transitions. |
| `breakpoint.sm` | `640` | Mobile/tablet boundary. |
| `breakpoint.md` | `900` | Tablet/desktop boundary. |
| `breakpoint.lg` | `1200` | Desktop boundary. |
| `breakpoint.xl` | `1440` | Large desktop boundary. |

Breakpoint ranges: `sm` = below 640, `md` = 640–899, `lg` = 900–1199, `xl` = 1200+. `visible-at` shows a node only in the listed ranges; `hide-at` hides it there. Hidden nodes are not laid out. Both take space-separated lists (`visible-at="sm md"`).

### 4.5 Base colors

| Token | Light | Dark | Use |
| --- | --- | --- | --- |
| `bg` | `#FFFFFF` | `#0C111D` | Screen background. |
| `surface` | `#F7F8FA` | `#131A26` | Panels, sidebars, secondary surfaces. |
| `raised` | `#FFFFFF` | `#1A2230` | Cards, inputs, menus. |
| `fg` | `#101828` | `#F5F6F7` | Primary foreground. |
| `muted` | `#667085` | `#94969C` | Secondary text. |
| `border` | `#E4E7EC` | `#2A3342` | Borders and dividers. |
| `primary` | `#2563EB` | `#60A5FA` | Primary accent. |
| `on-primary` | `#FFFFFF` | `#0B1220` | Text/icons on primary. |
| `primary-soft` | `#EFF4FF` | `#102A43` | Soft primary background. |
| `focus-ring` | `#2563EB66` | `#60A5FA66` | Focus ring. |
| `neutral-soft` | `#F2F4F7` | `#1F2937` | Secondary button, neutral tag. |
| `neutral-on` | `#344054` | `#D0D5DD` | Text on neutral-soft. |
| `scrim` | `#1018287A` | `#000000A6` | Modal backdrop. |

### 4.6 Semantic colors and badge palette

Semantic tones: `info` (blue), `success` (green), `alert` (yellow), `warning` (orange), `error` (red).

Each tone has `<tone>`, `<tone>-soft`, `<tone>-on` (readable on background/soft), and `<tone>-contrast` (readable on solid).

| Token | Light | Dark |
| --- | --- | --- |
| `info` | `#2563EB` | `#60A5FA` |
| `info-soft` | `#EFF8FF` | `#102A43` |
| `info-on` | `#175CD3` | `#84CAFF` |
| `info-contrast` | `#FFFFFF` | `#0B1220` |
| `success` | `#15803D` | `#32D583` |
| `success-soft` | `#ECFDF3` | `#0C2E22` |
| `success-on` | `#067647` | `#6CE9A6` |
| `success-contrast` | `#FFFFFF` | `#0B1220` |
| `alert` | `#CA8A04` | `#FDB022` |
| `alert-soft` | `#FEFCE8` | `#2E2408` |
| `alert-on` | `#854D0E` | `#FEC84B` |
| `alert-contrast` | `#422006` | `#0B1220` |
| `warning` | `#C2410C` | `#F79009` |
| `warning-soft` | `#FFF4ED` | `#2E1A0B` |
| `warning-on` | `#B93815` | `#FDB022` |
| `warning-contrast` | `#FFFFFF` | `#0B1220` |
| `error` | `#DC2626` | `#F97066` |
| `error-soft` | `#FEF3F2` | `#3A1414` |
| `error-on` | `#B42318` | `#FDA29B` |
| `error-contrast` | `#FFFFFF` | `#0B1220` |

Badge palette:

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
| `badge-contrast` | `#FFFFFF` | `#0B1220` |

Tone resolution:

| Target | Neutral | Primary | Semantic | Palette |
| --- | --- | --- | --- | --- |
| Text/icon | `fg` | `primary` | `<tone>-on` | `badge-<name>` |
| Fill/accent | `border` | `primary` | `<tone>` | `badge-<name>` |
| Tag background | `neutral-soft` | `primary-soft` | `<tone>-soft` | `badge-<name>` at 12% |
| Tag text | `neutral-on` | `primary` | `<tone>-on` | `badge-<name>` |
| Tag border | `border` | `primary` 30% | `<tone>` 30% | `badge-<name>` 30% |
| Solid badge background | `badge-gray` | `primary` | `<tone>` | `badge-<name>` |
| Solid badge text | `badge-contrast` | `on-primary` | `<tone>-contrast` | `badge-contrast` |

"At 12%/30%" means alpha blending over the current background. This is deterministic and implementable with `AlphaComposite`/`UIColor`/`android.graphics`/CSS `color-mix`.

### 4.7 Component default styling

| Component | Defaults |
| --- | --- |
| `label` | Transparent; normal/regular; `fg`; no padding. |
| `textfield`, `date`, `time`, `date-range`, `password`, `dropdown` | `raised`; 1px `border`; radius `md`; inset `s`/`m`; height 40. |
| `textarea` | Same; height `rows × 24 + 16`. |
| `icon` | Transparent; 20×20; `fg`. |
| `tag` | Tone-soft; tone text; 1px tone border at 30%; `pill`; inset `xs`/`s`; small/medium; height 26 (small) or 32 (normal). |
| `badge` | Solid tone; tone contrast; `pill`; inset `xs`/`s`; small/semibold; 16px line box; height 24; min width 24. |
| `button` | Radius `md`; normal/medium; see variants below. |
| `list` | Transparent; gap `none`; padding `none`; 1px dividers; vertical scroll. |
| `list-item` | Transparent; inset `m`/`l`; min height 56; leading 24; gap `m`; title normal/medium; description small/`muted`. |
| `checkbox` | 20×20; radius `sm`; 1px border; gap `s`; checked `primary`; label normal. |
| `radio` | 20×20 circle; 1px border; selected dot `primary`; gap `s`. |
| `switch` | 44×24 track; `pill`; off `neutral-soft`; on `tone`; 20px thumb; `shadow.sm`; gap `s`. |
| `slider` | 4px track; 20px thumb; `primary` fill; height 24. |
| `progress` | 8px track; `neutral-soft` track; tone fill; `pill`. |
| `tabs` | Transparent; bar + active content; variants below. |
| `tab` | Transparent; gap `m`; padding `none`. |
| `action-bar` | `surface`; pad-y `m`, pad-x `l`; gap `s`; 1px inner separator. |
| `carousel` | Transparent; gap `m`; slides fill viewport; indicators/arrows overlay. |
| `divider` | `border`; thickness 1. |
| `spacer` | Transparent; `grow=1`. |
| `image` | Transparent; `fit=cover`; radius `none`; neutral placeholder on load failure. |
| `avatar` | Size 40; circle; `primary-soft` initials; 10px status dot with 2px ring. |
| `field` | Transparent; gap `xs`; label small/medium; hint small `muted`; error small `error-on`. |
| `banner` | Tone-soft; 1px tone border at 30%; radius `lg`; pad `l`; gap `s`; title normal/semibold. |
| `menu` | `raised`; 1px border; radius `lg`; `shadow.md`; pad `xs`; min width 180. |
| `menu-item` | Height 40; pad `s`/`m`; gap `s`; radius `sm`; hover `neutral-soft`; selected `primary-soft`; danger `error-on`. |
| `table` | 1px border; radius `lg`; header `surface`; row 48/40; cell pad `s`/`m`; dividers; selected `primary-soft`. |
| `table-head` | `surface`; small/medium `muted`. |
| `breadcrumbs` | Small; gap `xs`; links `primary`; current `muted`. |
| `pagination` | 32px buttons; radius `sm`; gap `xs`; active `primary-soft`/`primary`. |
| `spinner` | `primary` arc; `size` 20; reduced motion → static. |
| `skeleton` | `neutral-soft`; radius `sm`; reduced motion → static. |
| `kbd` | Mono small; `surface`; 1px border; radius `sm`; height 22. |
| `document` | Header/content/footer stack; gap `m`; content scrolls by default. |
| `document-header` | 40px icon box + title/description; title large/bold; description small/`muted`. |
| `document-footer` | Right-aligned buttons; gap `s`; 1px top separator by default. |
| `screen-ref` | No styling; renders referenced content. |

Button variants:

| Variant | Background | Text | Border |
| --- | --- | --- | --- |
| `primary` | `primary` | `on-primary` | none |
| `secondary` | `neutral-soft` | `fg` | 1px `border` |
| `outline` | transparent | `fg` | 1px `border` |
| `ghost` | transparent | `primary` | none |
| `danger` | `error` | `error-contrast` | none |

Tab variants:

| Variant | Bar | Active tab | Inactive tab |
| --- | --- | --- | --- |
| `underline` | 48px; 1px outer border | 2px `primary` indicator; `primary` text | `muted` text |
| `pills` | 40px; `xs` gap | `primary-soft`; `primary`; `pill` | transparent; `muted` |
| `segmented` | 40px; `neutral-soft`; `md` radius; `xs` pad | `raised`; `fg`; `sm` shadow | `muted` |

Input icons: 20×20, `s` gap, `muted` by default. A leading icon adds 28px to the left inset; a trailing icon adds 28px to the right inset. Date/password/dropdown action icons occupy the final trailing slot.

### 4.8 State precedence

Visual state precedence, highest first:

1. `disabled`
2. `pressed`
3. `focused`
4. `hover`
5. `selected` / `checked`
6. default

`invalid`/`error` is a semantic overlay that combines with focus/hover (for example, error border + focus ring). Rules:

- **Disabled:** `disabled.opacity`, no pointer/focus.
- **Hover:** foreground overlay 6% light / 8% dark. Pointer devices only.
- **Pressed:** foreground overlay 10% light / 12% dark.
- **Focus:** `focus.width` ring in `focus-ring` with `focus.offset`. Keyboard focus only unless the platform has no keyboard.
- **Selected:** `primary-soft` background, `primary` text/indicator.
- **Reduced motion:** replace shimmer/rotation with a static state.

---

## 5. Layout

### 5.1 Box model

Each node has:

- an **outer box** (`x`, `y`, `width`, `height`),
- a **content box** = outer minus `pad-x`/`pad-y`,
- children placed inside the content box with `gap` between tracks.

No node has implicit margins.

### 5.2 Size precedence

For each axis, resolve in this order:

1. **Explicit size**: `width`/`height` if not `auto`, clamped by `min-*`/`max-*`.
2. **Fill**: `h=fill`/`v=fill` when the size on that axis is `auto`; the node takes the cell size.
3. **Preferred size**: intrinsic content size or the component default in §5.3.

If an explicit size is set, `fill` is ignored on that axis; the node is placed at the start of the cell. Do not combine explicit sizes with `fill` if you expect stretching.

Percentage sizes require a definite parent content size on that axis. If indefinite, they resolve to `auto` and emit `W001`.

### 5.3 Intrinsic sizes

| Node | Preferred size |
| --- | --- |
| `label` | Measured text width × line height. Wrapped: longest-word minimum; height from lines. |
| `textfield`, `date`, `time`, `password`, `dropdown` | 200×40 |
| `date-range` | 280×40 |
| `textarea` | 240 × (`rows` × 24 + 16) |
| `icon` | `size`×`size` (default 20) |
| `tag` | Content + padding; 26 (small) or 32 (normal). |
| `badge` | Content + padding; 24 high, minimum width 24. |
| `button` | Content + padding; min width 80; 32/40/48 high. |
| `list` | Content; scrolls when constrained. |
| `list-item` | 240×56 minimum. |
| `checkbox` | 20 + `s` + label. |
| `radio` | 20 + `s` + label. |
| `switch` | 44×24 + `s` + label. |
| `slider` | 200×24 |
| `progress` | 200×8 (plus value text when `show-value`). |
| `spinner` | `size`×`size`. |
| `skeleton` | Line: fill width × 12; circle: `size`×`size`; rect: 120×80. |
| `kbd` | Content + padding; 22 high. |
| `tabs` | Bar 48/40 + active tab content + gap. |
| `tab` | Content + padding/gaps. |
| `action-bar` | Max button height + pad-y + safe inset. |
| `carousel` | Max slide preferred height; fills width. |
| `field` | Label + controls + hint/error + gaps. |
| `banner` | Icon + content + padding. |
| `menu` | Max item width + padding; min 180. |
| `menu-item` | Content + padding; 40 high. |
| `radio-group` | Children + gaps. |
| `table` | Tracks + row heights + borders. |
| `table-row` | Cell content; 48 (40 dense). |
| `table-cell` | Content + cell padding. |
| `breadcrumbs` | Labels + separators + gaps. |
| `pagination` | Buttons; 32 high. |
| `document` | Header + content + footer + gaps. |
| `document-header` | 40 icon + title/description. |
| `document-footer` | Button row + separator. |
| `screen-ref` | Referenced screen preferred size. |
| `rows`, `columns` | Content + padding + gaps. |
| `grid` | Tracks + gaps + padding. |
| `divider` | Thickness on cross axis; fills along orientation. |
| `spacer` | 0×0. |
| `image` | 120×80 unless `width`/`height`/`aspect` determines it. |
| `avatar` | `size`×`size` (default 40). |

Text measurement is defined in §5.9.

### 5.4 Rows and columns

For a `rows` or `columns` container:

1. Compute the content box.
2. Main axis is vertical for `rows`, horizontal for `columns`.
3. For each child, compute the base main size: explicit main size, else preferred main size, clamped by min/max.
4. `total = sum(base) + gap × (n − 1)` (or the wrap algorithm in §5.5).
5. `free = content_main − total`.
6. If `free > 0`:
   - If any child has `grow > 0`, distribute `free` by weight.
   - Else distribute by `justify` (`start`, `center`, `end`, `between`, `around`, `evenly`).
7. If `free < 0`: shrink auto children proportionally down to their minimum content size; explicit sizes do not shrink below their explicit value. If still overflowing, clip or scroll.
8. Place tracks from the content-box start.
9. Cross axis: each child gets the content cross size; apply `h`/`v` using precedence in §5.5.
10. Main-axis placement: if a track grew beyond the child's preferred size, apply `v` (rows) or `h` (columns).

**Example:** `grow=1` on the last row absorbs all extra vertical space. `grow=1` on the first column absorbs all extra horizontal space.

### 5.5 Distribution, alignment, and wrapping

| Attribute | Applies to | Default | Description |
| --- | --- | --- | --- |
| `justify` | rows, columns | `start` | Main-axis leftover distribution: `start`, `center`, `end`, `between`, `around`, `evenly`. Ignored if `grow` consumes the free space. |
| `align-items` | rows, columns | `auto` | Default cross-axis alignment: `auto`, `start`, `center`, `end`, `stretch`. |
| `wrap` | columns | `false` | Flow children onto new lines. |
| `col-gap` | rows, columns | `gap` | Horizontal gap override. |
| `row-gap` | rows, columns | `gap` | Vertical gap override. |

Alignment precedence per axis:

1. child `h`/`v` if explicitly set,
2. parent `align-items` if not `auto`,
3. component-class default (§5.5.1).

`start` maps to `left`/`top`, `end` to `right`/`bottom`, `stretch` to `fill`.

`justify` details: `between` puts the first child at the start and the last at the end (a single child at the start); `around` gives each child equal space on both sides (a single child is centered); `evenly` gives equal space between and around all children.

#### 5.5.1 Component-class defaults

| Class | Components | `rows` | `columns` | `grid` |
| --- | --- | --- | --- | --- |
| Stretch | rows, columns, grid, list, tabs, tab, action-bar, carousel, list-item, field, banner, table, table-head, table-row, table-cell, radio-group, document, document-header, document-footer, screen-ref, label, textfield, textarea, date, password, dropdown, time, date-range, slider, progress, skeleton | `h=fill`, `v=top` | `h=left`, `v=fill` | `h=fill`, `v=fill` |
| Content | icon, tag, badge, button, checkbox, radio, image, avatar, switch, menu, menu-item, breadcrumbs, pagination, spinner, kbd | `h=left`, `v=top` | `h=left`, `v=center` | `h=left`, `v=center` |

If an explicit size is set on an axis, that axis starts aligned (left/top) unless `h`/`v` says otherwise.

#### 5.5.2 Wrapping

With `columns wrap=true`:

- Children keep their preferred/explicit main size; `grow` is ignored.
- Start a new line when the next child's base width exceeds the remaining width.
- `justify` applies to each line.
- `align-items` applies within each line.
- `gap` applies horizontally and vertically; `col-gap`/`row-gap` override.
- A single child wider than the content box overflows or scrolls.

### 5.6 Grid

| Attribute | Default | Description |
| --- | --- | --- |
| `cols` | `1fr` | Column tracks. |
| `rows` | `auto` | Row tracks. |
| `gap` | `m` | Both axes. |
| `col-gap` | `gap` | Horizontal override. |
| `row-gap` | `gap` | Vertical override. |
| `flow` | `row` | `row` or `column` auto-flow. |

Track tokens: `auto` (max preferred), `<n>fr` (flexible weight), `<n>` (px), `<n>%` (content box).

Algorithm:

1. Resolve fixed and percentage tracks.
2. Size `auto` tracks from preferred sizes of items in that track.
3. Distribute a spanning item's preferred size equally across spanned auto tracks after single-track contributions.
4. Distribute remaining space across `fr` tracks.
5. Place explicit `col`/`row` items first.
6. Auto-place remaining items in `flow` order, skipping occupied cells.
7. Size each item to its cell and apply alignment.
8. Overflow clips or scrolls.

If `cols`/`rows` are omitted: one flexible column, auto rows.

### 5.7 Overflow, scrolling, and safe areas

- `scroll=none` (default): overflow is clipped.
- `scroll=y|x|both`: overflow scrolls.
- `list` always scrolls vertically when constrained.
- Scrollbars are **overlays**; they never reduce the content box.
- Safe-area insets are added **outside** the content box when `safe=true`; `pad` is applied inside. Insets are inputs to the layout engine (tests use zero).

### 5.8 Fixed-purpose container layouts

| Container | Defaults |
| --- | --- |
| `field` | `gap=xs`, `pad=none`; label small/medium; hint/error small. |
| `banner` | `tone=info`, `variant=soft`, `dismissible=false`, `gap=s`, `pad=l`. |
| `menu` | `open=true`, `placement=bottom-start`, `gap=none`, `pad=xs`. |
| `radio-group` | `orientation=vertical`, `gap=s`, `pad=none`. |
| `tabs` | `variant=underline`, `placement=top`, active = first enabled tab, `equal=true`, `scrollable=false`, `gap=none`, `pad=none`. |
| `action-bar` | `placement=bottom`, `equal=true`, `align=right`, `separator=true`, `safe=true`, `gap=s`, `pad-y=m`, `pad-x=l`. |
| `carousel` | `active=0`, `gap=m`, `pad=none`, `show-indicators=true`, `show-arrows=false`, `loop=false`, `snap=true`. |
| `table` | `cols=1fr`, `selectable=false`, `striped=false`, `dense=false`, `gap=none`, `pad=none`. |
| `document` | `scroll=y`, `gap=m`, `pad=none`. |
| `document-footer` | `separator=true`, `gap=s`, `pad=none`. |
| `breadcrumbs` | `separator="/"`, `gap=xs`, `pad=none`. |
| `list` | `divider=true`, `navigation=false`, `gap=none`, `pad=none`. |

**`field`** — vertical stack: label, control children, hint/error. Gap `xs`. `error` replaces `hint`, marks the first control invalid. `for` associates the label; otherwise the first input-like child is used. `required` adds a marker and required semantics.

**`banner`** — horizontal: leading icon, content column, optional dismiss button. Content column stacks `title` and children with gap `s`. `tone` selects colors; `variant=soft|solid` (default `soft`: tone-soft background, tone-on text, tone 30% border; `solid`: tone background, tone-contrast text, no border); `dismissible` adds a close button. The default icon is `info` for info/neutral, `check-circle` for success, `alert-triangle` for alert/warning, and `x-circle` for error. Error/warning use `role=alert`, others `role=status`.

**`menu`** — overlay list; `open=true` by default; `gap=none`; children are `menu-item` and `divider`. `anchor` + `placement` position it. Items 40 high. Keyboard: Up/Down, Enter, Escape.

**`radio-group`** — `vertical` (default) or `horizontal`; children are `radio`. Group `value` selects the matching radio. Arrows move, Space selects.

**`table`** — children: optional `table-head`, then `table-row`s; rows contain `table-cell`s. `cols` defines tracks. `selectable` prepends a 40px checkbox column and a select-all header. Rows 48 (40 dense). `striped`, `caption`, `empty`.

**`breadcrumbs`** — horizontal labels with separators; last is current. Navigation landmark.

**`tabs` / `tab`** — bar (48 underline, 40 pills/segmented) + active tab content. Children are `tab`. `equal` shares width; `scrollable` uses preferred widths. Only the active tab is measured/painted. `placement=top|bottom`.

**`action-bar`** — horizontal buttons; `equal` shares width; `align` when not equal; `separator`; `safe`; gap `s`; pad-y `m`, pad-x `l`. Children MUST be buttons. Normal flow; place last with growing content for a bottom bar.

**`carousel`** — slides are children, sized to the viewport; child size/alignment/grow ignored. `active`, `gap`, `show-indicators`, `show-arrows`, `loop`, `snap`. Preferred height = max slide preferred height unless `height` is set.

**`document`** — vertical: optional `document-header`, exactly one content node, optional `document-footer`. Content grows and scrolls when `scroll=y` (default); header/footer fixed. Header: icon (40), title, description, `level`. Footer: buttons right-aligned, gap `s`, 1px top separator by default; exactly one button may be `default=true`. The default receives primary emphasis unless a variant is set.

**`screen-ref`** — expands to the referenced screen's root layout. The referenced screen's title/kind/host sizing is ignored. No cycles; IDs unique after expansion.

### 5.9 Text layout

- Single-line `label` (default): the line is laid out at its preferred width. If it does not fit, truncate at a grapheme boundary and append `…`.
- `wrap=true`: greedy wrap at spaces. If a word exceeds the width, break at grapheme boundaries.
- `max-lines=n`: wrap, then truncate the last line with `…`.
- Text alignment: `align=left|center|right`; vertical alignment within the line box is centered for single-line labels and top for multi-line.
- Ellipsis width is measured as `…` in the same style.
- List item title/description are single-line with ellipsis.
- Reference measurement: §10.4.

### 5.10 Rounding

- All measured sizes and layout arithmetic are quantized to **1/64 px**.
- Final boxes are reported as integer 1/64 units.
- Paint-time pixel snapping is renderer-specific and MUST NOT feed back into layout.
- Tests compare exact 1/64 integers when using reference measurement.

---

## 6. Components

### 6.1 Common attributes

All nodes accept:

| Attribute | Type | Default | Notes |
| --- | --- | --- | --- |
| `id` | identifier | — | Unique after reference expansion. |
| `mode` | `light`/`dark` | inherited | Subtree color mode. |
| `width`, `height` | `auto` / number / percentage | `auto` | Explicit size. |
| `min-width`, `max-width`, `min-height`, `max-height` | number / percentage | `0` / none | Clamps. |
| `grow` | number ≥ 0 | `0` | Main-axis weight. |
| `h` | `left`/`center`/`right`/`fill` | class default | Horizontal placement. |
| `v` | `top`/`center`/`bottom`/`fill` | class default | Vertical placement. |
| `pad`, `pad-x`, `pad-y` | spacing token | `none` | Inner padding. |
| `bg` | color | component default | Background. |
| `border` | bool / number | `false` | 1 when true. |
| `border-color` | color | `border` | |
| `radius` | number / `sm`/`md`/`lg`/`xl`/`pill`/`none` | component default | |
| `shadow` | `none`/`sm`/`md`/`lg` | `none` | |
| `opacity` | 0–1 | `1` | Subtree opacity. |
| `visible` | bool | `true` | Not laid out when false. |
| `visible-at`, `hide-at` | breakpoint list | all / none | Responsive visibility. |
| `action` | identifier | — | Emitted on activation. |
| `tooltip` | string | — | Hover/focus help. |
| `tooltip-placement` | `top`/`right`/`bottom`/`left` | `top` | |
| `scroll` | `none`/`y`/`x`/`both` | `none` | Containers only. |
| `col`, `row`, `col-span`, `row-span` | integer | auto / 1 | Grid children only. |

`x-` attributes are preserved but ignored.

### 6.2 Text

**`label`** — text, `size=small / normal|large` (normal), `weight=regular|medium|semibold|bold` (regular), `tone` (fg), `wrap=false`, `max-lines`, `align=left|center|right` (left), `for`, `level=1…6`. `level` adds heading semantics; if `size`/`weight` are omitted, levels 1–2 → large/bold, 3–4 → normal/semibold, 5–6 → small/semibold. A `label` with `action` is exposed and rendered as a link.

**`kbd`** — key text, `size=small / normal` (small), `tone=neutral`. Keycap styling; 22 high.

### 6.3 Inputs

| Type | Text | Key attributes | Preferred |
| --- | --- | --- | --- |
| `textfield` | — | `value`, `placeholder`, `input=text / number / email / tel / url / search` (default `text`), `label`, `icon`, `icon-right`, `icon-tone`, `required`, `disabled`, `readonly`, `invalid`, `max-length` | 200×40 |
| `textarea` | — | `value`, `placeholder`, `label`, `rows=3`, `icon`, `icon-right`, `icon-tone`, `max-length`, `disabled`, `invalid` | 240×auto |
| `date` | — | `value` (`YYYY-MM-DD`), `min`, `max`, `label`, `placeholder=YYYY-MM-DD`, `icon`, `icon-right`, `required`, `disabled`, `invalid` | 200×40 |
| `time` | — | `value` (`HH:MM`), `min`, `max`, `step=1`, `label`, `placeholder=HH:MM`, `required`, `disabled`, `invalid` | 160×40 |
| `date-range` | — | `start`, `end`, `min`, `max`, `label`, `required`, `disabled`, `invalid`, `icon=calendar` | 280×40 |
| `password` | — | `value`, `revealed=false`, `label`, `placeholder`, `icon`, `icon-right`, `required`, `disabled`, `invalid` | 200×40 |
| `dropdown` | — | `value`, `options` (`Label=value / ...`), `label`, `placeholder`, `icon`, `icon-right`, `required`, `disabled`, `invalid` | 200×40 |
| `checkbox` | Visible label | `checked=false`, `disabled`, `tone` | content |
| `radio` | Visible label | `value`, `checked=false`, `tone`, `disabled`, `label` | content |
| `radio-group` | — | `value`, `orientation=vertical / horizontal`, `label`, `disabled`, `action` | content |
| `switch` | Visible label | `checked=false`, `disabled`, `tone`, `label` | content |
| `slider` | — | `value=min`, `min=0`, `max=100`, `step=1 / any`, `tone`, `label`, `show-value`, `disabled` | 200×24 |
| `field` | Label | `for`, `hint`, `error`, `required`; children are controls | content |

Rules:

- Inputs use the textfield box; `date`/`time`/`date-range` have trailing picker actions; `password` has reveal; `dropdown` has a chevron.
- `invalid` uses the error tone and sets `aria-invalid`.
- `checkbox`/`radio`/`switch` labels are part of the hit area.
- `radio-group` children MUST be `radio`; at most one `checked` radio; group `value` wins.
- `field` error replaces hint and marks the first control invalid.
- `dropdown` options are `Label=value` separated by `|`; labels/values cannot contain `|` or `=` in v1.

### 6.4 Actions

**`button`** — text optional with icon+label; `variant=primary|secondary|outline|ghost|danger` (primary); `size=small / normal|large` (32/40/48); `tone` overrides primary/ghost accent; `icon`, `icon-right`, `align=left|center|right` (center); `disabled`; `default` (document footer only); `label` for icon-only buttons.

**`menu` / `menu-item`**

| `menu` | Default | | `menu-item` | Default |
| --- | --- | --- | --- | --- |
| `open` | `true` | | text | required |
| `anchor` | — | | `icon` | — |
| `placement` | `bottom-start` | | `shortcut` | — |
| `action` | — | | `tone` | `fg` (use `error` for danger) |
| | | | `selected` | `false` |
| | | | `disabled` | `false` |

Children of `menu`: `menu-item` or `divider`. Menus are raised panels with radius `lg`, `shadow.md`, pad `xs`, min width 180. Keyboard: Up/Down, Enter, Escape.

**`pagination`** — `page=1`, `pages` (required), `siblings=1`, `show-first-last=true`, `show-prev-next=true`, `disabled`, `label="Pagination"`. 32px buttons, active `primary-soft`/`primary`.

**`breadcrumbs`** — `separator="/"`; children are labels with `action`; last is current. Navigation landmark.

### 6.5 Display

| Type | Text | Key attributes |
| --- | --- | --- |
| `icon` | Icon name | `size=20`, `tone=fg`, `label`; with `action`, exposed as a link/button |
| `tag` | Visible text | `tone=neutral`, `size=small / normal`, `icon` |
| `badge` | Visible text | `tone=primary` |
| `image` | — | `src`, `alt`, `fit=cover / contain`, `aspect=free / 1:1 / 4:3 / 3:2 / 16:9 / 21:9`, `radius` |
| `avatar` | — | `src`, `initials`, `alt`, `size=40`, `shape=circle / rounded`, `status=online / away / busy / offline`, `tone=primary` |
| `progress` | — | `value=0…100`, `tone=primary`, `label`, `show-value`, `indeterminate` |
| `spinner` | — | `size=20`, `tone=primary`, `label="Loading"` |
| `skeleton` | — | `shape=line / circle / rect`, `lines=1`, `animated=true`, `label` |
| `divider` | — | `orientation=horizontal / vertical`, `thickness=1`, `color=border`, `inset=none` |
| `spacer` | — | `grow=1`, optional `width`/`height` |

Rules:

- A `label` or `icon` with `action` is exposed as a link/button and is keyboard-activatable.
- `image` `alt` is required; use `""` for decorative. If load fails, render a `neutral-soft` box with an `image` icon.
- `avatar` falls back to initials, then to letters derived from `alt`; status is exposed in the accessible description.
- `tag` tone resolution: neutral/primary/semantic/palette as §4.6.
- `badge` is solid; `tag` is soft.
- `skeleton` is hidden from assistive technology unless `label`.
- `progress`/`slider` `show-value` renders the value at the right.

### 6.6 Containers

**`rows`, `columns`, `grid`** — see §5. `rows`/`columns` accept `gap`, `pad*`, `scroll`, `justify`, `align-items`, `wrap` (columns), `col-gap`, `row-gap`. `grid` accepts `cols`, `rows`, `gap`, `col-gap`, `row-gap`, `flow`.

**`list`** — vertical scroll; `divider=true`, `navigation=false`, `empty`, `gap=none`, `pad=none`. Children may be any component. `navigation=true` exposes a navigation landmark; `list-item selected` marks current.

**`list-item`** — title text, `description`, `icon` OR `badge` (mutually exclusive), `icon-tone`, `badge-tone`, `selected`, `disabled`, `action`. 56 min height; title/description single-line ellipsis.

**`banner`** — `tone=info|success|alert|warning|error|neutral`, `title`, `icon`, `variant=soft|solid` (default `soft`), `dismissible`. Leading icon + content + close. Children are content/actions.

**`tabs` / `tab`** — see §5.8. `tab` attrs: `id` (required), `icon`, `badge`, `badge-tone`, `disabled`, `layout=rows|columns|grid` (rows), `gap=m`, `pad=none`, `cols`/`rows` for grid.

**`action-bar`** — see §5.8. `placement=bottom|top`, `equal=true`, `align=left|right|between`, `separator=true`, `safe=true`, `gap=s`, `pad-y=m`, `pad-x=l`, `bg=surface`.

**`carousel`** — see §5.8. `active=0`, `gap=m`, `show-indicators=true`, `show-arrows=false`, `loop=false`, `snap=true`, `action`.

**`table`** — see §5.8. `cols=1fr`, `caption`, `empty`, `selectable=false`, `striped=false`, `dense=false`, `action`. `table-row` `selected`, `disabled`, `action`; `table-cell` `align=left|center|right`.

**`document`** — see §5.8. `scroll=y`. `document-header` text title, `description`, `icon`, `icon-tone=primary`, `level=2`. `document-footer` `separator=true`; children are buttons; at most one `default=true`.

**`screen-ref`** — `screen` required.

### 6.7 Patterns

**Form section**

```text
field "Email" for=email hint="We never share it."
  textfield id=email input=email icon=mail
```

**Dialog document**

```text
screen settings "Settings" rows kind=dialog width=600 pad=xl gap=none
  document
    document-header "Workspace settings" description="Manage..." icon=settings
    rows gap=l
      field "Name" for=name
        textfield id=name value="Northstar"
    document-footer
      button "Cancel" variant=ghost action=close
      button "Save" variant=primary default action=save
```

**SPA split navigation**

```text
grid cols="280 1fr" gap=m
  list navigation=true
    list-item "Atlas" icon=palette selected action=open-atlas
    list-item "Orbit" icon=smartphone action=open-orbit
  document
    document-header "Atlas" description="Design system" icon=palette
    rows gap=l
      carousel
        ...
    document-footer
      button "Open" variant=primary default
```

No new layout primitive is needed: `grid` + `list` + `document` + `carousel` cover the classic split view. On mobile, hide the list with `hide-at=sm` and use a `drawer` screen or a menu.

**Dashboard** — `grid` with metric cards (`rows` + `tag`/`badge` + `progress`), `list` for activity, `action-bar` for actions.

**Empty/loading/error** — `empty-state` is composed from `icon` + `label` + `button`; loading uses `spinner`/`skeleton`; errors use `banner tone=error`.

---

## 7. Platform mapping

Use the theme tokens for all painting. Do not rely on platform default padding, fonts, or control chrome. Custom drawing is allowed and often required.

| Component | Web | Java Swing | Android | iOS |
| --- | --- | --- | --- | --- |
| `label` | `span`/`h1`–`h6` | `JLabel`/custom | `TextView` | `UILabel` |
| `heading` (`label level`) | semantic heading | `JLabel` + AccessibleRole | `TextView` + heading | `UILabel` + trait |
| `textfield` | `input` | `JTextField` | `EditText` | `UITextField` |
| `textarea` | `textarea` | `JTextArea` | `EditText` (multiline) | `UITextView` |
| `date`/`time`/`date-range` | `input[type=date/time]` or custom | custom picker | `DatePicker`/`TimePicker` | `UIDatePicker` |
| `password` | `input[type=password]` | `JPasswordField` | `EditText` password | `UITextField` secure |
| `dropdown` | `select` or custom | `JComboBox` | `Spinner`/menu | `UIButton` + menu |
| `checkbox` | `input[type=checkbox]` | `JCheckBox` | `CheckBox` | custom/`UIButton` |
| `radio`/`radio-group` | `input[type=radio]` | `JRadioButton` + `ButtonGroup` | `RadioButton` | custom |
| `switch` | `input[type=checkbox]` + style | `JToggleButton` custom | `Switch` | `UISwitch` |
| `slider` | `input[type=range]` | `JSlider` | `Slider` | `UISlider` |
| `progress` | `progress`/custom | `JProgressBar` | `ProgressBar` | `UIProgressView` |
| `button` | `button` | `JButton`/custom | `Button` | `UIButton` |
| `tag`/`badge` | `span` styled | custom `JLabel` | `TextView` background | `UILabel` background |
| `icon` | inline SVG | `Icon`/custom | `ImageView` | `UIImageView` |
| `image` | `img` | `JLabel` icon/custom | `ImageView` | `UIImageView` |
| `avatar` | `span`/`img` | custom | `ImageView` | `UIImageView` |
| `list`/`list-item` | `ul`/`li` | `JList`/custom | `RecyclerView` | `UITableView` |
| `tabs`/`tab` | custom + ARIA | `JTabbedPane`/custom | `TabLayout` | custom/`UITabBar` |
| `action-bar` | `div` | `JPanel` | `BottomAppBar` | `UIToolbar` |
| `carousel` | scroll-snap | custom | `ViewPager2` | `UIScrollView`/`UIPageViewController` |
| `table` | `table` | `JTable`/custom | `RecyclerView` | `UITableView` |
| `menu` | `div[role=menu]` | `JPopupMenu` | `PopupMenu` | `UIMenu` |
| `document` | `div` | `JPanel` | custom `View` | `UIView` |
| `field`/`banner` | `div` | `JPanel` | custom `View` | `UIView` |
| `pagination`/`breadcrumbs` | `nav` | custom | custom | custom |
| `spinner` | CSS/SVG | custom paint | `ProgressBar` | `UIActivityIndicatorView` |
| `skeleton` | `div` | custom paint | custom `View` | custom `UIView` |
| `kbd` | `kbd` | `JLabel` styled | `TextView` styled | `UILabel` styled |
| `screen-ref` | inline expansion | inline expansion | inline expansion | inline expansion |
| `divider` | `hr`/border | `JSeparator`/paint | `Divider` | `UIView` |
| `spacer` | flex spacer | `Box`/`JPanel` | `Space` | `UIView` |

Platform requirements:

- **Web:** semantic elements/ARIA; CSS variables for tokens; `:focus-visible`; `prefers-reduced-motion`; overlay scrollbars.
- **Swing:** custom `JPanel` painting for tags/badges/cards; `UIManager`/tokens; `AccessibleContext`; key bindings; overlay scrollbars; logical pixels.
- **Android:** `contentDescription`/roles; minimum 44dp touch targets; window insets for safe areas; `RecyclerView`/`ViewPager2`; theme attributes.
- **iOS:** `accessibilityLabel`/traits; safe-area guides; `UITableView`/`UICollectionView`; dynamic type only via explicit `size` attrs, not implicit scaling; `UIAccessibility` reduced motion.

Where a native widget cannot express the specified appearance, use custom drawing. Do not substitute a visually different native default.

**Text measurement per platform:**

- **Web:** measure with Canvas 2D using the resolved font and `measureText`; use DOM measurement only when the canvas is unavailable. Tests stub measurement with reference mode.
- **Swing:** use `FontMetrics` with fractional metrics disabled (`KEY_FRACTIONALMETRICS_OFF`) and integer advances. Do not use platform control borders or insets.
- **Android:** use `Paint.measureText`/`StaticLayout` with the resolved size in px; convert dp to px before layout.
- **iOS:** use TextKit/NSString sizing with the resolved font in points.
- **All:** production metrics may differ per platform; they MUST be stable for a given platform, font, and locale. Conformance tests use reference measurement (§10.4).

---

## 8. Accessibility

Every interactive component MUST have an accessible name from its text, `label`, or `label for=...`.

| Component | Role / semantics | Required states |
| --- | --- | --- |
| `label level` | heading at level | heading level |
| input controls | textbox/combobox/checkbox/radio/switch/slider | name, value, required, invalid, disabled |
| `button` | button | name, disabled, default |
| `tabs` | tablist/tab/tabpanel | selected, controls |
| `menu` | menu/menuitem | expanded, disabled, selected |
| `table` | table/row/columnheader/cell | caption, selection |
| `radio-group` | radiogroup/radio | name, checked, disabled |
| `dialog`/`drawer`/`sheet` | dialog | name, modal, focus trap |
| `banner` | status/alert | live region |
| `carousel` | region/carousel | slide position, controls |
| `pagination`/`breadcrumbs` | navigation | current page/current item |
| `spinner` | status | label |
| `skeleton` | hidden unless labelled | — |

Rules:

- Focus order is tree order. Every interactive node has a visible focus ring.
- Keyboard: buttons/links Enter/Space; tabs arrows/Home/End; menus Up/Down/Enter/Escape; radios arrows/Space; carousel Left/Right; dialogs Escape + focus trap.
- Touch targets SHOULD be at least 44×44; small visual controls get an invisible hit area.
- Contrast: 4.5:1 normal text, 3:1 large text/icons. The default theme is chosen for this.
- Color is never the only signal: invalid, selected, required also expose semantics.
- `tooltip` supplements, never replaces, the accessible name.
- `skeleton` is decorative unless `label` is set.
- `screen-ref` IDs must be unique after expansion; test the composed tree.

---

## 9. Validation and error codes

Validation reports errors in document order (line, column, path), then by code. Error object:

```json
{ "code": "E012", "severity": "error", "line": 42, "path": "root/1/0", "message": "button has neither text nor icon" }
```

| Code | Severity | Condition |
| --- | --- | --- |
| `E001` | error | Missing/invalid `gui 1` |
| `E002` | error | Tabs or indentation not a multiple of two spaces |
| `E003` | error | Unknown theme key |
| `E004` | error | Duplicate screen id |
| `E005` | error | Unknown type |
| `E006` | error | Leaf has children |
| `E007` | error | Unknown attribute (unless `x-`) |
| `E008` | error | Invalid enum |
| `E009` | error | Invalid numeric range |
| `E010` | error | Non-token spacing value |
| `E012` | error | Required text missing |
| `E013` | error | Button has neither text nor icon |
| `E014` | error | `list-item` has both `icon` and `badge` |
| `E015` | error | `tabs` has no `tab`, or a non-`tab` child |
| `E016` | error | Duplicate tab id or `active` not an enabled tab |
| `E017` | error | `action-bar` child is not a button |
| `E018` | error | `carousel.active` outside slide range |
| `E019` | error | Table structure/cell count invalid |
| `E020` | error | Document child order/count invalid |
| `E021` | error | More than one default button in a footer, or `default` outside a footer |
| `E022` | error | `screen-ref` missing/unknown/cyclic |
| `E023` | error | Radio group structure/value/checked invalid |
| `E024` | error | Pagination page out of range |
| `E025` | error | Invalid time/date-range format or bounds |
| `E026` | error | Missing image `src`/`alt` or avatar `alt` |
| `E027` | error | Menu child invalid |
| `E028` | error | Field has no control child |
| `E029` | error | Invalid `visible-at`/`hide-at` breakpoint |
| `E030` | error | `wrap=true` outside `columns` |
| `E031` | error | Duplicate id after reference expansion |
| `E032` | error | `for` does not resolve |
| `E033` | error | `label.level` outside 1–6 |
| `E034` | error | `tooltip-placement` invalid |
| `W001` | warning | Percentage resolved as `auto` because the parent is indefinite |
| `W002` | warning | Unsupported component on target platform |
| `W003` | warning | Text truncated or clipped |
| `W004` | warning | Non-default font fallback used |

Unknown `x-` attributes are preserved. Renderers MUST NOT silently repair errors.

---

## 10. AST, normalization, and testing

### 10.1 Canonical AST

```json
{
  "version": 1,
  "theme": {},
  "screens": [
    {
      "id": "login",
      "title": "Sign in",
      "kind": "screen",
      "layout": "rows",
      "attrs": { "mode": "light", "pad": "xl", "gap": "l" },
      "path": "login",
      "children": [
        {
          "type": "label",
          "text": "Welcome back",
          "attrs": { "size": "large", "weight": "bold" },
          "path": "login/0",
          "children": []
        }
      ]
    }
  ]
}
```

- `text` is `null` when absent.
- `attrs` contains explicit attributes only in the raw AST; the **normalized AST** applies defaults and resolves booleans/aliases.
- Stable paths are structural, not `id`-based.
- Canonical JSON for tests: sorted keys, 2-space indentation, UTF-8, trailing newline.

### 10.2 Normalization rules

1. Apply all defaults from §4 and §6.
2. Convert bare booleans to `true`.
3. Resolve spacing/radius tokens to numeric values in the **resolved** AST.
4. Resolve color tokens per mode.
5. Expand `screen-ref`; reject cycles and duplicate IDs.
6. Assign structural paths.
7. Clamp min/max.
8. Resolve percentages (definite parent) or mark `W001`.
9. Determine breakpoint visibility from the provided viewport width.

### 10.3 Layout output

```json
{
  "path": "login/0/1",
  "type": "textfield",
  "x": 0, "y": 38400, "w": 12800, "h": 2560,
  "content": { "x": 768, "y": 512, "w": 11264, "h": 1536 },
  "children": []
}
```

All numbers are 1/64 px. `content` is the padding-adjusted box. Painted pixels are derived at render time.

### 10.4 Reference measurement

Conformance tests use a deterministic measurement mode:

- Each Unicode grapheme cluster advances **0.5 × font size**.
- Small 13 → 6.5; normal 16 → 8; large 20 → 10.
- Line heights are 18/24/28.
- Font weight does not change advance.
- Ellipsis `…` is one cluster.
- Greedy wrap at spaces; break long words at grapheme boundaries.
- Images use `width`/`height`/`aspect`; load failure uses the placeholder size.
- Grapheme segmentation uses the Unicode version bundled with the test harness. For byte-exact golden tests, use ASCII-only strings; pin the Unicode version for other scripts.

Production renderers use platform metrics. The layout algorithm is identical; only the measurement function differs. Tests MUST stub or use reference mode.

### 10.5 Conformance tests

A conforming implementation SHOULD provide:

| Test | Input | Expected |
| --- | --- | --- |
| Parser | valid/invalid documents | AST or error codes |
| Normalizer | defaults/booleans/tokens | canonical normalized AST |
| Theme | light/dark overrides | resolved token values |
| Layout | rows/columns/grid/wrap | exact 1/64 boxes |
| Text | single-line/wrap/max-lines | exact line boxes and ellipsis |
| Components | each catalog entry | preferred size, roles, states |
| Accessibility | composed screen | role/name/state tree |
| References | screen-ref/cycle | expanded tree or E022 |
| Platform | component smoke test | correct native/custom widget |
| Visual | screenshots with test font | pixel tolerance per platform |

Fixture shape:

```json
{
  "spec": "...",
  "viewport": { "width": 390, "height": 844, "safe": { "top": 0, "bottom": 0 } },
  "measurement": "reference",
  "expected": {
    "boxes": [ { "path": "login", "x": 0, "y": 0, "w": 24960, "h": 54016 } ],
    "accessibility": [ { "path": "login/0", "role": "heading", "name": "Welcome back" } ],
    "errors": []
  }
}
```

### 10.6 Determinism checklist

- No implicit padding, margin, font, color, or control chrome.
- All sizes quantized to 1/64.
- Overlay scrollbars only.
- Safe-area insets explicit.
- Reference measurement for tests.
- Stable structural paths.
- Validation errors deterministic and ordered.
- No animations affect layout.
- No platform default theme leaks into components; custom draw where needed.

---

## 11. Quick reference

### 11.1 Syntax

```text
gui 1

theme
  key=value

screen <id> "<title>" rows|columns|grid [attributes]
  <type> ["<text>"] [attributes]
    <type> ["<text>"] [attributes]
```

Two spaces per level. `#` starts a whole-line comment. Strings are JSON-quoted. Booleans may be bare.

### 11.2 Attributes

```text
Placement: h=left|center|right|fill   v=top|center|bottom|fill
Sizing:    width/height=auto|<n>|<n>%  min-/max-  grow=<n>
Box:       bg=<color>  border=<bool|n>  border-color=<color>
           radius=<n|sm|md|lg|xl|pill|none>  shadow=<none|sm|md|lg>
           pad=<none|xs|s|m|l|xl>  pad-x=<same>  pad-y=<same>
Color:     mode=light|dark  tone=<tone>
Behavior:  id=<id>  action=<name>  visible=<bool>  scroll=<none|y|x|both>
           tooltip="..."  tooltip-placement=<top|right|bottom|left>
           visible-at="sm md lg xl"  hide-at="sm md lg xl"
Layout:    justify=<start|center|end|between|around|evenly>
           align-items=<auto|start|center|end|stretch>  wrap=<bool>
           col-gap=<spacing>  row-gap=<spacing>
Grid:      cols="<tracks>"  rows="<tracks>"  col=<n>  row=<n>
           col-span=<n>  row-span=<n>  flow=row|column
```

### 11.3 Containers

```text
rows|columns|grid
list navigation=<bool> divider=<bool> empty="..."
tabs active=<tab-id> variant=<underline|pills|segmented> placement=<top|bottom>
     equal=<bool> scrollable=<bool>
tab "label" id=<id> icon="name" badge="text" badge-tone=<tone> disabled
    layout=<rows|columns|grid> gap=<spacing> pad=<spacing>
action-bar placement=<bottom|top> equal=<bool> align=<left|right|between>
           separator=<bool> safe=<bool>
carousel active=<n> show-indicators=<bool> show-arrows=<bool> loop=<bool> snap=<bool>
field "label" for=<id> hint="..." error="..." required
banner tone=<tone> title="..." icon="name" variant=<soft|solid> dismissible
menu open=<bool> anchor=<id> placement=<bottom-start|bottom-end|top-start|top-end|left|right>
radio-group value="..." orientation=<vertical|horizontal> label="..." disabled
table cols="<tracks>" caption="..." empty="..." selectable striped dense
table-head
table-row selected disabled
table-cell align=<left|center|right>
breadcrumbs separator="/"
document scroll=<none|y>
document-footer separator=<bool>
screen-ref screen=<id>
```

### 11.4 Components

```text
label "text" size=<small|normal|large> weight=<regular|medium|semibold|bold>
      tone=<tone> wrap=<bool> max-lines=<n> align=<left|center|right>
      for=<id> level=<1..6>
textfield value="..." input=<text|number|email|tel|url|search> label="..."
          placeholder="..." icon="name" icon-right="name" icon-tone=<tone>
          required disabled readonly invalid max-length=<n>
textarea value="..." rows=<n> label="..." placeholder="..."
         icon="name" icon-right="name" icon-tone=<tone> disabled invalid
date value="YYYY-MM-DD" min="..." max="..." label="..." icon="name" icon-right="name"
time value="HH:MM" min="..." max="..." step=<n> label="..."
date-range start="YYYY-MM-DD" end="YYYY-MM-DD" min="..." max="..." label="..."
password value="..." revealed=<bool> label="..." placeholder="..." icon="name"
dropdown value="..." options="Label=value|Label=value" label="..." placeholder="..."
checkbox "label" checked disabled tone=<tone>
radio "label" value="..." checked disabled tone=<tone>
switch "label" checked disabled tone=<tone>
slider value=<n> min=<n> max=<n> step=<n|any> tone=<tone> show-value=<bool>
icon "name" size=<n> tone=<tone> label="..."
tag "text" tone=<tone> size=<small|normal> icon="name"
badge "text" tone=<tone>
button "text" variant=<primary|secondary|outline|ghost|danger> size=<small|normal|large>
       tone=<tone> icon="name" icon-right="name" align=<left|center|right>
       disabled default label="..."
list-item "title" description="..." icon="name" icon-tone=<tone>
          badge="text" badge-tone=<tone> selected disabled
progress value=<0..100> tone=<tone> show-value=<bool> indeterminate=<bool>
spinner size=<n> tone=<tone> label="..."
skeleton shape=<line|circle|rect> lines=<n> animated=<bool> label="..."
divider orientation=<horizontal|vertical> thickness=<n> color=<color> inset=<spacing>
spacer
image src="..." alt="..." fit=<cover|contain> aspect=<free|1:1|4:3|3:2|16:9|21:9>
avatar src="..." initials="..." alt="..." size=<n> shape=<circle|rounded>
       status=<online|away|busy|offline> tone=<tone>
pagination page=<n> pages=<n> siblings=<n> show-first-last=<bool>
           show-prev-next=<bool> disabled label="..."
kbd "key" size=<small|normal> tone=<tone>
menu-item "label" icon="name" shortcut="..." tone=<tone> selected disabled
document-header "title" description="..." icon="name" icon-tone=<tone> level=<1..6>
```

### 11.5 Defaults

```text
Font:      system-ui, 16px base, 13px small, 20px large
Weights:   400 / 500 / 600 / 700
Spacing:   4px unit -> none 0, xs 4, s 8, m 12, l 16, xl 24
Radii:     6 / 10 / 14 / 20 / pill
Controls:  40px height; S/M inset; 44px touch target
Breakpoints: sm 640, md 900, lg 1200, xl 1440
Rows:      48px (40 dense); menu item 40px; pagination 32px
Modes:     light/dark; semantic info/success/alert/warning/error
Badges:    blue, purple, pink, teal, indigo, cyan, lime, gray
State:     focus ring 2px + 2px offset; hover 6%/8%; pressed 10%/12%
           disabled 50%; overlay scrollbars; 1/64px layout units
```
