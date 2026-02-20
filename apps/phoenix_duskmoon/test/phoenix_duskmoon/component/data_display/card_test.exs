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

  describe "dm_async_card/1" do
    test "renders async card in loading state" do
      result =
        render_component(&dm_async_card/1, %{
          assign: %Phoenix.LiveView.AsyncResult{loading: true},
          inner_block: fn _, _ -> "Success content" end
        })

      assert result =~ ~s[<el-dm-card]
      assert result =~ "dm-skeleton"
      refute result =~ "Success content"
    end

    test "renders async card in loading state with skeleton" do
      result =
        render_component(&dm_async_card/1, %{
          assign: %Phoenix.LiveView.AsyncResult{loading: true},
          inner_block: fn _, _ -> "Content" end
        })

      assert result =~ "dm-skeleton"
    end

    test "renders async card in loading state with custom skeleton class" do
      result =
        render_component(&dm_async_card/1, %{
          assign: %Phoenix.LiveView.AsyncResult{loading: true},
          skeleton_class: "h-32",
          inner_block: fn _, _ -> "Content" end
        })

      assert result =~ "dm-skeleton"
      assert result =~ "h-32"
    end

    test "renders async card in failed state" do
      result =
        render_component(&dm_async_card/1, %{
          assign: %Phoenix.LiveView.AsyncResult{failed: {:error, "Network error"}},
          inner_block: fn _, _ -> "Success content" end
        })

      assert result =~ ~s[<el-dm-card]
      assert result =~ "dm-alert"
      assert result =~ "Network error"
      refute result =~ "dm-skeleton"
    end

    test "renders async card in success state" do
      result =
        render_component(&dm_async_card/1, %{
          assign: %Phoenix.LiveView.AsyncResult{ok?: true, result: "Data loaded"},
          inner_block: %{inner_block: fn _, _ -> "Success content" end}
        })

      assert result =~ ~s[<el-dm-card]
      assert result =~ "Success content"
      refute result =~ "dm-skeleton"
      refute result =~ "dm-alert"
    end

    test "renders async card with title in loading state" do
      result =
        render_component(&dm_async_card/1, %{
          assign: %Phoenix.LiveView.AsyncResult{loading: true},
          title: [%{inner_block: fn _, _ -> "Card Title" end}],
          inner_block: fn _, _ -> "Content" end
        })

      assert result =~ ~s[slot="header"]
      assert result =~ "Card Title"
      assert result =~ "dm-skeleton"
    end

    test "renders async card with title in failed state" do
      result =
        render_component(&dm_async_card/1, %{
          assign: %Phoenix.LiveView.AsyncResult{failed: {:error, "Failed"}},
          title: [%{inner_block: fn _, _ -> "Title" end}],
          inner_block: fn _, _ -> "Content" end
        })

      assert result =~ ~s[slot="header"]
      assert result =~ "Title"
      assert result =~ "dm-alert"
    end

    test "renders async card with action in success state" do
      result =
        render_component(&dm_async_card/1, %{
          assign: %Phoenix.LiveView.AsyncResult{ok?: true, result: "data"},
          action: [%{inner_block: fn _, _ -> "Action Button" end}],
          inner_block: %{inner_block: fn _, _ -> "Content" end}
        })

      assert result =~ ~s[slot="footer"]
      assert result =~ "Action Button"
    end

    test "renders async card with variant and shadow" do
      result =
        render_component(&dm_async_card/1, %{
          assign: %Phoenix.LiveView.AsyncResult{ok?: true, result: nil},
          variant: "bordered",
          shadow: "lg",
          inner_block: %{inner_block: fn _, _ -> "Content" end}
        })

      assert result =~ ~s[variant="bordered"]
      assert result =~ ~s[shadow="lg"]
    end

    test "renders async card with image in loading state shows skeleton" do
      result =
        render_component(&dm_async_card/1, %{
          assign: %Phoenix.LiveView.AsyncResult{loading: true},
          image: "/test.jpg",
          inner_block: fn _, _ -> "Content" end
        })

      # Loading state shows skeleton instead of actual image
      assert result =~ ~s[slot="image"]
      assert result =~ "dm-skeleton"
      refute result =~ ~s[src="/test.jpg"]
    end

    test "renders async card with image in success state" do
      result =
        render_component(&dm_async_card/1, %{
          assign: %Phoenix.LiveView.AsyncResult{ok?: true, result: nil},
          image: "/test.jpg",
          image_alt: "Test",
          inner_block: %{inner_block: fn _, _ -> "Content" end}
        })

      assert result =~ ~s[src="/test.jpg"]
      assert result =~ ~s[alt="Test"]
    end

    test "renders async card with body_class wrapping content in div" do
      result =
        render_component(&dm_async_card/1, %{
          assign: %Phoenix.LiveView.AsyncResult{ok?: true, result: nil},
          body_class: "p-6",
          inner_block: %{inner_block: fn _, _ -> "Wrapped content" end}
        })

      assert result =~ ~s[class="p-6"]
      assert result =~ "Wrapped content"
    end

    test "renders async card with global attributes" do
      result =
        render_component(&dm_async_card/1, %{
          assign: %Phoenix.LiveView.AsyncResult{ok?: true, result: nil},
          "data-testid": "async-card",
          inner_block: %{inner_block: fn _, _ -> "Content" end}
        })

      assert result =~ ~s[data-testid="async-card"]
    end

    test "renders async card with id and class in all states" do
      for state <- [
            %Phoenix.LiveView.AsyncResult{loading: true},
            %Phoenix.LiveView.AsyncResult{failed: {:error, "err"}},
            %Phoenix.LiveView.AsyncResult{ok?: true, result: nil}
          ] do
        inner =
          if state.ok? do
            %{inner_block: fn _, _ -> "Content" end}
          else
            fn _, _ -> "Content" end
          end

        result =
          render_component(&dm_async_card/1, %{
            assign: state,
            id: "state-card",
            class: "state-class",
            inner_block: inner
          })

        assert result =~ ~s[id="state-card"]
        assert result =~ "state-class"
      end
    end
  end

  test "renders card without image when image is nil" do
    result =
      render_component(&dm_card/1, %{
        inner_block: %{inner_block: fn _, _ -> "Content" end}
      })

    refute result =~ "<img"
    refute result =~ ~s[slot="image"]
  end

  test "renders card body in template when body_class is nil" do
    result =
      render_component(&dm_card/1, %{
        inner_block: %{inner_block: fn _, _ -> "Unwrapped" end}
      })

    assert result =~ "<template>"
    assert result =~ "Unwrapped"
  end

  test "renders card body in div when body_class is provided" do
    result =
      render_component(&dm_card/1, %{
        body_class: "p-4",
        inner_block: %{inner_block: fn _, _ -> "Wrapped" end}
      })

    assert result =~ ~s[class="p-4"]
    refute result =~ "<template>"
    assert result =~ "Wrapped"
  end

  test "renders card without title or action slots" do
    result =
      render_component(&dm_card/1, %{
        inner_block: %{inner_block: fn _, _ -> "Solo content" end}
      })

    refute result =~ ~s[slot="header"]
    refute result =~ ~s[slot="footer"]
    assert result =~ "Solo content"
  end

  test "renders card with nil variant and shadow" do
    result =
      render_component(&dm_card/1, %{
        inner_block: %{inner_block: fn _, _ -> "Content" end}
      })

    # variant and shadow should not be present when nil
    refute result =~ ~s[variant="]
    refute result =~ ~s[shadow="]
  end

  test "renders card image with empty alt text by default" do
    result =
      render_component(&dm_card/1, %{
        image: "/photo.jpg",
        inner_block: %{inner_block: fn _, _ -> "Content" end}
      })

    assert result =~ ~s[alt=""]
  end

  test "renders card with variant and shadow combined" do
    result =
      render_component(&dm_card/1, %{
        variant: "glass",
        shadow: "xl",
        inner_block: %{inner_block: fn _, _ -> "Content" end}
      })

    assert result =~ ~s[variant="glass"]
    assert result =~ ~s[shadow="xl"]
  end

  test "renders card with interactive" do
    result =
      render_component(&dm_card/1, %{
        interactive: true,
        inner_block: %{inner_block: fn _, _ -> "Content" end}
      })

    assert result =~ "interactive"
  end

  test "renders card without interactive by default" do
    result =
      render_component(&dm_card/1, %{
        inner_block: %{inner_block: fn _, _ -> "Content" end}
      })

    refute result =~ ~s[interactive]
  end

  test "renders card with padding" do
    for padding <- ~w(none sm md lg) do
      result =
        render_component(&dm_card/1, %{
          padding: padding,
          inner_block: %{inner_block: fn _, _ -> "Content" end}
        })

      assert result =~ ~s[padding="#{padding}"]
    end
  end

  test "renders card without padding by default" do
    result =
      render_component(&dm_card/1, %{
        inner_block: %{inner_block: fn _, _ -> "Content" end}
      })

    refute result =~ ~s[padding="]
  end

  test "renders card with all options combined" do
    result =
      render_component(&dm_card/1, %{
        id: "full-card",
        class: "w-96",
        body_class: "p-6",
        variant: "bordered",
        shadow: "lg",
        image: "/img.jpg",
        image_alt: "Photo",
        title: [%{id: "t1", class: "text-xl", inner_block: fn _, _ -> "Title" end}],
        action: [%{id: "a1", class: "mt-4", inner_block: fn _, _ -> "Save" end}],
        inner_block: %{inner_block: fn _, _ -> "Body" end},
        "data-testid": "card-full"
      })

    assert result =~ ~s[id="full-card"]
    assert result =~ "w-96"
    assert result =~ ~s[class="p-6"]
    assert result =~ ~s[variant="bordered"]
    assert result =~ ~s[shadow="lg"]
    assert result =~ ~s[src="/img.jpg"]
    assert result =~ ~s[alt="Photo"]
    assert result =~ "Title"
    assert result =~ "Save"
    assert result =~ "Body"
    assert result =~ ~s[data-testid="card-full"]
  end

  describe "dm_async_card/1 edge cases" do
    test "renders async card action slot with id and class" do
      result =
        render_component(&dm_async_card/1, %{
          assign: %Phoenix.LiveView.AsyncResult{ok?: true, result: nil},
          action: [%{id: "act-1", class: "btn-group", inner_block: fn _, _ -> "Actions" end}],
          inner_block: %{inner_block: fn _, _ -> "Content" end}
        })

      assert result =~ ~s[id="act-1"]
      assert result =~ "btn-group"
      assert result =~ "Actions"
    end

    test "renders async card title slot with id and class in success state" do
      result =
        render_component(&dm_async_card/1, %{
          assign: %Phoenix.LiveView.AsyncResult{ok?: true, result: nil},
          title: [%{id: "ttl-1", class: "font-bold", inner_block: fn _, _ -> "Heading" end}],
          inner_block: %{inner_block: fn _, _ -> "Content" end}
        })

      assert result =~ ~s[id="ttl-1"]
      assert result =~ "font-bold"
      assert result =~ "Heading"
    end

    test "renders async card without body_class uses template" do
      result =
        render_component(&dm_async_card/1, %{
          assign: %Phoenix.LiveView.AsyncResult{ok?: true, result: nil},
          inner_block: %{inner_block: fn _, _ -> "Unwrapped" end}
        })

      assert result =~ "<template>"
      assert result =~ "Unwrapped"
    end
  end
end
