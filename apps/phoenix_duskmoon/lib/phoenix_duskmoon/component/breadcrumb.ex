defmodule PhoenixDuskmoon.Component.Breadcrumb do
  @moduledoc """
  Backwards-compatible re-export module.

  This module delegates to `PhoenixDuskmoon.Component.Navigation.Breadcrumb`.
  Use the new module path for new code.
  """

  defdelegate dm_breadcrumb(assigns), to: PhoenixDuskmoon.Component.Navigation.Breadcrumb
end
