defmodule DuskmoonBundler.JS.Runtime.Installer do
  @moduledoc "Installs isolated npm runtime packages for QuickBEAM-backed plugins."

  require Logger

  alias NPM.Lockfile

  defmodule Metadata do
    @moduledoc "Package signature stored beside a JS runtime installation."

    @derive {Jason.Encoder, only: [:signature, :packages]}
    defstruct signature: nil, packages: %{}
  end

  @spec install!(map(), keyword()) :: %{install_dir: String.t(), node_modules: String.t()}
  def install!(packages, opts \\ []) when is_map(packages) do
    Application.ensure_all_started(:req)

    id = install_id(packages)
    install_dir = Keyword.get(opts, :install_dir, default_install_dir(id))
    node_modules = Path.join(install_dir, "node_modules")
    lockfile_path = Path.join(install_dir, "npm.lock")
    metadata_path = Path.join(install_dir, "duskmoon-bundler-runtime.json")
    signature = install_signature(packages)

    with_lock(install_dir, fn ->
      if Keyword.get(opts, :force, false) or metadata_mismatch?(metadata_path, signature) do
        File.rm_rf!(install_dir)
      end

      unless install_intact?(lockfile_path, node_modules, metadata_path, signature) do
        File.mkdir_p!(install_dir)
        resolve_and_link!(packages, node_modules, lockfile_path)
        write_metadata!(metadata_path, signature, packages)
      end
    end)

    %{install_dir: install_dir, node_modules: node_modules}
  end

  defp resolve_and_link!(packages, node_modules, lockfile_path) do
    NPM.Resolver.clear_cache()

    case NPM.Resolver.resolve(packages) do
      {:ok, resolved} ->
        {_nested, flat} = Map.pop(resolved, :nested, %{})
        lockfile = build_lockfile(flat)
        NPM.Lockfile.write(lockfile, lockfile_path)
        NPM.Install.Linker.link(lockfile, node_modules)
        warn_ignored_install_scripts(lockfile)

      {:error, message} ->
        raise "NPM package resolution failed:\n#{message}"
    end
  end

  defp build_lockfile(resolved) do
    for {name, version} <- resolved, into: %{} do
      {:ok, packument} = NPM.Registry.get_packument(name)
      info = Map.fetch!(packument.versions, version)

      {name,
       %{
         version: version,
         integrity: info.dist.integrity,
         tarball: info.dist.tarball,
         dependencies: info.dependencies,
         optional_dependencies: info.optional_dependencies,
         has_install_script: info.has_install_script
       }}
    end
  end

  defp warn_ignored_install_scripts(lockfile) do
    packages =
      lockfile
      |> Enum.filter(fn {_name, entry} -> Map.get(entry, :has_install_script, false) end)
      |> Enum.map(fn {name, entry} -> [name, "@", entry.version] end)
      |> Enum.intersperse(", ")
      |> IO.iodata_to_binary()

    if packages != "" do
      Logger.warning(
        "DuskmoonBundler ignored npm lifecycle scripts for #{packages}; npm_ex does not run install hooks"
      )
    end
  end

  defp install_intact?(lockfile_path, node_modules, metadata_path, signature) do
    with true <- metadata_matches?(metadata_path, signature),
         {:ok, policy} <- Lockfile.read_policy(lockfile_path),
         true <- Lockfile.policy_matches?(policy),
         {:ok, lockfile} when lockfile != %{} <- Lockfile.read(lockfile_path) do
      Enum.all?(lockfile, fn {name, _} ->
        File.exists?(Path.join([node_modules, name, "package.json"]))
      end)
    else
      _ -> false
    end
  end

  defp with_lock(id, fun) do
    :global.trans({__MODULE__, id}, fun, [node()], :infinity)
  end

  defp metadata_mismatch?(metadata_path, signature) do
    File.exists?(metadata_path) and not metadata_matches?(metadata_path, signature)
  end

  defp metadata_matches?(metadata_path, signature) do
    with {:ok, json} <- File.read(metadata_path),
         {:ok, decoded} <- Jason.decode(json) do
      match?(%{"signature" => ^signature}, decoded)
    else
      _ -> false
    end
  end

  defp write_metadata!(metadata_path, signature, packages) do
    metadata = %Metadata{signature: signature, packages: stringify_packages(packages)}
    File.write!(metadata_path, Jason.encode!(metadata))
  end

  defp install_id(packages), do: install_signature(packages)

  defp install_signature(packages) do
    packages
    |> Enum.sort()
    |> :erlang.term_to_binary()
    |> :erlang.md5()
    |> Base.encode16(case: :lower)
  end

  defp stringify_packages(packages) do
    Map.new(packages, fn {name, requirement} -> {to_string(name), to_string(requirement)} end)
  end

  defp default_install_dir(id) do
    root =
      System.get_env("DUSKMOON_BUNDLER_JS_RUNTIME_DIR") ||
        Path.join(NPM.Config.cache_dir(), "duskmoon-bundler-js-runtimes")

    Path.join(root, id)
  end
end
