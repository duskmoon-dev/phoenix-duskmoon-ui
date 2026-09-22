# Upstream design alignment

This audit compares published npm tarballs, public types, runtime code and release
notes, rather than assuming compatibility from package names. Checked 2026-09-22.

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

## Deferred upstream defect

Vertical join is not exposed by `dm_join`: Core 1.19.9 applies horizontal corner
rules to vertical groups. [Core #63](https://github.com/duskmoon-dev/duskmoonui/issues/63)
tracks the required upstream fix. The Phoenix component uses the verified horizontal
contract and does not add local CSS to override it.

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
