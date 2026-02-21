defmodule PhoenixDuskmoon.Component.Action.Link do
  @moduledoc """
  Duskmoon UI Link Component

  """
  use Phoenix.Component

  @doc """
  Generates a link for live and href navigation.

  Supports LiveView navigation (`:navigate`, `:patch`) and standard HTTP links (`:href`).

  ## Examples
  ```heex
  <.dm_link href="/">Regular anchor link</.dm_link>
  ```
  ```heex
  <.dm_link navigate={Routes.page_path(@socket, :index)} class="underline">home</.dm_link>
  ```
  ```heex
  <.dm_link navigate={Routes.live_path(@socket, MyLive, dir: :asc)} replace={false}>
    Sort By Price
  </.dm_link>
  ```
  ```heex
  <.dm_link patch={Routes.page_path(@socket, :index, :details)}>view details</.dm_link>
  ```
  ```heex
  <.dm_link href={URI.parse("https://elixir-lang.org")}>hello</.dm_link>
  ```
  ```heex
  <.dm_link href="/the_world" method={:delete} data-confirm="Really?">delete</.dm_link>
  ```
  ## JavaScript dependency
  In order to support links where `:method` is not `:get` or use the above data attributes,
  `Phoenix.HTML` relies on JavaScript. You can load `priv/static/phoenix_html.js` into your
  build tool.
  ### Data attributes
  Data attributes are added as a keyword list passed to the `data` key. The following data
  attributes are supported:
  * `data-confirm` - shows a confirmation prompt before generating and submitting the form when
  `:method` is not `:get`.
  ### Overriding the default confirm behaviour
  `phoenix_html.js` does trigger a custom event `phoenix.link.click` on the clicked DOM element
  when a click happened. This allows you to intercept the event on its way bubbling up
  to `window` and do your own custom logic to enhance or replace how the `data-confirm`
  attribute is handled. You could for example replace the browsers `confirm()` behavior with
  a custom javascript implementation:
  ```javascript
  // listen on document.body, so it's executed before the default of
  // phoenix_html, which is listening on the window object
  document.body.addEventListener('phoenix.link.click', function (e) {
    // Prevent default implementation
    e.stopPropagation();
    // Introduce alternative implementation
    var message = e.target.getAttribute("data-confirm");
    if(!message){ return true; }
    vex.dialog.confirm({
      message: message,
      callback: function (value) {
        if (value == false) { e.preventDefault(); }
      }
    })
  }, false);
  ```
  Or you could attach your own custom behavior.
  ```javascript
  window.addEventListener('phoenix.link.click', function (e) {
    // Introduce custom behaviour
    var message = e.target.getAttribute("data-prompt");
    var answer = e.target.getAttribute("data-prompt-answer");
    if(message && answer && (answer != window.prompt(message))) {
      e.preventDefault();
    }
  }, false);
  ```
  The latter could also be bound to any `click` event, but this way you can be sure your custom
  code is only executed when the code of `phoenix_html.js` is run.
  ## CSRF Protection
  By default, CSRF tokens are generated through `Plug.CSRFProtection`.
  """
  @doc type: :component
  attr(:id, :any, default: nil, doc: "HTML id attribute")
  attr(:class, :any, default: nil, doc: "additional CSS classes")

  attr(:navigate, :string,
    doc: """
    Navigates from a LiveView to a new LiveView.
    The browser page is kept, but a new LiveView process is mounted and its content on the page
    is reloaded. It is only possible to navigate between LiveViews declared under the same router
    `Phoenix.LiveView.Router.live_session/3`. Otherwise, a full browser redirect is used.
    """
  )

  attr(:patch, :string,
    doc: """
    Patches the current LiveView.
    The `handle_params` callback of the current LiveView will be invoked and the minimum content
    will be sent over the wire, as any other LiveView diff.
    """
  )

  attr(:href, :any,
    doc: """
    Uses traditional browser navigation to the new location.
    This means the whole page is reloaded on the browser.
    """
  )

  attr(:replace, :boolean,
    default: false,
    doc: """
    When using `:patch` or `:navigate`,
    should the browser's history be replaced with `pushState`?
    """
  )

  attr(:method, :string,
    default: "get",
    doc: """
    The HTTP method to use with the link.
    In case the method is not `get`, the link is generated inside the form which sets the proper
    information. In order to submit the form, JavaScript must be enabled in the browser.
    """
  )

  attr(:csrf_token, :any,
    default: true,
    doc: """
    A boolean or custom token to use for links with an HTTP method other than `get`.
    """
  )

  attr(:rest, :global,
    include: ~w(download hreflang referrerpolicy rel target type disabled),
    doc: """
    Additional HTML attributes added to the `a` tag.
    """
  )

  slot(:inner_block,
    required: true,
    doc: """
    The content rendered inside of the `a` tag.
    """
  )

  def dm_link(%{navigate: to} = assigns) when is_binary(to) do
    ~H"""
    <a
      id={@id}
      class={["transition-opacity hover:opacity-50", @class]}
      href={@navigate}
      data-phx-link="redirect"
      data-phx-link-state={if @replace, do: "replace", else: "push"}
      {@rest}
    >{render_slot(@inner_block)}</a>
    """
  end

  def dm_link(%{patch: to} = assigns) when is_binary(to) do
    ~H"""
    <a
      id={@id}
      class={["transition-opacity hover:opacity-50", @class]}
      href={@patch}
      data-phx-link="patch"
      data-phx-link-state={if @replace, do: "replace", else: "push"}
      {@rest}
    >{render_slot(@inner_block)}</a>
    """
  end

  def dm_link(%{href: href} = assigns) when href != "#" and not is_nil(href) do
    href = Phoenix.LiveView.Utils.valid_destination!(href, "<.dm_link>")
    assigns = assign(assigns, :href, href)

    ~H"""
    <a
      id={@id}
      class={["transition-opacity hover:opacity-50", @class]}
      href={@href}
      data-method={if @method != "get", do: @method}
      data-csrf={if @method != "get", do: csrf_token(@csrf_token, @href)}
      data-to={if @method != "get", do: @href}
      {@rest}
    >{render_slot(@inner_block)}</a>
    """
  end

  def dm_link(%{} = assigns) do
    ~H"""
    <a
      id={@id}
      class={["transition-opacity hover:opacity-50", @class]}
      href="#" {@rest}>{render_slot(@inner_block)}</a>
    """
  end

  defp csrf_token(true, href), do: Plug.CSRFProtection.get_csrf_token_for(href)
  defp csrf_token(false, _href), do: nil
  defp csrf_token(csrf, _href) when is_binary(csrf), do: csrf
end
