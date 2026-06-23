defmodule DuskmoonBundler.JS.Transforms.GlobImports.File do
  @moduledoc "Resolved file entry for `import.meta.glob` expansion."

  defstruct [:specifier, :key]
end
