defmodule PhoenixDuskmoon.Component.Feedback.LoadingTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.Feedback.Loading

  describe "dm_loading_spinner/1" do
    test "renders loading container" do
      result = render_component(&dm_loading_spinner/1, %{})

      assert result =~ "dm-loading-container"
    end

    test "renders spinner icon element" do
      result = render_component(&dm_loading_spinner/1, %{})

      assert result =~ "dm-loading-spinner__icon"
    end

    test "renders with role status" do
      result = render_component(&dm_loading_spinner/1, %{})

      assert result =~ ~s[role="status"]
    end

    test "renders with default aria-label Loading" do
      result = render_component(&dm_loading_spinner/1, %{})

      assert result =~ ~s[aria-label="Loading"]
    end

    test "renders with aria-busy true for loading state" do
      result = render_component(&dm_loading_spinner/1, %{})

      assert result =~ ~s[aria-busy="true"]
    end

    test "renders with default size md" do
      result = render_component(&dm_loading_spinner/1, %{})

      assert result =~ "dm-loading-spinner--md"
    end

    test "renders with all size options" do
      for size <- ~w(xs sm md lg) do
        result = render_component(&dm_loading_spinner/1, %{size: size})
        assert result =~ "dm-loading-spinner--#{size}"
      end
    end

    test "renders with default variant primary" do
      result = render_component(&dm_loading_spinner/1, %{})

      assert result =~ "dm-loading-spinner--primary"
    end

    test "renders with all variant options" do
      for variant <- ~w(primary secondary accent info success warning error) do
        result = render_component(&dm_loading_spinner/1, %{variant: variant})
        assert result =~ "dm-loading-spinner--#{variant}"
      end
    end

    test "renders with text" do
      result = render_component(&dm_loading_spinner/1, %{text: "Loading..."})

      assert result =~ "Loading..."
      assert result =~ "dm-loading-spinner__text"
    end

    test "renders without text span by default" do
      result = render_component(&dm_loading_spinner/1, %{})

      refute result =~ "dm-loading-spinner__text"
    end

    test "renders with text as aria-label" do
      result = render_component(&dm_loading_spinner/1, %{text: "Please wait"})

      assert result =~ ~s[aria-label="Please wait"]
    end

    test "renders with custom id" do
      result = render_component(&dm_loading_spinner/1, %{id: "my-loader"})

      assert result =~ ~s[id="my-loader"]
    end

    test "renders with custom class" do
      result = render_component(&dm_loading_spinner/1, %{class: "my-spinner"})

      assert result =~ "my-spinner"
    end

    test "renders with rest attributes" do
      result = render_component(&dm_loading_spinner/1, %{"data-testid": "loader"})

      assert result =~ "data-testid=\"loader\""
    end
  end

  describe "dm_loading_ex/1" do
    test "renders advanced particle loader with role status" do
      result = render_component(&dm_loading_ex/1, %{})

      assert result =~ ~s[role="status"]
      assert result =~ ~s[aria-label="Loading"]
    end

    test "renders dm_loading_ex with aria-busy true" do
      result = render_component(&dm_loading_ex/1, %{})

      assert result =~ ~s[aria-busy="true"]
    end

    test "renders loader with style block" do
      result = render_component(&dm_loading_ex/1, %{})

      assert result =~ "<style"
      assert result =~ "@keyframes"
    end

    test "renders default 88 particles" do
      result = render_component(&dm_loading_ex/1, %{})

      count = length(String.split(result, "<i")) - 1
      # The <i> tags inside the div (not in style block)
      assert count >= 88
    end

    test "renders custom item count" do
      result = render_component(&dm_loading_ex/1, %{item_count: 20})

      # The style block generates nth-child rules for each particle
      assert result =~ "nth-child(20)"
      refute result =~ "nth-child(21)"
    end

    test "renders with custom speed" do
      result = render_component(&dm_loading_ex/1, %{speed: "2s"})

      assert result =~ "--duration: 2s"
    end

    test "renders with default speed 4s" do
      result = render_component(&dm_loading_ex/1, %{})

      assert result =~ "--duration: 4s"
    end

    test "renders with custom size" do
      result = render_component(&dm_loading_ex/1, %{size: 44})

      assert result =~ "--size: 44em"
    end

    test "renders with default size 21" do
      result = render_component(&dm_loading_ex/1, %{})

      assert result =~ "--size: 21em"
    end

    test "renders with custom id" do
      result = render_component(&dm_loading_ex/1, %{id: "fancy-loader"})

      assert result =~ ~s[id="fancy-loader"]
    end

    test "renders with custom class" do
      result = render_component(&dm_loading_ex/1, %{class: "my-loader"})

      assert result =~ "my-loader"
    end

    test "renders with rest attributes" do
      result = render_component(&dm_loading_ex/1, %{"data-testid": "particle-loader"})

      assert result =~ "data-testid=\"particle-loader\""
    end

    test "renders with item_count 0 without crashing" do
      result = render_component(&dm_loading_ex/1, %{item_count: 0})

      assert result =~ ~s[role="status"]
      assert result =~ "<i"
    end

    test "renders with item_count 0 clamped to 1 nth-child rule" do
      result = render_component(&dm_loading_ex/1, %{item_count: 0})

      # max(0, 1) = 1, so should have nth-child(1) rule
      assert result =~ "nth-child(1)"
      # Should NOT have nth-child(2)
      refute result =~ "nth-child(2)"
    end

    test "renders with item_count 1 generates single particle" do
      result = render_component(&dm_loading_ex/1, %{item_count: 1})

      assert result =~ "nth-child(1)"
      refute result =~ "nth-child(2)"
    end

    test "renders oklch color in CSS" do
      result = render_component(&dm_loading_ex/1, %{})

      assert result =~ "oklch(75% 0.15 var(--hue, 0))"
    end

    test "renders CSS with rotation keyframes" do
      result = render_component(&dm_loading_ex/1, %{})

      assert result =~ "loaderSpin-"
      assert result =~ "item-move-"
      assert result =~ "rotate(360deg)"
    end

    test "renders particles with --hue CSS variable" do
      result = render_component(&dm_loading_ex/1, %{item_count: 3})

      assert result =~ "--hue:"
      assert result =~ "--rz:"
      assert result =~ "--delay:"
    end

    test "renders with item_count 3 has exactly 3 nth-child rules" do
      result = render_component(&dm_loading_ex/1, %{item_count: 3})

      assert result =~ "nth-child(1)"
      assert result =~ "nth-child(2)"
      assert result =~ "nth-child(3)"
      refute result =~ "nth-child(4)"
    end

    test "renders with all options combined" do
      result =
        render_component(&dm_loading_ex/1, %{
          id: "fancy",
          class: "my-loader",
          item_count: 5,
          speed: "1s",
          size: 10,
          "data-testid": "loader"
        })

      assert result =~ ~s[id="fancy"]
      assert result =~ "my-loader"
      assert result =~ "--duration: 1s"
      assert result =~ "--size: 10em"
      assert result =~ "nth-child(5)"
      refute result =~ "nth-child(6)"
      assert result =~ "data-testid=\"loader\""
    end

    test "renders negative item_count clamped to 1" do
      result = render_component(&dm_loading_ex/1, %{item_count: -5})

      assert result =~ "nth-child(1)"
      refute result =~ "nth-child(2)"
    end

    test "renders style data-id attribute" do
      result = render_component(&dm_loading_ex/1, %{})

      assert result =~ "<style data-id="
    end

    test "renders unique random_inner in class and style" do
      result = render_component(&dm_loading_ex/1, %{})

      # The loader class includes the random number
      assert result =~ "loader-"
      # Style block references same random number
      assert result =~ "@keyframes loaderSpin-"
      assert result =~ "@keyframes item-move-"
    end
  end

  describe "dm_loading_spinner/1 edge cases" do
    test "renders with all options combined" do
      result =
        render_component(&dm_loading_spinner/1, %{
          id: "my-spinner",
          class: "extra-class",
          size: "lg",
          variant: "success",
          text: "Please wait...",
          "data-testid": "spinner"
        })

      assert result =~ ~s[id="my-spinner"]
      assert result =~ "extra-class"
      assert result =~ "dm-loading-spinner--lg"
      assert result =~ "dm-loading-spinner--success"
      assert result =~ "Please wait..."
      assert result =~ "dm-loading-spinner__text"
      assert result =~ ~s[aria-label="Please wait..."]
      assert result =~ "data-testid=\"spinner\""
    end

    test "renders without id when not provided" do
      result = render_component(&dm_loading_spinner/1, %{})

      refute result =~ ~s[id="]
    end

    test "renders size and variant classes on inner span" do
      result = render_component(&dm_loading_spinner/1, %{size: "xs", variant: "warning"})

      assert result =~ "dm-loading-spinner--xs"
      assert result =~ "dm-loading-spinner--warning"
      assert result =~ "dm-loading-spinner__icon"
    end

    test "renders spinner icon with aria-hidden for screen readers" do
      result = render_component(&dm_loading_spinner/1, %{})

      assert result =~ ~s[aria-hidden="true"]
    end
  end
end
