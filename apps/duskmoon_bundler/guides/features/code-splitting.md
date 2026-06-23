# Code Splitting

Dynamic imports are automatically split into separate chunks:

```javascript
import { setup } from './core'

const admin = await import('./admin')
```

Produces:

```text
app-5e6f7a8b.js        42 KB   (entry)
app-admin-c3d4e5f6.js  86 KB   (async)
manifest.json           3 entries
```

Shared modules between chunks are extracted into common chunks to avoid duplication. CSS imported by an async chunk is emitted beside that chunk, and CSS imported by shared chunks is tracked on the shared chunk.

When a dynamic import has dependencies that would otherwise create a loading waterfall, DuskmoonBundler rewrites it through a small preload helper. The helper preloads imported JavaScript chunks and chunk-local CSS before executing the dynamic import.

Disable with `code_splitting: false` in config or `--no-code-splitting` flag.

## Manual Chunks

Control chunk boundaries explicitly:

```elixir
config :duskmoon_bundler,
  chunks: %{
    "vendor" => ["vue", "vue-router", "pinia"],
    "ui" => ["assets/src/components"]
  }
```

Bare specifiers match package names in `node_modules`. Path patterns match by directory prefix. Manual chunks work alongside automatic dynamic-import splitting.

## Manifest Metadata

Code-split builds write chunk relationships to `manifest.json`:

```json
{
  "app.js": {
    "file": "app-a1b2c3d4.js",
    "src": "app.js",
    "isEntry": true,
    "imports": ["common-11223344.js"],
    "dynamicImports": ["app-admin-c3d4e5f6.js"],
    "css": ["app-55667788.css"],
    "assets": ["logo-99aabbcc.svg"]
  }
}
```

- `file` is the emitted JavaScript or CSS file.
- `src` is present for source entry modules.
- `imports` lists static chunk dependencies.
- `dynamicImports` lists async chunks loaded through `import()`.
- `css` lists CSS files owned by the chunk.
- `assets` lists emitted non-code assets referenced by the chunk.

Use `DuskmoonBundler.Preload.tags/2` from server-rendered layouts to generate preload tags for an entry and its static chunk imports. Runtime dynamic imports handle their own dependency preloads.
