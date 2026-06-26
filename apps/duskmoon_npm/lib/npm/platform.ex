defmodule NPM.Platform do
  @moduledoc """
  Platform compatibility checks for npm packages.

  Evaluates `os`, `cpu`, and `engines` fields from `package.json`
  against the current system to detect incompatible packages.
  """

  @doc """
  Check if a package is compatible with the current OS.

  The `os` field is an array of allowed (or disallowed with `!` prefix)
  operating systems.
  """
  @spec os_compatible?([String.t()]) :: boolean()
  def os_compatible?([]), do: true

  def os_compatible?(os_list) when is_list(os_list) do
    current = current_os()

    has_allowlist = Enum.any?(os_list, &(not String.starts_with?(&1, "!")))
    has_blocklist = Enum.any?(os_list, &String.starts_with?(&1, "!"))

    blocked = Enum.any?(os_list, &(&1 == "!#{current}"))

    if has_allowlist do
      Enum.member?(os_list, current) and not blocked
    else
      not blocked or not has_blocklist
    end
  end

  def os_compatible?(_), do: true

  @doc """
  Check if a package is compatible with the current CPU architecture.

  The `cpu` field is an array of allowed (or disallowed with `!` prefix)
  CPU architectures.
  """
  @spec cpu_compatible?([String.t()]) :: boolean()
  def cpu_compatible?([]), do: true

  def cpu_compatible?(cpu_list) when is_list(cpu_list) do
    current = current_cpu()

    has_allowlist = Enum.any?(cpu_list, &(not String.starts_with?(&1, "!")))
    has_blocklist = Enum.any?(cpu_list, &String.starts_with?(&1, "!"))

    blocked = Enum.any?(cpu_list, &(&1 == "!#{current}"))

    if has_allowlist do
      Enum.member?(cpu_list, current) and not blocked
    else
      not blocked or not has_blocklist
    end
  end

  def cpu_compatible?(_), do: true

  @doc "Get the current OS name in npm format."
  @spec current_os :: String.t()
  def current_os do
    case :os.type() do
      {:unix, :darwin} -> "darwin"
      {:unix, :linux} -> "linux"
      {:unix, :freebsd} -> "freebsd"
      {:win32, _} -> "win32"
      {_, os} -> to_string(os)
    end
  end

  @doc "Get the current CPU architecture in npm format."
  @spec current_cpu :: String.t()
  def current_cpu do
    arch = :erlang.system_info(:system_architecture) |> to_string()

    cond do
      String.contains?(arch, "x86_64") or String.contains?(arch, "amd64") -> "x64"
      String.contains?(arch, "aarch64") or String.contains?(arch, "arm64") -> "arm64"
      String.contains?(arch, "arm") -> "arm"
      String.contains?(arch, "i686") or String.contains?(arch, "i386") -> "ia32"
      true -> arch
    end
  end

  @doc """
  Check if the `engines` field is satisfied.

  Returns a list of warning strings for unsatisfied engine constraints.
  Currently only checks the `node` engine as informational.
  """
  @spec check_engines(%{String.t() => String.t()}) :: [String.t()]
  def check_engines(engines) when is_map(engines) and map_size(engines) == 0, do: []

  def check_engines(engines) when is_map(engines) do
    Enum.flat_map(engines, fn
      {"node", range} -> ["requires node #{range}"]
      {"npm", range} -> ["requires npm #{range}"]
      _ -> []
    end)
  end

  def check_engines(_), do: []
end
