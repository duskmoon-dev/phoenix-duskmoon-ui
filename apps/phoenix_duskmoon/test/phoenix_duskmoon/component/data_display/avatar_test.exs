defmodule PhoenixDuskmoon.Component.DataDisplay.AvatarTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.DataDisplay.Avatar

  test "renders avatar with image src and alt" do
    result =
      render_component(&dm_avatar/1, %{
        src: "https://example.com/avatar.jpg",
        alt: "User Avatar"
      })

    assert result =~ "avatar"
    assert result =~ ~s[src="https://example.com/avatar.jpg"]
    assert result =~ ~s[alt="User Avatar"]
    assert result =~ "object-cover"
  end

  test "renders avatar with default circle shape" do
    result = render_component(&dm_avatar/1, %{src: "https://example.com/a.jpg"})

    assert result =~ "rounded-circle"
  end

  test "renders avatar with square shape" do
    result = render_component(&dm_avatar/1, %{name: "Test", shape: "square"})

    assert result =~ "rounded-square"
  end

  test "renders avatar with default size md" do
    result = render_component(&dm_avatar/1, %{src: "https://example.com/a.jpg"})

    assert result =~ "w-md"
  end

  test "renders avatar with all size options" do
    for size <- ~w(xs sm md lg xl) do
      result = render_component(&dm_avatar/1, %{name: "T", size: size})
      assert result =~ "w-#{size}"
    end
  end

  test "renders avatar with name showing initials" do
    result = render_component(&dm_avatar/1, %{name: "John Doe"})

    assert result =~ "JD"
  end

  test "renders avatar with single name initial" do
    result = render_component(&dm_avatar/1, %{name: "Alice"})

    assert result =~ "A"
  end

  test "renders avatar with default color primary" do
    result = render_component(&dm_avatar/1, %{name: "Test"})

    assert result =~ "bg-primary"
  end

  test "renders avatar with all color options" do
    for color <- ~w(primary secondary accent info success warning error) do
      result = render_component(&dm_avatar/1, %{name: "T", color: color})
      assert result =~ "bg-#{color}"
    end
  end

  test "renders avatar with border" do
    result = render_component(&dm_avatar/1, %{name: "T", border: true})

    assert result =~ "avatar-border"
  end

  test "renders avatar without border by default" do
    result = render_component(&dm_avatar/1, %{name: "T"})

    refute result =~ "avatar-border"
  end

  test "renders avatar with online indicator" do
    result = render_component(&dm_avatar/1, %{name: "T", online: true})

    assert result =~ "bg-success"
    assert result =~ "border-2 border-base-100"
  end

  test "renders avatar with offline indicator" do
    result = render_component(&dm_avatar/1, %{name: "T", offline: true})

    assert result =~ "bg-base-300"
  end

  test "renders avatar with placeholder image" do
    result =
      render_component(&dm_avatar/1, %{
        placeholder_img: "/path/to/placeholder.jpg"
      })

    assert result =~ ~s[src="/path/to/placeholder.jpg"]
    assert result =~ ~s[alt="Placeholder"]
  end

  test "renders default user icon svg when no name or src" do
    result = render_component(&dm_avatar/1, %{})

    assert result =~ "<svg"
    assert result =~ ~s[fill-rule="evenodd"]
    assert result =~ ~s[viewBox="0 0 20 20"]
  end

  test "renders avatar with custom class" do
    result = render_component(&dm_avatar/1, %{name: "T", class: "my-avatar"})

    assert result =~ "my-avatar"
  end

  test "renders avatar with img_class" do
    result =
      render_component(&dm_avatar/1, %{
        src: "https://example.com/a.jpg",
        img_class: "custom-img"
      })

    assert result =~ "custom-img"
  end

  test "renders avatar with placeholder_class" do
    result =
      render_component(&dm_avatar/1, %{
        name: "T",
        placeholder_class: "custom-placeholder"
      })

    assert result =~ "custom-placeholder"
  end

  test "renders avatar with rest attributes on img" do
    result =
      render_component(&dm_avatar/1, %{
        src: "https://example.com/a.jpg",
        "data-testid": "user-avatar"
      })

    assert result =~ "data-testid=\"user-avatar\""
  end

  test "renders avatar with three word name initials" do
    result = render_component(&dm_avatar/1, %{name: "Alice Bob Charlie"})

    # Should show first+last initials
    assert result =~ "A"
  end

  test "renders avatar img element with src" do
    result =
      render_component(&dm_avatar/1, %{
        src: "https://example.com/photo.png"
      })

    assert result =~ "<img"
    assert result =~ ~s[src="https://example.com/photo.png"]
  end

  test "renders avatar with both online and border" do
    result =
      render_component(&dm_avatar/1, %{
        name: "T",
        online: true,
        border: true
      })

    assert result =~ "avatar-border"
    assert result =~ "bg-success"
  end

  test "renders avatar wrapper div" do
    result = render_component(&dm_avatar/1, %{name: "T"})

    assert result =~ "<div"
    assert result =~ "avatar"
  end

  test "renders avatar with name and color combined" do
    result =
      render_component(&dm_avatar/1, %{
        name: "JD",
        color: "error"
      })

    assert result =~ "bg-error"
    assert result =~ "J"
  end

  test "renders online indicator with aria-label" do
    result = render_component(&dm_avatar/1, %{name: "T", online: true})

    assert result =~ ~s[aria-label="Online"]
  end

  test "renders offline indicator with aria-label" do
    result = render_component(&dm_avatar/1, %{name: "T", offline: true})

    assert result =~ ~s[aria-label="Offline"]
  end

  test "renders default svg icon with role img and aria-label" do
    result = render_component(&dm_avatar/1, %{})

    assert result =~ ~s[role="img"]
    assert result =~ ~s[aria-label="User"]
  end

  test "renders avatar with three word name takes first two initials" do
    result = render_component(&dm_avatar/1, %{name: "Alice Bob Charlie"})

    # Enum.take(2) means first two words: "A" + "B"
    assert result =~ "AB"
  end

  test "renders avatar with empty name shows default SVG icon" do
    result = render_component(&dm_avatar/1, %{name: ""})

    assert result =~ "<svg"
    assert result =~ ~s[aria-label="User"]
  end

  test "renders avatar with nil name shows default SVG icon" do
    result = render_component(&dm_avatar/1, %{name: nil})

    assert result =~ "<svg"
    assert result =~ ~s[aria-label="User"]
  end

  test "renders avatar with placeholder_img true shows initials" do
    result = render_component(&dm_avatar/1, %{name: "Jane Smith", placeholder_img: true})

    assert result =~ "JS"
  end

  test "renders avatar with placeholder_img string shows custom image" do
    result =
      render_component(&dm_avatar/1, %{
        name: "Jane",
        placeholder_img: "/img/placeholder.png"
      })

    assert result =~ ~s[src="/img/placeholder.png"]
    assert result =~ ~s[alt="Placeholder"]
    # Should NOT show initials when placeholder_img is a string
    refute result =~ ">J<"
  end

  test "renders avatar without online/offline indicator by default" do
    result = render_component(&dm_avatar/1, %{name: "T"})

    refute result =~ ~s[aria-label="Online"]
    refute result =~ ~s[aria-label="Offline"]
  end

  test "renders avatar with src does not show placeholder div" do
    result =
      render_component(&dm_avatar/1, %{
        src: "https://example.com/img.jpg",
        alt: "User"
      })

    # Should have img tag, not the SVG default icon
    assert result =~ "<img"
    assert result =~ ~s[src="https://example.com/img.jpg"]
    refute result =~ ~s[aria-label="User"]
  end

  test "renders avatar initials in uppercase" do
    result = render_component(&dm_avatar/1, %{name: "john doe"})

    assert result =~ "JD"
  end

  test "renders avatar initials content in text-lg span" do
    result = render_component(&dm_avatar/1, %{name: "Test User"})

    assert result =~ "text-lg"
    assert result =~ "TU"
  end
end
