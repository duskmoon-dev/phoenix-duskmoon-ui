defmodule PhoenixDuskmoon.Component.Form.CompactInput do
  @moduledoc """
  Backwards-compatible re-export module.

  This module delegates to `PhoenixDuskmoon.Component.DataEntry.CompactInput`.
  Use the new module path for new code.
  """

  defdelegate dm_compact_input(assigns), to: PhoenixDuskmoon.Component.DataEntry.CompactInput
end
