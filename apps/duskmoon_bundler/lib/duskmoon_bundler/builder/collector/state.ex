defmodule DuskmoonBundler.Builder.Collector.State do
  @moduledoc "State accumulated while walking the production dependency graph."

  defstruct root: nil,
            ctx: nil,
            files: [],
            seen: MapSet.new(),
            used_labels: MapSet.new(),
            dep_map: %{},
            workers: %{},
            specifier_labels: %{},
            path_labels: %{}
end
