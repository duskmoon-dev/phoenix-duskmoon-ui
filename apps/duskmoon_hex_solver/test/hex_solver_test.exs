defmodule HexSolverTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureLog

  @npm_mix_exs Path.expand("../../duskmoon_npm/mix.exs", __DIR__)

  test "duskmoon_hex_solver exposes the HexSolver public API" do
    assert {:module, HexSolver} = Code.ensure_loaded(HexSolver)
    assert HexSolver in Application.spec(:duskmoon_hex_solver, :modules)
  end

  test "duskmoon_hex_solver version matches duskmoon_npm" do
    assert Application.spec(:duskmoon_hex_solver, :vsn) |> to_string() == npm_version()
  end

  test "solver resolves a simple dependency graph" do
    constraint = HexSolver.parse_constraint!("~> 1.0")

    dependencies = [
      %{
        repo: nil,
        name: "left-pad",
        constraint: constraint,
        optional: false,
        label: "left-pad",
        dependencies: []
      }
    ]

    assert {:ok, %{"left-pad" => {%Version{major: 1, minor: 0, patch: 0}, nil}}} =
             HexSolver.run(HexSolverTest.Registry, dependencies, [], [])
  end

  test "solver debug logs are opt-in" do
    previous_level = Logger.level()
    Logger.configure(level: :debug)
    on_exit(fn -> Logger.configure(level: previous_level) end)

    constraint = HexSolver.parse_constraint!("~> 1.0")

    dependencies = [
      %{
        repo: nil,
        name: "left-pad",
        constraint: constraint,
        optional: false,
        label: "left-pad",
        dependencies: []
      }
    ]

    assert capture_log([level: :debug], fn ->
             assert {:ok, _} = HexSolver.run(HexSolverTest.Registry, dependencies, [], [])
           end) == ""

    assert capture_log([level: :debug], fn ->
             assert {:ok, _} =
                      HexSolver.run(HexSolverTest.Registry, dependencies, [], [], debug: true)
           end) =~ "RESOLVER:"
  end

  defp npm_version do
    [_, version] = Regex.run(~r/@version "([^"]+)"/, File.read!(@npm_mix_exs))
    version
  end

  defmodule Registry do
    @behaviour HexSolver.Registry

    @impl true
    def versions(nil, "left-pad") do
      {:ok, [Version.parse!("1.0.0"), Version.parse!("2.0.0")]}
    end

    def versions(_, _), do: :error

    @impl true
    def dependencies(nil, "left-pad", %Version{}) do
      {:ok, []}
    end

    def dependencies(_, _, _), do: :error

    @impl true
    def prefetch(_packages), do: :ok
  end
end
