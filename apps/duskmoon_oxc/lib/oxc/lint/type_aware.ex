defmodule OXC.Lint.TypeAware do
  @moduledoc "Runs type-aware TypeScript lint rules through tsgolint headless mode."

  defmodule Payload do
    @moduledoc "tsgolint headless payload."

    @derive Jason.Encoder
    defstruct version: 2,
              configs: [],
              source_overrides: %{},
              report_syntactic: false,
              report_semantic: false
  end

  defmodule Config do
    @moduledoc "Files and rules submitted to tsgolint."

    @derive Jason.Encoder
    defstruct file_paths: [], rules: []
  end

  defmodule Rule do
    @moduledoc "Rule entry submitted to tsgolint."

    @derive Jason.Encoder
    defstruct name: nil, options: nil
  end

  defmodule Diagnostic do
    @moduledoc "Normalized type-aware lint diagnostic."

    @derive Jason.Encoder
    defstruct rule: nil,
              message: "",
              severity: :warn,
              file: nil,
              span: {0, 0},
              labels: [],
              help: nil,
              fixes: [],
              suggestions: []
  end

  @type severity :: OXC.Lint.severity()
  @type diagnostic :: OXC.Lint.diagnostic()

  @doc "Run tsgolint on a list of files."
  @spec run([String.t()], keyword()) :: {:ok, [diagnostic()]} | {:error, [String.t()]}
  def run(files, opts \\ []) when is_list(files) do
    with {:ok, executable} <- find_executable(opts),
         {:ok, output} <- run_tsgolint(executable, files, opts) do
      if is_binary(output), do: parse_output(output, severity_by_rule(opts)), else: {:ok, output}
    end
  end

  @doc false
  def parse_output(output, severities \\ %{}) when is_binary(output) do
    parse_frames(output, severities, [], [])
  end

  defp find_executable(opts) do
    executable =
      Keyword.get(opts, :tsgolint) ||
        get_in(Application.get_env(:oxc, :tsgolint, []), [:executable]) ||
        System.find_executable("tsgolint")

    cond do
      is_binary(executable) and File.exists?(executable) -> {:ok, executable}
      is_binary(executable) and System.find_executable(executable) -> {:ok, executable}
      true -> {:error, ["tsgolint executable not found; pass tsgolint: \"/path/to/tsgolint\""]}
    end
  end

  defp run_tsgolint(executable, files, opts) do
    payload_path = write_payload!(build_payload(files, opts))
    stderr_path = tmp_path("oxc-tsgolint-stderr")
    args = ["headless" | headless_flags(opts)]

    try do
      command_args = ["sh", payload_path, stderr_path, executable | args]

      {output, status} =
        System.cmd(
          "sh",
          [
            "-c",
            "payload=$1; stderr=$2; shift 2; exec \"$@\" < \"$payload\" 2> \"$stderr\""
            | command_args
          ],
          cd: Keyword.get(opts, :cwd, File.cwd!()),
          stderr_to_stdout: false
        )

      stderr = read_file(stderr_path)
      handle_tsgolint_result(output, stderr, status, severity_by_rule(opts))
    after
      File.rm(payload_path)
      File.rm(stderr_path)
    end
  rescue
    exception -> {:error, [Exception.message(exception)]}
  end

  defp write_payload!(payload) do
    path = tmp_path("oxc-tsgolint-payload", ".json")
    File.write!(path, Jason.encode!(payload))
    path
  end

  defp tmp_path(prefix, extension \\ "") do
    Path.join(System.tmp_dir!(), "#{prefix}-#{System.unique_integer([:positive])}#{extension}")
  end

  defp read_file(path) do
    case File.read(path) do
      {:ok, content} -> content
      {:error, _reason} -> ""
    end
  end

  defp handle_tsgolint_result(output, _stderr, 0, _severities), do: {:ok, output}

  defp handle_tsgolint_result(output, stderr, status, severities) do
    case {parse_output(output, severities), stderr} do
      {{:ok, []}, _stderr} ->
        {:error, [tsgolint_failure_message(stderr, status)]}

      {{:ok, diagnostics}, ""} ->
        {:ok, diagnostics}

      {{:ok, _diagnostics}, _stderr} ->
        {:error, [tsgolint_failure_message(stderr, status)]}

      {{:error, errors}, ""} ->
        {:error, errors}

      {{:error, errors}, _stderr} ->
        {:error, errors ++ [tsgolint_failure_message(stderr, status)]}
    end
  end

  defp tsgolint_failure_message("", status), do: "tsgolint exited with status #{status}"

  defp tsgolint_failure_message(stderr, status) do
    stderr = String.trim(stderr)

    if stderr == "" do
      "tsgolint exited with status #{status}"
    else
      "tsgolint exited with status #{status}: #{stderr}"
    end
  end

  defp build_payload(files, opts) do
    %Payload{
      configs: [%Config{file_paths: Enum.map(files, &Path.expand/1), rules: rules(opts)}],
      source_overrides: Keyword.get(opts, :source_overrides, %{}),
      report_syntactic:
        Keyword.get(opts, :type_check, false) or Keyword.get(opts, :report_syntactic, false),
      report_semantic:
        Keyword.get(opts, :type_check, false) or Keyword.get(opts, :report_semantic, false)
    }
  end

  defp rules(opts) do
    opts
    |> Keyword.get(:rules, %{})
    |> Enum.reject(fn {_name, config} -> severity(config) == :allow end)
    |> Enum.map(fn {name, config} ->
      %Rule{name: tsgolint_rule_name(name), options: rule_options(config)}
    end)
  end

  defp severity_by_rule(opts) do
    Map.new(Keyword.get(opts, :rules, %{}), fn {name, config} ->
      severity = severity(config)
      stripped = tsgolint_rule_name(name)
      {stripped, severity}
    end)
  end

  defp severity({level, _options}), do: normalize_severity(level)
  defp severity([level | _options]), do: normalize_severity(level)
  defp severity(level), do: normalize_severity(level)

  defp normalize_severity(:deny), do: :deny
  defp normalize_severity(:error), do: :deny
  defp normalize_severity(:warn), do: :warn
  defp normalize_severity(:allow), do: :allow
  defp normalize_severity(:off), do: :allow
  defp normalize_severity("deny"), do: :deny
  defp normalize_severity("error"), do: :deny
  defp normalize_severity("warn"), do: :warn
  defp normalize_severity("allow"), do: :allow
  defp normalize_severity("off"), do: :allow
  defp normalize_severity(_level), do: :warn

  defp rule_options({_level, options}), do: options
  defp rule_options([_level, options]), do: options
  defp rule_options(_level), do: nil

  defp tsgolint_rule_name(name) do
    name
    |> to_string()
    |> String.replace_prefix("typescript/", "")
  end

  defp public_rule_name(nil), do: "typescript"
  defp public_rule_name("typescript/" <> _ = rule), do: rule
  defp public_rule_name(rule), do: "typescript/#{rule}"

  defp headless_flags(opts) do
    []
    |> maybe_flag(Keyword.get(opts, :fix, false), "-fix")
    |> maybe_flag(Keyword.get(opts, :fix_suggestions, false), "-fix-suggestions")
  end

  defp maybe_flag(args, true, flag), do: [flag | args]
  defp maybe_flag(args, _enabled, _flag), do: args

  defp parse_frames(<<>>, _severities, [], diagnostics), do: {:ok, Enum.reverse(diagnostics)}
  defp parse_frames(<<>>, _severities, errors, _diagnostics), do: {:error, Enum.reverse(errors)}

  defp parse_frames(
         <<length::little-32, type::unsigned-8, rest::binary>>,
         severities,
         errors,
         diagnostics
       )
       when byte_size(rest) >= length do
    <<payload::binary-size(^length), tail::binary>> = rest

    case decode_frame(type, payload, severities) do
      {:diagnostic, diagnostic} ->
        parse_frames(tail, severities, errors, [diagnostic | diagnostics])

      {:error, message} ->
        parse_frames(tail, severities, [message | errors], diagnostics)

      :ignore ->
        parse_frames(tail, severities, errors, diagnostics)
    end
  end

  defp parse_frames(_truncated, _severities, errors, diagnostics) do
    if errors == [] do
      {:ok, Enum.reverse(diagnostics)}
    else
      {:error, Enum.reverse(errors)}
    end
  end

  defp decode_frame(0, payload, _severities) do
    case Jason.decode(payload) do
      {:ok, %{"error" => message}} -> {:error, message}
      _ -> {:error, payload}
    end
  end

  defp decode_frame(1, payload, severities) do
    case Jason.decode(payload) do
      {:ok, decoded} -> {:diagnostic, normalize_diagnostic(decoded, severities)}
      {:error, _} -> :ignore
    end
  end

  defp decode_frame(_type, _payload, _severities), do: :ignore

  defp normalize_diagnostic(decoded, severities) do
    rule = public_rule_name(decoded["rule"] || get_in(decoded, ["message", "id"]))
    range = decoded["range"] || %{}

    %Diagnostic{
      rule: rule,
      message: get_in(decoded, ["message", "description"]) || "",
      severity: Map.get(severities, tsgolint_rule_name(rule), :warn),
      file: decoded["file_path"],
      span: {range["pos"] || 0, range["end"] || 0},
      labels: labeled_ranges(decoded["labeled_ranges"] || []),
      help: get_in(decoded, ["message", "help"]),
      fixes: decoded["fixes"] || [],
      suggestions: decoded["suggestions"] || []
    }
  end

  defp labeled_ranges(ranges) do
    Enum.map(ranges, fn %{"range" => range} -> {range["pos"] || 0, range["end"] || 0} end)
  end
end
