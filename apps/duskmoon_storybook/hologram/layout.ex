defmodule DuskmoonStorybook.Hologram.Layout do
  @moduledoc """
  An isolated document for the Hologram integration experiment.

  Reuses the Storybook stylesheet, but deliberately does not load app.js,
  LiveSocket, React mounts or the custom-element registry.
  """

  use Hologram.Component

  alias Hologram.UI.Runtime

  @impl true
  def init(_props, component, _server) do
    stylesheet =
      DuskmoonBundler.static_path(DuskmoonStorybookWeb.Endpoint, "/assets/css/app.css",
        profile: :duskmoon_storybook
      )

    put_state(component, :stylesheet, stylesheet)
  end

  @impl true
  def template do
    ~HOLO"""
    <!DOCTYPE html>
    <html lang="en">
      <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <title>Hologram + Duskmoon Core · Storybook</title>
        <link rel="stylesheet" href={@stylesheet} />
        <Runtime />
      </head>
      <body>
        <slot />
      </body>
    </html>
    """
  end
end
