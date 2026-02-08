defmodule PhoenixDuskmoon.Component.Dropdown do
  @moduledoc """
  Backwards-compatible re-export module.

  This module delegates to `PhoenixDuskmoon.Component.Action.Dropdown`.
  Use the new module path for new code.
  """

  defdelegate dm_dropdown(assigns), to: PhoenixDuskmoon.Component.Action.Dropdown
end
