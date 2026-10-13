#!/bin/sh
# Native invocations from other dependencies are logged and remain permitted.
set -eu
script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
elixir -r "$script_dir/native-policy.exs" -e 'DuskmoonUI.NativePolicy.validate!()'
DUSKMOON_NATIVE_MODE=precompiled
export DUSKMOON_NATIVE_MODE
trap_dir=$(mktemp -d "${TMPDIR:-/tmp}/duskmoon-precompiled.XXXXXX")
trap 'rm -rf "$trap_dir"' EXIT HUP INT TERM
DUSKMOON_NATIVE_INVOCATION_LOG=${DUSKMOON_NATIVE_INVOCATION_LOG:-"$PWD/native-invocations.log"}
export DUSKMOON_NATIVE_INVOCATION_LOG
: > "$DUSKMOON_NATIVE_INVOCATION_LOG"
for compiler in cargo rustc zig cc gcc g++ clang clang++ cmake; do
  real=$(command -v "$compiler" || true)
  [ -n "$real" ] || real=/nonexistent
  cat > "$trap_dir/$compiler" <<'WRAPPER'
#!/bin/sh
set -eu
compiler=$(basename "$0")
printf '%s\t%s\t%s\n' "$compiler" "$PWD" "$*" >> "$DUSKMOON_NATIVE_INVOCATION_LOG"
case "$PWD $*" in
  *duskmoon_oxc*|*duskmoon_oxide*|*duskmoon_vize*|*duskmoon_quickbeam*)
    echo "Strict precompiled toolchain refused native compiler $compiler in $PWD" >&2
    exit 93 ;;
esac
WRAPPER
  printf 'exec "%s" "$@"\n' "$real" >> "$trap_dir/$compiler"
  chmod +x "$trap_dir/$compiler"
done
PATH="$trap_dir:$PATH"
export PATH
"$@"
