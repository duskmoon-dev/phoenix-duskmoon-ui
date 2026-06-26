defmodule NPM.Security.RegistryPolicy do
  @moduledoc """
  Enforces registry origin policy for packuments and tarballs.

  Registry and mirror confusion can move package metadata or tarballs to an
  unexpected host. The default policy allows the configured registry and mirror
  origins, blocks cross-origin redirects, and rejects tarball URLs outside the
  allowlist.
  """

  defmodule Error do
    @moduledoc "Raised when a package URL points at an untrusted registry origin."

    defexception [:url, :allowed]

    @impl true
    def message(%__MODULE__{url: url, allowed: allowed}) do
      "untrusted npm registry URL #{url}. Allowed registry origins: #{Enum.join(allowed, ", ")}."
    end
  end

  @doc "Validate that a URL belongs to an allowed registry origin."
  @spec validate_url!(String.t()) :: :ok
  def validate_url!(url) when is_binary(url) do
    allowed = allowed_origins()

    if origin(url) in allowed do
      :ok
    else
      raise Error, url: url, allowed: allowed
    end
  end

  def validate_url!(_), do: :ok

  @doc "Return normalized allowed registry origins."
  @spec allowed_origins :: [String.t()]
  def allowed_origins do
    NPM.Config.allowed_registries()
    |> Enum.map(&origin/1)
    |> Enum.reject(&is_nil/1)
    |> Enum.uniq()
  end

  @doc "Return the normalized `scheme://host[:port]` origin for a URL."
  @spec origin(String.t()) :: String.t() | nil
  def origin(url) when is_binary(url) do
    uri = URI.parse(url)

    with scheme when scheme in ["http", "https"] <- uri.scheme,
         host when is_binary(host) <- uri.host do
      port = explicit_port(uri)
      "#{scheme}://#{String.downcase(host)}#{port}"
    else
      _ -> nil
    end
  end

  def origin(_), do: nil

  defp explicit_port(%URI{scheme: "http", port: port}) when port in [nil, 80], do: ""
  defp explicit_port(%URI{scheme: "https", port: port}) when port in [nil, 443], do: ""
  defp explicit_port(%URI{port: nil}), do: ""
  defp explicit_port(%URI{port: port}), do: ":#{port}"
end
