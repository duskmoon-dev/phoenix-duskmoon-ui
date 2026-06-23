defmodule DuskmoonBundler.Plugin.Solid.CompilerOptions do
  @moduledoc "Solid compiler options encoded for the JavaScript runtime."

  alias DuskmoonBundler.Plugin.Solid.CompilerOptions.SolidOptions

  defstruct filename: nil,
            typescript: false,
            sourcemap: true,
            solid_options: %SolidOptions{},
            plugin_solid_options: %{},
            build_solid_options: %{},
            typescript_options: %{}

  def new(filename, opts, plugin_opts) do
    %__MODULE__{
      filename: filename,
      typescript: Path.extname(filename) in ~w(.ts .tsx .mts),
      sourcemap: Keyword.get(opts, :sourcemap, true),
      solid_options: SolidOptions.new(opts, plugin_opts),
      plugin_solid_options: Keyword.get(plugin_opts, :solid_options, %{}),
      build_solid_options: Keyword.get(opts, :solid_options, %{}),
      typescript_options: Keyword.get(plugin_opts, :typescript_options, %{})
    }
  end
end

defimpl Jason.Encoder, for: DuskmoonBundler.Plugin.Solid.CompilerOptions do
  def encode(options, opts) do
    options
    |> json_fields()
    |> Jason.Encode.map(opts)
  end

  defp json_fields(options) do
    fields = %{
      "filename" => options.filename,
      "typescript" => options.typescript,
      "sourcemap" => options.sourcemap,
      "solidOptions" => solid_options(options)
    }

    case DuskmoonBundler.Plugin.Helpers.stringify_keys(options.typescript_options) do
      map when map_size(map) == 0 -> fields
      map -> Map.put(fields, "typescriptOptions", map)
    end
  end

  defp solid_options(options) do
    options.solid_options
    |> DuskmoonBundler.Plugin.Solid.CompilerOptions.SolidOptions.json_fields()
    |> Map.merge(DuskmoonBundler.Plugin.Helpers.stringify_keys(options.plugin_solid_options))
    |> Map.merge(DuskmoonBundler.Plugin.Helpers.stringify_keys(options.build_solid_options))
  end
end
