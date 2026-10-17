# Resizable split panes

`dm_split_pane` keeps two native HEEx regions visible while users resize the
primary pane. It uses Core's divider styling and the `DuskmoonSplitPane` LiveView
hook. Pane contents remain owned by LiveView, including forms, streams and links.

Register the hook with your application's LiveSocket:

```javascript
import { DuskmoonSplitPane } from "phoenix_duskmoon/hooks";

const liveSocket = new LiveSocket("/live", Socket, {
  hooks: { DuskmoonSplitPane },
  params: { _csrf_token: csrfToken },
});
```

Import the package CSS as described in the getting-started guide. The hook does
not require React or custom-element registration.

```heex
<.dm_split_pane
  id="storage-browser"
  initial_width={280}
  min_width={160}
  max_width={480}
  min_secondary_width={240}
  stack_at={640}
  resize_label={gettext("Resize folder navigation")}
  class="h-96"
  primary_class="p-4 bg-surface-container-low"
  secondary_class="p-4"
>
  <:primary><nav aria-label={gettext("Folders")}>Folder navigation</nav></:primary>
  <section aria-label={gettext("Files")}>File list</section>
</.dm_split_pane>
```

All size attributes are nonnegative integer CSS pixels. `max_width` must be at
least `min_width`. The available maximum also reserves `min_secondary_width`
and the 16px separator. A ResizeObserver updates these bounds when the container
changes size, even when the viewport stays the same size.

The panes stack when the container is narrower than `stack_at` or both minimum
widths cannot fit. Both contents remain visible, and the separator leaves the
tab order and accessibility tree. Widening restores the preferred desktop width,
subject to the current bounds. Before JavaScript mounts, the panes are stacked.

Drag the separator with a mouse, pen or touch pointer. Pointer capture keeps the
drag active outside its bounds. Pointer cancellation or lost capture restores
the width from before the drag. Focus the separator and press ArrowLeft or
ArrowRight to change the width by 10px, Home for the minimum, or End for the
available maximum. Arrow direction follows the layout's text direction.

The separator exposes `role="separator"`, vertical orientation, its controlled
pane, and current/minimum/maximum widths. Set `resize_label` to a translated,
context-specific accessible name.

The hook owns width in the browser. `initial_width` is used when it mounts;
changing that attribute during a patch does not reset a user's choice. Keep the
root `id` stable. Normal LiveView patches continue updating both panes, and the
hook reapplies width and ARIA values after each patch. A patch during a drag
releases capture while retaining the latest width. Do not add `phx-update="ignore"`
to the component. Removing/remounting the component or loading a new page starts
from `initial_width`; no storage persistence is implied.

Resizing sends no server events. Listener and observer cleanup happens when the
component is destroyed. `dm_sidebar_layout` remains the static sidebar layout
whose navigation hides on narrow containers; use `dm_split_pane` when both
regions need to remain visible.
