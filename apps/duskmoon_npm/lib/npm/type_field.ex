defmodule NPM.TypeField do
  @moduledoc """
  Analyzes the `type` field from package.json.

  The `type` field determines whether `.js` files are treated as
  ES modules (`"module"`) or CommonJS (`"commonjs"`, the default).
  """

  @doc """
  Returns the type field value (default: "commonjs").
  """
  @spec get(map()) :: String.t()
  def get(%{"type" => "module"}), do: "module"
  def get(%{"type" => "commonjs"}), do: "commonjs"
  def get(_), do: "commonjs"

  @doc """
  Checks if the package uses ES modules.
  """
  @spec esm?(map()) :: boolean()
  def esm?(data), do: get(data) == "module"

  @doc """
  Checks if the package uses CommonJS.
  """
  @spec cjs?(map()) :: boolean()
  def cjs?(data), do: get(data) == "commonjs"

  @doc """
  Determines the module system for a given file path.
  """
  @spec module_type(String.t(), map()) :: :esm | :cjs
  def module_type(filepath, data) do
    ext = Path.extname(filepath)

    case ext do
      ".mjs" -> :esm
      ".cjs" -> :cjs
      ".mts" -> :esm
      ".cts" -> :cjs
      _ -> if esm?(data), do: :esm, else: :cjs
    end
  end

  @doc """
  Returns the counts of ESM vs CJS packages.
  """
  @spec stats([map()]) :: map()
  def stats(packages) do
    esm_count = Enum.count(packages, &esm?/1)

    %{
      total: length(packages),
      esm: esm_count,
      cjs: length(packages) - esm_count,
      esm_pct:
        if(packages != [], do: Float.round(esm_count / length(packages) * 100, 1), else: 0.0)
    }
  end

  @doc """
  Checks if a package is a dual CJS/ESM package.
  """
  @spec dual?(map()) :: boolean()
  def dual?(data) do
    has_exports = is_map(data["exports"])
    has_main = is_binary(data["main"])
    has_module = is_binary(data["module"])
    (has_exports and has_main) or (has_main and has_module)
  end
end
