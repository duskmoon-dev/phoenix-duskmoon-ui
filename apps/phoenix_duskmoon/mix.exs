defmodule PhoenixDuskmoon.Mixfile do
  use Mix.Project

  # Version is automatically updated by semantic-release in CI
  # Do not manually edit - use mix version.sync to sync from published version
  @source_url "https://github.com/duskmoon-dev/phoenix-duskmoon-ui.git"
  @version "7.2.1"

  def project do
    [
      app: :phoenix_duskmoon,
      version: @version,
      elixir: "~> 1.15",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      deps: deps(),
      name: "PhoenixDuskmoon",
      description: "Duskmoon UI component library for Phoenix LiveView",
      package: package(),
      aliases: aliases(),
      docs: [
        main: "home",
        source_url: @source_url,
        source_ref: "v#{@version}",
        extras: [
          "guides/home.md",
          "guides/getting-started.md",
          "guides/theming.md",
          "guides/hooks.md",
          "guides/migrating-to-v9.md",
          "CHANGELOG.md"
        ],
        groups_for_extras: [
          Guides: ~r/guides\/.*/,
          Changelog: ["CHANGELOG.md"]
        ],
        groups_for_modules: [
          Action: [
            PhoenixDuskmoon.Component.Action.Button,
            PhoenixDuskmoon.Component.Action.Dropdown,
            PhoenixDuskmoon.Component.Action.Link,
            PhoenixDuskmoon.Component.Action.Menu,
            PhoenixDuskmoon.Component.Action.Toggle
          ],
          "Data Display": [
            PhoenixDuskmoon.Component.DataDisplay.Accordion,
            PhoenixDuskmoon.Component.DataDisplay.Avatar,
            PhoenixDuskmoon.Component.DataDisplay.Badge,
            PhoenixDuskmoon.Component.DataDisplay.Card,
            PhoenixDuskmoon.Component.DataDisplay.Chip,
            PhoenixDuskmoon.Component.DataDisplay.Collapse,
            PhoenixDuskmoon.Component.DataDisplay.Flash,
            PhoenixDuskmoon.Component.DataDisplay.List,
            PhoenixDuskmoon.Component.DataDisplay.Markdown,
            PhoenixDuskmoon.Component.DataDisplay.Pagination,
            PhoenixDuskmoon.Component.DataDisplay.Popover,
            PhoenixDuskmoon.Component.DataDisplay.Progress,
            PhoenixDuskmoon.Component.DataDisplay.Skeleton,
            PhoenixDuskmoon.Component.DataDisplay.Stat,
            PhoenixDuskmoon.Component.DataDisplay.Table,
            PhoenixDuskmoon.Component.DataDisplay.Timeline,
            PhoenixDuskmoon.Component.DataDisplay.Tooltip
          ],
          "Data Entry": [
            PhoenixDuskmoon.Component.DataEntry.Autocomplete,
            PhoenixDuskmoon.Component.DataEntry.Cascader,
            PhoenixDuskmoon.Component.DataEntry.Checkbox,
            PhoenixDuskmoon.Component.DataEntry.CompactInput,
            PhoenixDuskmoon.Component.DataEntry.FileUpload,
            PhoenixDuskmoon.Component.DataEntry.Form,
            PhoenixDuskmoon.Component.DataEntry.Input,
            PhoenixDuskmoon.Component.DataEntry.MultiSelect,
            PhoenixDuskmoon.Component.DataEntry.OtpInput,
            PhoenixDuskmoon.Component.DataEntry.PinInput,
            PhoenixDuskmoon.Component.DataEntry.Radio,
            PhoenixDuskmoon.Component.DataEntry.Rating,
            PhoenixDuskmoon.Component.DataEntry.SegmentControl,
            PhoenixDuskmoon.Component.DataEntry.Select,
            PhoenixDuskmoon.Component.DataEntry.Slider,
            PhoenixDuskmoon.Component.DataEntry.Switch,
            PhoenixDuskmoon.Component.DataEntry.Textarea,
            PhoenixDuskmoon.Component.DataEntry.TimeInput,
            PhoenixDuskmoon.Component.DataEntry.TreeSelect
          ],
          Feedback: [
            PhoenixDuskmoon.Component.Feedback.Dialog,
            PhoenixDuskmoon.Component.Feedback.Loading,
            PhoenixDuskmoon.Component.Feedback.Snackbar,
            PhoenixDuskmoon.Component.Feedback.Toast
          ],
          Navigation: [
            PhoenixDuskmoon.Component.Navigation.Actionbar,
            PhoenixDuskmoon.Component.Navigation.Appbar,
            PhoenixDuskmoon.Component.Navigation.BottomNav,
            PhoenixDuskmoon.Component.Navigation.Breadcrumb,
            PhoenixDuskmoon.Component.Navigation.LeftMenu,
            PhoenixDuskmoon.Component.Navigation.Navbar,
            PhoenixDuskmoon.Component.Navigation.NestedMenu,
            PhoenixDuskmoon.Component.Navigation.PageFooter,
            PhoenixDuskmoon.Component.Navigation.PageHeader,
            PhoenixDuskmoon.Component.Navigation.Stepper,
            PhoenixDuskmoon.Component.Navigation.Steps,
            PhoenixDuskmoon.Component.Navigation.Tab
          ],
          Layout: [
            PhoenixDuskmoon.Component.Layout.BottomSheet,
            PhoenixDuskmoon.Component.Layout.Divider,
            PhoenixDuskmoon.Component.Layout.Drawer,
            PhoenixDuskmoon.Component.Layout.ThemeSwitcher
          ],
          Icon: [
            PhoenixDuskmoon.Component.Icon.Icons
          ],
          "CSS Art": [
            PhoenixDuskmoon.CssArt.ButtonNoise,
            PhoenixDuskmoon.CssArt.Eclipse,
            PhoenixDuskmoon.CssArt.PlasmaBall,
            PhoenixDuskmoon.CssArt.Signature,
            PhoenixDuskmoon.CssArt.Snow,
            PhoenixDuskmoon.CssArt.SpotlightSearch
          ]
        ],
        nest_modules_by_prefix: [
          PhoenixDuskmoon.Component.Action,
          PhoenixDuskmoon.Component.DataDisplay,
          PhoenixDuskmoon.Component.DataEntry,
          PhoenixDuskmoon.Component.Feedback,
          PhoenixDuskmoon.Component.Navigation,
          PhoenixDuskmoon.Component.Layout,
          PhoenixDuskmoon.Component.Icon,
          PhoenixDuskmoon.CssArt
        ],
        skip_undefined_reference_warnings_on: ["CHANGELOG.md"]
      ]
    ]
  end

  def application do
    [
      extra_applications: [:eex, :logger],
      env: [csrf_token_reader: {Plug.CSRFProtection, :get_csrf_token_for, []}]
    ]
  end

  defp deps do
    [
      {:phoenix, "~> 1.8.1"},
      {:phoenix_html, "~> 4.0"},
      {:phoenix_live_view, "~> 1.1.0"},
      {:plug, "~> 1.14", optional: true},
      {:bun, "~> 1.4", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.3", runtime: Mix.env() == :dev},
      {:jason, "~> 1.2", only: :test},
      {:ex_doc, ">= 0.0.0", only: :prod, runtime: false}
    ]
  end

  defp package do
    [
      maintainers: ["Jonathan Gao"],
      licenses: ["MIT"],
      files: ~w(lib priv guides CHANGELOG.md LICENSE mix.exs package.json assets README.md),
      links: %{
        Changelog: "https://hexdocs.pm/phoenix_duskmoon/changelog.html",
        GitHub: @source_url
      }
    ]
  end

  defp aliases do
    [
      prepublish: [
        "cmd cp #{Path.expand("../../README.md", __DIR__)} #{Path.expand("README.md", __DIR__)}",
        "tailwind duskmoon",
        "bun duskmoon"
      ]
    ]
  end
end
