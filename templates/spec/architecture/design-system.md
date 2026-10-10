# UI Design System

<!-- (X) Co-owned. origin: human | inferred -->

This is a default preset: a starting design system to adapt to the project, not a blank stub.
Projects without a UI may leave it as-is; projects with one refine it during the requirements loop.

A design system for application user interfaces (web, mobile, desktop).

It defines the shared tokens, rules and elements that apply across platforms; anything not
specified here is left to the platform's conventions and the implementer's judgment.

## Design principles

- modern, flat look
- minimalistic
- elegant, pristine look
- reduce lines wherever possible, but never at the cost of clarity, affordance or accessibility
- responsive layouting, adapting to small, medium and big screen sizes
- optimize typography wherever possible
- animate transitions (e.g. unselected/hover/selected) where possible
- use progressive loading techniques (e.g. placeholder mocks for items being loaded)
- prefer composing from the elements below over inventing new ones

## Foundations

Applies to everything below. Tokens map to the platform's native mechanism (CSS variables, Android resources, Swing `UIManager`, ...). All sizes are density-independent units taken from one small scale (e.g. a base of 4).

### Styling

The styling of all elements follows a configurable style definition (the design tokens below).
A **mode** is light or dark; a **theme** is a color palette (see Themes).
Every design element has a mode, chosen when defining the UI.
Elements inherit the mode of their parent, unless specified otherwise.

Typography:
- font-family: the font family to use for normal text
- code-font-family: the font family to use for code-styled text
- text-font-size: font size for normal text
- title-font-size: font size for titles (e.g. a document or panel title)
- title-font-weight: font weight for titles (plain|bold)
- header-font-size: font size for section headers
- header-font-weight: font weight for section headers (plain|bold)

Spacing:
- item-padding: padding size for items (one size, used for top/bottom/left/right)
- content-padding: padding size for content (one size, used for top/bottom/left/right)
- density: compact|comfortable; scales spacing and control heights platform-wide (default: comfortable)

Shape:
- border-width: width for borders, dividers and separators
- corner-radius: corner radius for rounded elements

Elevation:
- elevation-{low,medium,high}: shadow levels for raised surfaces (menus, popovers, dialogs)
- layering (bottom to top): base content, sticky headers, popovers/menus, dialogs/overlays, tooltips

Motion:
- motion-duration-{fast,normal,slow}: durations for transitions
- motion-easing: standard easing curve for transitions

Colors. Each role has a value per mode: the token is prefixed with `light-` or `dark-`
(e.g. `light-primary-color`, `dark-primary-color`); elements refer to the unprefixed role (`primary-color`).
Concrete values are chosen from the Reference palette (see below).
`info`, `success`, `alert`, `warn` and `error` are the semantic colors.
- primary-color: color reserved for selections and special parts of the application.
- on-primary-color: text/icon color placed on top of primary-color.
- text-color-primary: primary text color
- text-color-secondary: secondary text color
- background-color-sunken: recessed background (code, wells, scroll tracks, inset areas).
- background-color-primary: base/page background (the canvas).
- background-color-secondary: surface/container background (cards, panels, fields).
- background-color-tertiary: a surface nested inside another surface.
- background-color-elevated: overlay background (menus, popovers, dialogs); pair with `elevation-*`.
- border-color: borders, dividers and separators
- focus-color: focus indicator (must stay visible on all backgrounds)
- {hover,pressed,selected}-overlay-color: translucent overlay applied on interaction
- disabled-opacity: opacity applied to disabled elements
- badge-background-color-{info,success,alert,warn,error}: background colors for the semantic badges.
- badge-background-color-{01-09}: background colors for additional, content-driven badges.
- tag-background-color: neutral background for tags.
- {info,success,alert,warn,error}-foreground-color: foreground color for semantic text and icons.

Backgrounds form an elevation ladder: `sunken` → `primary` → `secondary` → `tertiary` →
`elevated`. Use the lowest step that fits, and express nesting by moving one step. In dark mode
surfaces grow lighter as they rise; in light mode cards sit on a tinted page and nested/inset
areas step to the nearer neutral.

Badge and tag labels are always white. Because they carry their own background, badge colors are
typically identical in light and dark mode. The semantic foreground colors are for status text
and icons, not for badges.

Every semantic color has a badge variant, colored by its meaning:
- info: a shade of blue
- success: a shade of green
- alert: a shade of yellow
- warn: a shade of orange
- error: a shade of red

The content-driven badges (01-09) need only be distinguishable from red (the error color).

