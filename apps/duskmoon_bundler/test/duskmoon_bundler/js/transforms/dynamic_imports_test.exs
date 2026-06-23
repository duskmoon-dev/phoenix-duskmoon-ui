defmodule DuskmoonBundler.JS.Transforms.DynamicImportsTest do
  use ExUnit.Case, async: true

  test "rewrites relative template dynamic imports through import.meta.glob" do
    source = "const mod = await import(`./pages/${name}.ts`)"

    result = DuskmoonBundler.JS.Transforms.DynamicImports.transform(source, "app.ts")

    assert result =~
             ~S|const __duskmoon_bundler_dynamic_import_modules_0 = import.meta.glob("./pages/*.ts");|

    assert result =~ "__duskmoon_bundler_dynamic_import_0(`./pages/${name}.ts`)"
    refute result =~ "await import(`./pages/${name}.ts`)"
  end

  test "preserves static query suffixes through glob query options" do
    source = "const mod = await import(`./pages/${name}.txt?raw`)"

    result = DuskmoonBundler.JS.Transforms.DynamicImports.transform(source, "app.ts")

    assert result =~ ~S|import.meta.glob("./pages/*.txt", { query: "?raw" });|
    assert result =~ ~S|__duskmoon_bundler_dynamic_import_modules_0[path.split("?")[0]]|
  end

  test "ignores bare package dynamic imports" do
    source = "const mod = await import(`pkg/${name}.js`)"

    assert DuskmoonBundler.JS.Transforms.DynamicImports.transform(source, "app.ts") == source
  end
end
