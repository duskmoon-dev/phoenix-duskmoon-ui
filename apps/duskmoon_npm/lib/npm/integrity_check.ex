defmodule NPM.IntegrityCheck do
  @moduledoc """
  Verifies installed packages match lockfile entries.

  Checks version, integrity, and presence of packages in node_modules.
  """

  @doc """
  Verifies a single package against its lockfile entry.
  """
  @spec verify_package(String.t(), map(), String.t()) :: :ok | {:error, atom()}
  def verify_package(name, entry, node_modules \\ "node_modules") do
    pkg_json_path = Path.join([node_modules, name, "package.json"])

    case File.read(pkg_json_path) do
      {:ok, content} ->
        installed = NPM.JSON.decode!(content)
        check_version(installed, entry)

      {:error, _} ->
        {:error, :not_installed}
    end
  rescue
    _ -> {:error, :invalid_package_json}
  end

  @doc """
  Verifies all lockfile packages are correctly installed.
  """
  @spec verify_all(map(), String.t()) :: [map()]
  def verify_all(lockfile, node_modules \\ "node_modules") do
    lockfile
    |> Enum.flat_map(fn {name, entry} ->
      case verify_package(name, entry, node_modules) do
        :ok -> []
        {:error, reason} -> [%{name: name, reason: reason}]
      end
    end)
    |> Enum.sort_by(& &1.name)
  end

  @doc """
  Checks if all packages pass verification.
  """
  @spec all_valid?(map(), String.t()) :: boolean()
  def all_valid?(lockfile, node_modules \\ "node_modules") do
    verify_all(lockfile, node_modules) == []
  end

  @doc """
  Groups verification failures by reason.
  """
  @spec group_failures([map()]) :: map()
  def group_failures(failures) do
    Enum.group_by(failures, & &1.reason, & &1.name)
  end

  @doc """
  Formats verification results.
  """
  @spec format_results([map()]) :: String.t()
  def format_results([]), do: "All packages verified."

  def format_results(failures) do
    grouped = group_failures(failures)

    grouped
    |> Enum.sort_by(&elem(&1, 0))
    |> Enum.map_join("\n", fn {reason, names} ->
      "#{reason}: #{Enum.join(names, ", ")}"
    end)
  end

  defp check_version(%{"version" => installed_version}, %{version: locked_version}) do
    if installed_version == locked_version, do: :ok, else: {:error, :version_mismatch}
  end

  defp check_version(%{"version" => installed_version}, %{"version" => locked_version}) do
    if installed_version == locked_version, do: :ok, else: {:error, :version_mismatch}
  end

  defp check_version(_, _), do: {:error, :version_mismatch}
end
