# Upstream design alignment

This audit compares published npm tarballs, public types, runtime code and release
notes, rather than assuming compatibility from package names. Checked 2026-09-22.

## Core-first cleanup (2026-09-24)

This cleanup supersedes the wrapper inventory in the earlier synchronization below.
It intentionally removes public APIs; consumers must migrate before upgrading.

| Removed API | Replacement |
| --- | --- |
| `dm_kbd` | `<kbd class="kbd kbd-sm">Ctrl</kbd>` |
| `dm_mask` | `<img class="mask mask-hexagon" src="/avatar.png" alt="Team avatar" />` |
| `dm_stack` | `<div class="stack stack-end">...</div>`; retain content order and caller-owned `aria-hidden` / `inert` on decorative layers |
| `dm_join` | `<div class="join join-horizontal" role="group" aria-label="Actions">...</div>`; use `join-vertical` for vertical groups and `join-item` on direct children |
| `dm_indicator` | `.indicator` container with `.indicator-item.indicator-top.indicator-end`; preserve accessible status text |
| `dm_hero` | `<section class="hero" aria-label="Welcome"><div class="hero-content">...</div></section>`; optional `.hero-overlay` is decorative |
| `dm_steps` | `dm_stepper` with `:step` slots; map zero-based `current` to `active` and `completed`, and `orientation="vertical"` to `vertical` |
| `dm_nested_menu`, `dm_nested_menu_item` | `dm_left_menu` and `dm_left_menu_group`; map groups to `:menu` slots and item state to stable IDs with `active` |

Native Core primitives retain their upstream CSS without Phoenix modules, stories,
or dedicated wrapper tests. Do not add a new wrapper merely to show a CSS class.

```heex
<.dm_stepper vertical clickable>
  <:step :for={{step, index} <- Enum.with_index(@steps)}
    label={step.label}
    description={step[:description]}
    active={index == @current}
    completed={index < @current}
    disabled={step[:disabled]}
    on_click={JS.push("select-step", value: %{step: index})} />
</.dm_stepper>
```

The LiveView handles `select-step` and owns `@current`; the old element's automatic
client state and `change` event are not retained. The canonical Core stepper
supports its documented color/variant set; old arbitrary colors/icons require an
explicit application design rather than forwarding unsupported element attributes.

```heex
<.dm_left_menu nav_label="Workspace">
  <:menu>
    <.dm_left_menu_group active="reports">
      <:title>Workspace</:title>
      <:menu id="reports" to="/reports">Reports</:menu>
    </.dm_left_menu_group>
  </:menu>
</.dm_left_menu>
```

LeftMenu uses Phoenix `navigate` links; it is the canonical grouped sidebar API.
For standalone ordinary `href` lists or Core's compact/bordered modifiers, use native
`<ul class="nested-menu nested-menu-bordered nested-menu-compact">` markup.
The duplicate Steps/NestedMenu Storybook pages and routes are removed.

`dm_badge`, `dm_card`, and `dm_async_card` keep their Phoenix attributes and slots,
but render native Core markup without element registration or shadow DOM.
Update custom selectors, `::part` styling and DOM queries accordingly:

- Badge uses `.badge`, color, outlined/soft and dot classes. `soft` takes precedence
  over `outline`. `accent` remains mapped to tertiary. Ghost uses transparent
  Tailwind utilities; `xs` retains the former default-size fallback (`badge-md`),
  and `pill` uses `rounded-full` (Core badges are already rounded). Dot labels are
  visually hidden but remain accessible. Dot dimensions follow Core.
- Card uses `.card`, `.card-image`, `.card-body`, `.card-title`, `.card-actions`.
  `body_class` now styles the actual Core body rather than a nested wrapper.
  Padding maps to Core's `--card-p`; shadow uses literal Tailwind utilities.
  `interactive` retains focus and Enter/Space click activation on the card itself;
  nested native controls retain their own keyboard handling.
- Async loading keeps image/content skeletons; failures show the existing alert;
  success passes the loaded result to body and action slots. One shared native
  card layout renders all states.

Storybook removes 27 unused/obsolete lazy registrar entries (24 already unused,
plus badge/card/stepper), and 25 root direct package declarations (the two unused art entries were transitive).
Elements/Art Elements aggregates remain part of the public dependency contract,
so those packages can still be installed transitively. Theme bridge support for
other direct custom-element consumers remains; only badge/card/stepper selectors
are removed. Button and its registration are unchanged.

