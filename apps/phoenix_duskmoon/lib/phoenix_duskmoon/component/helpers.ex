defmodule PhoenixDuskmoon.Component.Helpers do
  @moduledoc false

  @doc """
  Maps the `"accent"` color name to the `"tertiary"` CSS token
  used by `@duskmoon-dev/core`, passing all other values through.
  """
  def css_color("accent"), do: "tertiary"
  def css_color(color), do: color

  @doc """
  Interpolates `{key}` placeholders in a template string with values from a map.

  Used for i18n-friendly aria-label templates.

  ## Examples

      iex> format_label("Rate {index} out of {max}", %{"index" => 3, "max" => 5})
      "Rate 3 out of 5"

  """
  def format_label(template, vars) do
    Enum.reduce(vars, template, fn {key, val}, acc ->
      String.replace(acc, "{#{key}}", to_string(val))
    end)
  end

  @doc """
  Splits a value string into a list of graphemes, taking at most `length` items.

  Returns an empty list for `nil` or non-binary values.

  ## Examples

      iex> split_value("1234", 4)
      ["1", "2", "3", "4"]

      iex> split_value("12", 4)
      ["1", "2"]

      iex> split_value(nil, 4)
      []

  """
  def split_value(nil, _length), do: []

  def split_value(value, length) when is_binary(value) do
    value |> String.graphemes() |> Enum.take(length)
  end

  def split_value(_, _length), do: []
end
