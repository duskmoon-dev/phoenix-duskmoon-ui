defmodule DuskmoonBundler.Formatter do
  @moduledoc """
  A `mix format` plugin that formats JavaScript and TypeScript files with oxfmt.

  ## Setup

  Add `DuskmoonBundler.Formatter` to your `.formatter.exs`. For an existing
  project, keep the current Elixir inputs and opt in only adopted JS/TS files:

      [
        plugins: [DuskmoonBundler.Formatter],
        inputs: [
          "{mix,.formatter}.exs",
          "{config,lib,test}/**/*.{ex,exs}",
          "assets/js/hooks/new_hook.js"
        ]
      ]

  ## Configuration

  Reads options from `config :duskmoon_bundler, :format` or falls back to
  `.oxfmtrc.json`, `.oxfmtrc`, `.prettierrc.json`, or `.prettierrc` JSON files.
  Defaults include two-space indentation, an 80-column print width,
  semicolons, double quotes, and trailing commas. Match the existing project's
  style with these options before adopting files.

  ## Incremental adoption

  Asset builds do not require enabling this plugin. Migrate the build first,
  then format and review selected files in a separate change. Expand `inputs`
  as files are adopted; a broad `assets/**/*.{js,ts,jsx,tsx}` input opts in every
  matching file. `mix format --check-formatted` checks the selected files
  without rewriting them.

  Formatting normalizes each selected file in full; it does not preserve all
  existing whitespace or format only changed lines. An explicit filename
  passed to `mix format` is formatted even if it is outside `inputs`.
  The bundler's `sources` and `ignore` configuration does not restrict this
  plugin; those options control the standalone JS tasks instead.

  See the [Formatting and Linting guide](formatting-and-linting.html) for
  configuration examples and a step-by-step migration.
  """

  @behaviour Mix.Tasks.Format

  @impl true
  def features(_opts) do
    [extensions: DuskmoonBundler.JS.Extensions.formattable()]
  end

  @impl true
  def format(contents, opts) do
    filename = opts[:file] || extension_to_filename(opts[:extension]) || "input.ts"
    format_opts = DuskmoonBundler.JS.Format.load_config()

    OXC.Format.run!(contents, filename, format_opts)
  end

  defp extension_to_filename(nil), do: nil
  defp extension_to_filename(ext), do: "input#{ext}"
end
