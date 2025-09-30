defmodule PhoenixDuskmoon.Component.IconsTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.Icons

  test "mdi_icons returns list of available Material Design Icons" do
    icons = mdi_icons()
    assert is_list(icons)
    assert length(icons) > 0
    assert "abacus" in icons
    assert "account" in icons
  end

  test "bsi_icons returns list of available Bootstrap Icons" do
    icons = bsi_icons()
    assert is_list(icons)
    assert length(icons) > 0
    assert "0-circle" in icons
    assert "1-circle" in icons
  end

  test "renders Material Design Icon with basic attributes" do
    result = render_component(&dm_mdi/1, %{name: "account"})

    assert result =~ ~s[<svg xmlns="http://www.w3.org/2000/svg"]
    assert result =~ ~s[fill="currentcolor"]
    assert result =~ ~s[viewBox="0 0 24 24"]
    assert result =~ ~s[<path d="]
  end

  test "renders Material Design Icon with custom id" do
    result = render_component(&dm_mdi/1, %{name: "account", id: "test-icon"})

    assert result =~ ~s[id="test-icon"]
    assert result =~ ~s[<svg xmlns="http://www.w3.org/2000/svg"]
  end

  test "renders Material Design Icon with custom class" do
    result = render_component(&dm_mdi/1, %{name: "account", class: "w-6 h-6"})

    assert result =~ ~s[class="w-6 h-6"]
    assert result =~ ~s[<svg xmlns="http://www.w3.org/2000/svg"]
  end

  test "renders Material Design Icon with custom color" do
    result = render_component(&dm_mdi/1, %{name: "account", color: "#ff0000"})

    assert result =~ ~s[fill="#ff0000"]
    assert result =~ ~s[<svg xmlns="http://www.w3.org/2000/svg"]
  end

  test "renders Material Design Icon with all custom attributes" do
    result =
      render_component(&dm_mdi/1, %{
        name: "account",
        id: "custom-icon",
        class: "w-8 h-8 text-red-500",
        color: "red"
      })

    assert result =~ ~s[id="custom-icon"]
    assert result =~ ~s[class="w-8 h-8 text-red-500"]
    assert result =~ ~s[fill="red"]
    assert result =~ ~s[<svg xmlns="http://www.w3.org/2000/svg"]
  end

  test "renders Bootstrap Icon with basic attributes" do
    result = render_component(&dm_bsi/1, %{name: "0-circle"})

    assert result =~ ~s[<svg xmlns="http://www.w3.org/2000/svg"]
    assert result =~ ~s[fill="currentcolor"]
    assert result =~ ~s[viewBox="0 0 16 16"]
    assert result =~ ~s[<path d="]
  end

  test "renders Bootstrap Icon with custom id" do
    result = render_component(&dm_bsi/1, %{name: "0-circle", id: "test-bsi-icon"})

    assert result =~ ~s[id="test-bsi-icon"]
    assert result =~ ~s[<svg xmlns="http://www.w3.org/2000/svg"]
  end

  test "renders Bootstrap Icon with custom class" do
    result = render_component(&dm_bsi/1, %{name: "0-circle", class: "w-4 h-4"})

    assert result =~ ~s[class="w-4 h-4"]
    assert result =~ ~s[<svg xmlns="http://www.w3.org/2000/svg"]
  end

  test "renders Bootstrap Icon with custom color" do
    result = render_component(&dm_bsi/1, %{name: "0-circle", color: "#00ff00"})

    assert result =~ ~s[fill="#00ff00"]
    assert result =~ ~s[<svg xmlns="http://www.w3.org/2000/svg"]
  end

  test "renders Bootstrap Icon with all custom attributes" do
    result =
      render_component(&dm_bsi/1, %{
        name: "0-circle",
        id: "custom-bsi-icon",
        class: "w-6 h-6 text-blue-500",
        color: "blue"
      })

    assert result =~ ~s[id="custom-bsi-icon"]
    assert result =~ ~s[class="w-6 h-6 text-blue-500"]
    assert result =~ ~s[fill="blue"]
    assert result =~ ~s[<svg xmlns="http://www.w3.org/2000/svg"]
  end

  test "raises error when Material Design Icon name is not provided" do
    assert_raise KeyError, ~r/key :name not found/, fn ->
      render_component(&dm_mdi/1, %{})
    end
  end

  test "raises error when Bootstrap Icon name is not provided" do
    assert_raise KeyError, ~r/key :name not found/, fn ->
      render_component(&dm_bsi/1, %{})
    end
  end

  test "mdi_icons list is sorted alphabetically" do
    icons = mdi_icons()
    assert icons == Enum.sort(icons)
  end

  test "bsi_icons list is sorted alphabetically" do
    icons = bsi_icons()
    assert icons == Enum.sort(icons)
  end
end
