#!/bin/sh
set -eu

version=${1:?usage: alpine_native_smoke.sh VERSION}
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
mix local.hex --force
mix local.rebar --force
cat > mix.exs <<EOF
defmodule AlpineNativeSmoke.MixProject do
  use Mix.Project
  def project do
    [app: :alpine_native_smoke, version: "0.1.0", elixir: ">= 1.18.0",
     deps: [{:duskmoon_bundler, "== $version"}, {:phoenix_duskmoon, "== $version"}]]
  end
  def application, do: [extra_applications: [:logger]]
end
EOF
mix deps.get
mix deps.compile
mix run /validation/alpine_native_smoke.exs
