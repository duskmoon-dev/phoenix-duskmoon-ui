defmodule NPM.Dependency.Outdated.Report do
  @moduledoc """
  Generates formatted reports for outdated npm packages.
  """

  @doc """
  Formats outdated packages as a table similar to `npm outdated`.
  """
  @spec format_table([map()]) :: String.t()
  def format_table([]), do: "All packages are up to date."

  def format_table(packages) do
    header = %{
      name: "Package",
      current: "Current",
      wanted: "Wanted",
      latest: "Latest",
      type: "Type"
    }

    rows = [header | packages]

    widths = %{
      name: rows |> Enum.map(&String.length(to_string(&1.name))) |> Enum.max(),
      current: rows |> Enum.map(&String.length(to_string(&1.current))) |> Enum.max(),
      wanted: rows |> Enum.map(&String.length(to_string(Map.get(&1, :wanted, "")))) |> Enum.max(),
      latest: rows |> Enum.map(&String.length(to_string(&1.latest))) |> Enum.max()
    }

    [format_row(header, widths) | Enum.map(packages, &format_row(&1, widths))]
    |> Enum.join("\n")
  end

  @doc """
  Categorizes a list of outdated packages by severity.
  """
  @spec categorize([map()]) :: map()
  def categorize(packages) do
    %{
      major: Enum.filter(packages, &(&1.type == :major)),
      minor: Enum.filter(packages, &(&1.type == :minor)),
      patch: Enum.filter(packages, &(&1.type == :patch))
    }
  end

  @doc """
  Generates a summary line.
  """
  @spec summary([map()]) :: String.t()
  def summary([]), do: "All packages are up to date."

  def summary(packages) do
    cat = categorize(packages)
    parts = []
    parts = if cat.major != [], do: ["#{length(cat.major)} major" | parts], else: parts
    parts = if cat.minor != [], do: ["#{length(cat.minor)} minor" | parts], else: parts
    parts = if cat.patch != [], do: ["#{length(cat.patch)} patch" | parts], else: parts
    "#{length(packages)} outdated: #{parts |> Enum.reverse() |> Enum.join(", ")}"
  end

  @doc """
  Returns security-relevant outdated packages (major versions behind).
  """
  @spec security_risk([map()]) :: [map()]
  def security_risk(packages) do
    Enum.filter(packages, &(&1.type == :major))
  end

  defp format_row(row, widths) do
    name = String.pad_trailing(to_string(row.name), widths.name)
    current = String.pad_trailing(to_string(row.current), widths.current)
    wanted = String.pad_trailing(to_string(Map.get(row, :wanted, "")), widths.wanted)
    latest = String.pad_trailing(to_string(row.latest), widths.latest)
    "#{name}  #{current}  #{wanted}  #{latest}"
  end
end
