defmodule PhoenixDuskmoon.Component.Appbar do
  @moduledoc """
  Backwards-compatible re-export module.

  This module delegates to `PhoenixDuskmoon.Component.Navigation.Appbar`.
  Use the new module path for new code.
  """

  defdelegate dm_appbar(assigns), to: PhoenixDuskmoon.Component.Navigation.Appbar
  defdelegate dm_simple_appbar(assigns), to: PhoenixDuskmoon.Component.Navigation.Appbar
end
