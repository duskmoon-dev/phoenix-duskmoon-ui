defmodule NPM.ConfigTest do
  use ExUnit.Case, async: false

  setup do
    old_cwd = File.cwd!()
    old_home = System.get_env("HOME")
    old_npm_token = System.get_env("NPM_TOKEN")
    old_prefetch_timeout = System.get_env("NPM_EX_PREFETCH_TIMEOUT_MS")
    old_app_token = Application.get_env(:duskmoon_npm, :token)
    old_app_prefetch_timeout = Application.get_env(:duskmoon_npm, :prefetch_timeout)

    tmp_dir =
      Path.join(System.tmp_dir!(), "npm_config_test_#{System.unique_integer([:positive])}")

    home_dir = Path.join(tmp_dir, "home")
    project_dir = Path.join(tmp_dir, "project")

    File.rm_rf!(tmp_dir)
    File.mkdir_p!(home_dir)
    File.mkdir_p!(project_dir)

    System.put_env("HOME", home_dir)
    System.delete_env("NPM_TOKEN")
    System.delete_env("NPM_EX_PREFETCH_TIMEOUT_MS")
    Application.delete_env(:duskmoon_npm, :token)
    Application.delete_env(:duskmoon_npm, :prefetch_timeout)
    File.cd!(project_dir)

    on_exit(fn ->
      File.cd!(old_cwd)
      restore_env("HOME", old_home)
      restore_env("NPM_TOKEN", old_npm_token)
      restore_env("NPM_EX_PREFETCH_TIMEOUT_MS", old_prefetch_timeout)
      restore_app_env(:token, old_app_token)
      restore_app_env(:prefetch_timeout, old_app_prefetch_timeout)
      File.rm_rf!(tmp_dir)
    end)

    {:ok, project_dir: project_dir}
  end

  test "does not reuse an npmjs auth token for a custom registry", %{project_dir: project_dir} do
    File.write!(Path.join(project_dir, ".npmrc"), """
    //registry.npmjs.org/:_authToken=npm-token
    registry=https://nexus.gsmlg.net/repository/npm/
    """)

    assert NPM.Config.auth_token("https://registry.npmjs.org") == "npm-token"
    refute NPM.Config.auth_token("https://nexus.gsmlg.net/repository/npm")
  end

  test "uses a token scoped to the custom registry path", %{project_dir: project_dir} do
    File.write!(Path.join(project_dir, ".npmrc"), """
    //nexus.gsmlg.net/repository/npm/:_authToken=nexus-token
    registry=https://nexus.gsmlg.net/repository/npm/
    """)

    assert NPM.Config.auth_token("https://nexus.gsmlg.net/repository/npm") == "nexus-token"
  end

  test "reads resolver prefetch timeout from app config" do
    Application.put_env(:duskmoon_npm, :prefetch_timeout, 120_000)

    assert NPM.Config.prefetch_timeout() == 120_000
  end

  test "prefers resolver prefetch timeout from environment" do
    Application.put_env(:duskmoon_npm, :prefetch_timeout, 120_000)
    System.put_env("NPM_EX_PREFETCH_TIMEOUT_MS", "180000")

    assert NPM.Config.prefetch_timeout() == 180_000
  end

  defp restore_env(name, nil), do: System.delete_env(name)
  defp restore_env(name, value), do: System.put_env(name, value)

  defp restore_app_env(key, nil), do: Application.delete_env(:duskmoon_npm, key)
  defp restore_app_env(key, value), do: Application.put_env(:duskmoon_npm, key, value)
end
