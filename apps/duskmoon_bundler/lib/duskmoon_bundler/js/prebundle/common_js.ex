defmodule DuskmoonBundler.JS.PrebundleEntry.CommonJS do
  @moduledoc false

  # Discover literal CommonJS exports without evaluating package code. Conditional
  # module.exports = require(...) entrypoints share the exports of their targets.
  def exports(path), do: collect([path], MapSet.new(), MapSet.new())

  def common_js?(path) do
    case parse_common_js(path) do
      {:ok, ast} -> Path.extname(path) == ".cjs" or common_js_node?(ast)
      _ -> false
    end
  end

  defp parse_common_js(path) do
    with {:ok, source} <- File.read(path),
         {:ok, ast} <- OXC.parse(source, Path.basename(path)) do
      if esm?(path, ast), do: :error, else: {:ok, ast}
    end
  end

  defp esm?(path, ast) do
    syntax =
      Enum.any?(
        ast[:body] || [],
        &(&1[:type] in [
            :import_declaration,
            :export_named_declaration,
            :export_default_declaration,
            :export_all_declaration
          ])
      )

    package_module =
      case NPM.Resolution.PackageResolver.nearest_package(Path.dirname(path)) do
        {:ok, _, %{"type" => "module"}} -> true
        _ -> false
      end

    syntax or Path.extname(path) == ".mjs" or (Path.extname(path) != ".cjs" and package_module)
  end

  defp common_js_node?(%{type: :assignment_expression, left: left} = node) do
    exports_object?(left) or
      (left[:type] == :member_expression and exports_object?(left[:object])) or
      Enum.any?(Map.values(node), &common_js_node?/1)
  end

  defp common_js_node?(node) when is_map(node),
    do: entries(node) != [] or Enum.any?(Map.values(node), &common_js_node?/1)

  defp common_js_node?(nodes) when is_list(nodes), do: Enum.any?(nodes, &common_js_node?/1)
  defp common_js_node?(_), do: false

  defp collect([], _seen, names), do: names |> Enum.sort()

  defp collect([path | rest], seen, names) do
    if MapSet.member?(seen, path) do
      collect(rest, seen, names)
    else
      entries =
        with {:ok, ast} <- parse_common_js(path) do
          scan(ast)
        else
          _ -> []
        end

      {paths, names} =
        Enum.reduce(entries, {rest, names}, fn
          {:name, name}, {paths, names} ->
            if name not in ["default", "__esModule"] and
                 Regex.match?(~r/^[A-Za-z_$][A-Za-z0-9_$]*$/, name),
               do: {paths, MapSet.put(names, name)},
               else: {paths, names}

          {:require, specifier}, {paths, names} ->
            case NPM.Resolution.PackageResolver.resolve(specifier, Path.dirname(path),
                   conditions: DuskmoonBundler.JS.Resolution.browser_conditions()
                 ) do
              {:ok, resolved} -> {[resolved | paths], names}
              _ -> {paths, names}
            end
        end)

      collect(paths, MapSet.put(seen, path), names)
    end
  end

  defp scan(node) when is_map(node), do: entries(node) ++ Enum.flat_map(Map.values(node), &scan/1)
  defp scan(nodes) when is_list(nodes), do: Enum.flat_map(nodes, &scan/1)
  defp scan(_), do: []

  defp entries(%{type: :assignment_expression, left: left, right: right}) do
    cond do
      exports_object?(left) ->
        exported_value(right)

      left[:type] == :member_expression and exports_object?(left[:object]) ->
        case property_name(left[:property], left[:computed]) do
          name when is_binary(name) -> [{:name, name}]
          _ -> []
        end

      true ->
        []
    end
  end

  defp entries(%{type: :call_expression, callee: callee, arguments: [target, key | _]}) do
    if DuskmoonBundler.JS.AST.member_expression?(callee, "Object", "defineProperty") and
         exports_object?(target) and is_binary(property_name(key, true)),
       do: [{:name, property_name(key, true)}],
       else: []
  end

  defp entries(_), do: []

  defp exported_value(%{type: :object_expression, properties: properties}) do
    Enum.flat_map(properties, fn property ->
      case property_name(property[:key], property[:computed]) do
        name when is_binary(name) -> [{:name, name}]
        _ -> []
      end
    end)
  end

  defp exported_value(%{
         type: :call_expression,
         callee: %{name: "require"},
         arguments: [%{value: specifier}]
       })
       when is_binary(specifier),
       do: [{:require, specifier}]

  defp exported_value(_), do: []

  defp exports_object?(%{type: :identifier, name: "exports"}), do: true

  defp exports_object?(node),
    do: DuskmoonBundler.JS.AST.member_expression?(node, "module", "exports")

  defp name(%{name: name}), do: name
  defp name(%{value: value}) when is_binary(value), do: value
  defp name(_), do: nil

  defp property_name(%{value: value}, true) when is_binary(value), do: value
  defp property_name(_, true), do: nil
  defp property_name(node, _), do: name(node)
end
