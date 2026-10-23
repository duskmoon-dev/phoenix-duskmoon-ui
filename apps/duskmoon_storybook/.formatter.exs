hologram? = System.get_env("DUSKMOON_HOLOGRAM") == "1"

[
  import_deps: [:phoenix] ++ if(hologram?, do: [:hologram], else: []),
  locals_without_parens: [route: 1, layout: 1],
  plugins: [Phoenix.LiveView.HTMLFormatter],
  inputs: [
    "*.{ex,exs}",
    "{config,lib,test,hologram,hologram_test}/**/*.{ex,exs,heex}",
    "storybook/integrations/hologram.story.exs"
  ]
]
