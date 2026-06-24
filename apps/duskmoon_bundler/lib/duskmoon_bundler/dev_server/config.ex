defmodule DuskmoonBundler.DevServer.Config do
  @moduledoc "Resolved runtime configuration for the development server plug."

  defstruct root: nil,
            public_dir: nil,
            prefix: DuskmoonBundler.Paths.prefix(),
            target: "",
            import_source: nil,
            vapor: false,
            custom_renderer: false,
            plugins: [],
            aliases: %{},
            node_modules: nil,
            resolve_dirs: [],
            vendor_hash: nil,
            vendor_source: [],
            vendor_url_token: nil,
            module_types: %{},
            define: %{},
            hmr_timeout: 60_000
end
