# JavaScript Hooks

Phoenix Duskmoon UI provides five LiveView hooks for client-side interactions
that cannot be handled server-side. Some components require specific hooks to
function correctly.

## Setup

Import all hooks and register them with your LiveSocket:

```javascript
import { LiveSocket } from "phoenix_live_view";
import * as DuskmoonHooks from "phoenix_duskmoon/hooks";

let liveSocket = new LiveSocket("/live", Socket, {
  params: { _csrf_token: csrfToken },
  hooks: DuskmoonHooks,
});
```

Or import individual hooks:

```javascript
import {
  WebComponentHook,
  FormElementHook,
  ThemeSwitcher,
  Spotlight,
  PageHeader,
} from "phoenix_duskmoon/hooks";

let hooks = { WebComponentHook, FormElementHook, ThemeSwitcher, Spotlight, PageHeader };
```

## Hook Reference

### WebComponentHook

**Purpose**: Universal bridge between LiveView and `el-dm-*` custom elements.

**Used by**: All components that render as custom elements.

**How it works**:

1. **Forwarding events to LiveView** — Maps custom element events to Phoenix events:

   | Custom Element Event | Phoenix Event |
   |---------------------|---------------|
   | `dm-click` | `phx-click` |
   | `dm-change` | `phx-change` |
   | `dm-input` | `phx-input` |
   | `dm-submit` | `phx-submit` |
   | `dm-focus` | `phx-focus` |
   | `dm-blur` | `phx-blur` |
   | `dm-select` | `phx-select` |
   | `dm-close` | `phx-close` |
   | `dm-open` | `phx-open` |
   | `dm-toggle` | `phx-toggle` |

2. **Custom event routing** — Use `duskmoon-send-{event}="{phxEvent}"` attributes
   to forward arbitrary custom element events to specific LiveView event handlers:

   ```heex
   <el-dm-slider duskmoon-send-change="slider_changed" />
   ```

3. **Receiving events from LiveView** — Use `duskmoon-receive-{event}="{handler}"`
   to push LiveView events to the custom element.

### FormElementHook

**Purpose**: Extends `WebComponentHook` with form-specific behavior.

**Used by**: Form components (`dm_input`, `dm_select`, `dm_checkbox`, etc.) when
used within a `<.dm_form>`.

**How it works**: Watches the parent form for the `phx-no-feedback` class via
`MutationObserver`. When LiveView removes this class (after form submission or
validation), the hook triggers `phx-feedback-for` error display on the element.
This ensures validation errors only appear after user interaction, matching
Phoenix's standard form feedback timing.

### ThemeSwitcher

**Purpose**: Theme toggle with `localStorage` persistence.

**Used by**: `<.dm_theme_switcher />`

**How it works**:
- On mount, reads the saved theme from `localStorage` and syncs it with the
  server-side `data-theme` attribute
- When the user toggles the theme, persists the choice to `localStorage` and
  pushes a `"theme_changed"` event to the LiveView
- On update, syncs checkbox state with the `data-theme` attribute

### Spotlight

**Purpose**: Keyboard shortcut handler for spotlight/command palette search.

**Used by**: `<.dmf_spotlight />`

**How it works**:
- On mount, adds a `keydown` listener on `window` for `Cmd+K` (macOS) / `Ctrl+K`
  (other platforms)
- When triggered, calls `this.el.showModal()` to open the spotlight dialog
- Handles `Escape` to close the dialog
- Cleans up listeners on destroy

### PageHeader

**Purpose**: Intersection observer for scroll-based effects.

**Used by**: `<.dm_page_header />`

**How it works**:
- On mount, creates an `IntersectionObserver` watching the page header element
- When the header scrolls out of view (`intersectionRatio <= 0.5`), shows a
  secondary navigation element (identified by `data-nav-id`) with opacity
  proportional to scroll position
- Cleans up the observer on destroy

## Components Requiring Hooks

| Component | Required Hook | What Breaks Without It |
|-----------|--------------|----------------------|
| `<.dm_theme_switcher />` | ThemeSwitcher | Theme choice not persisted across page loads |
| `<.dmf_spotlight />` | Spotlight | Keyboard shortcut (Cmd/Ctrl+K) doesn't work |
| `<.dm_page_header />` | PageHeader | Scroll-based nav visibility doesn't trigger |
| All `el-dm-*` elements | WebComponentHook | Custom element events not forwarded to LiveView |
| Form `el-dm-*` elements | FormElementHook | Validation errors don't respect feedback timing |
