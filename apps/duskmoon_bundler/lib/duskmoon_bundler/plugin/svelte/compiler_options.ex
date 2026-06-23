defmodule DuskmoonBundler.Plugin.Svelte.CompilerOptions do
  @moduledoc "Svelte compiler options encoded for the JavaScript runtime."

  defstruct filename: nil,
            generate: "client",
            dev: false,
            css: "external",
            plugin_options: %{},
            build_options: %{}

  def new(path, opts, plugin_opts) do
    %__MODULE__{
      filename: path,
      generate: compile_target(opts, plugin_opts),
      dev: option(opts, plugin_opts, :dev, false),
      css: option(opts, plugin_opts, :css, "external"),
      plugin_options: Keyword.get(plugin_opts, :compiler_options, %{}),
      build_options: Keyword.get(opts, :svelte_options, %{})
    }
  end

  defp compile_target(opts, plugin_opts) do
    case option(
           opts,
           plugin_opts,
           :svelte_generate,
           option(opts, plugin_opts, :generate, :client)
         ) do
      :client -> "client"
      :server -> "server"
      value when is_binary(value) -> value
    end
  end

  defp option(opts, plugin_opts, key, default) do
    Keyword.get(opts, key, Keyword.get(plugin_opts, key, default))
  end
end

defimpl Jason.Encoder, for: DuskmoonBundler.Plugin.Svelte.CompilerOptions do
  def encode(options, opts) do
    options
    |> json_fields()
    |> Jason.Encode.map(opts)
  end

  defp json_fields(options) do
    %{
      "filename" => options.filename,
      "generate" => options.generate,
      "dev" => options.dev,
      "css" => options.css
    }
    |> Map.merge(DuskmoonBundler.Plugin.Helpers.stringify_keys(options.plugin_options))
    |> Map.merge(DuskmoonBundler.Plugin.Helpers.stringify_keys(options.build_options))
  end
end
