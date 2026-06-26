defmodule NPM.Install.ScriptRunner do
  alias NPM.Install.Lifecycle

  @moduledoc """
  Analyzes and validates npm scripts from package.json.
  """

  @common_scripts ~w(start test build lint dev serve clean format typecheck)

  @doc """
  Extracts scripts from package.json.
  """
  @spec extract(map()) :: map()
  def extract(%{"scripts" => scripts}) when is_map(scripts), do: scripts
  def extract(_), do: %{}

  @doc """
  Returns lifecycle scripts defined in the package.
  """
  @spec lifecycle(map()) :: map()
  def lifecycle(data) do
    scripts = extract(data)
    Map.take(scripts, Lifecycle.hook_names())
  end

  @doc """
  Returns non-lifecycle (custom) scripts.
  """
  @spec custom(map()) :: map()
  def custom(data) do
    scripts = extract(data)
    lifecycle_names = Lifecycle.hook_names()
    Map.reject(scripts, fn {k, _} -> k in lifecycle_names end)
  end

  @doc """
  Checks if a specific script exists.
  """
  @spec has_script?(map(), String.t()) :: boolean()
  def has_script?(data, name), do: Map.has_key?(extract(data), name)

  @doc """
  Detects common script patterns.
  """
  @spec detect_patterns(map()) :: [atom()]
  def detect_patterns(data) do
    scripts = extract(data)

    patterns = [
      {:has_test,
       Map.has_key?(scripts, "test") and
         scripts["test"] != "echo \"Error: no test specified\" && exit 1"},
      {:has_build, Map.has_key?(scripts, "build")},
      {:has_lint,
       Map.has_key?(scripts, "lint") or
         Enum.any?(scripts, fn {_, v} -> String.contains?(v, "eslint") end)},
      {:has_typecheck,
       Map.has_key?(scripts, "typecheck") or
         Enum.any?(scripts, fn {_, v} -> String.contains?(v, "tsc") end)},
      {:has_dev, Map.has_key?(scripts, "dev") or Map.has_key?(scripts, "start")}
    ]

    patterns |> Enum.filter(&elem(&1, 1)) |> Enum.map(&elem(&1, 0))
  end

  @doc """
  Returns all script names sorted.
  """
  @spec names(map()) :: [String.t()]
  def names(data), do: data |> extract() |> Map.keys() |> Enum.sort()

  @doc """
  Counts scripts.
  """
  @spec count(map()) :: non_neg_integer()
  def count(data), do: data |> extract() |> map_size()

  @doc """
  Returns common scripts that are missing.
  """
  @spec missing_common(map()) :: [String.t()]
  def missing_common(data) do
    defined = extract(data) |> Map.keys() |> MapSet.new()
    @common_scripts |> Enum.reject(&MapSet.member?(defined, &1))
  end
end
