defmodule DuskmoonBundler.JS.Asset do
  @moduledoc "Access to JavaScript and TypeScript support assets bundled with DuskmoonBundler."

  @priv_ts Application.app_dir(:duskmoon_bundler, "priv/ts")

  @doc "Path to the priv/ts directory containing bundled TypeScript assets."
  @spec priv_dir :: String.t()
  def priv_dir, do: @priv_ts

  @spec read!(String.t()) :: String.t()
  def read!(filename) do
    filename
    |> path_for()
    |> File.read!()
  end

  @doc """
  Read a TypeScript asset, compile to JavaScript, and cache in persistent_term.

  Returns compiled JS on subsequent calls without recompilation.
  """
  @spec compiled!(String.t()) :: String.t()
  def compiled!(filename) do
    key = {__MODULE__, :compiled, filename}

    case :persistent_term.get(key, nil) do
      nil ->
        code = read!(filename) |> compile_ts(filename)
        :persistent_term.put(key, code)
        code

      code ->
        code
    end
  end

  @doc "Compile a TypeScript support asset after binding OXC `$placeholder` literals."
  @spec compiled_template!(String.t(), keyword() | map()) :: String.t()
  def compiled_template!(filename, bindings) do
    code =
      filename
      |> template_ast!()
      |> OXC.bind(literal_bindings(bindings))
      |> OXC.codegen!()

    rewrite_runtime_imports(code)
  end

  @spec path_for(String.t()) :: String.t()
  def path_for(filename), do: Path.join(@priv_ts, filename)

  defp template_ast!(filename) do
    key = {__MODULE__, :template_ast, filename}

    case :persistent_term.get(key, nil) do
      nil ->
        ast = filename |> read!() |> OXC.parse!(filename)
        :persistent_term.put(key, ast)
        ast

      ast ->
        ast
    end
  end

  defp literal_bindings(bindings) do
    Enum.map(bindings, fn {key, value} -> {key, {:literal, value}} end)
  end

  defp rewrite_runtime_imports(code) do
    case OXC.rewrite_specifiers(code, "duskmoon_bundler-template.js", fn
           "./hmr-client" -> {:rewrite, "/@duskmoon_bundler/client.js"}
           _specifier -> :keep
         end) do
      {:ok, rewritten} -> rewritten
      {:error, _errors} -> code
    end
  end

  # OXC.transform returns a plain string with sourcemap: false,
  # or %{code: string, sourcemap: string} with sourcemap: true.
  defp compile_ts(source, filename) do
    case OXC.transform(source, filename, sourcemap: false) do
      {:ok, code} when is_binary(code) -> code
      {:ok, %{code: code}} -> code
      _ -> source
    end
  end
end
