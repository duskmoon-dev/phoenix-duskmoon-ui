defmodule NPM.Node.Bin do
  @moduledoc """
  Parses and manages package bin field entries.

  The `bin` field in package.json maps command names to script files.
  Supports both string shorthand and map formats.
  """

  @doc """
  Extracts bin entries from package.json data.

  Returns a map of command name → script path.
  """
  @spec extract(map()) :: %{String.t() => String.t()}
  def extract(%{"bin" => bin, "name" => name}) when is_binary(bin) do
    %{name => bin}
  end

  def extract(%{"bin" => bin}) when is_map(bin), do: bin
  def extract(%{"directories" => %{"bin" => dir}}), do: %{"__dir__" => dir}
  def extract(_), do: %{}

  @doc """
  Lists all command names provided by a package.
  """
  @spec commands(map()) :: [String.t()]
  def commands(pkg_data) do
    pkg_data |> extract() |> Map.keys() |> Enum.sort()
  end

  @doc """
  Checks if a package provides any binaries.
  """
  @spec has_bin?(map()) :: boolean()
  def has_bin?(pkg_data), do: extract(pkg_data) != %{}

  @doc """
  Resolves the script path for a given command.
  """
  @spec resolve(String.t(), map()) :: String.t() | nil
  def resolve(command, pkg_data) do
    Map.get(extract(pkg_data), command)
  end

  @doc """
  Counts the number of binaries a package provides.
  """
  @spec count(map()) :: non_neg_integer()
  def count(pkg_data), do: pkg_data |> extract() |> map_size()

  @doc """
  Scans installed packages and collects all available binaries.
  """
  @spec all_bins(String.t()) :: %{String.t() => String.t()}
  def all_bins(node_modules_dir) do
    case File.ls(node_modules_dir) do
      {:ok, entries} ->
        entries
        |> Enum.reject(&String.starts_with?(&1, "."))
        |> Enum.flat_map(&read_pkg_bins(node_modules_dir, &1))
        |> Map.new()

      _ ->
        %{}
    end
  end

  defp read_pkg_bins(nm_dir, name) do
    pkg_path = Path.join([nm_dir, name, "package.json"])

    case File.read(pkg_path) do
      {:ok, content} ->
        data = NPM.JSON.decode!(content)
        bins = extract(data)
        Enum.map(bins, fn {cmd, script} -> {cmd, Path.join([nm_dir, name, script])} end)

      _ ->
        []
    end
  rescue
    _ -> []
  end
end
