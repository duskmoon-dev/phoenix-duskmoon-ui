defmodule PhoenixDuskmoon.Component.Card do
  @moduledoc """
  Backwards-compatible re-export module.

  This module delegates to `PhoenixDuskmoon.Component.DataDisplay.Card`.
  Use the new module path for new code.
  """

  defdelegate dm_card(assigns), to: PhoenixDuskmoon.Component.DataDisplay.Card
  defdelegate dm_async_card(assigns), to: PhoenixDuskmoon.Component.DataDisplay.Card
end
