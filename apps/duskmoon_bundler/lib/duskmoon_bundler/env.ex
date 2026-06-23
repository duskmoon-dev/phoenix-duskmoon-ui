defmodule DuskmoonBundler.Env do
  @moduledoc """
  Load environment variables for client-side code.

  Reads `.env` files via Dotenvy and exposes variables with configured prefixes
  as compile-time replacements for `import.meta.env.*` expressions.

  ## Files loaded (in order, later overrides earlier)

    1. `.env`
    2. `.env.local`
    3. `.env.{mode}` (e.g. `.env.production`)
    4. `.env.{mode}.local`

  ## Usage in source code

      console.log(import.meta.env.DUSKMOON_BUNDLER_API_URL)
      console.log(import.meta.env.MODE)   // "development" or "production"
      console.log(import.meta.env.DEV)    // true/false
      console.log(import.meta.env.PROD)   // true/false

  Only variables matching `:env_prefix` are exposed to client code. The default
  prefix is `"DUSKMOON_BUNDLER_"`.
  """

  @default_prefix "DUSKMOON_BUNDLER_"

  @doc """
  Build a define map for compile-time replacement.

  ## Options

    * `:mode` — build mode (default: `"production"`)
    * `:root` — project root for `.env` files (default: cwd)
    * `:env` — extra variables to inject (takes precedence over files)
    * `:env_prefix` — exposed env prefix or prefixes (default: `"DUSKMOON_BUNDLER_"`)
  """
  @spec define(keyword()) :: %{String.t() => String.t()}
  def define(opts \\ []) do
    mode = opts |> Keyword.get(:mode, "production") |> to_string()
    root = Keyword.get(opts, :root, File.cwd!())
    extra = Keyword.get(opts, :env, %{})
    prefixes = env_prefixes(Keyword.get(opts, :env_prefix, @default_prefix))

    vars =
      load_env_files(root, mode)
      |> Map.merge(extra)
      |> Enum.filter(fn {key, _} -> exposed_env?(key, prefixes) end)
      |> Map.new()

    encoded_mode = Jason.encode!(mode)

    base = %{
      "import.meta.env.MODE" => encoded_mode,
      "import.meta.env.DEV" => to_string(mode != "production"),
      "import.meta.env.PROD" => to_string(mode == "production"),
      "process.env.NODE_ENV" => encoded_mode
    }

    env_defines =
      Map.new(vars, fn {key, value} ->
        {"import.meta.env.#{key}", Jason.encode!(value)}
      end)

    Map.merge(base, env_defines)
  end

  defp env_prefixes(prefixes) do
    prefixes
    |> List.wrap()
    |> Enum.map(&to_string/1)
    |> Enum.reject(&(&1 == ""))
  end

  defp exposed_env?(key, prefixes) do
    Enum.any?(prefixes, &String.starts_with?(key, &1))
  end

  @doc """
  Load and merge `.env` files for the given mode.
  """
  @spec load_env_files(String.t(), String.t()) :: %{String.t() => String.t()}
  def load_env_files(root, mode) do
    files =
      [".env", ".env.local", ".env.#{mode}", ".env.#{mode}.local"]
      |> Enum.map(&Path.join(root, &1))
      |> Enum.filter(&File.regular?/1)

    case Dotenvy.source(files) do
      {:ok, vars} -> vars
      {:error, _} -> %{}
    end
  end
end
