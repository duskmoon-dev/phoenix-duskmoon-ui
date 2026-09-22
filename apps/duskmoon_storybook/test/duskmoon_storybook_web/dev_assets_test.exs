defmodule DuskmoonStorybookWeb.DevAssetsTest do
  use ExUnit.Case, async: false

  alias DuskmoonBundler.DevServer

  @project_root Path.expand("../../../..", __DIR__)
  @source_root Path.join(@project_root, "apps/duskmoon_storybook/assets/js")

  test "application imports remain valid while the umbrella compiler changes directories" do
    original_cwd = File.cwd!()
    on_exit(fn -> File.cd!(original_cwd) end)

    File.cd!(@project_root)
    config = asset_config()
    response = DevServer.call(Plug.Test.conn(:get, "/assets/js/app.js?hash=storybook"), config)
    assert response.status == 200
    assert response.halted

    assert [_, vendor_url] =
             Regex.run(~r/import "([^"]*phoenix_html\.js[^\"]*)"/, response.resp_body)

    File.cd!(Path.join(@project_root, "apps/duskmoon_oxc"))
    child_config = asset_config()

    child_response =
      DevServer.call(Plug.Test.conn(:get, "/assets/js/app.js?hash=storybook"), child_config)

    assert child_response.status == 200
    assert child_response.halted
    assert child_response.resp_body == response.resp_body

    vendor_response = DevServer.call(Plug.Test.conn(:get, vendor_url), child_config)
    assert vendor_response.status == 200
    refute vendor_response.resp_body =~ "outdated optimized dependency"
  end

  defp asset_config do
    DevServer.init(profile: :duskmoon_storybook, root: @source_root, prefix: "/assets/js")
  end
end
