# Runtime Installs with `NPM.install/2`

`NPM.install/2` installs npm packages outside a Mix project, similar to `Mix.install/2`.

```elixir
NPM.install(%{"tailwindcss" => "^4.0.0"})
```

The install is content-addressed by dependency map and cached under the configured runtime install directory.

## Locate installed packages

```elixir
NPM.install(%{"prettier" => "^3.0.0"})

NPM.install_dir!()
NPM.node_modules_dir!()
```

## Idempotency

A VM can call `NPM.install/2` repeatedly with the same dependency map. Calling it later with a different dependency map raises, mirroring `Mix.install/2` semantics.

Use `force: true` to reinstall the same dependency set:

```elixir
NPM.install(%{"prettier" => "^3.0.0"}, force: true)
```

## Configuration

Set the runtime install root with either config or env:

```elixir
config :duskmoon_npm, install_dir: "/tmp/npm-installs"
```

```bash
NPM_INSTALL_DIR=/tmp/npm-installs elixir script.exs
```

If unset, npm_ex uses a directory under the global cache root.

## Security behavior

Runtime installs use the same security defaults as project installs:

- lifecycle hooks are not executed automatically
- direct exotic dependencies require allowlisting
- transitive exotic dependencies are blocked by default
- lockfile security policy is recorded and checked
