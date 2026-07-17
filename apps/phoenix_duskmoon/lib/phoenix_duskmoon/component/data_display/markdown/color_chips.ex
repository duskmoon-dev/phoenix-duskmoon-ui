defmodule PhoenixDuskmoon.Component.DataDisplay.Markdown.ColorChips do
  @moduledoc """
  MDEx plugin that renders GitHub-style color chips next to supported inline
  color values.

  Three-, four-, six-, and eight-digit hexadecimal, RGB, and HSL colors are
  supported when written as inline code, for example `` `#0969DA` ``.
  """

  alias MDEx.Document

  @hex_color ~r/\A#(?:[0-9A-Fa-f]{3}|[0-9A-Fa-f]{4}|[0-9A-Fa-f]{6}|[0-9A-Fa-f]{8})\z/
  @rgb_color ~r/\Argb\(\s*(?<red>\d{1,3})\s*,\s*(?<green>\d{1,3})\s*,\s*(?<blue>\d{1,3})\s*\)\z/
  @hsl_color ~r/\Ahsl\(\s*(?<hue>\d{1,3})\s*,\s*(?<saturation>\d{1,3})%\s*,\s*(?<lightness>\d{1,3})%\s*\)\z/
  @chip_style "box-sizing: border-box; position: relative; display: inline-block; width: 0.75em; height: 0.75em; margin-left: 0.35em; overflow: hidden; border: 1px solid currentColor; border-radius: 0.2em; vertical-align: -0.05em; background-color: #fff; background-image: conic-gradient(#b8b8b8 25%, transparent 0 50%, #b8b8b8 0 75%, transparent 0); background-size: 4px 4px;"
  @swatch_style "position: absolute; inset: 0;"

  @doc """
  Attaches the color-chip transformation to an MDEx document.
  """
  @spec attach(Document.t(), keyword()) :: Document.t()
  def attach(document, _options \\ []) do
    Document.append_steps(document, color_chips: &add_color_chips/1)
  end

  defp add_color_chips(document) do
    MDEx.traverse_and_update(document, fn
      %MDEx.Code{literal: literal, sourcepos: sourcepos} = node ->
        case normalize_color(literal) do
          {:ok, color} -> color_chip_node(literal, color, sourcepos)
          :error -> node
        end

      node ->
        node
    end)
  end

  defp normalize_color(color) do
    cond do
      Regex.match?(@hex_color, color) ->
        {:ok, color}

      captures = Regex.named_captures(@rgb_color, color) ->
        normalize_rgb(captures)

      captures = Regex.named_captures(@hsl_color, color) ->
        normalize_hsl(captures)

      true ->
        :error
    end
  end

  defp normalize_rgb(%{"red" => red, "green" => green, "blue" => blue}) do
    channels = Enum.map([red, green, blue], &String.to_integer/1)

    if Enum.all?(channels, &(&1 in 0..255)) do
      {:ok, "rgb(#{Enum.join(channels, ", ")})"}
    else
      :error
    end
  end

  defp normalize_hsl(%{
         "hue" => hue,
         "saturation" => saturation,
         "lightness" => lightness
       }) do
    hue = String.to_integer(hue)
    saturation = String.to_integer(saturation)
    lightness = String.to_integer(lightness)

    if hue in 0..360 and saturation in 0..100 and lightness in 0..100 do
      {:ok, "hsl(#{hue}, #{saturation}%, #{lightness}%)"}
    else
      :error
    end
  end

  defp color_chip_node(literal, color, sourcepos) do
    escaped_literal =
      literal
      |> Phoenix.HTML.html_escape()
      |> Phoenix.HTML.safe_to_string()

    %MDEx.Raw{
      literal:
        ~s(<code>#{escaped_literal}<span class="markdown-color-chip" style="#{@chip_style}" aria-hidden="true"><span class="markdown-color-chip-swatch" style="#{@swatch_style} background-color: #{color};"></span></span></code>),
      sourcepos: sourcepos
    }
  end
end
