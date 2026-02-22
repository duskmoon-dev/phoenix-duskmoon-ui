# SYNC_AUDIT.md — Three-Layer Sync Audit

> Generated: 2026-02-20
> Branch: v9
> Server: http://localhost:4600

---

## 1. Discovered Routes

### Demo Pages (`/components/*`)

| # | Route | HTTP | Custom Elements Found |
|---|-------|------|-----------------------|
| 1 | `/` | 200 | (layout only) |
| 2 | `/components/action/button` | 200 | el-dm-button, el-dm-dialog |
| 3 | `/components/action/link` | 200 | (layout only) |
| 4 | `/components/action/dropdown` | 200 | (layout only) |
| 5 | `/components/data-display/avatar` | 200 | (layout only) |
| 6 | `/components/data-display/badge` | 200 | el-dm-badge |
| 7 | `/components/data-display/card` | 200 | el-dm-button, el-dm-card |
| 8 | `/components/data-display/flash` | 200 | (layout only) |
| 9 | `/components/data-display/markdown` | 200 | el-dm-markdown |
| 10 | `/components/data-display/pagination` | 200 | el-dm-pagination |
| 11 | `/components/data-display/progress` | 200 | (layout only) |
| 12 | `/components/data-display/skeleton` | 200 | (layout only) |
| 13 | `/components/data-display/table` | 200 | (layout only) |
| 14 | `/components/data-display/tooltip` | 200 | el-dm-button |
| 15 | `/components/data-entry/checkbox` | 200 | (layout only) |
| 16 | `/components/data-entry/compact-input` | 200 | (layout only) |
| 17 | `/components/data-entry/form` | 200 | (layout only) |
| 18 | `/components/data-entry/input` | 200 | (layout only) |
| 19 | `/components/data-entry/radio` | 200 | (layout only) |
| 20 | `/components/data-entry/select` | 200 | (layout only) |
| 21 | `/components/data-entry/slider` | 200 | (layout only) |
| 22 | `/components/data-entry/switch` | 200 | (layout only) |
| 23 | `/components/data-entry/textarea` | 200 | (layout only) |
| 24 | `/components/feedback/dialog` | 200 | el-dm-button, el-dm-dialog |
| 25 | `/components/feedback/loading` | 200 | (layout only) |
| 26 | `/components/navigation/actionbar` | 200 | (layout only) |
| 27 | `/components/navigation/appbar` | 200 | (layout only) |
| 28 | `/components/navigation/breadcrumb` | 200 | el-dm-breadcrumbs |
| 29 | `/components/navigation/left-menu` | 200 | (layout only) |
| 30 | `/components/navigation/navbar` | 200 | (layout only) |
| 31 | `/components/navigation/page-footer` | 200 | (layout only) |
| 32 | `/components/navigation/page-header` | 200 | (layout only) |
| 33 | `/components/navigation/tab` | 200 | el-dm-tabs |
| 34 | `/components/layout/divider` | 200 | (layout only) |
| 35 | `/components/layout/theme-switcher` | 200 | (layout only) |
| 36 | `/components/icon/icons` | 200 | (layout only) |
| 37 | `/components/fun/button-noise` | 200 | (layout only) |
| 38 | `/components/fun/eclipse` | 200 | (layout only) |
| 39 | `/components/fun/plasma-ball` | 200 | (layout only) |
| 40 | `/components/fun/signature` | 200 | (layout only) |
| 41 | `/components/fun/snow` | 200 | (layout only) |
| 42 | `/components/fun/spotlight-search` | 200 | (layout only) |

**Note**: "(layout only)" means the page uses el-dm-breadcrumbs, el-dm-card, el-dm-markdown as part of the demo page layout wrapper, not for the component being demonstrated.

### Storybook Routes (`/storybook/*`)

44 stories registered via PhoenixStorybook at `/storybook/`.

---

## 2. Three-Layer Mapping Table

### Legend
- **Rendering**: How the Phoenix component renders
  - `CE` = Custom Element (`<el-dm-*>`)
  - `CSS` = Raw HTML + `@duskmoon-dev/core` CSS classes
  - `MIX` = Mixed (some variants use CE, others CSS)
- **Status**:
  - ✅ = Working, uses best available approach
  - ⚠️ = Works but has available custom element not yet adopted
  - ❌ = Missing in one or more layers

### Tier 1 — Core Actions & Input

| Core CSS | el-* Package | Phoenix Module | Function | Rendering | Status |
|----------|-------------|----------------|----------|-----------|--------|
| button | el-button | Action.Button | `dm_btn` | CE | ✅ |
| input | el-input | DataEntry.Input | `dm_input` | CSS | ⚠️ |
| card | el-card | DataDisplay.Card | `dm_card` | CE | ✅ |
| badge | el-badge | DataDisplay.Badge | `dm_badge` | CE | ✅ |
| alert | el-alert | DataEntry.Form | `dm_alert` | CE | ✅ |
| dialog | el-dialog | Feedback.Dialog | `dm_modal` | CE | ✅ |

### Tier 2 — Form Elements

| Core CSS | el-* Package | Phoenix Module | Function | Rendering | Status |
|----------|-------------|----------------|----------|-----------|--------|
| checkbox | — | DataEntry.Checkbox | `dm_checkbox` | CSS | ✅ |
| radio | — | DataEntry.Radio | `dm_radio` | CSS | ✅ |
| select | — | DataEntry.Select | `dm_select` | CSS | ✅ |
| textarea | — | DataEntry.Textarea | `dm_textarea` | CSS | ✅ |
| toggle | el-switch | DataEntry.Switch | `dm_switch` | CSS | ⚠️ |
| range | el-slider | DataEntry.Slider | `dm_slider` | CSS | ⚠️ |
| rating | — | DataEntry.Input | `dm_input(type: "rating")` | CSS | ✅ |
| file-input | el-file-upload | DataEntry.Input | `dm_input(type: "file_upload")` | CSS | ⚠️ |

### Tier 3 — Navigation

| Core CSS | el-* Package | Phoenix Module | Function | Rendering | Status |
|----------|-------------|----------------|----------|-----------|--------|
| navbar | el-navbar | Navigation.Navbar | `dm_navbar` | CSS | ⚠️ |
| menu | el-menu | Navigation.LeftMenu | `dm_left_menu` | CSS | ✅* |
| breadcrumbs | el-breadcrumbs | Navigation.Breadcrumb | `dm_breadcrumb` | CE | ✅ |
| tab | el-tabs | Navigation.Tab | `dm_tab` | CE | ✅ |
| pagination | el-pagination | DataDisplay.Pagination | `dm_pagination` | CE | ✅ |
| steps | el-stepper | Navigation.Steps | `dm_steps` | CE | ✅ |