All token values above are the reference values (one padding, one radius, and so on). Small
relative deviations (e.g. half or double a spacing step, or an adjusted type size/weight) are
allowed punctually where a layout needs them, but prefer the reference values.

### States

Every interactive element defines how it looks in these states; unspecified states inherit their base styling:
- default, hover, focus, pressed, selected, disabled, loading, error

### Accessibility

A hard floor, not optional:
- text contrast at least 4.5:1; UI elements and graphics at least 3:1
- always show a visible focus indicator (never remove it without a replacement)
- focus indicators appear for keyboard navigation only, not on pointer/touch interaction
- overlays trap focus while open and return it to the opener on close
- minimum pointer/touch target of about 44x44
- honor reduced-motion preferences
- full keyboard operability, with a logical focus order

### Layout

- start simple: a vertical stack or horizontal row covers most cases; reach for grids only for collections of similar items
- space siblings with one consistent gap taken from the spacing scale
- constrain content to a sensible max width and center it on large screens; go full-bleed only for media and tables
- keep gutter/column spacing equal to the spacing scale
- never nest scrollable areas; each view has one primary scroll direction
- let whitespace group related content before using borders or dividers

### Alignment

Alignment is intentional, not incidental: elements that repeat in a column share the same alignment lines.
- use one small alignment set per axis (start, center, end, stretch); do not mix within a repeated group
- repeated rows expose fixed leading and trailing slots: the leading slot (icon/badge/chevron) has a fixed width, and optional trailing content (badges, actions) aligns to the trailing edge
- text that repeats shares one common leading edge; numbers are right-aligned
- vertically center single-line rows; top-align rows whose content can wrap
- align through shared columns and the spacing scale, never through per-item ad-hoc offsets

### Responsive

- breakpoints: small, medium, large
- content first; collapse or relocate secondary actions on small screens
- grid column counts adapt to the breakpoints (fewer columns on smaller screens)
- never hide essential information or actions, relocate them instead

### Text handling

- single-line text that may not fit: truncate at the end with an ellipsis (`...`)
- multi-line text: wrap normally, breaking words only when a single word is too long
- bounded multi-line areas: clamp to a fixed number of lines, ending with an ellipsis rather than overflowing
- never clip text without an ellipsis indicating there is more
- keep the full text reachable where it is truncated (e.g. tooltip or detail view)
- identifiers and numbers: prefer truncation or scrolling over breaking them mid-token

## Reference palette

Brand, accent and semantic colors are chosen from this palette (Material Design, shades 50-900).
The standard theme's neutral surfaces, borders and text use a dedicated neutral scale (given in
the mapping below) rather than the palette. Badge labels are always white; the lighter semantic
shades (yellow, light-green, orange, red) are used as picked even where white falls below the
text-contrast floor.

