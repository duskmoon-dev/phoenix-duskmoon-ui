defmodule PhoenixDuskmoon.Component.LeftMenu do
  @moduledoc """
  Backwards-compatible re-export module.

  This module delegates to `PhoenixDuskmoon.Component.Navigation.LeftMenu`.
  Use the new module path for new code.
  """

  defdelegate dm_left_menu(assigns), to: PhoenixDuskmoon.Component.Navigation.LeftMenu
  defdelegate dm_left_menu_group(assigns), to: PhoenixDuskmoon.Component.Navigation.LeftMenu
end
