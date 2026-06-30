defmodule Vize.Diagnostic do
  @moduledoc "Structured diagnostic emitted by Vize."

  defstruct [:code, :message, :location, recoverable?: false]

  @type t :: %__MODULE__{
          code: atom() | String.t() | nil,
          message: String.t(),
          location: Vize.SourceRange.t() | nil,
          recoverable?: boolean()
        }

  @type input :: %{
          optional(:code) => atom() | String.t() | nil,
          required(:message) => String.t(),
          optional(:location) => Vize.SourceRange.input() | Vize.SourceRange.t() | nil,
          optional(:loc) => Vize.SourceRange.input() | Vize.SourceRange.t() | nil,
          optional(:recoverable?) => boolean(),
          optional(:recoverable) => boolean()
        }

  @spec new(input() | t() | String.t()) :: t()
  def new(%__MODULE__{} = diagnostic), do: diagnostic
  def new(message) when is_binary(message), do: %__MODULE__{message: message}

  def new(%{} = attrs) do
    %__MODULE__{
      code: Map.get(attrs, :code),
      message: Map.fetch!(attrs, :message),
      location: Vize.SourceRange.new(Map.get(attrs, :location) || Map.get(attrs, :loc)),
      recoverable?: Map.get(attrs, :recoverable?, Map.get(attrs, :recoverable, false))
    }
  end
end
