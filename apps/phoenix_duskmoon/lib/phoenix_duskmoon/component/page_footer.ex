defmodule PhoenixDuskmoon.Component.PageFooter do
  @moduledoc """
  Backwards-compatible re-export module.

  This module delegates to `PhoenixDuskmoon.Component.Navigation.PageFooter`.
  Use the new module path for new code.
  """

  defdelegate dm_page_footer(assigns), to: PhoenixDuskmoon.Component.Navigation.PageFooter
end
