defmodule NPM.Node.Runner do
  alias NPM.Node.Exec

  @moduledoc """
  Runs JavaScript entrypoints with Node.js using project `node_modules` resolution.

  npm package binaries are often symlinks into package directories and expect
  Node's module resolver to see the project's `node_modules`. This module writes
  a short temporary ESM loader that configures `require`, `NODE_PATH`, and module
  lookup paths before importing the target entrypoint.

  It is used by `mix npm.exec` and related helpers when an installed package
  binary needs to execute through Node rather than through a shell script.
  """

  @spec run(String.t(), [String.t()], keyword()) :: {String.t(), non_neg_integer()}
  def run(entrypoint, args, opts \\ []) do
    node_modules_dir = Path.expand(Keyword.get(opts, :node_modules_dir, "node_modules"))
    env = Keyword.get(opts, :env, []) ++ Exec.env(node_modules_dir)
    entrypoint = resolve_entrypoint(Path.expand(entrypoint), node_modules_dir)
    cd = Keyword.get(opts, :cd, File.cwd!())

    if native_binary?(entrypoint) do
      System.cmd(entrypoint, args, env: env, stderr_to_stdout: true, cd: cd)
    else
      run_with_node(entrypoint, args, node_modules_dir, env, cd)
    end
  end

  defp run_with_node(entrypoint, args, node_modules_dir, env, cd) do
    if package_script?(entrypoint, node_modules_dir) do
      node_args = [entrypoint | args]
      System.cmd("node", node_args, env: env, stderr_to_stdout: true, cd: cd)
    else
      loader_path = write_loader(node_modules_dir, entrypoint)

      try do
        node_args = ["--preserve-symlinks", "--preserve-symlinks-main", loader_path | args]
        System.cmd("node", node_args, env: env, stderr_to_stdout: true, cd: cd)
      after
        File.rm(loader_path)
      end
    end
  end

  defp package_script?(entrypoint, node_modules_dir) do
    String.starts_with?(entrypoint, node_modules_dir)
  end

  @js_exts ~w(.js .mjs .cjs .ts)

  defp native_binary?(path) do
    Path.extname(path) not in @js_exts and not node_script?(path)
  end

  defp node_script?(path) do
    case File.open(path, [:read, :binary]) do
      {:ok, io} ->
        header = IO.binread(io, 64)
        File.close(io)
        match?(<<"#!", rest::binary>> when rest != "", header) and header_mentions_node?(header)

      _ ->
        false
    end
  end

  defp header_mentions_node?(<<"#!", rest::binary>>), do: String.contains?(rest, "node")
  defp header_mentions_node?(_), do: false

  defp resolve_entrypoint(entrypoint, node_modules_dir) do
    bin_dir = Path.join(node_modules_dir, ".bin")

    if String.starts_with?(entrypoint, bin_dir) do
      command = Path.basename(entrypoint)

      case find_package_entrypoint(command, node_modules_dir) do
        {:ok, resolved} -> resolved
        :error -> entrypoint
      end
    else
      entrypoint
    end
  end

  defp find_package_entrypoint(command, node_modules_dir) do
    bin_path = Path.join([node_modules_dir, ".bin", command])
    real_bin_path = resolve_symlink(bin_path)

    with {:ok, content} <- File.read(real_bin_path),
         [_, rel_path] <- Regex.run(~r{import\s+["'](\.\./[^"']+)["']}, content) do
      {:ok, Path.expand(rel_path, Path.dirname(real_bin_path))}
    else
      _ ->
        case Exec.which(command, node_modules_dir) do
          {:ok, pkg_path} -> {:ok, Path.expand(pkg_path)}
          _ -> :error
        end
    end
  end

  defp resolve_symlink(path, depth \\ 10)
  defp resolve_symlink(path, 0), do: path

  defp resolve_symlink(path, depth) do
    case File.read_link(path) do
      {:ok, target} ->
        resolve_symlink(Path.expand(target, Path.dirname(path)), depth - 1)

      {:error, _} ->
        path
    end
  end

  defp write_loader(node_modules_dir, entrypoint) do
    path =
      Path.join(
        Path.dirname(node_modules_dir),
        ".npm-node-runner-#{System.unique_integer([:positive])}.mjs"
      )

    File.write!(path, """
    import { createRequire } from 'node:module'
    import { pathToFileURL } from 'node:url'

    const nmDir = #{inspect(node_modules_dir)}
    globalThis.require = createRequire(pathToFileURL(nmDir + '/').href)
    process.env.NODE_PATH = nmDir
    require('node:module').Module._initPaths()

    await import(pathToFileURL(#{inspect(entrypoint)}).href)
    """)

    path
  end
end
