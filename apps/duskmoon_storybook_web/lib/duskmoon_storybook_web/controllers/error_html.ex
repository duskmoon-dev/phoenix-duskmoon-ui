defmodule DuskmoonStorybookWeb.ErrorHTML do
  @moduledoc """
  Error page rendering for the storybook web application.

  Returns plain text status messages (e.g. "Not Found" for 404).
  """

  def render(template, _assigns) do
    Phoenix.Controller.status_message_from_template(template)
  end
end
