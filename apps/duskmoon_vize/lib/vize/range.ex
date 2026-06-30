defmodule Vize.Range do
  @moduledoc "A byte range in source text, using `[start, end)` offsets."

  defstruct [:start, :end]

  @type t :: %__MODULE__{start: non_neg_integer(), end: non_neg_integer()}
end
