defmodule OXC.Lint do
  @moduledoc """
  Lint JavaScript/TypeScript source with oxlint's built-in rules
  and optional custom Elixir rules.

  Combines native Rust performance for 650+ standard rules with
  the ability to write project-specific rules in Elixir using
  the same AST that `OXC.parse/2` returns.

  ## Examples

      {:ok, diags} = OXC.Lint.run("debugger;", "test.js",
        rules: %{"no-debugger" => :deny})

      {:ok, []} = OXC.Lint.run("export const x = 1;\\n", "test.ts")
  """

  @type severity :: :allow | :warn | :deny
  @type diagnostic :: %{
          rule: String.t(),
          message: String.t(),
          severity: severity(),
          span: {non_neg_integer(), non_neg_integer()},
          labels: [{non_neg_integer(), non_neg_integer()}],
          help: String.t() | nil
        }

  @doc """
  Lint source code with oxlint's built-in rules and optional custom rules.

  Pass a list of files with `type_aware: true` to run TypeScript type-aware
  rules through `tsgolint` headless mode:

      OXC.Lint.run(["lib/app.ts"],
        type_aware: true,
        tsgolint: "tsgolint",
        rules: %{"typescript/no-floating-promises" => :deny})

  ## Options

    * `:rules` — map of rule names to severity (`:deny`, `:warn`, `:allow`).
      Rule names follow oxlint conventions: `"eqeqeq"`, `"react/no-danger"`,
      `"typescript/no-explicit-any"`, etc.

    * `:plugins` — list of built-in plugin atoms to enable.
      Default: oxlint defaults (eslint correctness rules).
      Available: `:react`, `:typescript`, `:unicorn`, `:import`, `:jsdoc`,
      `:jest`, `:vitest`, `:jsx_a11y`, `:nextjs`, `:react_perf`, `:promise`,
      `:node`, `:vue`, `:oxc`

    * `:fix` — compute fix suggestions. Default: `false`

    * `:custom_rules` — list of `{module, severity}` tuples for Elixir rules.
      Each module must implement the `OXC.Lint.Rule` behaviour.

    * `:settings` — arbitrary map passed to custom rule context.

  ## Examples

      # Built-in rules only
      {:ok, diags} = OXC.Lint.run("debugger;", "test.js",
        rules: %{"no-debugger" => :deny})

      # With specific plugins and rules
      {:ok, diags} = OXC.Lint.run(source, "app.tsx",
        plugins: [:react, :typescript],
        rules: %{"no-console" => :warn, "react/no-danger" => :deny}
      )

      # With custom Elixir rules
      {:ok, diags} = OXC.Lint.run(source, "app.ts",
        custom_rules: [{MyApp.NoConsoleLog, :warn}]
      )
  """
  @spec run([String.t()], keyword()) :: {:ok, [diagnostic()]} | {:error, [String.t()]}
  @spec run(iodata(), String.t(), keyword()) :: {:ok, [diagnostic()]} | {:error, [String.t()]}
  def run(files, opts) when is_list(files) and is_list(opts) do
    if Keyword.get(opts, :type_aware, false) do
      OXC.Lint.TypeAware.run(files, opts)
    else
      {:error, ["OXC.Lint.run/2 with a file list requires type_aware: true"]}
    end
  end

  def run(source, filename, opts \\ []) do
    source = IO.iodata_to_binary(source)
    plugins = opts |> Keyword.get(:plugins, []) |> Enum.map(&to_string/1)
    fix = Keyword.get(opts, :fix, false)

    rules =
      opts
      |> Keyword.get(:rules, %{})
      |> Enum.map(fn {name, severity} -> {to_string(name), severity_to_string(severity)} end)

    custom_rules = Keyword.get(opts, :custom_rules, [])
    settings = Keyword.get(opts, :settings, %{})

    case OXC.Lint.Native.lint(source, filename, plugins, rules, fix) do
      {:ok, builtin_diags} ->
        custom =
          case custom_rules do
            [] -> []
            rules -> run_custom_rules(rules, source, filename, settings)
          end

        {:ok, builtin_diags ++ custom}

      {:error, errors} ->
        {:error, errors}
    end
  end

  @doc """
  Like `run/3` but raises on errors.
  """
  @spec run!(iodata(), String.t(), keyword()) :: [diagnostic()]
  def run!(source, filename, opts \\ []) do
    case run(source, filename, opts) do
      {:ok, diags} ->
        diags

      {:error, errors} ->
        raise OXC.Error, message: "OXC lint error: #{inspect(errors)}", errors: errors
    end
  end

  defp severity_to_string(:deny), do: "deny"
  defp severity_to_string(:warn), do: "warn"
  defp severity_to_string(:allow), do: "allow"

  defp run_custom_rules(rules, source, filename, settings) do
    case OXC.parse(source, filename) do
      {:ok, ast} ->
        context = %{source: source, filename: filename, settings: settings}

        Enum.flat_map(rules, fn {module, severity} ->
          meta = module.meta()

          module.run(ast, context)
          |> Enum.map(fn diag ->
            %{
              rule: meta.name,
              message: diag.message,
              severity: severity,
              span: Map.get(diag, :span, {0, 0}),
              labels: Map.get(diag, :labels, []),
              help: Map.get(diag, :help)
            }
          end)
        end)

      {:error, _} ->
        []
    end
  end
end
