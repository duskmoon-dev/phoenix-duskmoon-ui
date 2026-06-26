defmodule NPM.Install.Link do
  @moduledoc """
  Manages local package linking via symlinks.

  Implements `npm link` functionality — creates symlinks in
  node_modules pointing to local package directories for development.
  """

  @type link_info :: %{
          name: String.t(),
          target: String.t(),
          link_path: String.t()
        }

  @doc """
  Links a local package into node_modules.
  """
  @spec link(String.t(), String.t()) :: {:ok, link_info()} | {:error, term()}
  def link(package_dir, node_modules_dir \\ "node_modules") do
    with {:ok, name} <- read_package_name(package_dir) do
      link_path = resolve_link_path(node_modules_dir, name)
      target = Path.expand(package_dir)

      File.mkdir_p!(Path.dirname(link_path))
      File.rm_rf!(link_path)

      case File.ln_s(target, link_path) do
        :ok ->
          {:ok, %{name: name, target: target, link_path: link_path}}

        {:error, reason} ->
          {:error, reason}
      end
    end
  end

  @doc """
  Unlinks a package from node_modules.
  """
  @spec unlink(String.t(), String.t()) :: :ok | {:error, term()}
  def unlink(name, node_modules_dir \\ "node_modules") do
    link_path = resolve_link_path(node_modules_dir, name)

    case File.read_link(link_path) do
      {:ok, _target} ->
        File.rm(link_path)

      {:error, _} ->
        {:error, :not_linked}
    end
  end

  @doc """
  Lists all linked packages in node_modules.
  """
  @spec list(String.t()) :: [link_info()]
  def list(node_modules_dir \\ "node_modules") do
    case File.ls(node_modules_dir) do
      {:ok, entries} ->
        entries
        |> Enum.flat_map(&find_links(node_modules_dir, &1))
        |> Enum.sort_by(& &1.name)

      _ ->
        []
    end
  end

  @doc """
  Checks if a package is linked (symlinked, not installed normally).
  """
  @spec linked?(String.t(), String.t()) :: boolean()
  def linked?(name, node_modules_dir \\ "node_modules") do
    link_path = resolve_link_path(node_modules_dir, name)

    case File.read_link(link_path) do
      {:ok, _} -> true
      _ -> false
    end
  end

  defp read_package_name(dir) do
    pkg_path = Path.join(dir, "package.json")

    case File.read(pkg_path) do
      {:ok, content} ->
        data = NPM.JSON.decode!(content)
        {:ok, data["name"] || Path.basename(dir)}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp resolve_link_path(nm_dir, name) do
    Path.join(nm_dir, name)
  end

  defp find_links(nm_dir, entry) do
    if String.starts_with?(entry, "@") do
      find_scoped_links(nm_dir, entry)
    else
      check_link(nm_dir, entry, entry)
    end
  end

  defp find_scoped_links(nm_dir, scope) do
    scope_dir = Path.join(nm_dir, scope)

    case File.ls(scope_dir) do
      {:ok, subs} -> Enum.flat_map(subs, &check_link(scope_dir, &1, "#{scope}/#{&1}"))
      _ -> []
    end
  end

  defp check_link(parent, entry, name) do
    path = Path.join(parent, entry)

    case File.read_link(path) do
      {:ok, target} -> [%{name: name, target: target, link_path: path}]
      _ -> []
    end
  end
end