*Left menu was deliberately migrated to CSS-only (`nested-menu` classes) in recent commits.

### Tier 4 — Data Display

| Core CSS | el-* Package | Phoenix Module | Function | Rendering | Status |
|----------|-------------|----------------|----------|-----------|--------|
| table | el-table | DataDisplay.Table | `dm_table` | CSS | ⚠️ |
| accordion | el-accordion | DataDisplay.Accordion | `dm_accordion` | CE | ✅ |
| avatar | — | DataDisplay.Avatar | `dm_avatar` | CSS | ✅ |
| stat | — | DataDisplay.Stat | `dm_stat` | CSS | ✅ |
| chip | el-chip | DataDisplay.Chip | `dm_chip` | CE | ✅ |
| — | el-markdown | DataDisplay.Markdown | `dm_markdown` | CE | ✅ |

### Tier 5 — Layout & Feedback

| Core CSS | el-* Package | Phoenix Module | Function | Rendering | Status |
|----------|-------------|----------------|----------|-----------|--------|
| drawer | el-drawer | Layout.Drawer | `dm_drawer` | CE | ✅ |
| toast | — | DataDisplay.Flash | `dm_flash` | CSS | ✅ |
| tooltip | el-tooltip | DataDisplay.Tooltip | `dm_tooltip` | CSS | ⚠️ |
| progress | el-progress | DataDisplay.Progress | `dm_progress` | CSS | ⚠️ |
| loading | — | Feedback.Loading | `dm_loading_spinner` | CSS | ✅ |
| divider | — | Layout.Divider | `dm_divider` | CSS | ✅ |

### Additional Components (Not in PRD tiers)

| Component | Phoenix Module | Function | Rendering | Status |
|-----------|---------------|----------|-----------|--------|
| link | Action.Link | `dm_link` | CSS | ✅ |
| dropdown | Action.Dropdown | `dm_dropdown` | CSS | ✅* |
| skeleton | DataDisplay.Skeleton | `dm_skeleton*` | CSS | ✅ |
| form | DataEntry.Form | `dm_form` | CSS | ✅ |
| compact_input | DataEntry.CompactInput | `dm_compact_input` | CSS | ✅ |
| appbar | Navigation.Appbar | `dm_appbar` | CSS | ✅ |
| actionbar | Navigation.Actionbar | `dm_actionbar` | CSS | ✅ |
| page_header | Navigation.PageHeader | `dm_page_header` | CSS | ✅ |
| page_footer | Navigation.PageFooter | `dm_page_footer` | CSS | ✅ |
| theme_switcher | Layout.ThemeSwitcher | `dm_theme_switcher` | CSS | ✅* |
| icons | Icon.Icons | `dm_mdi`, `dm_bsi` | CSS | ✅ |

*Dropdown and theme_switcher were recently migrated to CSS-only as a deliberate architecture choice.

---

## 3. Summary Statistics

| Metric | Count |
|--------|-------|
| Total Phoenix components | 41 files, ~55 functions |
| Using Custom Elements (CE) | 14 components |
| Using CSS-only (deliberately) | 25 components |
| Available CE but not adopted (⚠️) | 6 components |
| Missing Phoenix wrapper (❌) | 0 components |
| Installed el-* packages | 28 |
| Registered el-* packages | 28 (all) |
| Demo routes | 42 |
| Storybook stories | 44 |
| Tests | 3174 (all passing) |
| Compilation warnings | 0 |

---

## 4. Categorized Issues

### A. Missing Phoenix Wrappers (❌ — need creation)

1. ~~**Steps/Stepper**~~ — ✅ Created `dm_steps` wrapping `<el-dm-stepper>` (commit `06cc521`)
2. ~~**Accordion**~~ — ✅ Created `dm_accordion` wrapping `<el-dm-accordion>` (commit `06cc521`)
3. ~~**Drawer**~~ — ✅ Created `dm_drawer` wrapping `<el-dm-drawer>` (commit `06cc521`)
4. ~~**Stat**~~ — ✅ Created `dm_stat` as CSS-only component using Tailwind utilities + theme variables (no upstream CSS class needed)

### B. Available Custom Elements Not Yet Adopted (⚠️)

These components use raw HTML + CSS classes but have a corresponding `el-*` custom element available:

1. `dm_input` → could use `<el-dm-input>`
2. ~~`dm_alert`~~ → ✅ Migrated to `<el-dm-alert>` (commit `78fc0cf`)
3. `dm_switch` → could use `<el-dm-switch>`
4. `dm_slider` → could use `<el-dm-slider>`
5. `dm_navbar` → could use `<el-dm-navbar>`
6. `dm_table` → could use `<el-dm-table>` — **blocked** (see gap analysis below)
7. `dm_tooltip` → could use `<el-dm-tooltip>` — **blocked** (see gap analysis below)
8. `dm_progress` → could use `<el-dm-progress>` — **blocked** (see gap analysis below)
9. `dm_input(type: "file_upload")` → could use `<el-dm-file-upload>`

### B2. Migration Gap Analysis — Blocked Migrations

The following components have available custom elements but migration would lose features currently exposed by the Phoenix component API.

#### `dm_tooltip` → `el-dm-tooltip`
- **Missing from element**: `color` attribute (Phoenix supports primary/secondary/accent/info/success/warning/error)
- **Missing from element**: `open` attribute (Phoenix supports programmatic open state)
- **Impact**: Migrating would regress color theming and controlled display
- **Action needed**: File upstream issue on `duskmoon-dev/duskmoon-elements` requesting `color` and `open` attributes

#### `dm_progress` → `el-dm-progress`
- **Missing from element**: `accent` color variant
- **Missing from element**: `xs` size variant
- **Missing from element**: Custom label content (Phoenix renders slot text over progress bar)
- **Impact**: Migrating would lose small size option, accent color, and custom labels
- **Action needed**: File upstream issue on `duskmoon-dev/duskmoon-elements` requesting `accent` color, `xs` size, custom label slot

#### `dm_table` → `el-dm-table`
- **Fundamental API mismatch**: Phoenix `dm_table` uses LiveView slots (`:col`, `:action`) to declaratively render HTML table rows from Elixir data
- **Element API**: `el-dm-table` expects JSON `data` and `columns` attributes — incompatible with server-rendered HEEX templates
- **Impact**: Migration would completely break the existing API and require users to restructure their code
- **Action needed**: Not a migration candidate. The CSS-only approach is correct for this component.

