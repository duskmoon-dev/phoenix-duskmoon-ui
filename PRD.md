# PRD: Sync @duskmoon-dev/core → phoenix-duskmoon-ui (via duskmoon-elements)

> **Mode**: Claude Code — Loki (`--dangerously-skip-permissions`)
> **Repos**:
>   - `duskmoon-dev/duskmoonui` — CSS source of truth (`@duskmoon-dev/core`)
>   - `duskmoon-dev/duskmoon-elements` — Custom elements (`@duskmoon-dev/el-*`)
>   - `duskmoon-dev/phoenix-duskmoon-ui` — Phoenix wrapper (hex: `phoenix_duskmoon`)
> **Status**: Draft
> **Priority**: High

---

## 1. Architecture: Three-Layer Model

```
┌─────────────────────────────────────────────────────┐
│  @duskmoon-dev/core (Tailwind plugin)               │
│  Source of truth: color tokens, themes, CSS classes  │
│  Plugin entry: @plugin "@duskmoon-dev/core/plugin"  │
└──────────────────────┬──────────────────────────────┘
                       │ consumed by
                       ▼
┌─────────────────────────────────────────────────────┐
│  @duskmoon-dev/el-* (Custom Elements)               │
│  <el-dm-button>, <el-dm-input>, <el-dm-card>, ...   │
│  Shadow DOM + BaseElement + DuskMoonUI CSS tokens    │
│  Rendering layer — framework-agnostic                │
└──────────────────────┬──────────────────────────────┘
                       │ wrapped by
                       ▼
┌─────────────────────────────────────────────────────┐
│  phoenix_duskmoon (Elixir/Phoenix)                  │
│  Phoenix.Component functions → <el-dm-*> tags       │
│  LiveView bridge: WebComponentHook                  │
│  darkmoon-send-* / darkmoon-receive-* attrs         │
│  Demo/Storybook: phoenix_storybook_web (port 4600)  │
└─────────────────────────────────────────────────────┘
```

**Key principle**: Phoenix components emit `<el-dm-*>` custom element tags. The custom element owns Shadow DOM rendering. Phoenix owns the LiveView bridge.

---

## 2. Objective

Synchronize component definitions from `@duskmoon-dev/core` through `@duskmoon-dev/el-*` custom elements into `phoenix-duskmoon-ui`, using Chrome DevTools MCP as the primary feedback loop for every verification step.

---

## 3. Prerequisites

### Environment
- All three repos cloned locally
- `devenv` shell active for phoenix-duskmoon-ui
- Bun available for duskmoon-elements builds
- Chrome DevTools MCP connected

### Pinned Paths & URLs
```bash
CORE_SRC=~/duskmoonui/packages/core/src
ELEMENTS_SRC=~/duskmoon-elements/elements
ELEMENTS_CORE=~/duskmoon-elements/packages/core
PHOENIX_SRC=~/phoenix-duskmoon-ui/apps
DEMO_URL=http://localhost:4600
STORYBOOK_URL=http://localhost:4600/storybook
```

### Phoenix Umbrella App Structure
```
phoenix-duskmoon-ui/
├── apps/
│   ├── phoenix_duskmoon/           # Library package (published to hex)
│   │   └── lib/phoenix_duskmoon/
│   │       ├── component/          # Phoenix.Component wrappers
│   │       └── ...
│   └── phoenix_storybook_web/      # Demo & Storybook app (port 4600)
│       └── lib/phoenix_storybook_web/
│           ├── storybook/          # Storybook stories
│           └── ...
├── config/
├── mix.exs                         # Umbrella root
└── package.json
```

### Startup Sequence
```bash
# 1. Build core CSS plugin
cd ~/duskmoonui && bun run build:core

# 2. Build all custom elements
cd ~/duskmoon-elements && bun run build:all

# 3. Start Phoenix dev server (includes storybook on port 4600)
cd ~/phoenix-duskmoon-ui && mix phx.server &

# 4. Wait for server ready, then connect DevTools MCP to http://localhost:4600
```

