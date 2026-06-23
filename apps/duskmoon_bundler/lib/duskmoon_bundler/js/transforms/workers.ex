defmodule DuskmoonBundler.JS.Transforms.Workers do
  @moduledoc "Finds and rewrites `new Worker(new URL(..., import.meta.url))` module specifiers."

  @spec rewrite(String.t(), String.t(), (String.t() -> {:rewrite, String.t()} | :keep)) ::
          {:ok, String.t()} | {:error, term()}
  def rewrite(source, filename, rewrite_fn) do
    case OXC.select(source, filename, :workers) do
      {:ok, workers} ->
        patches = collect_worker_patches(workers, rewrite_fn)

        if patches == [],
          do: {:ok, source},
          else: {:ok, DuskmoonBundler.JS.Patch.apply(source, patches)}

      {:error, _} = error ->
        error
    end
  end

  defp collect_worker_patches(workers, rewrite_fn) do
    Enum.reduce(workers, [], fn worker, patches ->
      case worker |> DuskmoonBundler.JS.Patch.selector_specifier() |> rewrite_fn.() do
        {:rewrite, new} ->
          [DuskmoonBundler.JS.Patch.replace_selector(worker, Jason.encode!(new)) | patches]

        :keep ->
          patches
      end
    end)
  end
end
