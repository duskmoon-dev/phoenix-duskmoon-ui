defmodule DuskmoonBundler.Plugin.Solid.CompilerOptions.SolidOptions do
  @moduledoc "Nested Solid preset options passed to Babel."

  defstruct generate: "dom", hydratable: false, dev: false

  def new(opts, plugin_opts) do
    %__MODULE__{
      generate: option(opts, plugin_opts, :generate, "dom"),
      hydratable: option(opts, plugin_opts, :hydratable, false),
      dev: option(opts, plugin_opts, :dev, false)
    }
  end

  def json_fields(%__MODULE__{} = options) do
    %{
      "generate" => options.generate,
      "hydratable" => options.hydratable,
      "dev" => options.dev
    }
  end

  defp option(opts, plugin_opts, key, default) do
    Keyword.get(opts, key, Keyword.get(plugin_opts, key, default))
  end
end

defimpl Jason.Encoder, for: DuskmoonBundler.Plugin.Solid.CompilerOptions.SolidOptions do
  def encode(options, opts) do
    options
    |> DuskmoonBundler.Plugin.Solid.CompilerOptions.SolidOptions.json_fields()
    |> Jason.Encode.map(opts)
  end
end
