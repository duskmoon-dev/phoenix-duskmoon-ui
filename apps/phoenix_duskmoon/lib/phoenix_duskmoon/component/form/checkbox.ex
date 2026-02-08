defmodule PhoenixDuskmoon.Component.Form.Checkbox do
  @moduledoc """
  Backwards-compatible re-export module.

  This module delegates to `PhoenixDuskmoon.Component.DataEntry.Checkbox`.
  Use the new module path for new code.
  """

  defdelegate dm_checkbox(assigns), to: PhoenixDuskmoon.Component.DataEntry.Checkbox
end
