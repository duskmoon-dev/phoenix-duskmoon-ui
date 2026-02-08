defmodule PhoenixDuskmoon.Component.Navigation.BreadcrumbTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.Navigation.Breadcrumb

  test "renders basic breadcrumb" do
    result =
      render_component(&dm_breadcrumb/1, %{
        crumb: [
          %{inner_block: fn _, _ -> "Home" end},
          %{inner_block: fn _, _ -> "Products" end}
        ]
      })

    assert result =~ "<el-dm-breadcrumbs"
    assert result =~ "Home"
    assert result =~ "Products"
  end

  test "renders breadcrumb with custom class" do
    result =
      render_component(&dm_breadcrumb/1, %{
        class: "my-breadcrumb",
        crumb: [
          %{inner_block: fn _, _ -> "Home" end}
        ]
      })

    assert result =~ "my-breadcrumb"
  end

  test "renders breadcrumb with id" do
    result =
      render_component(&dm_breadcrumb/1, %{
        id: "nav-breadcrumb",
        crumb: [
          %{inner_block: fn _, _ -> "Home" end}
        ]
      })

    assert result =~ ~s[id="nav-breadcrumb"]
  end
end
