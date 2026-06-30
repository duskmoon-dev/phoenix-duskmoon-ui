defmodule Vize.Croquis do
  @moduledoc "Semantic analysis summary for a Vue SFC."

  defstruct stats: %{},
            bindings: %{},
            props: [],
            emits: [],
            models: [],
            used_components: [],
            used_directives: [],
            undefined_refs: [],
            component_usages: [],
            template_expressions: []

  @type t :: %__MODULE__{}

  @spec new(map()) :: t()
  def new(map) when is_map(map), do: struct!(__MODULE__, map)
end
