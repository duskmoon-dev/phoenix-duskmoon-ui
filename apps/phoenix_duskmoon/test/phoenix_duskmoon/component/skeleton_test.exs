defmodule PhoenixDuskmoon.Component.SkeletonTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.Skeleton

  describe "dm_skeleton/1" do
    test "renders basic skeleton" do
      assert render_component(&dm_skeleton/1, %{}) ==
               ~s[<div class="skeleton"></div>]
    end

    test "renders skeleton with custom class" do
      assert render_component(&dm_skeleton/1, %{class: "w-32 h-4"}) ==
               ~s[<div class="skeleton w-32 h-4"></div>]
    end

    test "renders skeleton with variant" do
      assert render_component(&dm_skeleton/1, %{variant: "circle"}) ==
               ~s[<div class="skeleton skeleton-circle"></div>]
    end

    test "renders skeleton with size" do
      assert render_component(&dm_skeleton/1, %{size: "md"}) ==
               ~s[<div class="skeleton skeleton-md"></div>]
    end

    test "renders skeleton with animation" do
      assert render_component(&dm_skeleton/1, %{animation: "pulse"}) ==
               ~s[<div class="skeleton animate-pulse"></div>]
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
               ~s[<div class="skeleton skeleton-avatar skeleton-lg animate-wave w-16 h-16 rounded-full"></div>]
    end

    test "renders skeleton with id" do
      assert render_component(&dm_skeleton/1, %{id: "skeleton-1"}) ==
               ~s[<div id="skeleton-1" class="skeleton"></div>]
    end
  end

  describe "dm_skeleton_text/1" do
    test "renders text skeleton with default lines" do
      result = render_component(&dm_skeleton_text/1, %{})
      assert result =~ ~s[<div class="space-y-2">]
      assert result =~ ~s[<div class="skeleton h-4 w-full"></div>]
      # Should have 3 lines total (2 full width + 1 last line)
      assert result |> String.split("<div class=\"skeleton h-4 w-full") |> length() |> Kernel.-(1) ==
               3

      assert result =~ ~s[<div class="skeleton h-4 w-full"></div>]
    end

    test "renders text skeleton with custom lines" do
      result = render_component(&dm_skeleton_text/1, %{lines: 5})
      assert result =~ ~s[<div class="space-y-2">]
      assert result =~ ~s[<div class="skeleton h-4 w-full"></div>]
      # Should have 5 lines total (4 full width + 1 last line)
      assert result |> String.split("<div class=\"skeleton h-4 w-full") |> length() |> Kernel.-(1) ==
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

      assert result =~ ~s[<div class="space-y-2">]
      assert result =~ ~s[<div class="skeleton h-6 w-full"></div>]
      assert result =~ ~s[<div class="skeleton h-6 w-3/4"></div>]
    end

    test "renders text skeleton with animation" do
      result = render_component(&dm_skeleton_text/1, %{animation: "pulse"})

      assert result =~ ~s[animate-pulse]
    end
  end

  describe "dm_skeleton_avatar/1" do
    test "renders avatar skeleton with default size" do
      result = render_component(&dm_skeleton_avatar/1, %{})

      assert result =~ ~s[<div class="avatar placeholder">]
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

      assert result =~ ~s[<div class="card bg-base-100 shadow-xl">]
      assert result =~ ~s[<div class="card-body">]
      assert result =~ ~s[<div class="skeleton h-6 w-3/4 mb-4">]
      assert result =~ ~s[<div class="space-y-2">]
    end

    test "renders card skeleton with avatar" do
      result = render_component(&dm_skeleton_card/1, %{show_avatar: true})

      assert result =~ ~s[<div class="avatar placeholder">]
      assert result =~ ~s[flex items-start gap-4]
    end

    test "renders card skeleton with custom lines" do
      result = render_component(&dm_skeleton_card/1, %{lines: 5})

      # Should have 5 skeleton lines
      # 5 lines + 1 title
      assert result |> String.split("skeleton h-4") |> length() == 6
    end

    test "renders card skeleton with action button" do
      result = render_component(&dm_skeleton_card/1, %{show_action: true})

      assert result =~ ~s[<div class="card-actions justify-end mt-4">]
      assert result =~ ~s[<div class="skeleton h-10 w-20">]
    end

    test "renders card skeleton with animation" do
      result = render_component(&dm_skeleton_card/1, %{animation: "pulse"})

      assert result =~ ~s[animate-pulse]
    end
  end

  describe "dm_skeleton_table/1" do
    test "renders table skeleton with header" do
      result = render_component(&dm_skeleton_table/1, %{rows: 3, columns: 2})

      assert result =~ ~s[<table class="table">]
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

      assert result =~ ~s[<div class="space-y-4">]
      assert result =~ ~s[flex items-start gap-3]
      assert result =~ ~s[flex-1]

      # Should have 3 items
      # 3 items + 1 split
      assert result |> String.split("flex items-start gap-3") |> length() == 4
    end

    test "renders list skeleton with avatars" do
      result = render_component(&dm_skeleton_list/1, %{items: 2, show_avatar: true})

      # 2 avatars + 1 split
      assert result |> String.split("avatar placeholder") |> length() == 3
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

      assert result =~ ~s[<form class="space-y-6">]
      assert result =~ ~s[<div class="form-control">]
      assert result =~ ~s[<div class="label">]
      assert result =~ ~s[<div class="skeleton h-4 w-24">]

      # Should have 3 fields + 1 submit button = 4 form-control divs
      # 4 controls + 1 split
      assert result |> String.split("form-control") |> length() == 5
    end

    test "renders form skeleton without submit button" do
      result = render_component(&dm_skeleton_form/1, %{fields: 2, show_submit: false})

      # Should have exactly 2 form-control divs
      # 2 controls + 1 split
      assert result |> String.split("form-control") |> length() == 3
    end

    test "renders form skeleton with custom field types" do
      result =
        render_component(&dm_skeleton_form/1, %{
          fields: 3,
          field_types: ["text", "textarea", "checkbox"]
        })

      # text field
      assert result =~ ~s[skeleton h-10 w-full]
      # textarea
      assert result =~ ~s[skeleton h-24 w-full]
      # checkbox
      assert result =~ ~s[skeleton h-4 w-4]
    end

    test "renders form skeleton with animation" do
      result = render_component(&dm_skeleton_form/1, %{animation: "bounce"})

      assert result =~ ~s[animate-bounce]
    end
  end

  describe "dm_skeleton_comment/1" do
    test "renders basic comment skeleton" do
      result = render_component(&dm_skeleton_comment/1, %{})

      assert result =~ ~s[<div class="space-y-4">]
      assert result =~ ~s[flex gap-4]
      assert result =~ ~s[avatar placeholder]
      assert result =~ ~s[flex items-center gap-2]
      # name
      assert result =~ ~s[skeleton h-4 w-20]
      # timestamp
      assert result =~ ~s[skeleton h-3 w-16]
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