| Color | 50 | 100 | 200 | 300 | 400 | 500 | 600 | 700 | 800 | 900 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| blue-gray | #eceff1 | #cfd8dc | #b0bec5 | #90a4ae | #78909c | #607d8b | #546e7a | #455a64 | #37474f | #263238 |
| gray | #fafafa | #f5f5f5 | #eeeeee | #e0e0e0 | #bdbdbd | #9e9e9e | #757575 | #616161 | #424242 | #212121 |
| brown | #efebe9 | #d7ccc8 | #bcaaa4 | #a1887f | #8d6e63 | #795548 | #6d4c41 | #5d4037 | #4e342e | #3e2723 |
| deep-orange | #fbe9e7 | #ffccbc | #ffab91 | #ff8a65 | #ff7043 | #ff5722 | #f4511e | #e64a19 | #d84315 | #bf360c |
| orange | #fff3e0 | #ffe0b2 | #ffcc80 | #ffb74d | #ffa726 | #ff9800 | #fb8c00 | #f57c00 | #ef6c00 | #e65100 |
| amber | #fff8e1 | #ffecb3 | #ffe082 | #ffd54f | #ffca28 | #ffc107 | #ffb300 | #ffa000 | #ff8f00 | #ff6f00 |
| yellow | #fffde7 | #fff9c4 | #fff59d | #fff176 | #ffee58 | #ffeb3b | #fdd835 | #fbc02d | #f9a825 | #f57f17 |
| lime | #f9fbe7 | #f0f4c3 | #e6ee9c | #dce775 | #d4e157 | #cddc39 | #c0ca33 | #afb42b | #9e9d24 | #827717 |
| light-green | #f1f8e9 | #dcedc8 | #c5e1a5 | #aed581 | #9ccc65 | #8bc34a | #7cb342 | #689f38 | #558b2f | #33691e |
| green | #e8f5e9 | #c8e6c9 | #a5d6a7 | #81c784 | #66bb6a | #4caf50 | #43a047 | #388e3c | #2e7d32 | #1b5e20 |
| teal | #e0f2f1 | #b2dfdb | #80cbc4 | #4db6ac | #26a69a | #009688 | #00897b | #00796b | #00695c | #004d40 |
| cyan | #e0f7fa | #b2ebf2 | #80deea | #4dd0e1 | #26c6da | #00bcd4 | #00acc1 | #0097a7 | #00838f | #006064 |
| light-blue | #e1f5fe | #b3e5fc | #81d4fa | #4fc3f7 | #29b6f6 | #03a9f4 | #039be5 | #0288d1 | #0277bd | #01579b |
| blue | #e3f2fd | #bbdefb | #90caf9 | #64b5f6 | #42a5f5 | #2196f3 | #1e88e5 | #1976d2 | #1565c0 | #0d47a1 |
| indigo | #e8eaf6 | #c5cae9 | #9fa8da | #7986cb | #5c6bc0 | #3f51b5 | #3949ab | #303f9f | #283593 | #1a237e |
| deep-purple | #ede7f6 | #d1c4e9 | #b39ddb | #9575cd | #7e57c2 | #673ab7 | #5e35b1 | #512da8 | #4527a0 | #311b92 |
| purple | #f3e5f5 | #e1bee7 | #ce93d8 | #ba68c8 | #ab47bc | #9c27b0 | #8e24aa | #7b1fa2 | #6a1b9a | #4a148c |
| pink | #fce4ec | #f8bbd0 | #f48fb1 | #f06292 | #ec407a | #e91e63 | #d81b60 | #c2185b | #ad1457 | #880e4f |
| red | #ffebee | #ffcdd2 | #ef9a9a | #e57373 | #ef5350 | #f44336 | #e53935 | #d32f2f | #c62828 | #b71c1c |

### Reference mapping (standard theme)

Suggested picks for the standard theme; additional themes may override them.

| Role | Light | Dark |
| --- | --- | --- |
| primary-color | blue 600 `#1e88e5` | blue 300 `#64b5f6` |
| on-primary-color | white `#ffffff` | blue-gray 900 `#263238` |
| text-color-primary | `#1f2328` | `#e6edf3` |
| text-color-secondary | `#59636e` | `#8b949e` |
| background-color-sunken | `#eaeef2` | `#010409` |
| background-color-primary | `#f6f8fa` | `#0d1117` |
| background-color-secondary | `#ffffff` | `#161b22` |
| background-color-tertiary | `#f0f3f6` | `#1c2128` |
| background-color-elevated | `#ffffff` | `#21262d` |
| border-color | `#d0d7de` | `#30363d` |
| focus-color | blue 600 `#1e88e5` | blue 300 `#64b5f6` |

Semantic colors and their badge background. Badge labels are always white; the lighter shades
(yellow, light-green, orange, red) are used as picked even though white falls below the
text-contrast floor on them:

| Semantic | Badge background (white text) |
| --- | --- |
| info | blue 700 `#1976d2` |
| success | light-green 600 `#7cb342` |
| alert | yellow 600 `#fdd835` |
| warn | orange 600 `#fb8c00` |
| error | red 600 `#e53935` |

Content-driven badge backgrounds (700 shades; only required to be distinguishable from red):
purple `#7b1fa2`, indigo `#303f9f`, light-blue `#0288d1`, cyan `#0097a7`, green `#388e3c`,
teal `#00796b`, lime `#afb42b`, orange `#f57c00`, amber `#ffa000`. Neutral tag background:
gray 800 `#424242`.

Each semantic color also has a `*-foreground-color` for status text and icons; pick it per mode
so it contrasts with the surface it sits on (e.g. red 700 on light, red 200 on dark).

## Themes

Support for color themes, with at least one standard theme, and optionally additional ones.
The standard theme defines all the styling values.
Themes are always bundled resources.
Additional themes extend the standard theme or another theme, and can override styling values (typically the colors only).

Example: Standard Theme > Theme "Adwaita" (extends Standard) > Theme "Adwaita Orange" (extends Adwaita).

## Icons

Vector icons are used, from a single consistent set (one visual style, one nominal grid and stroke weight).
- icons are drawn on a nominal grid (e.g. 24) and used at a small set of sizes (e.g. 16, 20, 24) matched to text sizes
- icons inherit the current text color, so they adapt to mode and theme automatically
- size icons relative to the surrounding text and align them optically with it
- an icon that acts as a control needs an accessible name (its action description serves as it)

