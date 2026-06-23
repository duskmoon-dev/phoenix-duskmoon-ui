defmodule DuskmoonBundler.CSS.AST do
  @moduledoc """
  Helpers for parser-backed CSS AST transforms.

  Centralizes the Vize parse → mutate → print flow so CSS transforms handle
  parse and print failures consistently.
  """

  @type transform_result :: {:ok, %{code: String.t(), metadata: term()}} | {:error, term()}

  @doc "Parse CSS, apply an AST transform, and print the result."
  @spec transform(String.t(), String.t() | nil, (term() -> {term(), term()})) ::
          transform_result()
  def transform(css, filename, transform_fn) do
    with {:parse, {:ok, %{ast: ast, errors: []}}} <-
           {:parse, Vize.CSS.parse_ast(css, filename: filename)},
         {ast, metadata} <- transform_fn.(ast),
         {:print, {:ok, %{code: code, errors: []}}} <- {:print, Vize.CSS.print_ast(ast)} do
      {:ok, %{code: code, metadata: metadata}}
    else
      {:parse, {:ok, %{errors: errors}}} when errors != [] ->
        {:error, {:css_parse_failed, errors}}

      {:parse, {:ok, %{ast: nil}}} ->
        {:error, :css_parse_failed}

      {:parse, {:error, reason}} ->
        {:error, {:css_parse_failed, reason}}

      {:print, {:ok, %{errors: errors}}} when errors != [] ->
        {:error, {:css_print_failed, errors}}

      {:print, {:error, reason}} ->
        {:error, {:css_print_failed, reason}}

      other ->
        {:error, {:css_transform_failed, other}}
    end
  end

  @doc "Walk CSS URL nodes with accumulator state."
  @spec postwalk_urls(term(), term(), (String.t(), map(), term() -> {map(), term()})) ::
          {term(), term()}
  def postwalk_urls(ast, acc, fun) do
    Vize.CSS.postwalk(ast, acc, fn
      %{"url" => url} = node, acc when is_binary(url) -> fun.(url, node, acc)
      node, acc -> {node, acc}
    end)
  end

  @doc "Walk CSS URL nodes without accumulator state."
  @spec postwalk_urls(term(), (String.t(), map() -> map())) :: term()
  def postwalk_urls(ast, fun) do
    Vize.CSS.postwalk(ast, fn
      %{"url" => url} = node when is_binary(url) -> fun.(url, node)
      node -> node
    end)
  end
end
