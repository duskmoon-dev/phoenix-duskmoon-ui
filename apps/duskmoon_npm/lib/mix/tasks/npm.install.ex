defmodule Mix.Tasks.Npm.Install do
  @shortdoc "Install npm packages"

  @moduledoc """
  Install npm packages.

      mix npm.install                         # Install all deps from package.json/workspaces
      mix npm.install lodash                  # Add latest version
      mix npm.install lodash@^4.0             # Add with specific range
      mix npm.install @types/node@^20         # Add scoped package
      mix npm.install --frozen                # Fail if lockfile is stale (CI)
      mix npm.install --production            # Skip devDependencies
      mix npm.install eslint --save-dev       # Add to devDependencies
      mix npm.install lodash react vue        # Add multiple packages

  Resolves all root and workspace dependencies using the PubGrub solver,
  writes `npm.lock`, and links packages into `node_modules/`.
  """

  use Mix.Task

  @impl true
  def run(args) do
    Application.ensure_all_started(:req)
    {opts, positional} = parse_args(args)

    case positional do
      [] -> NPM.install(opts)
      specs -> Enum.each(specs, &install_spec(&1, opts))
    end
  end

  defp parse_args(args) do
    {parsed, rest, _} =
      OptionParser.parse(args,
        strict: [
          frozen: :boolean,
          production: :boolean,
          save_dev: :boolean,
          save_exact: :boolean,
          save_optional: :boolean
        ]
      )

    {parsed, rest}
  end

  defp install_spec(spec, opts) do
    {name, range} = parse_package_spec(spec)

    add_opts =
      Enum.filter(
        [dev: opts[:save_dev], optional: opts[:save_optional], exact: opts[:save_exact]],
        &elem(&1, 1)
      )

    NPM.add(name, range, add_opts)
  end

  @doc false
  def parse_package_spec(spec) do
    case spec do
      # @scope/pkg@range
      "@" <> rest ->
        case String.split(rest, "@", parts: 2) do
          [scoped_name, range] -> {"@" <> scoped_name, range}
          [scoped_name] -> {"@" <> scoped_name, "latest"}
        end

      # pkg@range
      _ ->
        case String.split(spec, "@", parts: 2) do
          [name, range] -> {name, range}
          [name] -> {name, "latest"}
        end
    end
  end
end
