defmodule DuskmoonBundler.Builder.Dependencies do
  @moduledoc "Static, dynamic, and CommonJS dependency lists for one collected module."

  defstruct static: [], dynamic: [], requires: []
end
