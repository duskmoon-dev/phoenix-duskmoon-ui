defmodule PhoenixDuskmoon.Component.Link do
  @moduledoc """
  Backwards-compatible re-export module.

  This module delegates to `PhoenixDuskmoon.Component.Action.Link`.
  Use the new module path for new code.
  """

  defdelegate dm_link(assigns), to: PhoenixDuskmoon.Component.Action.Link
end
