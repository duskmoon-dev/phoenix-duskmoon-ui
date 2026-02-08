defmodule PhoenixDuskmoon.Component.Actionbar do
  @moduledoc """
  Backwards-compatible re-export module.

  This module delegates to `PhoenixDuskmoon.Component.Navigation.Actionbar`.
  Use the new module path for new code.
  """

  defdelegate dm_actionbar(assigns), to: PhoenixDuskmoon.Component.Navigation.Actionbar
end
