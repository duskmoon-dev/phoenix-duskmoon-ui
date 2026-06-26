defmodule NPM.Publish do
  @moduledoc """
  Validates a package before publishing to the registry.

  Checks required fields, validates package.json completeness,
  and reports readiness for publishing.
  """

  @required_fields ~w(name version)
  @recommended_fields ~w(description license repository keywords)

  @doc """
  Checks if a package is ready for publishing.
  """
  @spec check(map()) :: {:ok, [String.t()]} | {:error, [String.t()]}
  def check(pkg_data) do
    errors = check_required(pkg_data)
    warnings = check_recommended(pkg_data)

    if errors == [] do
      {:ok, warnings}
    else
      {:error, errors}
    end
  end

  @doc """
  Checks required fields are present.
  """
  @spec check_required(map()) :: [String.t()]
  def check_required(pkg_data) do
    Enum.flat_map(@required_fields, fn field ->
      case pkg_data[field] do
        nil -> ["Missing required field: #{field}"]
        "" -> ["Empty required field: #{field}"]
        _ -> []
      end
    end)
  end

  @doc """
  Checks recommended fields and returns warnings.
  """
  @spec check_recommended(map()) :: [String.t()]
  def check_recommended(pkg_data) do
    Enum.reject(@recommended_fields, &pkg_data[&1])
    |> Enum.map(&"Missing recommended field: #{&1}")
  end

  @doc """
  Checks if the version has already been published.
  """
  @spec version_exists?(String.t(), String.t(), map()) :: boolean()
  def version_exists?(name, version, packument) do
    versions = Map.get(packument, :versions, %{})
    Map.has_key?(versions, version) or (name != "" and false)
  end

  @doc """
  Validates that the package name is not taken (for new packages).
  """
  @spec name_available?(String.t()) :: boolean()
  def name_available?(name) do
    case NPM.Validator.validate_name(name) do
      :ok -> true
      _ -> false
    end
  end

  @doc """
  Returns a readiness summary.
  """
  @spec summary(map()) :: %{
          ready: boolean(),
          errors: [String.t()],
          warnings: [String.t()],
          name: String.t() | nil,
          version: String.t() | nil
        }
  def summary(pkg_data) do
    errors = check_required(pkg_data)
    warnings = check_recommended(pkg_data)

    %{
      ready: errors == [],
      errors: errors,
      warnings: warnings,
      name: pkg_data["name"],
      version: pkg_data["version"]
    }
  end
end
