defmodule Vize.Error do
  @moduledoc "Exception returned or raised by Vize bang APIs."

  defexception [:message, diagnostics: [], errors: []]

  @type t :: %__MODULE__{
          message: String.t(),
          diagnostics: [Vize.Diagnostic.t()],
          errors: term()
        }

  @spec new(String.t(), term()) :: t()
  def new(message, errors) do
    diagnostics = Enum.map(List.wrap(errors), &Vize.Diagnostic.new/1)
    %__MODULE__{message: message, diagnostics: diagnostics, errors: errors}
  end
end
