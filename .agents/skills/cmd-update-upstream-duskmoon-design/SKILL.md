---
name: cmd-update-upstream-duskmoon-design
description: Update @duskmoon-dev frontend packages, add or remove Phoenix components to match upstream design, verify the integration, and release a patch or minor version.
---

# Update upstream Duskmoon design

Use the invoking user request as input. Keep this repository's components aligned with the design and public APIs shipped by `@duskmoon-dev/core`, `@duskmoon-dev/elements`, `@duskmoon-dev/css-art`, `@duskmoon-dev/art-elements`, and their `@duskmoon-dev/el-*` packages. A version bump alone does not complete this task.

If the user requests a dry run, perform the inventory and comparison below without changing tracked files, installing packages into this workspace, or running commands with update/write flags. Inspect available package versions and their published contents in a temporary location if needed. Report the affected components and proposed edits, then stop.

## 1. Update packages and identify changes

1. Record the current `@duskmoon-dev/*` versions in the root `package.json`, `apps/phoenix_duskmoon/package.json`, and any other workspace manifest that contains them. Check the latest published versions with `bunx npm-check-updates --filter '@duskmoon-dev/*'` or registry metadata. In a dry run, do not use `-u`, `bun add`, or `bun install`.
2. Outside a dry run, update existing `@duskmoon-dev/*` dependencies to exact current versions with `bunx npm-check-updates -u --removeRange --filter '@duskmoon-dev/*' --packageFile <manifest>` for each applicable manifest, then run `bun install`. Add a missing package only when this repository actually needs it. Record a before/after version table.
3. Compare each changed package's release notes and **shipped** old and new public contracts. Inspect Core component CSS, themes, tokens, and plugin exports; Elements package exports, types, attributes, properties, slots, events, parts, and registration entrypoints; and CSS Art files. Use the installed package and published package contents or upstream source at the matching versions. Do not infer compatibility from package names alone.
4. If versions have not changed, still check whether the user's request identifies a design mismatch in the installed version. Report a true no-op only after checking the relevant component contracts.

## 2. Align Phoenix components with upstream design

1. Inventory upstream components and compare them with this repository's modules under `apps/phoenix_duskmoon/lib/phoenix_duskmoon/component/` and `art_component/`. Map changed contracts to their focused tests under `apps/phoenix_duskmoon/test/phoenix_duskmoon/` and examples under `apps/duskmoon_storybook/storybook/`. Include components that use Core CSS and native HTML, not only wrappers around `<el-dm-*>`.
2. Update affected HEEX markup, CSS classes, theme tokens, supported variants and sizes, attributes, slots, events, hooks, and native behavior so they render and behave as the new upstream design intends. Recheck existing upstream TODO and WORKAROUND comments, and remove obsolete compatibility code when the upstream package now provides the behavior. Preserve public Phoenix component APIs where feasible; document an intentional breaking change if the new upstream contract requires one.
3. Keep styling sourced from upstream packages. Change `apps/phoenix_duskmoon/assets/css/element-theme-bridge.css` only when the new element or theme contract requires it. Do not mask an upstream defect with new local CSS; follow this repository's upstream issue routing policy.
4. Update each affected component's Storybook example, documentation, and focused render or behavior tests. Cover the changed contract rather than merely asserting that a tag or class string exists.
5. Add Phoenix components for new upstream components that belong in this library's public component set. Include the module, `attr` and `slot` declarations, import in `apps/phoenix_duskmoon/lib/phoenix_duskmoon/component.ex`, focused tests, Storybook examples, and public documentation. Remove components whose upstream contract has been removed or replaced, including their imports, registrations, examples, tests, and documentation; first check for existing consumers and the migration path. Do not retain dead wrappers or create one for every upstream CSS Art file automatically.

## 3. Synchronize element and CSS Art integration

1. Compare the `@duskmoon-dev/el-*` dependencies in the installed `elements` and `art-elements` packages with the selectors in `apps/phoenix_duskmoon/assets/css/element-theme-bridge.css` and the lazy `duskmoonElementRegistrars` map in `apps/duskmoon_storybook/assets/js/app.js`. Add registrations and bridge selectors when the new element actually needs them. Preserve special registration behavior such as code engine loading. Review removed or renamed elements and update their consumers according to the upstream migration contract.
2. Compare shipped `@duskmoon-dev/css-art/dist/art/*.css` files with imports in `apps/phoenix_duskmoon/assets/css/phoenix_duskmoon.css`. Add imports for art used by this project, and update affected art components and stories when upstream markup or classes change. Review removed or renamed files before changing imports.

## 4. Build and verify

1. Run `mix format` for changed Elixir files. Build both configured bundles with `mix duskmoon_bundler.build phoenix_duskmoon` and `mix duskmoon_bundler.build duskmoon_storybook`. Check the generated assets actually contain the required upstream CSS and registrations.
2. Run `mix compile --warnings-as-errors` and the focused tests for affected Phoenix components and Storybook behavior. Run the full `mix test` suite when this is a repository-wide package update, unless a narrower scope is required by the user's request or a PRD.
3. Open representative affected Storybook pages in a browser. Verify light and dark themes, desktop and mobile layout, interaction states, and browser console for the changed components. For custom elements, check that registration and events work; for native components, check their native behavior. Report any browser engine that was unavailable rather than counting it as a pass.
4. Summarize package version changes, affected component and design contracts, code and story updates, build/test/browser evidence, and any remaining upstream blocker.

## 5. Release the result

1. When changes are verified, bring the intended code and package changes onto `main` through the repository's normal commit and merge process. Preserve unrelated work. Fetch `origin/main` and tags, check the latest GitHub release and published package versions, and choose an unused version. Use a patch for compatible fixes and design alignment; use a minor for additive public components or compatible public API additions. Assess component removals for downstream breakage. If the result needs a major version, stop and report that it cannot be released under the requested patch-or-minor policy.
2. After the changes are on `main`, dispatch `.github/workflows/release.yml` with `gh workflow run release.yml --repo duskmoon-dev/phoenix-duskmoon-ui --ref main -f version=X.Y.Z -f git-ref=main -f reuse-native-assets=false`. The workflow owns the version bump and tag; do not pre-bump its version files separately.
3. Wait for the release workflow to finish. Verify the GitHub tag and release assets/checksums, every package published by the workflow on Hex, the npm `phoenix_duskmoon` version and provenance, and the separately dispatched Docker workflow plus Docker Hub and GHCR images. A successful release workflow alone does not prove Docker publication. Synchronize local `main` with the workflow's version commit and report the final refs and published version.
