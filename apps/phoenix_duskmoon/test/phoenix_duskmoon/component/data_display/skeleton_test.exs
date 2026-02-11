defmodule PhoenixDuskmoon.Component.DataDisplay.SkeletonTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.DataDisplay.Skeleton

  describe "dm_skeleton/1" do
    test "renders basic skeleton" do
      assert render_component(&dm_skeleton/1, %{}) ==
               ~s[<div aria-busy="true" class="dm-skeleton"></div>]
    end

    test "renders skeleton with custom class" do
      assert render_component(&dm_skeleton/1, %{class: "w-32 h-4"}) ==
               ~s[<div aria-busy="true" class="dm-skeleton w-32 h-4"></div>]
    end

    test "renders skeleton with variant" do
      assert render_component(&dm_skeleton/1, %{variant: "circle"}) ==
               ~s[<div aria-busy="true" class="dm-skeleton dm-skeleton--circle"></div>]
    end

    test "renders skeleton with size" do
      assert render_component(&dm_skeleton/1, %{size: "md"}) ==
               ~s[<div aria-busy="true" class="dm-skeleton dm-skeleton--md"></div>]
    end

    test "renders skeleton with animation" do
      assert render_component(&dm_skeleton/1, %{animation: "pulse"}) ==
               ~s[<div aria-busy="true" class="dm-skeleton animate-pulse"></div>]
    end

    test "renders skeleton with all options" do
      assert render_component(&dm_skeleton/1, %{
               variant: "avatar",
               size: "lg",
               animation: "wave",
               width: "w-16",
               height: "h-16",
               class: "rounded-full"
             }) ==
               ~s[<div aria-busy="true" class="dm-skeleton dm-skeleton--avatar dm-skeleton--lg animate-wave w-16 h-16 rounded-full"></div>]
    end

    test "renders skeleton with id" do
      assert render_component(&dm_skeleton/1, %{id: "skeleton-1"}) ==
               ~s[<div id="skeleton-1" aria-busy="true" class="dm-skeleton"></div>]
    end
  end

  describe "dm_skeleton_text/1" do
    test "renders text skeleton with default lines" do
      result = render_component(&dm_skeleton_text/1, %{})
      assert result =~ ~s[class="space-y-2"]
      assert result =~ ~s[<div class="dm-skeleton h-4 w-full"></div>]
      # Should have 3 lines total (2 full width + 1 last line)
      assert result
             |> String.split("<div class=\"dm-skeleton h-4 w-full")
             |> length()
             |> Kernel.-(1) ==
               3

      assert result =~ ~s[<div class="dm-skeleton h-4 w-full"></div>]
    end

    test "renders text skeleton with custom lines" do
      result = render_component(&dm_skeleton_text/1, %{lines: 5})
      assert result =~ ~s[class="space-y-2"]
      assert result =~ ~s[<div class="dm-skeleton h-4 w-full"></div>]
      # Should have 5 lines total (4 full width + 1 last line)
      assert result
             |> String.split("<div class=\"dm-skeleton h-4 w-full")
             |> length()
             |> Kernel.-(1) ==
               5
    end

    test "renders text skeleton with custom dimensions" do
      result =
        render_component(&dm_skeleton_text/1, %{
          lines: 2,
          line_height: "h-6",
          line_spacing: "mb-4",
          last_line_width: "w-3/4"
        })

      assert result =~ ~s[class="space-y-2"]
      assert result =~ ~s[<div class="dm-skeleton h-6 w-full"></div>]
      assert result =~ ~s[<div class="dm-skeleton h-6 w-3/4"></div>]
    end

    test "renders text skeleton with animation" do
      result = render_component(&dm_skeleton_text/1, %{animation: "pulse"})

      assert result =~ ~s[animate-pulse]
    end
  end

  describe "dm_skeleton_avatar/1" do
    test "renders avatar skeleton with default size" do
      result = render_component(&dm_skeleton_avatar/1, %{})

      assert result =~ ~s[<div class="dm-avatar dm-avatar--placeholder">]
      assert result =~ ~s[<div class="bg-neutral text-neutral-content rounded-full w-md h-md">]
      assert result =~ ~s[<span class="text-xs"></span>]
    end

    test "renders avatar skeleton with custom size" do
      result = render_component(&dm_skeleton_avatar/1, %{size: "lg"})

      assert result =~ ~s[w-lg h-lg]
    end

    test "renders avatar skeleton with animation" do
      result = render_component(&dm_skeleton_avatar/1, %{animation: "bounce"})

      assert result =~ ~s[animate-bounce]
    end

    test "renders avatar skeleton with custom class" do
      result = render_component(&dm_skeleton_avatar/1, %{class: "ring ring-primary"})

      assert result =~ ~s[ring ring-primary]
    end
  end

  describe "dm_skeleton_card/1" do
    test "renders basic card skeleton" do
      result = render_component(&dm_skeleton_card/1, %{})

      assert result =~ ~s[class="dm-card bg-base-100 shadow-xl"]
      assert result =~ ~s[<div class="dm-card__body">]
      assert result =~ ~s[<div class="dm-skeleton h-6 w-3/4 mb-4">]
      assert result =~ ~s[class="space-y-2"]
    end

    test "renders card skeleton with avatar" do
      result = render_component(&dm_skeleton_card/1, %{show_avatar: true})

      assert result =~ ~s[<div class="dm-avatar dm-avatar--placeholder">]
      assert result =~ ~s[flex items-start gap-4]
    end

    test "renders card skeleton with custom lines" do
      result = render_component(&dm_skeleton_card/1, %{lines: 5})

      # Should have 5 skeleton lines
      # 5 lines + 1 title
      assert result |> String.split("dm-skeleton h-4") |> length() == 6
    end

    test "renders card skeleton with action button" do
      result = render_component(&dm_skeleton_card/1, %{show_action: true})

      assert result =~ ~s[<div class="dm-card__actions justify-end mt-4">]
      assert result =~ ~s[<div class="dm-skeleton h-10 w-20">]
    end

    test "renders card skeleton with animation" do
      result = render_component(&dm_skeleton_card/1, %{animation: "pulse"})

      assert result =~ ~s[animate-pulse]
    end
  end

  describe "dm_skeleton_table/1" do
    test "renders table skeleton with header" do
      result = render_component(&dm_skeleton_table/1, %{rows: 3, columns: 2})

      assert result =~ ~s[<table class="dm-table">]
      assert result =~ ~s[<thead>]
      assert result =~ ~s[<th>]
      assert result =~ ~s[<tbody>]
      assert result =~ ~s[<td>]

      # Should have header cells
      # 2 columns + 1 split
      assert result |> String.split("<th>") |> length() == 3
      # Should have data cells (3 rows * 2 columns = 6 cells)
      # 6 cells + 1 split
      assert result |> String.split("<td>") |> length() == 7
    end

    test "renders table skeleton without header" do
      result = render_component(&dm_skeleton_table/1, %{show_header: false, rows: 2, columns: 3})

      refute result =~ ~s[<thead>]
      assert result =~ ~s[<tbody>]
      # Should have data cells (2 rows * 3 columns = 6 cells)
      # 6 cells + 1 split
      assert result |> String.split("<td>") |> length() == 7
    end

    test "renders table skeleton with animation" do
      result = render_component(&dm_skeleton_table/1, %{animation: "wave"})

      assert result =~ ~s[animate-wave]
    end
  end

  describe "dm_skeleton_list/1" do
    test "renders basic list skeleton" do
      result = render_component(&dm_skeleton_list/1, %{items: 3})

      assert result =~ ~s[class="space-y-4"]
      assert result =~ ~s[flex items-start gap-3]
      assert result =~ ~s[flex-1]

      # Should have 3 items
      # 3 items + 1 split
      assert result |> String.split("flex items-start gap-3") |> length() == 4
    end

    test "renders list skeleton with avatars" do
      result = render_component(&dm_skeleton_list/1, %{items: 2, show_avatar: true})

      # 2 avatars + 1 split
      assert result |> String.split("dm-avatar dm-avatar--placeholder") |> length() == 3
    end

    test "renders list skeleton with multiple lines per item" do
      result = render_component(&dm_skeleton_list/1, %{items: 2, lines_per_item: 3})

      # Each item should have 3 lines
      # 2 items + 1 split
      assert result |> String.split("space-y-2") |> length() == 3
    end

    test "renders list skeleton with animation" do
      result = render_component(&dm_skeleton_list/1, %{animation: "pulse"})

      assert result =~ ~s[animate-pulse]
    end
  end

  describe "dm_skeleton_form/1" do
    test "renders basic form skeleton" do
      result = render_component(&dm_skeleton_form/1, %{fields: 3})

      assert result =~ ~s[class="space-y-6"]
      assert result =~ ~s[<div class="dm-form-group">]
      assert result =~ ~s[<div class="dm-label">]
      assert result =~ ~s[<div class="dm-skeleton h-4 w-24">]

      # Should have 3 fields + 1 submit button = 4 dm-form-group divs
      # 4 controls + 1 split
      assert result |> String.split("dm-form-group") |> length() == 5
    end

    test "renders form skeleton without submit button" do
      result = render_component(&dm_skeleton_form/1, %{fields: 2, show_submit: false})

      # Should have exactly 2 dm-form-group divs
      # 2 controls + 1 split
      assert result |> String.split("dm-form-group") |> length() == 3
    end

    test "renders form skeleton with custom field types" do
      result =
        render_component(&dm_skeleton_form/1, %{
          fields: 3,
          field_types: ["text", "textarea", "checkbox"]
        })

      # text field
      assert result =~ ~s[dm-skeleton h-10 w-full]
      # textarea
      assert result =~ ~s[dm-skeleton h-24 w-full]
      # checkbox
      assert result =~ ~s[dm-skeleton h-4 w-4]
    end

    test "renders form skeleton with animation" do
      result = render_component(&dm_skeleton_form/1, %{animation: "bounce"})

      assert result =~ ~s[animate-bounce]
    end
  end

  describe "dm_skeleton_form/1 edge cases" do
    test "renders form skeleton with auto-generated field_types for 5 fields" do
      result = render_component(&dm_skeleton_form/1, %{fields: 5})

      # Auto-gen: ["text", "select", "textarea", "checkbox"] + 1 padded "text"
      # text => h-10, textarea => h-24, checkbox => h-4 w-4
      assert result =~ "dm-skeleton h-10 w-full"
      assert result =~ "dm-skeleton h-24 w-full"
      assert result =~ "dm-skeleton h-4 w-4"
    end

    test "renders form skeleton with fields 0 shows no field groups" do
      result = render_component(&dm_skeleton_form/1, %{fields: 0, show_submit: false})

      refute result =~ "dm-form-group"
    end

    test "renders form skeleton with fields 0 and submit shows only submit" do
      result = render_component(&dm_skeleton_form/1, %{fields: 0, show_submit: true})

      # Only 1 dm-form-group for the submit button
      assert result |> String.split("dm-form-group") |> length() == 2
    end

    test "renders form skeleton with 1 field auto-generates text type" do
      result = render_component(&dm_skeleton_form/1, %{fields: 1, show_submit: false})

      assert result =~ "dm-skeleton h-10 w-full"
      assert result |> String.split("dm-form-group") |> length() == 2
    end

    test "renders form skeleton with select field type" do
      result =
        render_component(&dm_skeleton_form/1, %{
          fields: 1,
          field_types: ["select"],
          show_submit: false
        })

      # select renders same as text: h-10 w-full
      assert result =~ "dm-skeleton h-10 w-full"
    end

    test "renders form skeleton with unknown field type defaults to text size" do
      result =
        render_component(&dm_skeleton_form/1, %{
          fields: 1,
          field_types: ["unknown_type"],
          show_submit: false
        })

      # Unknown type falls through to default: h-10 w-full
      assert result =~ "dm-skeleton h-10 w-full"
    end
  end

  describe "dm_skeleton_text/1 edge cases" do
    test "renders text skeleton with 1 line (only last line)" do
      result = render_component(&dm_skeleton_text/1, %{lines: 1})

      assert result =~ "space-y-2"
      # Only the last line rendered (no loop for lines > 1)
      assert result
             |> String.split("<div class=\"dm-skeleton h-4")
             |> length()
             |> Kernel.-(1) == 1
    end

    test "renders text skeleton with id" do
      result = render_component(&dm_skeleton_text/1, %{id: "text-skel"})

      assert result =~ ~s[id="text-skel"]
    end

    test "renders text skeleton with custom class" do
      result = render_component(&dm_skeleton_text/1, %{class: "my-text-skeleton"})

      assert result =~ "my-text-skeleton"
    end
  end

  describe "dm_skeleton_comment/1 edge cases" do
    test "renders comment skeleton with show_replies 0 (no replies section)" do
      result = render_component(&dm_skeleton_comment/1, %{show_replies: 0})

      refute result =~ "ml-12 space-y-4"
      refute result =~ "flex gap-3"
    end

    test "renders comment skeleton with id" do
      result = render_component(&dm_skeleton_comment/1, %{id: "comment-skel"})

      assert result =~ ~s[id="comment-skel"]
    end

    test "renders comment skeleton with custom class" do
      result = render_component(&dm_skeleton_comment/1, %{class: "my-comment"})

      assert result =~ "my-comment"
    end
  end

  describe "dm_skeleton_card/1 edge cases" do
    test "renders card skeleton with avatar and action combined" do
      result =
        render_component(&dm_skeleton_card/1, %{
          show_avatar: true,
          show_action: true,
          lines: 2,
          animation: "pulse"
        })

      assert result =~ "dm-avatar dm-avatar--placeholder"
      assert result =~ "dm-card__actions"
      assert result =~ "dm-skeleton h-10 w-20"
      assert result =~ "animate-pulse"
    end

    test "renders card skeleton with custom avatar size" do
      result = render_component(&dm_skeleton_card/1, %{show_avatar: true, avatar_size: "lg"})

      assert result =~ "w-lg h-lg"
    end

    test "renders card skeleton with id" do
      result = render_component(&dm_skeleton_card/1, %{id: "card-skel"})

      assert result =~ ~s[id="card-skel"]
    end

    test "renders card skeleton with custom class" do
      result = render_component(&dm_skeleton_card/1, %{class: "my-card-skel"})

      assert result =~ "my-card-skel"
    end
  end

  describe "dm_skeleton_table/1 edge cases" do
    test "renders table skeleton with id" do
      result = render_component(&dm_skeleton_table/1, %{id: "tbl-skel"})

      assert result =~ ~s[id="tbl-skel"]
    end

    test "renders table skeleton with custom class" do
      result = render_component(&dm_skeleton_table/1, %{class: "my-table-skel"})

      assert result =~ "my-table-skel"
    end

    test "renders table skeleton with all options combined" do
      result =
        render_component(&dm_skeleton_table/1, %{
          id: "full-tbl",
          class: "w-full",
          rows: 2,
          columns: 3,
          show_header: true,
          animation: "wave"
        })

      assert result =~ ~s[id="full-tbl"]
      assert result =~ "w-full"
      assert result =~ "animate-wave"
      assert result =~ "<thead>"
      # 2 header cells + 6 data cells = 8 total (3 th + 6 td)
      assert result |> String.split("<th>") |> length() == 4
      assert result |> String.split("<td>") |> length() == 7
    end
  end

  describe "dm_skeleton_list/1 edge cases" do
    test "renders list skeleton with id" do
      result = render_component(&dm_skeleton_list/1, %{id: "list-skel"})

      assert result =~ ~s[id="list-skel"]
    end

    test "renders list skeleton with custom class" do
      result = render_component(&dm_skeleton_list/1, %{class: "my-list-skel"})

      assert result =~ "my-list-skel"
    end

    test "renders list skeleton with custom avatar size" do
      result =
        render_component(&dm_skeleton_list/1, %{
          show_avatar: true,
          avatar_size: "lg"
        })

      assert result =~ "w-lg h-lg"
    end

    test "renders list skeleton with all options combined" do
      result =
        render_component(&dm_skeleton_list/1, %{
          id: "full-list",
          class: "border rounded",
          items: 3,
          show_avatar: true,
          avatar_size: "sm",
          lines_per_item: 2,
          animation: "pulse"
        })

      assert result =~ ~s[id="full-list"]
      assert result =~ "border rounded"
      assert result =~ "animate-pulse"
      assert result =~ "dm-avatar"
      assert result |> String.split("flex items-start gap-3") |> length() == 4
    end
  end

  describe "dm_skeleton_comment/1 combined" do
    test "renders comment skeleton with animation and replies" do
      result =
        render_component(&dm_skeleton_comment/1, %{
          show_replies: 3,
          animation: "wave"
        })

      assert result =~ "animate-wave"
      assert result =~ "ml-12 space-y-4"
      assert result |> String.split("flex gap-3") |> length() == 4
    end

    test "renders comment skeleton with all options" do
      result =
        render_component(&dm_skeleton_comment/1, %{
          id: "comment-full",
          class: "border-l",
          show_replies: 1,
          animation: "bounce"
        })

      assert result =~ ~s[id="comment-full"]
      assert result =~ "border-l"
      assert result =~ "animate-bounce"
      assert result =~ "ml-12"
    end
  end

  describe "dm_skeleton/1 edge cases" do
    test "renders skeleton with width and height" do
      result = render_component(&dm_skeleton/1, %{width: "w-48", height: "h-12"})

      assert result =~ "w-48"
      assert result =~ "h-12"
    end

    test "renders skeleton with variant and size combined" do
      result = render_component(&dm_skeleton/1, %{variant: "square", size: "xl"})

      assert result =~ "dm-skeleton--square"
      assert result =~ "dm-skeleton--xl"
    end
  end

  describe "dm_skeleton_avatar/1 edge cases" do
    test "renders avatar skeleton with id" do
      result = render_component(&dm_skeleton_avatar/1, %{id: "avatar-skel"})

      assert result =~ ~s[id="avatar-skel"]
    end

    test "renders avatar skeleton with all sizes" do
      for size <- ~w(xs sm md lg xl) do
        result = render_component(&dm_skeleton_avatar/1, %{size: size})
        assert result =~ "w-#{size} h-#{size}"
      end
    end
  end

  describe "dm_skeleton_comment/1" do
    test "renders basic comment skeleton" do
      result = render_component(&dm_skeleton_comment/1, %{})

      assert result =~ ~s[class="space-y-4"]
      assert result =~ ~s[flex gap-4]
      assert result =~ ~s[dm-avatar dm-avatar--placeholder]
      assert result =~ ~s[flex items-center gap-2]
      # name
      assert result =~ ~s[dm-skeleton h-4 w-20]
      # timestamp
      assert result =~ ~s[dm-skeleton h-3 w-16]
    end

    test "renders comment skeleton with replies" do
      result = render_component(&dm_skeleton_comment/1, %{show_replies: 2})

      # replies container
      assert result =~ ~s[ml-12 space-y-4]
      # Should have main comment + 2 replies
      # 2 replies + 1 split
      assert result |> String.split("flex gap-3") |> length() == 3
    end

    test "renders comment skeleton with animation" do
      result = render_component(&dm_skeleton_comment/1, %{animation: "pulse"})

      assert result =~ ~s[animate-pulse]
    end
  end
end