#### `dm_navbar` → `el-dm-navbar`
- **Missing from element**: `aria-label` on inner Shadow DOM `<nav>` — accessibility regression
- **Missing from element**: Per-section class injection (`start_class`, `center_class`, `end_class`) — Shadow DOM containers can't receive arbitrary classes from host attrs
- **Slot name mismatch**: Phoenix `:start_part`/`:center_part`/`:end_part` vs element `slot="start"`/default/`slot="end"` — mechanical but breaking rename
- **Would gain**: `fixed` positioning, `elevated` shadow, `color` theming, responsive hamburger menu, `slot="mobile"` for mobile content
- **Action needed**: File upstream issues for `nav-label` attr and per-section class forwarding on `duskmoon-dev/duskmoon-elements`

#### `dm_switch` → `el-dm-switch` (form element)
- **Shadow DOM + `phx-change`**: LiveView's form bindings (`phx-change`, `phx-blur`, `phx-focus`) are placed on the host element, but the actual `<input>` lives inside Shadow DOM. LiveView's JS client may not intercept composed events from shadow DOM internals, breaking form interactivity.
- **Missing from element**: `xs` size, `accent`/`info`/`warning` colors, `multiple` name pattern, error display (`aria-invalid`, `aria-describedby`), `class`/`label_class`/`switch_class` customization
- **FormField integration**: CE has no concept of `Phoenix.HTML.FormField` — all field extraction must remain in the Phoenix wrapper
- **Action needed**: Not a migration candidate while Shadow DOM + LiveView incompatibility exists. File upstream issue on `duskmoon-dev/duskmoon-elements` requesting light DOM rendering mode for form elements.

#### `dm_slider` → `el-dm-slider` (form element)
- **Same Shadow DOM + LiveView blocker** as switch
- **Color palette severely reduced**: CE supports only 3 colors (`primary`/`secondary`/`tertiary`) vs Phoenix's 7
- **Missing from element**: `label` attr entirely, `xs` size, error display, min/max endpoint labels
- **Minimal benefit**: Phoenix wrapper must keep almost all outer HTML structure — CE only replaces the bare `<input type="range">`
- **Action needed**: Not a migration candidate. CSS-only is the correct approach for form inputs.

#### Form Elements — General Policy
All form input components (`dm_input`, `dm_switch`, `dm_slider`, `dm_select`, `dm_checkbox`, `dm_radio`, `dm_textarea`, `dm_compact_input`) should remain CSS-only because:
1. Shadow DOM encapsulation prevents LiveView's `phx-change`/`phx-blur` from working reliably
2. `Phoenix.HTML.FormField` integration requires direct access to the `<input>` element in light DOM
3. Error display (`aria-invalid`, `aria-describedby`, error message blocks) is a Phoenix-layer concern
4. The CSS-only approach with `@duskmoon-dev/core` classes provides full visual parity without these risks

#### New Component Created: `dm_chip`
- Wraps `<el-dm-chip>` custom element (commit `78fc0cf`)
- Supports variant (filled/outlined/soft), color (7 options), size (sm/md/lg), deletable, selected, disabled, icon slot

### C. Architecture Decision: CSS-Only vs Custom Elements

Recent commits show a deliberate move toward CSS-only for simpler components:
- Dropdown → native popover API + `@duskmoon-dev/core` CSS (commit `25aa69b`)
- Theme switcher → theme-controller CSS (commit `cff9701`)
- Left menu → nested-menu CSS (commit `e863fab`)

This dual strategy is valid: use custom elements for complex interactive components (button, card, dialog, tabs, breadcrumbs, pagination, markdown) and CSS classes for simpler ones (checkbox, radio, select, form, loading, divider, etc.).

### D. Console Errors

Previous audit found TypeError in dropdown's `dispatchConnected` — resolved by migration to native popover API.

Current baseline: **All 42 demo routes return HTTP 200.**

---

## 5. Recommended Priority Actions

### ~~High Priority~~ ✅ Done
1. ~~Create missing Phoenix wrapper: `dm_accordion`~~ ✅ (commit `06cc521`)
2. ~~Create missing Phoenix wrapper: `dm_drawer`~~ ✅ (commit `06cc521`)
3. ~~Create missing Phoenix wrapper: `dm_steps`~~ ✅ (commit `06cc521`)
4. ~~Migrate `dm_alert` to `<el-dm-alert>`~~ ✅ (commit `78fc0cf`)
5. ~~Create `dm_chip` wrapping `<el-dm-chip>`~~ ✅ (commit `78fc0cf`)

### Medium Priority — Requires Upstream Element Updates
6. Migrate `dm_tooltip` to `<el-dm-tooltip>` — **blocked**: element missing `color`, `open` attrs
7. Migrate `dm_progress` to `<el-dm-progress>` — **blocked**: element missing `accent`, `xs`, custom label
8. Migrate `dm_navbar` to `<el-dm-navbar>` — **blocked**: element missing `aria-label` on inner `<nav>`, no per-section class injection (`start_class`/`center_class`/`end_class`). Would gain responsive hamburger, color theming, scroll elevation.

### Medium Priority — Blocked by Shadow DOM + LiveView Form Incompatibility
9. `dm_switch` → `<el-dm-switch>` — **blocked**: Shadow DOM breaks `phx-change` bindings; also missing `xs` size, `accent`/`info`/`warning` colors, error display, `multiple` pattern
10. `dm_slider` → `<el-dm-slider>` — **blocked**: Shadow DOM breaks `phx-change` bindings; only 3 colors (vs 7); no label attr; no error display; minimal benefit since Phoenix wrapper must keep all outer HTML
11. `dm_input` → `<el-dm-input>` — **likely blocked**: same Shadow DOM + LiveView form binding concerns as switch/slider

### Low Priority
12. ~~Create `dm_stat` component~~ — ✅ Created as CSS-only
13. Do NOT migrate `dm_table` — API incompatible (see gap analysis above)
14. Evaluate `dm_input(type: "file_upload")` → `<el-dm-file-upload>`

---

## 6. Color Token Sync (Phase 2)

### Token Flow: Core → Phoenix CSS → Shadow DOM

```
@duskmoon-dev/core themes   →   :root [data-theme]   →   element-theme-bridge.css   →   Shadow DOM
(define --color-* values)        (applied to document)     (forces inherit on el-dm-*)     (inherits theme values)
```

