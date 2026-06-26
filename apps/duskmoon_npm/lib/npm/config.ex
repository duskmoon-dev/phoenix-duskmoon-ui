defmodule NPM.Config do
  @moduledoc """
  Read npm configuration from `.npmrc` files.

  Checks for `.npmrc` in the project directory and home directory.
  Environment variables take precedence over file configuration.
  """

  @doc """
  Read the effective registry URL.

  Priority: `NPM_REGISTRY` env var > `config :duskmoon_npm, :registry` > project `.npmrc` > home `.npmrc` > default.
  """
  @spec registry :: String.t()
  def registry do
    (System.get_env("NPM_REGISTRY") ||
       Application.get_env(:duskmoon_npm, :registry) ||
       read_npmrc_value("registry") ||
       "https://registry.npmjs.org")
    |> normalize_registry_url()
  end

  @doc """
  Read the auth token.

  Priority: `NPM_TOKEN` env var > `config :duskmoon_npm, :token` > project `.npmrc` > home `.npmrc`.
  """
  @spec auth_token :: String.t() | nil
  def auth_token do
    System.get_env("NPM_TOKEN") ||
      Application.get_env(:duskmoon_npm, :token) ||
      read_npmrc_value("//registry.npmjs.org/:_authToken")
  end

  @doc "Read the global package cache directory."
  @spec cache_dir :: String.t()
  def cache_dir do
    System.get_env("NPM_EX_CACHE_DIR") ||
      Application.get_env(:duskmoon_npm, :cache_dir) ||
      Path.join(System.user_home!(), ".npm_ex")
  end

  @doc "Read the runtime install directory for `NPM.install/2`."
  @spec install_dir(String.t()) :: String.t()
  def install_dir(id) do
    root =
      System.get_env("NPM_INSTALL_DIR") ||
        Application.get_env(:duskmoon_npm, :install_dir) ||
        Path.join(cache_dir(), "installs")

    Path.join(root, id)
  end

  @doc "Read the configured registry mirror URL."
  @spec mirror_url :: String.t()
  def mirror_url do
    System.get_env("NPM_MIRROR") ||
      Application.get_env(:duskmoon_npm, :mirror) ||
      NPM.Registry.registry_url()
  end

  @doc "Whether transitive git, file, and URL dependencies are blocked."
  @spec block_exotic_subdeps? :: boolean()
  def block_exotic_subdeps? do
    case System.get_env("NPM_EX_BLOCK_EXOTIC_SUBDEPS") do
      nil -> Application.get_env(:duskmoon_npm, :block_exotic_subdeps, true)
      value -> truthy?(value)
    end
  end

  @doc "Allowed direct exotic dependency specs."
  @spec exotic_deps :: [String.t()]
  def exotic_deps do
    env_list("NPM_EX_EXOTIC_DEPS") || Application.get_env(:duskmoon_npm, :exotic_deps, [])
  end

  @doc "Registry origins allowed for packuments and tarballs."
  @spec allowed_registries :: [String.t()]
  def allowed_registries do
    env_list("NPM_EX_ALLOWED_REGISTRIES") ||
      Application.get_env(:duskmoon_npm, :allowed_registries) ||
      [registry(), mirror_url()]
  end

  @doc "Whether HTTP redirects to different registry origins are allowed."
  @spec allow_registry_redirects? :: boolean()
  def allow_registry_redirects? do
    case System.get_env("NPM_EX_ALLOW_REGISTRY_REDIRECTS") do
      nil -> Application.get_env(:duskmoon_npm, :allow_registry_redirects, false)
      value -> truthy?(value)
    end
  end

  @doc "Warn when a package was created fewer than this many days ago."
  @spec package_age_warning_days :: non_neg_integer()
  def package_age_warning_days do
    env_integer("NPM_EX_PACKAGE_AGE_WARNING_DAYS") ||
      Application.get_env(:duskmoon_npm, :package_age_warning_days, 7)
  end

  @doc "Warn when a package version was published fewer than this many days ago."
  @spec version_age_warning_days :: non_neg_integer()
  def version_age_warning_days do
    env_integer("NPM_EX_VERSION_AGE_WARNING_DAYS") ||
      Application.get_env(:duskmoon_npm, :version_age_warning_days, 3)
  end

  @doc "Path to an OSV-format database of known malicious package reports."
  @spec compromised_db_path :: String.t()
  def compromised_db_path do
    System.get_env("NPM_EX_COMPROMISED_DB_PATH") ||
      Application.get_env(:duskmoon_npm, :compromised_db_path) ||
      Path.join([cache_dir(), "security", "compromised_packages.json"])
  end

  @doc "Path to the bundled seed database of known malicious package reports."
  @spec bundled_compromised_db_path :: String.t()
  def bundled_compromised_db_path do
    Application.app_dir(:duskmoon_npm, "priv/security/compromised_packages.json")
  end

  @doc "Known-compromised package intelligence sources to use."
  @spec compromised_sources :: [atom()]
  def compromised_sources do
    case env_list("NPM_EX_COMPROMISED_SOURCES") do
      nil -> Application.get_env(:duskmoon_npm, :compromised_sources, [:local])
      sources -> Enum.flat_map(sources, &parse_compromised_source/1)
    end
  end

  @doc "Policy for compromised-package findings in security tasks."
  @spec compromised_policy :: :error | :warn | :off
  def compromised_policy do
    case System.get_env("NPM_EX_COMPROMISED_POLICY") do
      nil -> Application.get_env(:duskmoon_npm, :compromised_policy, :error)
      value -> parse_compromised_policy(value)
    end
  end

  @doc """
  Read a value from `.npmrc` files.

  Checks project-level first, then home-level.
  """
  @spec read_npmrc_value(String.t()) :: String.t() | nil
  def read_npmrc_value(key) do
    read_from_file(".npmrc", key) ||
      read_from_file(Path.join(System.user_home!(), ".npmrc"), key)
  end

  @doc "Parse an `.npmrc` file into a map of key-value pairs."
  @spec parse_npmrc(String.t()) :: %{String.t() => String.t()}
  def parse_npmrc(content) do
    content
    |> String.split("\n")
    |> Enum.reject(&(String.starts_with?(String.trim(&1), "#") or String.trim(&1) == ""))
    |> Enum.flat_map(&parse_line/1)
    |> Map.new()
  end

  @doc """
  Gets a config value with fallback to defaults.
  """
  @spec get(map(), String.t(), term()) :: term()
  def get(config, key, default \\ nil) do
    Map.get(config, key, default)
  end

  @doc """
  Merges multiple config maps (later overrides earlier).
  """
  @spec merge([map()]) :: map()
  def merge(configs) do
    Enum.reduce(configs, %{}, &Map.merge(&2, &1))
  end

  @doc """
  Loads config from all levels: project .npmrc then user .npmrc.
  Project values override user values.
  """
  @spec load(String.t()) :: map()
  def load(project_dir \\ ".") do
    user_config = read_file(Path.join(System.user_home!(), ".npmrc"))
    project_config = read_file(Path.join(project_dir, ".npmrc"))
    merge([user_config, project_config])
  end

  @doc """
  Returns the registry URL for a given scope, or the default.
  """
  @spec scoped_registry(map(), String.t()) :: String.t()
  def scoped_registry(config, scope) do
    key = "#{scope}:registry"
    Map.get(config, key, Map.get(config, "registry", "https://registry.npmjs.org"))
  end

  defp read_file(path) do
    case File.read(path) do
      {:ok, content} -> parse_npmrc(content)
      _ -> %{}
    end
  end

  defp read_from_file(path, key) do
    case File.read(path) do
      {:ok, content} -> parse_npmrc(content) |> Map.get(key)
      {:error, _} -> nil
    end
  end

  defp parse_line(line) do
    case String.split(String.trim(line), "=", parts: 2) do
      [key, value] -> [{String.trim(key), String.trim(value)}]
      _ -> []
    end
  end

  defp normalize_registry_url(url), do: String.trim_trailing(url, "/")

  defp truthy?(value) when is_binary(value) do
    (value |> String.trim() |> String.downcase()) in ~w(1 true yes on)
  end

  defp parse_compromised_source("local"), do: [:local]
  defp parse_compromised_source("osv"), do: [:osv]
  defp parse_compromised_source(_), do: []

  defp parse_compromised_policy(value) when is_binary(value) do
    case value |> String.trim() |> String.downcase() do
      "error" -> :error
      "warn" -> :warn
      "off" -> :off
      _ -> :error
    end
  end

  defp env_list(name) do
    case System.get_env(name) do
      nil -> nil
      value -> value |> String.split(",", trim: true) |> Enum.map(&String.trim/1)
    end
  end

  defp env_integer(name) do
    case System.get_env(name) do
      nil ->
        nil

      value ->
        case Integer.parse(String.trim(value)) do
          {int, ""} when int >= 0 -> int
          _ -> nil
        end
    end
  end
end
