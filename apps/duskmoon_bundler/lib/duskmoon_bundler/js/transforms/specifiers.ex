defmodule DuskmoonBundler.JS.Transforms.Specifiers do
  @moduledoc "Rewrites JavaScript import and require specifiers while collecting resolved paths."

  @type rewrite_result :: :skip | {:ok, String.t() | nil, String.t()} | {:error, term()}
  @type rewrite_fun :: (String.t(), String.t(), term() -> rewrite_result())

  @spec rewrite(String.t(), String.t(), term(), rewrite_fun()) ::
          {:ok, String.t(), [String.t()]} | {:error, term()}
  def rewrite(source, importer, context, rewrite_fun) do
    case OXC.parse(source, Path.basename(importer)) do
      {:ok, ast} ->
        {patches, resolved_paths} = collect_patches(ast, importer, context, rewrite_fun)
        {:ok, DuskmoonBundler.JS.Patch.apply(source, patches), resolved_paths}

      {:error, errors} ->
        {:error, {:parse_error, importer, errors}}
    end
  catch
    {:error, _} = error -> error
  end

  defp collect_patches(ast, importer, context, rewrite_fun) do
    {_ast, {patches, paths}} =
      OXC.postwalk(ast, {[], []}, fn
        %{type: type, source: source}, acc
        when type in [:import_declaration, :export_all_declaration, :export_named_declaration] ->
          {nil, maybe_accumulate_patch(source, importer, context, rewrite_fun, acc)}

        %{type: :import_expression, source: source} = node, acc ->
          {node, maybe_accumulate_patch(source, importer, context, rewrite_fun, acc)}

        node, acc ->
          case DuskmoonBundler.JS.AST.call_arguments(node, "require") do
            {:ok, [source | _]} ->
              {node, maybe_accumulate_patch(source, importer, context, rewrite_fun, acc)}

            _ ->
              {node, acc}
          end
      end)

    {Enum.reverse(patches), Enum.reverse(paths)}
  end

  defp maybe_accumulate_patch(source, importer, context, rewrite_fun, acc) do
    case DuskmoonBundler.JS.AST.string_literal_span(source) do
      {:ok, specifier, start_pos, end_pos} ->
        accumulate_patch(specifier, start_pos, end_pos, importer, context, rewrite_fun, acc)

      nil ->
        acc
    end
  end

  defp accumulate_patch(
         specifier,
         start_pos,
         end_pos,
         importer,
         context,
         rewrite_fun,
         {patches, paths}
       ) do
    case rewrite_fun.(specifier, importer, context) do
      :skip ->
        {patches, paths}

      {:ok, nil, resolved_path} ->
        {patches, [resolved_path | paths]}

      {:ok, replacement, resolved_path} ->
        patch =
          DuskmoonBundler.JS.Patch.new(
            start_pos,
            end_pos,
            DuskmoonBundler.JS.AST.string_literal(replacement)
          )

        {[patch | patches], [resolved_path | paths]}

      {:error, _reason} ->
        {patches, paths}
    end
  end
end
