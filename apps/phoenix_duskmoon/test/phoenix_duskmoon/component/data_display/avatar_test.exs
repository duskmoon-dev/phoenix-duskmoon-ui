defmodule PhoenixDuskmoon.Component.DataDisplay.AvatarTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.DataDisplay.Avatar

  describe "dm_avatar basic rendering" do
    test "renders avatar wrapper div" do
      result = render_component(&dm_avatar/1, %{name: "T"})
      assert result =~ "<div"
      assert result =~ "avatar"
    end

    test "renders avatar with image src and alt" do
      result =
        render_component(&dm_avatar/1, %{
          src: "https://example.com/avatar.jpg",
          alt: "User Avatar"
        })

      assert result =~ ~s[src="https://example.com/avatar.jpg"]
      assert result =~ ~s[alt="User Avatar"]
    end

    test "renders img element when src provided" do
      result = render_component(&dm_avatar/1, %{src: "https://example.com/photo.png"})
      assert result =~ "<img"
      assert result =~ ~s[src="https://example.com/photo.png"]
    end

    test "renders with custom class" do
      result = render_component(&dm_avatar/1, %{name: "T", class: "my-avatar"})
      assert result =~ "my-avatar"
    end

    test "renders with img_class" do
      result =
        render_component(&dm_avatar/1, %{
          src: "https://example.com/a.jpg",
          img_class: "custom-img"
        })

      assert result =~ "custom-img"
    end

    test "renders rest attributes" do
      result =
        render_component(&dm_avatar/1, %{
          src: "https://example.com/a.jpg",
          "data-testid": "user-avatar"
        })

      assert result =~ ~s[data-testid="user-avatar"]
    end
  end

  describe "dm_avatar sizes" do
    test "defaults to md" do
      result = render_component(&dm_avatar/1, %{src: "https://example.com/a.jpg"})
      assert result =~ "avatar-md"
    end

    test "renders all size options" do
      for size <- ~w(xs sm md lg xl) do
        result = render_component(&dm_avatar/1, %{name: "T", size: size})
        assert result =~ "avatar-#{size}"
      end
    end
  end

  describe "dm_avatar shapes" do
    test "defaults to circle (no extra class)" do
      result = render_component(&dm_avatar/1, %{src: "https://example.com/a.jpg"})
      refute result =~ "avatar-square"
      refute result =~ "avatar-rounded"
    end

    test "renders square shape" do
      result = render_component(&dm_avatar/1, %{name: "Test", shape: "square"})
      assert result =~ "avatar-square"
    end

    test "renders rounded shape" do
      result = render_component(&dm_avatar/1, %{name: "Test", shape: "rounded"})
      assert result =~ "avatar-rounded"
    end
  end

  describe "dm_avatar colors" do
    test "defaults to primary" do
      result = render_component(&dm_avatar/1, %{name: "Test"})
      assert result =~ "avatar-primary"
    end

    test "renders upstream color classes" do
      for color <- ~w(primary secondary tertiary) do
        result = render_component(&dm_avatar/1, %{name: "T", color: color})
        assert result =~ "avatar-#{color}"
      end
    end

    test "maps accent to tertiary" do
      result = render_component(&dm_avatar/1, %{name: "T", color: "accent"})
      assert result =~ "avatar-tertiary"
    end

    test "renders fallback color classes for info/success/warning/error" do
      for color <- ~w(info success warning error) do
        result = render_component(&dm_avatar/1, %{name: "T", color: color})
        assert result =~ "var(--color-#{color})"
      end
    end
  end

  describe "dm_avatar ring" do
    test "no ring by default" do
      result = render_component(&dm_avatar/1, %{name: "T"})
      refute result =~ "avatar-ring"
    end

    test "renders ring" do
      result = render_component(&dm_avatar/1, %{name: "T", ring: true})
      assert result =~ "avatar-ring"
    end

    test "renders ring with color" do
      result = render_component(&dm_avatar/1, %{name: "T", ring: true, ring_color: "secondary"})
      assert result =~ "avatar-ring"
      assert result =~ "avatar-ring-secondary"
    end

    test "no ring color class when ring is false" do
      result = render_component(&dm_avatar/1, %{name: "T", ring_color: "primary"})
      refute result =~ "avatar-ring"
    end
  end

  describe "dm_avatar initials" do
    test "renders name showing initials" do
      result = render_component(&dm_avatar/1, %{name: "John Doe"})
      assert result =~ "JD"
    end

    test "renders single name initial" do
      result = render_component(&dm_avatar/1, %{name: "Alice"})
      assert result =~ "A"
    end

    test "renders initials in uppercase" do
      result = render_component(&dm_avatar/1, %{name: "john doe"})
      assert result =~ "JD"
    end

    test "renders three word name with first two initials" do
      result = render_component(&dm_avatar/1, %{name: "Alice Bob Charlie"})
      assert result =~ "AB"
    end

    test "renders initials in text-lg span" do
      result = render_component(&dm_avatar/1, %{name: "Test User"})
      assert result =~ "text-lg"
      assert result =~ "TU"
    end

    test "renders placeholder class on initials container" do
      result = render_component(&dm_avatar/1, %{name: "Test", placeholder_class: "bg-gradient"})
      assert result =~ "bg-gradient"
    end
  end

  describe "dm_avatar default icon" do
    test "renders default user icon svg when no name or src" do
      result = render_component(&dm_avatar/1, %{})
      assert result =~ "<svg"
      assert result =~ ~s[viewBox="0 0 20 20"]
    end

    test "renders default svg icon with role img and aria-label" do
      result = render_component(&dm_avatar/1, %{})
      assert result =~ ~s[role="img"]
      assert result =~ ~s[aria-label="User"]
    end

    test "renders custom default_icon_label" do
      result = render_component(&dm_avatar/1, %{default_icon_label: "Utilisateur"})
      assert result =~ ~s[aria-label="Utilisateur"]
    end

    test "renders default SVG icon for empty name" do
      result = render_component(&dm_avatar/1, %{name: ""})
      assert result =~ "<svg"
    end

    test "renders default SVG icon for nil name" do
      result = render_component(&dm_avatar/1, %{name: nil})
      assert result =~ "<svg"
    end
  end

  describe "dm_avatar online/offline indicator" do
    test "renders online indicator" do
      result = render_component(&dm_avatar/1, %{name: "T", online: true})
      assert result =~ "avatar-online"
    end

    test "renders offline indicator" do
      result = render_component(&dm_avatar/1, %{name: "T", offline: true})
      assert result =~ "avatar-offline"
    end

    test "no indicator by default" do
      result = render_component(&dm_avatar/1, %{name: "T"})
      refute result =~ ~s[aria-label="Online"]
      refute result =~ ~s[aria-label="Offline"]
    end

    test "online indicator has role=status and sr-only text" do
      result = render_component(&dm_avatar/1, %{name: "T", online: true})
      assert result =~ ~s[role="status"]
      assert result =~ "Online"
      assert result =~ "sr-only"
    end

    test "offline indicator has role=status and sr-only text" do
      result = render_component(&dm_avatar/1, %{name: "T", offline: true})
      assert result =~ ~s[role="status"]
      assert result =~ "Offline"
      assert result =~ "sr-only"
    end

    test "custom online_label" do
      result =
        render_component(&dm_avatar/1, %{name: "T", online: true, online_label: "En ligne"})

      assert result =~ "En ligne"
    end

    test "custom offline_label" do
      result =
        render_component(&dm_avatar/1, %{
          name: "T",
          offline: true,
          offline_label: "Hors ligne"
        })

      assert result =~ "Hors ligne"
    end

    test "indicator uses upstream avatar-online class" do
      result = render_component(&dm_avatar/1, %{name: "T", online: true})
      assert result =~ "avatar-online"
    end
  end

  describe "dm_avatar placeholder" do
    test "renders placeholder image" do
      result = render_component(&dm_avatar/1, %{placeholder_img: "/path/to/placeholder.jpg"})
      assert result =~ ~s[src="/path/to/placeholder.jpg"]
      assert result =~ ~s[alt="Placeholder"]
    end

    test "renders custom placeholder_alt" do
      result =
        render_component(&dm_avatar/1, %{
          placeholder_img: "/img/default.png",
          placeholder_alt: "Image par défaut"
        })

      assert result =~ ~s[alt="Image par défaut"]
    end

    test "placeholder_img true shows initials" do
      result = render_component(&dm_avatar/1, %{name: "Jane Smith", placeholder_img: true})
      assert result =~ "JS"
    end

    test "placeholder_img string shows custom image" do
      result =
        render_component(&dm_avatar/1, %{
          name: "Jane",
          placeholder_img: "/img/placeholder.png"
        })

      assert result =~ ~s[src="/img/placeholder.png"]
    end

    test "avatar-placeholder class on placeholder content" do
      result = render_component(&dm_avatar/1, %{name: "T"})
      assert result =~ "avatar-placeholder"
    end

    test "src with placeholder_img true hides src image" do
      result =
        render_component(&dm_avatar/1, %{
          src: "https://example.com/a.jpg",
          placeholder_img: true
        })

      refute result =~ ~s[src="https://example.com/a.jpg"]
    end

    test "src with placeholder_img string shows placeholder" do
      result =
        render_component(&dm_avatar/1, %{
          src: "https://example.com/a.jpg",
          placeholder_img: "/fallback.png"
        })

      assert result =~ ~s[src="/fallback.png"]
    end

    test "src without placeholder shows img not placeholder" do
      result =
        render_component(&dm_avatar/1, %{
          src: "https://example.com/img.jpg",
          alt: "User"
        })

      assert result =~ "<img"
      assert result =~ ~s[src="https://example.com/img.jpg"]
    end
  end

  describe "dm_avatar combined" do
    test "renders with all options" do
      result =
        render_component(&dm_avatar/1, %{
          src: "https://example.com/photo.jpg",
          alt: "Full Avatar",
          size: "xl",
          shape: "square",
          color: "accent",
          ring: true,
          ring_color: "tertiary",
          online: true,
          class: "my-avatar",
          img_class: "my-img"
        })

      assert result =~ ~s[src="https://example.com/photo.jpg"]
      assert result =~ ~s[alt="Full Avatar"]
      assert result =~ "avatar-xl"
      assert result =~ "avatar-square"
      assert result =~ "avatar-tertiary"
      assert result =~ "avatar-ring"
      assert result =~ "avatar-ring-tertiary"
      assert result =~ "avatar-online"
      assert result =~ "my-avatar"
      assert result =~ "my-img"
    end

    test "renders name and color combined" do
      result = render_component(&dm_avatar/1, %{name: "JD", color: "error"})
      assert result =~ "var(--color-error)"
      assert result =~ "J"
    end

    test "renders offline and ring combined" do
      result =
        render_component(&dm_avatar/1, %{
          name: "Jane",
          offline: true,
          ring: true,
          color: "warning"
        })

      assert result =~ "avatar-ring"
      assert result =~ "avatar-offline"
      assert result =~ "var(--color-warning)"
      assert result =~ "J"
    end
  end
end
