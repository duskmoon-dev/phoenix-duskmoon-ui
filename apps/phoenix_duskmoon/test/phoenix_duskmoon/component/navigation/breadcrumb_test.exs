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

  test "renders separator attribute value on el-dm-breadcrumbs" do
    result =
      render_component(&dm_breadcrumb/1, %{
        separator: "/",
        crumb: crumbs(["Home", "Page"])
      })

    assert result =~ ~s[separator="/"]
  end

  test "renders crumb with both to and class" do
    result =
      render_component(&dm_breadcrumb/1, %{
        crumb: crumbs([{"Home", %{to: "/", class: "font-bold"}}])
      })

    assert result =~ ~s[href="/"]
    assert result =~ "font-bold"
    assert result =~ ~s[data-href="/"]
  end

  test "renders only last crumb with aria-current in long chain" do
    result =
      render_component(&dm_breadcrumb/1, %{
        crumb: crumbs(["A", "B", "C", "D", "E"])
      })

    # Only the last crumb should have aria-current
    parts = String.split(result, ~s[aria-current="page"])
    assert length(parts) - 1 == 1
  end

  test "renders first crumb without aria-current when multiple" do
    result =
      render_component(&dm_breadcrumb/1, %{
        crumb: crumbs(["Home", "Products", "Detail"])
      })

    # Split by each span with slot="item" to inspect individually
    assert result =~ ~s[aria-current="page"]
    assert result =~ "Detail"
  end

  test "renders crumb with id and class and link combined" do
    result =
      render_component(&dm_breadcrumb/1, %{
        crumb: crumbs([{"Dashboard", %{id: "crumb-dash", class: "active", to: "/dash"}}])
      })

    assert result =~ ~s[id="crumb-dash"]
    assert result =~ "active"
    assert result =~ ~s[href="/dash"]
  end

  test "renders breadcrumb without separator by default" do
    result =
      render_component(&dm_breadcrumb/1, %{
        crumb: crumbs(["Home"])
      })

    refute result =~ ~s[separator="]
  end

  test "renders breadcrumb with arrow separator" do
    result =
      render_component(&dm_breadcrumb/1, %{
        separator: ">>",
        crumb: crumbs(["Home", "Page"])
      })

    assert result =~ ~s[separator="&gt;&gt;"]
  end

  test "renders breadcrumb with all attributes combined" do
    result =
      render_component(&dm_breadcrumb/1, %{
        id: "main-breadcrumb",
        class: "text-sm",
        separator: ">",
        "aria-label": "Breadcrumb navigation",
        crumb:
          crumbs([
            {"Home", %{to: "/", id: "c-home", class: "font-bold"}},
            {"Products", %{to: "/products"}},
            "Current Item"
          ])
      })

    assert result =~ ~s[id="main-breadcrumb"]
    assert result =~ "text-sm"
    assert result =~ "separator"
    assert result =~ "aria-label=\"Breadcrumb navigation\""
    assert result =~ ~s[href="/"]
    assert result =~ ~s[id="c-home"]
    assert result =~ "font-bold"
    assert result =~ ~s[href="/products"]
    assert result =~ "Current Item"
    assert result =~ ~s[aria-current="page"]
  end

  test "renders breadcrumb with default aria-label" do
    result =
      render_component(&dm_breadcrumb/1, %{
        crumb: crumbs(["Home"])
      })

    assert result =~ ~s[aria-label="Breadcrumb"]
  end

  test "renders breadcrumb using el-dm-breadcrumbs custom element" do
    result =
      render_component(&dm_breadcrumb/1, %{
        crumb: crumbs(["Home"])
      })

    assert result =~ "<el-dm-breadcrumbs"
    assert result =~ "</el-dm-breadcrumbs>"
  end

  test "renders breadcrumb items with slot attribute" do
    result =
      render_component(&dm_breadcrumb/1, %{
        crumb: crumbs(["Home", "Products"])
      })

    assert result =~ ~s[slot="item"]
  end

  test "renders breadcrumb with data-href on linked items" do
    result =
      render_component(&dm_breadcrumb/1, %{
        crumb: crumbs([{"Home", %{to: "/"}}, "Current"])
      })

    assert result =~ ~s[data-href="/"]
  end

  test "renders only last crumb with aria-current page" do
    result =
      render_component(&dm_breadcrumb/1, %{
        crumb: crumbs(["Home", "Products", "Details"])
      })

    # Only last item should have aria-current="page"
    page_count = length(String.split(result, ~s[aria-current="page"])) - 1
    assert page_count == 1
    assert result =~ "Details"
  end

  test "renders linked crumb as anchor tag" do
    result =
      render_component(&dm_breadcrumb/1, %{
        crumb: crumbs([{"Home", %{to: "/"}}])
      })

    assert result =~ "<a"
    assert result =~ ~s[href="/"]
    assert result =~ "Home"
  end

  test "renders non-linked crumb without anchor tag wrapping" do
    result =
      render_component(&dm_breadcrumb/1, %{
        crumb: crumbs(["Plain Text"])
      })

    assert result =~ "Plain Text"
    # The text should be rendered without an anchor wrapper
    assert result =~ ~s[slot="item"]
  end
end
