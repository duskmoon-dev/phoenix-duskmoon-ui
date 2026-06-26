defmodule NPM.Install.LockfileBuilder do
  @moduledoc """
  Builds `npm.lock` entries from resolved package versions.
  """

  @doc "Build lockfile entries from a resolved `%{name => version}` map."
  @spec build(map(), (String.t(), String.t(), map() -> term())) :: NPM.Lockfile.t()
  def build(resolved, on_package \\ fn _name, _version, _info -> :ok end) do
    for {name, version_str} <- resolved, into: %{} do
      {:ok, packument} = NPM.Registry.get_packument(name)
      info = Map.fetch!(packument.versions, version_str)
      on_package.(name, version_str, info)

      {name,
       %{
         version: version_str,
         integrity: info.dist.integrity,
         tarball: info.dist.tarball,
         dependencies: info.dependencies,
         optional_dependencies: info.optional_dependencies,
         has_install_script: info.has_install_script
       }}
    end
  end
end
