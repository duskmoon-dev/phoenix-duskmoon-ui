defmodule Storybook do
  # Temporarily disabled to fix CI/CD pipeline
  # TODO: Fix PhoenixStorybook folder_name issue and re-enable
  # 
  # use PhoenixStorybook,
  #   otp_app: :duskmoon_storybook_web,
  #   content_path: Path.expand("storybook", __DIR__),
  #   title: "Phoenix Duskmoon UI Storybook",
  #   compilation_mode: :lazy
end
