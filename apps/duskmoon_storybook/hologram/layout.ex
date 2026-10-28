defmodule DuskmoonStorybook.Hologram.Layout do
  @moduledoc """
  The content document embedded by the shared Phoenix demo layout.

  Phoenix owns the appbar, theme controls and dm_left_menu. This document loads
  only the Hologram runtime and the shared stylesheet for the demo content.
  """

  use Hologram.Component

  alias Hologram.UI.Runtime

  prop :title, :string, default: "Hologram"

  @impl true
  def init(_props, component, _server) do
    stylesheet =
      DuskmoonBundler.static_path(DuskmoonStorybookWeb.Endpoint, "/assets/css/app.css",
        profile: :duskmoon_storybook
      )

    component
    |> put_state(stylesheet: stylesheet, ready: false)
    |> put_action(:client_ready)
  end

  @impl true
  def action(:client_ready, _params, component), do: put_state(component, :ready, true)

  @impl true
  def template do
    ~HOLO"""
    <!DOCTYPE html>
    <html lang="en">
      <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <title>{@title} · Duskmoon Hologram</title>
        <link rel="stylesheet" href={@stylesheet} />
        <Runtime />
      </head>
      <body id="hologram-shell" data-ready={if(@ready, do: "true", else: "false")} class="bg-surface text-on-surface">
        <div class="card w-full">
          <div class="card-body p-4 md:p-8"><slot /></div>
        </div>
      </body>
    </html>
    """
  end
end
