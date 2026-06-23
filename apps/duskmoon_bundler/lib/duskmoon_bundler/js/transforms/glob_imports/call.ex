defmodule DuskmoonBundler.JS.Transforms.GlobImports.Call do
  @moduledoc "Parsed `import.meta.glob` call options."

  defstruct start: nil,
            end: nil,
            patterns: [],
            eager: false,
            import: nil,
            query: "",
            base: nil
end
