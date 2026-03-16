defmodule PhoenixDuskmoon.ArtComponent do
  @moduledoc """
  Duskmoon Art Components

  Decorative and animated visual effects powered by `@duskmoon-dev/art-elements`
  custom elements and `@duskmoon-dev/css-art`.

  ## Example

      defp html_helpers do
        quote do
          use PhoenixDuskmoon.Component  # includes art components
          ...
        end
      end

  Or import art components separately:

      use PhoenixDuskmoon.ArtComponent

  """

  @doc false
  def art_component do
    quote do
      import PhoenixDuskmoon.ArtComponent.Atom
      import PhoenixDuskmoon.ArtComponent.CatStargazer
      import PhoenixDuskmoon.ArtComponent.CircularGallery
      import PhoenixDuskmoon.ArtComponent.ColorSpin
      import PhoenixDuskmoon.ArtComponent.Eclipse
      import PhoenixDuskmoon.ArtComponent.FlowerAnimation
      import PhoenixDuskmoon.ArtComponent.Moon
      import PhoenixDuskmoon.ArtComponent.Mountain
      import PhoenixDuskmoon.ArtComponent.PlasmaBall
      import PhoenixDuskmoon.ArtComponent.Snow
      import PhoenixDuskmoon.ArtComponent.Sun
      import PhoenixDuskmoon.ArtComponent.SynthwaveStarfield
    end
  end

  @doc false
  defmacro __using__(_) do
    quote do
      unquote(art_component())
    end
  end
end
