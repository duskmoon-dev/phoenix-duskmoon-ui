defmodule PhoenixDuskmoon.Component.Form.Select do
  @moduledoc """
  Backwards-compatible re-export module.

  This module delegates to `PhoenixDuskmoon.Component.DataEntry.Select`.
  Use the new module path for new code.
  """

  defdelegate dm_select(assigns), to: PhoenixDuskmoon.Component.DataEntry.Select
end
