# Toolchain extraction inventory

The accompanying JSON records every tracked source file before adaptation, including all eight applications, vendored native libraries, tests, fixture resources, licenses, compiler checksums, native scripts and the bundler skill. `move` files are imported byte-for-byte; `split` root files are retained under destination `docs/migration-snapshot/` before partition. `duplicate` support files become independently maintained. `keep` files remain UI-owned. Hashes describe the source snapshot, not adapted destination files.

Source: `bca8e460adabe0454dd41125ed71a02662807767`. Destination baseline: `5251f8a29231d8cf3f8f9ff4507ad428d2b1cde6`.
