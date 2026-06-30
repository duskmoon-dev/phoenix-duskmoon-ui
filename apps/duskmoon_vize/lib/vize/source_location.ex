defmodule Vize.SourceLocation do
  @moduledoc "A source position reported by Vize."

  defstruct [:offset, :line, :column]

  @type t :: %__MODULE__{
          offset: non_neg_integer() | nil,
          line: pos_integer() | nil,
          column: pos_integer() | nil
        }

  @type input :: %{
          optional(:offset) => non_neg_integer() | nil,
          optional(:line) => pos_integer() | nil,
          optional(:column) => pos_integer() | nil
        }

  @spec new(input() | t() | nil) :: t() | nil
  def new(nil), do: nil
  def new(%__MODULE__{} = location), do: location

  def new(%{} = attrs) do
    %__MODULE__{
      offset: Map.get(attrs, :offset),
      line: Map.get(attrs, :line),
      column: Map.get(attrs, :column)
    }
  end
end
