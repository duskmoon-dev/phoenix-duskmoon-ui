defmodule PhoenixDuskmoon.Component.Badge do
  @moduledoc """
  Backwards-compatible re-export module.

  This module delegates to `PhoenixDuskmoon.Component.DataDisplay.Badge`.
  Use the new module path for new code.
  """

  defdelegate dm_badge(assigns), to: PhoenixDuskmoon.Component.DataDisplay.Badge
end
