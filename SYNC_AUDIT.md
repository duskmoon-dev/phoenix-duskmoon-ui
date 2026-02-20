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
| alert | el-alert | DataEntry.Form | `dm_alert` | CSS | ⚠️ |
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
| steps | el-stepper | — | — | — | ❌ |

*Left menu was deliberately migrated to CSS-only (`nested-menu` classes) in recent commits.

### Tier 4 — Data Display

| Core CSS | el-* Package | Phoenix Module | Function | Rendering | Status |
|----------|-------------|----------------|----------|-----------|--------|
| table | el-table | DataDisplay.Table | `dm_table` | CSS | ⚠️ |
| accordion | el-accordion | — | — | — | ❌ |
| avatar | — | DataDisplay.Avatar | `dm_avatar` | CSS | ✅ |
| stat | — | — | — | — | ❌ |
| — | el-markdown | DataDisplay.Markdown | `dm_markdown` | CE | ✅ |

### Tier 5 — Layout & Feedback

| Core CSS | el-* Package | Phoenix Module | Function | Rendering | Status |
|----------|-------------|----------------|----------|-----------|--------|
| drawer | el-drawer | — | — | — | ❌ |
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
| Using Custom Elements (CE) | 8 components |
| Using CSS-only (deliberately) | 25 components |
| Available CE but not adopted (⚠️) | 9 components |
| Missing Phoenix wrapper (❌) | 4 components |
| Installed el-* packages | 28 |
| Registered el-* packages | 28 (all) |
| Demo routes | 42 |
| Storybook stories | 44 |
| Tests | 1704 (all passing) |
| Compilation warnings | 0 |

---

## 4. Categorized Issues

### A. Missing Phoenix Wrappers (❌ — need creation)

1. **Steps/Stepper** — `el-dm-stepper` registered but no Phoenix `dm_steps` wrapper
2. **Accordion** — `el-dm-accordion` registered but no Phoenix `dm_accordion` wrapper
3. **Drawer** — `el-dm-drawer` registered but no Phoenix `dm_drawer` wrapper
4. **Stat** — No custom element, no Phoenix wrapper (PRD lists it)

### B. Available Custom Elements Not Yet Adopted (⚠️)

These components use raw HTML + CSS classes but have a corresponding `el-*` custom element available. Migration decision needed per component:

1. `dm_input` → could use `<el-dm-input>`
2. `dm_alert` → could use `<el-dm-alert>`
3. `dm_switch` → could use `<el-dm-switch>`
4. `dm_slider` → could use `<el-dm-slider>`
5. `dm_navbar` → could use `<el-dm-navbar>`
6. `dm_table` → could use `<el-dm-table>`
7. `dm_tooltip` → could use `<el-dm-tooltip>`
8. `dm_progress` → could use `<el-dm-progress>`
9. `dm_input(type: "file_upload")` → could use `<el-dm-file-upload>`

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

### High Priority
1. Create missing Phoenix wrapper: `dm_accordion` (wrapping `<el-dm-accordion>`)
2. Create missing Phoenix wrapper: `dm_drawer` (wrapping `<el-dm-drawer>`)
3. Create missing Phoenix wrapper: `dm_steps` (wrapping `<el-dm-stepper>`)

### Medium Priority
4. Evaluate migration of `dm_tooltip` to `<el-dm-tooltip>` (Shadow DOM would enable better theming)
5. Evaluate migration of `dm_progress` to `<el-dm-progress>`
6. Evaluate migration of `dm_table` to `<el-dm-table>`

### Low Priority
7. Create `dm_stat` component (no custom element available — CSS-only)
8. Evaluate form element migrations (input, switch, slider — CSS-only may be better for form integration)

---

## 6. Verification Screenshots

See `.loki/logs/screenshots/` and `.loki/audit/screenshots/` for baseline screenshots.

---

## 7. Final Regression Results

_To be updated after component migrations._
