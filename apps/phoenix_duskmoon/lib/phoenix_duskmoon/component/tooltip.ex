defmodule PhoenixDuskmoon.Component.Tooltip do
  @moduledoc """
  Backwards-compatible re-export module.

  This module delegates to `PhoenixDuskmoon.Component.DataDisplay.Tooltip`.
  Use the new module path for new code.
  """

  defdelegate dm_tooltip(assigns), to: PhoenixDuskmoon.Component.DataDisplay.Tooltip
end
