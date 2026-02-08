defmodule PhoenixDuskmoon.Component.ThemeSwitcher do
  @moduledoc """
  Backwards-compatible re-export module.

  This module delegates to `PhoenixDuskmoon.Component.Layout.ThemeSwitcher`.
  Use the new module path for new code.
  """

  defdelegate dm_theme_switcher(assigns), to: PhoenixDuskmoon.Component.Layout.ThemeSwitcher
end