### Gaps Found and Fixed

#### A. Missing `inherit` declarations (now bridged)
These theme tokens were defined in core but NOT bridged to custom elements:
- `--color-primary-container`, `--color-on-primary-container`
- `--color-secondary-container`, `--color-on-secondary-container`
- `--color-tertiary-container`, `--color-on-tertiary-container`
- `--color-surface-dim`, `--color-surface-bright`, `--color-surface-variant`
- `--color-surface-container-lowest`, `--color-surface-container-high`, `--color-surface-container-highest`
- `--color-inverse-surface`, `--color-inverse-on-surface`, `--color-inverse-primary`
- `--color-info-content`, `--color-on-info`, `--color-info-container`, `--color-on-info-container`
- `--color-success-content`, `--color-on-success`, `--color-success-container`, `--color-on-success-container`
- `--color-warning-content`, `--color-on-warning`, `--color-warning-container`, `--color-on-warning-container`
- `--color-error-content`, `--color-on-error`, `--color-error-container`, `--color-on-error-container`
- `--color-accent`, `--color-accent-content`
- `--color-neutral`, `--color-neutral-content`
- `--color-shadow`, `--color-scrim`

#### B. `--dm-*` namespace aliases (el-dm-table)
`el-dm-table` uses a `--dm-color-*` namespace instead of `--color-*`. Added aliases:
- `--dm-color-primary` → `var(--color-primary)` (and 8 more surface/outline vars)
- `--dm-radius-sm` → `var(--radius-sm)`, `--dm-radius-md` → `var(--radius-md)`

#### C. Non-standard variable aliases (el-dm-pagination, el-dm-bottom-navigation)
These elements use non-standard variable names with hardcoded fallbacks. Added aliases mapping to closest theme equivalents:
- `--color-border` → `var(--color-outline-variant)`
- `--color-border-hover` → `var(--color-outline)`
- `--color-surface-hover` → `var(--color-surface-container)`
- `--color-text` → `var(--color-on-surface)`
- `--color-text-muted` → `var(--color-on-surface-variant)`
- `--color-text-secondary` → `var(--color-on-surface-variant)`
- `--color-primary-contrast` → `var(--color-on-primary)`
- `--color-secondary-contrast` → `var(--color-on-secondary)`
- `--color-neutral-contrast` → `var(--color-neutral-content)`

#### D. Remaining upstream issues (cannot fix in phoenix-duskmoon-ui)
- `--color-primary-rgb` (RGB tuple) used by `el-file-upload` and `el-slider` — no OKLCH-to-RGB conversion available in CSS custom properties. Elements use hardcoded fallback `98, 0, 238`.
- `--color-primary-dark` used by `el-breadcrumbs` — falls back to `var(--color-primary)` which is acceptable.

---

## 7. Phase 4: Phoenix Component Sync — Attribute Gap Fixes

### Attrs Added (Additive Only)

| Component | New Attrs/Slots | Element Attr |
|-----------|----------------|--------------|
| `dm_markdown` | `src`, `theme`, `no_mermaid`, `rest` | `src`, `theme`, `no-mermaid` |
| `dm_modal` | `no_backdrop` | `no-backdrop` |
| `dm_badge` | `pill`, `dot` | `pill`, `dot` |
| `dm_card` / `dm_async_card` | `interactive`, `padding` | `interactive`, `padding` |
| `dm_btn` | `prefix` slot, `suffix` slot | `slot="prefix"`, `slot="suffix"` |
| `dm_pagination` | `el_size`, `el_color` | `size`, `color` |

### Variant Mismatches (Documented, NOT Fixed — Breaking Changes)

These components have fundamental variant/color mapping mismatches between the Phoenix API and the custom element API. Fixing them would be a breaking API change for Phoenix users.

#### `dm_badge` — variant vs color+variant split
- **Phoenix API**: `variant` = "primary" | "secondary" | "accent" | "info" | "success" | "warning" | "error" | "ghost" | "neutral"
- **Element API**: `color` = "primary" | "secondary" | "tertiary" | "success" | "warning" | "error" | "info"; `variant` = "filled" | "outlined" | "soft"
- **Current behavior**: Phoenix sends color names (e.g., "primary") via `variant` attr — element may interpret or ignore these
- **Phoenix `outline`** boolean maps conceptually to element `variant="outlined"` but is sent as a separate attr
- **Fix approach** (future v10): Split Phoenix `variant` into `color` + `style`, deprecate old API

#### `dm_card` — completely different variant vocabularies
- **Phoenix API**: `variant` = "compact" | "side" | "bordered" | "glass"
- **Element API**: `variant` = "elevated" | "outlined" | "filled"
- **No overlap**: The two variant sets describe different things (Phoenix = layout, element = surface style)
- **Fix approach** (future v10): Rename Phoenix `variant` to `layout`, add `style` for element's variant values

#### `dm_modal` — `dismissible` attr unusable from server-side
- **Element API**: `dismissible` is a boolean property defaulting to `true`
- **Lit boolean behavior**: Absent attribute = use property default (true). Cannot set to false via HTML attribute alone.
- **Workaround**: Users must use JavaScript to set `element.dismissible = false`
- **Action needed**: File upstream issue requesting a `no-dismiss` boolean attr (inverted pattern) or `dismiss-mode` string attr

### Tests Added

28 new tests covering all new attrs/slots across 6 test files. Total: **1841 tests, 0 failures**.

---

## 8. Verification Screenshots

See `.loki/logs/screenshots/` and `.loki/audit/screenshots/` for baseline screenshots.

---

## 9. Final Regression Results

### Iteration 2 Progress

- **Test coverage expansion**: Accordion 8→22, Steps 10→25, Drawer 11→23 tests (+41 total)
- **Storybook stories expanded**: Steps (5→11 variations, all 7 colors), Chip (8→16 variations, all colors/sizes)
- **Demo page improved**: Added modal drawer example with backdrop
- **Accessibility fixes**: Flash aria-live/atomic, Loading aria-live, Dropdown aria-expanded/controls, Rating aria-pressed, Password strength role=progressbar
- **Total tests**: 1841, 0 failures
- **Compilation warnings**: 0
- **Formatting**: Clean

### Iteration 5 Progress

