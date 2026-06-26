defmodule NPM.Os do
  @moduledoc """
  Checks package os/cpu field compatibility.

  npm packages can restrict which platforms they support via
  the `os` and `cpu` fields in package.json. Delegates to
  `NPM.Platform` for actual OS/CPU detection.
  """

  @doc """
  Returns the current operating system name (npm convention).
  """
  @spec current_os :: String.t()
  defdelegate current_os, to: NPM.Platform

  @doc """
  Returns the current CPU architecture (npm convention).
  """
  @spec current_cpu :: String.t()
  defdelegate current_cpu, to: NPM.Platform

  @doc """
  Checks if the current OS is compatible with a package's os field.
  """
  @spec os_compatible?(map()) :: boolean()
  def os_compatible?(%{"os" => os_list}) when is_list(os_list) do
    NPM.Platform.os_compatible?(os_list)
  end

  def os_compatible?(_), do: true

  @doc """
  Checks if the current CPU is compatible with a package's cpu field.
  """
  @spec cpu_compatible?(map()) :: boolean()
  def cpu_compatible?(%{"cpu" => cpu_list}) when is_list(cpu_list) do
    NPM.Platform.cpu_compatible?(cpu_list)
  end

  def cpu_compatible?(_), do: true

  @doc """
  Checks both os and cpu compatibility.
  """
  @spec compatible?(map()) :: boolean()
  def compatible?(pkg_data) do
    os_compatible?(pkg_data) and cpu_compatible?(pkg_data)
  end

  @doc """
  Scans packages for platform incompatibilities.
  """
  @spec check_all(String.t()) :: [%{name: String.t(), reason: String.t()}]
  def check_all(node_modules_dir) do
    case File.ls(node_modules_dir) do
      {:ok, entries} ->
        entries
        |> Enum.reject(&String.starts_with?(&1, "."))
        |> Enum.flat_map(&check_pkg(node_modules_dir, &1))
        |> Enum.sort_by(& &1.name)

      _ ->
        []
    end
  end

  defp check_pkg(nm_dir, name) do
    pkg_path = Path.join([nm_dir, name, "package.json"])

    case File.read(pkg_path) do
      {:ok, content} ->
        data = NPM.JSON.decode!(content)
        build_issues(name, data)

      _ ->
        []
    end
  rescue
    _ -> []
  end

  defp build_issues(name, data) do
    issues = []

    issues =
      if os_compatible?(data),
        do: issues,
        else: [%{name: name, reason: "incompatible os"} | issues]

    if cpu_compatible?(data),
      do: issues,
      else: [%{name: name, reason: "incompatible cpu"} | issues]
  end
end
