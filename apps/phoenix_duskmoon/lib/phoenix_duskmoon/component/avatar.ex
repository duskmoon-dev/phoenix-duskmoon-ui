defmodule PhoenixDuskmoon.Component.Avatar do
  @moduledoc """
  Backwards-compatible re-export module.

  This module delegates to `PhoenixDuskmoon.Component.DataDisplay.Avatar`.
  Use the new module path for new code.
  """

  defdelegate dm_avatar(assigns), to: PhoenixDuskmoon.Component.DataDisplay.Avatar
end
