defmodule NPM.Patch do
  @moduledoc """
  Manages patched packages (patch-package style).

  Tracks patches applied to node_modules packages and
  verifies they are still applied after install.
  """

  @patches_dir "patches"

  @doc """
  Lists all patch files in the patches directory.
  """
  @spec list(String.t()) :: [%{package: String.t(), file: String.t()}]
  def list(project_dir \\ ".") do
    dir = Path.join(project_dir, @patches_dir)

    case File.ls(dir) do
      {:ok, files} ->
        files
        |> Enum.filter(&String.ends_with?(&1, ".patch"))
        |> Enum.map(fn file ->
          %{package: extract_package_name(file), file: file}
        end)
        |> Enum.sort_by(& &1.package)

      _ ->
        []
    end
  end

  @doc """
  Checks if a package has patches.
  """
  @spec patched?(String.t(), String.t()) :: boolean()
  def patched?(package_name, project_dir \\ ".") do
    list(project_dir)
    |> Enum.any?(&(&1.package == package_name))
  end

  @doc """
  Returns the count of patches.
  """
  @spec count(String.t()) :: non_neg_integer()
  def count(project_dir \\ "."), do: list(project_dir) |> length()

  @doc """
  Extracts the package name from a patch filename.

  Supports formats like `lodash+4.17.21.patch` and `@scope+pkg+1.0.0.patch`.
  """
  @spec extract_package_name(String.t()) :: String.t()
  def extract_package_name(filename) do
    base = String.trim_trailing(filename, ".patch")

    case String.split(base, "+") do
      ["@" <> scope, name | _rest] -> "@#{scope}/#{name}"
      [name | _rest] -> name
      _ -> base
    end
  end

  @doc """
  Generates a patch filename for a package.
  """
  @spec filename(String.t(), String.t()) :: String.t()
  def filename(package_name, version) do
    safe_name = String.replace(package_name, "/", "+")
    "#{safe_name}+#{version}.patch"
  end

  @doc """
  Returns all patched package names.
  """
  @spec patched_packages(String.t()) :: [String.t()]
  def patched_packages(project_dir \\ ".") do
    list(project_dir) |> Enum.map(& &1.package) |> Enum.uniq()
  end
end
