[release_root] = System.argv()
[release_file] = Path.wildcard(Path.join([release_root, "releases", "*", "storybook.rel"]))
{:ok, [{:release, _, _, apps}]} = :file.consult(String.to_charlist(release_file))
actual = Enum.map(apps, &elem(&1, 0))
required = [:phoenix_duskmoon, :duskmoon_storybook, :duskmoon_bundler_runtime]
for app <- required, app not in actual, do: raise("Release missing required runtime #{app}")

for app <-
      ~w(duskmoon_bundler duskmoon_oxc duskmoon_oxide duskmoon_vize duskmoon_quickbeam duskmoon_npm duskmoon_hex_solver zigler zigler_precompiled)a,
    app in actual,
    do: raise("Release contains build-tool application #{app}")

IO.puts(
  "Storybook release runtime verified: #{length(actual)} applications, no Duskmoon compiler applications"
)
