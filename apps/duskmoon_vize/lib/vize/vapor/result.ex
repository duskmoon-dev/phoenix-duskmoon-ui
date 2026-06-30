defmodule Vize.Vapor.Result do
  @moduledoc "Result of Vapor template compilation."

  defstruct [:code, templates: [], diagnostics: []]

  @type t :: %__MODULE__{
          code: String.t(),
          templates: [String.t()],
          diagnostics: [Vize.Diagnostic.t()]
        }

  @type input :: %{
          required(:code) => String.t(),
          optional(:templates) => [String.t()],
          optional(:diagnostics) => [Vize.Diagnostic.input() | Vize.Diagnostic.t() | String.t()]
        }

  @spec new(input() | t()) :: t()
  def new(%__MODULE__{} = result), do: result

  def new(%{} = attrs) do
    %__MODULE__{
      code: Map.fetch!(attrs, :code),
      templates: Map.get(attrs, :templates, []),
      diagnostics: Enum.map(Map.get(attrs, :diagnostics, []), &Vize.Diagnostic.new/1)
    }
  end
end
