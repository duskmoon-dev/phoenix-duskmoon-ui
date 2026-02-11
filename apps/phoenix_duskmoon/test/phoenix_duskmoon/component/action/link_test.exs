defmodule PhoenixDuskmoon.Component.Action.LinkTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.Action.Link

  test "renders basic link with href" do
    result =
      render_component(&dm_link/1, %{
        href: "/test",
        inner_block: %{inner_block: fn _, _ -> "Test Link" end}
      })

    assert result =~ ~s[<a class="dm-link dm-link--hover " href="/test">Test Link</a>]
  end

  test "renders link with custom id" do
    result =
      render_component(&dm_link/1, %{
        href: "/test",
        id: "test-link",
        inner_block: %{inner_block: fn _, _ -> "Test Link" end}
      })

    assert result =~
             ~s[<a id="test-link" class="dm-link dm-link--hover " href="/test">Test Link</a>]
  end

  test "renders link with custom class" do
    result =
      render_component(&dm_link/1, %{
        href: "/test",
        class: "text-blue-500",
        inner_block: %{inner_block: fn _, _ -> "Test Link" end}
      })

    assert result =~
             ~s[<a class="dm-link dm-link--hover text-blue-500" href="/test">Test Link</a>]
  end

  test "renders link with navigate attribute" do
    result =
      render_component(&dm_link/1, %{
        navigate: "/live-route",
        inner_block: %{inner_block: fn _, _ -> "Live Link" end}
      })

    assert result =~ ~s[<a class="dm-link dm-link--hover " href="/live-route"]
    assert result =~ ~s[data-phx-link="redirect"]
    assert result =~ ~s[data-phx-link-state="push"]
    assert result =~ ~s[>Live Link</a>]
  end

  test "renders link with navigate and replace attributes" do
    result =
      render_component(&dm_link/1, %{
        navigate: "/live-route",
        replace: true,
        inner_block: %{inner_block: fn _, _ -> "Replace Link" end}
      })

    assert result =~ ~s[data-phx-link-state="replace"]
    assert result =~ ~s[>Replace Link</a>]
  end

  test "renders link with patch attribute" do
    result =
      render_component(&dm_link/1, %{
        patch: "/patch-route",
        inner_block: %{inner_block: fn _, _ -> "Patch Link" end}
      })

    assert result =~ ~s[<a class="dm-link dm-link--hover " href="/patch-route"]
    assert result =~ ~s[data-phx-link="patch"]
    assert result =~ ~s[data-phx-link-state="push"]
    assert result =~ ~s[>Patch Link</a>]
  end

  test "renders link with patch and replace attributes" do
    result =
      render_component(&dm_link/1, %{
        patch: "/patch-route",
        replace: true,
        inner_block: %{inner_block: fn _, _ -> "Replace Patch Link" end}
      })

    assert result =~ ~s[data-phx-link-state="replace"]
    assert result =~ ~s[>Replace Patch Link</a>]
  end

  test "renders link with post method" do
    result =
      render_component(&dm_link/1, %{
        href: "/submit",
        method: "post",
        inner_block: %{inner_block: fn _, _ -> "Submit" end}
      })

    assert result =~ ~s[data-method="post"]
    assert result =~ ~s[data-csrf="]
    assert result =~ ~s[data-to="/submit"]
    assert result =~ ~s[>Submit</a>]
  end

  test "renders link with delete method" do
    result =
      render_component(&dm_link/1, %{
        href: "/delete",
        method: "delete",
        inner_block: %{inner_block: fn _, _ -> "Delete" end}
      })

    assert result =~ ~s[data-method="delete"]
    assert result =~ ~s[data-csrf="]
    assert result =~ ~s[data-to="/delete"]
    assert result =~ ~s[>Delete</a>]
  end

  test "renders link with custom csrf token" do
    result =
      render_component(&dm_link/1, %{
        href: "/submit",
        method: "post",
        csrf_token: "custom-token",
        inner_block: %{inner_block: fn _, _ -> "Submit" end}
      })

    assert result =~ ~s[data-csrf="custom-token"]
  end

  test "renders link with disabled csrf token" do
    result =
      render_component(&dm_link/1, %{
        href: "/submit",
        method: "post",
        csrf_token: false,
        inner_block: %{inner_block: fn _, _ -> "Submit" end}
      })

    assert result =~ ~s[data-method="post"]
    refute result =~ ~s[data-csrf=]
  end

  test "renders link with global attributes" do
    result =
      render_component(&dm_link/1, %{
        href: "/test",
        "data-testid": "test-link",
        "aria-label": "Test link",
        download: true,
        inner_block: %{inner_block: fn _, _ -> "Test Link" end}
      })

    assert result =~ ~s[data-testid="test-link"]
    assert result =~ ~s[aria-label="Test link"]
    assert result =~ ~s[download]
  end

  test "renders link with href='#' when no navigation attributes provided" do
    result =
      render_component(&dm_link/1, %{
        inner_block: %{inner_block: fn _, _ -> "Default Link" end}
      })

    assert result =~ ~s[<a class="dm-link dm-link--hover " href="#">Default Link</a>]
  end

  test "renders link with href='#' when href is nil" do
    result =
      render_component(&dm_link/1, %{
        href: nil,
        inner_block: %{inner_block: fn _, _ -> "Nil Link" end}
      })

    assert result =~ ~s[<a class="dm-link dm-link--hover " href="#">Nil Link</a>]
  end

  test "renders link with href='#' when href is '#'" do
    result =
      render_component(&dm_link/1, %{
        href: "#",
        inner_block: %{inner_block: fn _, _ -> "Hash Link" end}
      })

    assert result =~ ~s[<a class="dm-link dm-link--hover " href="#">Hash Link</a>]
  end

  test "renders link with get method (default)" do
    result =
      render_component(&dm_link/1, %{
        href: "/get-request",
        method: "get",
        inner_block: %{inner_block: fn _, _ -> "Get Request" end}
      })

    refute result =~ ~s[data-method=]
    refute result =~ ~s[data-csrf=]
    refute result =~ ~s[data-to=]
    assert result =~ ~s[<a class="dm-link dm-link--hover " href="/get-request">Get Request</a>]
  end

  test "renders link with target attribute" do
    result =
      render_component(&dm_link/1, %{
        href: "/external",
        target: "_blank",
        inner_block: %{inner_block: fn _, _ -> "External Link" end}
      })

    assert result =~ ~s[target="_blank"]
    assert result =~ ~s[>External Link</a>]
  end

  test "renders link with rel attribute" do
    result =
      render_component(&dm_link/1, %{
        href: "/external",
        rel: "noopener noreferrer",
        inner_block: %{inner_block: fn _, _ -> "Safe External Link" end}
      })

    assert result =~ ~s[rel="noopener noreferrer"]
    assert result =~ ~s[>Safe External Link</a>]
  end

  test "renders link with put method" do
    result =
      render_component(&dm_link/1, %{
        href: "/update",
        method: "put",
        inner_block: %{inner_block: fn _, _ -> "Update" end}
      })

    assert result =~ ~s[data-method="put"]
    assert result =~ ~s[data-csrf="]
    assert result =~ ~s[data-to="/update"]
  end

  test "renders link with dm-link base class always" do
    result =
      render_component(&dm_link/1, %{
        href: "/test",
        inner_block: %{inner_block: fn _, _ -> "Test" end}
      })

    assert result =~ "dm-link"
    assert result =~ "dm-link--hover"
  end

  test "renders navigate link as anchor tag" do
    result =
      render_component(&dm_link/1, %{
        navigate: "/dashboard",
        inner_block: %{inner_block: fn _, _ -> "Dashboard" end}
      })

    assert result =~ "<a"
    assert result =~ "</a>"
  end

  test "renders patch link as anchor tag" do
    result =
      render_component(&dm_link/1, %{
        patch: "/settings",
        inner_block: %{inner_block: fn _, _ -> "Settings" end}
      })

    assert result =~ "<a"
    assert result =~ "</a>"
  end

  test "renders link with target and rel combined" do
    result =
      render_component(&dm_link/1, %{
        href: "https://example.com",
        target: "_blank",
        rel: "noopener",
        inner_block: %{inner_block: fn _, _ -> "External" end}
      })

    assert result =~ ~s[target="_blank"]
    assert result =~ ~s[rel="noopener"]
    assert result =~ ~s[href="https://example.com"]
  end

  test "renders link with class nil (no extra class)" do
    result =
      render_component(&dm_link/1, %{
        href: "/test",
        inner_block: %{inner_block: fn _, _ -> "Test" end}
      })

    assert result =~ "dm-link dm-link--hover"
  end

  test "renders fallback link has anchor tag" do
    result =
      render_component(&dm_link/1, %{
        inner_block: %{inner_block: fn _, _ -> "Fallback" end}
      })

    assert result =~ "<a"
    assert result =~ ~s[href="#"]
  end

  test "renders navigate link with all options" do
    result =
      render_component(&dm_link/1, %{
        id: "nav-link",
        navigate: "/dashboard",
        replace: true,
        class: "text-bold",
        "data-testid": "nav",
        inner_block: %{inner_block: fn _, _ -> "Dashboard" end}
      })

    assert result =~ ~s[id="nav-link"]
    assert result =~ ~s[href="/dashboard"]
    assert result =~ ~s[data-phx-link="redirect"]
    assert result =~ ~s[data-phx-link-state="replace"]
    assert result =~ "text-bold"
    assert result =~ "data-testid=\"nav\""
    assert result =~ "Dashboard"
  end

  test "renders patch link with all options" do
    result =
      render_component(&dm_link/1, %{
        id: "patch-link",
        patch: "/settings/edit",
        replace: false,
        class: "underline",
        inner_block: %{inner_block: fn _, _ -> "Edit" end}
      })

    assert result =~ ~s[id="patch-link"]
    assert result =~ ~s[href="/settings/edit"]
    assert result =~ ~s[data-phx-link="patch"]
    assert result =~ ~s[data-phx-link-state="push"]
    assert result =~ "underline"
    assert result =~ "Edit"
  end

  test "renders href link with all options" do
    result =
      render_component(&dm_link/1, %{
        id: "full-link",
        href: "/api/submit",
        method: "post",
        csrf_token: "my-token",
        class: "btn",
        target: "_blank",
        rel: "noopener",
        inner_block: %{inner_block: fn _, _ -> "Submit" end}
      })

    assert result =~ ~s[id="full-link"]
    assert result =~ ~s[href="/api/submit"]
    assert result =~ ~s[data-method="post"]
    assert result =~ ~s[data-csrf="my-token"]
    assert result =~ ~s[data-to="/api/submit"]
    assert result =~ "btn"
    assert result =~ ~s[target="_blank"]
    assert result =~ ~s[rel="noopener"]
    assert result =~ "Submit"
  end

  test "renders navigate link with replace false uses push state" do
    result =
      render_component(&dm_link/1, %{
        navigate: "/test",
        replace: false,
        inner_block: %{inner_block: fn _, _ -> "Test" end}
      })

    assert result =~ ~s[data-phx-link-state="push"]
  end

  test "renders fallback link with custom id and class" do
    result =
      render_component(&dm_link/1, %{
        id: "fallback",
        class: "inactive-link",
        inner_block: %{inner_block: fn _, _ -> "No Nav" end}
      })

    assert result =~ ~s[id="fallback"]
    assert result =~ "inactive-link"
    assert result =~ ~s[href="#"]
    assert result =~ "No Nav"
  end

  test "renders link with disabled attribute" do
    result =
      render_component(&dm_link/1, %{
        href: "/test",
        disabled: true,
        inner_block: %{inner_block: fn _, _ -> "Disabled" end}
      })

    assert result =~ "disabled"
  end

  test "renders link with hreflang attribute" do
    result =
      render_component(&dm_link/1, %{
        href: "/fr/page",
        hreflang: "fr",
        inner_block: %{inner_block: fn _, _ -> "French" end}
      })

    assert result =~ ~s[hreflang="fr"]
  end

  test "renders link with download attribute" do
    result =
      render_component(&dm_link/1, %{
        href: "/file.pdf",
        download: "report.pdf",
        inner_block: %{inner_block: fn _, _ -> "Download" end}
      })

    assert result =~ "download"
    assert result =~ "report.pdf"
  end
end
