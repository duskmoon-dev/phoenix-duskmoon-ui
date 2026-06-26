defmodule NPM.PlatformOptional do
  @moduledoc """
  Selects optional dependencies that match the current platform.

  Many npm packages publish one optional package per operating system and CPU,
  for example native bindings for Linux, macOS, Windows, x64, or arm64. The
  lockfile can contain all of those packages for portability, but linking should
  only install the package that can run on the current machine.

  This module groups platform-specific package families and keeps the best match
  for the current OS/CPU while leaving ordinary optional dependencies untouched.
  """

  @spec select(map()) :: map()
  def select(optional_dependencies) when map_size(optional_dependencies) == 0, do: %{}

  def select(optional_dependencies) when is_map(optional_dependencies) do
    cache_key = :erlang.phash2(optional_dependencies)

    case Process.get({__MODULE__, cache_key}) do
      nil ->
        result = do_select(optional_dependencies)
        Process.put({__MODULE__, cache_key}, result)
        result

      cached ->
        cached
    end
  end

  defp do_select(optional_dependencies) do
    optional_dependencies
    |> Enum.group_by(fn {name, _range} -> package_family(name) end)
    |> Enum.flat_map(fn {_family, deps} -> select_group(deps) end)
    |> Map.new()
  end

  defp select_group([{name, range}]) do
    [{name, range}]
  end

  defp select_group(deps) do
    exact_matches = Enum.filter(deps, fn {name, _range} -> current_match(name) end)

    case exact_matches do
      [first | _] -> [first]
      [] -> best_platform_match(deps)
    end
  end

  defp best_platform_match(deps) do
    case Enum.filter(deps, fn {name, _range} -> package_matches_platform?(name) end) do
      [] -> []
      matches -> [Enum.max_by(matches, fn {name, _range} -> platform_score(name) end)]
    end
  end

  defp package_matches_platform?(name) do
    platform_score(name) > 0
  end

  defp platform_score(name) do
    case NPM.Registry.get_packument(name) do
      {:ok, packument} ->
        packument.versions |> Map.values() |> Enum.map(&version_score/1) |> Enum.max(fn -> 0 end)

      _ ->
        0
    end
  end

  defp version_score(info) do
    os_match = if NPM.Platform.os_compatible?(info.os), do: 1, else: 0
    cpu_match = if NPM.Platform.cpu_compatible?(info.cpu), do: 1, else: 0
    os_match + cpu_match
  end

  @platform_tokens ~w(darwin linux win32 freebsd android openharmony arm64 x64 ia32 arm x86 ppc64 s390x riscv64 musl gnu msvc gnueabihf musleabihf)

  defp package_family(name) do
    if platform_binding?(name), do: binding_family(name), else: name
  end

  defp binding_family(name) do
    case Regex.run(~r/^(@[^\/]+\/)/, name) do
      [scope | _] -> scope
      nil -> name |> String.split("-", parts: 2) |> hd()
    end
  end

  defp platform_binding?(name) do
    lower = String.downcase(name)
    Enum.count(@platform_tokens, &String.contains?(lower, &1)) >= 2
  end

  @spec current_match(String.t()) :: boolean()
  def current_match(name) do
    os = NPM.Platform.current_os()
    cpu = NPM.Platform.current_cpu()
    lower = String.downcase(name)
    String.contains?(lower, os) and String.contains?(lower, cpu)
  end
end
