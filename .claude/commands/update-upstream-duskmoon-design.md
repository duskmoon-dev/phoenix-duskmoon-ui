---
description: Update @duskmoon-dev/core and @duskmoon-dev/elements packages, sync theme bridge + storybook registrations, rebuild assets, and verify.
---

## User Input

```text
$ARGUMENTS
```

If the user input is "dry-run" or "--dry-run", only perform Steps 1-2 and report what would change without modifying any files.

## Step 1: Update @duskmoon-dev/* packages

1. Record the **before** versions by reading `bun.lock` entries for `@duskmoon-dev/*`.
2. Run: `bun update --latest @duskmoon-dev/core @duskmoon-dev/elements`
   - This will also update all transitive `@duskmoon-dev/el-*` sub-packages.
3. Record the **after** versions from `bun.lock`.
4. Print a before/after version diff table. If nothing changed, inform the user and ask whether to continue with the remaining steps anyway.

## Step 2: Detect new custom elements

1. Read `node_modules/@duskmoon-dev/elements/package.json` and extract all `@duskmoon-dev/el-*` package names from its `dependencies` field.
2. Read `apps/phoenix_duskmoon/assets/css/element-theme-bridge.css` and extract the current list of `el-dm-*` tag selectors from the selector block (lines before the opening `{`).
3. Read `apps/duskmoon_storybook_web/assets/js/app.js` and extract the current list of `@duskmoon-dev/el-*/register` import lines.
4. Derive the canonical element tag name for each `el-*` package:
   - Package `@duskmoon-dev/el-button` → tag `el-dm-button`, import `@duskmoon-dev/el-button/register`
   - Package `@duskmoon-dev/el-foo-bar` → tag `el-dm-foo-bar`, import `@duskmoon-dev/el-foo-bar/register`
5. Compare and report:
   - **New elements**: in upstream `elements/package.json` but missing from bridge CSS or app.js
   - **Removed elements**: in bridge CSS or app.js but no longer in upstream (report only, do not auto-remove)

If this is a dry-run, stop here and report findings.

## Step 3: Update element-theme-bridge.css

If new `el-dm-*` elements were found in Step 2:

1. Read `apps/phoenix_duskmoon/assets/css/element-theme-bridge.css`.
2. Add the new element tag selectors to the comma-separated selector list (before the opening `{`), maintaining alphabetical order among the `el-dm-*` selectors.
3. Write the updated file. Do NOT change the CSS property block — only the selector list.

## Step 4: Update storybook app.js registrations

If new `el-*` elements were found in Step 2:

1. Read `apps/duskmoon_storybook_web/assets/js/app.js`.
2. Add the new `import "@duskmoon-dev/el-*/register";` lines in the element registration section (after the existing imports, before the `// Clipboard functionality` comment).
3. Keep imports in alphabetical order by package name.

## Step 5: Rebuild assets

Run these commands sequentially (each depends on the prior completing):

```bash
mix tailwind duskmoon && mix tailwind storybook && mix bun duskmoon && mix bun storybook
```

Report any build errors. If a build fails, stop and report the error — do not proceed to verification.

## Step 6: Verify

Run in parallel where possible:

1. `mix compile --warnings-as-errors` — ensure no compilation warnings
2. `mix test` — ensure all tests pass

Report results. If either fails, show the relevant error output and suggest next steps.

## Summary

After all steps, print a summary:

- Packages updated (with version changes)
- New elements added (if any)
- Build status
- Test status
