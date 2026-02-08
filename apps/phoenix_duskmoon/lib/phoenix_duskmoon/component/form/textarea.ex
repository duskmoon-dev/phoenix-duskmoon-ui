defmodule PhoenixDuskmoon.Component.Form.Textarea do
  @moduledoc """
  Backwards-compatible re-export module.

  This module delegates to `PhoenixDuskmoon.Component.DataEntry.Textarea`.
  Use the new module path for new code.
  """

  defdelegate dm_textarea(assigns), to: PhoenixDuskmoon.Component.DataEntry.Textarea
end
