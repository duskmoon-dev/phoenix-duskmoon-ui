defmodule NPM.VersionUtil do
  @moduledoc """
  Utilities for npm version string manipulation.

  Helpers for parsing, comparing, and formatting npm version strings
  that go beyond what Elixir's `Version` module handles.
  """

  @doc """
  Parse a version string into `{major, minor, patch}` tuple.

  Returns `:error` for invalid versions.
  """
  @spec parse_triple(String.t()) ::
          {:ok, {non_neg_integer(), non_neg_integer(), non_neg_integer()}} | :error
  def parse_triple(version) do
    case Version.parse(version) do
      {:ok, %{major: maj, minor: min, patch: patch}} -> {:ok, {maj, min, patch}}
      :error -> :error
    end
  end

  @doc """
  Compare two version strings.

  Returns `:gt`, `:eq`, or `:lt`.
  """
  @spec compare(String.t(), String.t()) :: :gt | :eq | :lt
  def compare(a, b) do
    Version.compare(a, b)
  end

  @doc """
  Check if version `a` is greater than version `b`.
  """
  @spec gt?(String.t(), String.t()) :: boolean()
  def gt?(a, b), do: compare(a, b) == :gt

  @doc """
  Check if version `a` is less than version `b`.
  """
  @spec lt?(String.t(), String.t()) :: boolean()
  def lt?(a, b), do: compare(a, b) == :lt

  @doc """
  Get the major version number from a version string.
  """
  @spec major(String.t()) :: non_neg_integer() | :error
  def major(version) do
    case parse_triple(version) do
      {:ok, {maj, _, _}} -> maj
      :error -> :error
    end
  end

  @doc """
  Get the minor version number from a version string.
  """
  @spec minor(String.t()) :: non_neg_integer() | :error
  def minor(version) do
    case parse_triple(version) do
      {:ok, {_, min, _}} -> min
      :error -> :error
    end
  end

  @doc """
  Check if a version is a prerelease (has a pre tag).
  """
  @spec prerelease?(String.t()) :: boolean()
  def prerelease?(version) do
    case Version.parse(version) do
      {:ok, %{pre: pre}} -> pre != []
      :error -> false
    end
  end

  @doc """
  Increment the patch version.
  """
  @spec bump_patch(String.t()) :: String.t() | :error
  def bump_patch(version) do
    case parse_triple(version) do
      {:ok, {maj, min, patch}} -> "#{maj}.#{min}.#{patch + 1}"
      :error -> :error
    end
  end

  @doc """
  Increment the minor version (resets patch to 0).
  """
  @spec bump_minor(String.t()) :: String.t() | :error
  def bump_minor(version) do
    case parse_triple(version) do
      {:ok, {maj, min, _}} -> "#{maj}.#{min + 1}.0"
      :error -> :error
    end
  end

  @doc """
  Increment the major version (resets minor and patch to 0).
  """
  @spec bump_major(String.t()) :: String.t() | :error
  def bump_major(version) do
    case parse_triple(version) do
      {:ok, {maj, _, _}} -> "#{maj + 1}.0.0"
      :error -> :error
    end
  end

  @doc """
  Sort a list of version strings.
  """
  @spec sort([String.t()]) :: [String.t()]
  def sort(versions) do
    versions
    |> Enum.flat_map(fn v ->
      case Version.parse(v) do
        {:ok, ver} -> [{v, ver}]
        :error -> []
      end
    end)
    |> Enum.sort_by(&elem(&1, 1), Version)
    |> Enum.map(&elem(&1, 0))
  end

  @doc """
  Get the latest (highest) version from a list.
  """
  @spec latest([String.t()]) :: String.t() | nil
  def latest(versions) do
    sort(versions) |> List.last()
  end
end
