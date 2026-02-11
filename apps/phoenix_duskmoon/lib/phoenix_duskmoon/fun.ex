defmodule PhoenixDuskmoon.Fun do
  @moduledoc """
  Duskmoon Fun Component

  **v9**: Fun components are now part of `PhoenixDuskmoon.Component` and are
  automatically imported via `use PhoenixDuskmoon.Component`. This module
  is kept for backward compatibility but delegates to the v9 component modules.

  ## Example

      defp html_helpers do
        quote do
          use PhoenixDuskmoon.Component  # includes fun components
          ...
        end
      end

  """

  @doc false
  def fun_component do
    quote do
      import PhoenixDuskmoon.Component.Fun.ButtonNoise
      import PhoenixDuskmoon.Component.Fun.Eclipse
      import PhoenixDuskmoon.Component.Fun.PlasmaBall
      import PhoenixDuskmoon.Component.Fun.Signature
      import PhoenixDuskmoon.Component.Fun.Snow
      import PhoenixDuskmoon.Component.Fun.SpotlightSearch
    end
  end

  @doc false
  defmacro __using__(_) do
    quote do
      unquote(fun_component())
    end
  end
end
