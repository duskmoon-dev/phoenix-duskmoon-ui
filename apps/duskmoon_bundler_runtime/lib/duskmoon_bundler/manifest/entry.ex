defmodule DuskmoonBundler.Manifest.Entry do
  @moduledoc "Normalized runtime view of a single DuskmoonBundler manifest entry."

  defstruct file: nil,
            src: nil,
            entry?: false,
            imports: [],
            dynamic_imports: [],
            css: [],
            assets: []

  def from_manifest(%{"file" => file} = entry) do
    %__MODULE__{
      file: file,
      src: Map.get(entry, "src"),
      entry?: Map.get(entry, "isEntry", false),
      imports: Map.get(entry, "imports", []),
      dynamic_imports: Map.get(entry, "dynamicImports", []),
      css: Map.get(entry, "css", []),
      assets: Map.get(entry, "assets", [])
    }
  end

  def from_manifest(file) when is_binary(file) do
    %__MODULE__{file: file}
  end

  def file(%{"file" => file}) when is_binary(file), do: {:ok, file}
  def file(file) when is_binary(file), do: {:ok, file}
  def file(_entry), do: :error
end