### CSS Import Chain (in Phoenix assets)
```css
@import "tailwindcss";
@plugin "@duskmoon-dev/core/plugin";
@import "phoenix_duskmoon/theme";
@import "phoenix_duskmoon/components";
```

---

## 4. Chrome DevTools MCP: Standard Inspection Protocol

Every verification step in this PRD follows these sub-protocols. Do NOT skip steps.

### 4a. Navigate & Screenshot
```
1. CDP: navigate to target URL
2. CDP: wait for networkIdle (all assets loaded)
3. CDP: take full-page screenshot → save as baseline
4. Log: URL, timestamp, screenshot filename
```

### 4b. Console Audit
```
1. CDP: collect all console messages (errors, warnings, info)
2. Filter: CSS-related errors (unresolved variables, failed imports)
3. Filter: JS errors (custom element registration, missing modules)
4. Log: every error with source URL and line number
```

### 4c. DOM Inspection (per component on page)
```
1. CDP: querySelectorAll for <el-dm-*> tags
2. For each element:
   a. Log: tag name, attributes present
   b. CDP: access shadowRoot
   c. If no shadowRoot → FLAG: element not rendering Shadow DOM
   d. Inspect shadowRoot innerHTML — verify internal structure
   e. CDP: getComputedStyle on key child elements
   f. Verify color values resolve (not transparent, not fallback)
```

### 4d. Theme Toggle Verification
```
1. CDP: evaluate `document.documentElement.setAttribute('data-theme', 'moonlight')`
2. CDP: wait 500ms (transition time)
3. CDP: screenshot → save as moonlight variant
4. For each <el-dm-*> on page:
   a. CDP: access shadowRoot
   b. CDP: getComputedStyle on colored elements
   c. Verify colors changed (compare with sunshine baseline)
   d. FLAG any element where colors did NOT change
5. CDP: evaluate `document.documentElement.setAttribute('data-theme', 'sunshine')`
6. CDP: wait 500ms
7. CDP: screenshot → verify matches original baseline
```

### 4e. Interactive State Testing
```
For interactive elements (buttons, inputs, links):
1. CDP: focus the element (Tab key or element.focus())
2. CDP: screenshot → verify focus ring visible
3. CDP: hover state (dispatchEvent mouseenter)
4. CDP: screenshot → verify hover style
5. CDP: click / activate
6. CDP: screenshot → verify active state
7. For disabled elements:
   a. CDP: verify pointer-events: none or cursor: not-allowed
   b. CDP: verify opacity reduced or color muted
```

### 4f. Form Element Testing
```
For form-associated custom elements:
1. CDP: find enclosing <form> or create test form
2. CDP: set element value programmatically
3. CDP: evaluate `new FormData(form)` → verify element's name/value present
4. CDP: trigger validation (element.checkValidity())
5. CDP: screenshot error state
6. CDP: submit form → verify no JS errors
```

---

## 5. Workflow

### Phase 1: Discovery & Baseline Audit

**Goal**: Full inventory of what exists, what's broken, what's missing. Do NOT fix anything yet.

#### Step 1.1: Route Discovery
1. CDP: navigate to `http://localhost:4600/`
2. CDP: screenshot the demo home page
3. CDP: extract all `<a>` href values → build route list
4. CDP: navigate to `http://localhost:4600/storybook`
5. CDP: screenshot the storybook index
6. CDP: extract all storybook navigation links → build component route list
7. **Write complete route list to `SYNC_AUDIT.md`**

#### Step 1.2: Baseline Screenshots (every route)
For each discovered route:
1. Run full [4a. Navigate & Screenshot]
2. Run full [4b. Console Audit]
3. Save screenshot with naming: `baseline/{route-slug}-sunshine.png`

#### Step 1.3: Baseline Theme Toggle (every route)
For each route:
1. Run full [4d. Theme Toggle Verification]
2. Save screenshots: `baseline/{route-slug}-moonlight.png`
3. Log any elements that failed theme transition