The local Tailwind loader now preserves the official `theme, base, components,
utilities` layer order when expanding `@import "tailwindcss"`. Without it, Core
component rules loaded after utilities masked card shadows and ghost badges.
This fixes the loader rather than adding local component CSS overrides.

Cleanup validation:

- 169 focused Phoenix component tests and 13 Storybook tests passed.
- All 15 Tailwind tests passed, including layer precedence before/after minification.
- Changed-file formatting, warnings-as-errors compilation and both asset builds passed.
  Storybook retains its existing single-bundle fallback for ambiguous split exports.
- Desktop Chrome confirmed native Badge/Card rendering, both themes, ghost transparency,
  card padding/image/shadow variants, Enter/Space activation, and a single click from
  a nested native button. Stepper uses named native buttons; old navigation links are absent.
  No console warnings/errors on the checked Card page.
- The earlier full-suite icon/QuickBEAM/CDP timeouts below remain unresolved; the full
  suite was not rerun for cleanup. The focused tests are not a claim of full-suite success.

## 2026-09-24 synchronization (before cleanup)

| Package | Before | Target / decision |
| --- | --- | --- |
| `@duskmoon-dev/core` | 1.19.9 | 1.19.10 |
| `@duskmoon-dev/css-art` | 1.19.9 | 1.19.10 |
| `@duskmoon-dev/elements` | 1.7.6 | 1.8.0 |
| `@duskmoon-dev/art-elements` | 1.7.6 | 1.8.0 |
| Declared `@duskmoon-dev/el-*` packages | 1.7.6 or 1.8.0 | 1.8.0 |
| `@duskmoon-dev/components` | Not installed | Reviewed 0.3.1; no required React integration |
| `@duskmoon-dev/art-components` | Not installed | Reviewed 0.3.1; existing CSS Art / element integration retained |

The comparison uses published tarballs. Core changes the horizontal join selectors
so they no longer affect vertical groups. CSS Art styles are unchanged. Existing
Elements and Art Elements public types and ESM runtime code are unchanged after
excluding generated source-path/debug comments; their dependency versions change.

- **Update:** expose `dm_join orientation="vertical"` using Core's fixed CSS;
  preserve horizontal as the default, and remove the obsolete upstream TODO.
- **Keep existing implementations:** the new Elements exports for carousel,
  countdown, diff, dropdown, fab, filter-group, footer, hero, indicator, join,
  kbd, link, loading, mask, megamenu, radial-progress, range, sidebar-layout,
  stack, stat, swap, toggle-switch, file-input and validator overlap existing
  Core/native controls, layout or form behavior. They do not require new wrappers
  or registrations in this synchronization.
- **No new page wrappers:** console-page, home-page and sign-page are application
  page-shell compositions, outside the current component synchronization scope.
- **No removals:** no previously consumed upstream export was removed.
- **React packages:** both use React/ReactDOM peers. Their exports were inventoried;
  introducing a React island is unnecessary for the changed join/art contracts.

Bun updates the root and Phoenix manifests and `bun.lock`. Storybook uses
`workspace:*` for the Phoenix package so the lockfile no longer retains an old
`file:` dependency snapshot with stale nested Duskmoon versions. The existing
`package-lock.json` is an older npm snapshot and is not the update source.
Validation for this synchronization:

- Both configured bundles built in `MIX_ENV=test`; Storybook's bundler used its
  single-bundle fallback after detecting ambiguous split exports.
- `MIX_ENV=test mix compile --warnings-as-errors` and changed-file formatting passed.
- Focused component and Storybook tests: 18 + 12 passed.
- Desktop Chrome DevTools checks passed for join corners/orientation in both themes,
  native button focus, Accordion registration/toggling, and Gemini Art registration/input.
- The isolated join browser test (subsequently removed with the wrapper) was blocked by CDP timeouts. The existing
  hoisted registrar browser test also timed out through the same helper.
- The umbrella run (`mix test --max-failures 5`) did not pass: five Phoenix tests
  timed out in icon loading and bundler tests timed out in QuickBEAM/CDP. The run
  was interrupted after these failures; remaining tests were not completed.

The following version inventory records the earlier 2026-09-22 synchronization.

## Exact dependency versions

The root manifest pins every existing dependency below. The Phoenix npm manifest
also pins Core, CSS Art, Elements and Art Elements to the same versions.

