defmodule PhoenixDuskmoon.Component.Markdown do
  @moduledoc """
  Backwards-compatible re-export module.

  This module delegates to `PhoenixDuskmoon.Component.DataDisplay.Markdown`.
  Use the new module path for new code.
  """

  defdelegate dm_markdown(assigns), to: PhoenixDuskmoon.Component.DataDisplay.Markdown
end
