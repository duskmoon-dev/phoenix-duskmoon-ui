defmodule PhoenixDuskmoon.Component.Form.Input do
  @moduledoc """
  Backwards-compatible re-export module.

  This module delegates to `PhoenixDuskmoon.Component.DataEntry.Input`.
  Use the new module path for new code.
  """

  defdelegate dm_input(assigns), to: PhoenixDuskmoon.Component.DataEntry.Input
end
