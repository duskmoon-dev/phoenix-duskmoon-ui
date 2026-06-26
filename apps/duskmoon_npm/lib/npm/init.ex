defmodule NPM.Init do
  @moduledoc """
  Generates package.json files with sensible defaults.

  Implements the `npm init` functionality — creates a new package.json
  with project metadata derived from the current directory or Mix project.
  """

  @doc """
  Generates a default package.json map from the given options.
  """
  @spec generate(keyword()) :: map()
  def generate(opts \\ []) do
    %{
      "name" => Keyword.get(opts, :name, default_name()),
      "version" => Keyword.get(opts, :version, "1.0.0"),
      "description" => Keyword.get(opts, :description, ""),
      "main" => Keyword.get(opts, :main, "index.js"),
      "scripts" => Keyword.get(opts, :scripts, default_scripts()),
      "keywords" => Keyword.get(opts, :keywords, []),
      "author" => Keyword.get(opts, :author, ""),
      "license" => Keyword.get(opts, :license, "ISC"),
      "dependencies" => %{},
      "devDependencies" => %{}
    }
  end

  @doc """
  Writes a package.json to disk.
  """
  @spec write(String.t(), keyword()) :: :ok | {:error, term()}
  def write(dir \\ ".", opts \\ []) do
    path = Path.join(dir, "package.json")

    if File.exists?(path) do
      {:error, :already_exists}
    else
      data = generate(opts)
      File.write(path, NPM.JSON.encode_pretty(data))
    end
  end

  @doc """
  Checks if a package.json already exists in the directory.
  """
  @spec exists?(String.t()) :: boolean()
  def exists?(dir \\ "."), do: dir |> Path.join("package.json") |> File.exists?()

  @doc """
  Infers project name from the current directory.
  """
  @spec default_name :: String.t()
  def default_name do
    File.cwd!() |> Path.basename() |> String.downcase() |> String.replace(~r/[^a-z0-9\-_]/, "-")
  end

  @doc """
  Returns default scripts for a new package.
  """
  @spec default_scripts :: map()
  def default_scripts do
    %{"test" => "echo \"Error: no test specified\" && exit 1"}
  end

  @doc """
  Generates a minimal package.json (name and version only).
  """
  @spec generate_minimal(String.t(), String.t()) :: map()
  def generate_minimal(name, version \\ "1.0.0") do
    %{"name" => name, "version" => version}
  end

  @doc """
  Detects if this is an Elixir/Mix project and adjusts defaults.
  """
  @spec from_mix_project(keyword()) :: map()
  def from_mix_project(mix_config \\ []) do
    name = Keyword.get(mix_config, :app, :unnamed) |> Atom.to_string()
    version = Keyword.get(mix_config, :version, "0.1.0")
    description = Keyword.get(mix_config, :description, "")

    generate(
      name: name,
      version: version,
      description: if(is_binary(description), do: description, else: "")
    )
  end
end
