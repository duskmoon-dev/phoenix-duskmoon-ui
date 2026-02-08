defmodule PhoenixDuskmoon.Component.Progress do
  @moduledoc """
  Backwards-compatible re-export module.

  This module delegates to `PhoenixDuskmoon.Component.DataDisplay.Progress`.
  Use the new module path for new code.
  """

  defdelegate dm_progress(assigns), to: PhoenixDuskmoon.Component.DataDisplay.Progress
end
