defmodule DuskmoonBundler.JS.Transforms.DynamicImports.Replacement do
  @moduledoc "Patch metadata for dynamic import variable replacements."

  defstruct start: nil,
            end: nil,
            index: nil,
            template: "",
            pattern: "",
            query: ""
end