#### Step 1.4: Source Code Inventory
1. Read `$CORE_SRC/components/` — list every component generator file
2. Read `$CORE_SRC/themes/` — extract full color token list (sunshine + moonlight)
3. Read `$ELEMENTS_SRC/` — list every `<el-dm-*>` element package
4. Read `$ELEMENTS_CORE/src/base-element.ts` — document base class API
5. Read `$PHOENIX_SRC/phoenix_duskmoon/lib/` — list every Phoenix component module
6. Read `$PHOENIX_SRC/phoenix_storybook_web/` — list registered storybook stories and demo pages

#### Step 1.5: Three-Layer Mapping Table
Produce this table in `SYNC_AUDIT.md`:

```markdown
| Core Component | CSS Classes         | Custom Element       | Phoenix Module                    | Storybook Route | Status |
|---------------|---------------------|----------------------|-----------------------------------|-----------------|--------|
| button.ts     | .btn .btn-primary … | <el-dm-button>       | PhoenixDuskmoon.Component.Button  | /storybook/…    | ✅/⚠️/❌ |
| card.ts       | .card .card-body …  | <el-dm-card>         | PhoenixDuskmoon.Component.Card    | /storybook/…    | …      |
```

Status:
- ✅ = all three layers exist and storybook renders correctly
- ⚠️ = exists but broken styles / missing variants / incomplete attrs
- ❌ = missing in one or more layers

#### Step 1.6: DOM Deep Inspection (every storybook page)
For each storybook route:
1. Run full [4c. DOM Inspection]
2. Log: which elements use `<el-dm-*>` tags vs raw HTML
3. Log: which elements have Shadow DOM vs light DOM
4. Log: missing attributes (compare with core CSS variants)
5. Log: unresolved CSS variables in Shadow DOM

#### Step 1.7: Color Token Diff
1. Extract all `--color-*` tokens from core themes (sunshine.ts, moonlight.ts)
2. CDP: on any page, run `getComputedStyle(document.documentElement)` → extract all `--color-*` properties
3. Diff: tokens in core vs tokens actually present in Phoenix CSS
4. CDP: inspect a Shadow DOM element → check which `--color-*` or `--dm-*` vars it references
5. Log all missing/mismatched tokens

#### Step 1.8: Write Complete Audit
Write ALL findings to `SYNC_AUDIT.md`:
- Route list
- Mapping table
- Console errors per route
- DOM inspection findings per component
- Color token diff
- Screenshot references
- **Categorized issue list** grouped by root cause:
  1. Missing custom elements (need creation in duskmoon-elements)
  2. Missing Phoenix wrappers (need creation in phoenix-duskmoon-ui)
  3. Missing color tokens (need sync)
  4. Broken styles (need fix)
  5. Missing variants/attrs (need update)
  6. Theme toggle failures (need investigation)
  7. Console errors (need fix)
  8. Form integration issues (need fix)

**⚠️ DO NOT proceed to Phase 2 until SYNC_AUDIT.md is complete and committed.**

---

### Phase 2: Color Token Sync

**Goal**: Tokens flow correctly: core → Phoenix CSS → Shadow DOM inheritance.

#### 2a. Fix Phoenix Theme CSS
For each missing/mismatched token from audit:
1. Add/update CSS custom property in `phoenix_duskmoon/theme` CSS
2. Follow core's naming: `--color-{role}` with HSL value
3. Save file, wait for live reload

#### 2b. Verify Token Presence via DevTools
1. CDP: navigate to any storybook page at `http://localhost:4600/storybook`
2. CDP: `getComputedStyle(document.documentElement)` → extract all `--color-*`
3. Compare against core token list — confirm 100% coverage
4. CDP: screenshot

#### 2c. Verify Token Inheritance into Shadow DOM
1. CDP: find any `<el-dm-*>` element on page
2. CDP: access its shadowRoot
3. CDP: `getComputedStyle(shadowChild)` for a colored element
4. Verify the computed color matches the expected theme token value
5. Run [4d. Theme Toggle Verification] — confirm tokens update in Shadow DOM

