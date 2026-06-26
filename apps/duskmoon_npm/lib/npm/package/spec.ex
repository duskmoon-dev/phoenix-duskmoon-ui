defmodule NPM.Package.Spec do
  @moduledoc """
  Parse npm package specifiers into structured data.

  npm supports multiple specifier formats:

      lodash          # name only (latest)
      lodash@^4.0     # name with range
      @scope/pkg@1.0  # scoped with range
      npm:react@^18   # alias
      file:../local   # file reference
      git+https://... # git reference
      https://...tgz  # URL tarball
  """

  @type t :: %{
          raw: String.t(),
          name: String.t(),
          range: String.t() | nil,
          type: :registry | :alias | :file | :git | :url
        }

  @doc """
  Parse a package specifier string.
  """
  @spec parse(String.t()) :: t()
  def parse("npm:" <> _ = spec) do
    case NPM.Alias.parse(spec) do
      {:alias, name, range} ->
        %{raw: spec, name: name, range: range, type: :alias}

      {:normal, _} ->
        %{raw: spec, name: spec, range: nil, type: :registry}
    end
  end

  def parse("file:" <> _ = spec) do
    %{raw: spec, name: spec, range: nil, type: :file}
  end

  def parse("git+" <> _ = spec) do
    %{raw: spec, name: spec, range: nil, type: :git}
  end

  def parse("git://" <> _ = spec) do
    %{raw: spec, name: spec, range: nil, type: :git}
  end

  def parse("github:" <> _ = spec) do
    %{raw: spec, name: spec, range: nil, type: :git}
  end

  def parse("http://" <> _ = spec) do
    %{raw: spec, name: spec, range: nil, type: :url}
  end

  def parse("https://" <> _ = spec) do
    %{raw: spec, name: spec, range: nil, type: :url}
  end

  def parse("@" <> _ = spec) do
    case String.split(spec, "@", parts: 3) do
      ["", scope_name, range] ->
        %{raw: spec, name: "@#{scope_name}", range: range, type: :registry}

      _ ->
        %{raw: spec, name: spec, range: nil, type: :registry}
    end
  end

  def parse(spec) do
    case String.split(spec, "@", parts: 2) do
      [name, range] when name != "" ->
        %{raw: spec, name: name, range: range, type: :registry}

      _ ->
        %{raw: spec, name: spec, range: nil, type: :registry}
    end
  end

  @doc """
  Check if a specifier targets the registry.
  """
  @spec registry?(t()) :: boolean()
  def registry?(%{type: :registry}), do: true
  def registry?(_), do: false

  @doc """
  Format a spec back to a string like `name@range`.
  """
  @spec to_string(t()) :: String.t()
  def to_string(%{name: name, range: nil}), do: name
  def to_string(%{name: name, range: range}), do: "#{name}@#{range}"
end
