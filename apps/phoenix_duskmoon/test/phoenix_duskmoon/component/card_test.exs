defmodule PhoenixDuskmoon.Component.CardTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.Card

  test "renders basic card" do
    assert render_component(&dm_card/1, %{
             inner_block: %{inner_block: fn _, _ -> "Card content" end}
           }) ==
             ~s[<div class="card ">\n  \n  <div class="card-body ">\n    \n    Card content\n    \n  </div>\n</div>]
  end

  test "renders card with custom class" do
    assert render_component(&dm_card/1, %{
             class: "card-compact",
             inner_block: %{inner_block: fn _, _ -> "Compact card" end}
           }) ==
             ~s[<div class="card card-compact">\n  \n  <div class="card-body ">\n    \n    Compact card\n    \n  </div>\n</div>]
  end

  test "renders card with custom body class" do
    assert render_component(&dm_card/1, %{
             body_class: "p-4",
             inner_block: %{inner_block: fn _, _ -> "Custom padding" end}
           }) ==
             ~s[<div class="card ">\n  \n  <div class="card-body p-4">\n    \n    Custom padding\n    \n  </div>\n</div>]
  end

  test "renders card with id" do
    assert render_component(&dm_card/1, %{
             id: "test-card",
             inner_block: %{inner_block: fn _, _ -> "Test card" end}
           }) ==
             ~s[<div id="test-card" class="card ">\n  \n  <div class="card-body ">\n    \n    Test card\n    \n  </div>\n</div>]
  end

  test "renders card with title" do
    result =
      render_component(&dm_card/1, %{
        title: [%{inner_block: fn _, _ -> "Card Title" end}],
        inner_block: %{inner_block: fn _, _ -> "Card content" end}
      })

    assert result =~ ~s[<div class="card-title ">\n      Card Title\n    </div>]
    assert result =~ ~s[Card content]
  end

  test "renders card with title and custom title class" do
    result =
      render_component(&dm_card/1, %{
        title: [%{class: "text-xl", inner_block: fn _, _ -> "Custom Title" end}],
        inner_block: %{inner_block: fn _, _ -> "Card content" end}
      })

    assert result =~ ~s[<div class="card-title text-xl">\n      Custom Title\n    </div>]
  end

  test "renders card with title and id" do
    result =
      render_component(&dm_card/1, %{
        title: [%{id: "title-id", inner_block: fn _, _ -> "Titled Card" end}],
        inner_block: %{inner_block: fn _, _ -> "Card content" end}
      })

    assert result =~ ~s[<div id="title-id" class="card-title ">\n      Titled Card\n    </div>]
  end

  test "renders card with action" do
    result =
      render_component(&dm_card/1, %{
        action: [%{inner_block: fn _, _ -> "Action Button" end}],
        inner_block: %{inner_block: fn _, _ -> "Card content" end}
      })

    assert result =~ ~s[<div class="card-actions ">\n      Action Button\n    </div>]
    assert result =~ ~s[Card content]
  end

  test "renders card with action and custom action class" do
    result =
      render_component(&dm_card/1, %{
        action: [%{class: "justify-end", inner_block: fn _, _ -> "Custom Action" end}],
        inner_block: %{inner_block: fn _, _ -> "Card content" end}
      })

    assert result =~ ~s[<div class="card-actions justify-end">\n      Custom Action\n    </div>]
  end

  test "renders card with action and id" do
    result =
      render_component(&dm_card/1, %{
        action: [%{id: "action-id", inner_block: fn _, _ -> "Action" end}],
        inner_block: %{inner_block: fn _, _ -> "Card content" end}
      })

    assert result =~ ~s[<div id="action-id" class="card-actions ">\n      Action\n    </div>]
  end

  test "renders card with title and action" do
    result =
      render_component(&dm_card/1, %{
        title: [%{inner_block: fn _, _ -> "Card Title" end}],
        action: [%{inner_block: fn _, _ -> "Action Button" end}],
        inner_block: %{inner_block: fn _, _ -> "Card content" end}
      })

    assert result =~ ~s[<div class="card-title ">\n      Card Title\n    </div>]
    assert result =~ ~s[Card content]
    assert result =~ ~s[<div class="card-actions ">\n      Action Button\n    </div>]
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

    assert result =~ ~s[<div class="card-title ">\n      Title 1\n    </div>]
    assert result =~ ~s[<div class="card-title ">\n      Title 2\n    </div>]
    assert result =~ ~s[<div class="card-actions ">\n      Action 1\n    </div>]
    assert result =~ ~s[<div class="card-actions ">\n      Action 2\n    </div>]
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
