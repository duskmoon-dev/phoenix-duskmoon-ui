defmodule DuskmoonBundler.Plugin.SvelteTest do
  use ExUnit.Case, async: true

  @tag :integration
  test "accepts plugin compiler options" do
    assert {:ok, %{code: code, warnings: warnings}} =
             DuskmoonBundler.Plugin.Svelte.compile("App.svelte", "<h1>Hello</h1>", [],
               generate: :server
             )

    assert code =~ "svelte/internal/server"
    assert is_list(warnings)
  end

  test "extracts imports from script blocks" do
    source = """
    <script module>
      import config from './config'
    </script>
    <script lang="ts">
      import Child from './Child.svelte'
      import { format } from '../format'
    </script>
    <h1>{format(config.title)}</h1>
    """

    assert {:ok, %{imports: imports, workers: []}} =
             DuskmoonBundler.Plugin.Svelte.extract_imports("App.svelte", source, [])

    assert {:static, "./config"} in imports
    assert {:static, "./Child.svelte"} in imports
    assert {:static, "../format"} in imports
  end
end
