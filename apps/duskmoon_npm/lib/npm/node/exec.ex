defmodule NPM.Node.Exec do
  @moduledoc """
  npx-style execution — resolve and run binaries from installed packages.

  Looks up binaries in `node_modules/.bin/` or resolves from package
  bin fields to find the right executable.
  """

  @doc """
  Finds the path to a binary command in node_modules/.bin/.
  """
  @spec which(String.t(), String.t()) :: {:ok, String.t()} | {:error, :not_found}
  def which(command, node_modules_dir \\ "node_modules") do
    bin_dir = Path.join(node_modules_dir, ".bin")
    bin_path = Path.join(bin_dir, command)

    if File.exists?(bin_path) do
      {:ok, bin_path}
    else
      find_in_packages(command, node_modules_dir)
    end
  end

  @doc """
  Lists all available binaries from installed packages.
  """
  @spec available(String.t()) :: [String.t()]
  def available(node_modules_dir \\ "node_modules") do
    bin_dir = Path.join(node_modules_dir, ".bin")

    case File.ls(bin_dir) do
      {:ok, entries} -> Enum.sort(entries)
      _ -> list_package_bins(node_modules_dir)
    end
  end

  @doc """
  Checks if a command is available in node_modules.
  """
  @spec available?(String.t(), String.t()) :: boolean()
  def available?(command, node_modules_dir \\ "node_modules") do
    case which(command, node_modules_dir) do
      {:ok, _} -> true
      _ -> false
    end
  end

  @doc """
  Resolves a package name from a command by checking bin fields.
  """
  @spec package_for(String.t(), String.t()) :: {:ok, String.t()} | {:error, :not_found}
  def package_for(command, node_modules_dir \\ "node_modules") do
    case File.ls(node_modules_dir) do
      {:ok, entries} ->
        entries
        |> Enum.find_value(fn entry ->
          find_command_in_package(node_modules_dir, entry, command)
        end)
        |> case do
          nil -> {:error, :not_found}
          name -> {:ok, name}
        end

      _ ->
        {:error, :not_found}
    end
  end

  @doc """
  Builds the execution environment with node_modules/.bin in PATH.
  """
  @spec env(String.t()) :: [{String.t(), String.t()}]
  def env(node_modules_dir \\ "node_modules") do
    bin_dir = Path.expand(Path.join(node_modules_dir, ".bin"))
    node_modules_dir = Path.expand(node_modules_dir)
    current_path = System.get_env("PATH") || ""

    node_path =
      [node_modules_dir, System.get_env("NODE_PATH")]
      |> Enum.reject(&is_nil/1)
      |> Enum.join(":")

    [
      {"PATH", "#{bin_dir}:#{current_path}"},
      {"NODE_PATH", node_path}
    ]
  end

  defp find_in_packages(command, node_modules_dir) do
    pkg_path = Path.join([node_modules_dir, command, "package.json"])

    case File.read(pkg_path) do
      {:ok, content} ->
        data = NPM.JSON.decode!(content)
        resolve_bin(data, command, node_modules_dir)

      _ ->
        {:error, :not_found}
    end
  rescue
    # JSON decode, missing keys, or unexpected package.json shape
    _ -> {:error, :not_found}
  end

  defp resolve_bin(%{"bin" => bin}, _command, nm_dir) when is_binary(bin) do
    {:ok, Path.join(nm_dir, bin)}
  end

  defp resolve_bin(%{"bin" => bin, "name" => name}, command, nm_dir) when is_map(bin) do
    case Map.get(bin, command) || Map.get(bin, name) do
      nil -> {:error, :not_found}
      path -> {:ok, Path.join([nm_dir, name, path])}
    end
  end

  defp resolve_bin(_, _, _), do: {:error, :not_found}

  defp find_command_in_package(nm_dir, entry, command) do
    if String.starts_with?(entry, ".") or String.starts_with?(entry, "@") do
      nil
    else
      check_package_bin(nm_dir, entry, command)
    end
  end

  defp check_package_bin(nm_dir, pkg_name, command) do
    pkg_path = Path.join([nm_dir, pkg_name, "package.json"])

    case File.read(pkg_path) do
      {:ok, content} ->
        data = NPM.JSON.decode!(content)
        if has_command?(data, command), do: pkg_name, else: nil

      _ ->
        nil
    end
  rescue
    _ -> nil
  end

  defp has_command?(%{"bin" => bin}, command) when is_map(bin), do: Map.has_key?(bin, command)
  defp has_command?(%{"bin" => _, "name" => name}, command), do: name == command
  defp has_command?(_, _), do: false

  defp list_package_bins(node_modules_dir) do
    case File.ls(node_modules_dir) do
      {:ok, entries} ->
        entries
        |> Enum.reject(&String.starts_with?(&1, "."))
        |> Enum.flat_map(&read_package_bins(node_modules_dir, &1))
        |> Enum.sort()

      _ ->
        []
    end
  end

  defp read_package_bins(nm_dir, pkg_name) do
    pkg_path = Path.join([nm_dir, pkg_name, "package.json"])

    case File.read(pkg_path) do
      {:ok, content} ->
        data = NPM.JSON.decode!(content)
        extract_bin_names(data)

      _ ->
        []
    end
  rescue
    _ -> []
  end

  defp extract_bin_names(%{"bin" => bin}) when is_map(bin), do: Map.keys(bin)
  defp extract_bin_names(%{"bin" => _, "name" => name}), do: [name]
  defp extract_bin_names(_), do: []
end
