defmodule NPM.ProjectInit do
  @moduledoc """
  Initializes an Elixir project for npm dependency management.

  Creates package.json, .gitignore entries, and verifies configuration.
  """

  @doc """
  Checks if a project is already initialized for npm.
  """
  @spec initialized?(String.t()) :: boolean()
  def initialized?(dir \\ ".") do
    File.exists?(Path.join(dir, "package.json"))
  end

  @doc """
  Creates a package.json from project metadata.
  """
  @spec create_package_json(String.t(), keyword()) :: :ok | {:error, term()}
  def create_package_json(dir \\ ".", opts \\ []) do
    path = Path.join(dir, "package.json")

    if File.exists?(path) and not Keyword.get(opts, :force, false) do
      {:error, :already_exists}
    else
      content = build_package_json(opts)
      File.write(path, :json.encode(content))
    end
  end

  @doc """
  Returns a checklist of items to verify for npm setup.
  """
  @spec checklist(String.t()) :: [%{item: String.t(), ok: boolean()}]
  def checklist(dir \\ ".") do
    [
      %{item: "package.json exists", ok: File.exists?(Path.join(dir, "package.json"))},
      %{item: ".gitignore covers node_modules", ok: gitignore_ok?(dir)},
      %{item: "mix.exs has npm compiler", ok: has_compiler?(dir)}
    ]
  end

  @doc """
  Returns true if all checklist items pass.
  """
  @spec ready?(String.t()) :: boolean()
  def ready?(dir \\ ".") do
    checklist(dir) |> Enum.all?(& &1.ok)
  end

  @doc """
  Formats the checklist for display.
  """
  @spec format_checklist([map()]) :: String.t()
  def format_checklist(items) do
    Enum.map_join(items, "\n", fn item ->
      mark = if item.ok, do: "✓", else: "✗"
      "  #{mark} #{item.item}"
    end)
  end

  defp build_package_json(opts) do
    %{
      "name" => Keyword.get(opts, :name, "elixir-app"),
      "version" => Keyword.get(opts, :version, "0.1.0"),
      "private" => true,
      "dependencies" => %{},
      "devDependencies" => %{}
    }
  end

  defp gitignore_ok?(dir) do
    path = Path.join(dir, ".gitignore")

    case File.read(path) do
      {:ok, content} -> NPM.Gitignore.covers_node_modules?(content)
      _ -> false
    end
  end

  defp has_compiler?(dir) do
    path = Path.join(dir, "mix.exs")

    case File.read(path) do
      {:ok, content} -> String.contains?(content, ":npm")
      _ -> false
    end
  end
end
