# Hologram + Duskmoon Core experiment

This is an opt-in example inside `duskmoon_storybook`, not a new UI package.
It uses the existing pinned Core styles and themes directly in Hologram templates.
`phoenix_duskmoon` does not acquire a Hologram dependency.

## Run

Use **Elixir 1.19+, OTP 28.1+, Node.js 20+ (including npm), Bun**, and the normal
published/precompiled Duskmoon toolchain. The example pins Hologram **0.12.2**.
The normal UI test matrix and dependency lock remain unchanged.

From the repository root:

```sh
scripts/with-hologram-example.sh deps.get
bun install --frozen-lockfile
scripts/with-hologram-example.sh duskmoon_bundler.build duskmoon_storybook
scripts/with-hologram-example.sh
```

Open:

- `http://localhost:4600/storybook/integrations/hologram`: Storybook page with an isolated iframe.
- `http://localhost:4600/examples/hologram`: the standalone Hologram document.

The wrapper enables `DUSKMOON_HOLOGRAM=1` and `HOLOGRAM_START=1`, uses an isolated
`_build/hologram-example` build, and seeds `_build/hologram-example.mix.lock` from
`mix.lock` on first use. Extra Hologram dependencies resolve into that experimental
lock, not the default one. Remove only the experimental lock when intentionally
refreshing its base pins. Dependency sources still use the existing `deps` directory.
Frontend packages continue to be managed with Bun; Hologram manages its own internal
compiler dependencies. No new frontend package or custom CSS theme is introduced.

Without the opt-in flag, the Hologram dependency, compiler, source directory and test
suite are excluded. The Storybook integration page then displays setup instructions.
Do not enable the experiment in normal package or release workflows.

## Ownership boundaries

`hologram/layout.ex` loads the existing Storybook stylesheet using the bundler's
server-side asset resolver and includes `Hologram.UI.Runtime`. It does **not** load
Storybook `app.js`, LiveSocket, React or the custom-element registry. Hologram compiles
its own client runtime; the existing Duskmoon build remains responsible for CSS.
The new source directory is registered with both CSS `@source` and the explicit
bundler sources/watch directories.

`hologram/gallery.ex` owns theme, counter and synchronized-input state through local
actions. Its server initializer schedules a client-readiness action so the visible
badge changes from **Server rendered** to **Client ready** only after client execution.
There are no server commands, persistence or backend form submission in this example.

The browser owns `<dialog>` and `<details>` state. The dialog is opened with native
`command="show-modal"` / `commandfor`, and closed with Escape or `method="dialog"`.
Use a current browser supporting command invokers. The example deliberately does not
bind an `open` attribute or maintain a second modal state in Hologram. A counter button
inside the dialog tests that a Hologram render preserves its native modal state.
Navigation between Storybook and the example uses normal links, not LiveView navigation.

## Tests and screenshots

With Chrome/Chromium installed (`CHROME_BIN` may select the binary):

```sh
MIX_ENV=test scripts/with-hologram-example.sh deps.get
MIX_ENV=test scripts/with-hologram-example.sh duskmoon_bundler.build duskmoon_storybook
MIX_ENV=test scripts/with-hologram-example.sh test apps/duskmoon_storybook/hologram_test
```

The scoped suite covers pure action transitions, SSR, client hydration, styled controls,
input and checkbox updates, theme changes, absence of server commands, dialog state
through a rerender, Escape/focus restoration, form-based closing and mobile overflow.
It writes sunshine, moonlight and mobile PNGs beneath the active Mix build directory's
`hologram-screenshots` directory. Browser tests fail rather than silently skip when the
runtime, built stylesheet, browser or command-invoker support is missing.

The dedicated **Hologram Example** workflow runs the opt-in test suite separately from
the existing Elixir 1.18 / OTP 27–28 matrix and uploads the screenshots. Its dependency
lock is experimental and generated from the checked-in baseline; this is not yet a
fully locked production integration.

For manual review, inspect the iframe and standalone page at desktop and mobile sizes;
compare Sunshine/Moonlight; type into the name field; toggle the checkbox; open the
dialog, increment inside it and close with both Escape and the close button. Confirm
that the normal `/storybook` and `/components` pages still behave as before.

## References

- https://hologram.page/docs/installation
- https://hologram.page/docs/forms
- https://github.com/bartblast/hologram/releases/tag/v0.12.2

This experiment must pass the browser checks before treating the integration as
verified or extracting a reusable Hologram component package.
