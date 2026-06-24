defmodule DuskmoonBundler.Config.Server do
  @moduledoc "Normalized development server configuration."

  defstruct prefix: DuskmoonBundler.Paths.prefix(),
            watch_dirs: [],
            hmr_timeout: 60_000,
            vendor_prebundle: true
end
