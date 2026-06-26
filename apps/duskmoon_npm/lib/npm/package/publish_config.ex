defmodule NPM.Package.PublishConfig do
  @moduledoc """
  Parses the `publishConfig` field from package.json.

  Controls behavior when `npm publish` is called — registry,
  access level, tag, etc.
  """

  @doc """
  Extracts publishConfig from package.json data.
  """
  @spec extract(map()) :: map()
  def extract(%{"publishConfig" => config}) when is_map(config), do: config
  def extract(_), do: %{}

  @doc """
  Returns the publish registry URL.
  """
  @spec registry(map()) :: String.t() | nil
  def registry(data), do: extract(data) |> Map.get("registry")

  @doc """
  Returns the access level (public or restricted).
  """
  @spec access(map()) :: String.t()
  def access(data) do
    case extract(data) |> Map.get("access") do
      "public" -> "public"
      "restricted" -> "restricted"
      _ -> default_access(data)
    end
  end

  @doc """
  Returns the publish tag (default: "latest").
  """
  @spec tag(map()) :: String.t()
  def tag(data), do: extract(data) |> Map.get("tag", "latest")

  @doc """
  Checks if the package would be published as public.
  """
  @spec public?(map()) :: boolean()
  def public?(data), do: access(data) == "public"

  @doc """
  Checks if publishConfig is set.
  """
  @spec configured?(map()) :: boolean()
  def configured?(data), do: extract(data) != %{}

  @doc """
  Formats publishConfig for display.
  """
  @spec format(map()) :: String.t()
  def format(data) do
    config = extract(data)

    if config == %{} do
      "No publish configuration."
    else
      config
      |> Enum.map_join(", ", fn {k, v} -> "#{k}: #{v}" end)
      |> then(&"Publish config: #{&1}")
    end
  end

  defp default_access(%{"name" => name}) when is_binary(name) do
    if NPM.Scope.scoped?(name), do: "restricted", else: "public"
  end

  defp default_access(_), do: "public"
end
