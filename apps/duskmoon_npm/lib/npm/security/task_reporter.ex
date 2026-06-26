defmodule NPM.Security.TaskReporter do
  @moduledoc """
  Shared reporting helpers for npm security Mix tasks.
  """

  alias NPM.Config
  alias NPM.JSON
  alias NPM.Security.Compromised

  @type output_format :: :text | :json
  @type policy :: :error | :warn | :off

  @doc "Parse a task output format option."
  @spec parse_format(String.t() | nil) :: {:ok, output_format()} | :error
  def parse_format(nil), do: {:ok, :text}
  def parse_format("text"), do: {:ok, :text}
  def parse_format("json"), do: {:ok, :json}
  def parse_format(_), do: :error

  @doc "Parse a compromised-package task policy option."
  @spec parse_policy(String.t() | nil) :: {:ok, policy()} | :error
  def parse_policy(nil), do: {:ok, Config.compromised_policy()}
  def parse_policy("error"), do: {:ok, :error}
  def parse_policy("warn"), do: {:ok, :warn}
  def parse_policy("off"), do: {:ok, :off}
  def parse_policy(_), do: :error

  @doc "Report compromised-package findings in text or JSON format."
  @spec report([Compromised.finding()], output_format(), String.t(), String.t()) :: :ok
  def report(findings, :text, empty_message, found_message) do
    case findings do
      [] ->
        Mix.shell().info(empty_message)

      _ ->
        Mix.shell().error(found_message)
        findings |> Compromised.format_findings() |> Enum.each(&Mix.shell().error("  #{&1}"))
    end
  end

  def report(findings, :json, _empty_message, _found_message) do
    findings
    |> Enum.map(&Compromised.finding_to_json/1)
    |> then(&%{"findings" => &1})
    |> JSON.encode_pretty()
    |> Mix.shell().info()
  end

  @doc "Raise according to policy when compromised-package findings exist."
  @spec enforce([Compromised.finding()], policy()) :: :ok | no_return()
  def enforce([], _policy), do: :ok
  def enforce(_findings, :warn), do: :ok
  def enforce(_findings, :off), do: :ok
  def enforce(findings, :error), do: Mix.raise("Found #{length(findings)} compromised packages")
end
