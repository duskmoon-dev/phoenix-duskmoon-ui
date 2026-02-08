defmodule PhoenixDuskmoon.Component.Button do
  @moduledoc """
  Backwards-compatible re-export module.

  This module delegates to `PhoenixDuskmoon.Component.Action.Button`.
  Use the new module path for new code.
  """

  defdelegate dm_btn(assigns), to: PhoenixDuskmoon.Component.Action.Button
end
