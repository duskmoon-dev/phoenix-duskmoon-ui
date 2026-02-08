defmodule PhoenixDuskmoon.Component.PageHeader do
  @moduledoc """
  Backwards-compatible re-export module.

  This module delegates to `PhoenixDuskmoon.Component.Navigation.PageHeader`.
  Use the new module path for new code.
  """

  defdelegate dm_page_header(assigns), to: PhoenixDuskmoon.Component.Navigation.PageHeader
end
