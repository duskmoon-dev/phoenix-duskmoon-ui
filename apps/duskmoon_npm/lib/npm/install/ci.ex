defmodule NPM.Install.CI do
  @moduledoc """
  Strict frozen install for CI environments.

  Implements `npm ci` behavior — validates lockfile matches package.json
  exactly, cleans node_modules, and installs from lockfile only.
  No lockfile modifications allowed.
  """

  @type validation_error ::
          :lockfile_missing
          | :package_json_missing
          | {:missing_dep, String.t()}
          | {:extra_dep, String.t()}

  @doc """
  Validates that the lockfile is in sync with package.json.
  """
  @spec validate(String.t()) :: :ok | {:error, [validation_error()]}
  def validate(project_dir \\ ".") do
    pkg_path = Path.join(project_dir, "package.json")
    lock_path = Path.join(project_dir, "npm.lock")

    with {:pkg, {:ok, pkg_content}} <- {:pkg, File.read(pkg_path)},
         {:lock, {:ok, _lock_content}} <- {:lock, File.read(lock_path)} do
      pkg_data = NPM.JSON.decode!(pkg_content)
      deps = Map.merge(pkg_data["dependencies"] || %{}, pkg_data["devDependencies"] || %{})
      validate_deps(deps, lock_path)
    else
      {:pkg, _} -> {:error, [:package_json_missing]}
      {:lock, _} -> {:error, [:lockfile_missing]}
    end
  end

  @doc """
  Checks if CI install is possible (all prerequisites met).
  """
  @spec preflight(String.t()) :: :ok | {:error, [String.t()]}
  def preflight(project_dir \\ ".") do
    issues =
      [
        check_file(project_dir, "package.json", "package.json is required"),
        check_file(project_dir, "npm.lock", "npm.lock is required — run mix npm.install first")
      ]
      |> Enum.reject(&is_nil/1)

    if issues == [], do: :ok, else: {:error, issues}
  end

  @doc """
  Determines if node_modules needs to be cleaned before install.
  """
  @spec needs_clean?(String.t()) :: boolean()
  def needs_clean?(project_dir \\ ".") do
    nm_path = Path.join(project_dir, "node_modules")
    File.exists?(nm_path) and File.dir?(nm_path)
  end

  @doc """
  Formats validation errors for display.
  """
  @spec format_errors([validation_error()]) :: String.t()
  def format_errors(errors) do
    Enum.map_join(errors, "\n", &format_error/1)
  end

  defp validate_deps(deps, lock_path) do
    case NPM.Lockfile.read(lock_path) do
      {:ok, lockfile} ->
        missing =
          deps
          |> Map.keys()
          |> Enum.reject(&Map.has_key?(lockfile, &1))
          |> Enum.map(&{:missing_dep, &1})

        if missing == [], do: :ok, else: {:error, missing}

      {:error, _} ->
        {:error, [:lockfile_missing]}
    end
  end

  defp check_file(dir, name, message) do
    if File.exists?(Path.join(dir, name)), do: nil, else: message
  end

  defp format_error(:lockfile_missing), do: "npm.lock is missing"
  defp format_error(:package_json_missing), do: "package.json is missing"
  defp format_error({:missing_dep, name}), do: "#{name} is in package.json but not in lockfile"
  defp format_error({:extra_dep, name}), do: "#{name} is in lockfile but not in package.json"
end
