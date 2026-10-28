ExUnit.start()

defmodule DuskmoonUI.CandidatePrepareTest do
  use ExUnit.Case, async: true
  @moduletag :tmp_dir
  test "adapter keeps a complete isolated candidate closure", %{tmp_dir: tmp_dir} do
    root = Path.expand("..", __DIR__)
    {source, 0} = System.cmd("git", ["rev-parse", "--show-toplevel"], cd: root)
    source = String.trim(source)
    stage = Path.join(tmp_dir, "stage")

    apps =
      ~w(duskmoon_bundler duskmoon_bundler_runtime duskmoon_oxc duskmoon_oxide duskmoon_vize duskmoon_quickbeam duskmoon_npm duskmoon_hex_solver)

    for app <- apps do
      File.mkdir_p!(Path.join(stage, app))
      File.write!(Path.join([stage, app, "mix.exs"]), "# candidate")
    end

    File.write!(Path.join(stage, "manifest.json"), "{}")
    output = Path.join(tmp_dir, "ui")

    {_, 0} =
      System.cmd("elixir", [
        Path.join(root, "scripts/prepare-candidate.exs"),
        source,
        stage,
        output
      ])

    content = File.read!(Path.join(output, "mix.exs"))

    {_, body} =
      content
      |> Code.string_to_quoted!()
      |> Macro.prewalk(nil, fn
        {:defp, _, [{:deps, _, _}, [do: body]]} = node, _ -> {node, body}
        node, body -> {node, body}
      end)

    {dependencies, _} = Code.eval_quoted(body)

    for name <- apps do
      app = String.to_atom(name)
      assert [{^app, options}] = Enum.filter(dependencies, &(elem(&1, 0) == app))
      assert options[:path] == Path.join(stage, name)
      assert options[:override]
    end

    provenance =
      output |> Path.join("candidate-provenance.json") |> File.read!() |> JSON.decode!()

    assert provenance["mode"] == "candidate-source-full-cohort"
    refute File.exists?(Path.join(output, "deps"))
    refute File.exists?(Path.join(output, "_build"))
  end
end
