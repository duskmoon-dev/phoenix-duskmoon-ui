defmodule PhoenixDuskmoon.Component.Form.Switch do
  @moduledoc """
  Backwards-compatible re-export module.

  This module delegates to `PhoenixDuskmoon.Component.DataEntry.Switch`.
  Use the new module path for new code.
  """

  defdelegate dm_switch(assigns), to: PhoenixDuskmoon.Component.DataEntry.Switch
end
