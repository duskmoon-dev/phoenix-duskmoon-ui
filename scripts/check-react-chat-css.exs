# Exercise the documented Bundler sources in an isolated consumer. No automatic
# checkout scanning or fixture CSS may supply the chat's missing utilities.
[output] = System.argv()
root = File.cwd!()
consumer = Path.join(System.tmp_dir!(), "dm-chat-css-#{System.unique_integer([:positive])}")
css_base = Path.join(consumer, "assets/css")
File.mkdir_p!(css_base)
File.ln_s!(Path.join(root, "node_modules"), Path.join(consumer, "node_modules"))
File.mkdir_p!(Path.join(consumer, "deps"))
File.ln_s!(Path.join(root, "apps/phoenix_duskmoon"), Path.join(consumer, "deps/phoenix_duskmoon"))
File.write!(Path.join(consumer, ".gitignore"), "/deps/\n")
{:ok, _} = Application.ensure_all_started(:duskmoon_bundler)

try do
  guide = File.read!("apps/phoenix_duskmoon/guides/getting-started.md")

  dependency_sources =
    Regex.scan(~r/%\{base: "(deps\/phoenix_duskmoon\/[^"\n]+)", pattern: "([^"\n]+)"\}/, guide)
    |> Enum.map(fn [_, base, pattern] -> %{base: Path.join(consumer, base), pattern: pattern} end)

  app_sources = [%{base: Path.join(consumer, "assets"), pattern: "**/*.js"}]

  compile = fn sources ->
    {:ok, server} = DuskmoonBundler.Tailwind.start_link(name: nil, sources: sources)

    try do
      {:ok, css} =
        DuskmoonBundler.Tailwind.build(
          server: server,
          css: """
          @import "tailwindcss" source(none);
          @import "@duskmoon-dev/core/base.css";
          @plugin "@duskmoon-dev/core/plugin";
          @import "@duskmoon-dev/core/themes/sunshine";
          @import "@duskmoon-dev/core/components";
          @import "@duskmoon-dev/components/styles.css";
          """,
          css_base: css_base,
          resolve_dirs: [Path.join(root, "node_modules")],
          sources: sources
        )

      css
    after
      GenServer.stop(server)
    end
  end

  missing = compile.(app_sources)
  css = compile.(app_sources ++ dependency_sources)

  for selector <- [".bottom-3", ".end-3", ".pb-16", ".shadow-md"] do
    if String.contains?(missing, selector), do: raise("fixture leaked #{selector}")
    unless String.contains?(css, selector), do: raise("documented sources missed #{selector}")
  end

  File.write!(output, css)
  IO.puts("Documented consumer sources generated React Chat utilities")
after
  File.rm_rf!(consumer)
end
