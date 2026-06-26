defmodule NPM.Scripts do
  @moduledoc """
  Reads and manages npm scripts from package.json.

  Provides the `npm run` functionality — listing, filtering,
  and determining execution order of scripts defined in package.json.
  """

  @well_known ~w(start test build dev lint format clean prepare pretest posttest prebuild postbuild)

  @doc """
  Reads all scripts from a package.json file.
  """
  @spec read(String.t()) :: {:ok, map()} | {:error, term()}
  def read(package_json_path) do
    case File.read(package_json_path) do
      {:ok, content} ->
        data = NPM.JSON.decode!(content)
        {:ok, data["scripts"] || %{}}

      error ->
        error
    end
  end

  @doc """
  Lists all available script names.
  """
  @spec list(map()) :: [String.t()]
  def list(scripts), do: scripts |> Map.keys() |> Enum.sort()

  @doc """
  Checks if a script exists.
  """
  @spec has?(map(), String.t()) :: boolean()
  def has?(scripts, name), do: Map.has_key?(scripts, name)

  @doc """
  Returns pre/post hooks for a script.
  """
  @spec hooks_for(map(), String.t()) :: %{pre: String.t() | nil, post: String.t() | nil}
  def hooks_for(scripts, name) do
    %{pre: scripts["pre#{name}"], post: scripts["post#{name}"]}
  end

  @doc """
  Categorizes scripts into well-known and custom.
  """
  @spec categorize(map()) :: %{well_known: [String.t()], custom: [String.t()]}
  def categorize(scripts) do
    known_set = MapSet.new(@well_known)
    names = Map.keys(scripts)

    %{
      well_known: names |> Enum.filter(&MapSet.member?(known_set, &1)) |> Enum.sort(),
      custom: names |> Enum.reject(&MapSet.member?(known_set, &1)) |> Enum.sort()
    }
  end

  @doc """
  Returns scripts matching a pattern.
  """
  @spec filter(map(), String.t()) :: map()
  def filter(scripts, pattern) do
    regex = Regex.compile!(pattern, "i")
    Map.filter(scripts, fn {name, _cmd} -> Regex.match?(regex, name) end)
  end

  @doc """
  Formats a scripts map for display.
  """
  @spec format(map()) :: String.t()
  def format(scripts) when map_size(scripts) == 0, do: "No scripts defined."

  def format(scripts) do
    scripts
    |> Enum.sort_by(&elem(&1, 0))
    |> Enum.map_join("\n", fn {name, cmd} -> "  #{name}: #{cmd}" end)
  end

  @doc """
  Returns the execution order for a script, including pre/post hooks.
  """
  @spec execution_order(map(), String.t()) :: [String.t()]
  def execution_order(scripts, name) do
    pre = if has?(scripts, "pre#{name}"), do: ["pre#{name}"], else: []
    main = if has?(scripts, name), do: [name], else: []
    post = if has?(scripts, "post#{name}"), do: ["post#{name}"], else: []
    pre ++ main ++ post
  end
end
