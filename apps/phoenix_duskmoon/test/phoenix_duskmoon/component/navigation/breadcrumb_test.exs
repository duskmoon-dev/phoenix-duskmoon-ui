defmodule PhoenixDuskmoon.Component.Navigation.BreadcrumbTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.Navigation.Breadcrumb

  defp crumbs(list) do
    Enum.map(list, fn
      {text, opts} -> Map.merge(%{inner_block: fn _, _ -> text end}, opts)
      text -> %{inner_block: fn _, _ -> text end}
    end)
  end

  test "renders el-dm-breadcrumbs element" do
    result =
      render_component(&dm_breadcrumb/1, %{
        crumb: crumbs(["Home", "Products"])
      })

    assert result =~ "<el-dm-breadcrumbs"
    assert result =~ "</el-dm-breadcrumbs>"
    assert result =~ "Home"
    assert result =~ "Products"
  end

  test "renders crumb items with slot attribute" do
    result = render_component(&dm_breadcrumb/1, %{crumb: crumbs(["Home"])})

    assert result =~ ~s[slot="item"]
  end

  test "renders crumbs with links when to is provided" do
    result =
      render_component(&dm_breadcrumb/1, %{
        crumb:
          crumbs([
            {"Home", %{to: "/"}},
            {"Products", %{to: "/products"}},
            "Detail"
          ])
      })

    assert result =~ ~s[href="/"]
    assert result =~ ~s[href="/products"]
    assert result =~ "Home"
    assert result =~ "Detail"
  end

  test "renders crumbs without links when to is not provided" do
    result = render_component(&dm_breadcrumb/1, %{crumb: crumbs(["Page"])})

    refute result =~ "<a "
  end

  test "renders data-href on linked crumbs" do
    result =
      render_component(&dm_breadcrumb/1, %{
        crumb: crumbs([{"Home", %{to: "/home"}}])
      })

    assert result =~ ~s[data-href="/home"]
  end

  test "renders last crumb with aria-current page" do
    result =
      render_component(&dm_breadcrumb/1, %{
        crumb: crumbs(["Home", "Current"])
      })

    assert result =~ ~s[aria-current="page"]
  end

  test "renders single crumb with aria-current page" do
    result = render_component(&dm_breadcrumb/1, %{crumb: crumbs(["Only"])})

    assert result =~ ~s[aria-current="page"]
  end

  test "renders breadcrumb with custom id" do
    result =
      render_component(&dm_breadcrumb/1, %{
        id: "nav-breadcrumb",
        crumb: crumbs(["Home"])
      })

    assert result =~ ~s[id="nav-breadcrumb"]
  end

  test "renders breadcrumb with custom class" do
    result =
      render_component(&dm_breadcrumb/1, %{
        class: "my-breadcrumb",
        crumb: crumbs(["Home"])
      })

    assert result =~ "my-breadcrumb"
  end

  test "renders breadcrumb with separator" do
    result =
      render_component(&dm_breadcrumb/1, %{
        separator: ">",
        crumb: crumbs(["Home", "Page"])
      })

    assert result =~ "separator"
  end

  test "renders crumb with id sub-attribute" do
    result =
      render_component(&dm_breadcrumb/1, %{
        crumb: crumbs([{"Home", %{id: "crumb-home"}}])
      })

    assert result =~ ~s[id="crumb-home"]
  end

  test "renders crumb with class sub-attribute" do
    result =
      render_component(&dm_breadcrumb/1, %{
        crumb: crumbs([{"Home", %{class: "font-bold"}}])
      })

    assert result =~ "font-bold"
  end

  test "renders breadcrumb with rest attributes" do
    result =
      render_component(&dm_breadcrumb/1, %{
        "data-testid": "breadcrumb-nav",
        crumb: crumbs(["Home"])
      })

    assert result =~ ~s[data-testid="breadcrumb-nav"]
  end

  test "renders multiple crumbs with mixed linked and unlinked" do
    result =
      render_component(&dm_breadcrumb/1, %{
        crumb:
          crumbs([
            {"Home", %{to: "/"}},
            "Category",
            {"Sub", %{to: "/sub"}},
            "Final"
          ])
      })

    assert result =~ ~s[href="/"]
    assert result =~ ~s[href="/sub"]
    assert result =~ "Category"
    assert result =~ "Final"
  end
end
