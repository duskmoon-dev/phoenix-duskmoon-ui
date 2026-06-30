defmodule Vize.SourceRange do
  @moduledoc "A source span reported by Vize."

  defstruct [:start, :end, :source]

  @type t :: %__MODULE__{
          start: Vize.SourceLocation.t() | nil,
          end: Vize.SourceLocation.t() | nil,
          source: String.t() | nil
        }

  @type input :: %{
          optional(:start) => Vize.SourceLocation.input() | Vize.SourceLocation.t() | nil,
          optional(:end) => Vize.SourceLocation.input() | Vize.SourceLocation.t() | nil,
          optional(:source) => String.t() | nil
        }

  @spec new(input() | t() | nil) :: t() | nil
  def new(nil), do: nil
  def new(%__MODULE__{} = range), do: range

  def new(%{} = attrs) do
    %__MODULE__{
      start: Vize.SourceLocation.new(Map.get(attrs, :start)),
      end: Vize.SourceLocation.new(Map.get(attrs, :end)),
      source: Map.get(attrs, :source)
    }
  end
end
