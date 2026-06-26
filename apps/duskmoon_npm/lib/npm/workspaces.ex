defmodule NPM.Workspaces do
  @moduledoc """
  Discovers and validates npm workspace packages.
  """

  @doc """
  Extracts workspace globs from package.json.
  """
  @spec globs(map()) :: [String.t()]
  def globs(%{"workspaces" => %{"packages" => pkgs}}) when is_list(pkgs), do: pkgs
  def globs(%{"workspaces" => ws}) when is_list(ws), do: ws
  def globs(_), do: []

  @doc """
  Checks if workspaces are configured.
  """
  @spec configured?(map()) :: boolean()
  def configured?(data), do: globs(data) != []

  @doc """
  Discovers workspace packages on disk matching globs.
  """
  @spec discover(String.t(), [String.t()]) :: [map()]
  def discover(root_dir, workspace_globs) do
    workspace_globs
    |> Enum.flat_map(fn glob ->
      Path.join(root_dir, glob)
      |> Path.wildcard()
      |> Enum.filter(&File.dir?/1)
    end)
    |> Enum.flat_map(&read_workspace_pkg/1)
    |> Enum.sort_by(& &1.name)
  end

  @doc """
  Validates workspace packages for common issues.
  """
  @spec validate([map()]) :: [map()]
  def validate(workspace_pkgs) do
    names = Enum.map(workspace_pkgs, & &1.name)
    duplicates = names -- Enum.uniq(names)

    issues =
      workspace_pkgs
      |> Enum.flat_map(fn pkg ->
        issues = []

        issues =
          if pkg.name == nil,
            do: [%{path: pkg.path, issue: "missing name"} | issues],
            else: issues

        issues =
          if pkg.version == nil,
            do: [%{path: pkg.path, issue: "missing version"} | issues],
            else: issues

        if pkg.name in duplicates do
          [%{path: pkg.path, issue: "duplicate name: #{pkg.name}"} | issues]
        else
          issues
        end
      end)

    Enum.sort_by(issues, & &1.path)
  end

  @doc """
  Counts workspace packages.
  """
  @spec count(map()) :: non_neg_integer()
  def count(data), do: length(globs(data))

  defp read_workspace_pkg(dir) do
    pkg_path = Path.join(dir, "package.json")

    case File.read(pkg_path) do
      {:ok, content} ->
        data = NPM.JSON.decode!(content)

        [
          %{
            name: data["name"],
            version: data["version"],
            path: dir,
            private: data["private"] == true
          }
        ]

      _ ->
        []
    end
  rescue
    _ -> []
  end
end
