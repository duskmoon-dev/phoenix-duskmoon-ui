defmodule DuskmoonBundler.JS.Transforms.WorkersTest do
  use ExUnit.Case, async: true

  test "returns source when no worker rewrites apply" do
    source =
      "const worker = new Worker(new URL('./worker.ts', import.meta.url), { type: 'module' })"

    {:ok, result} =
      DuskmoonBundler.JS.Transforms.Workers.rewrite(source, "test.ts", fn _ -> :keep end)

    assert result == source
  end
end
