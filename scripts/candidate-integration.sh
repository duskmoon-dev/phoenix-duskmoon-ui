#!/bin/sh
set -eu
[ "$#" -eq 1 ] || { echo 'Usage: scripts/candidate-integration.sh /absolute/duskmoon-bundler' >&2; exit 2; }
ui_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
toolchain_root=$(CDPATH= cd -- "$1" && pwd)
candidate_root=${DUSKMOON_CANDIDATE_ROOT:-$(mktemp -d "${TMPDIR:-/tmp}/duskmoon-candidate.XXXXXX")}
[ ! -e "$candidate_root/ui" ] || { echo 'Candidate output already exists; choose a fresh DUSKMOON_CANDIDATE_ROOT' >&2; exit 2; }
elixir "$toolchain_root/scripts/stage-packages.exs" --output "$candidate_root/toolchain"
elixir "$ui_root/scripts/prepare-candidate.exs" "$ui_root" "$candidate_root/toolchain" "$candidate_root/ui"
cd "$candidate_root/ui"
export DUSKMOON_NATIVE_MODE=source DUSKMOON_BUILD_NATIVE_FROM_SOURCE=1 QUICKBEAM_BUILD=1 DUSKMOON_CANDIDATE_INTEGRATION=1
export MIX_DEPS_PATH="$candidate_root/ui/deps"
export MIX_BUILD_PATH="$candidate_root/ui/_build/test" MIX_ENV=test
mix deps.get
# Provision Rust and Zig 0.16.0 through the destination development environment.
# Running zig.get here initializes this project before it installs the SDK.
bun install --frozen-lockfile
mix compile --warnings-as-errors
mix test
mix prepublish
mix duskmoon_bundler.build duskmoon_storybook
bun test --cwd apps/phoenix_duskmoon
printf 'Candidate integration evidence: %s\n' "$candidate_root/ui/candidate-provenance.json"
