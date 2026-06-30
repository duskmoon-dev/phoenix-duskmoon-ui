defmodule Vize.CSS.URL do
  @moduledoc "A parser-backed CSS `url()` reference."

  defstruct [:url, :range, :location]

  @type t :: %__MODULE__{
          url: String.t(),
          range: Vize.Range.t(),
          location: Vize.SourceRange.t()
        }

  @type input :: %{
          required(:url) => String.t(),
          required(:start) => non_neg_integer(),
          required(:end) => non_neg_integer(),
          optional(:start_line) => pos_integer() | nil,
          optional(:start_column) => pos_integer() | nil,
          optional(:end_line) => pos_integer() | nil,
          optional(:end_column) => pos_integer() | nil
        }

  @spec new(input() | t()) :: t()
  def new(%__MODULE__{} = url), do: url

  def new(%{} = attrs) do
    %__MODULE__{
      url: Map.fetch!(attrs, :url),
      range: %Vize.Range{
        start: Map.fetch!(attrs, :start),
        end: Map.fetch!(attrs, :end)
      },
      location: %Vize.SourceRange{
        start: %Vize.SourceLocation{
          line: Map.get(attrs, :start_line),
          column: Map.get(attrs, :start_column)
        },
        end: %Vize.SourceLocation{
          line: Map.get(attrs, :end_line),
          column: Map.get(attrs, :end_column)
        }
      }
    }
  end
end
