defmodule PhoenixDuskmoon.Component.Form do
  @moduledoc """
  Backwards-compatible re-export module.

  This module delegates to `PhoenixDuskmoon.Component.DataEntry.Form`.
  Use the new module path for new code.
  """

  defdelegate dm_form(assigns), to: PhoenixDuskmoon.Component.DataEntry.Form
  defdelegate dm_label(assigns), to: PhoenixDuskmoon.Component.DataEntry.Form
  defdelegate dm_error(assigns), to: PhoenixDuskmoon.Component.DataEntry.Form
  defdelegate dm_alert(assigns), to: PhoenixDuskmoon.Component.DataEntry.Form
  defdelegate normalize_checkbox_value(assigns), to: PhoenixDuskmoon.Component.DataEntry.Form
end
