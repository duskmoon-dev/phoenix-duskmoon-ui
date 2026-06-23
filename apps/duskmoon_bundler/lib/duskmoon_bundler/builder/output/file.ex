defmodule DuskmoonBundler.Builder.OutputFile do
  @moduledoc "Metadata for one generated production output file."

  defstruct path: nil,
            size: 0,
            assets: [],
            chunk_id: nil,
            type: nil
end
