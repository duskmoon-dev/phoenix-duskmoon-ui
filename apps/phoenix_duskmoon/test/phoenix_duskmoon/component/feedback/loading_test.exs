defmodule PhoenixDuskmoon.Component.Feedback.LoadingTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.Feedback.Loading

  test "renders loading spinner" do
    result = render_component(&dm_loading_spinner/1, %{})

    assert result =~ "dm-loading-container"
  end

  test "renders loading spinner with size" do
    result = render_component(&dm_loading_spinner/1, %{size: "lg"})

    assert result =~ "dm-loading-container"
    assert result =~ "dm-loading-spinner--lg"
  end

  test "renders loading spinner with variant" do
    result = render_component(&dm_loading_spinner/1, %{variant: "success"})

    assert result =~ "dm-loading-spinner--success"
  end

  test "renders loading spinner with text" do
    result = render_component(&dm_loading_spinner/1, %{text: "Loading..."})

    assert result =~ "Loading..."
  end

  test "renders advanced particle loader" do
    result = render_component(&dm_loading_ex/1, %{})

    assert result =~ "loader-"
  end

  test "renders advanced loader with custom item count" do
    result = render_component(&dm_loading_ex/1, %{item_count: 44})

    assert result =~ "loader-"
  end

  test "renders advanced loader with custom speed" do
    result = render_component(&dm_loading_ex/1, %{speed: "2s"})

    assert result =~ "2s"
  end
end
