defmodule NPM.Diagnostics.EnvCheck do
  @moduledoc """
  Environment checks for npm_ex.

  Detects available Node.js installations, npm configuration,
  and checks compatibility with package engine requirements.
  """

  @doc """
  Check if Node.js is available on the system PATH.

  Returns `{:ok, version}` or `:not_found`.
  """
  @spec node_version :: {:ok, String.t()} | :not_found
  def node_version do
    case System.cmd("node", ["--version"], stderr_to_stdout: true) do
      {version, 0} -> {:ok, String.trim(version)}
      _ -> :not_found
    end
  rescue
    ErlangError -> :not_found
  end

  @doc """
  Check if a package's engine requirements are met.

  Compares the `engines` field from package.json against the
  currently available Node.js version.
  """
  @spec check_engines(%{String.t() => String.t()}) :: :ok | {:warn, [String.t()]}
  def check_engines(engines) when map_size(engines) == 0, do: :ok

  def check_engines(engines) do
    warnings =
      engines
      |> Enum.flat_map(&check_single_engine/1)

    if warnings == [], do: :ok, else: {:warn, warnings}
  end

  defp check_single_engine({"node", range}) do
    case node_version() do
      {:ok, "v" <> version} ->
        if version_satisfies?(version, range),
          do: [],
          else: ["node #{version} does not satisfy #{range}"]

      :not_found ->
        ["node not found (requires #{range})"]
    end
  end

  defp check_single_engine({engine, _range}) do
    ["unknown engine: #{engine}"]
  end

  defp version_satisfies?(version, range) do
    NPMSemver.matches?(version, range)
  rescue
    _ -> true
  end

  @doc """
  Get a summary of the current environment.

  Returns a map with system info relevant to npm operations.
  """
  @spec summary :: map()
  def summary do
    %{
      elixir_version: System.version(),
      otp_version: :erlang.system_info(:otp_release) |> to_string(),
      os: NPM.Platform.current_os(),
      cpu: NPM.Platform.current_cpu(),
      node: node_version(),
      npm_ex_version: Application.spec(:duskmoon_npm, :vsn) |> to_string()
    }
  end
end
