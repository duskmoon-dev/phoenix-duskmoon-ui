defmodule PhoenixDuskmoon.Component.Navbar do
  @moduledoc """
  Backwards-compatible re-export module.

  This module delegates to `PhoenixDuskmoon.Component.Navigation.Navbar`.
  Use the new module path for new code.
  """

  defdelegate dm_navbar(assigns), to: PhoenixDuskmoon.Component.Navigation.Navbar
end
