defmodule NPM.Resolution.PackageResolver do
  alias NPM.Resolution.Exports

  @moduledoc """
  Resolve bare and relative import specifiers to files on disk.

  Implements the Node.js module resolution algorithm for use by
  bundlers, TypeScript tooling, and anything that needs to turn
  an import specifier into an absolute file path.

  This is the **npm domain** half of resolution — specifier parsing,
  `node_modules` traversal, `package.json` entry points, and file
  extension probing. AST rewriting stays in the consumer (e.g. OXC).

  ## Examples

      iex> NPM.Resolution.PackageResolver.split_specifier("@babel/core/lib/parse")
      {"@babel/core", "./lib/parse"}

      iex> NPM.Resolution.PackageResolver.relative?("./utils")
      true

      iex> NPM.Resolution.PackageResolver.node_builtin?("node:fs")
      true

      iex> NPM.Resolution.PackageResolver.find_node_modules("/app/src")
      "/app/node_modules"
  """

  @node_builtins ~w(
    assert async_hooks buffer child_process cluster console constants
    crypto dgram diagnostics_channel dns domain events fs http http2
    https inspector module net os path perf_hooks process punycode
    querystring readline repl stream string_decoder sys timers tls
    trace_events tty url util v8 vm wasi worker_threads zlib
  )

  @default_extensions [".js", ".mjs", ".cjs", ".json"]

  # ---------------------------------------------------------------------------
  # Specifier classification
  # ---------------------------------------------------------------------------

  @doc """
  Returns `true` for relative specifiers (`./`, `../`, or `/`).
  """
  @spec relative?(String.t()) :: boolean()
  def relative?("." <> _), do: true
  def relative?("/" <> _), do: true
  def relative?(_), do: false

  @doc """
  Returns `true` for bare (package) specifiers — anything that is
  neither relative nor a Node.js built-in.
  """
  @spec bare?(String.t()) :: boolean()
  def bare?(specifier), do: not relative?(specifier) and not node_builtin?(specifier)

  @doc """
  Returns `true` for Node.js built-in modules (`fs`, `node:path`, etc.).
  """
  @spec node_builtin?(String.t()) :: boolean()
  def node_builtin?("node:" <> _), do: true
  def node_builtin?(name), do: name in @node_builtins

  # ---------------------------------------------------------------------------
  # Specifier splitting
  # ---------------------------------------------------------------------------

  @doc """
  Split a bare specifier into `{package_name, subpath | nil}`.

  Handles scoped packages correctly:

      "lodash"                → {"lodash", nil}
      "lodash/fp"             → {"lodash", "./fp"}
      "@babel/core"           → {"@babel/core", nil}
      "@babel/core/lib/parse" → {"@babel/core", "./lib/parse"}
  """
  @spec split_specifier(String.t()) :: {String.t(), String.t() | nil}
  def split_specifier("@" <> _ = specifier) do
    case String.split(specifier, "/", parts: 3) do
      [scope, name, subpath] -> {"#{scope}/#{name}", "./#{subpath}"}
      [scope, name] -> {"#{scope}/#{name}", nil}
      _ -> {specifier, nil}
    end
  end

  def split_specifier(specifier) do
    case String.split(specifier, "/", parts: 2) do
      [name, subpath] -> {name, "./#{subpath}"}
      [name] -> {name, nil}
    end
  end

  # ---------------------------------------------------------------------------
  # node_modules traversal
  # ---------------------------------------------------------------------------

  @doc """
  Walk up from `dir` to find the nearest `node_modules` directory.

  Returns the absolute path or `nil` if none is found before the
  filesystem root.
  """
  @spec find_node_modules(String.t()) :: String.t() | nil
  def find_node_modules(dir) do
    dir = Path.expand(dir)
    candidate = Path.join(dir, "node_modules")

    cond do
      File.dir?(candidate) -> candidate
      dir == "/" -> nil
      true -> find_node_modules(Path.dirname(dir))
    end
  end

  # ---------------------------------------------------------------------------
  # File resolution (extension probing)
  # ---------------------------------------------------------------------------

  @doc """
  Resolve a file path by probing extensions and `index.*` files.

  Given a base path (without extension), tries each extension in order,
  then tries `base/index.*` for directory imports.

  ## Options

    * `:extensions` — list of extensions to probe (default: `#{inspect(@default_extensions)}`)
  """
  @spec try_resolve(String.t(), keyword()) :: {:ok, String.t()} | :error
  def try_resolve(base, opts \\ []) do
    extensions = Keyword.get(opts, :extensions, @default_extensions)

    with :error <- try_exact(base),
         :error <- try_extensions(base, extensions) do
      try_index(base, extensions)
    end
  end

  # ---------------------------------------------------------------------------
  # Package entry point resolution
  # ---------------------------------------------------------------------------

  @doc """
  Resolve the entry point of a package directory.

  Reads `package.json` and checks (in order):

    1. `exports` field (via `Exports`) with the given subpath and conditions
    2. `browser` field (when `"browser"` is in conditions and value is a string)
    3. `module` field
    4. `main` field
    5. `./index.js` fallback

  ## Options

    * `:subpath` — export subpath to resolve (default: `"."`)
    * `:conditions` — condition names for the `exports` field
      (default: `["import", "default"]`)
    * `:extensions` — extensions for file probing (default: `#{inspect(@default_extensions)}`)
  """
  @spec resolve_entry(String.t(), keyword()) :: {:ok, String.t()} | :error
  def resolve_entry(package_dir, opts \\ []) do
    subpath = Keyword.get(opts, :subpath, ".")
    conditions = Keyword.get(opts, :conditions, ["import", "default"])
    extensions = Keyword.get(opts, :extensions, @default_extensions)

    pkg_json_path = Path.join(package_dir, "package.json")

    case read_package_json(pkg_json_path) do
      {:ok, pkg} -> resolve_from_pkg(pkg, package_dir, subpath, conditions, extensions)
      :error -> try_resolve(Path.join(package_dir, "index"), extensions: extensions)
    end
  end

  @doc """
  Resolve a full import specifier to an absolute file path.

  Handles bare, relative, and built-in specifiers:

    * **Relative** (`./foo`) — resolved against `from_dir` with extension probing
    * **Package imports** (`#internal`) — resolved from the nearest package.json `imports` map
    * **Built-in** (`node:fs`) — returns `{:builtin, name}`
    * **Bare** (`lodash/fp`) — locates `node_modules`, then resolves the entry point

  ## Options

    * `:conditions` — condition names for the `exports` field
    * `:extensions` — extensions for file probing
  """
  @spec resolve(String.t(), String.t(), keyword()) ::
          {:ok, String.t()} | {:builtin, String.t()} | :error
  def resolve(specifier, from_dir, opts \\ []) do
    cond do
      node_builtin?(specifier) ->
        {:builtin, specifier}

      String.starts_with?(specifier, "#") ->
        resolve_package_import(specifier, from_dir, opts)

      relative?(specifier) ->
        base = Path.expand(specifier, from_dir)
        try_resolve(base, opts)

      true ->
        resolve_bare(specifier, from_dir, opts)
    end
  end

  # ---------------------------------------------------------------------------
  # Relative import paths
  # ---------------------------------------------------------------------------

  @doc """
  Compute a relative import path from `importer` to `target` within `project_root`.

  Both paths must be absolute. Returns a POSIX-style relative path with
  a guaranteed `./` or `../` prefix, suitable for use as an import specifier.

  ## Examples

      iex> NPM.Resolution.PackageResolver.relative_import_path(
      ...>   "/app/src/pages/home.js",
      ...>   "/app/src/utils/format.js",
      ...>   "/app"
      ...> )
      "../utils/format.js"

      iex> NPM.Resolution.PackageResolver.relative_import_path(
      ...>   "/app/src/index.js",
      ...>   "/app/src/app.js",
      ...>   "/app"
      ...> )
      "./app.js"
  """
  @spec relative_import_path(String.t(), String.t(), String.t()) :: String.t()
  def relative_import_path(importer, target, project_root) do
    importer_dir = importer |> Path.relative_to(project_root) |> Path.dirname()
    target_label = Path.relative_to(target, project_root)
    relative = Path.relative_to(target_label, importer_dir)
    ensure_relative_prefix(relative)
  end

  defp ensure_relative_prefix("./" <> _ = path), do: path
  defp ensure_relative_prefix("../" <> _ = path), do: path
  defp ensure_relative_prefix(path), do: "./" <> path

  # ---------------------------------------------------------------------------
  # Private
  # ---------------------------------------------------------------------------

  @doc "Find the nearest package root from `dir` by walking up to package.json."
  @spec nearest_package(String.t()) :: {:ok, String.t(), map()} | :error
  def nearest_package(dir) do
    dir = Path.expand(dir)
    package_json_path = Path.join(dir, "package.json")

    cond do
      File.regular?(package_json_path) ->
        with {:ok, package} <- read_package_json(package_json_path), do: {:ok, dir, package}

      dir == "/" or Path.basename(dir) == "node_modules" ->
        :error

      true ->
        nearest_package(Path.dirname(dir))
    end
  end

  @doc "Find an installed package root visible from `from_dir`."
  @spec package_root(String.t(), String.t()) :: {:ok, String.t()} | :error
  def package_root(package_name, from_dir) do
    case find_node_modules(from_dir) do
      nil ->
        :error

      node_modules ->
        package_dir = Path.join(node_modules, package_name)
        if File.dir?(package_dir), do: {:ok, package_dir}, else: :error
    end
  end

  defp resolve_package_import(specifier, from_dir, opts) do
    conditions = Keyword.get(opts, :conditions, ["import", "default"])
    extensions = Keyword.get(opts, :extensions, @default_extensions)

    with {:ok, package_dir, %{"imports" => imports}} <- nearest_package(from_dir),
         {:ok, target} <- Exports.resolve(imports, specifier, conditions) do
      package_dir
      |> expand_target(target)
      |> try_resolve(extensions: extensions)
    else
      _ -> :error
    end
  end

  defp resolve_bare(specifier, from_dir, opts) do
    {package_name, subpath} = split_specifier(specifier)

    with {:ok, package_dir} <- package_root(package_name, from_dir) do
      entry_opts =
        opts
        |> Keyword.put(:subpath, subpath || ".")

      resolve_entry(package_dir, entry_opts)
    end
  end

  defp resolve_from_pkg(pkg, package_dir, subpath, conditions, extensions) do
    with :error <- resolve_via_exports(pkg, package_dir, subpath, conditions) do
      resolve_without_exports(pkg, package_dir, subpath, conditions, extensions)
    end
  end

  defp resolve_without_exports(pkg, package_dir, ".", conditions, extensions) do
    with :error <- resolve_via_fields(pkg, package_dir, conditions, extensions) do
      try_resolve(Path.join(package_dir, "index"), extensions: extensions)
    end
  end

  defp resolve_without_exports(_pkg, package_dir, subpath, _conditions, extensions) do
    package_dir
    |> expand_target(subpath)
    |> try_resolve(extensions: extensions)
  end

  defp resolve_via_exports(pkg, package_dir, subpath, conditions) do
    case Exports.parse(pkg) do
      nil ->
        :error

      export_map ->
        case Exports.resolve(export_map, subpath, conditions) do
          {:ok, target} -> ensure_file(package_dir, target)
          :error -> :error
        end
    end
  end

  defp resolve_via_fields(pkg, package_dir, conditions, extensions) do
    conditions
    |> fields_for_conditions()
    |> Enum.find_value(:error, fn field ->
      case Map.get(pkg, field) do
        nil -> nil
        target when is_binary(target) -> resolve_field_target(package_dir, target, extensions)
        _ -> nil
      end
    end)
  end

  defp fields_for_conditions(conditions) do
    browser_fields = if "browser" in conditions, do: ["browser"], else: []

    (browser_fields ++ Enum.flat_map(conditions, &fields_for_condition/1) ++ ["module", "main"])
    |> Enum.uniq()
  end

  defp fields_for_condition("import"), do: ["module"]
  defp fields_for_condition("require"), do: ["main"]
  defp fields_for_condition("default"), do: ["main"]
  defp fields_for_condition(_), do: []

  defp resolve_field_target(package_dir, target, extensions) do
    if unsupported_field_extension?(target, extensions) do
      nil
    else
      full = expand_target(package_dir, target)

      case try_resolve(full, extensions: extensions) do
        {:ok, _} = ok -> ok
        :error -> nil
      end
    end
  end

  defp unsupported_field_extension?(target, extensions) do
    ext = Path.extname(target)
    ext != "" and ext not in extensions
  end

  defp ensure_file(package_dir, target) do
    package_dir
    |> expand_target(target)
    |> try_resolve(extensions: [""])
  end

  defp expand_target(package_dir, "./" <> rest), do: Path.join(package_dir, rest)
  defp expand_target(package_dir, target), do: Path.join(package_dir, target)

  defp try_exact(path) do
    if File.regular?(path), do: {:ok, path}, else: :error
  end

  defp try_extensions(base, extensions) do
    Enum.find_value(extensions, :error, fn ext ->
      path = base <> ext
      if File.regular?(path), do: {:ok, path}
    end)
  end

  defp try_index(base, extensions) do
    if File.dir?(base) do
      try_extensions(Path.join(base, "index"), extensions)
    else
      :error
    end
  end

  defp read_package_json(path) do
    case File.read(path) do
      {:ok, content} -> {:ok, NPM.JSON.decode!(content)}
      {:error, _} -> :error
    end
  end
end
