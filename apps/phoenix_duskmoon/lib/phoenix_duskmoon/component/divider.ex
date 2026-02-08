defmodule PhoenixDuskmoon.Component.Divider do
  @moduledoc """
  Backwards-compatible re-export module.

  This module delegates to `PhoenixDuskmoon.Component.Layout.Divider`.
  Use the new module path for new code.
  """

  defdelegate dm_divider(assigns), to: PhoenixDuskmoon.Component.Layout.Divider
end
