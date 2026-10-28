#!/bin/sh
# Compatibility launcher for the Storybook Hologram demos and shared dependency lock.
set -eu
root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$root"
export HOLOGRAM_START=1
if [ "$#" -eq 0 ]; then
  set -- holo
fi
exec "$root/scripts/with-precompiled-toolchain.sh" mix "$@"
