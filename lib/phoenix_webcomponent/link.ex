defmodule Phoenix.WebComponent.Link do
  @moduledoc """
  Conveniences for working with links and URLs in HTML.
  """

  import Phoenix.WebComponent.Tag

  @doc """
  Generates a link to the given URL.

  ## Examples

      link("hello", to: "/world")
      #=> <a href="/world">hello</a>

      link("hello", to: URI.parse("https://elixir-lang.org"))
      #=> <a href="https://elixir-lang.org">hello</a>

      link("<hello>", to: "/world")
      #=> <a href="/world">&lt;hello&gt;</a>

      link("<hello>", to: "/world", class: "btn")
      #=> <a class="btn" href="/world">&lt;hello&gt;</a>

      link("delete", to: "/the_world", data: [confirm: "Really?"])
      #=> <a data-confirm="Really?" href="/the_world">delete</a>

      # If you supply a method other than `:get`:
      link("delete", to: "/everything", method: :delete)
      #=> <a href="/everything" data-csrf="csrf_token" data-method="delete" data-to="/everything">delete</a>

      # You can use a `do ... end` block too:
      link to: "/hello" do
        "world"
      end
      #=> <a href="/hello">world<a>

  ## Options

    * `:to` - the page to link to. This option is required

    * `:method` - the method to use with the link. In case the
      method is not `:get`, the link is generated inside the form
      which sets the proper information. In order to submit the
      form, JavaScript must be enabled

    * `:csrf_token` - a custom token to use for links with a method
      other than `:get`.

  All other options are forwarded to the underlying `<a>` tag.

  ## Data attributes

  Data attributes are added as a keyword list passed to the `data` key.
  The following data attributes are supported:

    * `data-confirm` - shows a confirmation prompt before
      generating and submitting the form when `:method`
      is not `:get`.

  ## CSRF Protection

  By default, CSRF tokens are generated through `Plug.CSRFProtection`.
  """
  def wc_link(text, opts)

  def wc_link(opts, do: contents) when is_list(opts) do
    wc_link(contents, opts)
  end

  def wc_link(_text, opts) when not is_list(opts) do
    raise ArgumentError, "link/2 requires a keyword list as second argument"
  end

  def wc_link(text, opts) do
    {to, opts} = pop_required_option!(opts, :to, "expected non-nil value for :to in link/2")
    {method, opts} = Keyword.pop(opts, :method, :get)

    if method == :get do
      # Call link attributes to validate `to`
      [data: data] = Phoenix.WebComponent.link_attributes(to, [])
      content_tag(:a, text, [href: data[:to]] ++ Keyword.delete(opts, :csrf_token))
    else
      {csrf_token, opts} = Keyword.pop(opts, :csrf_token, true)
      opts = Keyword.put_new(opts, :rel, "nofollow")

      [data: data] =
        Phoenix.WebComponent.link_attributes(to, method: method, csrf_token: csrf_token)

      content_tag(:a, text, [data: data, href: data[:to]] ++ opts)
    end
  end

  @doc """
  Generates a button tag that uses the Javascript function handleClick()
  (see phoenix_html.js) to submit the form data.

  Useful to ensure that links that change data are not triggered by
  search engines and other spidering software.

  ## Examples

      button("hello", to: "/world")
      #=> <button class="button" data-csrf="csrf_token" data-method="post" data-to="/world">hello</button>

      button("hello", to: "/world", method: :get, class: "btn")
      #=> <button class="btn" data-method="get" data-to="/world">hello</button>

  ## Options

    * `:to` - the page to link to. This option is required

    * `:method` - the method to use with the button. Defaults to :post.

  All other options are forwarded to the underlying button input.

  When the `:method` is set to `:get` and the `:to` URL contains query
  parameters the generated form element will strip the parameters in accordance
  with the [W3C](https://www.w3.org/TR/html401/interact/forms.html#h-17.13.3.4)
  form specification.

  ## Data attributes

  Data attributes are added as a keyword list passed to the
  `data` key. The following data attributes are supported:

    * `data-confirm` - shows a confirmation prompt before generating and
      submitting the form.
  """
  def wc_button(opts, do: contents) do
    wc_button(contents, opts)
  end

  def wc_button(text, opts) do
    {to, opts} = pop_required_option!(opts, :to, "option :to is required in button/2")

    {link_opts, opts} =
      opts
      |> Keyword.put_new(:method, :post)
      |> Keyword.split([:method, :csrf_token])

    link_attributes = Phoenix.WebComponent.link_attributes(to, link_opts)
    content_tag(:"mwc-button", text, link_attributes ++ opts)
  end

  defp pop_required_option!(opts, key, error_message) do
    {value, opts} = Keyword.pop(opts, key)

    unless value do
      raise ArgumentError, error_message
    end

    {value, opts}
  end
end