| Package | Before | After |
| --- | --- | --- |
| `@duskmoon-dev/art-elements` | 1.7.2 | 1.7.6 |
| `@duskmoon-dev/core` | 1.18.1 | 1.19.9 |
| `@duskmoon-dev/css-art` | 1.18.1 | 1.19.9 |
| `@duskmoon-dev/el-accordion` | 1.7.2 | 1.8.0 |
| `@duskmoon-dev/el-alert` | 1.7.2 | 1.8.0 |
| `@duskmoon-dev/el-art-gemini-input` | 1.7.2 | 1.7.6 |
| `@duskmoon-dev/el-autocomplete` | 1.7.2 | 1.8.0 |
| `@duskmoon-dev/el-base` | 1.7.2 | 1.8.0 |
| `@duskmoon-dev/el-badge` | 1.7.2 | 1.8.0 |
| `@duskmoon-dev/el-bottom-navigation` | 1.7.2 | 1.8.0 |
| `@duskmoon-dev/el-bottom-sheet` | 1.7.2 | 1.8.0 |
| `@duskmoon-dev/el-breadcrumbs` | 1.7.2 | 1.8.0 |
| `@duskmoon-dev/el-button` | 1.7.2 | 1.8.0 |
| `@duskmoon-dev/el-card` | 1.7.2 | 1.8.0 |
| `@duskmoon-dev/el-cascader` | 1.7.2 | 1.7.6 |
| `@duskmoon-dev/el-chat` | 1.7.2 | 1.7.6 |
| `@duskmoon-dev/el-chip` | 1.7.2 | 1.7.6 |
| `@duskmoon-dev/el-circle-menu` | 1.7.2 | 1.7.6 |
| `@duskmoon-dev/el-code-block` | 1.7.2 | 1.7.6 |
| `@duskmoon-dev/el-code-engine` | 1.7.2 | 1.7.6 |
| `@duskmoon-dev/el-datepicker` | 1.7.2 | 1.7.6 |
| `@duskmoon-dev/el-datetime` | 1.7.2 | 1.7.6 |
| `@duskmoon-dev/el-drawer` | 1.7.2 | 1.7.6 |
| `@duskmoon-dev/el-file-upload` | 1.7.2 | 1.7.6 |
| `@duskmoon-dev/el-form` | 1.7.2 | 1.7.6 |
| `@duskmoon-dev/el-form-group` | 1.7.2 | 1.7.6 |
| `@duskmoon-dev/el-input` | 1.7.2 | 1.7.6 |
| `@duskmoon-dev/el-markdown` | 1.7.2 | 1.7.6 |
| `@duskmoon-dev/el-markdown-input` | 1.7.2 | 1.7.6 |
| `@duskmoon-dev/el-menu` | 1.7.2 | 1.7.6 |
| `@duskmoon-dev/el-navbar` | 1.7.2 | 1.7.6 |
| `@duskmoon-dev/el-navigation` | 1.7.2 | 1.7.6 |
| `@duskmoon-dev/el-nested-menu` | 1.7.2 | 1.7.6 |
| `@duskmoon-dev/el-otp-input` | 1.7.2 | 1.7.6 |
| `@duskmoon-dev/el-pagination` | 1.7.2 | 1.7.6 |
| `@duskmoon-dev/el-pin-input` | 1.7.2 | 1.7.6 |
| `@duskmoon-dev/el-pro-data-grid` | 1.7.2 | 1.7.6 |
| `@duskmoon-dev/el-progress` | 1.7.2 | 1.7.6 |
| `@duskmoon-dev/el-segment-control` | 1.7.2 | 1.7.6 |
| `@duskmoon-dev/el-select` | 1.7.2 | 1.7.6 |
| `@duskmoon-dev/el-slider` | 1.7.2 | 1.7.6 |
| `@duskmoon-dev/el-stepper` | 1.7.2 | 1.7.6 |
| `@duskmoon-dev/el-switch` | 1.7.2 | 1.7.6 |
| `@duskmoon-dev/el-table` | 1.7.2 | 1.7.6 |
| `@duskmoon-dev/el-tabs` | 1.7.2 | 1.7.6 |
| `@duskmoon-dev/el-theme-controller` | 1.7.2 | 1.7.6 |
| `@duskmoon-dev/el-time-input` | 1.7.2 | 1.7.6 |
| `@duskmoon-dev/elements` | 1.7.2 | 1.7.6 |

Elements 1.7.6 pins its aggregate dependencies to 1.7.6. Ten direct packages
have a newer published 1.8.0; their public types remain compatible. We register
individual packages lazily in Storybook. Unpublished 1.8.0 aggregate components
are not assumed available and no dependencies on them are introduced.

