defmodule NPM.SemverUtil do
  @moduledoc """
  Utility functions for working with npm semver ranges.

  Provides higher-level operations that build on `NPMSemver.matches?/2`
  for common npm workflows like finding the best matching version,
  filtering compatible versions, and determining update targets.
  """

  @doc """
  Find the highest version from a list that satisfies a range.

  Returns `{:ok, version}` or `:none`.
  """
  @spec max_satisfying([String.t()], String.t()) :: {:ok, String.t()} | :none
  def max_satisfying(versions, range) do
    versions
    |> Enum.filter(&matches?(&1, range))
    |> sort_desc()
    |> case do
      [best | _] -> {:ok, best}
      [] -> :none
    end
  end

  @doc """
  Find the lowest version from a list that satisfies a range.
  """
  @spec min_satisfying([String.t()], String.t()) :: {:ok, String.t()} | :none
  def min_satisfying(versions, range) do
    versions
    |> Enum.filter(&matches?(&1, range))
    |> sort_asc()
    |> case do
      [lowest | _] -> {:ok, lowest}
      [] -> :none
    end
  end

  @doc """
  Filter a list of versions to only those satisfying a range.
  """
  @spec filter([String.t()], String.t()) :: [String.t()]
  def filter(versions, range) do
    Enum.filter(versions, &matches?(&1, range))
  end

  @doc """
  Check if any version in the list satisfies the range.
  """
  @spec any_satisfying?([String.t()], String.t()) :: boolean()
  def any_satisfying?(versions, range) do
    Enum.any?(versions, &matches?(&1, range))
  end

  @doc """
  Determine the type of update between two versions.

  Returns `:major`, `:minor`, `:patch`, or `:prerelease`.
  """
  @spec update_type(String.t(), String.t()) :: :major | :minor | :patch | :prerelease | :none
  def update_type(from, to) do
    with {:ok, {fmaj, fmin, fpatch}} <- parse(from),
         {:ok, {tmaj, tmin, tpatch}} <- parse(to) do
      cond do
        fmaj != tmaj -> :major
        fmin != tmin -> :minor
        fpatch != tpatch -> :patch
        true -> :none
      end
    else
      _ -> :none
    end
  end

  defp matches?(version, range) do
    NPMSemver.matches?(version, range)
  rescue
    ArgumentError -> false
  end

  defp sort_desc(versions) do
    Enum.sort(versions, fn a, b ->
      case {Version.parse(a), Version.parse(b)} do
        {{:ok, va}, {:ok, vb}} -> Version.compare(va, vb) == :gt
        _ -> a >= b
      end
    end)
  end

  defp sort_asc(versions) do
    Enum.sort(versions, fn a, b ->
      case {Version.parse(a), Version.parse(b)} do
        {{:ok, va}, {:ok, vb}} -> Version.compare(va, vb) == :lt
        _ -> a <= b
      end
    end)
  end

  defp parse(version) do
    case String.split(version, ".") do
      [maj, min, patch_str] ->
        patch = patch_str |> String.split("-") |> List.first()
        {:ok, {String.to_integer(maj), String.to_integer(min), String.to_integer(patch)}}

      _ ->
        :error
    end
  rescue
    _ -> :error
  end
end
