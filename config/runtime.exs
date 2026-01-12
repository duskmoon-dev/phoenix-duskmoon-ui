import Config

config :tailwind,
  tailwind_path: System.get_env("TAILWIND_PATH", "tailwindcss")

config :bun,
  bun_path: System.get_env("BUN_PATH", "bun")

if System.get_env("PHX_SERVER") do
  config :duskmoon_storybook_web, DuskmoonStorybookWeb.Endpoint, server: true
end

if config_env() == :prod do
  secret_key_base =
    System.get_env(
      "SECRET_KEY_BASE",
      "MZp9owsA4KMpak7Pxu/sPIs3dKPx95C0gpRvAI3LsKnq54Gxtl9ZMyzQF9xa8X5q"
    )

  config :duskmoon_storybook_web, DuskmoonStorybookWeb.Endpoint,
    http: [
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: String.to_integer(System.get_env("PORT", "4600"))
    ],
    secret_key_base: secret_key_base
end
