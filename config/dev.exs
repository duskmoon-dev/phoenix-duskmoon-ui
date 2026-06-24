import Config

config :duskmoon_storybook_web, DuskmoonStorybookWeb.Endpoint,
  http: [ip: {0, 0, 0, 0}, port: 4600],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "BM3gjYo7YUKjr9Ye7kqOjj4t4c4dAkezwSbPFN1AJE1Tqi/aw1Kt/fNszzGoSGi9",
  watchers: [
    duskmoon_bundler_phoenix_duskmoon:
      {Mix.Tasks.DuskmoonBundler.Dev, :run, [["phoenix_duskmoon"]]},
    duskmoon_bundler_storybook:
      {Mix.Tasks.DuskmoonBundler.Dev, :run, [["duskmoon_storybook_web"]]}
  ],
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/duskmoon_storybook_web/.*(ex|heex)$",
      ~r"storybook/.*(exs)$"
    ]
  ]

config :duskmoon_storybook_web, DuskmoonStorybookWeb.Storybook,
  compilation_mode: :lazy,
  compilation_debug: true

config :duskmoon_bundler, :lint,
  tsgolint: "apps/duskmoon_bundler/node_modules/.bin/tsgolint",
  cwd: Path.expand("../apps/duskmoon_bundler", __DIR__)

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20
