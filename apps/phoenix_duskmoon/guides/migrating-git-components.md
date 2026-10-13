# Migrating Git repository components

The unreleased removal of Git repository components is a **breaking API change**.
Phoenix Duskmoon continues to provide foundation controls, icons, styles and
LiveView integration. Applications own their Git repository presentation and
navigation policy.

## Removed API

`PhoenixDuskmoon.Component.DataDisplay.GitRepository` and its automatic import
through `use PhoenixDuskmoon.Component` are removed, including all six helpers:

- `dm_git_repository_header/1`
- `dm_git_repository_nav/1`
- `dm_git_file_tree/1`
- `dm_git_blob_viewer/1`
- `dm_git_commit_diff/1`
- `dm_git_clone_box/1`

Their Storybook stories, gallery pages and routes are also removed. This change
does not remove the general-purpose `dm_diff`, dialog, popover, table, breadcrumb
or pagination components.

The package JavaScript runtime no longer exports `copyTextToClipboard`,
`handleClipboardClick` or `installClipboardBehavior`, or installs delegated copy
behavior for `data-copy-value`, `data-copy-label` and `data-copy-status`. The
confirm-dialog runtime and existing LiveView hooks remain available.

## Application migration

Before adopting a release containing this removal:

1. Replace imports and every `dm_git_*` invocation with application-owned Phoenix
   components. Keep repository authorization, Git reads and route construction in
   the application's existing boundaries; pass prepared presentation values and
   links into the renderers.
2. If adopting implementations from an earlier Phoenix Duskmoon release, retain
   the MIT copyright and permission notice. Maintain the copied code and its
   behavior tests in your application rather than editing dependency source.
3. Provide application-owned clipboard handling for blob content, clone URLs and
   commands. Include accessible success/failure feedback and preserve fallback
   copying and focus restoration where your application requires them. Use
   application-specific selectors to avoid duplicate handlers during migration.
4. Include the new component source in your Tailwind scan and verify escaping,
   keyboard navigation, active tabs, empty/binary/truncated states and copy
   interactions before upgrading the dependency.

Fornacast adopts these renderers in its internal `fornacast_component` umbrella
application. That app is **not a published Hex or npm replacement package**, and
external Phoenix Duskmoon consumers do not receive it automatically. Other
applications must provide their own components or explicitly adopt appropriately
licensed code; adding a dependency named `fornacast_component` is not a supported
package migration.
