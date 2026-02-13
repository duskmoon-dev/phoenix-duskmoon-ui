defmodule PhoenixDuskmoon.CssArt do
  @moduledoc """
  Duskmoon CSS Art Components

  Decorative and animated visual effects built with pure CSS.

  ## Example

      defp html_helpers do
        quote do
          use PhoenixDuskmoon.Component  # includes CSS art components
          ...
        end
      end

  Or import CSS art components separately:

      use PhoenixDuskmoon.CssArt

  """

  @doc false
  def css_art_component do
    quote do
      import PhoenixDuskmoon.CssArt.ButtonNoise
      import PhoenixDuskmoon.CssArt.Eclipse
      import PhoenixDuskmoon.CssArt.PlasmaBall
      import PhoenixDuskmoon.CssArt.Signature
      import PhoenixDuskmoon.CssArt.Snow
      import PhoenixDuskmoon.CssArt.SpotlightSearch
    end
  end

  @doc false
  defmacro __using__(_) do
    quote do
      unquote(css_art_component())
    end
  end
end
