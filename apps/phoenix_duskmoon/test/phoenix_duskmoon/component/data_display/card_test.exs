defmodule PhoenixDuskmoon.Component.DataDisplay.CardTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.DataDisplay.Card

  test "renders basic card" do
    result =
      render_component(&dm_card/1, %{
        inner_block: %{inner_block: fn _, _ -> "Card content" end}
      })

    assert result =~ ~s[<el-dm-card]
    assert result =~ ~s[Card content]
    assert result =~ ~s[</el-dm-card>]
  end

  test "renders card with custom id and class" do
    result =
      render_component(&dm_card/1, %{
        id: "my-card",
        class: "my-custom-class",
        inner_block: %{inner_block: fn _, _ -> "Content" end}
      })

    assert result =~ ~s[<el-dm-card]
    assert result =~ ~s[id="my-card"]
    assert result =~ ~s[class="my-custom-class"]
  end

  test "renders card with title slot" do
    result =
      render_component(&dm_card/1, %{
        title: [%{inner_block: fn _, _ -> "Card Title" end}],
        inner_block: %{inner_block: fn _, _ -> "Content" end}
      })

    assert result =~ ~s[slot="header"]
    assert result =~ ~s[Card Title]
  end

  test "renders card with title slot with id and class" do
    result =
      render_component(&dm_card/1, %{
        title: [%{id: "title-id", class: "title-class", inner_block: fn _, _ -> "Card Title" end}],
        inner_block: %{inner_block: fn _, _ -> "Content" end}
      })

    assert result =~ ~s[slot="header"]
    assert result =~ ~s[id="title-id"]
    assert result =~ ~s[class="title-class"]
  end

  test "renders card with action slot" do
    result =
      render_component(&dm_card/1, %{
        action: [%{inner_block: fn _, _ -> "Action Button" end}],
        inner_block: %{inner_block: fn _, _ -> "Content" end}
      })

    assert result =~ ~s[slot="footer"]
    assert result =~ ~s[Action Button]
  end

  test "renders card with action slot with id and class" do
    result =
      render_component(&dm_card/1, %{
        action: [%{id: "action-id", class: "action-class", inner_block: fn _, _ -> "Action" end}],
        inner_block: %{inner_block: fn _, _ -> "Content" end}
      })

    assert result =~ ~s[slot="footer"]
    assert result =~ ~s[id="action-id"]
    assert result =~ ~s[class="action-class"]
  end

  test "renders card with variant" do
    for variant <- ["compact", "side", "bordered", "glass"] do
      result =
        render_component(&dm_card/1, %{
          variant: variant,
          inner_block: %{inner_block: fn _, _ -> "Content" end}
        })

      assert result =~ ~s[<el-dm-card]
      assert result =~ ~s[variant="#{variant}"]
    end
  end

  test "renders card with shadow" do
    for shadow <- ["none", "sm", "md", "lg", "xl", "2xl"] do
      result =
        render_component(&dm_card/1, %{
          shadow: shadow,
          inner_block: %{inner_block: fn _, _ -> "Content" end}
        })

      assert result =~ ~s[<el-dm-card]
      assert result =~ ~s[shadow="#{shadow}"]
    end
  end

  test "renders card with image" do
    result =
      render_component(&dm_card/1, %{
        image: "/images/test.jpg",
        image_alt: "Test image",
        inner_block: %{inner_block: fn _, _ -> "Content" end}
      })

    assert result =~ ~s[<img]
    assert result =~ ~s[slot="image"]
    assert result =~ ~s[src="/images/test.jpg"]
    assert result =~ ~s[alt="Test image"]
  end

  test "renders card with body_class" do
    result =
      render_component(&dm_card/1, %{
        body_class: "p-4 bg-base-200",
        inner_block: %{inner_block: fn _, _ -> "Content" end}
      })

    assert result =~ ~s[class="p-4 bg-base-200"]
  end

  test "renders card with all slots" do
    result =
      render_component(&dm_card/1, %{
        title: [%{inner_block: fn _, _ -> "Title" end}],
        action: [%{inner_block: fn _, _ -> "Action" end}],
        inner_block: %{inner_block: fn _, _ -> "Body Content" end}
      })

    assert result =~ ~s[<el-dm-card]
    assert result =~ ~s[slot="header"]
    assert result =~ ~s[Title]
    assert result =~ ~s[Body Content]
    assert result =~ ~s[slot="footer"]
    assert result =~ ~s[Action]
  end

  test "renders card with global attributes" do
    result =
      render_component(&dm_card/1, %{
        "data-testid": "test-card",
        "aria-label": "Test card",
        inner_block: %{inner_block: fn _, _ -> "Content" end}
      })

    assert result =~ ~s[data-testid="test-card"]
    assert result =~ ~s[aria-label="Test card"]
  end

  test "renders card with multiple titles and actions" do
    result =
      render_component(&dm_card/1, %{
        title: [
          %{inner_block: fn _, _ -> "Title 1" end},
          %{inner_block: fn _, _ -> "Title 2" end}
        ],
        action: [
          %{inner_block: fn _, _ -> "Action 1" end},
          %{inner_block: fn _, _ -> "Action 2" end}
        ],
        inner_block: %{inner_block: fn _, _ -> "Card content" end}
      })

    assert result =~ ~s[Title 1]
    assert result =~ ~s[Title 2]
    assert result =~ ~s[Action 1]
    assert result =~ ~s[Action 2]
  end

  # TODO: Fix async card tests - they require proper AsyncResult struct setup
  # test "renders async card with loading state" do
  # end
  # test "renders async card with failed state" do
  # end
  # test "renders async card with success state" do
  # end
  # test "renders async card with custom skeleton class" do
  # end
  # test "renders async card with title in loading state" do
  # end
  # test "renders async card with action in success state" do
  # end
end
