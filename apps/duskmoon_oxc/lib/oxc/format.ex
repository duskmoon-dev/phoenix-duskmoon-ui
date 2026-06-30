defmodule OXC.Format do
  @moduledoc """
  Format JavaScript/TypeScript source code with oxfmt.

  Prettier-compatible formatter built on OXC, ~30× faster than Prettier.
  Supports JS, JSX, TS, and TSX.

  ## Examples

      {:ok, formatted} = OXC.Format.run("const x=1;let   y =  2;", "test.js")
      # "const x = 1;\nlet y = 2;\n"

      {:ok, formatted} = OXC.Format.run("const x=1", "test.js", semi: false)
      # "const x = 1\n"
  """

  @type sort_imports_opts :: %{
          optional(:ignore_case) => boolean(),
          optional(:sort_side_effects) => boolean(),
          optional(:order) => :asc | :desc,
          optional(:newlines_between) => boolean(),
          optional(:partition_by_newline) => boolean(),
          optional(:partition_by_comment) => boolean(),
          optional(:internal_pattern) => [String.t()]
        }

  @type sort_tailwindcss_opts :: %{
          optional(:config) => String.t(),
          optional(:stylesheet) => String.t(),
          optional(:functions) => [String.t()],
          optional(:attributes) => [String.t()],
          optional(:preserve_whitespace) => boolean(),
          optional(:preserve_duplicates) => boolean()
        }

  @type option ::
          {:print_width, pos_integer()}
          | {:tab_width, pos_integer()}
          | {:use_tabs, boolean()}
          | {:semi, boolean()}
          | {:single_quote, boolean()}
          | {:jsx_single_quote, boolean()}
          | {:trailing_comma, :all | :none}
          | {:bracket_spacing, boolean()}
          | {:bracket_same_line, boolean()}
          | {:arrow_parens, :always | :avoid}
          | {:end_of_line, :lf | :crlf | :cr}
          | {:quote_props, :as_needed | :consistent | :preserve}
          | {:single_attribute_per_line, boolean()}
          | {:object_wrap, :preserve | :collapse}
          | {:experimental_operator_position, :start | :end}
          | {:experimental_ternaries, boolean()}
          | {:embedded_language_formatting, :auto | :off}
          | {:sort_imports, boolean() | sort_imports_opts()}
          | {:sort_tailwindcss, boolean() | sort_tailwindcss_opts()}

  @doc """
  Format source code.

  ## Options

    * `:print_width` — line width (default: 80)
    * `:tab_width` — spaces per indentation level (default: 2)
    * `:use_tabs` — indent with tabs instead of spaces (default: false)
    * `:semi` — print semicolons (default: true)
    * `:single_quote` — use single quotes (default: false)
    * `:jsx_single_quote` — use single quotes in JSX (default: false)
    * `:trailing_comma` — `:all` or `:none` (default: `:all`)
    * `:bracket_spacing` — spaces inside object braces (default: true)
    * `:bracket_same_line` — put `>` on the same line (default: false)
    * `:arrow_parens` — `:always` or `:avoid` (default: `:always`)
    * `:end_of_line` — `:lf`, `:crlf`, or `:cr` (default: `:lf`)
    * `:quote_props` — `:as_needed`, `:consistent`, or `:preserve` (default: `:as_needed`)
    * `:single_attribute_per_line` — force one attribute per line in JSX (default: false)
    * `:object_wrap` — `:preserve` or `:collapse` (default: `:preserve`)
    * `:experimental_operator_position` — `:start` or `:end` (default: `:end`)
    * `:experimental_ternaries` — use curious ternaries (default: false)
    * `:embedded_language_formatting` — `:auto` or `:off` (default: `:auto`)
    * `:sort_imports` — `true` for defaults, or a map with sub-options:
      * `:ignore_case` — case-insensitive sorting (default: true)
      * `:sort_side_effects` — sort side-effect imports (default: false)
      * `:order` — `:asc` or `:desc` (default: `:asc`)
      * `:newlines_between` — blank lines between groups (default: true)
      * `:partition_by_newline` — partition by existing newlines (default: false)
      * `:partition_by_comment` — partition by comments (default: false)
      * `:internal_pattern` — prefixes for internal imports (default: `["~/", "@/"]`)
    * `:sort_tailwindcss` — `true` for defaults, or a map with sub-options:
      * `:config` — path to Tailwind v3 config
      * `:stylesheet` — path to Tailwind v4 stylesheet
      * `:functions` — custom function names containing classes
      * `:attributes` — additional attributes to sort
      * `:preserve_whitespace` — preserve whitespace around classes (default: false)
      * `:preserve_duplicates` — preserve duplicate classes (default: false)

  ## Examples

      iex> {:ok, code} = OXC.Format.run("const   x=1", "test.js")
      iex> code
      "const x = 1;\\n"

      iex> {:ok, code} = OXC.Format.run("const x=1", "test.js", semi: false)
      iex> code
      "const x = 1\\n"

      iex> {:ok, code} = OXC.Format.run("const x = {a: 1, b: 2}", "test.js", print_width: 20)
      iex> String.contains?(code, "\\n")
      true
  """
  @spec run(iodata(), String.t(), [option()]) ::
          {:ok, String.t()} | {:error, [String.t()]}
  def run(source, filename, opts \\ []) do
    opts_map =
      opts
      |> Map.new()
      |> Map.new(fn
        {k, v}
        when is_atom(v) and
               k in [
                 :trailing_comma,
                 :arrow_parens,
                 :end_of_line,
                 :object_wrap,
                 :experimental_operator_position,
                 :embedded_language_formatting
               ] ->
          {k, to_string(v)}

        {:quote_props, v} ->
          {:quote_props, String.replace(to_string(v), "_", "-")}

        {:sort_imports, %{} = m} ->
          {:sort_imports,
           Map.new(m, fn
             {:order, v} -> {:order, to_string(v)}
             pair -> pair
           end)}

        {:sort_tailwindcss, %{} = m} ->
          {:sort_tailwindcss, m}

        {k, v} ->
          {k, v}
      end)

    OXC.Format.Native.format(source, filename, opts_map)
  end

  @doc """
  Like `run/3` but raises on errors.

  ## Examples

      iex> OXC.Format.run!("const   x=1", "test.js")
      "const x = 1;\\n"
  """
  @spec run!(iodata(), String.t(), [option()]) :: String.t()
  def run!(source, filename, opts \\ []) do
    case run(source, filename, opts) do
      {:ok, code} ->
        code

      {:error, errors} ->
        raise OXC.Error, message: "OXC format error: #{inspect(errors)}", errors: errors
    end
  end
end
