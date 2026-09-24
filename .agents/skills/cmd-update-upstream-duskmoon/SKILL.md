---
name: cmd-update-upstream-duskmoon
description: Synchronize this Phoenix library with published duskmoon-dev npm packages, including component additions, updates, removals, and integration verification.
---

# Synchronize upstream Duskmoon packages

Use this skill only for synchronizing these published upstream packages and the supporting `@duskmoon-dev/el-*` element packages they require:

```text
@duskmoon-dev/core
@duskmoon-dev/css-art
@duskmoon-dev/elements
@duskmoon-dev/art-elements
@duskmoon-dev/components
@duskmoon-dev/art-components
```

It does not commit, merge, release, publish, or create upstream issues unless the user separately requests that work.

## Upstream package selection

Choose the smallest upstream package that matches the component's behavior:

| Need | Package and integration path |
| --- | --- |
| Styling, design tokens, themes, and ordinary layout or components | `@duskmoon-dev/core` through its Tailwind CSS plugin and component classes |
| Pure CSS decorative illustrations | `@duskmoon-dev/css-art` through CSS imports and Phoenix art components |
| A structurally complex element with a stable custom-element contract | The complete `@duskmoon-dev/elements` registry, or the smallest matching `@duskmoon-dev/el-*` package, through its `<el-dm-*>` registration path |
| A CSS art illustration exposed as a custom element | `@duskmoon-dev/art-elements` or its matching `@duskmoon-dev/el-art-*` package through its `<el-dm-art-*>` registration path |
| Rich client-side interaction or stateful behavior that cannot be expressed by server-rendered HEEX and CSS | `@duskmoon-dev/components` through an explicit React mount boundary and its published client API |
| Rich interactive CSS art requiring React | `@duskmoon-dev/art-components` through an explicit React mount boundary and its published client API |

Start with `@duskmoon-dev/core` for normal UI and `@duskmoon-dev/css-art` for pure CSS art. Use Elements when structure or encapsulated element behavior justifies a custom element; prefer a matching `@duskmoon-dev/el-*` or `@duskmoon-dev/el-art-*` package when the complete registry is unnecessary. Use Components or Art Components only when the interaction model requires the React client package. React packages must be mounted from JavaScript and must not be rendered directly as HEEX or treated as custom elements. Check React/ReactDOM requirements, mount and unmount behavior, props serialization, and LiveView patch boundaries. Do not add an Elements, Art Elements, Components, or Art Components dependency merely because an equivalent Core/CSS Art class or Phoenix behavior already satisfies the requirement. Verify the package's shipped exports and public contract before choosing a path.

If the user requests a dry run, inspect package metadata and shipped files in a temporary location. Do not modify manifests, install packages into this workspace, or run update/write commands. Report the package and component plan, then stop.

## 1. Discover package changes

1. Record the six required packages above in the root and app manifests, plus `bun.lock` (the Bun lockfile is authoritative for updates). Include any supporting `@duskmoon-dev/el-*` and `@duskmoon-dev/el-art-*` packages used by the integration. Check the registry for current versions and preserve exact-version policy. Treat each package as independently versioned.
2. Compare the old and new shipped contracts. Inspect Core CSS exports, themes, tokens, and plugin entrypoints; CSS Art files and selectors; Elements and Art Elements custom-element exports, attributes, properties, slots, events, parts, and registration entrypoints; and Components and Art Components React exports, peer dependencies, props, events, and mount requirements. Do not infer a component contract from its package name.
3. Update the six required packages when they are declared or used by this repository. Add a package only when a component or integration in this repository needs it. For one custom element or art element, prefer its `@duskmoon-dev/el-*` or `@duskmoon-dev/el-art-*` package over a complete registry. Outside a dry run, update manifests with Bun and install `bun.lock`; inspect any other lockfile for drift without using it as the update source.
4. If no package version changed, still inspect the requested component contract before reporting a no-op.

## 2. Choose the component path

For every upstream component affected by the package change, choose exactly one package path and one lifecycle path (`Add`, `Update`, or `Remove`), and record both reasons. A Phoenix wrapper is an integration boundary: it should expose the smallest stable API needed by this repository while delegating styling and client behavior to the selected upstream package.

### Add

Add a Phoenix component only when the selected upstream package exposes a stable public contract that belongs in this library's public component set. Prefer a Core class-based HEEX component or a CSS Art import; choose an Elements or Art Elements wrapper for a structurally complex custom element; choose Components or Art Components only when rich React client-side interaction is required. For React packages, add the JavaScript mount entrypoint and explicit LiveView mount/unmount boundary in addition to the Phoenix wrapper. Add the module under `apps/phoenix_duskmoon/lib/phoenix_duskmoon/component/` or `art_component/`, its `attr` and `slot` declarations, the import in `component.ex` or `art_component.ex`, focused render or behavior tests, a Storybook example, and public documentation. Include custom-element registration and theme-bridge selectors only when the selected package needs them. Do not create wrappers for every upstream CSS or Art file. Native markup such as `<kbd class="kbd">` or a `join`, `mask`, `stack`, `indicator`, or `hero` container needs no Phoenix wrapper when Core already supplies the entire behavior. Before adding an API, check existing components for the same responsibility (for example, `dm_stepper` and `dm_left_menu`); extend or reuse the canonical API instead of adding a second wrapper.

### Update

Update an existing wrapper when its selected package or upstream tag, class, attribute, property, slot, event, registration, theme token, client API, CSS selector, or native behavior changed. Re-evaluate package selection during the update: migrate back to Core or CSS Art when client behavior is no longer needed, or migrate to Elements, Art Elements, Components, or Art Components when the new contract requires it. For React packages, check React entrypoints, props serialization, LiveView patch behavior, and unmount cleanup. Search its module, tests, Storybook story, documentation, `element-theme-bridge.css`, lazy registrar map, client hooks and mount entrypoints, CSS Art imports, and art-element imports together. Preserve the Phoenix API where possible; document an intentional breaking change when the upstream contract requires it. Remove obsolete compatibility code only after the new shipped contract provides the behavior.

### Remove

Remove a wrapper only when the upstream component is removed, renamed with a migration path, or no longer belongs in this library. First search all repository consumers and identify whether the replacement is a Core/CSS Art component, an Elements/Art Elements custom element, a Components/Art Components client component, or an existing Phoenix-native implementation. Then remove the module, `component.ex` or `art_component.ex` import, tests, stories, documentation, registrar entries, client hooks and mount entrypoints, React-only dependencies, bridge selectors, and unused art imports as applicable. Do not remove a still-valid native or Phoenix-only component merely because an upstream package changed.

### Block or route upstream defects

Do not hide a missing or broken upstream style with unrelated local CSS. Keep integration CSS such as `element-theme-bridge.css` only when it adapts a shipped upstream contract to Phoenix. For a dependency defect, use the repository's `upstream-github-routing` skill and report the blocker or approved workaround; do not silently create an issue or workaround.

## 3. Verify the synchronization

1. Format changed Elixir files and build both configured bundles with `mix duskmoon_bundler.build phoenix_duskmoon` and `mix duskmoon_bundler.build duskmoon_storybook`.
2. Run `mix compile --warnings-as-errors` and focused tests for each changed component. Run `mix test` for a repository-wide package update.
3. Inspect generated assets for required upstream CSS and registrations. Open representative Storybook pages in a desktop browser, checking light/dark themes, changed interactions, custom-element registration/events, native behavior, and console errors.
4. Report package version changes, each Add/Update/Remove decision, changed integration paths, validation results, and unresolved upstream blockers.
