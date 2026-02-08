defmodule PhoenixDuskmoon.Component.Loading do
  @moduledoc """
  Backwards-compatible re-export module.

  This module delegates to `PhoenixDuskmoon.Component.Feedback.Loading`.
  Use the new module path for new code.
  """

  defdelegate dm_loading_spinner(assigns), to: PhoenixDuskmoon.Component.Feedback.Loading
  defdelegate dm_loading_ex(assigns), to: PhoenixDuskmoon.Component.Feedback.Loading
end