## Public component mapping

Core 1.19.9 adds 32 public CSS component modules relative to 1.18.1; none are removed.

| Upstream additions | Phoenix integration |
| --- | --- |
| carousel, countdown, diff, kbd, radial-progress | New native DataDisplay components |
| fab, swap | New native Action components |
| filter-group | New native DataEntry component |
| hero, indicator, join, mask, sidebar-layout, stack | New Layout components |
| megamenu | New native Navigation component |
| breadcrumbs, dropdown, file-input, footer, link, menu, navbar, pagination, range, tabs, toggle-switch | Existing Phoenix components preserve their native or Elements APIs; new CSS is available through the aggregate import |
| loading, stat | Existing spinner and stat markup now uses upstream component classes |
| validator | Opt-in class on native input controls; server error messages and application validation remain application-owned |
| console-page, home-page, sign-page | Optional page composition CSS included in the bundle; application page templates are not new public Phoenix components |

Existing native dialog/popover contracts remain intact. Core's regular-element
Modal styling does not replace the library's native dialog implementation.
Menu, drawer and bottom-sheet retain Elements behavior because replacing their
methods and events would be a breaking change. Their former Core blocker #61 is resolved.

The new native components require no registration. Timers, progress values,
filter updates, and layout state are supplied by applications. Slots accept normal
Phoenix components and native controls, preserving form and navigation behavior.

Sunshine keeps the same token names with updated semantic contrast values;
Moonlight is unchanged. The theme bridge inherits these values without local
color overrides. Core plugin entrypoint paths remain compatible, and component
and theme exports now also include a CSS default condition.

## Elements and CSS Art

All 43 directly declared non-art Elements packages, including `el-base`, were
compared using their published old/new type contracts. Chat gains its timeline
setting, scroll wrapper, and File attachment event contract. Chip gains semantic interaction attributes and
`dm-click`, `dm-change`, and `dm-delete` events. Markdown input synchronizes its
observed attributes upstream without requiring a Phoenix wrapper change.

Lazy registration recognizes standalone chat subcomponents, including chat scroll.
The existing code-engine registration behavior is preserved. Element theme selectors
remain valid; the new chat scroll wrapper does not introduce host theme defaults.

All 15 individual CSS Art stylesheets (excluding the aggregate `index.css`) and
all 15 art element public type contracts are unchanged.
Every used art stylesheet, registration and required bridge selector is already present.
There are no removed art components and no new decorative wrappers are needed.

## Resolved compatibility code

- Core #43: removed local collapse padding overrides; shipped CSS now handles the closed state.
- Elements #65: removed the Object.values highlighting patch; shipped `el-code-engine` imports oneDark explicitly.
- Elements #66: removed inline form submission from `dm_btn`; shipped button runtime submits once.
- Elements #67/#68: native breadcrumb and pagination navigation remain intentional public APIs.
- Elements #74: native chip paths remain for Phoenix navigation/patching and JS delete commands;
  new Elements interactions are exposed for custom-element consumers.
- Code Engine #9/#10: still open; existing marked workarounds remain.

## Resolved vertical join defect

Core 1.19.10 excludes vertical groups from its horizontal corner rules, resolving
the shipped CSS defect tracked by [Core #63](https://github.com/duskmoon-dev/duskmoonui/issues/63).
Native `.join.join-vertical` and `.join.join-horizontal` groups now use the fixed rules.
Both orientations use upstream CSS without local overrides.

Storybook now declares its application script as an ES module so the lazy element
registrations execute on component story pages. Its development source root and
workspace resolution directories are absolute, so umbrella code reload cannot
resolve them from a temporary application working directory. The production build
explicitly resolves Bun's root `node_modules` directory as well as workspace apps
and dependencies, ensuring lazy imports are included in emitted assets.

## Sources and verification

- [Core releases](https://github.com/duskmoon-dev/duskmoonui/releases)
- [Elements releases](https://github.com/duskmoon-dev/duskmoon-elements/releases)
- Installed `@duskmoon-dev/core/dist/components`, themes and plugin exports.
- Published package `dist/*.d.ts`, ESM implementations, manifests and registration entrypoints.

Verification covers both built bundles, warnings-as-errors compilation, component
render tests, native browser behavior, the umbrella suite, and representative
Storybook pages in light/dark themes at desktop/mobile widths. Browser `File`
attachments require an application upload mechanism; the generic LiveView event
bridge does not serialize their binary contents.
