defmodule DuskmoonBundler.FormatterTest do
  use ExUnit.Case, async: true

  describe "features/1" do
    test "returns JS/TS extensions" do
      features = DuskmoonBundler.Formatter.features([])

      assert ".js" in features[:extensions]
      assert ".ts" in features[:extensions]
      assert ".jsx" in features[:extensions]
      assert ".tsx" in features[:extensions]
      assert ".mjs" in features[:extensions]
      assert ".mts" in features[:extensions]
    end
  end

  describe "format/2" do
    test "formats JavaScript" do
      input = "const   x=1;  let  y =  2;"
      result = DuskmoonBundler.Formatter.format(input, extension: ".js", file: "test.js")

      assert result =~ "const x = 1"
      assert result =~ "let y = 2"
    end

    test "formats TypeScript" do
      input = "const   x:number=1;"
      result = DuskmoonBundler.Formatter.format(input, extension: ".ts", file: "test.ts")

      assert result =~ "const x: number = 1"
    end

    test "formats JSX" do
      input = "const App = () =>   <div   className=\"foo\"  />"
      result = DuskmoonBundler.Formatter.format(input, extension: ".jsx", file: "app.jsx")

      assert result =~ "<div"
    end

    test "uses file option for filename" do
      input = "const x   =   1;"
      result = DuskmoonBundler.Formatter.format(input, extension: ".ts", file: "src/app.ts")

      assert result =~ "const x = 1"
    end

    test "falls back to extension when file is missing" do
      input = "const x   =   1;"
      result = DuskmoonBundler.Formatter.format(input, extension: ".js")

      assert result =~ "const x = 1"
    end
  end
end
