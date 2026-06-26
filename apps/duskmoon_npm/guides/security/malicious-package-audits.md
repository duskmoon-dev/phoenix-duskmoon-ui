# Malicious Package Audits

npm_ex can check installed package versions against OSV/OpenSSF malicious-package advisories.

OpenSSF publishes malicious package reports in OSV format. npm_ex uses this open data source by default-compatible design. Socket, Snyk, and Phylum provide valuable proprietary intelligence or install-time firewall workflows; those fit best as external scanners/proxies or optional integrations.

## Online OSV audit

```bash
mix npm.audit --osv
```

This queries OSV.dev for every package version in `npm.lock` and reports malicious-package matches.

Online OSV audit fails closed: if OSV cannot be queried, the Mix task fails.

## Offline compromised-package audit

```bash
mix npm.audit --compromised
```

This checks `npm.lock` against a local OSV-format database. By default the database path is:

```text
~/.npm_ex/security/compromised_packages.json
```

Override it:

```bash
mix npm.audit --compromised --db priv/security/compromised_packages.json
```

## Refresh the shared cache

```bash
mix npm.audit --osv --write-cache --policy warn
```

`--write-cache` merges matching OSV advisories for the current lockfile into the shared global cache. `--policy warn` prevents the refresh job from failing just because it found a malicious package; enforcement can happen later with the offline gate.

## Project-local advisory database

If you want to commit advisory data for a project:

```bash
mix npm.audit --osv --write priv/security/compromised_packages.json --policy warn
mix npm.audit --compromised --db priv/security/compromised_packages.json
```

`--write` also merges with existing advisory data instead of overwriting it.

## Output formats

```bash
mix npm.audit --compromised --format text
mix npm.audit --compromised --format json
```

JSON output is suitable for CI annotations or custom policy tooling.

## Policies

Compromised-package audit modes support:

```bash
--policy error
--policy warn
--policy off
```

Default is `error`. The same setting can be configured globally:

```elixir
config :duskmoon_npm, compromised_policy: :error
```

or:

```bash
NPM_EX_COMPROMISED_POLICY=warn mix npm.audit --compromised
```

## Recommended CI patterns

Deterministic offline gate:

```bash
mix npm.ci
mix npm.verify
mix npm.audit --compromised
```

Scheduled intelligence refresh:

```bash
mix npm.audit --osv --write-cache --policy warn
```

Strict online gate:

```bash
mix npm.audit --osv
```
