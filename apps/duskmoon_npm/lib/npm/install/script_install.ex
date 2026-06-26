defmodule NPM.Install.ScriptInstall do
  alias NPM.Install.Linker
  alias NPM.Install.LockfileBuilder
  alias NPM.Security.Age
  alias NPM.Security.ExoticDeps

  @moduledoc """
  Implements `NPM.install/2` for script-style usage outside Mix projects.

  The public `NPM.install/2` API works like `Mix.install/2`: dependencies are
  resolved once per BEAM VM, installed into a content-addressed directory, and
  exposed through `NPM.install_dir!/0` and `NPM.node_modules_dir!/0`.

  Installs are cached by dependency map and guarded with `:persistent_term` so a
  running VM cannot accidentally switch to a different npm dependency set after
  code has already loaded packages from the first install.
  """

  @state_key :npm_script_installed

  @spec install(map(), keyword()) :: :ok
  def install(deps, opts) when is_map(deps) do
    Application.ensure_all_started(:req)

    unless Keyword.get(opts, :__skip_project_check__, false) do
      if Mix.Project.get() do
        Mix.raise(
          "NPM.install/2 cannot be used inside a Mix project. Use mix npm.install instead."
        )
      end
    end

    id = cache_id(deps)
    force? = Keyword.get(opts, :force, false)

    case :persistent_term.get(@state_key, nil) do
      nil ->
        do_install(deps, id, force?)

      {^id, _dir} when not force? ->
        :ok

      {^id, _dir} ->
        do_install(deps, id, true)

      _ ->
        Mix.raise("NPM.install/2 can only be called with the same dependencies in the given VM")
    end
  end

  defp do_install(deps, id, force?) do
    validate_direct_exotic_deps!(deps)
    dir = install_dir(id)

    if force?, do: File.rm_rf!(dir)

    nm_dir = Path.join(dir, "node_modules")
    lockfile_path = Path.join(dir, "npm.lock")

    if not force? and File.exists?(lockfile_path) and lockfile_policy_current?(lockfile_path) and
         node_modules_intact?(lockfile_path, nm_dir) do
      :persistent_term.put(@state_key, {id, dir})
      :ok
    else
      File.mkdir_p!(dir)
      resolve_and_link(deps, dir, nm_dir, lockfile_path)
      :persistent_term.put(@state_key, {id, dir})
      :ok
    end
  end

  defp resolve_and_link(deps, _dir, nm_dir, lockfile_path) do
    NPM.Resolver.clear_cache()

    case NPM.Resolver.resolve(deps) do
      {:ok, resolved} ->
        {_nested, flat} = Map.pop(resolved, :nested, %{})
        lockfile = build_lockfile(flat)
        NPM.Lockfile.write(lockfile, lockfile_path)
        Linker.link(lockfile, nm_dir)

      {:error, message} ->
        Mix.raise("NPM.install/2 resolution failed:\n#{message}")
    end
  end

  defp build_lockfile(resolved) do
    LockfileBuilder.build(resolved, &warn_age_heuristics/3)
  end

  defp lockfile_policy_current?(lockfile_path) do
    case NPM.Lockfile.read_policy(lockfile_path) do
      {:ok, policy} -> NPM.Lockfile.policy_matches?(policy)
      _ -> false
    end
  end

  defp warn_age_heuristics(name, version, info) do
    info
    |> Age.warnings()
    |> Enum.each(fn warning ->
      Mix.shell().info("Warning: #{Age.format(name, version, warning)}")
    end)
  end

  defp node_modules_intact?(lockfile_path, nm_dir) do
    case NPM.Lockfile.read(lockfile_path) do
      {:ok, lockfile} when lockfile != %{} ->
        Enum.all?(lockfile, fn {name, _} ->
          File.exists?(Path.join([nm_dir, name, "package.json"]))
        end)

      _ ->
        false
    end
  end

  defp validate_direct_exotic_deps!(deps) do
    Enum.each(deps, fn {name, spec} -> ExoticDeps.validate_direct!(name, spec) end)
  end

  defp cache_id(deps) do
    deps
    |> :erlang.term_to_binary()
    |> :erlang.md5()
    |> Base.encode16(case: :lower)
  end

  defp install_dir(id) do
    NPM.Config.install_dir(id)
  end

  @spec installed? :: boolean()
  def installed? do
    :persistent_term.get(@state_key, nil) != nil
  end

  @spec install_dir! :: String.t()
  def install_dir! do
    case :persistent_term.get(@state_key, nil) do
      {_id, dir} -> dir
      nil -> Mix.raise("NPM.install/2 has not been called")
    end
  end

  @spec node_modules_dir! :: String.t()
  def node_modules_dir! do
    Path.join(install_dir!(), "node_modules")
  end
end
