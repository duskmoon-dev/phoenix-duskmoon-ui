ExUnit.start()

defmodule DuskmoonUI.CandidateIntegrationTest do
  use ExUnit.Case, async: true
  @moduletag :tmp_dir

  setup %{tmp_dir: root} do
    scripts = Path.join(root, "source/scripts")
    bin = Path.join(root, "bin")
    toolchain = Path.join(root, "toolchain")
    Enum.each([scripts, bin, toolchain], &File.mkdir_p!/1)
    helper = Path.join(scripts, "candidate-integration.sh")
    File.cp!(Path.join(__DIR__, "candidate-integration.sh"), helper)

    executables = %{
      "elixir" => """
      #!/bin/sh
      set -eu
      case "$1" in
        */stage-packages.exs)
          printf 'stage\n' >> "$CANDIDATE_TEST_LOG"
          mkdir -p "$3"
          ;;
        */prepare-candidate.exs)
          printf 'prepare\n' >> "$CANDIDATE_TEST_LOG"
          mkdir -p "$4"
          ;;
        *) exit 90 ;;
      esac
      """,
      "mix" => """
      #!/bin/sh
      set -eu
      test "$PWD" = "$DUSKMOON_CANDIDATE_ROOT/ui"
      test "$MIX_DEPS_PATH" = "$PWD/deps"
      test "$MIX_BUILD_PATH" = "$PWD/_build/test"
      test "$MIX_ENV" = test
      test "$DUSKMOON_NATIVE_MODE" = source
      test "$DUSKMOON_BUILD_NATIVE_FROM_SOURCE" = 1
      test "$QUICKBEAM_BUILD" = 1
      test "$DUSKMOON_CANDIDATE_INTEGRATION" = 1
      printf 'mix %s\n' "$*" >> "$CANDIDATE_TEST_LOG"
      case "$*" in
        'duskmoon_bundler.build duskmoon_storybook')
          test "${HOLOGRAM_START:-}" = 1
          test "${CANDIDATE_TEST_FAILURE:-}" != assets || exit 23
          mkdir -p apps/duskmoon_storybook/priv/static/assets/css
          printf '/* candidate CSS */\n' > apps/duskmoon_storybook/priv/static/assets/css/app.css
          ;;
        test)
          test "${HOLOGRAM_START:-}" = 1
          test -s apps/duskmoon_storybook/priv/static/assets/css/app.css
          test "${CANDIDATE_TEST_FAILURE:-}" != tests || exit 24
          ;;
      esac
      """,
      "bun" => """
      #!/bin/sh
      set -eu
      test "$PWD" = "$DUSKMOON_CANDIDATE_ROOT/ui"
      printf 'bun %s\n' "$*" >> "$CANDIDATE_TEST_LOG"
      """
    }

    for {name, content} <- executables do
      path = Path.join(bin, name)
      File.write!(path, content)
      File.chmod!(path, 0o755)
    end

    log = Path.join(root, "commands.log")

    env = [
      {"PATH", bin <> ":" <> System.fetch_env!("PATH")},
      {"DUSKMOON_CANDIDATE_ROOT", Path.join(root, "candidate")},
      {"CANDIDATE_TEST_LOG", log},
      {"HOLOGRAM_START", "0"}
    ]

    {:ok, helper: helper, toolchain: toolchain, log: log, env: env}
  end

  test "builds candidate Storybook CSS and enables Hologram before unchanged tests", fixture do
    assert {output, 0} = run_helper(fixture)

    assert File.read!(fixture.log) == """
           stage
           prepare
           mix deps.get
           mix npm.ci
           mix compile --warnings-as-errors
           mix duskmoon_bundler.build duskmoon_storybook
           mix test
           mix prepublish
           bun test --cwd apps/phoenix_duskmoon
           """

    assert output =~ "Candidate integration evidence:"
  end

  test "stops before browser tests when candidate asset generation fails", fixture do
    assert {output, 23} = run_helper(fixture, "assets")
    commands = File.read!(fixture.log)
    assert String.ends_with?(commands, "mix duskmoon_bundler.build duskmoon_storybook\n")
    refute commands =~ "mix test\n"
    refute output =~ "Candidate integration evidence:"
  end

  test "preserves browser test failures", fixture do
    assert {output, 24} = run_helper(fixture, "tests")
    assert fixture.log |> File.read!() |> String.ends_with?("mix test\n")
    refute output =~ "Candidate integration evidence:"
  end

  defp run_helper(fixture, failure \\ "") do
    System.cmd("sh", [fixture.helper, fixture.toolchain],
      env: [{"CANDIDATE_TEST_FAILURE", failure} | fixture.env],
      stderr_to_stdout: true
    )
  end
end
