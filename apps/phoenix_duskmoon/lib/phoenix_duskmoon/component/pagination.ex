defmodule PhoenixDuskmoon.Component.Pagination do
  @moduledoc """
  Backwards-compatible re-export module.

  This module delegates to `PhoenixDuskmoon.Component.DataDisplay.Pagination`.
  Use the new module path for new code.
  """

  defdelegate dm_pagination(assigns), to: PhoenixDuskmoon.Component.DataDisplay.Pagination
  defdelegate dm_pagination_thin(assigns), to: PhoenixDuskmoon.Component.DataDisplay.Pagination
end
