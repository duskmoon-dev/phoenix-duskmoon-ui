defmodule DuskmoonBundler.JS.ImportExtractor.Result do
  @moduledoc "Structured result returned by JavaScript import extraction."

  @type import_type :: :static | :dynamic
  @type t :: %__MODULE__{
          imports: [{import_type(), String.t()}],
          requires: [String.t()],
          workers: [String.t()]
        }

  defstruct imports: [], requires: [], workers: []
end