#### 2d. Fix Element Token References (if needed)
If elements use `--dm-*` instead of `--color-*`:
1. Document the mapping in `SYNC_AUDIT.md`
2. Either:
   a. Update elements to use `--color-*` directly, OR
   b. Add `--dm-*` aliases in Phoenix theme CSS that reference `--color-*`
3. CDP: re-verify after fix

**Commit**: `sync: color tokens from core to Phoenix theme CSS`

---

### Phase 3: Custom Element Sync (per component, in tier order)

**Goal**: Every core CSS component has a corresponding `<el-dm-*>` custom element.

For each component (following priority order in Section 7):

#### 3a. If Element Missing (❌ in audit)

Create in duskmoon-elements following conventions:
- Directory: `elements/{name}/`
- Package: `@duskmoon-dev/el-{name}`
- Tag: `<el-dm-{name}>`
- Class: `ElDm{PascalName}` extending `BaseElement`
- Shadow DOM with `adoptedStyleSheets`
- Map core CSS variants to element attributes:
  ```
  .btn-primary → variant="primary"
  .btn-tertiary → variant="tertiary"
  .btn-lg → size="lg"
  .btn-outline → style-variant="outline"
  ```
- For form elements: `static formAssociated = true` + `ElementInternals`

Build and test:
```bash
cd ~/duskmoon-elements && bun run build:all && bun run test
```

#### 3b. If Element Incomplete (⚠️ in audit)

- Add missing attributes for new core variants (tertiary, container colors)
- Update Shadow DOM styles for any new tokens
- Update `observedAttributes`

Build and test.

#### 3c. Verify New/Updated Element via DevTools

**This is the critical feedback loop. Do not skip.**

1. Rebuild Phoenix assets (pick up new element bundle)
2. CDP: hard refresh storybook page at `http://localhost:4600/storybook/…`
3. Run full [4a. Navigate & Screenshot]
4. Run full [4b. Console Audit] — zero errors expected
5. Run full [4c. DOM Inspection]:
   - Confirm `<el-dm-{name}>` tag present
   - Confirm shadowRoot exists
   - Confirm all variant attributes render correctly
   - Confirm colors resolve from `--color-*` tokens
6. Run full [4d. Theme Toggle Verification]
7. Run full [4e. Interactive State Testing]
8. For form elements: run full [4f. Form Element Testing]
9. CDP: screenshot final state → save as `verified/{name}-sunshine.png` and `verified/{name}-moonlight.png`

**If any check fails**:
1. Log the failure
2. Fix in source
3. Rebuild
4. CDP: wait for reload
5. Re-run the failed check
6. Repeat until clean

**Commit per element**: `sync: <el-dm-{name}> custom element from core`

---

### Phase 4: Phoenix Component Sync (per component)

**Goal**: Every `<el-dm-*>` element has a `Phoenix.Component` wrapper in `phoenix_duskmoon`.

For each component:

#### 4a. Create/Update Phoenix Module

In `apps/phoenix_duskmoon/lib/phoenix_duskmoon/component/`:

```elixir
defmodule PhoenixDuskmoon.Component.Button do
  use PhoenixDuskmoon, :component

  attr :variant, :string, default: nil,
    values: ~w(primary secondary tertiary accent info success warning error)
  attr :size, :string, default: nil,
    values: ~w(xs sm md lg xl)
  attr :style_variant, :string, default: nil,
    values: ~w(outline ghost link glass)
  attr :disabled, :boolean, default: false
  attr :rest, :global
  slot :inner_block, required: true

  def dm_button(assigns) do
    ~H"""
    <el-dm-button
      variant={@variant}
      size={@size}
      style-variant={@style_variant}
      disabled={@disabled}
      {@rest}
    >
      {render_slot(@inner_block)}
    </el-dm-button>
    """
  end
end
```

Ensure `@rest` passes through: `phx-click`, `phx-hook`, `darkmoon-send-*`, `darkmoon-receive-*`.

