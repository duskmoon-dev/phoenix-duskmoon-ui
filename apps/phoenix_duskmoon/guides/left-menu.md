# Collapsible left menus and persistent navigation

`dm_left_menu` owns the collapsible icon rail, fixed header/footer, scrolling menu
body and optional persistent child LiveView. For navigation shared by several
LiveView pages, use its `sticky` data API in the shared LiveView layout.

## Register the package hooks once

```javascript
import * as DuskmoonHooks from "phoenix_duskmoon/hooks";

const liveSocket = new LiveSocket("/live", Socket, {
  params: { _csrf_token: csrfToken },
  hooks: { ...DuskmoonHooks },
});
```

This registers both `DuskmoonLeftMenu` and `DuskmoonLeftMenuNavigation`. The
component attaches them automatically. Applications supply menu data and the
current item; no application sidebar LiveView, navigation hook, event handler or
scroll timer is required.

## Use the persistent menu

Assign menu data from your application, filtering it for the current user's
permissions before rendering. Use atom keys and string IDs, labels and paths:

```elixir
menu_groups = [
  %{
    id: "overview",
    label: "Overview",
    open: true,
    items: [
      %{id: "dashboard", label: "Dashboard", to: "/admin/dashboard", icon: "view-dashboard"},
      %{id: "settings", label: "Settings", to: "/admin/settings", icon: "cog"}
    ]
  }
]
```

Render the menu beside the page content in the **shared LiveView layout** used by
all destination pages. This layout receives `@socket`; the root HTML layout with
`@conn` is not the place for this example.

```heex
<div class="flex min-h-dvh items-start">
  <.dm_left_menu
    id="admin-sidebar"
    sticky
    socket={@socket}
    groups={@menu_groups}
    active={@active_nav}
    brand={%{label: "Administration", icon: "view-dashboard", to: "/admin/dashboard", version: "v1"}}
    footer_text="My application"
    storage_key="my-app:admin-sidebar-collapsed"
    class="sticky top-0 h-dvh"
  />
  <main class="min-w-0 flex-1">{@inner_content}</main>
</div>
```

`sticky` enables the collapsible layout and creates the persistent child
LiveView inside the component. Keep the same stable, unique menu `id` and menu
configuration across destination pages. Set each page's `@active_nav` in
`mount/3`, or `handle_params/3` when it depends on patchable URL parameters. The
application chooses the active item explicitly; the component does not infer it
from the URL.

| Data | Fields |
| --- | --- |
| Group | Required `id`, `label`, `items`; optional `open` (defaults to `true`) |
| Item | Required `id`, `label`, `to`; optional `icon`, `disabled` (defaults to `false`), `class`, `rest` (defaults to `%{}`) |
| Brand | Required `label`; optional `icon`, `to`, `version` |

Required IDs, labels and item paths must be non-empty strings. Group IDs must be
unique, and item IDs must be unique across all groups. `icon` is an MDI name.
`rest` forwards global link attributes, for example `%{"aria-label" => "Settings"}`.
All data-driven menus require a stable, unique menu `id`.
`brand` and `footer_text` are optional. These data attributes also work without
`sticky`; `groups` and `:menu` slots cannot be combined.

## Sticky position and scrolling

CSS positioning and LiveView persistence have separate settings:

| Setting | Effect |
| --- | --- |
| `class="sticky top-0 h-dvh"` | Keeps the menu in view within its containing layout and bounds its height |
| `sticky socket={@socket}` | Keeps the component-owned child alive during LiveView navigation |
| `storage_key="..."` | Restores the collapsed preference after a full page reload |

Keep a bounded height so only the menu body scrolls. The component's flex column
keeps the brand/header, footer and bottom toggle visible outside that scrolling
body. Avoid adding `overflow-auto` to the whole menu. CSS sticky is constrained by
its containing block, and an ancestor with `overflow` can establish a different
scroll container. For a top app bar, adjust both offset and height, for example
`class="sticky top-16 h-[calc(100dvh-4rem)]"`.

