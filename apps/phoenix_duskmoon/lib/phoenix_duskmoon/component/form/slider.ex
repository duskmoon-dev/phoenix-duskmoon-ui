defmodule PhoenixDuskmoon.Component.Form.Slider do
  @moduledoc """
  Backwards-compatible re-export module.

  This module delegates to `PhoenixDuskmoon.Component.DataEntry.Slider`.
  Use the new module path for new code.
  """

  defdelegate dm_slider(assigns), to: PhoenixDuskmoon.Component.DataEntry.Slider
end