For form elements: add `field` attr for `Phoenix.HTML.Form` integration.

#### 4b. Create/Update Storybook Story

In `apps/phoenix_storybook_web/`:
- Story must show all color variants (primary, secondary, **tertiary**, accent, semantic)
- All sizes
- All style variants
- Disabled / loading states
- For form elements: form integration, validation states

#### 4c. Verify Phoenix Wrapper via DevTools

**Full inspection cycle on the storybook page.**

1. CDP: navigate to component's storybook route at `http://localhost:4600/storybook/…`
2. Run full [4a. Navigate & Screenshot]
3. Run full [4b. Console Audit]
4. Run full [4c. DOM Inspection]:
   - Confirm Phoenix rendered `<el-dm-{name}>` tag (NOT raw `<button>` etc.)
   - Confirm all `attr` values pass through as element attributes
   - Confirm Shadow DOM renders correctly
5. Run full [4d. Theme Toggle Verification]
6. Run full [4e. Interactive State Testing]
7. For form elements: run full [4f. Form Element Testing]
8. Test LiveView bridge:
   - CDP: click element with `darkmoon-send-*` attr
   - CDP: check console for `pushEvent` debug log
   - For receive: CDP: evaluate a `pushEvent` call → verify element method triggers
9. CDP: screenshot → `verified/{name}-phoenix-sunshine.png`

**Fix → reload → re-verify loop until clean.**

**Commit**: `sync: Phoenix wrapper for <el-dm-{name}>`

---

### Phase 5: JS Bundle & Asset Pipeline

**Goal**: All custom elements load correctly in Phoenix.

#### 5a. Verify JS Imports
1. Read Phoenix JS entry point — confirm all `@duskmoon-dev/el-*` packages imported
2. Confirm `WebComponentHook` exported and available

#### 5b. Verify CSS Imports
Confirm this exact chain in Phoenix assets CSS:
```css
@import "tailwindcss";
@plugin "@duskmoon-dev/core/plugin";
@import "phoenix_duskmoon/theme";
@import "phoenix_duskmoon/components";
```

#### 5c. Full Page Load Test via DevTools
1. CDP: navigate to `http://localhost:4600/` (demo home)
2. CDP: check Network tab — zero 404s on JS/CSS assets
3. CDP: check Console — zero errors
4. CDP: screenshot
5. CDP: navigate to `http://localhost:4600/storybook` — repeat checks

**Commit if changes needed**: `fix: asset pipeline imports`

---

### Phase 6: Full Regression — Every Route, Every Component

**Goal**: Compare final state against Phase 1 baseline. Everything must be equal or better.

#### 6a. Screenshot Every Route (both themes)
For each route discovered in Phase 1:
1. CDP: navigate to `http://localhost:4600/{route}`
2. CDP: screenshot sunshine → `final/{route-slug}-sunshine.png`
3. CDP: toggle to moonlight
4. CDP: screenshot → `final/{route-slug}-moonlight.png`

#### 6b. Console Audit Every Route
For each route:
1. CDP: collect all console messages
2. **Zero CSS errors expected**
3. **Zero JS errors expected**
4. Log any remaining warnings (acceptable if non-blocking)

#### 6c. DOM Audit Every Storybook Page
For each storybook component route:
1. Run full [4c. DOM Inspection]
2. Confirm all `<el-dm-*>` tags have Shadow DOM
3. Confirm all color tokens resolve
4. Confirm all variants render

#### 6d. Theme Toggle Stress Test
1. CDP: navigate to storybook index at `http://localhost:4600/storybook`
2. CDP: rapid toggle sunshine → moonlight → sunshine → moonlight (4 switches, 300ms each)
3. CDP: screenshot after final toggle
4. Confirm no flash, no stuck states, no unresolved variables

#### 6e. Form Submission End-to-End
For any page with a form containing custom elements:
1. CDP: fill all fields via element properties/methods
2. CDP: submit form
3. CDP: verify no errors, verify server received values
4. CDP: screenshot

