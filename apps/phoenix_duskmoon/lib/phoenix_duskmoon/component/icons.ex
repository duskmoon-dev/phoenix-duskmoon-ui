defmodule PhoenixDuskmoon.Component.Icons do
  @moduledoc """
  Backwards-compatible re-export module.

  This module delegates to `PhoenixDuskmoon.Component.Icon.Icons`.
  Use the new module path for new code.
  """

  defdelegate mdi_icons(), to: PhoenixDuskmoon.Component.Icon.Icons
  defdelegate dm_mdi(assigns), to: PhoenixDuskmoon.Component.Icon.Icons
  defdelegate bsi_icons(), to: PhoenixDuskmoon.Component.Icon.Icons
  defdelegate dm_bsi(assigns), to: PhoenixDuskmoon.Component.Icon.Icons
end
