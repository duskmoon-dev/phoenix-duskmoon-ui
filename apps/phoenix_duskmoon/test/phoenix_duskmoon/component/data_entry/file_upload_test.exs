defmodule PhoenixDuskmoon.Component.DataEntry.FileUploadTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest

  import PhoenixDuskmoon.Component.DataEntry.FileUpload

  describe "dm_file_upload basic rendering" do
    test "renders el-dm-file-upload element" do
      result = render_component(&dm_file_upload/1, %{})
      assert result =~ "<el-dm-file-upload"
      assert result =~ "</el-dm-file-upload>"
    end

    test "renders with custom id" do
      result = render_component(&dm_file_upload/1, %{id: "my-upload"})
      assert result =~ ~s(id="my-upload")
    end

    test "renders with custom class" do
      result = render_component(&dm_file_upload/1, %{class: "w-full"})
      assert result =~ "w-full"
    end

    test "renders inner_block content" do
      result =
        render_component(&dm_file_upload/1, %{
          inner_block: [
            %{__slot__: :inner_block, inner_block: fn _, _ -> "Drop files here" end}
          ]
        })

      assert result =~ "Drop files here"
    end
  end

  describe "dm_file_upload accept" do
    test "no accept by default" do
      result = render_component(&dm_file_upload/1, %{})
      refute result =~ ~s(accept=")
    end

    test "renders accept attribute" do
      result = render_component(&dm_file_upload/1, %{accept: "image/*"})
      assert result =~ ~s(accept="image/*")
    end

    test "renders accept with multiple types" do
      result = render_component(&dm_file_upload/1, %{accept: ".pdf,.doc,.docx"})
      assert result =~ ~s(accept=".pdf,.doc,.docx")
    end
  end

  describe "dm_file_upload multiple" do
    test "not multiple by default" do
      result = render_component(&dm_file_upload/1, %{})
      refute result =~ ~s( multiple)
    end

    test "renders multiple when true" do
      result = render_component(&dm_file_upload/1, %{multiple: true})
      assert result =~ "multiple"
    end
  end

  describe "dm_file_upload disabled" do
    test "not disabled by default" do
      result = render_component(&dm_file_upload/1, %{})
      refute result =~ ~s( disabled)
    end

    test "renders disabled when true" do
      result = render_component(&dm_file_upload/1, %{disabled: true})
      assert result =~ "disabled"
    end
  end

  describe "dm_file_upload max_size" do
    test "no max-size by default" do
      result = render_component(&dm_file_upload/1, %{})
      refute result =~ "max-size"
    end

    test "renders max-size attribute" do
      result = render_component(&dm_file_upload/1, %{max_size: 5_242_880})
      assert result =~ ~s(max-size="5242880")
    end
  end

  describe "dm_file_upload max_files" do
    test "no max-files by default" do
      result = render_component(&dm_file_upload/1, %{})
      refute result =~ "max-files"
    end

    test "renders max-files attribute" do
      result = render_component(&dm_file_upload/1, %{max_files: 5})
      assert result =~ ~s(max-files="5")
    end
  end

  describe "dm_file_upload show_preview" do
    test "no show-preview by default" do
      result = render_component(&dm_file_upload/1, %{})
      refute result =~ "show-preview"
    end

    test "renders show-preview when true" do
      result = render_component(&dm_file_upload/1, %{show_preview: true})
      assert result =~ "show-preview"
    end
  end

  describe "dm_file_upload compact" do
    test "not compact by default" do
      result = render_component(&dm_file_upload/1, %{})
      refute result =~ ~s( compact)
    end

    test "renders compact when true" do
      result = render_component(&dm_file_upload/1, %{compact: true})
      assert result =~ "compact"
    end
  end

  describe "dm_file_upload size" do
    test "defaults to md" do
      result = render_component(&dm_file_upload/1, %{})
      assert result =~ ~s(size="md")
    end

    test "renders sm size" do
      result = render_component(&dm_file_upload/1, %{size: "sm"})
      assert result =~ ~s(size="sm")
    end

    test "renders lg size" do
      result = render_component(&dm_file_upload/1, %{size: "lg"})
      assert result =~ ~s(size="lg")
    end
  end

  describe "error messages" do
    test "renders error messages from errors list" do
      result =
        render_component(&dm_file_upload/1, %{
          errors: ["file too large"]
        })

      assert result =~ "file too large"
      assert result =~ "file-upload-error"
    end

    test "does not render errors when list is empty" do
      result =
        render_component(&dm_file_upload/1, %{
          errors: []
        })

      refute result =~ "helper-text helper-text-error"
    end

    test "shows error state from errors list even without error boolean" do
      result =
        render_component(&dm_file_upload/1, %{
          errors: ["invalid file type"]
        })

      assert result =~ "file-upload-error"
    end

    test "renders aria-invalid when errors present" do
      result =
        render_component(&dm_file_upload/1, %{
          errors: ["file too large"]
        })

      assert result =~ ~s(aria-invalid="true")
    end

    test "no aria-invalid when no errors" do
      result = render_component(&dm_file_upload/1, %{})
      refute result =~ "aria-invalid"
    end
  end

  describe "aria-describedby" do
    test "references errors container when errors present" do
      result =
        render_component(&dm_file_upload/1, %{
          id: "fu",
          errors: ["file too large"]
        })

      assert result =~ ~s(aria-describedby="fu-errors")
    end

    test "references helper when no errors" do
      result =
        render_component(&dm_file_upload/1, %{
          id: "fu",
          helper: "Max 5MB"
        })

      assert result =~ ~s(aria-describedby="fu-helper")
    end

    test "no aria-describedby when no id" do
      result =
        render_component(&dm_file_upload/1, %{
          errors: ["file too large"]
        })

      refute result =~ "aria-describedby"
    end
  end

  test "renders phx-feedback-for with name" do
    result =
      render_component(&dm_file_upload/1, %{
        name: "user[avatar]"
      })

    assert result =~ ~s(phx-feedback-for="user[avatar]")
  end

  describe "helper text" do
    test "renders helper text when provided" do
      result =
        render_component(&dm_file_upload/1, %{
          id: "fu",
          helper: "Max 5MB per file"
        })

      assert result =~ "helper-text"
      assert result =~ "Max 5MB per file"
    end

    test "hides helper text when errors present" do
      result =
        render_component(&dm_file_upload/1, %{
          id: "fu",
          helper: "Max 5MB per file",
          errors: ["file too large"]
        })

      refute result =~ "Max 5MB per file"
      assert result =~ "file too large"
    end
  end

  describe "dm_file_upload with form field" do
    test "extracts id and name from FormField" do
      field = Phoenix.Component.to_form(%{"avatar" => nil}, as: "user")[:avatar]

      result = render_component(&dm_file_upload/1, %{field: field})
      assert result =~ ~s(id="user_avatar")
      assert result =~ ~s(phx-feedback-for="user[avatar]")
    end

    test "id attr overrides field id" do
      field = Phoenix.Component.to_form(%{"avatar" => nil}, as: "user")[:avatar]

      result = render_component(&dm_file_upload/1, %{field: field, id: "custom-id"})
      assert result =~ ~s(id="custom-id")
    end
  end

  describe "dm_file_upload combined attrs" do
    test "renders with all attrs" do
      result =
        render_component(&dm_file_upload/1, %{
          id: "photo-upload",
          class: "border-dashed",
          accept: "image/*",
          multiple: true,
          max_size: 10_485_760,
          max_files: 10,
          show_preview: true,
          size: "lg",
          inner_block: [
            %{__slot__: :inner_block, inner_block: fn _, _ -> "Upload photos" end}
          ]
        })

      assert result =~ ~s(id="photo-upload")
      assert result =~ "border-dashed"
      assert result =~ ~s(accept="image/*")
      assert result =~ "multiple"
      assert result =~ ~s(max-size="10485760")
      assert result =~ ~s(max-files="10")
      assert result =~ "show-preview"
      assert result =~ ~s(size="lg")
      assert result =~ "Upload photos"
    end
  end
end