#### 6f. Automated Tests
```bash
cd ~/phoenix-duskmoon-ui && mix test
cd ~/phoenix-duskmoon-ui && mix format --check-formatted
cd ~/duskmoon-elements && bun run test
```

#### 6g. Update SYNC_AUDIT.md
- Update mapping table: all statuses should be ✅
- Add final screenshot references
- Add summary: issues found vs issues fixed
- Add any remaining known issues

**Commit**: `docs: final sync audit complete`

---

## 6. Scope

### In Scope
- Audit all three layers via DevTools inspection
- Create missing `<el-dm-*>` custom elements
- Create/update Phoenix wrappers emitting `<el-dm-*>` tags
- Sync color tokens across all layers
- WebComponentHook integration for all interactive elements
- Storybook stories in `phoenix_storybook_web` for every component
- DevTools-verified regression on every route at port 4600

### Out of Scope
- `@duskmoon-dev/docs` (Astro documentation site)
- React/Preact packages
- yew-duskmoon-ui (Rust/Wasm)
- New components not defined in core

---

## 7. Component Priority Order

### Tier 1 — Core Actions & Input
| # | Core | Element Tag | Phoenix Function | Storybook Route |
|---|------|------------|-----------------|-----------------|
| 1 | button.ts | `<el-dm-button>` | `dm_button` | _discover_ |
| 2 | input.ts | `<el-dm-input>` | `dm_input` | _discover_ |
| 3 | card.ts | `<el-dm-card>` | `dm_card` | _discover_ |
| 4 | badge.ts | `<el-dm-badge>` | `dm_badge` | _discover_ |
| 5 | alert.ts | `<el-dm-alert>` | `dm_alert` | _discover_ |
| 6 | modal.ts | `<el-dm-modal>` | `dm_modal` | _discover_ |

### Tier 2 — Form Elements
| # | Core | Element Tag | Phoenix Function |
|---|------|------------|-----------------|
| 7 | checkbox.ts | `<el-dm-checkbox>` | `dm_checkbox` |
| 8 | radio.ts | `<el-dm-radio>` | `dm_radio` |
| 9 | select.ts | `<el-dm-select>` | `dm_select` |
| 10 | textarea.ts | `<el-dm-textarea>` | `dm_textarea` |
| 11 | toggle.ts | `<el-dm-switch>` | `dm_switch` |
| 12 | range.ts | `<el-dm-slider>` | `dm_slider` |
| 13 | rating.ts | `<el-dm-rating>` | `dm_rating` |
| 14 | file-input.ts | `<el-dm-file-upload>` | `dm_file_upload` |

### Tier 3 — Navigation
| # | Core | Element Tag | Phoenix Function |
|---|------|------------|-----------------|
| 15 | navbar.ts | `<el-dm-navbar>` | `dm_navbar` |
| 16 | menu.ts | `<el-dm-menu>` | `dm_menu` / `dm_left_menu` |
| 17 | breadcrumbs.ts | `<el-dm-breadcrumbs>` | `dm_breadcrumbs` |
| 18 | tab.ts | `<el-dm-tabs>` | `dm_tabs` |
| 19 | pagination.ts | `<el-dm-pagination>` | `dm_pagination` |
| 20 | steps.ts | `<el-dm-steps>` | `dm_steps` |

### Tier 4 — Data Display
| # | Core | Element Tag | Phoenix Function |
|---|------|------------|-----------------|
| 21 | table.ts | `<el-dm-table>` | `dm_table` |
| 22 | accordion.ts | `<el-dm-accordion>` | `dm_accordion` |
| 23 | avatar.ts | `<el-dm-avatar>` | `dm_avatar` |
| 24 | stat.ts | `<el-dm-stat>` | `dm_stat` |
| 25 | — | `<el-dm-pro-data-grid>` | `dm_pro_data_grid` |

