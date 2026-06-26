defmodule NPM.Diagnostics.EngineCheck do
  @moduledoc """
  Checks engine compatibility across all installed packages.

  Validates that the current Node.js version (if installed) satisfies
  engine requirements declared by packages in node_modules.
  """

  @type engine_issue :: %{
          package: String.t(),
          engine: String.t(),
          required: String.t(),
          actual: String.t() | nil,
          satisfied: boolean()
        }

  @doc """
  Scans node_modules for engine requirements and checks compatibility.
  """
  @spec check_all(String.t()) :: [engine_issue()]
  def check_all(node_modules_dir) do
    node_version = current_node_version()

    case File.ls(node_modules_dir) do
      {:ok, entries} ->
        entries
        |> Enum.flat_map(&read_engines(node_modules_dir, &1))
        |> Enum.flat_map(&check_engine(&1, node_version))
        |> Enum.sort_by(& &1.package)

      _ ->
        []
    end
  end

  @doc """
  Checks a single package's engines against current versions.
  """
  @spec check_package(map(), String.t() | nil) :: [engine_issue()]
  def check_package(%{"engines" => engines} = data, node_version) when is_map(engines) do
    name = data["name"] || "unknown"
    check_engine({name, engines}, node_version)
  end

  def check_package(_, _), do: []

  @doc """
  Returns only unsatisfied engine requirements.
  """
  @spec unsatisfied([engine_issue()]) :: [engine_issue()]
  def unsatisfied(issues), do: Enum.reject(issues, & &1.satisfied)

  @doc """
  Formats engine issues for display.
  """
  @spec format_issues([engine_issue()]) :: String.t()
  def format_issues([]), do: "All engine requirements satisfied."

  def format_issues(issues) do
    Enum.map_join(issues, "\n", fn issue ->
      status = if issue.satisfied, do: "✓", else: "✗"
      actual = issue.actual || "not installed"
      "#{status} #{issue.package}: #{issue.engine} #{issue.required} (current: #{actual})"
    end)
  end

  defp read_engines(nm_dir, entry) do
    if String.starts_with?(entry, "@") do
      read_scoped_engines(nm_dir, entry)
    else
      read_single_engines(nm_dir, entry, entry)
    end
  end

  defp read_scoped_engines(nm_dir, scope) do
    scope_dir = Path.join(nm_dir, scope)

    case File.ls(scope_dir) do
      {:ok, subs} -> Enum.flat_map(subs, &read_single_engines(scope_dir, &1, "#{scope}/#{&1}"))
      _ -> []
    end
  end

  defp read_single_engines(parent, name, full_name) do
    pkg_json = Path.join([parent, name, "package.json"])

    case File.read(pkg_json) do
      {:ok, content} ->
        data = NPM.JSON.decode!(content)

        case data["engines"] do
          engines when is_map(engines) and map_size(engines) > 0 -> [{full_name, engines}]
          _ -> []
        end

      _ ->
        []
    end
  rescue
    _ -> []
  end

  defp check_engine({name, engines}, node_version) do
    Enum.flat_map(engines, fn {engine, range} ->
      {actual, satisfied} = evaluate_engine(engine, range, node_version)

      [
        %{
          package: name,
          engine: engine,
          required: range,
          actual: actual,
          satisfied: satisfied
        }
      ]
    end)
  end

  defp evaluate_engine("node", range, node_version) do
    case node_version do
      nil -> {nil, true}
      version -> {version, NPMSemver.matches?(version, range)}
    end
  rescue
    _ -> {node_version, true}
  end

  defp evaluate_engine(_engine, _range, _node_version), do: {nil, true}

  defp current_node_version do
    case System.cmd("node", ["--version"], stderr_to_stdout: true) do
      {"v" <> version, 0} -> String.trim(version)
      _ -> nil
    end
  rescue
    _ -> nil
  end
end
