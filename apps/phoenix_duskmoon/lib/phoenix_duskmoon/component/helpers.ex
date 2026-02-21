defmodule PhoenixDuskmoon.Component.Helpers do
  @moduledoc false

  @doc """
  Maps the `"accent"` color name to the `"tertiary"` CSS token
  used by `@duskmoon-dev/core`, passing all other values through.
  """
  def css_color("accent"), do: "tertiary"
  def css_color(color), do: color
end
