defmodule DuskmoonBundler.JS.Resolution do
  @moduledoc "Shared JavaScript package resolution defaults."

  @browser_conditions ["browser", "import", "default"]

  def browser_conditions, do: @browser_conditions
end