The bottom button switches between the default 18rem expanded width and 4.5rem
rail. Override `--dm-left-menu-width` and `--dm-left-menu-collapsed-width` to change
those widths. `collapsed={true}` sets the initial state. A saved `storage_key`
preference takes precedence; omit the key to keep the choice only while mounted.
Storage being unavailable does not prevent toggling. Customize accessible toggle
names with `expand_label` and `collapse_label`.

Use icons and concise labels for rail items. Their labels become accessible names
and right-side tooltips on hover and keyboard focus. Collapsing temporarily opens
all groups so their icons remain available; expanding restores the user's group
choices. Stable group IDs also preserve those choices through server patches.

## Active updates and configuration changes

When only `active` changes, the package navigation hook sends the new value to the
existing child. The menu, scrolling element, collapse preference and group state
remain mounted. An empty string clears the selection. The child accepts only
known, enabled item IDs or an empty string. Failed synchronization can retry after
the next update or reconnection.

The component derives its child ID from a hash of the normalized groups, brand
and presentation configuration. Changing that configuration, including menu
permissions, creates a new child with the new data. This deliberately resets
in-memory scroll and group state; a configured `storage_key` still restores the
collapsed preference. Keep route-specific changes in `active` rather than
rebuilding different menu configurations for each page.

The scroll hook restores the menu body's position around server patches and
LiveView `redirect`, `patch` and `initial` page-loading updates, including browser
history navigation. A redirect may finish before the destination's initial
patch, so restoration continues through that patch.

Persistence requires LiveView navigation and the same shared menu configuration.
A full HTTP navigation or reload, leaving the shared layout, or changing the menu
ID creates a new menu. Only the collapsed preference survives a full reload when
`storage_key` is set; scroll and group choices are kept in memory.

The Storybook application's `/components` gallery uses this setup in its shared
`Layouts.app` layout. `ComponentNavigation.groups/0` supplies the menu data, and
each destination assigns `active_menu`. Ordinary demo templates run in `PageLive`
alongside the existing React demo LiveViews, so all menu destinations use LiveView
navigation. Its 4rem app bar uses `top-16 h-[calc(100dvh-4rem)]` for the sidebar.

## Use slots without sticky mode

Existing slot-based menus remain supported. Use `collapsible` and a stable `id`
for the rail, and give each group a stable ID. Pass `active` explicitly to each
slotted group; the outer menu cannot assign values to nested components.

```heex
<.dm_left_menu id="page-sidebar" collapsible class="sticky top-0 h-dvh">
  <:header>
    <.dm_mdi name="view-dashboard" class="size-7" aria-hidden="true" />
    <strong data-left-menu-label>My application</strong>
  </:header>
  <:menu>
    <.dm_left_menu_group id="page-overview" active={@active_nav}>
      <:title>Overview</:title>
      <:menu id="dashboard" to="/admin/dashboard" icon="view-dashboard" label="Dashboard">
        Dashboard
      </:menu>
      <:menu id="settings" to="/admin/settings" icon="cog" label="Settings">
        Settings
      </:menu>
    </.dm_left_menu_group>
  </:menu>
  <:footer><p data-left-menu-label>My application</p></:footer>
</.dm_left_menu>
```

Mark custom header/footer text with `data-left-menu-label` so it hides in the
rail. Keep a brand or account icon outside that marked element to leave it
visible. The slot's `rest` map still forwards custom global link attributes.
Omit `collapsible` for a regular menu. Sticky mode uses serializable `groups`,
`brand` and `footer_text` data instead of `:header`, `:footer`, `:title` or `:menu`
slots.

## Verify in a browser

Use a long menu and a short viewport:

- Scroll, close a group, navigate to another page, then use Back/Forward. Check
  the menu and scroll container remain the same DOM objects, the scroll position
  and group state survive, and the active item updates.
- Repeat while collapsed, with patch navigation and after reconnecting. Hover and
  keyboard-focus rail links to check labels, tooltips and focus targets.
- Change the menu configuration to check the new data replaces the child. Reload
  to check the optional collapsed preference, and verify the brand, footer and
  toggle remain visible while the menu body scrolls.
