defmodule OXC.Bundle.Result do
  @moduledoc "Result of a bundle run."

  alias OXC.Bundle.Output

  defstruct outputs: [], warnings: []

  @type t :: %__MODULE__{outputs: [Output.t()], warnings: [map()]}

  def new(%__MODULE__{} = result), do: result

  def new(map) when is_map(map) do
    %__MODULE__{
      outputs: map |> Map.get(:outputs, []) |> Enum.map(&Output.new/1),
      warnings: Map.get(map, :warnings, [])
    }
  end
end
