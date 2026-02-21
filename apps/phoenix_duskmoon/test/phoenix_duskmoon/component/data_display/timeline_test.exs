defmodule PhoenixDuskmoon.Component.DataDisplay.TimelineTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.DataDisplay.Timeline

  defp timeline_items do
    [
      %{
        title: "Step 1",
        time: "Jan 1",
        inner_block: fn _, _ -> "First content" end,
        __slot__: :item
      },
      %{
        title: "Step 2",
        inner_block: fn _, _ -> "Second content" end,
        __slot__: :item
      }
    ]
  end

  test "renders basic timeline with items" do
    result = render_component(&dm_timeline/1, %{item: timeline_items()})

    assert result =~ "timeline"
    assert result =~ "Step 1"
    assert result =~ "Step 2"
    assert result =~ "First content"
    assert result =~ "Second content"
  end

  test "renders timeline with timeline class" do
    result =
      render_component(&dm_timeline/1, %{
        item: [
          %{title: "Item", inner_block: fn _, _ -> "Content" end, __slot__: :item}
        ]
      })

    assert result =~ "class=\"timeline"
  end

  test "renders timeline item with title" do
    result =
      render_component(&dm_timeline/1, %{
        item: [
          %{title: "My Title", inner_block: fn _, _ -> "Body" end, __slot__: :item}
        ]
      })

    assert result =~ "timeline-title"
    assert result =~ "My Title"
  end

  test "renders timeline item with time" do
    result =
      render_component(&dm_timeline/1, %{
        item: [
          %{
            title: "Event",
            time: "2026-01-15",
            inner_block: fn _, _ -> "Body" end,
            __slot__: :item
          }
        ]
      })

    assert result =~ "timeline-time"
    assert result =~ "2026-01-15"
  end

  test "renders timeline item description" do
    result =
      render_component(&dm_timeline/1, %{
        item: [
          %{title: "Event", inner_block: fn _, _ -> "Description text" end, __slot__: :item}
        ]
      })

    assert result =~ "timeline-description"
    assert result =~ "Description text"
  end

  test "renders timeline with custom id" do
    result =
      render_component(&dm_timeline/1, %{
        id: "my-timeline",
        item: [
          %{title: "Item", inner_block: fn _, _ -> "Body" end, __slot__: :item}
        ]
      })

    assert result =~ ~s[id="my-timeline"]
  end

  test "renders timeline with custom class" do
    result =
      render_component(&dm_timeline/1, %{
        class: "my-custom-class",
        item: [
          %{title: "Item", inner_block: fn _, _ -> "Body" end, __slot__: :item}
        ]
      })

    assert result =~ "my-custom-class"
  end

  describe "color variants" do
    test "renders timeline item with primary color" do
      result =
        render_component(&dm_timeline/1, %{
          item: [
            %{
              title: "Primary",
              color: "primary",
              inner_block: fn _, _ -> "Body" end,
              __slot__: :item
            }
          ]
        })

      assert result =~ "timeline-item-primary"
    end

    test "renders timeline item with success color" do
      result =
        render_component(&dm_timeline/1, %{
          item: [
            %{
              title: "Success",
              color: "success",
              inner_block: fn _, _ -> "Done" end,
              __slot__: :item
            }
          ]
        })

      assert result =~ "timeline-item-success"
    end

    test "renders timeline item with warning color" do
      result =
        render_component(&dm_timeline/1, %{
          item: [
            %{
              title: "Warning",
              color: "warning",
              inner_block: fn _, _ -> "Caution" end,
              __slot__: :item
            }
          ]
        })

      assert result =~ "timeline-item-warning"
    end

    test "renders timeline item with error color" do
      result =
        render_component(&dm_timeline/1, %{
          item: [
            %{
              title: "Error",
              color: "error",
              inner_block: fn _, _ -> "Failed" end,
              __slot__: :item
            }
          ]
        })

      assert result =~ "timeline-item-error"
    end

    test "renders timeline item without color by default" do
      result =
        render_component(&dm_timeline/1, %{
          item: [
            %{title: "Default", inner_block: fn _, _ -> "Body" end, __slot__: :item}
          ]
        })

      refute result =~ "timeline-item-primary"
      refute result =~ "timeline-item-success"
    end
  end

  describe "item states" do
    test "renders completed timeline item" do
      result =
        render_component(&dm_timeline/1, %{
          item: [
            %{
              title: "Done",
              completed: true,
              inner_block: fn _, _ -> "Finished" end,
              __slot__: :item
            }
          ]
        })

      assert result =~ "completed"
    end

    test "renders active timeline item" do
      result =
        render_component(&dm_timeline/1, %{
          item: [
            %{
              title: "Current",
              active: true,
              inner_block: fn _, _ -> "In progress" end,
              __slot__: :item
            }
          ]
        })

      assert result =~ "active"
    end

    test "renders loading timeline item" do
      result =
        render_component(&dm_timeline/1, %{
          item: [
            %{
              title: "Loading",
              loading: true,
              inner_block: fn _, _ -> "Please wait" end,
              __slot__: :item
            }
          ]
        })

      assert result =~ "loading"
    end
  end

  describe "marker" do
    test "renders dot marker by default" do
      result =
        render_component(&dm_timeline/1, %{
          item: [
            %{title: "Item", inner_block: fn _, _ -> "Body" end, __slot__: :item}
          ]
        })

      assert result =~ "timeline-marker-dot"
      assert result =~ "timeline-marker"
    end

    test "marker dot has aria-hidden" do
      result =
        render_component(&dm_timeline/1, %{
          item: [
            %{title: "Item", inner_block: fn _, _ -> "Body" end, __slot__: :item}
          ]
        })

      assert result =~ ~s(class="timeline-marker-dot" aria-hidden="true")
    end

    test "renders icon marker when icon provided" do
      result =
        render_component(&dm_timeline/1, %{
          item: [
            %{
              title: "Item",
              icon: "check",
              inner_block: fn _, _ -> "Body" end,
              __slot__: :item
            }
          ]
        })

      assert result =~ "timeline-marker-icon"
      refute result =~ "timeline-marker-dot"
    end
  end

  describe "size variants" do
    test "renders small timeline" do
      result =
        render_component(&dm_timeline/1, %{
          size: "sm",
          item: [
            %{title: "Item", inner_block: fn _, _ -> "Body" end, __slot__: :item}
          ]
        })

      assert result =~ "timeline-sm"
    end

    test "renders large timeline" do
      result =
        render_component(&dm_timeline/1, %{
          size: "lg",
          item: [
            %{title: "Item", inner_block: fn _, _ -> "Body" end, __slot__: :item}
          ]
        })

      assert result =~ "timeline-lg"
    end

    test "renders default size without modifier" do
      result =
        render_component(&dm_timeline/1, %{
          item: [
            %{title: "Item", inner_block: fn _, _ -> "Body" end, __slot__: :item}
          ]
        })

      refute result =~ "timeline-sm"
      refute result =~ "timeline-lg"
    end
  end

  describe "layout variants" do
    test "renders alternate layout" do
      result =
        render_component(&dm_timeline/1, %{
          layout: "alternate",
          item: [
            %{title: "Left", inner_block: fn _, _ -> "Left content" end, __slot__: :item},
            %{title: "Right", inner_block: fn _, _ -> "Right content" end, __slot__: :item}
          ]
        })

      assert result =~ "timeline-alternate"
    end

    test "renders right layout" do
      result =
        render_component(&dm_timeline/1, %{
          layout: "right",
          item: [
            %{title: "Item", inner_block: fn _, _ -> "Body" end, __slot__: :item}
          ]
        })

      assert result =~ "timeline-right"
    end

    test "renders horizontal layout" do
      result =
        render_component(&dm_timeline/1, %{
          layout: "horizontal",
          item: [
            %{title: "Step 1", inner_block: fn _, _ -> "First" end, __slot__: :item},
            %{title: "Step 2", inner_block: fn _, _ -> "Second" end, __slot__: :item}
          ]
        })

      assert result =~ "timeline-horizontal"
    end

    test "renders default left layout without modifier" do
      result =
        render_component(&dm_timeline/1, %{
          item: [
            %{title: "Item", inner_block: fn _, _ -> "Body" end, __slot__: :item}
          ]
        })

      refute result =~ "timeline-alternate"
      refute result =~ "timeline-right"
      refute result =~ "timeline-horizontal"
    end
  end

  test "renders timeline with multiple items with mixed states and colors" do
    result =
      render_component(&dm_timeline/1, %{
        id: "order-timeline",
        size: "sm",
        item: [
          %{
            title: "Placed",
            time: "Jan 1",
            color: "success",
            completed: true,
            icon: "check",
            inner_block: fn _, _ -> "Order placed" end,
            __slot__: :item
          },
          %{
            title: "Shipped",
            time: "Jan 3",
            color: "primary",
            active: true,
            inner_block: fn _, _ -> "In transit" end,
            __slot__: :item
          },
          %{
            title: "Delivered",
            inner_block: fn _, _ -> "Pending" end,
            __slot__: :item
          }
        ]
      })

    assert result =~ ~s[id="order-timeline"]
    assert result =~ "timeline-sm"
    assert result =~ "Placed"
    assert result =~ "Shipped"
    assert result =~ "Delivered"
    assert result =~ "timeline-item-success"
    assert result =~ "completed"
    assert result =~ "timeline-item-primary"
    assert result =~ "active"
    assert result =~ "Jan 1"
    assert result =~ "Jan 3"
  end

  test "renders timeline item with custom class" do
    result =
      render_component(&dm_timeline/1, %{
        item: [
          %{
            title: "Custom",
            class: "my-item-class",
            inner_block: fn _, _ -> "Body" end,
            __slot__: :item
          }
        ]
      })

    assert result =~ "my-item-class"
  end

  describe "accessibility" do
    test "timeline container has role list" do
      result = render_component(&dm_timeline/1, %{item: timeline_items()})
      assert result =~ ~s(role="list")
    end

    test "timeline items have role listitem" do
      result = render_component(&dm_timeline/1, %{item: timeline_items()})
      assert result =~ ~s(role="listitem")
    end
  end

  test "passes through global attributes" do
    result =
      render_component(&dm_timeline/1, %{item: timeline_items(), "data-testid": "my-timeline"})

    assert result =~ ~s[data-testid="my-timeline"]
  end
end