- **Critical fix**: All custom elements now render with Shadow DOM (were previously inert)
  - Root cause: Stale `app.js.gz` from a past `mix phx.digest` run was served by `Plug.Static` with `gzip: true`. The old gzipped bundle predated all `el-dm-*` registrations.
  - Fix: Set `gzip: Mix.env() == :prod` in endpoint.ex; cleaned stale artifacts with `mix phx.digest.clean --all`
- **DevTools verified**: All 24 custom elements register correctly (`customElements.get()` returns class)
- **Shadow DOM verified**: Every `<el-dm-*>` on demo pages has `shadowRoot` with child nodes
- **Theme switching verified**: Sunshine ↔ Moonlight propagates into Shadow DOM (computed style changes confirmed)
- **Console errors**: 1 non-fatal D3/mermaid `CustomEvent` error (upstream in el-dm-markdown)
- **Orphan cleanup**: Removed stale `@gsmlg/lit` from node_modules (not a dependency)
- **Total tests**: 3174 (3171 + 3), 0 failures
- **Compilation warnings**: 0
- **Formatting**: Clean

### Phase 6 Regression (Iteration 5, continued — 2026-02-22)

#### 6a. Demo Routes — 39/39 Pass
All demo routes at `/components/{category}/{component}` return HTTP 200.
Custom elements render with Shadow DOM on all pages tested:
- Button: 21 el-dm-button (all Shadow DOM)
- Card: 9 el-dm-card (all Shadow DOM)
- Form: 16 alerts/cards/buttons (all Shadow DOM)
- Badge: 23 el-dm-badge (all Shadow DOM)
- Dialog: 5 el-dm-dialog + 11 el-dm-button (all Shadow DOM)
- Markdown: el-dm-markdown (Shadow DOM)
- Tab: 4 el-dm-tab (Shadow DOM)
- Pagination: el-dm-pagination (Shadow DOM)

#### 6b. Storybook Routes — 80/80 Pass (after fixes)
20 stories were returning 500 errors. Root causes and fixes:

| Category | Count | Root Cause | Fix Applied |
|----------|-------|-----------|-------------|
| Cross-module imports | 8 | Slot templates called dm_btn/dm_mdi/dm_bsi/dm_menu_item/dm_nested_menu_item without imports/0 | Added `def imports` callbacks |
| Wrong slot names | 2 | menu used `:item` slot (doesn't exist), popover used `:content` (doesn't exist) | Rewrote to match component slot API |
| Self-referencing imports | 11 | Stories imported their own function, conflicting with PhoenixStorybook auto-bind | Converted to `%VariationGroup{}` structs |
| Missing attr default | 2 | select.ex and textarea.ex: `attr(:value, :any)` without `default: nil` | Added default, changed `assign_new` to `assign` in FormField clause |

#### 6c. Console Errors
Only known upstream error on all pages:
```
Uncaught TypeError: Cannot read properties of undefined (reading 'CustomEvent')
```
D3/mermaid library — non-fatal, no functional impact.
**Zero CSS errors. Zero component JS errors.**

#### 6d. Theme Toggle Stress Test
Tested on button and card pages:
- Sunshine → Moonlight → Auto → Sunshine: all transitions immediate
- `data-theme` attribute and `localStorage` update correctly
- Auto mode removes `data-theme` attribute (correct)
- All custom elements retain Shadow DOM through rapid theme switching
- Theme persists across page navigation (localStorage)

#### 6e. Custom Element Registration
19 elements registered at startup:
el-dm-button, el-dm-card, el-dm-badge, el-dm-chip, el-dm-alert,
el-dm-dialog, el-dm-drawer, el-dm-dropdown, el-dm-input, el-dm-loading,
el-dm-markdown, el-dm-menu, el-dm-pagination, el-dm-popover,
el-dm-progress, el-dm-rating, el-dm-select, el-dm-tab, el-dm-tooltip

#### 6f. Automated Tests
```
mix compile --warnings-as-errors  → 0 warnings
mix format --check-formatted      → clean
mix test                          → 3171 tests, 0 failures
```

#### 6g. Phase 6 Commit
- `7b9741a6` — fix: resolve 20 storybook story 500 errors and add value defaults to select/textarea

---

## 7. Iteration 6 — Accessibility Audit & Improvements

### 7a. Full Accessibility Audit (62 components)

| Category | Components Audited | No Issues | Minor (Fixed) | Upstream |
|----------|-------------------|-----------|---------------|----------|
| Action | 5 | 5 | 0 | 0 |
| Data Display | 14 | 12 | 0 | 2 (badge, popover) |
| Data Entry | 18 | 18 | 0 | 0 |
| Feedback | 5 | 5 | 0 | 0 |
| Navigation | 11 | 8 | 2 (appbar, footer) | 1 (bottom_nav) |
| Layout | 5 | 5 | 0 | 0 |
| Icon | 2 | 2 | 0 | 0 |
| Fun | 2 | 2 | 0 | 0 |
| **Total** | **62** | **57** | **2** | **3** |

### 7b. Fixes Applied

1. **dm_appbar**: Added `<nav aria-label={@nav_label}>` wrapper around menu links (consistent with `dm_simple_appbar`)
2. **dm_page_footer**: Added optional `label` attr for `aria-label` on `<footer>` element

### 7c. Upstream Issues Identified

| Component | Custom Element | Missing ARIA | Priority |
|-----------|---------------|-------------|----------|
| dm_accordion | el-dm-accordion | aria-expanded, aria-controls, role="region" | High |
| dm_bottom_nav | el-dm-bottom-navigation | role="navigation", aria-label | High |
| dm_badge | el-dm-badge | role="status", aria-label | Medium |
| dm_popover | el-dm-popover | aria-expanded, aria-haspopup | Medium |
| dm_chip | el-dm-chip | role="option" (in selection context) | Low |
| dm_card | el-dm-card | role="article" (when interactive) | Low |

### 7d. assign_new Pitfall Verification

All 16 form components verified:
- 7 components with `assign_new(:name, ...)`: use `attr(:name, :any)` (no default) → **correct**
- 9 components with `assign(:name, field.name)`: use `attr(:name, :string, default: nil)` → **correct**
- **No instances of the assign_new + default: nil pitfall found**

### 7e. Regression Results
```
mix compile --warnings-as-errors  → 0 warnings
mix format --check-formatted      → clean
mix test                          → 3179 tests, 0 failures (+5 new accessibility tests)
```

---

## 8. Iteration 7 — Upstream Accessibility Issues & Storybook Completeness

### 8a. Upstream Accessibility Issues Filed

All 6 upstream accessibility issues from the iteration 6 audit have been filed on `duskmoon-dev/duskmoon-elements`:

