defmodule PhoenixDuskmoon.ArtComponent.GeminiInput do
  @moduledoc """
  Gemini-style animated gradient input art component using the
  `<el-dm-art-gemini-input>` custom element.

  ## Examples

      <.dm_art_gemini_input id="gemini-1" />

      <.dm_art_gemini_input id="gemini-2" size="lg" placeholder="Ask me anything..." />

  """

  use Phoenix.Component

  @doc """
  Renders a Gemini-style animated gradient input using the
  `<el-dm-art-gemini-input>` custom element.

  ## Examples

      <.dm_art_gemini_input id="gemini" />

      <.dm_art_gemini_input id="gemini-lg" size="lg" placeholder="Type here..." />

  """
  @doc type: :component
  attr(:id, :string, required: true)
  attr(:class, :any, default: nil)
  attr(:size, :string, default: nil, values: [nil, "sm", "md", "lg"])
  attr(:placeholder, :string, default: nil)
  attr(:rest, :global)

  def dm_art_gemini_input(assigns) do
    ~H"""
    <style>
      @property --art-gemini-input-rotation {
        syntax: '<angle>';
        inherits: false;
        initial-value: 0deg;
      }
      @keyframes art-gemini-input-rotate {
        to { --art-gemini-input-rotation: 360deg; }
      }
    </style>
    <el-dm-art-gemini-input
      id={@id}
      class={@class}
      size={@size}
      placeholder={@placeholder}
      {@rest}
    ></el-dm-art-gemini-input>
    """
  end
end
