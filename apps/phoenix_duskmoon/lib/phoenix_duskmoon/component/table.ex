defmodule PhoenixDuskmoon.Component.Table do
  @moduledoc """
  Backwards-compatible re-export module.

  This module delegates to `PhoenixDuskmoon.Component.DataDisplay.Table`.
  Use the new module path for new code.
  """

  defdelegate dm_table(assigns), to: PhoenixDuskmoon.Component.DataDisplay.Table
end
