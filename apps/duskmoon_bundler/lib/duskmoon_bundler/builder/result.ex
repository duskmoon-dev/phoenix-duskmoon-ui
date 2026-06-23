defmodule DuskmoonBundler.Builder.Result do
  @moduledoc "Production build result returned from `DuskmoonBundler.Builder`."

  defstruct js: [], css: nil, manifest: %{}, chunks: []

  @behaviour Access

  @impl Access
  def fetch(result, key), do: Map.fetch(result, key)

  @impl Access
  def get_and_update(result, key, fun), do: Map.get_and_update(result, key, fun)

  @impl Access
  def pop(result, key), do: Map.pop(result, key)
end
