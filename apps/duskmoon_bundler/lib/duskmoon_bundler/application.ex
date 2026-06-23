defmodule DuskmoonBundler.Application do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    DuskmoonBundler.Cache.create_table()
    DuskmoonBundler.HMR.ImportGraph.create_table()
    DuskmoonBundler.HMR.GlobGraph.create_table()
    DuskmoonBundler.HMR.ModuleGraph.create_table()

    children = [
      {Registry, keys: :duplicate, name: DuskmoonBundler.HMR.Registry},
      {DuskmoonBundler.Tailwind, DuskmoonBundler.Config.tailwind()}
    ]

    opts = [strategy: :one_for_one, name: DuskmoonBundler.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
