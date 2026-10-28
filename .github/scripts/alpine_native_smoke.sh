#!/bin/sh
set -eu

version=${1:?usage: alpine_native_smoke.sh B [U]}
ui_version=${2:-}
case "$version" in
  *[!0-9.]*|'') echo "Expected a stable numeric release version" >&2; exit 2 ;;
esac

# A fresh consumer must use published precompiled NIFs, without build tools or
# source-build/target overrides. Run inside the official Alpine Elixir image.
for tool in cargo rustc zig; do
  if command -v "$tool" >/dev/null 2>&1; then
    echo "Unexpected source-build tool: $tool" >&2
    exit 1
  fi
done
for variable in DUSKMOON_BUILD_NATIVE_FROM_SOURCE OXC_EX_BUILD OXC_FMT_BUILD OXC_LINT_BUILD OXIDE_EX_BUILD VIZE_EX_BUILD QUICKBEAM_BUILD TARGET_ARCH TARGET_OS TARGET_ABI; do
  if printenv "$variable" >/dev/null 2>&1; then
    echo "Unexpected native override: $variable" >&2
    exit 1
  fi
done

consumer_dir=$(mktemp -d)
trap 'rm -rf "$consumer_dir"' EXIT
cd "$consumer_dir"
export MIX_ENV=prod
export DUSKMOON_NATIVE_MODE=precompiled
ui_dep=""
if [ -n "$ui_version" ]; then
  case "$ui_version" in *[!0-9.]*|'') exit 2 ;; esac
  ui_dep=", {:phoenix_duskmoon, \"== $ui_version\"}"
fi
elixir -r /validation/release_support.exs -e '
  [expected] = System.argv()
  unless ReleaseSupport.bundler_version!("/validation/mix.lock") == expected,
    do: raise("requested Bundler version differs from the repository lockfile")
  lock = ReleaseSupport.bundler_lock!("/validation/mix.lock")
  File.write!("mix.lock", inspect(lock, limit: :infinity))
' "$version"
mix local.hex --force
mix local.rebar --force
cat > mix.exs <<EOF
defmodule AlpineNativeSmoke.MixProject do
  use Mix.Project
  def project do
    [app: :alpine_native_smoke, version: "0.1.0", elixir: ">= 1.18.0",
     compilers: Mix.compilers() ++ [:hologram],
     deps: [
       {:duskmoon_bundler, "~> 10.0"},
       {:duskmoon_bundler_runtime, "~> 10.0"},
       {:duskmoon_oxc, "~> 10.0"}, {:duskmoon_oxide, "~> 10.0"},
       {:duskmoon_vize, "~> 10.0"}, {:duskmoon_quickbeam, "~> 10.0"},
       {:duskmoon_npm, "~> 10.0"}, {:duskmoon_hex_solver, "~> 10.0"},
       {:duskmoon_hologram, "~> 10.0"}$ui_dep]]
  end
  def application, do: [extra_applications: [:logger]]
end
EOF
mix deps.get
elixir -r /validation/release_support.exs -e '
  ReleaseSupport.immutable_action(
    ReleaseSupport.bundler_lock!(),
    ReleaseSupport.bundler_lock!("/validation/mix.lock")
  )
'
mix deps.compile
mix run /validation/alpine_native_smoke.exs
if [ -n "$ui_version" ]; then
  mix run -e 'true = Code.ensure_loaded?(PhoenixDuskmoon)'
fi
