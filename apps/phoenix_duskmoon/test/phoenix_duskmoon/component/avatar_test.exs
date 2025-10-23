defmodule PhoenixDuskmoon.Component.AvatarTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.Avatar

  test "renders avatar with image" do
    result =
      render_component(&dm_avatar/1, %{
        src: "https://example.com/avatar.jpg",
        alt: "User Avatar"
      })

    assert result =~ ~s[<div class="avatar ]
    assert result =~ ~s[w-md rounded-circle]

    assert result =~
             ~s[<img src="https://example.com/avatar.jpg" alt="User Avatar" class="w-full h-full object-cover ]
  end

  test "renders avatar with name placeholder" do
    result =
      render_component(&dm_avatar/1, %{
        name: "John Doe",
        size: "lg"
      })

    assert result =~ ~s[w-lg]
    assert result =~ ~s[JD]
  end

  test "renders avatar with online status" do
    result =
      render_component(&dm_avatar/1, %{
        src: "https://example.com/avatar.jpg",
        alt: "User Avatar",
        online: true
      })

    assert result =~ ~s[bg-success]
    assert result =~ ~s[border-2 border-base-100]
  end

  test "renders avatar with border" do
    result =
      render_component(&dm_avatar/1, %{
        src: "https://example.com/avatar.jpg",
        alt: "User Avatar",
        border: true
      })

    assert result =~ ~s[avatar-border]
  end

  test "renders avatar with square shape" do
    result =
      render_component(&dm_avatar/1, %{
        name: "Test",
        shape: "square"
      })

    assert result =~ ~s[rounded-square]
  end

  test "renders avatar with custom color" do
    result =
      render_component(&dm_avatar/1, %{
        name: "Test",
        color: "success"
      })

    assert result =~ ~s[bg-success]
    assert result =~ ~s[text-success-content]
  end

  test "renders avatar with placeholder image" do
    result =
      render_component(&dm_avatar/1, %{
        placeholder_img: "/path/to/placeholder.jpg",
        alt: "Placeholder"
      })

    assert result =~
             ~s[<img src="/path/to/placeholder.jpg" alt="Placeholder" class="w-full h-full object-cover">]
  end

  test "renders avatar with default user icon when no name" do
    result = render_component(&dm_avatar/1, %{})

    assert result =~ ~s[<svg]
    assert result =~ ~s[fill-rule="evenodd"]
    assert result =~ ~s[clip-rule="evenodd"]
  end
end
