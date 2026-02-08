defmodule PhoenixDuskmoon.Component.Tab do
  @moduledoc """
  Backwards-compatible re-export module.

  This module delegates to `PhoenixDuskmoon.Component.Navigation.Tab`.
  Use the new module path for new code.
  """

  defdelegate dm_tab(assigns), to: PhoenixDuskmoon.Component.Navigation.Tab
end
