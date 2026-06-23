defmodule DuskmoonBundler.Path do
  @moduledoc "Filesystem path helpers shared across DuskmoonBundler runtime modules."

  def inside?(path, root) do
    path = Path.expand(path)
    root = Path.expand(root)
    path == root or String.starts_with?(path, root <> "/")
  end
end
