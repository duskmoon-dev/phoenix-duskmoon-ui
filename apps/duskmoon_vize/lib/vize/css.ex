defmodule Vize.CSS do
  @moduledoc """
  CSS parsing, printing, and AST traversal helpers.

  The AST is produced by LightningCSS and represented as Elixir maps, lists,
  strings, numbers, booleans, and `nil`. Use `parse_ast/2` to parse CSS,
  transform the returned AST with `prewalk/2` or `postwalk/2`, and then use
  `print_ast/2` to serialize it back to CSS.
  """

  @type css_result :: %{
          optional(:exports) => %{optional(String.t()) => String.t()} | nil,
          code: String.t(),
          css_vars: [String.t()],
          errors: [String.t()],
          warnings: [String.t()]
        }

  @type ast :: map() | list() | String.t() | number() | boolean() | nil

  @type ast_result :: %{
          ast: map() | nil,
          errors: [String.t()],
          warnings: [String.t()]
        }

  @type url_ref :: Vize.CSS.URL.t()

  @doc """
  Compile CSS using LightningCSS.

  Parses, autoprefixes, and optionally minifies CSS. Also handles Vue scoped CSS
  transformation, `v-bind()` extraction, and CSS Modules.

  ## Options

    * `:minify` — minify the output (default: `false`)
    * `:scoped` — apply Vue scoped CSS transformation (default: `false`)
    * `:scope_id` — scope ID for scoped CSS (e.g. `"data-v-abc123"`)
    * `:filename` — filename for error reporting
    * `:css_modules` — enable CSS Modules scoping (default: `false`)
    * `:targets` — browser targets for autoprefixing, map with optional
      `:chrome`, `:firefox`, `:safari` keys as major version integers

  ## Examples

      iex> {:ok, result} = Vize.CSS.compile(".foo { color: red }")
      iex> result.code =~ "color"
      true
      iex> result.errors
      []
  """
  @spec compile(String.t(), keyword()) :: {:ok, css_result()}
  def compile(source, opts \\ []) do
    minify = Keyword.get(opts, :minify, false)
    scoped = Keyword.get(opts, :scoped, false)
    scope_id = Keyword.get(opts, :scope_id, "")
    filename = Keyword.get(opts, :filename, "")
    css_modules = Keyword.get(opts, :css_modules, false)
    targets = Keyword.get(opts, :targets, %{})
    chrome = Map.get(targets, :chrome, -1)
    firefox = Map.get(targets, :firefox, -1)
    safari = Map.get(targets, :safari, -1)

    Vize.Native.compile_css_nif(
      source,
      minify,
      scoped,
      scope_id,
      filename,
      chrome,
      firefox,
      safari,
      css_modules
    )
  end

  @doc "Like `compile/2` but raises on errors."
  @spec compile!(String.t(), keyword()) :: css_result()
  def compile!(source, opts \\ []) do
    case compile(source, opts) do
      {:ok, result} ->
        if result.errors != [] do
          raise "Vize CSS compile error: #{inspect(result.errors)}"
        end

        result
    end
  end

  @doc """
  Bundle a CSS file and all its `@import` dependencies into a single stylesheet.

  Reads the entry file and all imported files from disk, resolving `@import`
  rules recursively. The result is a single merged stylesheet with all imports
  inlined, wrapped in the appropriate `@media`, `@supports`, and `@layer` rules.

  ## Options

    * `:minify` — minify the output (default: `false`)
    * `:css_modules` — enable CSS Modules scoping (default: `false`)
    * `:targets` — browser targets for autoprefixing
  """
  @spec bundle(String.t(), keyword()) :: {:ok, css_result()}
  def bundle(entry_path, opts \\ []) do
    minify = Keyword.get(opts, :minify, false)
    css_modules = Keyword.get(opts, :css_modules, false)
    targets = Keyword.get(opts, :targets, %{})
    chrome = Map.get(targets, :chrome, -1)
    firefox = Map.get(targets, :firefox, -1)
    safari = Map.get(targets, :safari, -1)

    Vize.Native.bundle_css_nif(
      Path.expand(entry_path),
      minify,
      chrome,
      firefox,
      safari,
      css_modules
    )
  end

  @doc "Like `bundle/2` but raises on errors."
  @spec bundle!(String.t(), keyword()) :: css_result()
  def bundle!(entry_path, opts \\ []) do
    case bundle(entry_path, opts) do
      {:ok, result} ->
        if result.errors != [] do
          raise "Vize CSS bundle error: #{inspect(result.errors)}"
        end

        result
    end
  end

  @doc """
  Select compact parser events from CSS source by name.

  Available selectors:

    * `:urls` — `url()` references with source byte ranges and source locations

  ## Options

    * `:filename` — filename for parser locations and error reporting
    * `:css_modules` — enable CSS Modules parsing (default: `false`)
    * `:custom_media` — enable custom media parsing (default: `false`)
  """
  @spec select(String.t(), atom(), keyword()) :: {:ok, [map()]} | {:error, Vize.Error.t()}
  def select(source, selector, opts \\ []) when is_atom(selector) do
    filename = Keyword.get(opts, :filename, "")
    css_modules = Keyword.get(opts, :css_modules, false)
    custom_media = Keyword.get(opts, :custom_media, false)

    case Vize.Native.select_css_nif(
           source,
           filename,
           custom_media,
           css_modules,
           selector_spec(selector)
         ) do
      {:ok, events} -> {:ok, events}
      {:error, errors} -> {:error, error("Vize CSS selection error", errors)}
    end
  end

  @doc """
  Collect parser-backed `url()` references from CSS source.

  Returns byte offsets for the URL value inside the original source, suitable for
  source patching without round-tripping through the serialized CSS AST.
  """
  @spec collect_urls(String.t(), keyword()) :: {:ok, [url_ref()]} | {:error, Vize.Error.t()}
  def collect_urls(source, opts \\ []) do
    case select(source, :urls, opts) do
      {:ok, urls} -> {:ok, Enum.map(urls, &Vize.CSS.URL.new/1)}
      {:error, _} = error -> error
    end
  end

  defp selector_spec(:urls) do
    [
      {{:css_url, :"$1", :"$2", :"$3", :"$4", :"$5", :"$6", :"$7"}, [],
       [
         %{
           url: :"$1",
           start: :"$2",
           end: :"$3",
           start_line: :"$4",
           start_column: :"$5",
           end_line: :"$6",
           end_column: :"$7"
         }
       ]}
    ]
  end

  defp selector_spec(selector) do
    raise ArgumentError, "unknown Vize CSS selector #{inspect(selector)}"
  end

  @doc "Like `collect_urls/2` but raises `Vize.Error` on errors."
  @spec collect_urls!(String.t(), keyword()) :: [url_ref()]
  def collect_urls!(source, opts \\ []) do
    case collect_urls(source, opts) do
      {:ok, urls} -> urls
      {:error, error} -> raise error
    end
  end

  @doc """
  Rewrite parser-backed `url()` references in CSS source.

  The callback receives each URL string and returns either `:keep` or
  `{:rewrite, new_url}`. Rewrites are applied to the original source using byte
  ranges reported by the native parser.
  """
  @spec rewrite_urls(String.t(), keyword(), (String.t() -> :keep | {:rewrite, iodata()})) ::
          {:ok, String.t()} | {:error, Vize.Error.t()}
  def rewrite_urls(source, fun) when is_function(fun, 1), do: rewrite_urls(source, [], fun)

  def rewrite_urls(source, opts, fun) when is_function(fun, 1) do
    with {:ok, urls} <- collect_urls(source, opts) do
      patches =
        Enum.reduce(urls, [], fn %Vize.CSS.URL{url: url, range: range}, acc ->
          case fun.(url) do
            {:rewrite, replacement} ->
              [%{start: range.start, end: range.end, change: replacement} | acc]

            :keep ->
              acc
          end
        end)

      {:ok, patch_string(source, patches)}
    end
  end

  @doc "Like `rewrite_urls/3` but raises `Vize.Error` on errors."
  @spec rewrite_urls!(String.t(), keyword(), (String.t() -> :keep | {:rewrite, iodata()})) ::
          String.t()
  def rewrite_urls!(source, fun) when is_function(fun, 1), do: rewrite_urls!(source, [], fun)

  def rewrite_urls!(source, opts, fun) when is_function(fun, 1) do
    case rewrite_urls(source, opts, fun) do
      {:ok, source} -> source
      {:error, error} -> raise error
    end
  end

  @doc """
  Parse CSS into a LightningCSS-backed AST represented as Elixir maps and lists.

  ## Options

    * `:filename` — filename for parser locations and error reporting
    * `:css_modules` — enable CSS Modules parsing (default: `false`)
    * `:custom_media` — enable custom media parsing (default: `false`)

  ## Examples

      iex> {:ok, result} = Vize.CSS.parse_ast(".foo { background: url('./logo.svg') }")
      iex> is_map(result.ast)
      true
      iex> result.errors
      []
  """
  @spec parse_ast(String.t(), keyword()) :: {:ok, ast_result()}
  def parse_ast(source, opts \\ []) do
    filename = Keyword.get(opts, :filename, "")
    css_modules = Keyword.get(opts, :css_modules, false)
    custom_media = Keyword.get(opts, :custom_media, false)

    Vize.Native.parse_css_ast_nif(source, filename, custom_media, css_modules)
  end

  @doc "Like `parse_ast/2` but raises on errors."
  @spec parse_ast!(String.t(), keyword()) :: ast_result()
  def parse_ast!(source, opts \\ []) do
    case parse_ast(source, opts) do
      {:ok, result} ->
        if result.errors != [] do
          raise "Vize CSS parse error: #{inspect(result.errors)}"
        end

        result
    end
  end

  @doc """
  Print CSS from an AST returned by `parse_ast/2`.

  ## Options

    * `:minify` — minify the output (default: `false`)
    * `:targets` — browser targets for autoprefixing, map with optional
      `:chrome`, `:firefox`, `:safari` keys as major version integers

  ## Examples

      iex> {:ok, parsed} = Vize.CSS.parse_ast(".foo { color: red }")
      iex> {:ok, printed} = Vize.CSS.print_ast(parsed.ast)
      iex> printed.code =~ "color"
      true
  """
  @spec print_ast(map(), keyword()) :: {:ok, css_result()}
  def print_ast(ast, opts \\ []) do
    minify = Keyword.get(opts, :minify, false)
    targets = Keyword.get(opts, :targets, %{})
    chrome = Map.get(targets, :chrome, -1)
    firefox = Map.get(targets, :firefox, -1)
    safari = Map.get(targets, :safari, -1)

    Vize.Native.print_css_ast_nif(ast, minify, chrome, firefox, safari)
  end

  @doc "Like `print_ast/2` but raises on errors."
  @spec print_ast!(map(), keyword()) :: css_result()
  def print_ast!(ast, opts \\ []) do
    case print_ast(ast, opts) do
      {:ok, result} ->
        if result.errors != [] do
          raise "Vize CSS print error: #{inspect(result.errors)}"
        end

        result
    end
  end

  @doc """
  Traverse the AST in pre-order and call `fun` for every map node.

  Returns `:ok`. Use `prewalk/2` or `postwalk/2` when you need to transform
  the AST.
  """
  @spec walk(ast(), (map() -> any())) :: :ok
  def walk(value, fun) when is_function(fun, 1) do
    prewalk(value, fn
      node when is_map(node) ->
        fun.(node)
        node

      other ->
        other
    end)

    :ok
  end

  @doc """
  Depth-first pre-order traversal, like `Macro.prewalk/2`.

  The callback receives every map node before its children and must return the
  node to continue traversing.
  """
  @spec prewalk(ast(), (map() -> map())) :: ast()
  def prewalk(value, fun) when is_function(fun, 1) do
    do_prewalk(value, fn node, acc -> {fun.(node), acc} end, nil) |> elem(0)
  end

  @doc """
  Depth-first pre-order traversal with accumulator, like `Macro.prewalk/3`.
  """
  @spec prewalk(ast(), acc, (map(), acc -> {map(), acc})) :: {ast(), acc} when acc: term()
  def prewalk(value, acc, fun) when is_function(fun, 2) do
    do_prewalk(value, fun, acc)
  end

  @doc """
  Depth-first post-order traversal, like `Macro.postwalk/2`.

  The callback receives every map node after its children and must return the
  transformed node.
  """
  @spec postwalk(ast(), (map() -> map())) :: ast()
  def postwalk(value, fun) when is_function(fun, 1) do
    do_postwalk(value, fn node, acc -> {fun.(node), acc} end, nil) |> elem(0)
  end

  @doc """
  Depth-first post-order traversal with accumulator, like `Macro.postwalk/3`.
  """
  @spec postwalk(ast(), acc, (map(), acc -> {map(), acc})) :: {ast(), acc} when acc: term()
  def postwalk(value, acc, fun) when is_function(fun, 2) do
    do_postwalk(value, fun, acc)
  end

  @doc """
  Collect values from map nodes that match `fun`.

  `fun` should return `{:keep, value}` to include a value, or `:skip` to ignore
  the node.
  """
  @spec collect(ast(), (map() -> {:keep, term()} | :skip)) :: [term()]
  def collect(value, fun) when is_function(fun, 1) do
    {_value, collected} =
      postwalk(value, [], fn node, acc ->
        case fun.(node) do
          {:keep, value} -> {node, [value | acc]}
          :skip -> {node, acc}
        end
      end)

    Enum.reverse(collected)
  end

  defp error(message, errors), do: Vize.Error.new(message, errors)

  defp patch_string(source, patches) do
    {chunks, offset} =
      patches
      |> Enum.uniq_by(fn %{start: start, end: end_offset} -> {start, end_offset} end)
      |> Enum.sort_by(fn %{start: start} -> start end)
      |> Enum.reduce({[], 0}, fn %{start: start, end: end_offset, change: replacement},
                                 {chunks, offset} ->
        chunk = binary_part(source, offset, start - offset)
        {[replacement, chunk | chunks], end_offset}
      end)

    tail = binary_part(source, offset, byte_size(source) - offset)
    IO.iodata_to_binary(Enum.reverse([tail | chunks]))
  end

  defp do_prewalk(value, fun, acc) when is_map(value) do
    {value, acc} = fun.(value, acc)

    Enum.reduce(value, {value, acc}, fn {key, child}, {node, acc} ->
      {child, acc} = do_prewalk(child, fun, acc)
      {Map.put(node, key, child), acc}
    end)
  end

  defp do_prewalk(value, fun, acc) when is_list(value) do
    Enum.map_reduce(value, acc, &do_prewalk(&1, fun, &2))
  end

  defp do_prewalk(value, _fun, acc), do: {value, acc}

  defp do_postwalk(value, fun, acc) when is_map(value) do
    {value, acc} =
      Enum.reduce(value, {value, acc}, fn {key, child}, {node, acc} ->
        {child, acc} = do_postwalk(child, fun, acc)
        {Map.put(node, key, child), acc}
      end)

    fun.(value, acc)
  end

  defp do_postwalk(value, fun, acc) when is_list(value) do
    Enum.map_reduce(value, acc, &do_postwalk(&1, fun, &2))
  end

  defp do_postwalk(value, _fun, acc), do: {value, acc}
end
