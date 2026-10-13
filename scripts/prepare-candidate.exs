# Only the explicit candidate helper uses path overrides. No published metadata changes.
[source, stage, output] = System.argv() |> Enum.map(&Path.expand/1)
{files, 0} = System.cmd("git", ["ls-files", "-z"], cd: source)
File.mkdir_p!(output)

for relative <- String.split(files, <<0>>, trim: true),
    File.regular?(Path.join(source, relative)) do
  destination = Path.join(output, relative)
  File.mkdir_p!(Path.dirname(destination))
  File.cp!(Path.join(source, relative), destination)
end

apps =
  ~w(duskmoon_bundler duskmoon_bundler_runtime duskmoon_oxc duskmoon_oxide duskmoon_vize duskmoon_quickbeam duskmoon_npm duskmoon_hex_solver)a

for app <- apps do
  unless File.regular?(Path.join([stage, Atom.to_string(app), "mix.exs"])),
    do: raise("Incomplete candidate cohort: #{app}")
end

path_deps =
  Enum.map(apps, fn app ->
    {app, [path: Path.join(stage, Atom.to_string(app)), override: true, runtime: false]}
  end)

# The explicit runtime dependency in Storybook remains runtime-enabled.
path_deps =
  Enum.map(path_deps, fn
    {:duskmoon_bundler, opts} ->
      {:duskmoon_bundler, Keyword.put(opts, :runtime, true)}

    {:duskmoon_bundler_runtime, opts} ->
      {:duskmoon_bundler_runtime, Keyword.put(opts, :runtime, true)}

    other ->
      other
  end)

path_deps = path_deps ++ [{:zigler, "~> 0.16.0", [runtime: false]}]
root_mix = Path.join(output, "mix.exs")
content = File.read!(root_mix)
needle = "  defp deps do\n"

unless String.contains?(content, needle),
  do: raise("Unexpected UI Mix project; candidate adapter must be reviewed")

# Replace only existing workspace toolchain constraints; add the complete candidate closure.
content =
  Regex.replace(
    ~r/^\s*\{:duskmoon_(?:oxc|oxide|vize|quickbeam|npm|hex_solver),[^\n]+\n/m,
    content,
    ""
  )

content =
  String.replace(
    content,
    needle,
    needle <> "    candidate_deps = #{inspect(path_deps, limit: :infinity)}\n",
    global: false
  )

content = String.replace(content, "      {:plug, \"~> 1.19\"},", "      {:plug, \"~> 1.19\"}")
# Existing ordinary constraints are a separate list; no second copy of a native app can remain.
content =
  String.replace(
    content,
    "      {:plug, \"~> 1.19\"}\n    ]",
    "      {:plug, \"~> 1.19\"}\n    ] ++ candidate_deps",
    global: false
  )

File.write!(root_mix, content)
{source_sha, 0} = System.cmd("git", ["rev-parse", "HEAD"], cd: source)
{patch, 0} = System.cmd("git", ["diff", "HEAD"], cd: source)

provenance = %{
  ui_sha: String.trim(source_sha),
  ui_patch_sha256: Base.encode16(:crypto.hash(:sha256, patch), case: :lower),
  toolchain_stage_sha256:
    Base.encode16(:crypto.hash(:sha256, File.read!(Path.join(stage, "manifest.json"))),
      case: :lower
    ),
  mode: "candidate-source-full-cohort",
  warning:
    "Path/source candidate validation is separate from published precompiled consumer proof"
}

File.write!(Path.join(output, "candidate-provenance.json"), JSON.encode!(provenance) <> "\n")
IO.puts(output)
