file_mutation = ["File.write!", "File.rm", "File.rm_rf!"]
app_config = [
  "Application.get_env",
  "Application.get_all_env",
  "Application.fetch_env",
  "Application.put_env",
  "Application.delete_env"
]
compat_json = [":json.*"]
unsafe_runtime_encoding = ["Jason.encode!"]
unstable_hashing = [":erlang.phash2"]
builder_runtime = ["DuskmoonBundler.DevServer.*", "DuskmoonBundler.Watcher.*", "DuskmoonBundler.HMR.*"]
asset_runtime = ["DuskmoonBundler.Assets.*", "DuskmoonBundler.Builder.*", "DuskmoonBundler.DevServer.*", "DuskmoonBundler.JS.*"]
ast_side_effects = app_config ++ file_mutation ++ ["System.cmd", "QuickBEAM.*"] ++ builder_runtime

adapter = [
  "Mix.Tasks.DuskmoonBundler.*",
  "DuskmoonBundler",
  "DuskmoonBundler.Formatter"
]

orchestrator = [
  "DuskmoonBundler.Builder",
  "DuskmoonBundler.Builder.Collector",
  "DuskmoonBundler.Builder.Externals",
  "DuskmoonBundler.Builder.Output",
  "DuskmoonBundler.Builder.Rewriter",
  "DuskmoonBundler.DevServer",
  "DuskmoonBundler.JS.Vendor",
  "DuskmoonBundler.Pipeline",
  "DuskmoonBundler.Tailwind",
  "DuskmoonBundler.Watcher"
]

model = [
  "DuskmoonBundler.Builder.BuildContext",
  "DuskmoonBundler.Builder.Collector.State",
  "DuskmoonBundler.Builder.Context",
  "DuskmoonBundler.Builder.Dependencies",
  "DuskmoonBundler.Builder.ManifestEntry",
  "DuskmoonBundler.Builder.OutputContext",
  "DuskmoonBundler.Builder.OutputFile",
  "DuskmoonBundler.Builder.Result",
  "DuskmoonBundler.ChunkGraph.Chunk",
  "DuskmoonBundler.Config",
  "DuskmoonBundler.Config.*",
  "DuskmoonBundler.DevServer.CacheEntry",
  "DuskmoonBundler.DevServer.Config",
  "DuskmoonBundler.HMR.Message",
  "DuskmoonBundler.JS.ImportExtractor.Result",
  "DuskmoonBundler.JS.PrebundleEntry.Export",
  "DuskmoonBundler.JS.PrebundleEntry.Import",
  "DuskmoonBundler.JS.Runtime.Installer.Metadata",
  "DuskmoonBundler.JS.TSConfig",
  "DuskmoonBundler.Paths",
  "DuskmoonBundler.Pipeline.Result.Hashes"
]

logic = [
  "DuskmoonBundler.Assets",
  "DuskmoonBundler.Assets.Query",
  "DuskmoonBundler.Builder.Resolver",
  "DuskmoonBundler.ChunkGraph",
  "DuskmoonBundler.CSS.AST",
  "DuskmoonBundler.CSS.AssetURLRewriter",
  "DuskmoonBundler.CSS.Modules",
  "DuskmoonBundler.Env",
  "DuskmoonBundler.Format",
  "DuskmoonBundler.HTMLEntry",
  "DuskmoonBundler.JS.AST",
  "DuskmoonBundler.JS.Check",
  "DuskmoonBundler.JS.Extensions",
  "DuskmoonBundler.JS.Format",
  "DuskmoonBundler.JS.Helpers",
  "DuskmoonBundler.JS.ImportExtractor",
  "DuskmoonBundler.JS.Patch",
  "DuskmoonBundler.JS.PrebundleEntry",
  "DuskmoonBundler.JS.Resolution",
  "DuskmoonBundler.JS.Resolver",
  "DuskmoonBundler.JS.Transforms.AssetURLs",
  "DuskmoonBundler.JS.Transforms.DynamicImports",
  "DuskmoonBundler.JS.Transforms.DynamicImports.Replacement",
  "DuskmoonBundler.JS.Transforms.GlobImports",
  "DuskmoonBundler.JS.Transforms.GlobImports.Call",
  "DuskmoonBundler.JS.Transforms.GlobImports.File",
  "DuskmoonBundler.JS.Transforms.ImportMetaEnv",
  "DuskmoonBundler.JS.Transforms.Imports",
  "DuskmoonBundler.JS.Transforms.Specifiers",
  "DuskmoonBundler.JS.Transforms.Workers",
  "DuskmoonBundler.Path",
  "DuskmoonBundler.Pipeline.Result",
  "DuskmoonBundler.PluginRunner",
  "DuskmoonBundler.Preload",
  "DuskmoonBundler.PublicDir",
  "DuskmoonBundler.Tailwind.Resolver",
  "DuskmoonBundler.URL"
]

