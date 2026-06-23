defmodule DuskmoonBundler.Plugin.SolidTest do
  use ExUnit.Case, async: true

  @tag :integration
  test "compiles Solid TSX through the Solid compiler" do
    source = """
    type Props = { name: string }

    export function App(props: Props) {
      return <h1>Hello {props.name}</h1>
    }
    """

    assert {:ok, %{code: code, sourcemap: sourcemap}} =
             DuskmoonBundler.Plugin.Solid.compile("App.tsx", source, [])

    assert code =~ "solid-js/web"
    assert code =~ "template"
    refute code =~ "jsx-runtime"
    assert is_binary(sourcemap)
  end

  test "adds Solid compiler runtime imports during import extraction" do
    source = """
    import { createSignal } from 'solid-js'
    const [count] = createSignal(0)
    export const App = () => <button>{count()}</button>
    """

    assert {:ok, %{imports: imports, workers: []}} =
             DuskmoonBundler.Plugin.Solid.extract_imports("App.tsx", source, [])

    assert {:static, "solid-js"} in imports
    assert {:static, "solid-js/web"} in imports
  end

  @tag :integration
  test "removes imports that are only used as TypeScript types" do
    source = """
    import { createSignal } from 'solid-js'
    import { Label } from './types'

    type Props = { label: Label }

    export function App(props: Props) {
      const [count] = createSignal(0)
      return <button>{props.label.text} {count()}</button>
    }
    """

    assert {:ok, %{code: code}} = DuskmoonBundler.Plugin.Solid.compile("App.tsx", source, [])

    refute code =~ "./types"
    assert code =~ "solid-js"
  end

  test "extracts require imports and worker specifiers" do
    source = """
    import { render } from 'solid-js/web'
    const helper = require('./helper')
    const worker = new Worker(new URL('./worker.ts', import.meta.url), { type: 'module' })
    console.log(worker)
    export const App = () => <button>{helper.label}</button>
    """

    assert {:ok, %{imports: imports, workers: workers}} =
             DuskmoonBundler.Plugin.Solid.extract_imports("App.tsx", source, [])

    assert {:static, "./helper"} in imports
    assert {:static, "solid-js/web"} in imports
    assert "./worker.ts" in workers
  end

  @tag :integration
  test "drops sourcemap when target downleveling rewrites compiled output" do
    source = """
    export const App = () => <button>{globalThis.value ?? 'fallback'}</button>
    """

    assert {:ok, %{code: code, sourcemap: nil}} =
             DuskmoonBundler.Plugin.Solid.compile("App.tsx", source, target: :es2019)

    refute code =~ "??"
  end
end
