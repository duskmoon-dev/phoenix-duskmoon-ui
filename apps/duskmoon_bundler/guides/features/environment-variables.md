# Environment Variables

## `.env` Files

Create `.env` files in your project root:

```
DUSKMOON_BUNDLER_API_URL=https://api.example.com
DUSKMOON_BUNDLER_DEBUG=true
```

Only variables prefixed with `DUSKMOON_BUNDLER_` are exposed to client code by default.

## Accessing Variables

```javascript
console.log(import.meta.env.DUSKMOON_BUNDLER_API_URL)
console.log(import.meta.env.MODE)  // "development" or "production"
console.log(import.meta.env.DEV)   // true/false
console.log(import.meta.env.PROD)  // true/false
```

## Env Prefix

Configure `env_prefix` when migrating from Vite or when your app already uses a different public-env naming convention:

```elixir
config :duskmoon_bundler, env_prefix: "VITE_"
```

Multiple prefixes are also supported:

```elixir
config :duskmoon_bundler, env_prefix: ["DUSKMOON_BUNDLER_", "PUBLIC_"]
```

## File Loading Order

Files are loaded in order, with later files overriding earlier ones:

1. `.env`
2. `.env.local`
3. `.env.{mode}` (e.g. `.env.production`)
4. `.env.{mode}.local`

The mode defaults to `"production"` for `mix duskmoon_bundler.build` and `"development"` for the dev server. Override with `--mode`.

> #### Security {: .warning}
>
> Environment variables are embedded into the built JavaScript at compile time. Never put secrets or API keys in variables matching `env_prefix` — they will be visible in the client bundle.
