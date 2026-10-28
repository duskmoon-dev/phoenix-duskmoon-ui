# Duskmoon Hologram demos

Storybook consumes the published `duskmoon_hologram ~> 10.0` package from
[duskmoon-bundler](https://github.com/duskmoon-dev/duskmoon-bundler). Its public
modules remain `Hologram.*` and its compiler remains `:hologram`. Do not install
upstream `:hologram` alongside the fork: both define the same modules.
`phoenix_duskmoon` has no Hologram dependency; the UI umbrella still has two apps.

## Run

Use Elixir 1.18+, OTP 28+, Bun and the published precompiled Duskmoon toolchain.
All nine toolchain requirements use `~> 10.0` and resolve together in `mix.lock`.
Node.js and the npm CLI are not required for Hologram compilation.
On Linux GNU, the locked 10.0.8 native artifacts require glibc 2.43 or newer
(for example, Ubuntu 26.04). The Elixir/OTP process must run with a compatible
libc. The default glibc 2.42 environment cannot load the published Vize NIF;
use a compatible runtime environment while retaining strict precompiled mode.
See the toolchain's [supported build environments](https://github.com/duskmoon-dev/duskmoon-bundler/blob/main/docs/releasing.md).

```sh
mix deps.get
bun install --frozen-lockfile
scripts/with-precompiled-toolchain.sh mix duskmoon_bundler.build duskmoon_storybook
mix duskmoon.dev
```

`mix duskmoon.dev` delegates to `mix holo`, which enables the Hologram runtime and
compiler in development. The devenv environment also sets `HOLOGRAM_START=1`, so
`mix phx.server` works there. When running checks outside devenv, explicitly set
`HOLOGRAM_START=1`. Production builds enable the compiler automatically; releases
must start with `HOLOGRAM_ENV=prod` (the Docker image sets it).

The Hologram top menu appears immediately before Storybook. Open:

- `/hologram`: demo catalog.
- `/hologram/playground`: counter, synchronized inputs, native dialog and disclosure.
- `/hologram/tasks`: add, complete, filter and clear tasks.
- `/hologram/preferences`: display-name, density and notification preview with apply/reset.
- `/storybook/integrations/hologram`: embedded playground and link to the catalog.

The original `/examples/hologram` URL redirects to `/hologram/playground`.
`scripts/with-hologram-example.sh` remains a compatibility launcher using the normal
build directory and lockfile; there is no experimental dependency lane.

## Runtime and styling

The public `/hologram` routes use `HologramLive` with the same Phoenix root and
app layouts as Components. The appbar is the exact `dm_appbar` and
`dm_theme_switcher` used by Components and Art Components. The sidebar is the
same sticky `dm_left_menu` used by Components, populated with the Hologram demos.
It retains its DOM, collapse and group state during sidebar navigation. Shell
classes, navigation data and footer links live in `DuskmoonStorybookWeb.DemoLayout`.

Only demo content runs in a same-origin iframe. Its Hologram documents are served
at `/hologram/demos`, `/hologram/demos/playground`, `/hologram/demos/tasks` and
`/hologram/demos/preferences`. `hologram/layout.ex` loads the existing Storybook
stylesheet through `DuskmoonBundler.static_path/3` and `Hologram.UI.Runtime`.
These documents have no appbar, sidebar, footer or LiveView app bundle.
`DuskmoonHologramFrame` keeps their height fitted to the content and synchronizes
the parent theme without resetting Hologram state. The shared theme dropdown
provides Auto, Sunshine and Moonlight, using the existing `theme` preference.
Catalog links target the outer document so navigation cannot nest site shells.

Templates use published Core CSS and native HTML controls. Existing Tailwind
sources/watch directories include `hologram/**/*.ex`; there is no duplicate theme
or component stylesheet. The layout's `#hologram-shell[data-ready="true"]` marker
indicates that its initial client action has executed.

The demos keep state in the open page, without persistence or server commands.
Native forms handle task submission, including Enter. The browser owns dialog
opening, Escape, focus restoration and `method="dialog"` closing. Hologram updates
inside the dialog must preserve its native modal state. The playground requires a
current browser supporting `command` / `commandfor`.

## Verification

With Chrome/Chromium installed (`CHROME_BIN` can select its binary):

```sh
HOLOGRAM_START=1 MIX_ENV=test scripts/with-precompiled-toolchain.sh mix duskmoon_bundler.build duskmoon_storybook
HOLOGRAM_START=1 MIX_ENV=test scripts/with-precompiled-toolchain.sh mix test apps/duskmoon_storybook/hologram_test
```

Normal Storybook tests also include `hologram_test`. Tests cover state transitions,
SSR, hydration, styles, input/checkbox updates, theme changes, native modal behavior,
mobile overflow and demo navigation. Screenshots are written beneath the active
Mix build directory's `hologram-screenshots` directory. The dedicated Hologram
workflow uses the same locked dependencies and uploads these screenshots.

Production validation also runs `scripts/check-release-applications.exs` against
the actual release. It requires the Hologram runtime and retains the exclusion of
build-tool applications; consuming the framework does not relax that boundary.

The published 10.0.8 framework currently retains npm/Hex solver as runtime
dependencies. [Upstream issue #14](https://github.com/duskmoon-dev/duskmoon-bundler/issues/14)
tracks the resulting production release blocker. Do not bypass the exclusion
check; adopt a corrected published cohort and verify the actual release before
publishing or deploying this integration.