## Design elements

### Tags and Badges

Badges are short labels with a background color and only minimally rounded corners (`corner-radius`), used to categorize content, indicate status, or highlight items.
Badge labels are always white.
Badges come in different colors based on the usage / semantic.
The semantic variants (info/success/alert/warn/error) follow their semantic color (blue/green/yellow/orange/red).
Content-driven badge colors need only be distinguishable from red (the error color).
Tags are the neutral variant (a neutral background, still with white text), usually used to categorize items only.

### Split views

Horizontal or vertical split views, with content areas and slideable dividers.
Panes have a minimum size. The divider is borderless, shows a subtle highlight on hover/focus,
and is also operable with the keyboard for accessibility.

### Lists and list items

Lists are vertical lists with list items which fill the full width.
Lists can be scrolled with the mouse scroll wheel, or with the scroll bar (only visible when the list has more items than can be displayed in the list's viewport).

List items have:
- an optional icon on the left (either a specific icon, or a badge with two characters)
- a title, in the primary text color
- a description, in the secondary text color

List alignment:
- the leading slot (icon or badge) has the same fixed width for every item, so all titles share one vertical alignment line
- title and description share the same leading text edge
- optional trailing content (e.g. a badge or an action) aligns to the trailing edge
- leading and trailing accessories are vertically centered against the text

### Trees

Expandable tree of items. The root node is conceptual only and not displayed, the tree content starts with the children of the root node.
By default, the first two levels of the tree are expanded, unless stated otherwise.
Non-leaf nodes have a chevron indicating if the node is expanded (chevron pointing down) or not (chevron pointing right).

Tree alignment:
- each level is exactly one indent step (from the spacing scale) deeper than its parent
- the expand chevron occupies a fixed leading slot; leaf items reserve the same slot so their icons and labels align with sibling non-leaf nodes at the same level
- icons and labels share one column per level

### Action Buttons

Action buttons can have an icon, a short text, or both. Actions have a description, shown as hover text (with an equivalent available on touch devices).

### Action Bars

Horizontal or vertical action bars, with borderless action buttons and minimal spacing.

### Documents

Documents have (from top to bottom): a title, subtitle, content, and optional footer.
All these elements scale horizontally.
Only the content scales vertically, and is scrollable (vertically only).

### Forms

Forms are documents, with a title, optional subtitle, content and optional footer.

Forms have input elements, which may be pre-populated.

Input elements can be decorated with a label, with following variants:
- label as independent element
- floating label in the input element

Common input elements (start from these before inventing others):
- text field (single-line)
- text area (multi-line)
- numeric field
- search field
- select / dropdown
- checkbox
- radio group
- switch / toggle
- slider
- date / time picker

Input constraints:
- every input has a visible label; a placeholder is a hint, never a label
- inputs reflect the States set above (notably focus, disabled and error)
- prefer the platform's native control and conventions where they exist

### Dialogs

Dialogs are shown as pop-up modals.
Dialogs are documents (title, subtitle, content, footer).
Action buttons for the forms are in the footer, right-aligned.
One of the actions can be the default action that is initially highlighted, and pressing enter will execute the action.
Dialog buttons come in following variants:
- OK, Cancel
- Yes, No, Cancel
- {specific actions}, Cancel

### Menus and navigation

Navigation is persistent (tabs, navigation rail, sidebar) or transient (menu, context menu).
- breadcrumbs show the current location; pagination moves through a paged collection
- the active location uses the selected state and the primary color
- menus are transient, keyboard-navigable and dismissed by Escape or an outside click

### Data display

- tables and data grids have a header row, and support sorting and selection; columns may be
  resizable; numbers are right-aligned
- cards and KPI/stat tiles group related values; description lists show key-value pairs
- tables and grids are the only elements allowed to scroll horizontally, and only when needed

### Feedback and states

- progress: a determinate bar for known progress, an indeterminate spinner otherwise; show
  skeleton placeholders while content loads
- transient feedback: toasts/snackbars for brief confirmations; inline banners/alerts for
  persistent messages (using the semantic colors)
- empty, loading and error states are first-class: every view and collection defines them

### Overlays

- beyond dialogs: drawer/sheet (a side panel), popover (anchored and transient), tooltip
  (hover or long-press; never the only source of essential information)
- overlays stack above content using the layering order, and are dismissed by Escape/back, an
  outside click (menus/popovers) or an explicit action (dialogs)
