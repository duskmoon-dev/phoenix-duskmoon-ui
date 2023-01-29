defmodule Mix.Tasks.PhxWc.GenRsIcons do
  # Generate Material Design Icons and Bootstrap Icons to yew components

  @moduledoc """
  Generate mdi.rs or bsi.rs fron svg files.
  """
  use Mix.Task

  @shortdoc "Generate mdi.rs or bsi.rs file"
  def run(["mdi"]) do
    Mix.Task.run("app.start")

    ns = "MD"

    icons =
      File.ls!(Application.app_dir(:phoenix_webcomponent, "priv/mdi/svg"))
      |> Enum.filter(&String.ends_with?(&1, ".svg"))
      |> Enum.map(&String.trim(&1, ".svg"))

    icon_names = icons |> Enum.map(fn(name) ->
      name |> String.split("-") |> Enum.map(&String.capitalize/1) |> Enum.join("")
    end)

    wd = Path.expand("../../../mdi", __DIR__)
    File.mkdir_p!(wd)

    quoted = EEx.compile_file("#{__DIR__}/yew_icon_mod.eex")
    {result, _bindings} = Code.eval_quoted(quoted, icons: icons, icon_names: icon_names, ns: ns)
    fl = "#{wd}/mod.rs"
    File.write!(fl, result)

    quoted = EEx.compile_file("#{__DIR__}/yew_icon_props.eex")
    {result, _bindings} = Code.eval_quoted(quoted, ns: ns)
    fl = "#{wd}/icon_props.rs"
    File.write!(fl, result)

    icons |> Enum.each(fn(name) ->
      inner = File.read!(Application.app_dir(:phoenix_webcomponent, "priv/mdi/svg/#{name}.svg")) |> String.replace(~r/<svg[^>]+>/, "") |> String.replace("</svg>", "") |> String.trim()
      quoted = EEx.compile_file("#{__DIR__}/yew_icon_item.eex")
      {result, _bindings} = Code.eval_quoted(quoted, ns: ns, name: name, inner: inner, vb: "0 0 24 24")

      fl = "#{wd}/#{name |> String.replace("-", "_")}.rs"
      File.write!(fl, result)
    end)
  end

  def run(["bsi"]) do
    Mix.Task.run("app.start")

    ns = "BS"

    icons =
      File.ls!(Application.app_dir(:phoenix_webcomponent, "priv/bsi/svg"))
      |> Enum.filter(&String.ends_with?(&1, ".svg"))
      |> Enum.map(&String.trim(&1, ".svg"))

    icon_names = icons |> Enum.map(fn(name) ->
      name |> String.split("-") |> Enum.map(&String.capitalize/1) |> Enum.join("")
    end)

    wd = Path.expand("../../../bsi", __DIR__)
    File.mkdir_p!(wd)

    quoted = EEx.compile_file("#{__DIR__}/yew_icon_mod.eex")
    {result, _bindings} = Code.eval_quoted(quoted, icons: icons, icon_names: icon_names, ns: ns)
    fl = "#{wd}/mod.rs"
    File.write!(fl, result)

    quoted = EEx.compile_file("#{__DIR__}/yew_icon_props.eex")
    {result, _bindings} = Code.eval_quoted(quoted, ns: ns)
    fl = "#{wd}/icon_props.rs"
    File.write!(fl, result)

    icons |> Enum.each(fn(name) ->
      inner = File.read!(Application.app_dir(:phoenix_webcomponent, "priv/bsi/svg/#{name}.svg")) |> String.replace(~r/<svg[^>]+>/, "") |> String.replace("</svg>", "") |> String.trim()
      quoted = EEx.compile_file("#{__DIR__}/yew_icon_item.eex")
      {result, _bindings} = Code.eval_quoted(quoted, ns: ns, name: name, inner: inner, vb: "0 0 16 16")

      fl = "#{wd}/#{name |> String.replace("-", "_")}.rs"
      File.write!(fl, result)
    end)
  end

  def run(_) do
    IO.puts("Use `mix phx_wc.gen_rs_icons bsi` or `mix phx_wc.gen_rs_icons mdi`")
  end
end
