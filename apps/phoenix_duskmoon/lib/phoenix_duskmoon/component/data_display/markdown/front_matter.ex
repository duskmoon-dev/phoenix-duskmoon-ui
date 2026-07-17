defmodule PhoenixDuskmoon.Component.DataDisplay.Markdown.FrontMatter do
  @moduledoc """
  MDEx plugin that renders YAML front matter as a labeled code block.

  MDEx parses configured front matter into an `MDEx.FrontMatter` node, which
  its HTML renderer otherwise omits. This plugin preserves the front matter as
  escaped, visible YAML without treating it as component metadata.
  """

  alias MDEx.Document

  @block_style "box-sizing: border-box; margin-block-end: 1rem; border: 1px solid var(--color-outline, #8b949e); border-inline-start: 4px solid var(--color-warning, #f59e0b); border-radius: 0.5rem; overflow: hidden;"
  @header_style "display: flex; align-items: center; padding: 0.5rem 1rem; background-color: var(--color-surface-container-highest, #b8b4b0); border-bottom: 1px solid var(--color-outline, #8b949e);"
  @language_style "color: var(--color-warning, #d97706); font-size: 0.75rem; font-weight: 600; letter-spacing: 0.05em; text-transform: uppercase;"
  @content_style "background-color: #0d1117; overflow-x: auto;"
  @pre_style "margin: 0; padding: 1rem; background: transparent; border-radius: 0; color: #e6edf3; overflow-x: auto;"
  @code_style "background: transparent; padding: 0; color: inherit; font-family: ui-monospace, SFMono-Regular, SF Mono, Menlo, Consolas, Liberation Mono, monospace; font-size: 0.875rem; line-height: 1.6;"

  @doc """
  Attaches the front-matter rendering transformation to an MDEx document.
  """
  @spec attach(Document.t(), keyword()) :: Document.t()
  def attach(document, _options \\ []) do
    Document.append_steps(document, front_matter: &render_front_matter/1)
  end

  defp render_front_matter(document) do
    Document.update_nodes(document, MDEx.FrontMatter, fn
      %MDEx.FrontMatter{literal: literal, sourcepos: sourcepos} ->
        front_matter_node(yaml_content(literal), sourcepos)
    end)
  end

  defp yaml_content(literal) do
    [_opening | lines] = String.split(literal, ~r/\r\n|\n|\r/, trim: false)

    [_closing | reversed_content] =
      lines
      |> Enum.reverse()
      |> Enum.drop_while(&(&1 == ""))

    reversed_content
    |> Enum.reverse()
    |> Enum.join("\n")
  end

  defp front_matter_node(yaml, sourcepos) do
    escaped_yaml =
      yaml
      |> Phoenix.HTML.html_escape()
      |> Phoenix.HTML.safe_to_string()

    %MDEx.Raw{
      literal: """
      <div class="markdown-front-matter code-block" data-language="yaml" style="#{@block_style}">
        <div class="code-header" style="#{@header_style}"><span class="code-language" style="#{@language_style}">YAML</span></div>
        <div class="code-content" style="#{@content_style}"><pre lang="yaml" style="#{@pre_style}"><code class="language-yaml" style="#{@code_style}">#{escaped_yaml}</code></pre></div>
      </div>
      """,
      sourcepos: sourcepos
    }
  end
end
