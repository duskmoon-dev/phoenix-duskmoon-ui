import Config

config :duskmoon_storybook,
  namespace: DuskmoonStorybook,
  generators: [context_app: false]

config :duskmoon_storybook, DuskmoonStorybookWeb.Endpoint,
  adapter: Bandit.PhoenixAdapter,
  url: [host: "localhost"],
  render_errors: [
    formats: [html: DuskmoonStorybookWeb.ErrorHTML, json: DuskmoonStorybookWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: DuskmoonStorybook.PubSub,
  live_view: [signing_salt: "HkF5qV0r"]

config :duskmoon_storybook, DuskmoonStorybookWeb.Storybook,
  content_path: Path.expand("../apps/duskmoon_storybook/storybook", __DIR__),
  otp_app: :duskmoon_storybook,
  title: "Phoenix Duskmoon UI Storybook",
  js_path: "/assets/js/app.js",
  css_path: "/assets/css/app.css"

config :duskmoon_bundler,
  namespace: DuskmoonBundler,
  root: "apps/duskmoon_bundler/priv/ts",
  entry: "apps/duskmoon_bundler/priv/ts/dev/hmr-client.ts"

config :duskmoon_bundler, :phoenix_duskmoon,
  root: "apps/phoenix_duskmoon/assets",
  entry: "apps/phoenix_duskmoon/assets/js/phoenix_duskmoon.js",
  outdir: "apps/phoenix_duskmoon/priv/static/assets",
  resolve_dirs: ["apps", "deps"],
  format: :esm,
  hash: false,
  sourcemap: false,
  tailwind: [
    css: "apps/phoenix_duskmoon/assets/css/phoenix_duskmoon.css",
    sources: [
      %{base: "apps/phoenix_duskmoon/assets", pattern: "**/*.{css,js}"},
      %{base: "apps/phoenix_duskmoon/lib", pattern: "**/*.{ex,exs,heex}"}
    ]
  ],
  server: [
    watch_dirs: [
      "apps/phoenix_duskmoon/assets",
      "apps/phoenix_duskmoon/lib"
    ]
  ]

config :duskmoon_bundler, :duskmoon_storybook,
  root: "apps/duskmoon_storybook/assets",
  entry: "apps/duskmoon_storybook/assets/js/app.js",
  outdir: "apps/duskmoon_storybook/priv/static/assets",
  resolve_dirs: ["apps", "deps"],
  vendor_source: [
    "@duskmoon-dev/el-chat/register",
    "@duskmoon-dev/el-markdown",
    "@duskmoon-dev/el-markdown-input",
    "@duskmoon-dev/el-markdown-input/register",
    "@duskmoon-dev/el-markdown/register"
  ],
  hash: false,
  sourcemap: false,
  tailwind: [
    css: "apps/duskmoon_storybook/assets/css/app.css",
    sources: [
      %{base: "apps/duskmoon_storybook/assets", pattern: "**/*.{css,js}"},
      %{base: "apps/duskmoon_storybook/lib", pattern: "**/*.{ex,exs,heex}"},
      %{base: "apps/duskmoon_storybook/storybook", pattern: "**/*.{ex,exs,heex}"},
      %{base: "apps/phoenix_duskmoon/assets", pattern: "**/*.{css,js}"},
      %{base: "apps/phoenix_duskmoon/lib", pattern: "**/*.{ex,exs,heex}"}
    ]
  ],
  server: [
    vendor_prebundle: false,
    watch_dirs: [
      "apps/duskmoon_storybook/assets",
      "apps/duskmoon_storybook/lib",
      "apps/duskmoon_storybook/storybook",
      "apps/phoenix_duskmoon/assets",
      "apps/phoenix_duskmoon/lib"
    ]
  ]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

import_config "#{config_env()}.exs"
