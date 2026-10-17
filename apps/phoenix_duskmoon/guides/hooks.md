# JavaScript Hooks

Phoenix Duskmoon UI provides LiveView hooks for client-side interactions
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

Importing `phoenix_duskmoon/hooks` also loads the package runtime, including the
CSP-safe delegated behavior for confirm dialogs. Apps that use server-rendered
confirm dialogs without LiveView hooks can load only that runtime:

```javascript
import "phoenix_duskmoon";
```

Or import individual hooks:

```javascript
import {
  WebComponentHook,
  FormElementHook,
  ThemeSwitcher,
  Spotlight,
  PageHeader,
  DuskmoonLeftMenu,
  DuskmoonLeftMenuNavigation,
  DuskmoonSplitPane,
} from "phoenix_duskmoon/hooks";

let hooks = { WebComponentHook, FormElementHook, ThemeSwitcher, Spotlight, PageHeader, DuskmoonLeftMenu, DuskmoonLeftMenuNavigation, DuskmoonSplitPane };
```

## Hook Reference

### DuskmoonSplitPane

**Used by**: `<.dm_split_pane />`. Supports pointer capture/cancellation and
ArrowLeft/ArrowRight/Home/End keyboard resizing with accessible separator range
attributes. Width survives LiveView patches; a ResizeObserver clamps the available
range and stacks both panes in narrow containers. No resize events go to the
server. See [Resizable split panes](split-pane.md) for setup and the lifecycle
contract.

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

### DuskmoonLeftMenu

**Purpose**: Keeps collapse, group and scroll state in a collapsible `dm_left_menu`.

Use a stable menu `id` and stable group IDs. The hook restores the menu's scroll
through `redirect`, `initial` and `patch` page-loading updates, keeps group choices
when expanding, and enables native link tooltips in the icon rail. `storage_key`
optionally persists the collapsed preference across reloads.

### DuskmoonLeftMenuNavigation

**Purpose**: Synchronizes `active` with the component-owned persistent menu child.

Use `<.dm_left_menu id="sidebar" sticky socket={@socket} groups={@menu_groups} active={@active_nav} />`
with a stable `id` in the shared LiveView layout. The component attaches both
left-menu hooks automatically once the package hooks are registered in LiveSocket.
Applications do not need a sidebar LiveView, synchronization hook or event handler.

Changing only `active` preserves the child and its scroll state; an empty string
clears highlighting. Configuration changes create a new child so menu data stays
current. Full reloads reset in-memory scroll and group state. See the
[left menu guide](left-menu.md) for the data format, bounded sticky layout and
persistence behavior.

## Components Requiring Hooks

| Component | Required Hook | What Breaks Without It |
|-----------|--------------|----------------------|
| `<.dm_theme_switcher />` | ThemeSwitcher | Theme choice not persisted across page loads |
| `<.dmf_spotlight />` | Spotlight | Keyboard shortcut (Cmd/Ctrl+K) doesn't work |
| `<.dm_page_header />` | PageHeader | Scroll-based nav visibility doesn't trigger |
| `<.dm_left_menu collapsible />` | DuskmoonLeftMenu | Collapse toggle and navigation scroll preservation do not run |
| `<.dm_left_menu sticky socket={@socket} />` | DuskmoonLeftMenu, DuskmoonLeftMenuNavigation | Collapse/scroll restoration and active-page synchronization do not run |
| All `el-dm-*` elements | WebComponentHook | Custom element events not forwarded to LiveView |
| Form `el-dm-*` elements | FormElementHook | Validation errors don't respect feedback timing |
