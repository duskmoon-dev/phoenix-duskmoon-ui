# Exercise every native module, then actual production bundling and Tailwind.
{:unix, :linux} = :os.type()
system_arch = :erlang.system_info(:system_architecture) |> List.to_string()
unless system_arch =~ "musl", do: raise("Expected Alpine musl, got #{system_arch}")

{:ok, _ast} = OXC.parse("export const answer: number = 42", "answer.ts")
{:ok, formatted} = OXC.Format.run("const answer=42", "answer.js")
unless formatted =~ "answer = 42", do: raise("OXC formatter did not execute")
{:ok, diagnostics} = OXC.Lint.run("debugger;", "answer.js", rules: %{"no-debugger" => :deny})

unless Enum.any?(diagnostics, &(&1.rule == "eslint(no-debugger)" and &1.severity == :deny)),
  do: raise("OXC linter did not execute")

{:ok, vue} = Vize.compile_sfc("<template><div>Alpine</div></template>")
unless vue.code =~ "Alpine", do: raise("Vize compiler did not execute")

{:ok, runtime} = QuickBEAM.start()
{:ok, 42} = QuickBEAM.eval(runtime, "6 * 7")
:ok = QuickBEAM.stop(runtime)

File.mkdir_p!("assets")
File.write!("assets/answer.ts", "export const answer: number = 42;")
File.write!("assets/app.ts", "import { answer } from './answer'; globalThis.answer = answer;")
File.write!("assets/page.heex", "<div class=\"flex items-center p-4 text-blue-500\">Alpine</div>")
scanner = Oxide.new(sources: [%{base: Path.expand("assets"), pattern: "**/*.heex"}])
unless "items-center" in Oxide.scan(scanner), do: raise("Oxide scanner did not execute")

{:ok, bundle} =
  DuskmoonBundler.Builder.build(entry: "assets/app.ts", outdir: "dist", format: :iife)

bundle_code = File.read!(bundle.js.path)
{:ok, runtime} = QuickBEAM.start()
{:ok, _} = QuickBEAM.eval(runtime, bundle_code)
{:ok, 42} = QuickBEAM.eval(runtime, "globalThis.answer")
:ok = QuickBEAM.stop(runtime)

{:ok, css} =
  DuskmoonBundler.Tailwind.build(
    sources: [%{base: Path.expand("assets"), pattern: "**/*.heex"}],
    css: "@import \"tailwindcss\";",
    minify: true
  )

unless css =~ ".flex" and css =~ ".items-center" and css =~ ".p-4" and
         css =~ ".text-blue-500",
       do: raise("Tailwind did not generate the scanned utilities")

IO.puts("Alpine precompiled NIFs, production bundling and Tailwind passed on #{system_arch}")