### Tier 5 — Layout & Feedback
| # | Core | Element Tag | Phoenix Function |
|---|------|------------|-----------------|
| 26 | drawer.ts | `<el-dm-drawer>` | `dm_drawer` |
| 27 | toast.ts | `<el-dm-toast>` | `dm_toast` |
| 28 | tooltip.ts | `<el-dm-tooltip>` | `dm_tooltip` |
| 29 | progress.ts | `<el-dm-progress>` | `dm_progress` |
| 30 | loading.ts | `<el-dm-loading>` | `dm_loading` |
| 31 | divider.ts | `<el-dm-divider>` | `dm_divider` |

### Standalone Elements (no core CSS equivalent)
| Element Tag | Phoenix Function | Notes |
|------------|-----------------|-------|
| `<el-dm-markdown-stream>` | `dm_markdown` | Streaming markdown renderer |
| `<el-dm-pro-data-grid>` | `dm_pro_data_grid` | Advanced data grid (separate PRD) |

---

## 8. Custom Element ↔ LiveView Bridge Patterns

### Pattern 1: Event Send (element → LiveView)
```html
<el-dm-button
  phx-hook="WebComponentHook"
  darkmoon-send-click="handle_button_click"
>
  Save
</el-dm-button>
```

### Pattern 2: Event Receive (LiveView → element)
```html
<el-dm-markdown-stream
  id="ai-output"
  phx-hook="WebComponentHook"
  darkmoon-receive-append_chunk="append"
/>
```

### Pattern 3: Bidirectional (form elements)
```html
<el-dm-input
  name="user[email]"
  value={@form[:email].value}
  phx-hook="WebComponentHook"
  darkmoon-send-change="validate"
/>
```

### Pattern 4: Form-Associated (ElementInternals)
No `phx-hook` needed for basic form submission — `ElementInternals` participates natively. `WebComponentHook` only for real-time events.

### DevTools Verification for Bridge
```
1. CDP: find element with darkmoon-send-* attr
2. CDP: click element
3. CDP: check console for pushEvent debug log
4. CDP: evaluate `document.querySelector('#el').dispatchEvent(new CustomEvent('test'))`
5. Verify WebComponentHook forwards to LiveView
```

---

## 9. Theme Propagation in Shadow DOM

CSS custom properties defined on `<html data-theme="sunshine">` inherit through Shadow DOM. Shadow DOM stylesheets reference `var(--color-primary)` directly — no duplication.

**What does NOT work**: Tailwind utility classes and `@apply` do NOT pierce Shadow DOM. Elements must use explicit `var(--color-*)` in their stylesheets.

### DevTools Theme Verification (per element)
```
1. CDP: getComputedStyle(document.documentElement).getPropertyValue('--color-primary')
   → save as expected_primary
2. CDP: access el.shadowRoot.querySelector('[part="button"]') (or similar)
3. CDP: getComputedStyle(shadowChild).backgroundColor
   → verify contains expected_primary HSL value
4. CDP: switch to moonlight
5. Repeat steps 1-3 — values must change
```

---

## 10. Constraints

- **Audit before fix**: Phase 1 MUST complete before any code changes
- **DevTools verification mandatory**: Every fix verified via Chrome DevTools MCP — no "trust the code" assumptions
- **Atomic commits**: One commit per component per layer
- **No API breaks**: Additive only for existing Phoenix components
- **Custom element first**: Phoenix MUST render `<el-dm-*>` tags, not raw HTML
- **Tertiary everywhere**: All color-supporting elements accept `variant="tertiary"`
- **Shadow DOM mandatory**: Every `<el-dm-*>` uses Shadow DOM
- **CSS tokens inherit**: Don't duplicate core tokens inside Shadow DOM
- **`darkmoon-*` attrs preserved**: Maintain existing bridge patterns
- **Form association**: Form elements use `ElementInternals`, not hidden `<input>` hacks
- **BaseElement convention**: All elements extend `BaseElement` from `@duskmoon-dev/el-core`
- **Plugin path**: Always `@plugin "@duskmoon-dev/core/plugin"` — not `@plugin "duskmoonui"`

