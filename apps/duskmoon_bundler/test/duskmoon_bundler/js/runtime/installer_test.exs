defmodule DuskmoonBundler.JS.Runtime.InstallerTest do
  use ExUnit.Case, async: false

  alias DuskmoonBundler.JS.Runtime.Installer

  setup do
    tmp_dir =
      Path.join(
        System.tmp_dir!(),
        "duskmoon_bundler-runtime-installer-test-#{System.unique_integer([:positive])}"
      )

    on_exit(fn -> File.rm_rf!(tmp_dir) end)

    %{tmp_dir: tmp_dir}
  end

  test "writes package metadata for an install directory", %{tmp_dir: tmp_dir} do
    install = Installer.install!(%{}, install_dir: tmp_dir)

    metadata = read_metadata(tmp_dir)

    assert install.install_dir == tmp_dir
    assert install.node_modules == Path.join(tmp_dir, "node_modules")
    assert metadata["packages"] == %{}
    assert is_binary(metadata["signature"])
  end

  test "same install directory with different packages rewrites metadata", %{tmp_dir: tmp_dir} do
    Installer.install!(%{}, install_dir: tmp_dir)
    first = read_metadata(tmp_dir)

    Installer.install!(%{"left-pad" => "1.3.0"}, install_dir: tmp_dir)
    second = read_metadata(tmp_dir)

    assert first["signature"] != second["signature"]
    assert second["packages"] == %{"left-pad" => "1.3.0"}
  end

  defp read_metadata(install_dir) do
    install_dir
    |> Path.join("duskmoon-bundler-runtime.json")
    |> File.read!()
    |> Jason.decode!()
  end
end
