# CI and Reproducibility

Commit both `package.json` and `npm.lock`.

In CI, use frozen installs:

```bash
mix npm.ci
```

or:

```bash
mix npm.install --frozen
```

Frozen mode fails when `package.json` and `npm.lock` do not agree. This prevents CI from silently resolving a different dependency graph than the one reviewed in source control.

## Verify installed state

After install, verify that `node_modules/` matches the lockfile:

```bash
mix npm.verify
```

This reports missing or extraneous packages.

## Recommended CI sequence

```bash
mix deps.get
mix npm.ci
mix npm.verify
mix test
```

If you enforce malicious-package checks offline, add:

```bash
mix npm.audit --compromised
```

A typical stricter pipeline:

```bash
mix deps.get
mix npm.ci
mix npm.verify
mix npm.audit --compromised
mix test
```

## Updating malicious-package intelligence

Use a scheduled job or a developer machine to refresh OSV/OpenSSF matches for the current lockfile:

```bash
mix npm.audit --osv --write-cache --policy warn
```

Then CI can run deterministic offline checks:

```bash
mix npm.audit --compromised
```

For a strict online gate, run:

```bash
mix npm.audit --osv
```

Online OSV audit fails closed if OSV cannot be queried.
