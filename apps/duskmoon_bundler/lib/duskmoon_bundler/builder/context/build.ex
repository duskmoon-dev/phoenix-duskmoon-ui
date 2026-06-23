defmodule DuskmoonBundler.Builder.BuildContext do
  @moduledoc "Options required while rendering production build output."

  defstruct outdir: nil,
            target: "",
            hash: true,
            bundle_opts: [],
            ctx: nil,
            asset_url_prefix: DuskmoonBundler.Paths.prefix(),
            code_splitting: true,
            sourcemap_hidden: false,
            chunks: %{}
end
