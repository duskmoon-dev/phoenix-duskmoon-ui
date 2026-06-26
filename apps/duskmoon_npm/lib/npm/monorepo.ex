defmodule NPM.Monorepo do
  @moduledoc """
  Detects monorepo tooling and structure.

  Identifies which monorepo tool is in use (npm workspaces, lerna,
  turborepo, nx, rush) and provides workspace discovery.
  """

  @doc """
  Detects the monorepo tool in use.
  """
  @spec detect(String.t()) :: [atom()]
  def detect(project_dir \\ ".") do
    checks = [
      {:npm_workspaces, "package.json", &has_workspaces?/1},
      {:lerna, "lerna.json", &File.exists?/1},
      {:turborepo, "turbo.json", &File.exists?/1},
      {:nx, "nx.json", &File.exists?/1},
      {:rush, "rush.json", &File.exists?/1},
      {:pnpm_workspaces, "pnpm-workspace.yaml", &File.exists?/1}
    ]

    Enum.flat_map(checks, fn {tool, file, checker} ->
      path = Path.join(project_dir, file)
      if checker.(path), do: [tool], else: []
    end)
  end

  @doc """
  Returns the primary monorepo tool.
  """
  @spec primary(String.t()) :: atom() | nil
  def primary(project_dir \\ ".") do
    detect(project_dir) |> List.first()
  end

  @doc """
  Checks if the project is a monorepo.
  """
  @spec monorepo?(String.t()) :: boolean()
  def monorepo?(project_dir \\ ".") do
    detect(project_dir) != []
  end

  @doc """
  Returns monorepo metadata.
  """
  @spec info(String.t()) :: map()
  def info(project_dir \\ ".") do
    tools = detect(project_dir)

    %{
      is_monorepo: tools != [],
      tools: tools,
      primary: List.first(tools),
      tool_count: length(tools)
    }
  end

  @doc """
  Formats detection results.
  """
  @spec format_info(map()) :: String.t()
  def format_info(%{is_monorepo: false}), do: "Not a monorepo."

  def format_info(%{tools: tools, primary: primary}) do
    tool_list = Enum.map_join(tools, ", ", &to_string/1)
    "Monorepo detected (#{tool_list}), primary: #{primary}"
  end

  defp has_workspaces?(path) do
    case File.read(path) do
      {:ok, content} ->
        data = NPM.JSON.decode!(content)
        is_list(data["workspaces"]) and data["workspaces"] != []

      _ ->
        false
    end
  rescue
    _ -> false
  end
end
