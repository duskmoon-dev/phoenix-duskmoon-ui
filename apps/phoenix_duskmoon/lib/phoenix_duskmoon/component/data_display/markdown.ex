defmodule PhoenixDuskmoon.Component.DataDisplay.Markdown do
  @moduledoc """
  Duskmoon UI Markdown Component

  Render markdown using `<el-dm-markdown>` custom element from `@duskmoon-dev/el-markdown`.

  Supported markdown features:
    * GitHub Flavored Markdown
    * Syntax highlighting with highlight.js
    * Mermaid diagram rendering (optional)

  Requires `@duskmoon-dev/el-markdown` registered in your project:

  ```js
  import '@duskmoon-dev/el-markdown/register';
  ```

  For server-rendered Markdown, use `dm_markdown_body/1`. It renders Markdown
  with MDEx and applies the design system's `markdown-body` styles without
  requiring a custom element.

  """
  use Phoenix.Component

  @default_markdown_body_plugins [
    MDExGFM,
    PhoenixDuskmoon.Component.DataDisplay.Markdown.FrontMatter,
    PhoenixDuskmoon.Component.DataDisplay.Markdown.ColorChips,
    MDExMermaid
  ]

  @default_markdown_body_options [
    extension: [front_matter_delimiter: "---"],
    render: [hardbreaks: true]
  ]

  @doc """
  Generates `<el-dm-markdown>` custom element to render markdown content.

  ## Examples

      <.dm_markdown class="dark"># Hello</.dm_markdown>
      #=> <el-dm-markdown class="dark"># Hello</el-dm-markdown>

      <.dm_markdown content="# Hello" />
      #=> <el-dm-markdown># Hello</el-dm-markdown>

  """
  @doc type: :component
  attr(:id, :any,
    default: nil,
    doc: """
    html attribute id
    """
  )

  attr(:class, :any,
    default: nil,
    doc: """
    html attribute class
    """
  )

  attr(:debug, :boolean,
    default: false,
    doc: """
    el-dm-markdown attribute, enable debug
    """
  )

  attr(:content, :string,
    default: "",
    doc: """
    markdown content (inline)
    """
  )

  attr(:src, :string,
    default: nil,
    doc: "URL to fetch markdown content from"
  )

  attr(:theme, :string,
    default: nil,
    values: [nil, "github", "atom-one-dark", "atom-one-light", "auto"],
    doc: "Code syntax highlighting theme"
  )

  attr(:no_mermaid, :boolean,
    default: false,
    doc: "Disable mermaid diagram rendering"
  )

  attr(:rest, :global)

  def dm_markdown(assigns) do
    ~H"""
    <el-dm-markdown
      id={@id}
      debug={@debug}
      src={@src}
      theme={@theme}
      no-mermaid={@no_mermaid}
      class={@class}
      {@rest}
    >{@content}</el-dm-markdown>
    """
  end

  @doc """
  Renders Markdown source as server-generated HTML using MDEx.

  GitHub Flavored Markdown, visible YAML front matter, color chips, and Mermaid
  are enabled by default. Three-, four-, six-, and eight-digit hexadecimal,
  RGB, and HSL colors written as inline code render with a color chip.
  YAML-style front matter delimited by `---` renders as a labeled code block,
  and soft line breaks render as `<br>` elements by default. Front matter is
  not parsed into component metadata. Pass a custom list of MDEx-compatible
  plugins through `plugins` to replace the defaults, and pass MDEx document
  options through `options` to override the default document options.

  The default plugins enable raw HTML rendering. Only render trusted Markdown
  source with the default configuration, and only use trusted plugins and
  options. To preserve MDEx's conservative set of safe HTML tags from untrusted
  source, disable Mermaid and enable MDEx sanitization as shown below. Mermaid
  is disabled in this safe configuration because sanitization removes its
  built-in initialization script.

  ## Examples

      <.dm_markdown_body source="# Hello\n\nThis is **Markdown**." />

      <.dm_markdown_body
        id="release-notes"
        class="max-w-none"
        source={@release_notes}
        options={[render: [hardbreaks: false]]}
      />

      <.dm_markdown_body
        source={@external_markdown}
        plugins={[MDExGFM]}
        options={[
          render: [unsafe: true],
          sanitize: MDEx.Document.default_sanitize_options()
        ]}
      />

  """
  @doc type: :component
  attr(:source, :string,
    required: true,
    doc: "Markdown source to render"
  )

  attr(:plugins, :list,
    default: @default_markdown_body_plugins,
    doc: "MDEx-compatible plugins used while rendering; replaces the default list"
  )

  attr(:options, :list,
    default: [],
    doc:
      "MDEx document options merged over the front matter and hard line-break defaults; source and plugins are controlled by their dedicated attributes"
  )

  attr(:id, :any,
    default: nil,
    doc: "HTML attribute id"
  )

  attr(:class, :any,
    default: nil,
    doc: "Additional CSS classes"
  )

  attr(:rest, :global)

  def dm_markdown_body(assigns) do
    caller_options = Keyword.drop(assigns.options, [:document, :markdown, :plugins])

    body =
      MDEx.new(markdown: assigns.source, plugins: assigns.plugins)
      |> MDEx.Document.put_options(@default_markdown_body_options)
      |> MDEx.Document.put_options(caller_options)
      |> MDEx.to_html!()
      |> Phoenix.HTML.raw()

    assigns = assign(assigns, :body, body)

    ~H"""
    <div id={@id} class={["markdown-body" | List.wrap(@class)]} {@rest}>{@body}</div>
    """
  end
end
