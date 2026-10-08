defmodule OXC.BundleOutputTest do
  use ExUnit.Case, async: true

  alias OXC.Bundle

  @tag :tmp_dir
  test "reports resolved empty, shared, and dynamic modules without source maps", %{tmp_dir: root} do
    files = %{
      "a.js" =>
        "import './empty.js'; export { state } from './shared.js'; export const load = () => import('./lazy.js');",
      "b.js" => "export { state } from './shared.js';",
      "empty.js" => "// No code or source-map mappings.",
      "shared.js" => "export const state = { singleton: true };",
      "lazy.js" => "export const value = 'lazy';"
    }

    for {name, source} <- files, do: File.write!(Path.join(root, name), source)

    assert {:ok, result} =
             Bundle.new()
             |> Bundle.entries([{"a", Path.join(root, "a.js")}, {"b", Path.join(root, "b.js")}])
             |> Bundle.cwd(root)
             |> Bundle.outdir(Path.join(root, "dist"))
             |> Bundle.format(:esm)
             |> Bundle.output(preserve_entry_signatures: :strict)
             |> Bundle.run()

    ids = Enum.flat_map(result.outputs, & &1.module_ids)
    for name <- Map.keys(files), do: assert(Path.join(root, name) in ids)
    assert Enum.all?(result.outputs, &is_nil(&1.sourcemap))
    assert Enum.any?(result.outputs, &(&1.type == :chunk))
  end
end