| # | GitHub Issue | Component | Missing ARIA | Priority |
|---|-------------|-----------|-------------|----------|
| #9 | [el-dm-accordion: ARIA attributes](https://github.com/duskmoon-dev/duskmoon-elements/issues/9) | dm_accordion | aria-expanded, aria-controls, role="region" | High |
| #10 | [el-dm-bottom-navigation: navigation role](https://github.com/duskmoon-dev/duskmoon-elements/issues/10) | dm_bottom_nav | role="navigation", aria-label | High |
| #11 | [el-dm-badge: status role](https://github.com/duskmoon-dev/duskmoon-elements/issues/11) | dm_badge | role="status", aria-label | Medium |
| #12 | [el-dm-popover: ARIA state attrs](https://github.com/duskmoon-dev/duskmoon-elements/issues/12) | dm_popover | aria-expanded, aria-haspopup | Medium |
| #13 | [el-dm-chip: option role](https://github.com/duskmoon-dev/duskmoon-elements/issues/13) | dm_chip | role="option" (selection context) | Low |
| #14 | [el-dm-card: article role](https://github.com/duskmoon-dev/duskmoon-elements/issues/14) | dm_card | role="article" (when interactive) | Low |

Previously filed migration-blocker issues (#3–8) remain open.

### 8b. Button Storybook Expanded

The button storybook now covers all PRD-required variants (Section 4b requirement: "Story must show all color variants, all sizes, all style variants, disabled/loading states"):

| Group | Variations Added |
|-------|-----------------|
| Color variants | primary, secondary, **tertiary**, accent, info, success, warning, error |
| Style variants | ghost, outline, link |
| Sizes | xs, sm, md, lg (all four sizes now shown) |
| Shapes | square, circle |
| States | loading, disabled |
| Slots | prefix, suffix |
| Confirm dialog | basic, custom action |
| Noise | decorative noise button |

### 8c. Regression Results
```
mix compile --warnings-as-errors  → 0 warnings
mix format --check-formatted      → clean
mix test                          → 3179 tests, 0 failures
```

---

## 9. Iteration 8 — Comprehensive Storybook Coverage Expansion

### 9a. Scope

Systematic coverage audit of all storybook stories against component `attr` declarations. Identified stories with missing `values:` demonstrations and uncovered boolean attrs.

### 9b. Stories Expanded (8 commits)

| Story | Key Additions |
|-------|--------------|
| `badge` | `pill` shape, `dot` indicator |
| `card` | `compact`, `side`, `bordered`, `glass` variants; `shadow` (sm/xl); `padding` (none/lg) |
| `progress` | `striped`, `striped+animated`, `inline_label` |
| `tab` | `lifted`, `bordered` variants; `xs`, `sm`, `lg` sizes |
| `dropdown` | `position: "top"` |
| `stat` | `tertiary` color; `icon` slot |
| `dialog` | `position` (top/middle/bottom); `size` (xs/lg/xl); `backdrop`, `hide_close`, `responsive` |
| `collapse` | `color` (secondary/tertiary/accent); `size` (sm/lg); `animation` (fade/slide/fast/slow); `nested`, `disabled` |
| `stepper` | `variant` (dots/alt-labels/icons); `color` (secondary/tertiary/accent); `size` (sm/lg); `clickable`; `disabled`/`optional` step states |
| `switch` | `xl` size; `tertiary`, `info` colors |
| `checkbox` | `xl` size; `tertiary`, `info` colors; `indeterminate` |
| `bottom_nav` | All 4 remaining colors (secondary/success/warning/error); `sticky` position |
| `popover` | `focus` trigger; `open` state; cardinal placements (top/left/right); start/end aligned placements |
| `timeline` | `right`, `horizontal` layouts; `sm`, `lg` sizes; `loading` item state |
| `toggle` | `color` (secondary/tertiary/accent); `size` (sm/lg); `vertical`; `exclusive`; `full` |
| `divider` | `sm`, `xl` sizes; `gradient`; `inset` (left/right/both); `text_position` (left/right) |
| `steps` | `accent` color |
| `list` | `compact`, `dense`, `two_line`, `three_line` |
| `bottom_sheet` | `persistent` |
| `left_menu` | Remove invalid `horizontal` attr; `xs`, `sm`, `lg` size group |
| `menu` | `placement` group (top/bottom/right/bottom-end) |

### 9c. Regression Results
```
mix compile --warnings-as-errors  → 0 warnings
mix format --check-formatted      → clean
mix test                          → 3179 tests, 0 failures
```

---

## 10. Iteration 9 — PRD Browser Verification via Chrome DevTools MCP

### 10a. Theme Toggle Verification (PRD §4d)

Verified on `/storybook/action/button`:

| Token | Sunshine | Moonlight |
|-------|----------|-----------|
| `--color-primary` | `oklch(72% 0.17 75)` | `oklch(85.45% 0 0)` |
| `--color-surface` | `oklch(100% 0 0)` | `oklch(20% 0.02 260)` |
| `--color-on-surface` | `oklch(27% 0.02 260)` | `oklch(95% 0.01 260)` |

Shadow DOM inherited correctly: `el-dm-button` `shadowBg = oklch(0.8545 0 0)` matched `--color-primary` in moonlight ✅

Theme restored to sunshine: tokens matched baseline ✅

### 10b. Color Token Inventory (PRD §1.7)

Resolved on `document.documentElement` (sunshine theme):

| Token | Value |
|-------|-------|
| `--color-primary` | `oklch(72% 0.17 75)` |
| `--color-secondary` | `oklch(62% 0.19 20)` |
| `--color-tertiary` | `oklch(80% 0.085 235)` |
| `--color-accent` | `oklch(85.23% 0.14 327)` |
| `--color-info` | `oklch(41.94% 0.114 254.39)` |
| `--color-success` | `oklch(67.21% 0.19 133.55)` |
| `--color-warning` | `oklch(68.19% 0.203 42.44)` |
| `--color-error` | `oklch(61.17% 0.237 28.15)` |
| `--color-neutral` | `oklch(0% 0 0)` |
| `--color-surface` | `oklch(100% 0 0)` |
| `--color-surface-container` | `oklch(97% 0.01 85)` |
| `--color-on-surface` | `oklch(27% 0.02 260)` |
| `--color-on-primary` | `oklch(1 0 0)` |
| `--color-on-secondary` | `oklch(1 0 0)` |
| `--color-on-tertiary` | `oklch(1 0 0)` |
| `--color-on-error` | `oklch(1 0 0)` |
| `--color-shadow` | `oklch(0% 0 0)` |
| `--color-primary-container` | `oklch(95% 0.035 95.91)` |
| `--color-secondary-container` | `oklch(94% 0.05 87.01)` |
| `--color-tertiary-container` | `oklch(95% 0.035 235)` |
| `--color-on-primary-container` | `oklch(25% 0.03 95.91)` |
| `--color-on-secondary-container` | `oklch(25% 0.05 87.01)` |
| `--color-on-tertiary-container` | `oklch(22% 0.012 235)` |

Not defined (not in core): `--color-on-accent`, `--color-on-info`, `--color-on-success`, `--color-on-warning`, `--color-border`, `--color-divider`, `--color-disabled`

### 10c. DOM Inspection Findings (PRD §4c)

| Route | Custom Elements | Shadow DOM | Notes |
|-------|----------------|------------|-------|
| `/storybook/action/button` | `el-dm-button`, `el-dm-dialog` (28 total) | ✅ | Shadow: `<button class="btn btn-primary" part="button">` |
| `/storybook/data_display/card` | `el-dm-card` (10 total) | ✅ | Shadow: `<div class="card" part="card">` with header/body/footer slots |
| `/storybook/feedback/dialog` | `el-dm-dialog`, `el-dm-button` | ✅ | |
| `/storybook/navigation/tab` | `el-dm-tabs` | ✅ | |
| `/storybook/layout/bottom_sheet` | `el-dm-bottom-sheet` | ✅ | |
| `/storybook/data_display/popover` | `el-dm-popover` | ✅ | |
| `/storybook/data_entry/input` | none (raw HTML) | N/A | Form elements use raw HTML + CSS classes by design |
| `/storybook/navigation/appbar` | none (raw HTML) | N/A | Uses `@duskmoon-dev/core` CSS classes directly |

### 10d. Console Audit (PRD §4b)

All pages: 2 pre-existing errors from PhoenixStorybook's LiveView bundle (`js-c70cba293ecc4b549eeb24312f2b2720`):
```
Uncaught TypeError: Cannot read properties of undefined (reading 'CustomEvent')
```
Source: PhoenixStorybook internal bundle — NOT our `app.js`. Not actionable.

### 10e. Route Health Scan

Full scan of **75 storybook routes** using HTTP response body analysis:
- ✅ 75/75 routes PASS (no `Exception`, `ArgumentError`, `KeyError`, `UndefinedFunctionError`)
- ❌ 0 failures

**One bug found and fixed during scan:**
- `/storybook/data_display/card` — `interactive_with_image` variation used `<:actions>` (plural) but component declares `slot(:action)` (singular). Fixed to `<:action>`.

### 10f. Regression Results
```
mix compile --warnings-as-errors  → 0 warnings
mix format --check-formatted      → clean
```

---

## 11. Iteration 8 (continued) — Functional Attr Coverage & Secondary Function Stories

### 11a. Route Health Scan (expanded)

Full scan of **122 routes** (80 storybook + 42 demo):
- ✅ 122/122 routes PASS
- ❌ 0 failures

### 11b. Stories Expanded (functional attrs)

| Story | Before | After | Key Additions |
|-------|--------|-------|---------------|
| `action/link` | 3 | 7 | Color variant group, navigate, patch, replace, method_delete, external |
| `data_display/markdown` | 3 | 6 | no_mermaid, dark theme, rich content |
| `data_display/flash` | 3 | 5 | custom_close_label, no_title |
| `data_display/table` | 3 | 5 | hover_zebra combo, minimal |
| `navigation/appbar` | 3 | 6 | active_menu, non_sticky, title_link, nav_label |
| `navigation/page_header` | 2 | 4 | active_menu, nav_label |
| `navigation/page_footer` | 3 | 5 | label (a11y), multi_section |
| `navigation/nested_menu` | 2 | 4 | sizes group, nav_label |
| `layout/drawer` | 4 | 6 | label (a11y), right_modal |
| `layout/bottom_sheet` | 3 | 5 | snap_points, label (a11y) |
| `navigation/breadcrumb` | 3 | 5 | custom_separator, nav_label |
| `navigation/navbar` | 3 | 5 | section_classes, nav_label |

### 11c. New Stories Created (secondary functions)

| Story | Component Function | Variations |
|-------|-------------------|------------|
| `navigation/simple_appbar` | `dm_simple_appbar` | 4 (default, active_menu, minimal, nav_label) |
| `feedback/snackbar_container` | `dm_snackbar_container` | 3 (bottom, top-right, bottom-left) |
| `feedback/toast_container` | `dm_toast_container` | 3 (top-right, bottom-center, top-left) |
| `data_display/collapse_group` | `dm_collapse_group` | 2 (default, with_class) |

### 11d. Test Coverage Additions (ARIA Accessibility)

| Component | Tests Added | What's Tested |
|-----------|-------------|---------------|
| `layout/drawer` | 3 | `role="dialog"` when modal, `aria-modal="true"` when modal, no `aria-modal` when not |
| `data_display/chip` | 2 | `aria-disabled="true"` when disabled, absent when not |
| `layout/bottom_sheet` | 2 | `aria-modal="true"` when modal, absent when not |
| `navigation/stepper` | 2 | `aria-disabled="true"` on disabled steps, absent otherwise |
| `data_display/accordion` | 2 | `aria-disabled="true"` on disabled items, absent on enabled |
| `data_display/collapse` | 4 | `aria-controls` linked to content id, absent when no id, `aria-disabled` when disabled/not |

### 11e. Console Error Verification (Chrome DevTools MCP)

Routes verified with zero additional errors:
- `/storybook/navigation/simple_appbar` — 2 pre-existing PhoenixStorybook errors only
- `/storybook/feedback/toast_container` — 2 pre-existing PhoenixStorybook errors only
- `/storybook/feedback/snackbar_container` — 2 pre-existing PhoenixStorybook errors only
- `/storybook/data_display/collapse_group` — 2 pre-existing PhoenixStorybook errors only
- `/storybook/layout/bottom_sheet` — 2 pre-existing PhoenixStorybook errors only

Pre-existing errors (PhoenixStorybook internal bundle, NOT our code):
```
Uncaught TypeError: Cannot read properties of undefined (reading 'CustomEvent')
```

### 11f. Story Description Coverage (Session 2)

Achieved **100% description coverage** across all 84 story files:

1. **Story-level descriptions**: Replaced 10 generic "A X element." descriptions with meaningful component summaries
2. **Missing descriptions**: Added `def description` to 9 stories that had none (chip, stat, 5 fun components, tab)
3. **Variation descriptions**: Added descriptions to 49+ variations across pagination (5), card (5), tooltip (10), dropdown (8), avatar (21), popover (5)

### 11g. Attr Coverage Tests (Session 2)

Added tests for 2 previously untested component attrs:
| Component | Attr | What's Tested |
|-----------|------|---------------|
| `data_entry/form` | `:as` | Server-side parameter grouping |
| `navigation/appbar` | `:title_to` | Renders title as link when set, plain div when nil |

### 11h. Storybook Story Expansions (Session 2)

- **Snackbar**: Added warning type, multiline layout, top-right position variations
- **Toast**: Added title, icon, show_close variations; restructured types as VariationGroup
- **Form grid / Fieldset**: Added variation descriptions

### 11i. Final Regression Results (Session 2)
```
mix compile --warnings-as-errors  → 0 warnings
mix format --check-formatted      → clean
mix test                          → 3195 tests, 0 failures
Storybook stories                 → 84 (100% with descriptions)
Demo routes                       → 42 (unchanged)
Console errors (our code)         → 0
```

---

## 12. Iteration 9 — Docker Fix, Test Expansion & Storybook Coverage

### 12a. Docker Build Fix

Docker build was failing 5 times due to `SECRET_KEY_BASE` missing during `mix release`:
- **Root cause**: Elixir 1.17's `mix release` evaluates `runtime.exs` during build, which requires SECRET_KEY_BASE
- **Fix**: Added `ARG SECRET_KEY_BASE=build-time-placeholder-replaced-at-runtime` to Dockerfile builder stage
- **Also fixed**: Tailwind version mismatch — updated download URL from 4.0.3 to 4.1.11 to match `config.exs`

### 12b. Test Coverage Expansion (+9 tests)

| Component | Tests Added | What's Tested |
|-----------|-------------|---------------|
| `navigation/nested_menu_item` | 3 | rest attrs passthrough, nil `to` link, default state (no active/disabled) |
| `data_entry/form_inline` | 2 | rest attrs passthrough, div element type |
| `data_entry/form_hint` | 2 | rest attrs passthrough, span element type |
| `data_entry/form_counter` | 2 | rest attrs passthrough, zero-value edge case |

### 12c. Storybook Coverage Expansion

| Story | Variations Added | Attrs Demonstrated |
|-------|-----------------|-------------------|
| `action/button` | 3 (confirm_customization group) | `confirm_text`, `cancel_text`, `show_cancel_action`, `confirm_dialog_label` |
| `feedback/snackbar` | 4 (color_types group) | `type: "primary"/"secondary"/"tertiary"/"dark"` |
| `data_display/progress` | 2 (label_customization group) | `label_text`, `complete_text` |

### 12d. Regression Results
```
mix compile --warnings-as-errors  → 0 warnings
mix format --check-formatted      → clean
mix test                          → 3207 tests, 0 failures (+12 from iteration 8)
Storybook stories                 → 84 (unchanged count, expanded variations)
Demo routes                       → 42 (unchanged)
```

---

## 13. Iteration 10 — Docker Optimization, Storybook Modifiers & Code Quality

### 13a. Docker Context Optimization

Created `.dockerignore` to reduce Docker build context from ~960MB to <10MB:
- Excluded: `_build/`, `deps/`, `node_modules/`, `.git/`, `.devenv*`, `.loki/`, `.trees/`, `.claude/`
- Also excluded: `*.png` screenshots, `package-lock.json`, `erl_crash.dump`

### 13b. Storybook Form-Integration Variations

Filled gaps where form-related storybook variations were missing:

| Story | Variations Added | Attrs Demonstrated |
|-------|-----------------|-------------------|
| `data_entry/checkbox` | 5 (horizontal, with_helper, with_errors, validation_states group) | `horizontal`, `helper`, `errors`, `state` |
| `data_entry/switch` | 5 (horizontal, with_helper, with_errors, validation_states group) | `horizontal`, `helper`, `errors`, `state` |
| `data_display/tooltip` | 3 (primary, secondary, tertiary) | `color` variants |
| `data_entry/compact_input` | 4 (with_helper, horizontal, validation_states group) | `helper`, `horizontal`, `state` |
| `data_entry/input` | 1 (with_errors) | `errors` list display |

### 13c. Code Quality — PageHeader Import Fix

Refactored `PhoenixDuskmoon.Component.Navigation.PageHeader`:
- Added `import PhoenixDuskmoon.Component.Icon.Icons` at module top
- Replaced 2 fully-qualified `<PhoenixDuskmoon.Component.Icon.Icons.dm_mdi ...>` calls with shorthand `<.dm_mdi ...>`
- Now consistent with Appbar, Pagination, and other icon-importing components

### 13d. Storybook Interactive Modifiers (15 stories)

Added `def modifiers` sections to 15 stories, enabling interactive attribute toggling in the storybook UI:

| Story | Modifiers Added |
|-------|----------------|
| `action/button` | variant, size, shape, loading, disabled |
| `data_display/badge` | variant, size, outline, soft, pill, dot |
| `data_display/chip` | variant, color, size, deletable, selected, disabled |
| `data_display/tooltip` | position, color, open |
| `data_display/progress` | type, color, size, striped, animated, indeterminate, show_label |
| `data_display/avatar` | size, shape, color, ring, online, offline |
| `data_display/card` | variant, shadow, padding, interactive |
| `data_display/collapse` | variant, color, size, animation, open, disabled |
| `data_entry/input` | size, color, variant, horizontal |
| `data_entry/compact_input` | size, color, variant, disabled, horizontal |
| `navigation/tab` | variant, size, orientation |
| `layout/divider` | orientation, variant, style, size, gradient |
| `feedback/dialog` | size, position, backdrop, no_backdrop, responsive, hide_close |
| `feedback/snackbar` | type, open, multiline |
| `feedback/toast` | type, filled, open, show_close |

**Total stories with modifiers**: 25 (was 10, added 15)

### 13e. Regression Results
```
mix compile --warnings-as-errors  → 0 warnings
mix format --check-formatted      → clean
mix test                          → 3207 tests, 0 failures (unchanged)
Storybook stories                 → 84 (unchanged count, expanded variations + modifiers)
Stories with modifiers             → 25 / 84 (~30%)
Demo routes                       → 42 (unchanged)
```
