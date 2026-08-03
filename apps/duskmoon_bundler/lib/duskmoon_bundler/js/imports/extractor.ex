defmodule DuskmoonBundler.JS.ImportExtractor do
  @moduledoc "Extracts static, dynamic, CJS, and worker imports from JavaScript source."

  @type import_type :: :static | :dynamic
  @type result :: DuskmoonBundler.JS.ImportExtractor.Result.t()

  @spec extract_typed(String.t(), String.t(), keyword()) :: {:ok, result()} | {:error, term()}
  def extract_typed(source, filename, opts \\ []) do
    with {:ok, imports} <- OXC.select(source, filename, :import_sources),
         {:ok, require_calls} <- select_require_calls(source, filename, opts),
         {:ok, workers} <- select_workers(source, filename) do
      requires = Enum.map(require_calls, & &1.specifier)
      typed = Enum.map(imports, &{&1.type, &1.specifier}) ++ Enum.map(requires, &{:static, &1})

      {:ok,
       %DuskmoonBundler.JS.ImportExtractor.Result{
         imports: typed,
         requires: requires,
         workers: workers
       }}
    end
  end

  defp select_require_calls(source, filename, opts) do
    if Keyword.get(opts, :include_require, false) do
      case OXC.select(source, filename, :require_calls) do
        {:ok, require_calls} -> {:ok, require_calls}
        {:error, _} = error -> error
      end
    else
      {:ok, []}
    end
  end

  defp select_workers(source, filename) do
    case OXC.select(source, filename, :workers) do
      {:ok, workers} -> {:ok, Enum.map(workers, & &1.specifier)}
      {:error, _} = error -> error
    end
  end
end
