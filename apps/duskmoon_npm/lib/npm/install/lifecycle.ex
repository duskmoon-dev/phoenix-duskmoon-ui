defmodule NPM.Install.Lifecycle do
  @moduledoc """
  Detect and manage npm lifecycle scripts.

  npm packages can define `preinstall`, `install`, `postinstall`,
  `prepare`, and other scripts in their `package.json`.

  By default, npm_ex does NOT run lifecycle scripts for security.
  This module provides detection and opt-in execution.
  """

  @install_hooks ["preinstall", "install", "postinstall", "prepare"]

  @doc """
  Detect lifecycle scripts in a package's `package.json`.

  Returns a list of `{hook_name, command}` tuples for install-related hooks.
  """
  @spec detect(String.t()) :: [{String.t(), String.t()}]
  def detect(package_json_path) do
    case File.read(package_json_path) do
      {:ok, content} ->
        content |> NPM.JSON.decode!() |> Map.get("scripts", %{}) |> extract_hooks()

      {:error, _} ->
        []
    end
  end

  defp extract_hooks(scripts) do
    @install_hooks
    |> Enum.filter(&Map.has_key?(scripts, &1))
    |> Enum.map(&{&1, scripts[&1]})
  end

  @doc """
  Detect lifecycle scripts across all packages in `node_modules`.

  Returns a map of `package_name => [{hook, command}]` for packages
  that have install-related scripts.
  """
  @spec detect_all(String.t()) :: %{String.t() => [{String.t(), String.t()}]}
  def detect_all(node_modules_dir) do
    node_modules_dir
    |> list_packages()
    |> Enum.flat_map(fn name ->
      pkg_json = Path.join([node_modules_dir, name, "package.json"])
      hooks = detect(pkg_json)
      if hooks == [], do: [], else: [{name, hooks}]
    end)
    |> Map.new()
  end

  @doc "List the install hook names."
  @spec hook_names :: [String.t()]
  def hook_names, do: @install_hooks

  defp list_packages(dir) do
    dir
    |> list_dir()
    |> Enum.reject(&String.starts_with?(&1, "."))
    |> Enum.flat_map(&expand_entry(dir, &1))
  end

  defp expand_entry(dir, "@" <> _ = scope) do
    dir |> Path.join(scope) |> list_dir() |> Enum.map(&"#{scope}/#{&1}")
  end

  defp expand_entry(_dir, entry), do: [entry]

  defp list_dir(path) do
    case File.ls(path) do
      {:ok, entries} -> entries
      {:error, _} -> []
    end
  end
end
