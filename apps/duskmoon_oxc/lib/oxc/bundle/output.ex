defmodule OXC.Bundle.Output do
  @moduledoc "A generated bundle output chunk or asset."

  defstruct type: nil,
            name: nil,
            file_name: nil,
            path: nil,
            code: nil,
            source: nil,
            sourcemap: nil,
            imports: [],
            dynamic_imports: [],
            exports: []

  @type t :: %__MODULE__{}

  def new(%__MODULE__{} = output), do: output

  def new(map) when is_map(map) do
    %__MODULE__{
      type: Map.get(map, :type),
      name: Map.get(map, :name),
      file_name: Map.get(map, :file_name),
      path: Map.get(map, :path),
      code: Map.get(map, :code),
      source: Map.get(map, :source),
      sourcemap: Map.get(map, :sourcemap),
      imports: Map.get(map, :imports, []),
      dynamic_imports: Map.get(map, :dynamic_imports, []),
      exports: Map.get(map, :exports, [])
    }
  end
end
