defmodule DuskmoonStorybookWeb.ArtComponentHTML do
  use DuskmoonStorybookWeb, :html
  use PhoenixDuskmoon.ArtComponent

  embed_templates("art_component_html/*")
end
