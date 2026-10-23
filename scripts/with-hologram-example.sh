#!/bin/sh
# Run an opt-in Hologram experiment without changing the default dependency lock/build.
set -eu
root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$root"
export DUSKMOON_HOLOGRAM=1
export HOLOGRAM_START=1
export MIX_BUILD_PATH="$root/_build/hologram-example"
mkdir -p "$root/_build"
lockfile="$root/_build/hologram-example.mix.lock"
if [ ! -f "$lockfile" ]; then
  cp "$root/mix.lock" "$lockfile"
fi
if [ "$#" -eq 0 ]; then
  set -- holo
fi
exec "$root/scripts/with-precompiled-toolchain.sh" mix "$@"
