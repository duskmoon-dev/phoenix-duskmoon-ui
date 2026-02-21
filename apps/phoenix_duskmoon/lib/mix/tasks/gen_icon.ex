defmodule Mix.Tasks.PhoenixDuskmoon.GenIcons do
  # Generate Material Design Icons
  # try to define with macro, it's too slow

  @moduledoc """
  Generate PhoenixDuskmoon.MaterialDesignIcons from 7000+ svg files
  """
  use Mix.Task

  @shortdoc "Generate PhoenixDuskmoon.MaterialDesignIcons.ex file"
  @impl Mix.Task
  def run(_) do
    Mix.Task.run("app.start")

    icons =
      File.ls!(Application.app_dir(:phoenix_duskmoon, "priv/mdi/svg"))
      |> Enum.filter(&String.ends_with?(&1, ".svg"))
      |> Enum.map(&String.trim(&1, ".svg"))

    quoted = EEx.compile_file("#{__DIR__}/material_design_icons.eex")
    {result, _bindings} = Code.eval_quoted(quoted, icons: icons)

    fl = Path.expand("../../phoenix_duskmoon/material_design_icons.ex", __DIR__)

    File.write!(fl, result)
  end
end