infrastructure = [
  "DuskmoonBundler.Application",
  "DuskmoonBundler.Builder.Writer",
  "DuskmoonBundler.Cache",
  "DuskmoonBundler.Dev.ConsoleForwarder",
  "DuskmoonBundler.ETS",
  "DuskmoonBundler.HMR.Boundary",
  "DuskmoonBundler.HMR.GlobGraph",
  "DuskmoonBundler.HMR.ImportGraph",
  "DuskmoonBundler.HMR.ModuleGraph",
  "DuskmoonBundler.HMR.ModuleGraph.Node",
  "DuskmoonBundler.HMR.Socket",
  "DuskmoonBundler.JS.Asset",
  "DuskmoonBundler.JS.Runtime",
  "DuskmoonBundler.JS.Runtime.Bundler",
  "DuskmoonBundler.JS.Runtime.Entry",
  "DuskmoonBundler.JS.Runtime.Error",
  "DuskmoonBundler.JS.Runtime.Installer",
  "DuskmoonBundler.Tailwind.Loader"
]

plugin = [
  "DuskmoonBundler.Plugin",
  "DuskmoonBundler.Plugin.Helpers",
  "DuskmoonBundler.Plugin.React",
  "DuskmoonBundler.Plugin.Solid",
  "DuskmoonBundler.Plugin.Solid.CompilerOptions",
  "DuskmoonBundler.Plugin.Solid.CompilerOptions.SolidOptions",
  "DuskmoonBundler.Plugin.Svelte",
  "DuskmoonBundler.Plugin.Svelte.CompilerOptions",
  "DuskmoonBundler.Plugin.Vue"
]

model_must_not_depend_on = [:adapter, :orchestrator, :infrastructure]
logic_must_not_depend_on = [:adapter, :orchestrator, :infrastructure]

[
  layers: [
    adapter: adapter,
    orchestrator: orchestrator,
    model: model,
    logic: logic,
    infrastructure: infrastructure,
    plugin: plugin
  ],
  checks: [
    layer_coverage: [
      require_all_modules: true,
      forbid_multiple_matches: true,
      ignore: ["Jason.Encoder.*"]
    ]
  ],
  deps: [
    forbidden:
      Enum.map(model_must_not_depend_on, &{:model, &1}) ++
        Enum.map(logic_must_not_depend_on, &{:logic, &1}) ++
        [
          {:infrastructure, :adapter},
          {:plugin, :adapter}
        ]
  ],
  source: [
    forbidden_modules: [
      "DuskmoonBundler.Builder.BundleResult",
      "DuskmoonBundler.DepGraph",
      "DuskmoonBundler.HMR.Client",
      "DuskmoonBundler.JS.PackageResolver",
      "DuskmoonBundler.JS.VueImports",
      "DuskmoonBundler.Mix"
    ]
  ],
  calls: [
    forbidden: [
      {"DuskmoonBundler.URL", app_config ++ asset_runtime},
      {"DuskmoonBundler.Path", app_config ++ asset_runtime},
      {"DuskmoonBundler.JS.AST", ast_side_effects},
      {"DuskmoonBundler.CSS.AST", ast_side_effects},
      {"DuskmoonBundler.JS.Transforms.*", ["QuickBEAM.*", "System.cmd"] ++ file_mutation},
      {"DuskmoonBundler.Builder*", builder_runtime},
      {"DuskmoonBundler.HMR.*Graph",
       ["DuskmoonBundler.HMR.Socket.*", "Registry.dispatch", "WebSock.*", "WebSockAdapter.*"] ++
         file_mutation ++ ["System.cmd"]},
      {"DuskmoonBundler.Plugin",
       [
         "DuskmoonBundler.Plugin.React.*",
         "DuskmoonBundler.Plugin.Solid.*",
         "DuskmoonBundler.Plugin.Svelte.*",
         "DuskmoonBundler.Plugin.Vue.*"
       ]},
      {"DuskmoonBundler.*", compat_json, except: ["DuskmoonBundler.Plugin.*"]},
      {"DuskmoonBundler.HMR.Socket", unsafe_runtime_encoding},
      {"DuskmoonBundler.Plugin.*", unstable_hashing},
      {"Mix.Tasks.DuskmoonBundler.Js.Check", ["OXC.Format.run!", "OXC.Lint.run!"]}
    ]
  ],
  effects: [
    allowed: [
      {"DuskmoonBundler.URL", [:pure, :unknown, :exception]},
      {"DuskmoonBundler.Path", [:pure, :unknown, :exception]},
      {"DuskmoonBundler.JS.AST", [:pure, :unknown, :exception, :nif]},
      {"DuskmoonBundler.CSS.AST", [:pure, :unknown, :exception, :nif]}
    ]
  ],
  smells: [
    strict: true
  ]
]
