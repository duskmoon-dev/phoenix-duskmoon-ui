import Config

config :tailwind,
  tailwind_path: System.get_env("TAILWIND_PATH", "tailwindcss")

config :bun,
  bun_path: System.get_env("BUN_PATH", "bun")

if System.get_env("PHX_SERVER") do
  config :duskmoon_storybook_web, DuskmoonStorybookWeb.Endpoint, server: true
end

if config_env() == :prod do
  # Only require SECRET_KEY_BASE when starting the server.
  # This allows mix tasks (e.g. mix prepublish) to run in prod mode
  # without needing the secret.
  if System.get_env("PHX_SERVER") do
    secret_key_base =
      System.get_env("SECRET_KEY_BASE") ||
        raise """
        environment variable SECRET_KEY_BASE is missing.
        You can generate one by calling: mix phx.gen.secret
        """

    config :duskmoon_storybook_web, DuskmoonStorybookWeb.Endpoint,
      http: [
        ip: {0, 0, 0, 0, 0, 0, 0, 0},
        port: String.to_integer(System.get_env("PORT", "4600"))
      ],
      secret_key_base: secret_key_base
  end
end
