defmodule OXC.ParseTest do
  use ExUnit.Case, async: true

  test "preserves lone high and low surrogate literal values as WTF-8 binaries" do
    for {escape, expected} <- [
          {~S(\uD800), <<0xED, 0xA0, 0x80>>},
          {~S(\uDC00), <<0xED, 0xB0, 0x80>>}
        ] do
      raw = ~s("#{escape}")

      assert {:ok, %{body: [%{declarations: [%{init: literal}]}]}} =
               OXC.parse("const value = #{raw};", "surrogate.js")

      assert %{type: :literal, value: ^expected, raw: ^raw, start: 14, end: 22} = literal
    end
  end

  test "preserves valid surrogate pairs as ordinary UTF-8" do
    assert {:ok, %{body: [%{declarations: [%{init: literal}]}]}} =
             OXC.parse(~S(const value = "\uD83D\uDE00";), "paired.js")

    assert %{
             type: :literal,
             value: "😀",
             raw: ~S("\uD83D\uDE00"),
             start: 14,
             end: 28
           } = literal
  end

  test "preserves nested decimal, exponent and integer values as numbers" do
    assert {:ok,
            %{
              body: [
                %{
                  declarations: [
                    %{
                      init: %{
                        elements: [
                          %{type: :literal, value: 2.075},
                          %{type: :literal, value: 2},
                          %{type: :unary_expression, operator: "-", argument: %{value: 2}},
                          %{type: :literal, value: 207.5}
                        ]
                      }
                    }
                  ]
                }
              ]
            }} = OXC.parse("const values = [2.075, 2, -2, 2.075e2];", "numbers.js")
  end

  test "preserves nested literals and template cooked values without changing escaped text" do
    source =
      ~S|const value = { high: "\uD800", low: ["\uDC00"], template: `\uD800`, escaped: "\\uD800" };|

    assert {:ok,
            %{
              body: [
                %{
                  declarations: [
                    %{
                      init: %{
                        properties: [
                          %{value: high},
                          %{value: %{elements: [low]}},
                          %{value: %{quasis: [template]}},
                          %{value: escaped}
                        ]
                      }
                    }
                  ]
                }
              ]
            }} = OXC.parse(source, "nested.js")

    assert %{value: <<0xED, 0xA0, 0x80>>, raw: ~S("\uD800")} = high
    assert %{value: <<0xED, 0xB0, 0x80>>, raw: ~S("\uDC00")} = low
    assert %{value: %{cooked: <<0xED, 0xA0, 0x80>>, raw: ~S(\uD800)}} = template
    assert %{value: ~S(\uD800), raw: ~S("\\uD800")} = escaped
  end

  test "codegen round trips surrogate literals, property keys and template cooked values" do
    source =
      ~S|const value = { "\uD800": "\uDC00\uFFFD", template: `\uD800\uFFFD`, replacement: "\uFFFD" };|

    assert {:ok, ast} = OXC.parse(source, "roundtrip.js")
    assert {:ok, generated} = OXC.codegen(ast)
    assert String.valid?(generated)

    assert {:ok,
            %{
              body: [
                %{
                  declarations: [
                    %{
                      init: %{
                        properties: [
                          %{key: key, value: literal},
                          %{value: %{quasis: [template]}},
                          %{value: replacement}
                        ]
                      }
                    }
                  ]
                }
              ]
            }} = OXC.parse(generated, "generated.js")

    assert %{value: <<0xED, 0xA0, 0x80>>} = key
    assert %{value: <<0xED, 0xB0, 0x80, 0xEF, 0xBF, 0xBD>>} = literal
    assert %{value: %{cooked: <<0xED, 0xA0, 0x80, 0xEF, 0xBF, 0xBD>>}} = template
    assert %{value: "�"} = replacement
  end

  test "codegen uses a mutated surrogate value rather than its original raw spelling" do
    assert {:ok, ast} = OXC.parse(~S(const value = "\uD800";), "mutation.js")

    ast =
      put_in(
        ast,
        [:body, Access.at(0), :declarations, Access.at(0), :init, :value],
        <<0xED, 0xB0, 0x80>>
      )

    assert {:ok, generated} = OXC.codegen(ast)
    assert String.valid?(generated)

    assert {:ok, %{body: [%{declarations: [%{init: %{value: <<0xED, 0xB0, 0x80>>}}]}]}} =
             OXC.parse(generated, "mutated.js")
  end

  test "codegen explicitly rejects lone surrogate import and re-export sources" do
    for {source, expected} <- [
          {~S(import "\uD800";), <<0xED, 0xA0, 0x80>>},
          {~S(export { value } from "\uDC00";), <<0xED, 0xB0, 0x80>>},
          {~S(export * from "\uD800";), <<0xED, 0xA0, 0x80>>}
        ] do
      assert {:ok, %{body: [%{source: %{value: ^expected}}]} = ast} =
               OXC.parse(source, "sources.js")

      assert {:error, [%{message: message}]} = OXC.codegen(ast)
      assert message == "Codegen does not support non-UTF-8 module source strings"
    end
  end

  test "codegen preserves ordinary Unicode import and re-export sources" do
    for source <- [
          ~S(import "./😀.js";),
          ~S(export { value } from "./😀.js";),
          ~S(export * from "./😀.js";)
        ] do
      assert {:ok, ast} = OXC.parse(source, "sources.js")
      assert {:ok, generated} = OXC.codegen(ast)
      assert String.valid?(generated)

      assert {:ok, %{body: [%{source: %{value: "./😀.js"}}]}} =
               OXC.parse(generated, "generated.js")
    end
  end
end
