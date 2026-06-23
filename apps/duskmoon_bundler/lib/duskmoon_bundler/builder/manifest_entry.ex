defmodule DuskmoonBundler.Builder.ManifestEntry do
  @moduledoc "Manifest entry written to production `manifest.json`."

  @derive Jason.Encoder
  defstruct file: nil,
            src: nil,
            isEntry: false,
            imports: [],
            dynamicImports: [],
            css: [],
            assets: []

  def js(src, file, opts \\ []) do
    %__MODULE__{src: src, file: file, isEntry: Keyword.get(opts, :entry, false)}
  end

  def css(src, file, assets), do: %__MODULE__{src: src, file: file, assets: assets}

  def asset(src, file), do: %__MODULE__{src: src, file: file}
end
