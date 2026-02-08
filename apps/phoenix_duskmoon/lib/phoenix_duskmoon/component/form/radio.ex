defmodule PhoenixDuskmoon.Component.Form.Radio do
  @moduledoc """
  Backwards-compatible re-export module.

  This module delegates to `PhoenixDuskmoon.Component.DataEntry.Radio`.
  Use the new module path for new code.
  """

  defdelegate dm_radio(assigns), to: PhoenixDuskmoon.Component.DataEntry.Radio
end
