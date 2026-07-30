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

  test "uses the install directory as the lock resource and the process as requester", %{
    tmp_dir: tmp_dir
  } do
    requester = make_ref()

    assert Installer.__lock_id__(tmp_dir, requester) ==
             {{Installer, Path.expand(tmp_dir)}, requester}
  end

  test "serializes concurrent forced installs into the same directory", %{tmp_dir: tmp_dir} do
    1..16
    |> Task.async_stream(
      fn _ -> Installer.install!(%{}, install_dir: tmp_dir, force: true) end,
      max_concurrency: 16,
      ordered: false,
      timeout: 30_000
    )
    |> Enum.each(fn
      {:ok, %{install_dir: ^tmp_dir}} -> :ok
    end)

    assert read_metadata(tmp_dir)["packages"] == %{}
  end

  defp read_metadata(install_dir) do
    install_dir
    |> Path.join("duskmoon-bundler-runtime.json")
    |> File.read!()
    |> Jason.decode!()
  end
end
