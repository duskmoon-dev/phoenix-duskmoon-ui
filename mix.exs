Code.require_file("scripts/native-policy.exs", __DIR__)
DuskmoonUI.NativePolicy.validate!()

defmodule PhoenixDuskmoon.Umbrella.MixProject do
  use Mix.Project

  # Umbrella version tracks phoenix_duskmoon package version
  @version "10.0.12"

  def project do
    [
      apps_path: "apps",
      apps: [:phoenix_duskmoon, :duskmoon_storybook],
      version: @version,
      lockfile: "mix.lock",
      elixir: ">= 1.18.0",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      listeners: [Phoenix.CodeReloader],
      releases: [
        storybook: [
          applications: [duskmoon_storybook: :permanent],
          steps: [&strip_build_tools/1, :assemble]
        ]
      ],
      aliases: aliases()
    ]
  end

  defp strip_build_tools(%Mix.Release{} = release) do
    excluded =
      ~w(duskmoon_bundler duskmoon_oxc duskmoon_oxide duskmoon_vize duskmoon_quickbeam duskmoon_npm duskmoon_hex_solver zigler zigler_precompiled)a

    for {app, props} <- release.applications, app not in excluded do
      path = props[:path] || Application.app_dir(app)
      app_file = Path.join([path, "ebin", "#{app}.app"])

      if File.exists?(app_file) do
        case :file.consult(String.to_charlist(app_file)) do
          {:ok, [{:application, ^app, app_props}]} ->
            current_apps = Keyword.get(app_props, :applications, [])

            if Enum.any?(excluded, &(&1 in current_apps)) do
              cleaned_apps = current_apps -- excluded
              updated_props = Keyword.put(app_props, :applications, cleaned_apps)
              content = :io_lib.format("~tp.~n", [{:application, app, updated_props}])
              File.write!(app_file, content)
            end

          _ ->
            :ok
        end
      end
    end

    applications =
      release.applications
      |> Map.new(fn {app, spec} ->
        updated_spec =
          Keyword.update(spec, :applications, [], fn child_apps -> child_apps -- excluded end)

        {app, updated_spec}
      end)
      |> Map.drop(excluded)

    boot_scripts =
      Map.new(release.boot_scripts, fn {boot_name, modes} ->
        {boot_name, Keyword.drop(modes, excluded)}
      end)

    %{release | applications: applications, boot_scripts: boot_scripts}
  end

  defp deps do
    # Keep the build-tool cohort in the 10.x series without adding it to the public package.
    [
      {:ex_doc, "~> 0.40", runtime: false, override: true},
      # Keep Plug available to both test servers and runtime umbrella applications.
      {:plug, "~> 1.20"},
      {:websock_adapter, "~> 0.14", hex: :gaoxy_websock_adapter, override: true},
      {:duskmoon_oxc, "~> 10.0", runtime: false},
      {:duskmoon_oxide, "~> 10.0", runtime: false},
      {:duskmoon_vize, "~> 10.0", runtime: false},
      {:duskmoon_quickbeam, "~> 10.0", runtime: false},
      {:duskmoon_npm, "~> 10.0", runtime: false},
      {:duskmoon_hex_solver, "~> 10.0", runtime: false}
    ]
  end

  defp aliases do
    [
      setup: ["deps.get", "npm.install", "cmd mix setup"],
      "duskmoon.dev": "holo",
      prepublish: [
        "do --app phoenix_duskmoon cmd cp #{Path.expand("README.md", __DIR__)} README.md",
        "duskmoon_bundler.build phoenix_duskmoon",
        "do --app phoenix_duskmoon icons.bundle"
      ]
    ]
  end
end
