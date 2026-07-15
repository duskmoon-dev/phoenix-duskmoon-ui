defmodule PhoenixDuskmoon.Component.DataDisplay.GitRepository do
  @moduledoc """
  Git repository web view components.

  These components are plain Phoenix components for repository overview,
  navigation, trees, blobs, diffs, and clone instructions. They accept already
  loaded Git data and use slots for callers that need to provide Phoenix links
  or custom actions.
  """
  use Phoenix.Component

  import PhoenixDuskmoon.Component.Icon.Icons

  @doc """
  Renders a repository header with identity, visibility, default ref, metadata,
  description, and actions.

  ## Examples

      <.dm_git_repository_header owner="duskmoon-dev" name="phoenix-duskmoon-ui" visibility="public">
        <:meta>Updated 2 minutes ago</:meta>
        <:action><.dm_link href="/settings">Settings</.dm_link></:action>
      </.dm_git_repository_header>

  """
  @doc type: :component
  attr(:id, :any, default: nil, doc: "HTML id attribute")
  attr(:class, :any, default: nil, doc: "additional CSS classes")
  attr(:owner, :string, default: nil, doc: "repository owner or namespace")
  attr(:name, :string, required: true, doc: "repository name")
  attr(:visibility, :string, default: nil, doc: "repository visibility label")
  attr(:default_ref, :string, default: nil, doc: "default branch or ref name")
  attr(:description, :string, default: nil, doc: "repository description")
  attr(:rest, :global)

  slot(:meta, doc: "metadata items displayed below the title") do
    attr(:icon, :string, doc: "Material Design icon name")
    attr(:class, :any, doc: "metadata item CSS classes")
  end

  slot(:action, doc: "header action controls") do
    attr(:class, :any, doc: "action wrapper CSS classes")
  end

  def dm_git_repository_header(assigns) do
    ~H"""
    <section
      id={@id}
      class={[
        "rounded-lg border border-surface-container-high bg-surface-container-low p-4",
        @class
      ]}
      {@rest}
    >
      <div class="flex flex-col gap-4 md:flex-row md:items-start md:justify-between">
        <div class="min-w-0 space-y-2">
          <div class="flex min-w-0 flex-wrap items-center gap-2">
            <.dm_mdi name="source-repository" class="h-5 w-5 shrink-0 text-on-surface-variant" />
            <h1 class="min-w-0 break-all text-xl font-semibold leading-7 text-on-surface">
              <span :if={@owner not in [nil, ""]} class="font-normal text-on-surface-variant">
                {@owner}/
              </span>{@name}
            </h1>
            <span
              :if={@visibility not in [nil, ""]}
              class={[
                "inline-flex shrink-0 items-center rounded-full border px-2 py-0.5 text-xs font-medium",
                visibility_class(@visibility)
              ]}
            >
              {@visibility}
            </span>
            <span
              :if={@default_ref not in [nil, ""]}
              class="inline-flex min-w-0 items-center gap-1 rounded-md border border-surface-container-high px-2 py-0.5 text-xs text-on-surface-variant"
            >
              <.dm_mdi name="source-branch" class="h-3.5 w-3.5 shrink-0" />
              <span class="min-w-0 break-all">{@default_ref}</span>
            </span>
          </div>
          <p
            :if={@description not in [nil, ""]}
            class="max-w-5xl break-words text-sm leading-6 text-on-surface-variant"
          >
            {@description}
          </p>
          <div :if={@meta != []} class="flex flex-wrap items-center gap-x-4 gap-y-2 text-sm text-on-surface-variant">
            <span :for={item <- @meta} class={["inline-flex min-w-0 items-center gap-1.5", item[:class]]}>
              <.dm_mdi :if={item[:icon]} name={item[:icon]} class="h-4 w-4 shrink-0" />
              <span class="min-w-0 break-words">{render_slot(item)}</span>
            </span>
          </div>
        </div>
        <div :if={@action != []} class="flex shrink-0 flex-wrap items-center gap-2 md:justify-end">
          <span :for={action <- @action} class={action[:class]}>
            {render_slot(action)}
          </span>
        </div>
      </div>
    </section>
    """
  end

  @doc """
  Renders repository route navigation for server-rendered pages.

  Items accept `href`, `navigate`, or `patch`, so the caller can use normal
  Phoenix route values without a client-side tab panel.
  """
  @doc type: :component
  attr(:id, :any, default: nil, doc: "HTML id attribute")
  attr(:class, :any, default: nil, doc: "additional CSS classes")
  attr(:label, :string, default: "Repository navigation", doc: "navigation aria-label")
  attr(:rest, :global)

  slot(:item, required: true, doc: "repository navigation items") do
    attr(:label, :string, doc: "item label when no slot content is provided")
    attr(:href, :any, doc: "regular browser href")
    attr(:navigate, :string, doc: "LiveView navigate destination")
    attr(:patch, :string, doc: "LiveView patch destination")
    attr(:replace, :boolean, doc: "replace browser history for LiveView links")
    attr(:active, :boolean, doc: "mark item as current page")
    attr(:icon, :string, doc: "Material Design icon name")
    attr(:count, :any, doc: "optional count badge")
    attr(:class, :any, doc: "item CSS classes")
  end

  def dm_git_repository_nav(assigns) do
    ~H"""
    <nav id={@id} class={["border-b border-surface-container-high", @class]} aria-label={@label} {@rest}>
      <ul role="list" class="flex min-w-0 gap-1 overflow-x-auto">
        <li :for={item <- @item} class="shrink-0">
          <a
            href={link_href(item)}
            data-phx-link={link_kind(item)}
            data-phx-link-state={link_state(item)}
            class={[
              "inline-flex h-10 items-center gap-2 border-b-2 px-3 text-sm font-medium transition-colors",
              item[:active] && "border-primary text-primary",
              !item[:active] && "border-transparent text-on-surface-variant hover:text-on-surface",
              item[:class]
            ]}
            aria-current={item[:active] && "page"}
          >
            <.dm_mdi :if={item[:icon]} name={item[:icon]} class="h-4 w-4 shrink-0" />
            <span class="whitespace-nowrap">
              <%= if item[:inner_block] do %>
                {render_slot(item)}
              <% else %>
                {item[:label]}
              <% end %>
            </span>
            <span
              :if={item[:count] not in [nil, ""]}
              class="rounded-full bg-surface-container-high px-1.5 py-0.5 text-xs text-on-surface-variant"
            >
              {item[:count]}
            </span>
          </a>
        </li>
      </ul>
    </nav>
    """
  end

  @doc """
  Renders a dense repository file tree.

  Each row can be a folder, file, submodule, symlink, or any custom kind. Rows
  accept `href`, `navigate`, or `patch` for server-rendered repository routes.
  """
  @doc type: :component
  attr(:id, :any, default: nil, doc: "HTML id attribute")
  attr(:class, :any, default: nil, doc: "additional CSS classes")
  attr(:label, :string, default: "Repository files", doc: "file tree aria-label")

  attr(:empty_message, :string,
    default: "This repository is empty.",
    doc: "message for empty trees"
  )

  attr(:rest, :global)

  slot(:row, doc: "file tree rows") do
    attr(:kind, :any, doc: "entry kind: folder, file, submodule, symlink, or custom")
    attr(:name, :string, doc: "entry display name")
    attr(:path, :string, doc: "entry path or secondary metadata")
    attr(:meta, :string, doc: "right-side metadata such as size, mode, or object id")
    attr(:href, :any, doc: "regular browser href")
    attr(:navigate, :string, doc: "LiveView navigate destination")
    attr(:patch, :string, doc: "LiveView patch destination")
    attr(:replace, :boolean, doc: "replace browser history for LiveView links")
    attr(:active, :boolean, doc: "mark item as selected")
    attr(:class, :any, doc: "row CSS classes")
    attr(:aria_label, :string, doc: "custom row aria-label")
  end

  def dm_git_file_tree(assigns) do
    ~H"""
    <section
      id={@id}
      class={[
        "overflow-hidden rounded-lg border border-surface-container-high bg-surface-container-low",
        @class
      ]}
      aria-label={@label}
      {@rest}
    >
      <ul :if={@row != []} role="list" class="divide-y divide-surface-container-high">
        <li :for={row <- @row}>
          <.git_tree_entry row={row} />
        </li>
      </ul>
      <div :if={@row == []} class="px-4 py-8 text-center text-sm text-on-surface-variant">
        {@empty_message}
      </div>
    </section>
    """
  end

  attr(:row, :map, required: true)

  defp git_tree_entry(assigns) do
    ~H"""
    <a
      :if={has_link?(@row)}
      href={link_href(@row)}
      data-phx-link={link_kind(@row)}
      data-phx-link-state={link_state(@row)}
      class={tree_row_class(@row)}
      aria-current={@row[:active] && "true"}
      aria-label={@row[:aria_label] || tree_row_label(@row)}
    >
      <.git_tree_entry_content row={@row} />
    </a>
    <div
      :if={!has_link?(@row)}
      class={tree_row_class(@row)}
      aria-current={@row[:active] && "true"}
      aria-label={@row[:aria_label] || tree_row_label(@row)}
    >
      <.git_tree_entry_content row={@row} />
    </div>
    """
  end

  attr(:row, :map, required: true)

  defp git_tree_entry_content(assigns) do
    ~H"""
    <.dm_mdi name={tree_icon(@row[:kind])} class={["h-5 w-5 shrink-0", tree_icon_class(@row[:kind])]} />
    <span class="min-w-0 flex-1">
      <span class="block min-w-0 break-all font-medium text-on-surface">
        {@row[:name] || render_slot(@row)}
      </span>
      <span :if={@row[:path] not in [nil, ""]} class="block min-w-0 break-all text-xs text-on-surface-variant">
        {@row[:path]}
      </span>
    </span>
    <span :if={@row[:meta] not in [nil, ""]} class="shrink-0 text-xs text-on-surface-variant">
      {@row[:meta]}
    </span>
    """
  end

  @doc """
  Renders a read-only repository blob panel.

  Supports raw/copy action affordances plus truncated, binary, and non-UTF-8
  states.
  """
  @doc type: :component
  attr(:id, :any, default: nil, doc: "HTML id attribute")
  attr(:class, :any, default: nil, doc: "additional CSS classes")
  attr(:filename, :string, required: true, doc: "blob filename")
  attr(:size, :string, default: nil, doc: "human-readable blob size")
  attr(:language, :string, default: nil, doc: "syntax language hint")
  attr(:content, :string, default: "", doc: "blob text content")
  attr(:raw_href, :any, default: nil, doc: "raw file URL")
  attr(:truncated, :boolean, default: false, doc: "mark content as truncated")
  attr(:binary, :boolean, default: false, doc: "mark blob as binary")
  attr(:non_utf8, :boolean, default: false, doc: "mark blob as non-UTF-8 text")
  attr(:copy_label, :string, default: "Copy file contents", doc: "copy button aria-label")
  attr(:raw_label, :string, default: "View raw file", doc: "raw link aria-label")
  attr(:rest, :global)

  slot(:action, doc: "additional blob actions") do
    attr(:class, :any, doc: "action wrapper CSS classes")
  end

  def dm_git_blob_viewer(assigns) do
    ~H"""
    <section
      id={@id}
      class={[
        "overflow-hidden rounded-lg border border-surface-container-high bg-surface-container-low",
        @class
      ]}
      {@rest}
    >
      <div class="flex flex-col gap-3 border-b border-surface-container-high px-4 py-3 md:flex-row md:items-center md:justify-between">
        <div class="min-w-0">
          <h2 class="min-w-0 break-all text-sm font-semibold text-on-surface">{@filename}</h2>
          <p :if={@size not in [nil, ""]} class="text-xs text-on-surface-variant">{@size}</p>
        </div>
        <div class="flex shrink-0 flex-wrap items-center gap-2">
          <a
            :if={@raw_href}
            href={@raw_href}
            class="btn btn-sm"
            aria-label={@raw_label}
          >
            Raw
          </a>
          <.git_copy_button
            :if={!@binary && !@non_utf8}
            label={@copy_label}
            value={@content}
          />
          <span :for={action <- @action} class={action[:class]}>
            {render_slot(action)}
          </span>
        </div>
      </div>
      <p :if={@truncated} class="border-b border-warning px-4 py-2 text-sm text-warning">
        This file is truncated.
      </p>
      <p :if={@binary} class="px-4 py-8 text-center text-sm text-on-surface-variant">
        Binary file not shown.
      </p>
      <p :if={!@binary && @non_utf8} class="px-4 py-8 text-center text-sm text-on-surface-variant">
        Non-UTF-8 file not shown.
      </p>
      <pre
        :if={!@binary && !@non_utf8}
        class="overflow-x-auto p-4 text-sm leading-6"
        data-language={@language}
      ><code class="block min-w-max whitespace-pre font-mono">{@content}</code></pre>
    </section>
    """
  end

  @doc """
  Renders commit metadata and a unified diff presentation.
  """
  @doc type: :component
  attr(:id, :any, default: nil, doc: "HTML id attribute")
  attr(:class, :any, default: nil, doc: "additional CSS classes")
  attr(:title, :string, required: true, doc: "commit title")
  attr(:sha, :string, default: nil, doc: "commit SHA")
  attr(:author, :string, default: nil, doc: "commit author")
  attr(:committed_at, :string, default: nil, doc: "commit timestamp")
  attr(:message, :string, default: nil, doc: "commit body")
  attr(:changed_files, :integer, default: nil, doc: "changed file count")
  attr(:additions, :integer, default: nil, doc: "total added lines")
  attr(:deletions, :integer, default: nil, doc: "total deleted lines")
  attr(:rest, :global)

  slot(:file, doc: "changed file diff sections") do
    attr(:path, :string, doc: "changed file path")
    attr(:status, :string, doc: "file status label")
    attr(:additions, :integer, doc: "file added line count")
    attr(:deletions, :integer, doc: "file deleted line count")
    attr(:binary, :boolean, doc: "mark file diff as binary")
    attr(:truncated, :boolean, doc: "mark file diff as truncated")
    attr(:lines, :list, doc: "diff line maps with type, old_line, new_line, and content")
    attr(:class, :any, doc: "file section CSS classes")
  end

  def dm_git_commit_diff(assigns) do
    ~H"""
    <section
      id={@id}
      class={[
        "overflow-hidden rounded-lg border border-surface-container-high bg-surface-container-low",
        @class
      ]}
      {@rest}
    >
      <header class="space-y-3 border-b border-surface-container-high px-4 py-3">
        <div class="flex flex-col gap-2 md:flex-row md:items-start md:justify-between">
          <div class="min-w-0">
            <h2 class="break-words text-base font-semibold leading-6 text-on-surface">{@title}</h2>
            <p :if={@message not in [nil, ""]} class="mt-1 whitespace-pre-wrap break-words text-sm text-on-surface-variant">
              {@message}
            </p>
          </div>
          <code :if={@sha not in [nil, ""]} class="shrink-0 rounded bg-surface-container-high px-2 py-1 font-mono text-xs text-on-surface-variant">
            {short_sha(@sha)}
          </code>
        </div>
        <div class="flex flex-wrap items-center gap-x-4 gap-y-1 text-sm text-on-surface-variant">
          <span :if={@author not in [nil, ""]} class="inline-flex items-center gap-1">
            <.dm_mdi name="account" class="h-4 w-4" /> {@author}
          </span>
          <span :if={@committed_at not in [nil, ""]} class="inline-flex items-center gap-1">
            <.dm_mdi name="clock-outline" class="h-4 w-4" /> {@committed_at}
          </span>
          <span :if={has_stats?(@changed_files, @additions, @deletions)} class="inline-flex items-center gap-2">
            <span :if={@changed_files}>{changed_files_label(@changed_files)}</span>
            <span :if={@additions} class="text-success">+{@additions}</span>
            <span :if={@deletions} class="text-error">-{@deletions}</span>
          </span>
        </div>
      </header>
      <div :if={@file != []} class="divide-y divide-surface-container-high">
        <section :for={file <- @file} class={["bg-surface", file[:class]]}>
          <header class="flex flex-col gap-2 bg-surface-container px-4 py-2 text-sm md:flex-row md:items-center md:justify-between">
            <div class="flex min-w-0 items-center gap-2">
              <span class="rounded border border-surface-container-high px-1.5 py-0.5 text-xs uppercase text-on-surface-variant">
                {file[:status] || "modified"}
              </span>
              <span class="min-w-0 break-all font-medium text-on-surface">{file[:path]}</span>
            </div>
            <span class="shrink-0 text-xs">
              <span :if={file[:additions]} class="text-success">+{file[:additions]}</span>
              <span :if={file[:deletions]} class="ml-2 text-error">-{file[:deletions]}</span>
            </span>
          </header>
          <p :if={file[:binary]} class="px-4 py-6 text-center text-sm text-on-surface-variant">
            Binary file changed.
          </p>
          <p :if={file[:truncated]} class="border-b border-warning px-4 py-2 text-sm text-warning">
            Diff truncated.
          </p>
          <div :if={!file[:binary] && file_lines(file) != []} class="overflow-x-auto font-mono text-sm leading-6">
            <div
              :for={line <- file_lines(file)}
              class={[
                "grid min-w-max grid-cols-[4rem_4rem_1.5rem_1fr]",
                diff_line_class(line[:type])
              ]}
            >
              <span class="select-none px-2 text-right text-on-surface-variant">{line[:old_line]}</span>
              <span class="select-none px-2 text-right text-on-surface-variant">{line[:new_line]}</span>
              <span class="select-none px-1 text-center">{diff_marker(line[:type])}</span>
              <code class="whitespace-pre pr-4">{line[:content]}</code>
            </div>
          </div>
          <div :if={!file[:binary] && file_lines(file) == [] && file[:inner_block]} class="overflow-x-auto">
            {render_slot(file)}
          </div>
        </section>
      </div>
      <div :if={@file == []} class="px-4 py-8 text-center text-sm text-on-surface-variant">
        No file changes.
      </div>
    </section>
    """
  end

  @doc """
  Renders clone URLs and copyable command snippets.

  Use command slots for empty repository setup instructions such as adding a
  remote and pushing the first branch.
  """
  @doc type: :component
  attr(:id, :any, default: nil, doc: "HTML id attribute")
  attr(:class, :any, default: nil, doc: "additional CSS classes")
  attr(:title, :string, default: "Clone repository", doc: "panel title")
  attr(:clone_url, :string, default: nil, doc: "default HTTPS clone URL")
  attr(:ssh_url, :string, default: nil, doc: "SSH clone URL")
  attr(:empty, :boolean, default: false, doc: "render empty repository defaults")
  attr(:rest, :global)

  slot(:url, doc: "clone URL rows") do
    attr(:label, :string, doc: "URL label")
    attr(:value, :string, doc: "clone URL value")
    attr(:active, :boolean, doc: "mark URL as active")
    attr(:class, :any, doc: "URL row CSS classes")
  end

  slot(:command, doc: "command rows") do
    attr(:label, :string, doc: "command label")
    attr(:value, :string, doc: "command value")
    attr(:class, :any, doc: "command row CSS classes")
  end

  def dm_git_clone_box(assigns) do
    assigns =
      assigns
      |> assign(:default_urls, default_clone_urls(assigns))
      |> assign(:default_commands, default_clone_commands(assigns))

    ~H"""
    <section
      id={@id}
      class={[
        "space-y-4 rounded-lg border border-surface-container-high bg-surface-container-low p-4",
        @class
      ]}
      {@rest}
    >
      <h2 class="text-sm font-semibold text-on-surface">{@title}</h2>
      <div :if={@url != [] || @default_urls != []} class="space-y-2">
        <div :for={url <- @url} class={["flex min-w-0 items-center gap-2", url[:class]]}>
          <span class="w-16 shrink-0 text-xs font-medium uppercase text-on-surface-variant">
            {url[:label] || "URL"}
          </span>
          <code class="min-w-0 flex-1 overflow-x-auto rounded bg-surface-container px-2 py-1 font-mono text-sm">
            {url[:value]}
          </code>
          <.git_copy_button label={"Copy #{url[:label] || "URL"}"} value={url[:value]} />
        </div>
        <div :for={url <- @default_urls} class="flex min-w-0 items-center gap-2">
          <span class="w-16 shrink-0 text-xs font-medium uppercase text-on-surface-variant">
            {url.label}
          </span>
          <code class="min-w-0 flex-1 overflow-x-auto rounded bg-surface-container px-2 py-1 font-mono text-sm">
            {url.value}
          </code>
          <.git_copy_button label={"Copy #{url.label}"} value={url.value} />
        </div>
      </div>
      <div :if={@command != [] || @default_commands != []} class="space-y-2">
        <div :for={command <- @command} class={command[:class]}>
          <div class="mb-1 text-xs font-medium uppercase text-on-surface-variant">
            {command[:label] || "Command"}
          </div>
          <div class="flex min-w-0 items-start gap-2">
            <pre class="min-w-0 flex-1 overflow-x-auto rounded bg-surface-container p-3 text-sm"><code class="font-mono">{command[:value]}</code></pre>
            <.git_copy_button
              label={"Copy #{command[:label] || "command"}"}
              value={command[:value]}
            />
          </div>
        </div>
        <div :for={command <- @default_commands}>
          <div class="mb-1 text-xs font-medium uppercase text-on-surface-variant">
            {command.label}
          </div>
          <div class="flex min-w-0 items-start gap-2">
            <pre class="min-w-0 flex-1 overflow-x-auto rounded bg-surface-container p-3 text-sm"><code class="font-mono">{command.value}</code></pre>
            <.git_copy_button label={"Copy #{command.label}"} value={command.value} />
          </div>
        </div>
      </div>
    </section>
    """
  end

  attr(:label, :string, required: true)
  attr(:value, :string, required: true)

  defp git_copy_button(assigns) do
    ~H"""
    <button type="button" class="btn btn-sm" aria-label={@label} data-copy-value={@value}>
      <span data-copy-label>Copy</span>
    </button>
    <span
      class="sr-only"
      role="status"
      aria-live="polite"
      aria-atomic="true"
      data-copy-status
    >
    </span>
    """
  end

  defp visibility_class("private"), do: "border-warning text-warning"
  defp visibility_class("internal"), do: "border-info text-info"
  defp visibility_class(_visibility), do: "border-surface-container-high text-on-surface-variant"

  defp link_href(item), do: item[:href] || item[:navigate] || item[:patch] || "#"

  defp link_kind(item) do
    cond do
      item[:navigate] not in [nil, ""] -> "redirect"
      item[:patch] not in [nil, ""] -> "patch"
      true -> nil
    end
  end

  defp link_state(item) do
    if link_kind(item), do: if(item[:replace], do: "replace", else: "push")
  end

  defp has_link?(item), do: link_href(item) != "#"

  defp tree_row_class(row) do
    [
      "flex min-w-0 items-center gap-3 px-4 py-2 text-sm transition-colors",
      has_link?(row) && "hover:bg-surface-container",
      row[:active] && "bg-surface-container text-primary",
      row[:class]
    ]
  end

  defp tree_row_label(row) do
    [row[:kind] || "file", row[:name] || "entry"]
    |> Enum.map_join(" ", &to_string/1)
  end

  defp tree_icon(kind) when kind in [:folder, "folder", :dir, "dir"], do: "folder"
  defp tree_icon(kind) when kind in [:submodule, "submodule"], do: "source-repository"
  defp tree_icon(kind) when kind in [:symlink, "symlink"], do: "file-link-outline"
  defp tree_icon(_kind), do: "file-document-outline"

  defp tree_icon_class(kind) when kind in [:folder, "folder", :dir, "dir"], do: "text-warning"
  defp tree_icon_class(kind) when kind in [:submodule, "submodule"], do: "text-info"
  defp tree_icon_class(_kind), do: "text-on-surface-variant"

  defp short_sha(sha) when is_binary(sha) and byte_size(sha) > 12, do: binary_part(sha, 0, 12)
  defp short_sha(sha), do: sha

  defp has_stats?(changed_files, additions, deletions) do
    changed_files not in [nil, ""] || additions not in [nil, ""] || deletions not in [nil, ""]
  end

  defp changed_files_label(1), do: "1 file"
  defp changed_files_label(count), do: "#{count} files"

  defp file_lines(file), do: file[:lines] || []

  defp diff_line_class(type) when type in [:add, "add", :added, "added"],
    do: "bg-success/10 text-success"

  defp diff_line_class(type) when type in [:delete, "delete", :del, "del", :deleted, "deleted"],
    do: "bg-error/10 text-error"

  defp diff_line_class(type) when type in [:hunk, "hunk"], do: "bg-info/10 text-info"
  defp diff_line_class(_type), do: "text-on-surface"

  defp diff_marker(type) when type in [:add, "add", :added, "added"], do: "+"

  defp diff_marker(type) when type in [:delete, "delete", :del, "del", :deleted, "deleted"],
    do: "-"

  defp diff_marker(type) when type in [:hunk, "hunk"], do: "@"
  defp diff_marker(_type), do: " "

  defp default_clone_urls(%{url: [_ | _]}), do: []

  defp default_clone_urls(assigns) do
    [
      clone_url(assigns[:clone_url], "HTTPS"),
      clone_url(assigns[:ssh_url], "SSH")
    ]
    |> Enum.reject(&is_nil/1)
  end

  defp clone_url(nil, _label), do: nil
  defp clone_url("", _label), do: nil
  defp clone_url(value, label), do: %{label: label, value: value}

  defp default_clone_commands(%{command: [_ | _]}), do: []

  defp default_clone_commands(%{clone_url: value, empty: false}) when value not in [nil, ""],
    do: [%{label: "Clone", value: "git clone #{value}"}]

  defp default_clone_commands(%{clone_url: value, empty: true}) when value not in [nil, ""] do
    [
      %{label: "Add remote", value: "git remote add origin #{value}"},
      %{label: "Push", value: "git push -u origin main"}
    ]
  end

  defp default_clone_commands(_assigns), do: []
end
