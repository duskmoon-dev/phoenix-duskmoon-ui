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

  test "renders breadcrumb crumbs with links" do
    result =
      render_component(&dm_breadcrumb/1, %{
        crumb: [
          %{to: "/", inner_block: fn _, _ -> "Home" end},
          %{to: "/products", inner_block: fn _, _ -> "Products" end},
          %{inner_block: fn _, _ -> "Detail" end}
        ]
      })

    assert result =~ ~s[href="/"]
    assert result =~ ~s[href="/products"]
    assert result =~ "Home"
    assert result =~ "Products"
    assert result =~ "Detail"
  end

  test "renders breadcrumb with separator" do
    result =
      render_component(&dm_breadcrumb/1, %{
        separator: ">",
        crumb: [
          %{inner_block: fn _, _ -> "Home" end},
          %{inner_block: fn _, _ -> "Page" end}
        ]
      })

    assert result =~ "separator=\"&gt;\""
  end

  test "renders last crumb with aria-current page" do
    result =
      render_component(&dm_breadcrumb/1, %{
        crumb: [
          %{inner_block: fn _, _ -> "Home" end},
          %{inner_block: fn _, _ -> "Current" end}
        ]
      })

    assert result =~ ~s[aria-current="page"]
  end

  test "renders crumb items with slot attribute" do
    result =
      render_component(&dm_breadcrumb/1, %{
        crumb: [
          %{inner_block: fn _, _ -> "Home" end}
        ]
      })

    assert result =~ ~s[slot="item"]
  end

  test "renders breadcrumb with crumb id and class" do
    result =
      render_component(&dm_breadcrumb/1, %{
        crumb: [
          %{id: "crumb-home", class: "font-bold", inner_block: fn _, _ -> "Home" end}
        ]
      })

    assert result =~ ~s[id="crumb-home"]
    assert result =~ "font-bold"
  end

  test "renders breadcrumb with rest attributes" do
    result =
      render_component(&dm_breadcrumb/1, %{
        "data-testid": "breadcrumb-nav",
        crumb: [
          %{inner_block: fn _, _ -> "Home" end}
        ]
      })

    assert result =~ ~s[data-testid="breadcrumb-nav"]
  end

  test "renders single crumb with aria-current page" do
    result =
      render_component(&dm_breadcrumb/1, %{
        crumb: [
          %{inner_block: fn _, _ -> "Only Page" end}
        ]
      })

    # Single crumb is both first and last, so it gets aria-current
    assert result =~ ~s[aria-current="page"]
  end
end