---

## 11. Success Criteria

- [ ] `SYNC_AUDIT.md` Phase 1 baseline complete (all routes at port 4600, all screenshots)
- [ ] Every core component → `<el-dm-*>` element → Phoenix wrapper chain complete
- [ ] Three-layer mapping table: all ✅
- [ ] 65+ color tokens present and verified via DevTools across all layers
- [ ] Sunshine/Moonlight themes work in Shadow DOM (DevTools computed style proof)
- [ ] Theme toggle propagates to all custom elements (DevTools verified, screenshots)
- [ ] Form submission works for all form-associated elements (DevTools FormData check)
- [ ] `WebComponentHook` bridge verified via DevTools for all interactive elements
- [ ] Zero console errors on every storybook route (DevTools verified)
- [ ] Zero console errors on demo home page (DevTools verified)
- [ ] Final regression screenshots match or exceed baseline quality
- [ ] `mix test` passes
- [ ] `bun run test` passes (duskmoon-elements)
- [ ] `mix format --check-formatted` passes
- [ ] Storybook stories in `phoenix_storybook_web` cover all components

---

## 12. Loki Mode Session

Running with `--dangerously-skip-permissions` — no permission config needed.

### Session Init Prompt
```
Read PRD_SYNC_CORE_TO_PHOENIX.md and execute all phases sequentially.

Three repos:
- Core CSS: ~/duskmoonui/packages/core/src/
- Custom Elements: ~/duskmoon-elements/elements/
- Phoenix: ~/phoenix-duskmoon-ui/apps/

Phoenix umbrella apps:
- phoenix_duskmoon — library (component wrappers)
- phoenix_storybook_web — demo & storybook

Demo/Storybook server: http://localhost:4600
CSS plugin: @plugin "@duskmoon-dev/core/plugin"

Use chrome-devtools MCP for ALL verification. Follow Section 4
(Standard Inspection Protocol) for every check. Take screenshots
at every step. Do NOT skip DevTools verification.

Do NOT ask for confirmation between phases — proceed autonomously.
Commit after each component sync.
Write all findings to SYNC_AUDIT.md before fixing anything.
```

---

## 13. Known Issues / Watch Out For

- **Shadow DOM + CSS inheritance**: `var(--color-*)` inherits. `@apply` and Tailwind classes do NOT.
- **`--dm-*` vs `--color-*` prefix**: Elements may use `--dm-*` internally. Standardize in Phase 2.
- **Plugin path**: Must be `@plugin "@duskmoon-dev/core/plugin"` — old references to `@plugin "duskmoonui"` are outdated.
- **CSS `@import` order**: Theme before components in Phoenix CSS.
- **Umbrella `apps/`**: Library code in `apps/phoenix_duskmoon/`, storybook in `apps/phoenix_storybook_web/`.
- **`PhoenixDuskmoon.Fun`**: Separate module system — may wrap elements differently.
- **Element registration race**: Elements must be defined before first use. Check load order.
- **SSR gap**: Custom elements render empty server-side. LiveView hydrates. Not a bug.
- **DevTools MCP Shadow DOM access**: Use `element.shadowRoot` to inspect. Some CDP methods may need `pierce: true` for Shadow DOM queries.
- **Port 4600**: All demo/storybook URLs are on port 4600, not 4000.

---

## 14. Appendix: Findings

<!-- Claude Code fills this in during Phase 1 -->

### Discovered Routes
_Phase 1, Step 1.1 — all routes at http://localhost:4600_

### Baseline Screenshots
_Phase 1, Step 1.2_

### Console Error Log
_Phase 1, Step 1.2_

### Three-Layer Mapping Table
_Phase 1, Step 1.5_

### DOM Inspection Findings
_Phase 1, Step 1.6_

### Color Token Diff
_Phase 1, Step 1.7_

### Categorized Issues
_Phase 1, Step 1.8_

### Verification Screenshots
_Phases 3-6_

### Final Regression Results
_Phase 6_
