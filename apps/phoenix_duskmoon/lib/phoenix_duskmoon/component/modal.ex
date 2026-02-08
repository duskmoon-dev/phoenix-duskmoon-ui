defmodule PhoenixDuskmoon.Component.Modal do
  @moduledoc """
  Backwards-compatible re-export module.

  This module delegates to `PhoenixDuskmoon.Component.Feedback.Dialog`.
  Use the new module path for new code.
  """

  defdelegate dm_modal(assigns), to: PhoenixDuskmoon.Component.Feedback.Dialog
end
