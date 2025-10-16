import Config

config :duskmoon_storybook,
  namespace: DuskmoonStorybook

config :duskmoon_storybook_web,
  namespace: DuskmoonStorybookWeb,
  generators: [context_app: :duskmoon_storybook]

config :duskmoon_storybook_web, DuskmoonStorybookWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: DuskmoonStorybookWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: DuskmoonStorybook.PubSub,
  live_view: [signing_salt: "HkF5qV0r"]

config :duskmoon_storybook_web, DuskmoonStorybookWeb.Storybook,
  content_path: Path.expand("../apps/duskmoon_storybook_web/storybook", __DIR__),
  otp_app: :duskmoon_storybook_web,
  title: "Phoenix Duskmoon UI Storybook",
  js_path: "/assets/app.js",
  css_path: "/assets/app.css"

config :tailwind,
  version: "4.1.11",
  duskmoon: [
    args: ~w(
      --input=assets/css/phoenix_duskmoon.css
      --output=priv/static/phoenix_duskmoon.css
    ),
    cd: Path.expand("../apps/phoenix_duskmoon", __DIR__),
    env: %{"NODE_PATH" => "#{Path.expand("../deps", __DIR__)}:#{Path.expand("../apps", __DIR__)}"}
  ],
  storybook: [
    args: ~w(
      --input=assets/css/app.css
      --output=priv/static/assets/app.css
    ),
    cd: Path.expand("../apps/duskmoon_storybook_web", __DIR__),
    env: %{"NODE_PATH" => "#{Path.expand("../deps", __DIR__)}:#{Path.expand("../apps", __DIR__)}"}
  ]

config :bun,
  version: "1.2.13",
  duskmoon: [
    args: ~w(build assets/js/phoenix_duskmoon.js --outdir=priv/static/),
    cd: Path.expand("../apps/phoenix_duskmoon", __DIR__),
    env: %{"NODE_PATH" => "#{Path.expand("../apps", __DIR__)}:#{Path.expand("../deps", __DIR__)}"}
  ],
  storybook: [
    args: ~w(build assets/js/app.js --bundle --outdir=priv/static/assets),
    cd: Path.expand("../apps/duskmoon_storybook_web", __DIR__),
    env: %{"NODE_PATH" => "#{Path.expand("../deps", __DIR__)}:#{Path.expand("../apps", __DIR__)}"}
  ]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

import_config "#{config_env()}.exs"
