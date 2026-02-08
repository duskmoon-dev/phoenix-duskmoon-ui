defmodule PhoenixDuskmoon.Component.Flash do
  @moduledoc """
  Backwards-compatible re-export module.

  This module delegates to `PhoenixDuskmoon.Component.DataDisplay.Flash`.
  Use the new module path for new code.
  """

  defdelegate dm_flash(assigns), to: PhoenixDuskmoon.Component.DataDisplay.Flash
  defdelegate dm_flash_group(assigns), to: PhoenixDuskmoon.Component.DataDisplay.Flash
end
